#!/usr/bin/env python
# coding: utf-8

# In[13]:


import unittest

from ConnectTest import TestDBConnection
from DrawTest import TestStatsVisualization
from RecheckTest import TestStatsValidation
from SearchTest import TestDBFetching
suite = unittest.TestSuite()

loader = unittest.TestLoader()
suite.addTests(loader.loadTestsFromTestCase(TestDBConnection))
suite.addTests(loader.loadTestsFromTestCase(TestDBFetching))
suite.addTests(loader.loadTestsFromTestCase(TestStatsValidation))

runner = unittest.TextTestRunner(verbosity=2)
runner.run(suite)


# In[11]:





# In[ ]:




