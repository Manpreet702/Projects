
from gymtrack.data.db_manager import DBManager

def run_db_demo():
    """Demonstrates database functionality."""
    db = DBManager()
    if db.connect():
        print("\n--- Exercise Catalog ---")
        exercises = db.fetch_all_exercises()
        # 4. Close connection
        db.close()
    return exercises
    
COLORS = {
    "bg_main": "#e6e6e6",       
    "header_bg": "#2c3e50",     
    "header_text": "white",
    "list_left": "#ffffff",    
    "list_right": "#fff9c4",   
    "btn_text": "black",        
    "text_main": "black"        
}

GYM_DATA ={}
sql_data = run_db_demo()
for item in sql_data:
    category = item['body_part']
    exercise = item['e_itemName']
   
    if category not in GYM_DATA:
        GYM_DATA[category] = []
    GYM_DATA[category].append(exercise)
