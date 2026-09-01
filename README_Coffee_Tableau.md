# Analysis of Coffee Brand — Tableau Dashboard

A single-page Tableau dashboard exploring the global coffee brand landscape: how roast styles are distributed, whether price predicts quality, and which countries dominate by brand count.

**File:** `Final Project Part 1 - Tableau` (dashboard + PDF export)
**Course:** Willis College — Final Project, Part 1
**Author:** Ayleen Santander · June 2026
**Data source:** [Coffee Review](https://www.coffeereview.com/)

\---

## Dataset

|Item|Value|
|-|-|
|Source|Coffee Review — expert coffee ratings|
|Coverage|Last 6 years|
|Records|\~1,113 coffee brands|
|Producing countries|19 represented on the map|
|Price range|$0 – $140 USD|
|Rating range|\~84 – 96 (100-point scale)|

Grain: one row per reviewed coffee brand, carrying roast type, price (USD), rating, country of origin, and review year.

\---

## Tech stack

* **Tableau Desktop** — dashboard, calculated fields, trend line
* **Mapbox / OpenStreetMap** — basemap for the geographic view

\---

## Dashboard layout

Built as one screen with a narrative header, three analytical views in a top row, and a map beneath. Two global filters cross-filter everything.

### Header

Title bar plus a written summary of findings, so the dashboard reads on its own without a presenter.

### 1\. Roast type distribution (pie chart)

Share of brands by roast category:

|Roast|Share|
|-|-|
|Medium-Light|73.3%|
|Light|16.1%|
|Medium|9.2%|
|Medium-Dark|1.2%|
|Dark|0.24%|

### 2\. Price vs. rating (scatter plot with trend line)

Every brand plotted by price (x) against rating (y), with a linear trend line fitted across all points.

### 3\. Coffee brands by country (horizontal bar chart)

Count of brands per country, sorted descending, with the leader labelled as a percentage of the total.

### 4\. Producing countries (filled map)

The 19 origin countries highlighted on a Mapbox basemap — Latin America, East Africa, and Southeast Asia — giving a quick read on the coffee belt.

### Filters

* **Rating Slicer** — narrow to a rating band
* **Filter by Year** — isolate a single review year or view all six

\---

## Key findings

* **Ethiopia leads decisively** — 443 brands, 39.8% of all brands in the dataset, ahead of Colombia (151) and Kenya (143). Ethiopia and Colombia are also the most geographically concentrated origins.
* **Roast styles are lopsided** — medium-light alone accounts for 73.3% of brands, more than all other roast levels combined. Dark roast is nearly absent at 0.24%, suggesting the reviewed market skews heavily toward lighter, origin-forward profiles.
* **Price is a poor proxy for quality** — the price/rating relationship is statistically significant but practically weak (R² = 0.084, p < 0.0001). Price explains under 10% of the variation in rating, meaning origin, processing method, and other factors matter far more. A more expensive coffee is not a reliably better-rated one.

\---

## How to run

1. Open the `.twb` / `.twbx` in **Tableau Desktop** (or Tableau Public).
2. If the workbook is a `.twb`, repoint the data connection to your local copy of the Coffee Review extract.
3. Refresh the extract and interact with the Rating and Year filters.

The included PDF is a static export for quick viewing without Tableau installed.

\---

## Notes and limitations

* **Rounding is inconsistent in the header text** — medium-light appears as 73.32%, 73.34%, and 73.3% in different places, and the medium-light vs. "others" split reads 73.34% / 26.44%, which doesn't total 100%. Worth standardizing to one decimal place throughout before this goes public.
* **The map is decorative rather than analytical** — countries are highlighted but not encoded by brand count, average rating, or price. Colouring by a measure would make it earn its space instead of restating the bar chart.
* **Selection bias** — Coffee Review covers specialty coffees submitted for review, not the global market. The roast-type skew and the narrow rating band (\~84–96) both reflect that. Conclusions describe the specialty review universe, not coffee overall.
* **The trend line pools all origins together.** A weak overall correlation can mask stronger within-country relationships; faceting the scatter by origin would test that.
* **Dark roast at 0.24%** is too small to render a visible slice, so the pie shows four labels while the text describes five categories.

