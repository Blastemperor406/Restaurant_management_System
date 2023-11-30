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

st.title("Inventory management")


ingredient_options=[ 'Spaghetti', 'Assorted vegetables', 'cheese', 'meatballs', 'chicken', 'white sauce', 'red sauce', 'penne', 'butter chicken mix', 'dal', 'makhani mix']
selected_name = st.radio("Chef", ingredient_options)
ingredient_id=ingredient_options.index(selected_name)+1

Amount = st.text_input("Enter amount", "0")
print(ingredient_id)
args1=(int(Amount),ingredient_id)
if st.button("Update Inventory"):
    try:
        cursor.callproc("UpdateInventory",args1)
        db.commit()
        print(cursor.statement)
        cursor.execute("SELECT * FROM Inventory")
        data_t=cursor.fetchall()
        data_t=pd.DataFrame(data_t,columns=['Ingridient_ID','Ingridient_Name','Amount'])
        st.table(data_t)
    except mysql.connector.Error as e:
        st.exception(f"SQL Error: {e}")
if st.button('Show inventory'):
    cursor.execute("SELECT * FROM Inventory")
    data_t=cursor.fetchall()
    data_t=pd.DataFrame(data_t,columns=['Ingridient_ID','Ingridient_Name','Amount'])
    st.table(data_t)
