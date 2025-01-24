"""
Reads from the BlueSky Jetstream via websocket and stores the data in object storage.
"""

import asyncio
import io

from prefect import flow, get_run_logger
import duckdb
import pendulum
import websockets

JETSTREAM_URL = "wss://jetstream1.us-west.bsky.network/subscribe?wantedCollections=app.bsky.feed.post"


@flow
async def source_jetstream(limit: int = 1_000):
    idx = 0
    logger = get_run_logger()

    # Read the messages from the jetstream into memory
    with io.StringIO() as fh:
        logger.info(f"Reading {limit} messages from the jetstream")
        async with websockets.connect(JETSTREAM_URL) as ws:
            while idx < limit:
                message = await ws.recv()
                fh.write(message)
                idx += 1

        logger.info(f"Writing {limit} messages to disk as a parquet file")
        with duckdb.connect() as con:
            # Reset the file pointer to the beginning of the file
            fh.seek(0)
            # Write the data to disk as a parquet file
            con.read_json(fh).write_parquet(
                f"jetstream-{pendulum.now().isoformat()}.parquet"
            )


if __name__ == "__main__":
    asyncio.run(source_jetstream())
