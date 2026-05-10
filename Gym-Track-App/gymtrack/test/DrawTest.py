#!/usr/bin/env python
# coding: utf-8

# In[5]:


import sys
import os
import unittest
from unittest.mock import patch, MagicMock
import numpy as np 
try:
    current_file_path = os.path.abspath(__file__)
    current_dir = os.path.dirname(current_file_path)
except NameError:
    current_dir = os.getcwd()

parent_dir = os.path.dirname(current_dir)
path_to_logic = os.path.join(parent_dir, 'logic') 

if path_to_logic not in sys.path:
    sys.path.append(path_to_logic)


# 2.

# ==========================================
class TestStatsVisualization(unittest.TestCase):
    """Test Class 4: Visualization logic checks."""

    def setUp(self):
        self.patcher_show = patch('matplotlib.pyplot.show')
        self.patcher_subplots = patch('matplotlib.pyplot.subplots')
        self.mock_show = self.patcher_show.start()
        self.mock_subplots = self.patcher_subplots.start()
        
        self.mock_ax = MagicMock()
        self.mock_subplots.return_value = (MagicMock(), self.mock_ax)

    def tearDown(self):
        self.patcher_show.stop()
        self.patcher_subplots.stop()

    @patch('builtins.print')
    def test_high_weight_msg(self, mock_print):
        """Test 1: High weight triggers motivation message."""
        data = [
            {'exercise_name': 'Bench', 'max_weight': 95, 'date': '2023-01-01'},
            {'exercise_name': 'Bench', 'max_weight': 98, 'date': '2023-01-02'},
            {'exercise_name': 'Bench', 'max_weight': 100, 'date': '2023-01-03'}
        ] 
        
        stats.generate_workout_progress_chart(data)

        prints = [call[0][0] for call in mock_print.call_args_list]
        combined = " ".join(prints)

        self.assertIn("Good job", combined)

        self.assertNotIn("not in your mood", combined) 
        self.mock_show.assert_called_once()

    @patch('builtins.print')
    def test_low_weight_msg(self, mock_print):
        """Test 2: Low weight triggers other message."""
 
        data = [
            {'exercise_name': 'Bench', 'max_weight': 10, 'date': '2023-01-01'},
            {'exercise_name': 'Bench', 'max_weight': 12, 'date': '2023-01-02'},
            {'exercise_name': 'Bench', 'max_weight': 11, 'date': '2023-01-03'}
        ] 
        
        stats.generate_workout_progress_chart(data)

        prints = [call[0][0] for call in mock_print.call_args_list]
        combined = " ".join(prints)

        self.assertIn("not in your mood", combined)
        self.assertNotIn("Good job", combined)
        self.mock_ax.plot.assert_called()
        self.mock_show.assert_called_once()


if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)


# In[ ]:




