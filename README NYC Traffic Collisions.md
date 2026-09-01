# NYC Traffic Collisions: Where, When \& Why

A two-page Power BI report analyzing motor vehicle collisions in New York City — when they happen, where they cluster, what vehicles are involved, and which driver behaviours drive both crashes and fatalities.

**File:** `Final\_Project\_M\_8\_Power\_BI.pbix`
**Course:** Willis College — M.8 Data Wrangling and Visualization
**Author:** Ayleen Santander · June 2026
**Data source:** Motor Vehicle Collisions (NYC Open Data)

\---

## Dataset

|Item|Value|
|-|-|
|Source file|`NYC\_Collisions.csv` (18 columns)|
|Rows loaded|216,098 collisions|
|Date range|2021-01-01 → 2023-04-09|
|Boroughs|5 (Brooklyn, Queens, Bronx, Manhattan, Staten Island)|
|Distinct streets|\~5,200|
|Distinct cross streets|\~5,100|
|Persons injured|104,334|
|Persons killed|544|

Grain: one row per collision, with location (borough, street, cross street, lat/long), timestamp, contributing factor, vehicle type, and injury/fatality counts split by motorist, cyclist, and pedestrian.

\---

## Tech stack

* **Power BI Desktop** — report, data model, DAX
* **Power Query (M)** — ingestion and cleaning
* **CSV** — flat-file source

\---

## Data preparation (Power Query)

1. Load CSV, promote headers, and set explicit data types (dates, times, integers, decimals).
2. Convert `Longitude` to its absolute value to correct sign errors in the raw feed.
3. Replace blanks with explicit placeholders so nulls don't silently disappear from visuals:

   * `Borough` → `"No Inf provide"`
   * `Street Name` → `"No inf provide"`
   * `Contributing Factor` → `"Undescribed"`
   * `Cross Street` → `"Not at intersection"`
4. Filter out rows with missing `Latitude` or `Longitude`.
5. Duplicate `Time` and extract the hour into `Time - Copy` for time-of-day analysis.

\---

## Data model

Single fact table: **`NYC\_Collisions (2)`** (flat model, no dimension tables). Power BI's automatic time intelligence generates hidden local date tables behind the `Date` column.

### Calculated columns

|Column|DAX|
|-|-|
|`DayOFTheWeek`|`FORMAT('NYC\_Collisions (2)'\[Date], "dddd")`|
|`Time (bins)`|`IF(ISBLANK(\[Time]), BLANK(), (INT((\[Time] \* 1440) / 60) \* 60) / 1440)` — rounds each timestamp down to the hour|

### Measures

|Measure|DAX|
|-|-|
|`Total Collisions`|`COUNTROWS('NYC\_Collisions (2)')`|
|`Total Boroughs`|`DISTINCTCOUNT('NYC\_Collisions (2)'\[Borough])`|
|`Total Streets`|`DISTINCTCOUNT('NYC\_Collisions (2)'\[Street Name])`|
|`Total Cross Streets`|`DISTINCTCOUNT('NYC\_Collisions (2)'\[Cross Street])`|
|`First Collision`|`MIN('NYC\_Collisions (2)'\[Date].\[Date])`|
|`Last Collision`|`MAX('NYC\_Collisions (2)'\[Date])`|
|`Total Persons Injured`|`SUM('NYC\_Collisions (2)'\[Persons Injured])`|
|`Total Persons Killed`|`SUM('NYC\_Collisions (2)'\[Persons Killed])`|
|`Total Motorist Injured/ Killed`|`SUM(\[Motorists Injured]) + SUM(\[Motorists Killed])`|
|`Total Cyclist Injured / Killed`|`SUM(\[Cyclists Injured]) + SUM(\[Cyclists Killed])`|
|`Total Pedestrians Injured / Killed`|`SUM(\[Pedestrians Injured]) + SUM(\[Pedestrians Killed])`|
|`Uncategorized Injured`|Injuries not attributed to motorists, cyclists, or pedestrians|
|`Uncategorized Killed`|Fatalities not attributed to motorists, cyclists, or pedestrians|
|`Other Persons`|Total casualties minus the three named categories|

\---

## Report pages

### 1\. Person and Period Overview

Sets the scope of the data and answers *when* collisions happen.

* **Dynamic summary text** — narrates the date range, total collisions, boroughs, streets, and intersections directly from measures, so it updates with the data.
* **Borough slicer** — cross-filters the page.
* **Line chart** — `% Total Collisions by Month`.
* **Multi-row card** — casualty breakdown by road-user type (motorist / cyclist / pedestrian / uncategorized).
* **Matrix** — collision frequency by hour of day × day of week, forming a heat-map-style rush-hour view.

### 2\. Collision Overview

Answers *where* and *why*.

* **Column chart** — collisions by street name (Top N).
* **Column chart** — top 7 vehicle types, excluding `Passenger Vehicle` so the long tail is readable.
* **Bar chart** — top 7 contributing factors of collisions, excluding `Unspecified`.
* **Bar chart** — top 7 contributing factors of fatalities, split by motorists / pedestrians / cyclists killed.
* **Commentary boxes** — written interpretation beside each visual.

Both pages use navigation buttons and a shared image/title header for a consistent layout.

\---

## Key findings (as reported)

* **Seasonality** — collisions peak in **March (10.4%)** and **June (8.4%)**, which the report links to higher event and pedestrian activity in those months.
* **Time of day** — collisions cluster on **weekday afternoons, 2–6 PM**, and bottom out pre-dawn; weekends show a flatter daytime curve, pointing to commuting as the weekday driver.
* **Location** — **Belt Parkway** is the single highest-collision street at **10.7%** of the streets shown.
* **Vehicles** — once passenger vehicles are set aside, **Transport (public) 38.64%** and **Taxi 35.73%** dominate.
* **Behaviour** — **Unsafe Speed** is the leading named factor (**51.14%** within the charted set), followed by **Unsafe Lane Changing (27.18%)**. Unsafe speed is also the top factor in fatalities across all three road-user groups: motorists 96.70%, cyclists 75%, pedestrians 71.43%.

\---

## How to run

1. Clone or download this repo.
2. Download `NYC\_Collisions.csv` from NYC Open Data and save it locally.
3. Open the `.pbix` in **Power BI Desktop**.
4. Go to **Transform data → Data source settings** and repoint the CSV path to your local copy (the file currently references an absolute OneDrive path from the original machine).
5. **Refresh**.

\---

## Notes and limitations

* The source path is hard-coded to a local drive; parameterizing it would make the file portable.
* The model is a single flat table. A proper star schema — a shared `Date` dimension plus lookup tables for borough, vehicle type, and contributing factor — would replace the auto-generated local date tables and scale better.
* Percentages in the commentary describe the **filtered Top-N views** (with `Passenger Vehicle` and `Unspecified` excluded), not the full 216K-row dataset. Read them as shares within each chart.
* `Unspecified` and `Driver Inattention/Distraction` together account for roughly half of all rows in the raw data, so contributing-factor conclusions rest on a partial picture.
* Latitude/longitude are cleaned and loaded but not yet used in a map visual — an obvious next addition.

