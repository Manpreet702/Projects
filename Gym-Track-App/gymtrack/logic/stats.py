import tkinter as tk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import numpy as np
import time

def format_time(seconds):
    """Helper to convert seconds to MM:SS or HH:MM:SS"""
    if seconds < 3600:
        mins, secs = divmod(seconds, 60)
        return f"{mins}m {secs}s"
    else:
        hours, remainder = divmod(seconds, 3600)
        mins, secs = divmod(remainder, 60)
        return f"{hours}h {mins}m {secs}s"

def generate_workout_progress_chart(wishlist_data, duration_sec, rest_sec, total_vol):
    """
    Generates a chart with a Session Summary Dashboard.
    """
    
    if not wishlist_data:
        print("Error: Wishlist data is empty.")
        return

    # Extract data
    exercise_names = [item['exercise_name'] for item in wishlist_data]
    max_weights = [item['max_weight'] for item in wishlist_data]

    # --- UI: POPUP WINDOW ---
    graph_window = tk.Toplevel()
    graph_window.title("Session Complete")
    graph_window.geometry("900x750")
    graph_window.lift()
    graph_window.focus_force()

    # --- UI: SUMMARY DASHBOARD (New Feature) ---
    dashboard_frame = tk.Frame(graph_window, bg="#f0f0f0", pady=20)
    dashboard_frame.pack(fill=tk.X)

    # Helper to create stats cards
    def create_stat_card(parent, title, value, color):
        card = tk.Frame(parent, bg="white", bd=1, relief="solid", padx=20, pady=10)
        card.pack(side=tk.LEFT, expand=True, fill=tk.BOTH, padx=10)
        
        tk.Label(card, text=title, font=("Arial", 10, "bold"), fg="gray", bg="white").pack()
        tk.Label(card, text=value, font=("Arial", 18, "bold"), fg=color, bg="white").pack()

    # calculating active time (Total - Rest)
    active_time = max(0, duration_sec - rest_sec)

    create_stat_card(dashboard_frame, "Total Duration", format_time(duration_sec), "#333333")
    create_stat_card(dashboard_frame, "Rest Time", format_time(rest_sec), "#2196F3") # Blue
    create_stat_card(dashboard_frame, "Active Lifting", format_time(active_time), "#4CAF50") # Green
    create_stat_card(dashboard_frame, "Total Volume", f"{total_vol} lbs", "#E91E63") # Pink

    # --- CHART GENERATION ---
    fig, ax = plt.subplots(figsize=(8, 5), dpi=100)
    
    # Plot bars instead of lines for better visibility of discrete exercises
    bars = ax.bar(exercise_names, max_weights, color='#4CAF50', alpha=0.7)
    
    # Add a line on top for trend
    ax.plot(exercise_names, max_weights, marker='o', linestyle='-', color='#2E7D32', linewidth=2, label='Progression')

    ax.set_title('Max Weight Lifted per Exercise', fontsize=14, fontweight='bold', pad=20)
    ax.set_ylabel('Max Weight (Lbs)', fontsize=11)
    ax.tick_params(axis='x', rotation=45)
    ax.grid(axis='y', linestyle='--', alpha=0.5)

    #Annotate bars
    for bar in bars:
        height = bar.get_height()
        ax.annotate(f'{height}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=9, fontweight='bold')

    plt.tight_layout()

    canvas = FigureCanvasTkAgg(fig, master=graph_window)
    canvas.draw()
    canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True, padx=20, pady=10)

    #btn_close
    btn_close = tk.Button(graph_window, text="Close Summary", command=graph_window.destroy,
                          bg="#f44336", fg="black", font=("Arial", 12, "bold"), pady=10)
    btn_close.pack(side=tk.BOTTOM, fill=tk.X, padx=20, pady=20)