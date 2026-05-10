#!/usr/bin/env python
# coding: utf-8

import sys
import os
import unittest
from unittest.mock import patch, MagicMock

# --- 1. Dynamic Path Setup ---
try:
    current_file_path = os.path.abspath(__file__)
    current_dir = os.path.dirname(current_file_path)
except NameError:
    current_dir = os.getcwd()

parent_dir = os.path.dirname(current_dir)
DATA_PATH = os.path.join(parent_dir, 'data')

if os.path.exists(DATA_PATH):
    if DATA_PATH not in sys.path:
        sys.path.insert(0, DATA_PATH)
    print("DEBUG: Data path found and added successfully.")
else:
    print("ERROR: Could not find 'data' folder relative to this test file.")

# --- 2. Import Module ---
try:
    from db_manager import DBManager
    from mysql.connector import Error
    print("DEBUG: Successfully imported DBManager class.")
except ImportError as e:
    print(f"CRITICAL ERROR: Could not import DBManager. Error: {e}")
    DBManager = None
    Error = Exception

# ⚠️ 关键点：类名必须是 TestDBConnection，以便 TestSuite.py 能找到它
class TestDBConnection(unittest.TestCase):
    """
    Comprehensive tests for DBManager to achieve high coverage.
    """

    @classmethod
    def setUpClass(cls):
        cls.config_patcher = patch('db_manager.DB_CONFIG', {
            'host': 'test_host',
            'user': 'test_user',
            'password': 'test_password',
            'database': 'test_db'
        })
        cls.config_patcher.start()

    @classmethod
    def tearDownClass(cls):
        cls.config_patcher.stop()

    def setUp(self):
        if DBManager is None:
            self.fail("Cannot run tests: DBManager class was not imported.")
        self.db = DBManager()

    def tearDown(self):
        self.db = None

    # --- Test Group 1: Connection Logic ---

    @patch('mysql.connector.connect')
    def test_connect_success(self, mock_connect):
        """Test successful connection."""
        mock_conn = MagicMock()
        mock_conn.is_connected.return_value = True
        mock_connect.return_value = mock_conn

        result = self.db.connect()

        self.assertTrue(result)
        self.assertIsNotNone(self.db.connection)
        mock_connect.assert_called_once()

    @patch('mysql.connector.connect')
    def test_connect_failure(self, mock_connect):
        """Test connection failure."""
        mock_connect.side_effect = Error("Connection failed")

        result = self.db.connect()

        self.assertFalse(result)
        self.assertIsNone(self.db.connection)

    def test_close_connection(self):
        """Test close() method."""
        mock_conn = MagicMock()
        mock_conn.is_connected.return_value = True
        self.db.connection = mock_conn

        self.db.close()

        mock_conn.close.assert_called_once()

    def test_close_no_connection(self):
        """Test close() when no connection exists."""
        self.db.connection = None
        self.db.close()

    # --- Test Group 2: fetch_all_exercises ---

    def test_fetch_all_exercises_success(self):
        """Test fetching exercises."""
        mock_conn = MagicMock()
        mock_conn.is_connected.return_value = True
        mock_cursor = MagicMock()
        
        expected_data = [
            {'e_exerciseId': 1, 'e_itemName': 'Push Up', 'body_part': 'Chest'}
        ]
        mock_cursor.fetchall.return_value = expected_data
        
        mock_conn.cursor.return_value = mock_cursor
        self.db.connection = mock_conn

        result = self.db.fetch_all_exercises()

        self.assertEqual(result, expected_data)

    def test_fetch_all_exercises_db_error(self):
        """Test DB error during fetch."""
        mock_conn = MagicMock()
        mock_conn.is_connected.return_value = True
        mock_cursor = MagicMock()
        mock_cursor.execute.side_effect = Error("Query failed")
        
        mock_conn.cursor.return_value = mock_cursor
        self.db.connection = mock_conn

        result = self.db.fetch_all_exercises()

        self.assertEqual(result, [])

    # --- Test Group 3: fetch_user_max_weight_stats ---

    def test_fetch_user_stats_success(self):
        """Test fetching user stats."""
        mock_conn = MagicMock()
        mock_conn.is_connected.return_value = True
        mock_cursor = MagicMock()
        
        expected_data = [{'exercise_name': 'Bench Press', 'max_weight': 100}]
        mock_cursor.fetchall.return_value = expected_data
        mock_conn.cursor.return_value = mock_cursor
        self.db.connection = mock_conn

        result = self.db.fetch_user_max_weight_stats(123)

        self.assertEqual(result, expected_data)

if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)