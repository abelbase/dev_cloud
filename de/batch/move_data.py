#from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import psycopg2 as pg
import sys
import datetime as dt 
import os
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
        query = "select * from students where inserted_date::timestamp > now() - interval '2 day'"
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
            output.write(",".join(i for i in row).encode("utf-8"))
        return gzip.compress(output.getvalue())
    @classmethod
    def process(cls,cur,chunk_size):
        output = StringIO()
        writer = csv.writer(output)
        print("chunk process to byte started...")
        MAX_SIZE = 50 * 1024 * 1024 
        print(f"MAX SIZE: {MAX_SIZE/(1024 * 1024)} mb")
        rows = 0
        while True:
            data = cur.fetchmany(chunk_size)   
            rows += len(data)
            if not data:
                break
            writer.writerows(data)
            current_byte_size = len(output.getvalue().encode("utf-8"))
            if current_byte_size >= MAX_SIZE:
                yield output.getvalue().encode("utf-8")
                print(f"{round(current_byte_size/(1024 * 1024),2)} mb processed...")
                print(f"total rows processed so far : {rows}")
                output.seek(0)
                output.truncate(0)
        if len(output.getvalue().encode("utf-8")) > 0 :
            yield output.getvalue().encode("utf-8")
        print(f"current rows fetched: {rows}")
    @classmethod
    def get_byte(cls,cursor):
        try:
            MAX_SIZE = 64 * 1024 *1024
            buffer=[]
            size = 0
            rows= 0
            while True:
                data = cursor.fetchmany(100000)
                rows += len(data)
                if not data:
                    break
                for row in data:
                    line = ",".join( str(i) if i is not None else "" for i in row) + "\n"
                    encoded= line.encode("utf-8")
                    size += len(encoded)
                    buffer.append(encoded)
                    if size >= MAX_SIZE:
                        yield b"".join(buffer)
                        buffer =[]
                        size = 0
                        print(f"{rows} processed so far...")
            if buffer:
                yield b"".join(buffer)
                print(f"total row processed: {rows}")
            else:
                print(f"total row processed: {rows}")
        except Exception as e:
            print(e)

class WriteStorage:
    def gzip_upload(self,conn_url,cursor,chunk_size):
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
                blob_client.upload_blob(ProcessData.process(cursor,chunk_size),overwrite=True)
                print(f"Upload completed.")
                break
            except Exception as e:
                print(e)
                print(f"retry: {count}")
                if count == 3:
                    print(f"Max retry reached: {count}")
                    break 
                count +=1
    def stream(self,conn_url,cursor):
        blob = BlobServiceClient.from_connection_string(conn_url,max_single_put_size = 64 * 1024 * 1024,
                                                            max_block_size = 4 * 1024 * 1024   )
        container_client = blob.get_container_client("staging")
        today=str(dt.datetime.now().date().strftime("%Y%m%d"))
        try:
            retries = 3
            max_retry= False
            for i in range(retries):
                try:
                    print("Uploading...")
                    blob_client =container_client.get_blob_client(f"students_table/students_{today}.csv")
                    blob_client.upload_blob(ProcessData.get_byte(cursor),overwrite=True,max_concurrency=5)
                    print("upload completed...")
                    break
                except Exception as e:
                    print(e)
                    print(f"retry: {i+1}")
                if i+1 == 3:
                    max_retry  =True
            if max_retry:
                print(f"Max retry reached: {retries}") 
        except Exception as e:
            print(e)
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
    db = Database(os.environ.get("PG_CONN"))
    cursor = db.select_table()
    wrt = WriteStorage()
    wrt.stream(os.environ.get("STORAGE_CONN"),cursor)
