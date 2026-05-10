import tkinter as tk
from tkinter import ttk
from .config import COLORS

class WorkoutTimer(tk.Frame):
    """
    A GUI-based Rest Timer that sits at the bottom of the window.
    Adapts the logic from your original timer.py for Tkinter.
    """
    def __init__(self, parent):
        super().__init__(parent, bg="white", height=60)
        self.pack_propagate(False) #height of the window
        self.duration = 60
        self.remaining = 0
        self.is_running = False
        self._timer_job = None 
        
        self._build_ui()

    def _build_ui(self):
        #Progress Bar (Blue)
        self.canvas = tk.Canvas(self, bg="#f0f0f0", height=5, highlightthickness=0)
        self.canvas.pack(fill=tk.X, side=tk.TOP)
        self.progress_rect = self.canvas.create_rectangle(0, 0, 0, 5, fill="#2196F3", width=0)

        #Controls Row
        self.controls_frame = tk.Frame(self, bg="white")
        self.controls_frame.pack(fill=tk.BOTH, expand=True, padx=10)

        #Time Label (Center)
        self.lbl_time = tk.Label(self.controls_frame, text="00:00", 
                                 font=("Arial", 20, "bold"), bg="white", fg="#2c3e50")
        self.lbl_time.pack(side=tk.LEFT, padx=10)

        #Buttons (Right)
        btn_config = {"font": ("Arial", 10, "bold"), "relief": "flat", "bg": "#e0e0e0"}
        
        tk.Button(self.controls_frame, text="+30s", command=lambda: self.add_time(30), **btn_config).pack(side=tk.RIGHT, padx=2)
        tk.Button(self.controls_frame, text="+10s", command=lambda: self.add_time(10), **btn_config).pack(side=tk.RIGHT, padx=2)
        tk.Button(self.controls_frame, text="Start Rest", command=lambda: self.start(60), 
                  bg="#2196F3", fg="black", font=("Arial", 10, "bold")).pack(side=tk.RIGHT, padx=10)

    def start(self, seconds):
        """Starts the countdown"""
        if self.is_running:
            self.stop() # Reset if already running
            
        self.duration = seconds
        self.remaining = seconds
        self.is_running = True
        self._animate()

    def stop(self):
        """Stops the timer"""
        self.is_running = False
        if self._timer_job:
            self.after_cancel(self._timer_job)
            self._timer_job = None
        self.canvas.coords(self.progress_rect, 0, 0, 0, 5) # Reset bar
        self.lbl_time.config(text="00:00")

    def add_time(self, seconds):
        """Adds time dynamically"""
        if self.is_running:
            self.remaining += seconds
            self.duration += seconds 
        else:
            self.start(seconds)

    def _animate(self):
        """The Loop (Replaces 'while' loop in your original code)"""
        if self.remaining > 0 and self.is_running:
            mins, secs = divmod(self.remaining, 60)
            self.lbl_time.config(text=f"{mins:02d}:{secs:02d}")
            
            screen_width = self.winfo_width()
            pct = self.remaining / self.duration
            bar_width = screen_width * pct
            self.canvas.coords(self.progress_rect, 0, 0, bar_width, 5)

            self.remaining -= 1
            self._timer_job = self.after(1000, self._animate)
        else:
            self.stop()
            self.lbl_time.config(text="Done!")