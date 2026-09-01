# Final Project
#Name: Ayleen Santander

#Library
import pandas as pd
import numpy as np
import params
from bs4 import BeautifulSoup
import requests
import time
import random
import csv
from  PIL import Image
import matplotlib.pyplot as plt
import seaborn as sns
import sqlite3
import re

from sklearn.utils.estimator_checks import check_classifiers_multilabel_output_format_predict

# Part 1: Introduction to Data Types and Storage Methods
# Hands-On: Load the Titanic dataset (available at the bottom of this page) and explore different types of data.
transatlantic = pd.read_csv('titanic.csv')
print(transatlantic.head())
print(transatlantic.info())
print(transatlantic.dtypes)

# Part 2: Compare and Contrast Types of Data Sources
# Hands-On: Write Python code to read data from different sources.
clone_transatlantic = transatlantic.copy()
clone_transatlantic.to_excel('clone_transatlantic.xlsx', index=False)
clone_transatlantic = pd.read_excel('clone_transatlantic.xlsx')
print(clone_transatlantic.head())

# Part 3: Structured vs. Unstructured Data
# Hands-On:Create examples of structured and unstructured data using Titanic Dataset
# structured_data.csv: Contains the structured data extracted from the Titanic dataset.
# unstructured_data.txt: Contains the unstructured data (names of passengers).

#1.Structured data
structured = transatlantic[[ "name", "age", "sex", "embarked", "home.dest"]]
print("Structured Data:")
print(structured.head())

#2.Unstructured data
#1. Text unstructured
unstructured = transatlantic.apply(lambda row:
    f"Passenger {row['name']} was a {row['age']} year old {row['sex']} "
    f"traveling in class {row['pclass']}. "
    f"{'Survived' if row['survived'] == 1 else 'Did not survive'}.", axis=1)

print("\nUNSTRUCTURED DATA:")
print(unstructured.head())
print(unstructured.info())

#3. Image
#Load Image
Image1 = Image.open('Titanic_1.jpg')
Image2 = Image.open('Titanic_2.jpg')
Image3 = Image.open('Titanic_3.jpg')
#Display the images
fig, axes = plt.subplots(1,3, figsize=(10,5))
axes[0].imshow(Image1)
axes[0].axis('off')
axes[0].set_title('Titanic 1')

axes[1].imshow(Image2)
axes[1].axis('off')
axes[1].set_title('Titanic 2')

axes[2].imshow(Image3)
axes[2].axis('off')
axes[2].set_title('Titanic 3')
plt.tight_layout()
# plt.axis('off')
plt.show()

#Part 4: Storage Considerations
#Hands-On:Implement storage solutions in Python.
data = {
    'StudentID': [1,2,3,4,5],
    'Name': ['Alice', 'Bob', 'Diana', 'Eve', 'Cleo'],
    'Course': ['Math', 'Science', 'Art', 'History', 'Music'],
    'Grade':       ['A', 'B', 'A', 'C', 'B'],
    'Score':       [95, 82, 91, 74, 88]
}

df = pd.DataFrame(data)
print(df.head())

# 1. Save as Excel
df.to_excel('students.xlsx', index=False)
print("Excel file saved: students.xlsx")

# 2. Save as CSV
df.to_csv('students.csv', index=False)
print("CSV file saved: students.csv")

# 3. Save as SQL Database
conn = sqlite3.connect('students.db')           # creates the database file
df.to_sql('students', conn,                     # 'students' is the table name
          if_exists='replace',                  # replace table if it already exists
          index=False)
conn.close()
print("SQL database saved: students.db")

#Verify: Read back all three files
print("\n Excel")
print(pd.read_excel('students.xlsx'))

print("\n CSV ")
print(pd.read_csv('students.csv'))

print("\n SQL")
conn = sqlite3.connect('students.db')
print(pd.read_sql('SELECT * FROM students', conn))
conn.close()

# Part 5: Integrate and Use an API
# Hands-On:Fetch weather data for the departure (Southampton) and arrival (New York) locations of the Titanic.
#Step 2: Second Methors API Data Acquisition/ Accessing OpenWeather data and import library previous
#My API Keys
api_key =  'f419a5dfd85013130cde8825389b4802'

#Define cities = Southampton and New York
city_1 = 'Southampton'
city_2 = 'New York'
url = 'https://api.openweathermap.org/data/2.5/weather'

