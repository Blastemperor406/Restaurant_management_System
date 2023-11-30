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

st.title("management")

if st.button ('View order details'):
    cursor.execute("SELECT * FROM DishesordersView")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Order_ID','Dish_ID','Dish_name','preperation_id','Veg/non-Veg','Customer_ID'])
    st.table(data_t)
if st.button ('view ingredient requirements'):
    cursor.execute("SELECT * FROM DishIngredientsView")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Dish_name', 'Dish_ID', 'ingridient_ID', 'Ingredient_name', 'amount_Required'])
    st.table(data_t)
if st.button ('view chef details'):
    cursor.execute("SELECT * FROM Chef")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Chef_ID','Chef_Name','Hours Available'])
    st.table(data_t)
if st.button ('Show menu'):
    cursor.execute("SELECT * FROM Dishes")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Dish_ID', 'dish_Name', 'Preparation_time', 'Veg_NonVeg'])
    st.table(data_t)
if st.button ('Customers'):
    cursor.execute("SELECT * FROM Customer")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['customer','id'])
    st.table(data_t)