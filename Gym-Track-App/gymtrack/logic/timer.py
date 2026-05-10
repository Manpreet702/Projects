import time 
import sys 
import threading 

# ANSI Escape Code for clearing the line in the console
CLEAR_LINE = "\r\033[K" 

class RestTimer:
    """
    Simulates the core functionality of the Strong App rest timer.
    Manages the timer's state (duration, remaining time, run status).
    """
    def __init__(self, duration_seconds=60):
        # Timer duration (seconds)
        self.duration = duration_seconds
        # Remaining time
        self.remaining_time = duration_seconds
        # Timer state: True if running
        self.is_running = False
        # Timer thread
        self.timer_thread = None
        # Used to record start/pause time
        self.start_time = None
        # Pause flag
        self.is_paused = False

    def _format_time(self, seconds):
        """Formats seconds into M:SS format"""
        minutes = int(seconds // 60)
        seconds = int(seconds % 60)
        return f"{minutes:02d}:{seconds:02d}"

    def _run_timer(self):
        """Private method: Runs the timer logic in a separate thread."""
        print(f"\n[Timer Started] Rest Time: {self._format_time(self.duration)}")
        self.start_time = time.time()
        self.is_running = True
        self.is_paused = False
        
        while self.remaining_time > 0 and self.is_running:
            if not self.is_paused:
                elapsed_time = time.time() - self.start_time
                # Recalculate remaining time for precision
                self.remaining_time = self.duration - elapsed_time
                
                if self.remaining_time < 0:
                    self.remaining_time = 0
                
                # Real-time update display (using \r for non-newline refresh)
                display_time = self._format_time(self.remaining_time)
                sys.stdout.write(f"{CLEAR_LINE}⏱️ Remaining: {display_time} (p: Pause, s: Resume, q: Quit)")
                sys.stdout.flush()
                
            time.sleep(0.1) # Refresh every 100 milliseconds

        if self.is_running and self.remaining_time <= 0:
            self.stop()
            print(f"{CLEAR_LINE}✅ Rest Time Finished! Ready for the next set.")
        elif not self.is_running:
             # If stopped by stop() call
            print(f"{CLEAR_LINE}🛑 Timer Stopped.")


    def set_duration(self, duration_seconds):
        """Sets a new timer duration"""
        if self.is_running:
            print("❌ Timer is running. Please stop before setting duration.")
            return
        self.duration = duration_seconds
        self.remaining_time = duration_seconds
        print(f"✅ Duration set to: {self._format_time(self.duration)}")

    def start(self):
        """Starts or resumes the timer"""
        if self.is_running and not self.is_paused:
            print("ℹ️ Timer is already running.")
            return
        
        if self.timer_thread and self.timer_thread.is_alive():
            # Resume from paused state
            self.start_time = time.time() - (self.duration - self.remaining_time)
            self.is_paused = False
            print("\n▶️ Timer resumed.")
        else:
            # First launch
            self.duration = self.remaining_time 
            self.timer_thread = threading.Thread(target=self._run_timer)
            self.timer_thread.daemon = True # Set as daemon thread for clean exit
            self.timer_thread.start()
            
    def pause(self):
        """Pauses the timer"""
        if self.is_running and not self.is_paused:
            self.is_paused = True
            print("\n⏸️ Timer paused.")
        elif self.is_paused:
            print("ℹ️ Timer is already paused.")
        else:
            print("❌ Timer is not running.")

    def stop(self):
        """Stops the timer (does not reset duration)"""
        if self.is_running:
            self.is_running = False
            self.is_paused = False
            # We skip resetting remaining_time to self.duration as per removal of 'o' functionality
        else:
            print("ℹ️ Timer is not running or already stopped.")

# -----------------------------------------------------------
# Demo Usage
# -----------------------------------------------------------

def run_timer_demo():
    """Demonstrates timer functionality."""
    # Default 120 seconds rest
    timer = RestTimer(duration_seconds=120) 
    
    print("\n--- Strong Rest Timer Demo ---")
    timer.start()

    while timer.is_running or timer.is_paused:
        try:
            # Wait for user command
            command = input("\nEnter command (s:Start/Resume, p:Pause, q:Quit): ").lower()
            
            if command == 's':
                timer.start()
            elif command == 'p':
                timer.pause()
            elif command == 'q':
                timer.stop()
                print("Program exiting.")
                break
            else:
                print("Unknown command. Please try again.")

        except EOFError:
            # Handle console input termination, safe exit
            timer.stop()
            break
        except Exception as e:
            print(f"An error occurred: {e}")
            timer.stop()
            break
    
    # Ensure timer thread stops before exiting
    if timer.timer_thread and timer.timer_thread.is_alive():
        timer.is_running = False
        timer.timer_thread.join(timeout=1)

if __name__ == '__main__':
    run_timer_demo()
