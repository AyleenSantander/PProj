# New York City Airbnb Open Data (2019) — Exploratory Data Analysis

Exploratory data analysis of \~49,000 Airbnb listings in New York City, focused on one question:

> \*\*How does the number of reviews relate to the price, availability, and other features of a listing?\*\*

[!\[Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Ryan32423/Notebook-Example/blob/main/Project_NYC_Airbnb.ipynb)

\---

## Project Overview

This project takes the listing data through a full analytics pipeline: data inspection, cleaning, distribution and outlier analysis, feature scaling, correlation testing, and a first pass at predictive modeling. The goal is to understand whether the number of reviews a listing receives is connected to its price or its availability.

## Dataset

* **Source:** New York City Airbnb Open Data (2019)
* **Size:** 48,895 rows × 16 columns
* **Key columns:** `price`, `number\_of\_reviews`, `availability\_365`, `minimum\_nights`, `room\_type`, `neighbourhood\_group`
* **Known data quality issues:** missing values in `name`, `host\_name`, `last\_review`, and `reviews\_per\_month`

## Tools \& Libraries

* **Language:** Python
* **Data handling:** pandas, NumPy
* **Visualization:** Matplotlib, Seaborn
* **Machine learning:** scikit-learn (Isolation Forest, RobustScaler, KMeans, Decision Tree, KNN)
* **Statistics:** SciPy (Pearson correlation)
* **Environment:** Google Colab

## Workflow

1. **Data inspection** — shape, types, nulls, duplicates, and summary statistics.
2. **Cleaning** — handled missing values and reduced the dataset to the columns relevant to the question.
3. **Distribution analysis** — histograms and box plots for `price`, `availability\_365`, and `number\_of\_reviews`.
4. **Outlier detection** — Isolation Forest plus an IQR check to quantify extreme values.
5. **Transformation \& scaling** — log transformation to reduce skew, then RobustScaler for normalization.
6. **Correlation analysis** — heatmap and Pearson correlation with p-values.
7. **Modeling** — supervised (Decision Tree, KNN) and unsupervised (KMeans with the Elbow Method and Silhouette Score).

## Key Findings

* **Number of reviews is not related to price.** The correlation between `number\_of\_reviews` and `price` is essentially zero (r ≈ −0.05). Listings with more reviews are *not* priced higher or lower in any meaningful way.
* **Reviews relate slightly to availability.** There is a weak positive correlation (r ≈ 0.17) between reviews and `availability\_365` — listings available more days of the year tend to collect a few more reviews.
* **The data is heavily skewed.** `price` had a skewness of \~19 before transformation. A log transformation brought it down to \~0.55, making the distribution close to normal.
* **About 5% of listings are anomalies** (extreme prices or review counts), identified with Isolation Forest.
* **Two natural groupings** emerged from KMeans (best k = 2 by silhouette score).

## Visualizations

* Distribution histograms (price, availability, reviews)
* Box plots for outlier comparison
* Pair plot of the three main numeric features
* Isolation Forest outlier scatter plots
* Before/after log-transformation comparison
* Before/after scaling comparison
* Correlation heatmap
* Elbow Method and Silhouette Score curves

## Limitations \& Next Steps

* **Reframe the prediction task as regression.** `availability\_365` is a continuous value (0–365), so the classification models in this version produced low accuracy. A regression model (e.g. `DecisionTreeRegressor`), or binning availability into ranges (Low / Medium / High), would be more appropriate.
* **Add more predictors.** Using only `number\_of\_reviews` to predict availability is too narrow. Including `price`, `room\_type`, and `neighbourhood\_group` should improve the model.
* **Engineer categorical features correctly.** Encode `room\_type` and `neighbourhood\_group` with `LabelEncoder` or one-hot encoding so they can feed into the models.
* **Geographic analysis.** The dataset includes latitude/longitude — a map of price or reviews by neighborhood would add strong visual insight.

## How to Run

1. Open the notebook in Google Colab using the badge above.
2. Upload the `AB\_NYC\_2019.csv` dataset.
3. Run the cells in order from top to bottom.

## Author

**Ayleen Santander** — Data Analytics \& Business Intelligence

