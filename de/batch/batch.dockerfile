FROM python:3.11-slim as build
WORKDIR /install
RUN pip install --prefix=/install --no-cache-dir azure-storage-blob psycopg2-binary

FROM python:3.11-slim
COPY --from=build /install /usr/local
WORKDIR /app
COPY move_data.py .
CMD ["python3","move_data.py"]