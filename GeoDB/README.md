# Notebook/Diaries
See folder /Diaries-Notebooks  
  
# Source code:
See folder /geoDBapi/R  
  
# Docs:
See folder /geoDBapi/man  
  
# Vignette:
See folder /geoDBapi/vignettes  
  
# Code of Conduct and License: 
See folder /geoDBapi
  
# Continuous Integration:  
Uses github actions to run devtools::check() (R cmd check .) which runs if any commit (push) is made to the main branch. It then checks our package and also runs all tests in the /geoDBapi/tests/testthat folder. If a test fails then the workflow build fails and we recieve an email.  
  
# Tests
See folders /geoDBapi/tests and /geoDBapi/tests/testthat
