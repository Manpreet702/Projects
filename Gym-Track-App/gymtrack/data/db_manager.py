import mysql.connector
from mysql.connector import Error

# Database connection configuration.
# !!! IMPORTANT: Please update these values with your actual MySQL credentials. !!!
DB_CONFIG = {
    'host': 'localhost',  
    'database': 'gymtrack_db', # Database name used in records.sql
    'user': 'root',  # Your MySQL username
    'password': 'mysql1234' # Your MySQL password
}

class DBManager:
    """
    Manages the connection and interaction with the MySQL database.
    """
    def __init__(self):
        self.connection = None

    def connect(self):
        """Creates and returns a MySQL database connection."""
        try:
            self.connection = mysql.connector.connect(**DB_CONFIG)
            if self.connection.is_connected():
                print("Successfully connected to MySQL Database.")
                return True
            return False
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return False

    def close(self):
        """Closes the database connection if it is open."""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("MySQL connection closed.")

    def fetch_all_exercises(self):
        """
        Fetches all exercises grouped by body part, necessary for Page 2.
        
        Returns:
            list: List of dictionaries containing exercise details.
        """
        if not self.connection or not self.connection.is_connected():
            print("Database connection is not active.")
            return []

        # Join exercises with body_parts to get the part name
        query = """
        SELECT 
            e.e_exerciseId, 
            e.e_itemName, 
            bp.b_name AS body_part 
        FROM 
            exercises e
        JOIN 
            body_parts bp ON e.e_bId = bp.b_bId
        ORDER BY 
            bp.b_bId, e.e_itemName;
        """
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query)
            results = cursor.fetchall()
            cursor.close()
            return results
        except Error as e:
            print(f"Error fetching exercises: {e}")
            return []

    def fetch_user_max_weight_stats(self, user_id):
        """
        Fetches maximum weight lifted per exercise for the stats chart.
        
        Args:
            user_id (int): The ID of the user (e.g., 1000).
            
        Returns:
            list: List of dictionaries with {'exercise_name', 'max_weight'}.
        """
        if not self.connection or not self.connection.is_connected():
            print("Database connection is not active.")
            return []
            
        # Select the highest recorded weight for each unique exercise by the user
        query = """
        SELECT 
            e.e_itemName AS exercise_name,
            MAX(r.r_weight) AS max_weight
        FROM 
            records r
        JOIN 
            exercises e ON r.r_exerciseId = e.e_exerciseId
        WHERE 
            r.r_userId = %s 
        GROUP BY 
            e.e_itemName
        ORDER BY
            MAX(r.r_weight) DESC;
        """
        try:
            cursor = self.connection.cursor(dictionary=True)
            cursor.execute(query, (user_id,))
            results = cursor.fetchall()
            cursor.close()
            return results
        except Error as e:
            print(f"Error fetching stats: {e}")
            return []


# -----------------------------------------------------------
# Demo Usage
# -----------------------------------------------------------

def run_db_demo():
    """Demonstrates database functionality."""
    db = DBManager()
    
    # 1. Connect to the database
    if db.connect():
        
        # 2. Test fetching all exercises (for Page 2)
        print("\n--- Exercise Catalog ---")
        exercises = db.fetch_all_exercises()
        if exercises:
            # Display first 5 exercises
            print(f"Total exercises found: {len(exercises)}. Showing first 5:")
            for item in exercises[:5]:
                print(f"  [{item['body_part']}] ID:{item['e_exerciseId']} - {item['e_itemName']}")
        else:
            print("No exercises found. Check the 'exercises' and 'body_parts' tables.")

        # 3. Test fetching user stats (for Chart)
        TEST_USER_ID = 1000 
        print(f"\n--- User Stats (User ID: {TEST_USER_ID}) ---")
        stats = db.fetch_user_max_weight_stats(TEST_USER_ID)
        if stats:
            print("Stats fetched successfully:")
            for item in stats:
                # This data can be passed directly to the stats_generator.py function
                print(f"  {item['exercise_name']}: Max Weight {item['max_weight']}")
        else:
            print("No records found for the user. Check the 'records' table.")
            
        # 4. Close connection
        db.close()

if __name__ == '__main__':
    print("--- Running DB Manager Demo ---")
    run_db_demo()
