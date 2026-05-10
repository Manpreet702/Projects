class QueryBuilder:
    def __init__(self, connection):
        self.connection = connection

    def fetch(self, table_name, columns="*", conditions=None):
        """
        table_name : str
        columns : list or "*" 
        conditions : dict like {"age": 30, "city": "Toronto"}
        """

        # Convert columns
        if isinstance(columns, list):
            column_str = ", ".join(columns)
        else:
            column_str = columns

        # Construct base query
        query = f"SELECT {column_str} FROM {table_name}"

        # Add conditions if provided
        params = []
        if conditions:
            where_clauses = []
            for col, val in conditions.items():
                where_clauses.append(f"{col} = ?")
                params.append(val)

            query += " WHERE " + " AND ".join(where_clauses)

        # Execute query
        conn = self.connection.connect()
        cursor = conn.cursor()
        cursor.execute(query, params)

        rows = cursor.fetchall()
        columns = [column[0] for column in cursor.description]

        # Convert to list of dicts
        result = [dict(zip(columns, row)) for row in rows]

        return result

# How to use this function

from db_client.dbConnect import SQLServerConnection # update this
from db_client.getDataQuery import QueryBuilder # update this

# Step 1: create connection object
conn = SQLServerConnection(
    host="localhost",
    username="sa",
    password="P@ssword123",
    database="TestDB"
)

# Step 2: create query builder
qb = QueryBuilder(conn)

# Example 1: get all rows
data1 = qb.fetch("Employees")
print(data1)

# Example 2: select specific columns
data2 = qb.fetch("Employees", columns=["id", "name", "salary"])
print(data2)

# Example 3: with conditions
data3 = qb.fetch(
    "Employees",
    columns=["id", "name"],
    conditions={"department": "Sales", "status": 1}
)
print(data3)
