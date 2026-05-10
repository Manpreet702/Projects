#!/usr/bin/env python
# coding: utf-8

import unittest
import sys
import os
from unittest.mock import patch, MagicMock

# --- 1. Dynamic Path Setup ---
try:
    current_file_path = os.path.abspath(__file__)
    current_dir = os.path.dirname(current_file_path)
except NameError:
    current_dir = os.getcwd()

parent_dir = os.path.dirname(current_dir)
LOGIC_PATH = os.path.join(parent_dir, 'logic')

if os.path.exists(LOGIC_PATH):
    if LOGIC_PATH not in sys.path:
        sys.path.insert(0, LOGIC_PATH)
    print("DEBUG: Logic path added successfully.")
else:
    print("ERROR: Could not find 'logic' folder.")

# --- 2. Import Module ---
try:
    import stats
    print("DEBUG: Successfully imported stats module.")
except ImportError as e:
    print(f"CRITICAL ERROR: Could not import stats. Error: {e}")
    stats = None

class TestStatsValidation(unittest.TestCase):
    """Test Class: Validates the statistics and charting logic."""

    def setUp(self):
        if stats is None:
            self.fail("Cannot run tests: stats module was not imported.")
            
        # Prepare test data
        self.valid_data = [
            {'exercise_name': 'Bench Press', 'max_weight': 100},
            {'exercise_name': 'Squat', 'max_weight': 150}
        ]
        self.empty_data = []

    # Ignore all plotting operations to prevent failure due to environment issues
    @patch('matplotlib.pyplot') 
    def test_valid_input(self, mock_plt):
        """Test 1: Valid data should run without crashing (Smoke Test)."""
        print("\nTesting valid input execution...")
        
        execution_success = False
        try:
            # We only care if an error occurs here
            stats.generate_workout_progress_chart(
                self.valid_data, 
                duration_sec=3600, 
                rest_sec=600, 
                total_vol=5000
            )
            # If execution reaches this line, no crash occurred
            execution_success = True
            print("DEBUG: Function executed successfully.")
            
        except Exception as e:
            print(f"DEBUG: Function CRASHED with error: {e}")
            execution_success = False
        
        # As long as it doesn't crash, consider it a pass
        self.assertTrue(execution_success, "The function crashed during execution. Check inputs.")

    @patch('builtins.print')
    def test_empty_input(self, mock_print):
        """Test 2: Empty data should execute without crashing."""
        print("\nTesting empty input...")
        
        try:
            stats.generate_workout_progress_chart(
                self.empty_data, 
                duration_sec=0, 
                rest_sec=0, 
                total_vol=0
            )
            # Similarly, pass as long as it doesn't crash
            self.assertTrue(True)
        except Exception as e:
            self.fail(f"Function crashed on empty input: {e}")

if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)