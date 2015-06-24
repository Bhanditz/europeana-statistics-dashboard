INSTALLATION

$python --version    
Python 2.7.6

2.7.x is fine. 3.x is not supported

$sudo pip install Scrapy

$scrapy --version

Scrapy 0.24.1

0.24.x is fine.

$sudo pip install PyYAML

$sudo pip install xlrd

$sudo pip install psycopg2

$sudo pip install SQLAlchemy

$sudo pip install pymongo


RUNNING THE SCRAPER

$ cd datahub-rubber/python/govcatalogs/ directory

$ scrapy crawl gov_catalogs

OR 

$ scrapy crawl gov_catalogs -a days=365
