# Final Project – E-Commerce Feedback Integration

**Name:** Ayleen Santander
**Database:** `Duplicatee\_E\_CommerceCompanyDB`

This README explains how to run everything in order, structured to follow the assignment brief itself (Part 1). Run the numbered SQL/Python files top to bottom;
each section below says what that step covers and why it comes where it does.

\---

## Setup — before running anything

1. **MySQL 8.0+** (required — `JSON\_TABLE` and window functions don't exist in 5.7).
2. **Python 3.9+** with `pandas` installed.
3. Enable local file loading on both the server and the client:

```sql
   SHOW GLOBAL VARIABLES LIKE 'local\_infile';
   SET GLOBAL local\_infile = 1;
   ```

```
   mysql --local-infile=1 -u root -p
   ```

4. Check where the server will actually read files from, and copy the raw source files there — this is the step that blocked `LOAD XML INFILE` until it was done:

```sql
   SHOW VARIABLES LIKE 'secure\_file\_priv';
   ```

```
   copy "C:\\Users\\aylee\\Downloads\\customer\_survey.csv"  "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\"
   copy "C:\\Users\\aylee\\Downloads\\external\_reviews.xml" "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\"
   ```

   Confirm the file actually landed with `dir "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\"` before retrying the load.

\---

## Part 1: Database Design

### `01\_create\_schema.sql`

* Drops and recreates `E\_CommerceCompanyDB` from scratch (item 5).
* Creates `customers`, `products`, and `reviews`, normalized to **3NF**: customer region/country and product category are each held once rather than repeated per row.
* `reviews` defines:

  * `CHECK (rating BETWEEN 1 AND 5)` (item 3).
  * `FOREIGN KEY (customerid) REFERENCES customers(customerid) ON DELETE CASCADE ON UPDATE CASCADE` and the same pattern for `productid` (item 3).
  * **`customerid` is `NOT NULL`** — the business rule is that a review only exists once a customer submits a comment to finalize it, so a review with no customer should never
be a valid state at the database level (item 3's justification).
  * `UNIQUE (customerid, productid)` plus a composite source/record-id uniqueness rule so re-running an import is safe even though the three feeds issue colliding IDs (item 4).
* Also creates `Dim\_Date` and `OrdersFact`, the star-schema pieces used later for the sales/rating comparison.

Run:

```sql
SOURCE 01\_create\_schema.sql;
```

\---

## Part 2: Data Integration

### `02\_create\_staging\_tables.sql`

Create DB and Load data in SQL.

* `customer\_survey` — CSV target.
* `external\_reviews\_native` — XML target.
* `web\_feedback\_from\_json` — target for the Python-flattened JSON output.

### `web\_feedback\_json.py`

`web\_feedback.json` is one object containing an array, so it can't be loaded line-by-line (item 3). This script:

1. `json.load()`s the file.
2. `pd.json\_normalize(data\['submissions'])` to flatten the nested `customer`/`product`objects.
3. Handles the field that's sometimes absent rather than empty (`customer\_email`, via `.get()`/`or 'N/A'`) and the field whose type varies between records (`verified\_purchaser`).
4. Writes the flat result to `web\_feedback\_from\_json.csv`.

Run:

```
python parse\_web\_feedback\_json.py
```

Copy the output CSV into the MySQL uploads folder from Setup step 4.

### `03\_load\_staging\_data.sql`

* **CSV:** `LOAD DATA LOCAL INFILE 'customer\_survey.csv' INTO TABLE customer\_survey ...` (item 2).
* **JSON-derived CSV:** `LOAD DATA LOCAL INFILE 'web\_feedback\_from\_json.csv' ...`
* **XML:** `LOAD XML INFILE '.../external\_reviews.xml' INTO TABLE external\_reviews\_native ROWS IDENTIFIED BY '<review>';` (item 4).

  * `LOAD XML INFILE` only reads **xml**, not attributes on the root or child elements — where the file's ID/date/score values live as attributes rather than element text, they came back empty and had to be picked up separately with `xml.etree.ElementTree` in Python. This is the "explain what it could and could not read" justification the report calls for.
  * Getting here required: confirming `secure\_file\_priv`'s target directory, copying the XML file into it from `cmd`, verifying the copy with `dir`, then re-running `SHOW GLOBAL VARIABLES LIKE 'local\_infile'` / `SET GLOBAL local\_infile = 0/1` until the client and server flags agreed — documented in full in the report.

Sanity check row counts right after loading:

```sql
SELECT COUNT(\*) FROM customer\_survey;          -- 67 raw rows
SELECT COUNT(\*) FROM external\_reviews\_native;  -- 33 rows
SELECT COUNT(\*) FROM web\_feedback\_from\_json;   -- 38 rows
```

### `04\_clean\_staging\_data.sql`  

Each fix is a **separate, commented** `UPDATE`:

1. Inconsistent case/whitespace in names and emails.
2. Two date formats in `customer\_survey.submitted\_on` — standardized to one format.
3. Ratings outside 1–5 nulled out (`SQL\_SAFE\_UPDATES` toggled off/on around the statement).
4. `external\_reviews\_native`'s 0–10 scale rescaled into a new `score\_normalized` column on the shared 1–5 scale.
5. Call`customer\_survey` submissions identified and removed 'customer\_ID' using a \_**key** to match all tables (`respondent\_email`, `product\_label`, `rating\_1\_5`, `open\_comment`), since the duplicates don't share a record ID.

### `05\_create\_reject\_log\_and\_dims.sql` 

* `reject\_log` — every nulled/rejected value gets a row here with a reason, so deletions are never silent and row counts stay reconcilable.

### `06\_promote\_to\_fact.sql` (item 7)

Three `INSERT INTO fact\_review and  SELECT` statements, one per source, each: 

* `LEFT JOIN`s to `dim\_customer` on normalized email, so a review with no matching customer **still loads**. 
* Uses `ON DUPLICATE KEY UPDATE` for idempotent re-runs.

Verify:

```sql
SELECT source\_system, COUNT(\*) AS promoted\_rows
FROM fact\_review
GROUP BY source\_system;
```

\---

## Part 3: Queries, Optimization and Testing

### `07\_create\_views.sql`

* **`vw\_all\_reviews\_combined`** (item 1) — `LEFT JOIN` across customer/product/review so no review drops for lacking a customer link; row count must match `reviews`/`fact\_review`.
* Analysis queries, run ad hoc or saved in this same file:

  * Top products by rating **and** sales, with `HAVING COUNT(reviewid) >= 1` (or a weighted score) so a two-review product can't outrank a well-reviewed one on raw `AVG(rating)` alone.
  * Recurring issues by category, using the `issue\_keyword\_map` **table** joined via `LIKE CONCAT('%', keyword, '%')` — not a hard-coded `CASE` chain.
  * Rating trend by month (`DATE\_FORMAT(Full\_Date, '%Y-%m')`), positive/negative split, keyword frequency, and customer engagement by region.
  * Three-source comparison, quantifying how much the feeds disagree per SKU rather than asserting they agree.
  * *(Watch-for:* reviews and sales sit at different grains — joining both to `products` in the same query multiplies revenue by review count, so they're queried separately.)
* **`vw\_top\_rated\_products`** and **`vw\_flagged\_reviews`** (item 3):

  * **Flagged definition:** a review is flagged if **either** condition is true — rating ≤ 2 (`'Low Rating'`), **or** its comment matches a negative keyword in `issue\_keyword\_map` (`'Negative Keyword'`, e.g. build-quality issue, assembly issue).

### `08\_create\_indexes.sql`  

Run `EXPLAIN` on the queries above **before** creating any index. Then, named to the
query each serves:

* `idx\_reviews\_productid` — the `Reviews ⋈ Products` join in `vw\_top\_rated\_products`.
* `idx\_reviews\_rating` — the `WHERE rating <= 2` filter in `vw\_flagged\_reviews`.
* `idx\_customers\_region` — the `GROUP BY region` engagement query.
* `idx\_reviews\_fulldate` — the monthly trend `GROUP BY`.

Indexes are created **after** the bulk load — building them before loading would force MySQL to update the index on every single inserted row instead of once at the end. Re-run the same `EXPLAIN` statements after creating the indexes and paste both sets of output into the report. On this dataset size the optimizer may legitimately ignore an  index (`Using temporary`/full scan either way) — report that honestly rather than inventing a speedup.

### `09\_run\_validation\_queries.sql`  

Seven checks, each returning a `'PASS'`/`'FAIL'` result column:

1. Rows staged = rows loaded + rows rejected.
2. No `(source\_system, source\_id)` pair loaded twice.
3. All ratings/`score\_normalized` values in range.
4. No orphaned foreign keys (every non-null `fact\_review.customer\_id` resolves in`dim\_customer`).
5. No implausible dates (not in the future, not before 2020-01-01).
6. `vw\_all\_reviews\_combined` row count matches `fact\_review` row count.
7. Aggregate averages recomputed from raw rows match the reported summary averages, per source system.

Run this last, after every step above — all seven should report `PASS`.

### &#x20;

&#x20;

## Run order summary

&#x20;
0. Setup: enable local\_infile, locate secure\_file\_priv, copy raw source files in
1. 01\_create\_schema.sql
2. 02\_create\_staging\_tables.sql
3. python parse\_web\_feedback\_json.py / (produces web\_feedback\_from\_json.csv)
4. 03\_load\_staging\_data.sql
5. 04\_clean\_staging\_data.sql
6. 05\_create\_reject\_log\_and\_dims.sql
7. 06\_promote\_to\_fact.sql
8. 07\_create\_views.sql
9. 08\_create\_indexes.sql
10. 09\_run\_validation\_queries.sql
```

## Deliverables checklist

|Item|File|
|-|-|
|ER diagram (PNG/PDF, all tables + keys + cardinality)|`ER\_Diagram\_ECommerce.pdf`|
|Numbered SQL scripts|`01\_create\_schema.sql` – `09\_run\_validation\_queries.sql`|
|Parsing scripts (CSV/JSON/XML, commented, CLI-runnable)|`parse\_web\_feedback\_json.py` (+ any XML `ElementTree` script)|
|Report (1,200–2,000 words + tables)|`Final\_Report.docx`|
|README|`README.md` (this file)|

## Limitations (expand in the report)

* Small per-product review counts (often 1–2) make raw average ratings volatile even
with the `HAVING` threshold.
* The three feeds disagree on average score per SKU by varying amounts — cross-source
comparisons should be read as directional, not precise.
* Keyword-based issue tagging is a substring match against `issue\_keyword\_map` and will
miss paraphrased complaints not covered by the stored keyword list.

