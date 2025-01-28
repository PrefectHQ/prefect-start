"""
Reads from the BlueSky Jetstream via websocket and stores the data in object storage.
"""

import asyncio
import io
import time
import uuid

from prefect import flow, get_run_logger
from prefect.variables import Variable
import duckdb
import pendulum
import websockets

JETSTREAM_URL = "wss://jetstream1.us-west.bsky.network/subscribe"
BATCH_SIZE = 50_000


async def read_messages(ws, fh):
    # Read the messages from the jetstream into memory
    for _ in range(BATCH_SIZE):
        message = await ws.recv()
        fh.write(message)
    # Reset the file pointer to the beginning of the file
    fh.seek(0)


async def write_messages(con, fh, bucket):
    path = (
        f"{bucket}/source/jetstream/{pendulum.now().isoformat()}-{uuid.uuid4()}.parquet"
    )
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
        # TODO: partition by date
    ).write_parquet(path)
    # Clear the memory buffer
    fh.truncate(0)
    fh.seek(0)
    return path


@flow
async def source_jetstream(batches: int = 100):
    logger = get_run_logger()
    bucket = await Variable.get("storage_bucket")

    # Open connection to the jetstream and duckdb
    async with websockets.connect(JETSTREAM_URL) as ws:
        with duckdb.connect() as con, io.StringIO() as fh:
            # Authenticate to AWS for S3 use
            con.sql("CREATE SECRET (TYPE S3, PROVIDER CREDENTIAL_CHAIN);")

            for _ in range(batches):
                logger.info(f"Reading {BATCH_SIZE} messages from the jetstream")
                _start = time.time()
                await read_messages(ws, fh)
                logger.info(
                    f"Read {BATCH_SIZE} messages in {time.time() - _start:.2f} seconds"
                )

                _start = time.time()
                path = await write_messages(con, fh, bucket)
                logger.info(
                    f"Wrote messages to '{path}' in {time.time() - _start:.2f} seconds"
                )


if __name__ == "__main__":
    asyncio.run(source_jetstream())
