Web Scraping
#Name: Ayleen Santander
from email.quoprimime import header_decode

# Instructions
#webpage to scrape: https://books.toscrape.com/

# Complete the following tasks:
#Part 1: Importing the libraries
import requests
import pandas as pd
import re
from bs4 import BeautifulSoup
from fontTools.t1Lib import std_subrs
from selenium import webdriver
from selenium.webdriver.chrome.service import Service

#Part 2:  Send an HTTP Request
url = 'https://books.toscrape.com//catalogue/category/books/romance_8/'
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'}
response = requests.get(url, headers=headers)
html = response.content

#Part 3:  Parse the HTML
soup = BeautifulSoup(html, 'html.parser')
books = soup.find_all('article', class_='product_pod')

#Part 4: Extract and print the data title book "Sit, Stay, Love"
for book in books:
    title = book.find('h3').find('a')['title']
    rating = book.find('p', class_='star-rating')['class'][1]
    print(f'Title: {title}\nRating: {rating}\n')

#Part 5: Handle Pagination
for page in range(2, 5):
    url = f'https://books.toscrape.com/catalogue/page-{page}.html'
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.content, 'html.parser')
    books = soup.find_all('article', class_='product_pod')
    for book in books:
        title = book.find('h3').find('a')['title']
        print(f'Pagination here is the Titles: {title}')

#Part 6: Handling Dynamic Content with Selenium
driver = webdriver.Chrome()
driver.get('https://books.toscrape.com/')
html = driver.page_source
soup = BeautifulSoup(html, 'html.parser')
books = soup.find_all('article', class_='product_pod')
data = []
for book in books:
    h3 = book.find('h3')
    if h3 is None:
        continue
    title = h3.find('a')['title']
    availability = book.find('p', class_='instock availability').text.strip()
    rating = book.find('p', class_='star-rating')['class'][1]
    data.append({'Title': title, 'Availability': availability, 'Rating': rating})

driver.quit()

df = pd.DataFrame(data)

#Part 8: Cleaning the data remove bracket and symbols
df['Title']= df['Title'].str.replace(r'[# ():\"\'£]','', regex=True)

print(df)
#Part 9: Data Transformation
rating_map = {'One': 1, 'Two': 2, 'Three': 3, 'Four': 4, 'Five': 5}
df['Rating'] = df['Rating'].map(rating_map)
df = df.sort_values('Rating', ascending=False)
df.to_csv('books.csv', index=False)

print(f'Save is done',df)


# Document Your Work (Include screenshots of the web page, your code, and a sample of the extracted data.)
# Deliverable
#
# Submit the assignment as a Python script (.py file) containing the web scraping code, the extracted data saved as a CSV file, and a report as a PDF or Word document.
