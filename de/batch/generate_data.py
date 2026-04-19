from dataclasses import dataclass,asdict
import random as rn
import datetime as dt
@dataclass
class dto:
    student_name: str 
    roll_no : str 
    height: str
    weight: str 
    grade: str 
    date_of_birth: str 
    city: str 
    fee : str 
    inserted_date: str

class Student:
    student = ["Hari","Shyam","Rhaul","Jaya","Jay","","","Peter","121","Ram"]
    city = ["ktm","london","mumbai","pokhara","new york","",""]
    grade = ["std-8","std-9","","","std-10","10"]
    dob = ["2000-10-10","","2001-01-20","1999-12-01","2002-03-04"]
    @classmethod
    def generate_student_data(cls):
        rows = rn.randint(1000,100000)
        print(rows)
        for i in range(rows):
            if i !=7 : 
                dummy_data = asdict(dto(rn.choice(Student.student),Student.student_id(),str(rn.randint(60,80))+"in",str(rn.randint(60,80))+"kg",rn.choice(Student.grade),rn.choice(Student.dob),rn.choice(Student.city),str(rn.randint(10000,30000)),str(dt.datetime.now().date())))
                #data.append(dummy_data)
                #db.append(tuple(dummy_data.values()))
                yield tuple(dummy_data.values())
            else:
                dummy_data = asdict(dto(rn.choice(Student.student),Student.student_id(),str(rn.randint(60,80))+"in",str(rn.randint(60,80))+"kg",rn.choice(Student.grade),rn.choice(Student.dob),rn.choice(Student.city),str(rn.randint(10000,30000)),str(dt.datetime.now().date())))
                #data.append(dummy_data)
                #db.append(tuple(dummy_data.values()))
                yield tuple(dummy_data.values())
    @classmethod
    def student_id(cls):
        return "S"+"".join([rn.choice(["0","1","2","3","4","5","6","7","8","9"])for i in range(6)])