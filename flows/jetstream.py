"""
Reads from the BlueSky Jetstream via websocket and stores the data in object storage.
"""

import asyncio
import io
import time
from prefect import flow, get_run_logger
import duckdb
import pendulum
import websockets

JETSTREAM_URL = "wss://jetstream1.us-west.bsky.network/subscribe?wantedCollections=app.bsky.feed.post"
BATCH_SIZE = 10_000


async def read_messages(ws, fh):
    # Read the messages from the jetstream into memory
    for _ in range(BATCH_SIZE):
        message = await ws.recv()
        fh.write(message)
    # Reset the file pointer to the beginning of the file
    fh.seek(0)


def write_messages(con, fh):
    # Write the messages to disk as a parquet file
    con.read_json(
        fh,
        columns={
            "did": "VARCHAR",
            "time_us": "BIGINT",
            "kind": "VARCHAR",
            "commit": "JSON",
            "identity": "JSON",
            "account": "JSON",
        },
    ).write_parquet(f"data/jetstream-{pendulum.now().isoformat()}.parquet")
    # Clear the memory buffer
    fh.truncate(0)
    fh.seek(0)


@flow
async def source_jetstream(batches: int = 10):
    logger = get_run_logger()

    # Open connection to the jetstream and duckdb
    async with websockets.connect(JETSTREAM_URL) as ws:
        with duckdb.connect() as con, io.StringIO() as fh:
            for _ in range(batches):
                logger.info(f"Reading {BATCH_SIZE} messages from the jetstream")
                _start = time.time()
                await read_messages(ws, fh)
                logger.info(
                    f"Read {BATCH_SIZE} messages in {time.time() - _start:.2f} seconds"
                )

                logger.info(f"Writing {BATCH_SIZE} messages to disk as a parquet file")
                _start = time.time()
                write_messages(con, fh)
                logger.info(
                    f"Wrote {BATCH_SIZE} messages in {time.time() - _start:.2f} seconds"
                )


if __name__ == "__main__":
    asyncio.run(source_jetstream())
