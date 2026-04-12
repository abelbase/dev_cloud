from flask import Flask, render_template, request, jsonify
import random as  rn
#from  pgdb import *
app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"message":"Thank You"})

@app.route('/api/submit', methods=['POST'])
def submit():
    user_input = request.form.get('user_data')
    processed_message = f"Name: {user_input}\n Status: {rn.randint(100,200)}"
    return jsonify(message=processed_message)
if __name__ == '__main__':
    app.run(host="0.0.0.0",port=5000)