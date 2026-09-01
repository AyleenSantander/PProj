# Time Series Analysis

Three forecasting techniques applied to daily Delhi climate data: 3-period moving average, simple exponential smoothing, and SARIMA.

**Notebook:** `Assignment 9 Time Series Analysis.ipynb` (Google Colab)
**Course:** Willis College — Data Analytics
**Author:** Ayleen Santander · August 2026

\---

## Dataset

`dataset.csv` — daily weather observations, parsed with `date` as a `DatetimeIndex`.

|Item|Value|
|-|-|
|Rows|114|
|Range|2017-01-01 → 2017-04-24 (\~3.5 months)|
|Frequency|Daily|
|Missing values|None|
|Duplicates|None|

|Column|Mean|Min|Max|
|-|-|-|-|
|`mean\_temp`|21.71|11.00|34.50|
|`humidity`|56.26|17.75|95.83|
|`wind\_speed`|8.14|1.39|19.31|
|`mean\_pressure`|1004.04|**59.00**|1022.81|

Columns are renamed from `meantemp` / `meanpressure` to snake\_case.

\---

## Tech stack

```
pandas · matplotlib
statsmodels — SimpleExpSmoothing, SARIMAX
```

\---

## Workflow

### Part 1 — Data exploration

Structure check (`.info()`, `.shape`, `.dtypes`), null and duplicate counts, descriptive statistics, then three paired line plots: temperature vs wind speed, pressure vs humidity, and temperature vs humidity.

The temperature/humidity plot is the informative one: temperature climbs steadily from \~15°C in January to \~34°C by late April while humidity falls from \~85% to \~27%. The two series cross in early April. This is the seasonal transition into Delhi's pre-monsoon summer.

### Part 2 — 3-period moving average

`rolling(window=3).mean()` computed for all four variables in turn, each plotted against its original series. The smoothed line tracks the original closely for wind speed, where the underlying data is noisiest.

### Part 3 — Simple exponential smoothing

`SimpleExpSmoothing(humidity).fit(smoothing\_level=0.3, optimized=False)` — α fixed at 0.3, then a 20-step forecast.

The fitted line tracks the humidity decline well. The forecast is **flat at 30.88** for all 20 days, because SES has no trend component: it projects the last smoothed level forward indefinitely.

### Part 4 — SARIMA

`SARIMAX(humidity, order=(1,1,1), seasonal\_order=(1,1,1,7))`, 20-step forecast.

Unlike SES, this produces a *declining* forecast — from 25.0 on 2017-04-25 down to 17.2 by 2017-05-14, with visible short-cycle wobble. The differencing terms let the model carry the downward trend forward, which is the right behaviour for a series in sustained decline.

\---

## Findings

The three methods differ in what they can express, and the humidity series makes that visible:

* **Moving average** smooths but doesn't forecast — it has no value beyond the last observation.
* **SES** produces a flat line, which is structurally wrong for a series with a clear downward trend. Its 30.88 forecast sits above where the actual data was already heading.
* **SARIMA** is the only one of the three that extends the trend, projecting humidity continuing to fall into May. That matches the physical reality of Delhi heading into peak dry season.

\---

## Known issues and next steps

Two of these affect the results directly:

* **`mean\_pressure` has a corrupt first value: 59.00 on 2017-01-01.** Sea-level pressure is physically bounded around 950–1050 hPa; 59 is a data-entry error. Its effects are visible throughout: the descriptive `std` is 89.47 when the real spread is closer to 7, the 3-day moving average returns a meaningless 698.54 on 2017-01-03, and both pressure charts are rendered unreadable because the y-axis stretches from 0 to 1000 to accommodate it. Dropping or interpolating that single row fixes all three.
* **`3\_Moving\_Average` is a single column, overwritten four times.** Each variable's moving average replaces the previous one, so only the last (pressure) survives. The evidence is in the SES output cell: it prints `humidity` = 85.87 beside `3\_Moving\_Average` = 3.22, which is the *wind speed* average. The same mismatch shows in the humidity and temperature MA charts, where the plotted orange line sits far below the printed values — those cells rendered against a stale column. Use distinct names (`humidity\_ma3`, `temp\_ma3`, …) so each survives.

Smaller items:

* **No frequency on the index** — this is what triggers the repeated `ValueWarning: No frequency information was provided`. `ASS9 = ASS9.asfreq('D')` after loading resolves it and lets statsmodels handle dates properly.
* **Paired plots use a shared y-axis across incompatible scales.** Pressure (\~1000) and humidity (\~50) on one axis makes humidity a flat line at the bottom. Use `twinx()` or separate subplots.
* **No error metrics and no holdout.** Without a train/test split and MAE or RMSE per method, the comparison is visual only. Holding out the last 20 days and scoring all three would make the SARIMA-beats-SES claim quantitative.
* **`seasonal\_order=(1,1,1,7)` assumes a weekly cycle**, which weather does not have — humidity doesn't care what day of the week it is. The model may be fitting noise. Worth testing against a non-seasonal `ARIMA(1,1,1)` to see whether the seasonal terms earn their place.
* **Holt's linear trend method** (`Holt` in statsmodels) is the natural middle step between SES and SARIMA: it adds a trend component while staying simple, and would forecast a decline rather than a flat line.
* **α = 0.3 is chosen arbitrarily.** Setting `optimized=True` lets statsmodels fit α by maximum likelihood; comparing the two is a useful sanity check.
* `SimpleExpSmoothing` is imported twice from two different modules; keep the `statsmodels.tsa.holtwinters` import.
* **Caveat on interpretation:** 114 days covers one seasonal transition, not a full cycle. The strong "trend" in both temperature and humidity is a seasonal move, and neither should be extrapolated far beyond May.

