class InsertBuilder:
    def __init__(self, connection):
        self.connection = connection

    def insert(self, table_name, data: dict):
        """
        table_name : str
        data : dict of column-value pairs
                Example: {"name": "John", "age": 30, "city": "Toronto"}
        """

        # Extract columns and values
        columns = ", ".join(data.keys())
        placeholders = ", ".join(["?"] * len(data))
        values = list(data.values())

        # Build query
        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

        # Execute
        conn = self.connection.connect()
        cursor = conn.cursor()
        cursor.execute(query, values)
        conn.commit()

        return cursor.rowcount  # returns number of rows inserted

# How to use this function

 from db_client.dbConnect import SQLServerConnection
from db_client.addDataQuery import InsertBuilder

# Step 1: create connection
conn = SQLServerConnection(
    host="localhost",
    username="sa",
    password="P@ssword123",
    database="TestDB"
)

# Step 2: create insert builder
ib = InsertBuilder(conn)

# Step 3: Example insert
row = {
    "name": "Manpreet Singh",
    "age": 27,
    "department": "IT",
    "salary": 75000
}

result = ib.insert("Employees", row)

print("Rows inserted:", result)
--- 
   