#Obtain data from website
records =[]
for city in [city_1, city_2]:
    response = requests.get(url, params={'q': city, 'appid': api_key, 'units': 'metric'})

    if response.status_code == 200:
        data = response.json()
        print(f"City: {data['name']}")
        print(f"Temperature: {data['main']['temp']}°C")
        print(f"Humidity: {data['main']['humidity']}%")
        print(f"Weather: {data['weather'][0]['description']}")
        print('-' * 50)
    else:
        print(f"Error for {city}: {response.status_code} - {response.text}")

# Convert to DataFrame
records = []
for city in [city_1, city_2]:
    response = requests.get(url, params={'q': city, 'appid': api_key, 'units': 'metric'})
    if response.status_code == 200:
        data = response.json()
        records.append({
            'City': data['name'],
            'Temperature': data['main']['temp'],
            'Humidity': data['main']['humidity'],
            'Weather': data['weather'][0]['description']
        })
    else:
        print(f"Error for {city}: {response.status_code}")
df = pd.DataFrame(records)
print(f'Weather data departure Southampton and arrival New York:\n',df)


# Part 6: Data Quality Dimensions
# Hands-On:Assess the quality of the Titanic dataset.

print(clone_transatlantic.info())
clone_transatlantic = transatlantic.copy()
clone_transatlantic.to_csv('clone_transatlantic.csv', index=False)
clone_transatlantic = pd.read_csv('clone_transatlantic.csv')
print(clone_transatlantic.head())

#Step 1: Inspection dataset / Identify missing values
print('Missing Values:\n',clone_transatlantic.isnull().sum())

# Step 2: Replace None/null with NaN
clone_transatlantic['age'] = clone_transatlantic['age'].replace('null', np.nan)
clone_transatlantic['age'] = clone_transatlantic['age'].replace('None', np.nan)

# age           263
# fare            1
# cabin        1014
# embarked        2
# boat          823
# body         1188
# home.dest     564

# Step 3: Fill NaN with median
clone_transatlantic['age'] = clone_transatlantic['age'].fillna(clone_transatlantic['age'].median())

# Verify changes
print('Missing age values remaining:', clone_transatlantic['age'].isnull().sum())
print('Median age applied:           ', clone_transatlantic['age'].median())


print ("=" *50)
print ('TITANIC DATASSET - DATA QUALITY ASSESSMENT')
print ("=" *50)

summary = {
'Total Entries': clone_transatlantic.shape[0],
'Missing Values': clone_transatlantic.isnull().sum().to_dict(),
'Unique Values': clone_transatlantic.nunique().to_dict(),
'Data Types': clone_transatlantic.dtypes.to_dict(),
'Year of Service Statistics': {
'Count': clone_transatlantic['fare'].count(),
'Unique': clone_transatlantic['fare'].nunique(),
'Mean': round( clone_transatlantic['fare'].mean(),2),
'Median': clone_transatlantic['fare'].median(),
'Min': clone_transatlantic['fare'].min(),
'Max': clone_transatlantic['fare'].max()
}
}

# Display summary
for section, values in summary.items():
     print(f"\n{section}:")
     if isinstance(values, dict):
         for key, value in values.items():
            print(f"  {key}: {value}")
     else:
         print(f"  {values}")
#Final Assesment
print('\n=== DATA QUALITY ASSESSMENT')

#Step 1: Completness(missing Values)
total_cells =clone_transatlantic.shape[0] * clone_transatlantic.shape[1]
missing_cells = clone_transatlantic.isnull().sum().sum()
completeness = ((total_cells - missing_cells) / total_cells) * 100
print(f"\nCompleteness: {completeness:.2f}%")
print(f"Total cells: {total_cells}")
print(f"Missing cells: {missing_cells}")

#Step 2: Missing per column
print("\nMissing values per column:")
for col, count in clone_transatlantic.isnull().sum().items():
    pct = (count / len(clone_transatlantic)) * 100
    print(f"  {col}: {count} missing ({pct:.1f}%)")

#Step 3: Invalid values
print("\n 2. Accuracy: Outliers & Valid Ranges")
print(clone_transatlantic[['age', 'fare', 'sibsp', 'parch']].describe())

print(f"\nNegative Fares:      {(clone_transatlantic['fare'] < 0).sum()}")
print(f"Age below 0:         {(clone_transatlantic['age'] < 0).sum()}")
print(f"Age above 100:       {(clone_transatlantic['age'] > 100).sum()}")
print(f"Invalid Pclass:      {(clone_transatlantic['pclass'].isin([1, 2, 3])).sum()}")
print(f"Invalid Survived:    {(clone_transatlantic['survived'].isin([0, 1])).sum()}")

