import requests
import sys
import re
from bs4 import BeautifulSoup

mainFile = open('./artistScrape.txt','a+')

imutex = 0
mutex1 = 0

url = sys.argv[1]
data = requests.get(url)

souped = BeautifulSoup(data.text, 'html.parser')

data = []

for div in souped.find_all('textarea', { 'class': 'textarea'  }):
    mainFile.write(div.text)

mainFile.close()
