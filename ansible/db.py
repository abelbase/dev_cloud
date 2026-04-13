import psycopg2 as pg
import os
def connection():
    conn = pg.connect(os.environ.get("PG_CONN"))
    return conn

def create_table(conn):
    query="create table if not exists mytable(name text, age text,coding text)"
    try:
        cursor=conn.cursor()
        cursor.execute(query)
    except Exception as e:
        conn.rollback()
    else:
        conn.commit()
        print("table created..")

def insert_data(conn):
    try:
        query="insert into mytable(name,age,hobby) values(%s,%s,%s)"
        cursor = conn.cursor()
        cursor.execute(query,('testuser1','100','coding'))
    except Exception as e:
        conn.rollback()
    else:
        conn.commit()
        print("data insertion completed..")
def select(conn,name):
    data = None
    try:
        query=f"select * from mytable where name = '{name}'"
        cursor = conn.cursor()
        cursor.execute(query)
        data = cursor.fetchall()
    except Exception as e:
        print(e)
    return data

if __name__ == "__main__":
    conn = connection()
    create_table(conn)
    insert_data(conn)
    print(select(conn,"testuser1"))