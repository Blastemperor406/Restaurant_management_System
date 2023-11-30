import streamlit as st
import mysql.connector
import pandas as pd

db = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="yashdarsh",
    database="dbms_project"
)

# Create cursor
cursor = db.cursor()

st.title("Order taking")


wpp=st.number_input('White penne pasta',min_value=0)
rsm=st.number_input('Red spaghetti meatballs',min_value=0)
bc=st.number_input('Butter chicken',min_value=0)
dm=st.number_input('Dal makhani',min_value=0)

customer_name=st.text_input('Enter customer name')

if st.button('Submit order'):
    try:
        cursor.execute("SELECT AddCustomers(%s) AS customer_id",[customer_name])
        result=cursor.fetchone()
        print(result)
        if wpp!=0:
            cursor.execute("Insert into orders (Customer_id,Dish_id,amount) values (%s,%s,%s)",[result[0],1,wpp])
            db.commit()
        if rsm!=0:
            cursor.execute("Insert into orders (Customer_id,Dish_id,amount) values (%s,%s,%s)",[result[0],2,rsm])
            db.commit()
        if bc!=0:
            cursor.execute("Insert into orders (Customer_id,Dish_id,amount) values (%s,%s,%s)",[result[0],3,bc])
            db.commit()
        if dm!=0:
            cursor.execute("Insert into orders (Customer_id,Dish_id,amount) values (%s,%s,%s)",[result[0],4,dm])
            db.commit()

        
    except mysql.connector.Error as e:
        st.exception(f"SQL Error: {e}")