import tkinter as tk
from .config import COLORS

def create_header(parent, text):
    """
    Creates a Dark Blue header.
    """
    return tk.Label( parent, 
                    text=text, 
                    bg=COLORS["header_bg"], 
                    fg=COLORS["header_text"], 
                    font=("Arial", 11, "bold"), 
                    pady=5
                    )

def create_styled_listbox(parent, bg_color):
    """
    Creates a listbox with Black text
    """
    return tk.Listbox( parent, 
                        selectmode=tk.MULTIPLE, 
                        exportselection=False, 
                        bg=bg_color, 
                        fg=COLORS["text_main"],  
                        font=("Arial", 10)
                    )