# 3. Consistency (duplicates, data types)
print("\n 3. Consistency: Duplicates & Data Types ")
print(f"Duplicate rows:      {clone_transatlantic.duplicated().sum()}")
print(f"\nData Types:\n{clone_transatlantic.dtypes}")
print(f"\nUnique values in 'Sex':      {clone_transatlantic['sex'].unique()}")
print(f"Unique values in 'Embarked': {clone_transatlantic['embarked'].unique()}")
print(f"Unique values in 'Pclass':   {clone_transatlantic['pclass'].unique()}")

#4. Timeliness
print("\n 4. Timeliness")
print("The Titanic dataset is a historical snapshot from 1912.")
print("No date columns are present — timeliness is not applicable.")

#Summary
print("\n  Summary ")
print(f"Total Rows:          {len(clone_transatlantic)}")
print(f"Total Columns:       {len(clone_transatlantic.columns)}")
print(f"Duplicate Rows:      {clone_transatlantic.duplicated().sum()}")
print(f"Columns with nulls:  {(clone_transatlantic.isnull().sum() > 0).sum()}")
print(f"Total Missing Cells: {clone_transatlantic.isnull().sum().sum()}")

# Part 7: Data Modeling
# Hands-On:Create a simple data model for a Hotel Management System. Completed in Lucichart


# Part 8: Data Visualization
# Hands-On:Create visualizations using matplotlib and seaborn.
# 1. Sales Distribution by Age

# d_b_a = clone_transatlantic.groupby('Product Name')['Total Sales'].sum().reset_index().sort_values('Total Sales', ascending=True)

plt.figure(figsize=(10, 5))
sns.barplot(data = clone_transatlantic, hue = 'sex',y = 'age',palette = 'Spectral',legend = 'auto',estimator = 'mean')
plt.title('Sales Distribution by age', fontsize= 16)
plt.xlabel('sex', fontsize= 14)
plt.ylabel('age', fontsize= 14)
plt.xticks(rotation=45, ha='right')
plt.grid(True)
plt.tight_layout()
plt.show()

# 2. Total Distribution by Fare

# d_b_f = clone_transatlantic.groupby('Payment Method')['Total Sales'].sum().reset_index().sort_values('Total Sales', ascending=False)

plt.figure(figsize=(10, 5))
sns.barplot(data = clone_transatlantic, hue = 'sex',y = 'fare',palette = 'flare',legend = 'auto',estimator = 'mean')
plt.title('Total Distribution by Fare', fontsize= 16)
plt.xlabel('sex', fontsize= 14)
plt.ylabel('fare', fontsize= 14)
plt.xticks(rotation=45, ha='right')
plt.grid(True)
plt.tight_layout()
plt.show()


# Part 9: Web Scraping
# Hands-On:Scrape additional data related to the Titanic from a website.
#Step 1: First Methods Web Scraping
url = "https://www.britannica.com/search?query=titanic"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.3"
}
#Make a requests to the website
response = requests.get(url, headers=headers)

#Check the status code to ensure the request was successfully (200)
if response.status_code == 200:
    print ("Successfully fetched the page!")
    print(response.text[:500])
else:
    print("Failed to retrieve the page")

#Parsing the HTML content using BeautifulSoup
soup = BeautifulSoup(response.content, 'html.parser')

#Print the parsed HTML
print(soup.prettify()[:500])

# Step 3: Find Headlines - get only the first one
headlines = soup.find_all('h1', class_='container_headline-text')

#Extract and print all the URLs
for headline in headlines:
    text = headline.find_all('h1', class_='text').text
    author = headline.find_all('small', class_='author').text
    print(f'Headline: {text}\nAuthor: {author}\n')
    print('-'*50)
#Handle Pagination
headlines_list =[]
while True:
    headlines = soup.find_all('h1', class_='container_headline-text')
    for headline in headlines:
        text = headline.text.strip()

        headlines_list.append({
            'text': text,
        })
    next_buttton = soup.find('li', class_='next')
    if next_buttton:
        next_page = next_buttton.find_all('a')['href']
        response = requests.get(url + next_page)
        soup = BeautifulSoup(response.text, 'html.parser')
    else:
        break
print(f'Total headlines: {len(headlines_list)}')

