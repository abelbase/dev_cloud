from psycopg2.extras  import  execute_values
import psycopg2 as pg
class Database:
    def __init__(self,conn_url):
        self.conn = pg.connect(conn_url)
        if self.conn:
            print("pg connected...")
        else:
            print("pg not connected...")
    def create_table(self):
        query = '''
        create table if not exists students(
        student_name text,
        roll_no text,
        height text , 
        weight text, 
        grade text,
        date_of_birth text,
        city text,
        fee text,
        inserted_date text);'''
        try: 
            cur = self.conn.cursor()
            cur.execute(query)
        except Exception as e:
            print(e)
            self.conn.rollback()
        else:
            self.conn.commit()
            print("table created....")

    def insert_table(self,data):
        query = '''insert into students(student_name,roll_no,height,weight,grade,date_of_birth,city,fee,inserted_date) values %s;'''
        try: 
            cur = self.conn.cursor()
            # cur.executemany(query,data)
            execute_values(cur,query,data, page_size=10000)
        except Exception as e:
            print(e)
            self.conn.rollback()
        else:
            self.conn.commit()
            print("data inserted....")
    def select_table(self):
        query = '''select * from students;'''
        data = None
        try: 
            cur = self.conn.cursor()
            cur.execute(query)
            data = cur.fetchall()
        except Exception as e:
            print(e)
        return data