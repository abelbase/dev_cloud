import csv 
from generate_data import dto
import os
class WriteToCSV:
    @classmethod
    def write_to_csv(cls,file_name,data):
        is_empty = False
        if os.path.isfile(file_name):
            if os.path.getsize(file_name) < 1: 
                is_empty = True
        else:
            is_empty = True
        with open(file_name,'a',newline='') as wrt:
            write = csv.writer(wrt)
            if is_empty:
                print("emtpy file, writing cols")
                cols = list(dto.__dataclass_fields__.keys())
                
                write.writerow(cols)
            print("writing data..")
            for items in data:
                write.writerow(items.values())
    @classmethod
    def write_to_csv_dict(cls,file_name,data):
        is_empty = False 
        if os.path.isfile(file_name):
            if os.path.getsize(file_name) < 1:
                is_empty = True 
        else:
            is_empty = True
        cols = list(dto.__dataclass_fields__.keys())
        with open(file_name,'a',newline='') as wrt:
            writer = csv.DictWriter(wrt,fieldnames=cols)
            if is_empty:
                writer.writeheader()
            writer.writerows(data)
