# Titanic Dataset — Data Handling Final Project (Module 7)

An end-to-end data project on the classic Titanic dataset, covering the full data-handling workflow: loading data, working with multiple data sources and storage formats, accessing a live API, auditing data quality, modeling, visualization, and web scraping.

## Overview

This project demonstrates a complete data pipeline using the Titanic passenger dataset (1,309 records). Each section maps to a core data skill, from raw ingestion through cleaning, analysis, and external data acquisition.

## Tech Stack

* **Language:** Python 3
* **Data handling:** pandas, NumPy
* **Storage:** SQLite (`sqlite3`), Excel (`openpyxl`), CSV
* **Web \& API:** `requests`, BeautifulSoup (`bs4`)
* **Visualization:** Matplotlib, Seaborn
* **Other:** Pillow (`PIL`), `re`, `json`
* **Environment:** Google Colab / Jupyter Notebook

## Project Structure

The notebook is organized into nine parts:

|Part|Topic|What it does|
|-|-|-|
|1|Data Types \& Storage|Loads the Titanic CSV; inspects shape, dtypes, and null counts with `.info()` and `.dtypes`|
|2|Comparing Data Sources|Round-trips the data through Excel (CSV → `.xlsx` → DataFrame)|
|3|Structured vs. Unstructured|Builds a structured table, generates unstructured passenger text, and loads 3 images|
|4|Storage Considerations|Saves the same dataset as Excel, CSV, and a SQLite database, then reads each back to verify|
|5|API Integration|Pulls live weather for Southampton (departure) and New York (arrival) from the OpenWeather API|
|6|Data Quality Dimensions|Audits completeness, accuracy, consistency, and timeliness; imputes missing ages with the median|
|7|Data Modeling|Entity model for a Hotel Management System (built in Lucidchart)|
|8|Data Visualization|Seaborn bar plots of average age and fare by sex|
|9|Web Scraping|Scrapes the Wikipedia "Wreck of the Titanic" article, cleans citations, and round-trips through JSON|

## Key Results

* **Dataset:** 1,309 passengers across 14 columns
* **Data completeness:** \~80.4% (3,592 missing cells, mostly in `cabin`, `boat`, and `body`)
* **Missing age handling:** 263 missing values imputed with the median (28.0)
* **No duplicate rows** and no invalid values found in `pclass` or `survived`
* **Web scraping:** 5 cleaned paragraphs extracted and serialized to JSON

## Getting Started

### Prerequisites

```bash
pip install pandas numpy beautifulsoup4 requests pillow matplotlib seaborn
```

### Data files

Place the following in the project directory:

* `titanic.csv` — the Titanic dataset
* `Titanic\_1.jpg`, `Titanic\_2.jpg`, `Titanic\_3.jpg` — images used in Part 3

### API key (Part 5)

Part 5 calls the [OpenWeather API](https://openweathermap.org/api). Sign up for a free key and set it as an environment variable instead of hardcoding it:

```python
import os
api\_key = os.environ\["OPENWEATHER\_API\_KEY"]
```

> \*\*Security note:\*\* Never commit a real API key to a public repository. If a key has ever been pushed, revoke and regenerate it.

### Run

Open the notebook in Jupyter or Google Colab and run the cells top to bottom.

## License

This project is for educational purposes.

## Author

Ayleen Santander

