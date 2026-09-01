# Supervised Machine Learning with Python

Three classification algorithms trained on the Titanic dataset, compared on accuracy and per-class recall to show why accuracy alone is a misleading metric under class imbalance.

**Notebook:** Supervised ML with Python.ipynb` (Google Colab)
**Course:** Willis College — Machine Learning with Python
**Author:** Ayleen Santander · August 2026

\---

## Dataset

**Titanic** (`titanic (4).csv`) — 891 passengers, 12 columns.

Missing values before cleaning:

|Column|Missing|
|-|-|
|Age|177|
|Cabin|687|
|Embarked|2|

\---

## Tech stack

```
pandas · numpy
scikit-learn — train\_test\_split, StandardScaler, LabelEncoder,
               LogisticRegression, RandomForestClassifier, SVC,
               accuracy\_score, classification\_report
```

\---

## Data preparation

1. **Age** — fill nulls with the rounded column mean, cast to integer.
2. **Embarked** — fill nulls with the mode.
3. **Ticket** — regex-extract the trailing numeric portion, coerce to numeric, fill failures with 0.
4. **Cabin** — take the first character as the deck letter (A, B, C…), fill missing with `'Unknown'`.
5. **Name** — strip parenthetical text (cosmetic only).
6. **Encoding** — `LabelEncoder` on `Sex` (female=0, male=1), `Embarked` (C=0, Q=1, S=2), and `Cabin` (deck letters → integers).
7. **Scaling** — `StandardScaler` fitted on the training split, applied to both splits.

\---

## Modelling setup

|Item|Value|
|-|-|
|Features (`X`)|`Age`, `Fare`, `Cabin`|
|Target (`y`)|`Sex`|
|Split|80 / 20, `random\_state=0`|
|Test set|179 samples — 67 female (class 0), 112 male (class 1)|
|Models|Logistic Regression, Random Forest, SVM (RBF) — all defaults|

All three models are trained in a single loop and scored with `accuracy\_score` plus a full `classification\_report`.

\---

## Results

|Model|Accuracy|Recall (female)|Recall (male)|Macro F1|
|-|-|-|-|-|
|Logistic Regression|0.66|0.18|0.96|0.53|
|Random Forest|0.65|0.54|0.71|**0.63**|
|SVM|0.66|0.21|0.93|0.54|

\---

## Analysis

The three models look nearly identical on accuracy (65–66%), but the per-class recall tells a different story.

**Logistic Regression and SVM are effectively guessing "male."** They catch 93–96% of actual males and only 18–21% of actual females. Their 0.66 accuracy is inflated by the majority class (112 of 179 test samples), not earned by discriminating between the classes. Macro F1 of 0.53–0.54 exposes this — barely above what you'd get from a constant prediction.

**Random Forest is the only balanced model.** Recalls of 0.54 and 0.71 are far more even, and its macro F1 of 0.63 is the highest of the three despite it having the *lowest* raw accuracy. It's not defaulting to the majority class the way the other two are.

**The wider conclusion:** Age, Fare, and Cabin are weak predictors of Sex. No model gets meaningfully above the majority-class baseline, which is the real takeaway — the comparison demonstrates the metric lesson rather than producing a useful classifier.

\---

## Known issues and next steps

Worth addressing before this goes in a portfolio:

* **The target choice is unusual.** Predicting `Sex` from `Age`, `Fare`, and `Cabin` has no real-world use, and the weak results are the expected outcome. If the assignment didn't mandate this target, `Survived` is the standard framing and would produce a model with genuine signal — plus `Sex` becomes the strongest predictor rather than the thing being predicted.
* **The majority-class baseline isn't stated.** Always predicting "male" scores 112/179 = **0.626**. Every model beats it by 2–3 points at most, which is the sharpest way to make the argument the analysis is already making.
* **`Cabin` is label-encoded as if ordinal.** Deck A→0, B→1, C→2 implies deck C is "twice" deck B to a distance-based model like SVM. One-hot encoding is the correct treatment for nominal categories. Note also that `'Unknown'` covers 687 of 891 rows, so the column is mostly a single value.
* **No `random\_state` on `RandomForestClassifier`**, so its numbers change on every run and aren't reproducible.
* **Filling 177 missing ages with the mean** compresses variance and creates a spike at \~30. Median is more robust, or predict age from `Pclass` and title extracted from `Name`.
* **`Ticket` and `Name` are cleaned but never used** as features — dead code in the pipeline.
* **No cross-validation.** A single 80/20 split on 891 rows makes small accuracy differences hard to trust; `cross\_val\_score` with 5 folds would show whether the Random Forest gap is real.
* **Next step:** `class\_weight='balanced'` on Logistic Regression and SVM would directly test the imbalance hypothesis. If their female recall jumps while accuracy drops, that confirms they were exploiting the class distribution rather than learning a signal.

