#!/usr/bin/env python
# coding: utf-8

# In[4]:


import sys
import os
import unittest
from unittest.mock import MagicMock, ANY

# 路径设置保持不变
try:
    current_file_path = os.path.abspath(__file__)
    current_dir = os.path.dirname(current_file_path)
except NameError:
    current_dir = os.getcwd()

parent_dir = os.path.dirname(current_dir)
path_to_data = os.path.join(parent_dir, 'data')

if path_to_data not in sys.path:
    sys.path.append(path_to_data)

try:
    from db_manager import DBManager
except ImportError as e:
    print(f"\n❌ 无法导入 DBManager。请确认 db_manager.py 是否在: {path_to_data}")
    raise e

class TestDBFetching(unittest.TestCase):
    """Test Class 2: Data fetching methods."""

    @classmethod
    def setUpClass(cls):
        pass

    @classmethod
    def tearDownClass(cls):
        pass

    def setUp(self):
        self.db = DBManager()
        self.db.connection = MagicMock() 
        self.db.connection.is_connected.return_value = True

    def tearDown(self):
        self.db = None

    def test_fetch_exercises(self):
        """Test 1: Fetching exercises (Raw List)."""
        # 1. Mock DB
        cursor = MagicMock()
        # 模拟返回原始数据
        cursor.fetchall.return_value = [
            {'e_exerciseId': 1, 'e_itemName': 'PushUp', 'body_part': 'Chest'}
        ]
        self.db.connection.cursor.return_value = cursor

        # 2. 执行
        result = self.db.fetch_all_exercises()

        # 3. 断言 (修改为验证 List)
        # 验证返回的是列表
        self.assertIsInstance(result, list) 
        # 验证列表中第一个元素的名称是 'PushUp'
        # 注意：这里用数据库原始字段名 'e_itemName'，而不是重命名后的 'name'
        self.assertEqual(result[0]['e_itemName'], 'PushUp')
        self.assertEqual(result[0]['body_part'], 'Chest')
        
        cursor.execute.assert_called_once()

    def test_fetch_stats(self):
        """Test 2: Fetching user stats."""
        # 保持不变
        cursor = MagicMock()
        cursor.fetchall.return_value = [{'exercise_name': 'Squat', 'max_weight': 100}]
        self.db.connection.cursor.return_value = cursor

        result = self.db.fetch_user_max_weight_stats(1000)

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['max_weight'], 100)
        cursor.execute.assert_called_with(ANY, (1000,))

if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)


# In[ ]:




