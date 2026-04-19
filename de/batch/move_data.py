#from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import psycopg2 as pg
import sys
import datetime as dt 
import json
from io import StringIO , BytesIO
import csv
import gzip
class Database:
    def __init__(self,conn_url):
        print("connecting database...")
        self.conn = pg.connect(conn_url)
        if self.conn:       
            self.conn
            print("connected datbase...")
        else:
            print("no connection...")
    def select_table(self):
        query = "select * from students where inserted_date::timestamp > now() - interval '1 day'"
        try: 
            cur = self.conn.cursor()
            print("fetching data...")
            cur.execute(query)
            print("data fetched...")
            return cur
        except Exception as e:
            print(e)
class ProcessData:
    @classmethod
    def gzip_way(self,cur):
        output = BytesIO()
        data = cur.fetchall()
        print(f"total record number: {len(data)}")
        for row in data:
            output.write(",".join(row).encode("utf-8"))
        return gzip.compress(output.getvalue())
    @classmethod
    def process(cls,cur,chunk_size):
        output = BytesIO()
        writer = csv.writer(output)
        print("chunk process to byte started...")
        MAX_SIZE = 50 * 1024 * 1024
        size = 0
        print(f"MAX SIZE: {MAX_SIZE/(1024 * 1024)} mb")
        rows = 0
        while True:
            data = cur.fetchmany(chunk_size)
            rows += len(data)
            if not data:
                break
            for row in data:
                byt_row = ",".join(row).encode("utf-8")
                size += len(byt_row)
                if size <= MAX_SIZE:
                    output.write(byt_row)
                else:
                    yield output.getvalue()
                    print(f"{size/(1024 * 1024)} mb processed...")
                    output.seek(0)
                    output.truncate(0)
                    size = 0
        if size != 0:
            yield output.getvalue()
        print(f"current rows fetched: {rows}")
class WriteStorage:
    def gzip_upload(self,conn_url,cursor):
        if conn_url is None:
            print("need conn string..")
            sys.exit(1)
        blob = BlobServiceClient.from_connection_string(conn_url)
        container_client = blob.get_container_client("staging")
        count = 1
        while True:
            try:
                today=str(dt.datetime.now().date())
                print("getting data gzip....")
                print("uploading ....")
                blob_client =container_client.get_blob_client(f"{today}/students.csv.gzip")
                blob_client.upload_blob(ProcessData.gzip_way(cursor),overwrite=True)
                print(f"Upload completed.")
                break
            except Exception as e:
                print(e)
                print(f"retry: {count}")
                if count == 3:
                    print(f"Max retry reached: {count}")
                    break 
                count +=1
    def stream_block(self,conn_url,cursor, chunk_size=10000):
        if conn_url is None:
            print("need conn string...")
            sys.exit(1)
        blob_service_client = BlobServiceClient.from_connection_string(conn_url)
        container_client = blob_service_client.get_container_client("staging")
        try:
            today=str(dt.datetime.now().date())
            print("getting data....")
            for chunk_id, data in enumerate(ProcessData.process(cursor,chunk_size)):
                count = 1
                while True:
                    try:
                        print("uploading ....")
                        blob_client =container_client.get_blob_client(f"{today}/students_{chunk_id}.csv")
                        blob_client.upload_blob(data,overwrite=True)
                        print(f"Successfully completed chunk id: {chunk_id}")
                        break
                    except Exception as e:
                        print(e)
                        print(f"retry: {count} for chunk id: {chunk_id}")
                        if count == 3:
                            print(f"Max try reached: {count} for chunk id: {chunk_id}")
                            break
                        count +=1
        except Exception as e:
            print(e)
        else:
            print("transfer completed...")
if __name__ =="__main__":
    #move to azure storage
    db = Database("database-connection")
    cursor = db.select_table()
    wrt = WriteStorage()
    wrt.gzip_upload("storage-connection-string",cursor)
