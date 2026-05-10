import tkinter as tk
from tkinter import messagebox
from .config import COLORS
from .components import create_header
from .gui_timer import WorkoutTimer
from gymtrack.logic.stats import generate_workout_progress_chart
import time

class ActiveWorkoutWindow(tk.Toplevel):
    def __init__(self, parent, exercise_list):
        super().__init__(parent)
        self.title("Track Your Workout")
        self.geometry("380x750")
        self.configure(bg=COLORS["bg_main"])
        self.lift()
        self.focus_force()
        self.grab_set() 
        self.exercise_list = exercise_list
        self.exercise_data = {ex: [] for ex in exercise_list}
        self.start_time = time.time()
        self.vcmd = (self.register(self._validate_int), '%P')
        self._build_ui()

    def _validate_int(self, P):
        if P == "": return True
        return P.isdigit()

    def _build_ui(self):
        #HEADER
        create_header(self, "Current Session").pack(fill=tk.X)
        
        tk.Label(self, text="Log progress: Click '✓' to mark set complete & start timer.", 
                 bg=COLORS["bg_main"], fg="black", font=("Arial", 14, "italic")
                 ).pack(pady=(5, 10))

        #MAIN CONTAINER
        container = tk.Frame(self, bg=COLORS["bg_main"])
        container.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        canvas = tk.Canvas(container, bg=COLORS["bg_main"], highlightthickness=0)
        scrollbar = tk.Scrollbar(container, orient="vertical", command=canvas.yview)
        self.scrollable_frame = tk.Frame(canvas, bg=COLORS["bg_main"])

        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True, padx=10)
        scrollbar.pack(side="right", fill="y")

        #EXERCISES 
        for exercise in self.exercise_list:
            self._create_exercise_section(exercise)

        #FINISH BUTTON
        btn_finish = tk.Button(self.scrollable_frame, text="Finish Workout", 
                               command=self.finish_workout,
                               bg="#4CAF50", fg="black", 
                               font=("Arial", 14, "bold"), pady=10,
                               highlightthickness=0, borderwidth=1)
        btn_finish.pack(pady=30, fill=tk.X)

        #TIMER
        self.timer_widget = WorkoutTimer(self)
        self.timer_widget.pack(side=tk.BOTTOM, fill=tk.X)

    def trigger_rest_timer(self, seconds):
        if hasattr(self, 'timer_widget'):
            self.timer_widget.start(seconds)

    def _create_exercise_section(self, exercise_name):
        frame_group = tk.Frame(self.scrollable_frame, bg="white", bd=1, relief="solid")
        frame_group.pack(fill=tk.X, pady=10, ipady=5)

        tk.Label(frame_group, text=exercise_name, font=("Arial", 14, "bold"), 
                 bg="white", fg="#2c3e50").pack(anchor="w", padx=10, pady=5)

        # HEADERS
        headers_frame = tk.Frame(frame_group, bg="white")
        headers_frame.pack(fill=tk.X, padx=10)
        
        headers_frame.grid_columnconfigure(0, minsize=40)
        headers_frame.grid_columnconfigure(1, minsize=100)
        headers_frame.grid_columnconfigure(2, minsize=100)
        headers_frame.grid_columnconfigure(3, minsize=50) 
        
        tk.Label(headers_frame, text="Set", bg="white", fg="gray", font=("Arial", 14)).grid(row=0, column=0, sticky="ew")
        tk.Label(headers_frame, text="Lbs", bg="white", fg="gray", font=("Arial", 14)).grid(row=0, column=1, sticky="ew")
        tk.Label(headers_frame, text="Reps", bg="white", fg="gray", font=("Arial", 14)).grid(row=0, column=2, sticky="ew")
        tk.Label(headers_frame, text="Done", bg="white", fg="gray", font=("Arial", 14)).grid(row=0, column=3, sticky="ew")

        #Rows Container
        rows_container = tk.Frame(frame_group, bg="white")
        rows_container.pack(fill=tk.X, padx=10, pady=5)
        
        self._add_set_row(rows_container, exercise_name)

        #BUTTONS
        btn_frame = tk.Frame(frame_group, bg="white")
        btn_frame.pack(fill=tk.X, padx=10, pady=5)

        btn_del = tk.Button(btn_frame, text="- Delete Last", 
                            command=lambda: self._delete_last_set(rows_container, exercise_name),
                            font=("Arial", 14, "bold"),#slightly smaller for a cleaner look
                    fg="red",#text color
                    bg="#28a745",#modern "Success" Green (Hex code)
                    activebackground="#1e7e34",#darker green when you click it
                    activeforeground="red",#keep text green when clicking
                    relief="flat",#Removes the old-school 3D border
                    borderwidth=0, 
                    highlightthickness=0,
                    padx=15, pady=5)#adds space inside the button (width/height)
        btn_del.pack(side="left")

        btn_add = tk.Button(btn_frame, text="+ Add Set", 
                    command=lambda: self._add_set_row(rows_container, exercise_name),
                    font=("Arial", 14, "bold"),#slightly smaller for a cleaner look
                    fg="Green",#text color
                    bg="#28a745",#modern "Success" Green (Hex code)
                    activebackground="#1e7e34",#darker green when you click it
                    activeforeground="green",#keep text green when clicking
                    relief="flat",#Removes the old-school 3D border
                    borderwidth=0, 
                    highlightthickness=0,
                    padx=15, pady=5)#adds space inside the button (width/height)

        # Add external padding in the pack method so it doesn't touch the screen edge
        btn_add.pack(side="right", padx=10)

        # tk.Button(frame_btns, text="< Remove", command=self.remove_from_workout, 
        #           fg=COLORS["btn_text"], font=("Arial", 20, "bold"), width=8).pack(pady=10)


        
    def _add_set_row(self, parent, exercise_name):
        current_count = len(self.exercise_data[exercise_name])
        set_num = current_count + 1

        row_frame = tk.Frame(parent, bg="white")
        row_frame.pack(fill=tk.X, pady=2)

        row_frame.grid_columnconfigure(0, minsize=40)
        row_frame.grid_columnconfigure(1, minsize=100)
        row_frame.grid_columnconfigure(2, minsize=100)
        row_frame.grid_columnconfigure(3, minsize=50)

        #Set Number
        tk.Label(row_frame, text=str(set_num), bg="#f0f0f0", fg="black", width=3).grid(row=0, column=0)
        
        #Inputs
        entry_w = self._create_input_field(row_frame, 1)
        entry_r = self._create_input_field(row_frame, 2)
        
        #Create Data Object First
        row_data = {
            'frame': row_frame,
            'weight': entry_w,
            'reps': entry_r,
            'done': False # Default state
        }
        
        #TICK BUTTON
        btn_tick = tk.Button(row_frame, text="✓", 
                     # Combine the visual toggle with your logic
                     command=lambda: toggle_status(btn_tick), 
                     bg="#e0e0e0",#light Gray(Inactive Background)
                     fg="#a0a0a0",#dark Gray-Inactive Checkmark)
                     activebackground="#1e7e34",#darker Green on click
                     activeforeground="green",
                     font=("Arial", 12, "bold"),
                     relief="flat", 
                     width=4,#slightly wider for a better touch target
                     highlightthickness=0)

        #command with closure
        btn_tick.configure(command=lambda b=btn_tick, d=row_data: self._toggle_set(b, d))
        btn_tick.grid(row=0, column=3, padx=5)

        #Store references
        self.exercise_data[exercise_name].append(row_data)

    def _toggle_set(self, btn, row_data):
        """
        Toggles the set status between Done (Green) and Not Done (Gray).
        Starts timer only when marking as Done.
        """
        if not row_data['done']:
            #Mark as Done
            row_data['done'] = True
            btn.config(bg="#28a745", fg="green")#turn greeen
            self.trigger_rest_timer(120) #Start Timer
        else:
            #Unmark (Reset)
            row_data['done'] = False
            btn.config(bg="#e0e0e0", fg="#a0a0a0") # Turn back to Gray

        # # Check current color to decide next state
        # if btn.cget('bg') == "#28a745":  # If currently Green (Done)
        #     btn.config(bg="#e0e0e0", fg="#a0a0a0") # Turn back to Gray
        # else:                            # If currently Gray (Not Done)
        #     btn.config(bg="#28a745", fg="white")

        

    def _delete_last_set(self, parent, exercise_name):
        sets = self.exercise_data[exercise_name]
        if len(sets) > 0:
            last_set = sets.pop()
            last_set['frame'].destroy()
        else:
            messagebox.showinfo("Info", "No sets left to delete!")

    def _create_input_field(self, parent, col_idx):
        container = tk.Frame(parent, bg="black", bd=1) 
        container.grid(row=0, column=col_idx, padx=5)
        
        entry = tk.Entry(container, width=8, justify="center", 
                         bg="white", fg="black", 
                         insertbackground="black",
                         selectbackground="#cce5ff",
                         selectforeground="black",
                         relief="flat", highlightthickness=0,
                         validate="key", validatecommand=self.vcmd)
        entry.pack(fill="both", padx=1, pady=1)
        return entry
    
    def finish_workout(self):
        duration_sec = int(time.time() - self.start_time)

        # Get total rest time from the timer widget
        rest_sec = 0
        if hasattr(self, 'timer_widget'):
            # Using getattr to be safe if total_rested isn't initialized
            rest_sec = getattr(self.timer_widget, 'total_rested', 0)
            self.timer_widget.stop()
            
        # 1. Stop Timer
        if hasattr(self, 'timer_widget'):
            self.timer_widget.stop()
        
        # 2. Generate Summary Strings & Data for Chart
        summary_lines = []
        summary_lines.append(f"{'Exercise':<15} | {'Sets':<5} | {'Max(Lbs)':<8} | {'Total Vol'}")
        summary_lines.append("-" * 60)
        
        total_session_vol = 0
        chart_data = [] #data to send to stats.py
        
        for ex_name, sets in self.exercise_data.items():
            completed_sets = [s for s in sets if s['done']]
            
            #skip if no sets completed
            if not completed_sets:
                continue
                
            set_count = len(completed_sets)
            total_vol = 0
            max_weight = 0
            
            for s in completed_sets:
                w_str = s['weight'].get() or "0"
                r_str = s['reps'].get() or "0"
                try:
                    w, r = int(w_str), int(r_str)
                except ValueError:
                    w, r = 0, 0
                
                total_vol += (w * r)
                if w > max_weight:
                    max_weight = w
            
            total_session_vol += total_vol
            summary_lines.append(f"{ex_name:<15} | {set_count:<5} | {max_weight:<8} | {total_vol}")
            
            # Add to chart data
            chart_data.append({
                'exercise_name': ex_name, 
                'max_weight': max_weight
            })

        summary_lines.append("-" * 60)
        summary_lines.append(f"TOTAL SESSION VOLUME: {total_session_vol} Lbs")
        
        # 3. Show Summary
        #messagebox.showinfo("Workout Summary", "\n".join(summary_lines))
        
        # 4. Show Chart (If there is data)
        # 3. OPEN GRAPH (Passing all 4 required arguments)
        if chart_data:
            self.withdraw()
            generate_workout_progress_chart(chart_data, duration_sec, rest_sec, total_session_vol)
        else:
            messagebox.showinfo("Done", "No sets completed. Workout finished.")