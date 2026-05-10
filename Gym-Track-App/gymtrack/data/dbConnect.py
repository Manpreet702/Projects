import pyodbc

class SQLServerConnection:
    def __init__(self, host, username, password, database, driver="{ODBC Driver 17 for SQL Server}"):
        self.host = host
        self.username = username
        self.password = password
        self.database = database
        self.driver = driver
        self.conn = None

    def connect(self):
        if self.conn is None:
            conn_str = (
                f"DRIVER={self.driver};"
                f"SERVER={self.host};"
                f"DATABASE={self.database};"
                f"UID={self.username};"
                f"PWD={self.password}"
            )
            self.conn = pyodbc.connect(conn_str)
        return self.conn

    def close(self):
        if self.conn:
            self.conn.close()
            self.conn = None
