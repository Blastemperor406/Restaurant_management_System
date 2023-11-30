import streamlit as st
import mysql.connector
import pandas as pd
# Connect to database
db = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="yashdarsh",
    database="dbms_project"
)

# Create cursor
cursor = db.cursor()

# entering hours available

st.title("Chefs available hours")

name_options = ["Darsh", "Disha"]
selected_name = st.radio("Chef", name_options)

if selected_name == "Darsh":
    chef_id=1
elif selected_name == "Disha":
    chef_id=2

hours = st.text_input("Enter Hours available", "0")
args1=(int(hours),chef_id)
if st.button("Submit Hours"):
    try:
        cursor.callproc("UpdateHours",args1)
        db.commit()
        print(cursor.statement)
        cursor.execute("SELECT * FROM Chef")
        data_t=cursor.fetchall()
        data_t=pd.DataFrame(data_t,columns=['Chef_ID','Chef_Name','Hours Available'])
        st.table(data_t)
    except mysql.connector.Error as e:
        st.exception(f"SQL Error: {e}")
if st.button('Show chef details'):
    cursor.execute("SELECT * FROM Chef")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Chef_ID','Chef_Name','Hours Available'])
    st.table(data_t)
    








