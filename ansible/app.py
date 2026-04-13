from flask import Flask, render_template, request, jsonify
import random as  rn
import os
from  db import *
app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"message":"Thank You"})

@app.route('/api/submit', methods=['POST'])
def submit():
    user_input = request.form.get('user_data')
    data =select_data(user_input)
    check_data = data if not data is None and len(data) == 1 else None
    if check_data is None:
        processed_message = f"Name: {user_input}\n Status: 'Not Found' "
        return jsonify(message=processed_message)
    processed_message = f"Name: {check_data[0][0]}\nAge: {check_data[0][1]}\nHobbies: {check_data[0][2]}"
    return jsonify(message=processed_message)
def select_data(name):
  data = None
  try:
    conn = pg.connect(os.environ.get("PG_CONN"))
    cursor = conn.cursor()
    cursor.execute("select * from mytable where name = %s",(name,))
    data = cursor.fetchall()
  except Exception as e:
     print(e)
  finally:
    if not conn is None:
      conn.close()
  return data
if __name__ == '__main__':
    app.run(host="0.0.0.0",port=5000)