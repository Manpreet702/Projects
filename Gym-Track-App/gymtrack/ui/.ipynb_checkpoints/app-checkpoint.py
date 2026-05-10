import tkinter as tk  # for the UI
from tkinter import messagebox  
from .config import COLORS, GYM_DATA  #data and colors for mac user
from .components import create_header, create_styled_listbox
from .tracker import ActiveWorkoutWindow

class GymPlannerApp(tk.Tk):
    
    def __init__(self):
        'Container configurations'
        
        super().__init__() 
        self.title("GymTrack")
        self.geometry("650x600")
        self.configure(bg=COLORS["bg_main"])
        self._build_ui() #creating a ui as soon as the app launches

    def _build_ui(self):
        'UI - The blueprint of the app'
        
        create_header(self, "Step 1: Filter by Body Part").pack(fill=tk.X, padx=10, pady=(10,0))
        self.body_part_listbox = create_styled_listbox(self, "white")
        
        for part in GYM_DATA.keys(): #adding keys from database dictionary(BODY PARTS) to list box
            self.body_part_listbox.insert(tk.END, part)
            
        self.body_part_listbox.pack(padx=10, pady=(0, 10), fill=tk.X)
        self.body_part_listbox.bind('<<ListboxSelect>>', self.update_available_exercises) # update xercises when user clicks add
        self.body_part_listbox.config(font=("Helvetica", 14))

        # middle part
        frame_middle = tk.Frame(self, bg=COLORS["bg_main"])
        frame_middle.pack(pady=5, padx=10, fill=tk.BOTH, expand=True)

        # Left Side
        frame_left = tk.Frame(frame_middle, bg=COLORS["bg_main"])
        frame_left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        create_header(frame_left, "Available Menu").pack(fill=tk.X)
        self.available_listbox = create_styled_listbox(frame_left, COLORS["list_left"])
        self.available_listbox.pack(fill=tk.BOTH, expand=True)
        self.available_listbox.config(font=("Helvetica", 14))
        
        # Buttons
        frame_btns = tk.Frame(frame_middle, bg=COLORS["bg_main"])
        frame_btns.pack(side=tk.LEFT, padx=15)
        tk.Button(frame_btns, text="Add >", command=self.add_to_workout, 
                  fg=COLORS["btn_text"], font=("Arial", 20, "bold"), width=8).pack(pady=10)
        tk.Button(frame_btns, text="< Remove", command=self.remove_from_workout, 
                  fg=COLORS["btn_text"], font=("Arial", 20, "bold"), width=8).pack(pady=10)

        # Right Side
        frame_right = tk.Frame(frame_middle, bg=COLORS["bg_main"])
        frame_right.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        create_header(frame_right, "My Workout Cart").pack(fill=tk.X)
        self.my_workout_listbox = create_styled_listbox(frame_right, COLORS["list_right"])
        self.my_workout_listbox.pack(fill=tk.BOTH, expand=True)
        self.my_workout_listbox.config(font=("Helvetica", 14))
        # BOTTOM BUTTON 
        tk.Button(self, text="Start Workout", command=self.launch_tracker, 
                  fg="black", font=("Arial", 20, "bold"), pady=10).pack(pady=20, fill=tk.X, padx=20)

    def update_available_exercises(self, event):
        self.available_listbox.delete(0, tk.END)
        selected_indices = self.body_part_listbox.curselection()
        for index in selected_indices:
            part_name = self.body_part_listbox.get(index)
            exercises = GYM_DATA.get(part_name, [])
            for ex in exercises:
                self.available_listbox.insert(tk.END, ex)

    def add_to_workout(self):
        selected_indices = self.available_listbox.curselection()
        if not selected_indices:
            messagebox.showwarning("Warning", "Select an exercise on the left first!")
            return
        for i in selected_indices:
            exercise = self.available_listbox.get(i)
            current_plan = self.my_workout_listbox.get(0, tk.END)
            if exercise not in current_plan:
                self.my_workout_listbox.insert(tk.END, exercise)
        self.available_listbox.selection_clear(0, tk.END)

    def remove_from_workout(self):
        selected_indices = self.my_workout_listbox.curselection()
        if not selected_indices:
            messagebox.showwarning("Warning", "Select an exercise on the right to remove!")
            return
        for i in reversed(selected_indices):
            self.my_workout_listbox.delete(i)

    def launch_tracker(self):
        """
        Gets the list of exercises and opens the new Tracker Window.
        """
        workout_plan = self.my_workout_listbox.get(0, tk.END)
        
        if not workout_plan:
            messagebox.showwarning("Empty", "Add some exercises first!")
            return
        self.withdraw()
        ActiveWorkoutWindow(self, workout_plan)
        