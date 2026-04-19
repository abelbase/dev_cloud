from generate_data import *
from write_to_db import *
import os
class Main:
    @classmethod
    def run(cls):
        # insert into database
        #data = Student.generate_student_data()
        db = Database(os.environ.get("PG_CONN"))
        count = 0
        all = []
        chunks = 0
        for row in Student.generate_student_data():
            all.append(row)
            count +=1
            chunks +=1
            if count == 10000:
                db.insert_table(all)
                all=[]
                count =0
        if count >= 0:
            db.insert_table(all)
        print(f"{chunks} rows written...")
        print(len(db.select_table()))
if __name__ == "__main__":
    Main.run()