# Unsupervised Machine Learning with Python

Four clustering algorithms applied to the UCI Wine dataset to test how well each recovers the true cultivar structure without ever seeing the class labels.

**Notebook:** `Assignment 12 Unsupervised ML with Python.ipynb` (Google Colab)
**Course:** Willis College — Machine Learning with Python
**Author:** Ayleen Santander · August 2026

\---

## Dataset

**UCI Wine** (`sklearn.datasets.load\_wine`)

|Item|Value|
|-|-|
|Samples|178|
|Features|13 continuous chemical measurements|
|Target|3 cultivars (class 0 = 59, class 1 = 71, class 2 = 48)|
|Missing values|None|

Features include alcohol, malic acid, ash, alcalinity of ash, magnesium, total phenols, flavanoids, nonflavanoid phenols, proanthocyanins, colour intensity, hue, OD280/OD315, and proline.

The class labels are held out of the clustering itself and used only afterward to score how well each algorithm did.

\---

## Tech stack

```
pandas · numpy · matplotlib · seaborn · plotly
scikit-learn (KMeans, DBSCAN, HDBSCAN, StandardScaler, NearestNeighbors, adjusted\_rand\_score)
scipy (linkage, dendrogram, fcluster)
hdbscan
```

\---

## Workflow

1. **Data selection** — load the Wine dataset into a feature frame `X` and a target series `y`.
2. **EDA** — inspect structure and feature distributions.
3. **Scaling** — `StandardScaler` applied before the distance-based methods, since the raw features span wildly different magnitudes (proline is in the hundreds, hue is around 1).
4. **Clustering** — four algorithms, each with a parameter-selection step.
5. **Validation** — crosstabs against the true classes, heatmaps, and Adjusted Rand Index.

\---

## Algorithms and results

### 1\. K-Means

Elbow method across k = 1–10 on inertia (WCSS). The bend appears at **k = 2**, though the dataset is known to contain 3 cultivars, so both were fitted.

|k|Result|
|-|-|
|2|123 / 55 split|
|3|Fitted to match the known cultivar count|

The notebook's own read: the elbow suggests 2, but the 3-cluster solution separates the data more sensibly given what we know about the source.

### 2\. Hierarchical clustering (Ward linkage) — best performer

Dendrogram on scaled data with a cut line at distance 15, yielding 3 clusters. Cut two ways (`maxclust=3` and `criterion='distance', t=15`) for comparison.

Crosstab against true classes:

|True class|Cluster 1|Cluster 2|Cluster 3|
|-|-|-|-|
|0 (n=59)|**50**|0|9|
|1 (n=71)|1|6|**64**|
|2 (n=48)|0|**48**|0|

**Adjusted Rand Index = 0.742** — strong agreement, well above chance. Class 2 is recovered perfectly with zero leakage.

### 3\. DBSCAN — failed on this dataset

`eps` chosen from a k-distance plot (5th nearest neighbour), with the bend around 2.8–3.0 → **eps = 2.9, min\_samples = 5**.

Result: **one cluster of 164 points plus 14 noise points.** DBSCAN lumped all three cultivars together.

This is the instructive failure in the assignment. DBSCAN assumes clusters are separated by regions of low density. The wine cultivars overlap enough chemically that no single global density threshold finds a gap between them.

### 4\. HDBSCAN

`min\_cluster\_size = 5, min\_samples = 5` on scaled data. The condensed tree shows **3 stable clusters** — matching the true cultivar count — but at the cost of heavy noise labelling.

|Cluster|Size|Composition|
|-|-|-|
|0|46|100% class 0 — pure|
|1|32|31 from class 1 — pure|
|2|29|28 from class 2, 1 from class 1 — nearly pure|
|Noise (−1)|72|40% of the dataset discarded|

A sweep over `min\_samples` confirmed the structure is stable:

|min\_samples|Clusters|Noise points|
|-|-|-|
|3|3|54|
|5|3|72|
|8|3|79|
|10|3|85|

Lowering `min\_samples` to 3 recovered 18 points from noise while keeping cluster purity intact.

\---

## Conclusion

|Algorithm|Clusters found|Verdict|
|-|-|-|
|K-Means|2 (elbow) / 3 (forced)|Strong|
|Hierarchical (Ward)|3|**Best — ARI 0.742**|
|DBSCAN|1 + noise|Failed|
|HDBSCAN|3|Correct structure, 40% discarded as noise|

Centroid- and linkage-based methods handled overlapping chemical profiles well because they only need relative distances. Density-based methods struggled: DBSCAN found no density gap at all, and HDBSCAN found the right number of clusters but only by refusing to commit on nearly half the points. On overlapping continuous data, density is the wrong assumption.

\---

## Known issues and next steps

Worth cleaning up before this goes in a portfolio:

* **K-Means is fitted on unscaled `X`** while every other algorithm uses `X\_scaled`. Proline and magnesium dominate the distance calculation as a result, which is very likely why the elbow reads k = 2 instead of 3. Re-running K-Means on `X\_scaled` should be the first fix.
* **`X\['Cluster'] = ...` mutates the feature DataFrame in place.** Every K-Means fit after that line silently includes the previous cluster label as a 14th input feature. Assign cluster labels to a copy, or to a separate results frame.
* **Plotting bug in the k=3 scatter** — `X\_array\[y\_kmeans == 2, 2]` uses column index 2 (ash) on the y-axis while the other two series use index 1 (malic acid), so cluster 3 is plotted against a different variable than clusters 1 and 2.
* **Two different HDBSCAN implementations** are used — `sklearn.cluster.HDBSCAN` and the standalone `hdbscan` package — producing different noise counts (63 vs 72) for the same parameters. Pick one.
* **ARI is only computed for hierarchical clustering.** Scoring all four on the same metric would make the comparison table quantitative rather than narrative.
* `load\_iris` is imported but never used.
* Small typo in the discussion: "least noise (53 vs 72)" should read 54, matching the sweep output.
* **Natural extension:** PCA to two components before clustering, so the scatter plots show real cluster separation instead of an arbitrary alcohol/malic-acid slice of 13-dimensional space.

