FROM prefecthq/prefect:3-latest

COPY pyproject.toml .

RUN uv sync

COPY flows/ /opt/prefect/flows/