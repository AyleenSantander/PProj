# Natural Language Processing with Python

Text preprocessing and sentiment analysis on IMDB movie reviews. Two lexicon-based sentiment scorers (TextBlob and VADER) are used to label the corpus, then Naive Bayes and Linear SVM classifiers are trained on TF-IDF vectors and compared against each labelling scheme.

**Notebook:** `Assignment 13 NLP with Python.ipynb` (Google Colab)
**Course:** Willis College — Machine Learning with Python
**Author:** Ayleen Santander · August 2026

#Sentiment Distribution and Insights
The full dataset contains 50,000 reviews with extensive text content, labeled by sentiment: Positive, Neutral, and Negative. For this analysis, a random sample of 1,000 rows was selected as a representative subset. A cloned copy of the data was used with the sentiment label held out, so the exploratory analysis would not be biased by knowing the "correct" answer in advance.

\---

## Dataset

**IMDB Movie Reviews** (`IMDB\_Dataset.csv`) — first **1,000 rows** loaded via `nrows=1000`.

|Column|Description|
|-|-|
|`review`|Free-text movie review, contains HTML markup|
|`sentiment`|Ground-truth label (positive / negative) — **dropped at the start of the analysis**|

\---

## Tech stack

```
pandas · numpy · matplotlib · seaborn · re
nltk        — word\_tokenize, stopwords, PorterStemmer, WordNetLemmatizer,
              pos\_tag, wordnet, VADER (SentimentIntensityAnalyzer)
spacy       — en\_core\_web\_sm (tagger + lemmatizer only)
textblob    — polarity scoring
contractions — contraction expansion
scikit-learn — TfidfVectorizer, MultinomialNB, LinearSVC, train\_test\_split,
               classification\_report, confusion\_matrix
```

\---

## Part 1 — Text preprocessing

Three progressively more refined pipelines are built and compared.

### Pipeline 1: Baseline (NLTK, stemming)

Lowercase → `word\_tokenize` → remove NLTK English stopwords → `PorterStemmer`.

This version is deliberately naive and the output shows why: tokens like `<`, `br`, `/`, `>` survive because HTML is never stripped, and Porter stemming produces non-words (`littl`, `episod`, `wonder` from *wonderful*).

### Pipeline 2: Full clean + POS-aware lemmatization (NLTK)

`clean\_and\_lemmatize()` applies seven ordered steps:

1. Strip HTML tags with `re.sub(r'<.\*?>', ' ', review)`
2. Expand contractions (`don't` → `do not`)
3. Lowercase
4. Remove punctuation and digits, keeping `\[a-z\\s]` only
5. Tokenize
6. Remove stopwords
7. POS-tag, then lemmatize each token with its mapped WordNet tag

The POS mapping (`get\_wordnet\_pos`) is what makes this meaningfully better than the baseline — without it, `WordNetLemmatizer` defaults to noun and leaves verbs untouched. With it, *thought* → *think* and *filming* → *film*.

### Pipeline 3: spaCy equivalent

Same cleaning function, but lemmatization runs through `en\_core\_web\_sm` with `parser` and `ner` disabled and batched via `nlp.pipe(batch\_size=100)` rather than row-by-row `apply()` — a substantial speedup on larger corpora.

Both pipelines produce near-identical output, with minor divergences (NLTK returns *technique*, spaCy returns *filming technique*).

\---

## Part 2 — Sentiment analysis

### TextBlob polarity

`TextBlob(review).sentiment.polarity` returns a score in \[-1, +1], binned into Good / Bad.

|Category|Count|
|-|-|
|Good|734|
|Bad|264|

The polarity histogram is roughly normal, centred slightly above zero, ranging about -0.6 to +0.6 — few reviews are scored strongly either way.

### VADER compound score

`SentimentIntensityAnalyzer` run on the raw (uncleaned) text, since VADER uses punctuation, capitalization, and intensifiers as signal. Compound score thresholded at ±0.05.

|Category|Count|Share|
|-|-|-|
|good|625|62.5%|
|bad|371|37.1%|
|no answer|4|0.4%|

Average compound: **0.24** → overall corpus reads positive. Strongest positive review scores 0.9996; strongest negative, -0.9994.

VADER produces a noticeably more balanced split than TextBlob (37% negative vs 26%) and pushes far more reviews to the extremes of the range.

### Classifiers

`text\_lemmatized` → `TfidfVectorizer(max\_features=5000)` → Naive Bayes and `LinearSVC(random\_state=42)`, 80/20 split.

**Trained on TextBlob labels:**

|Model|Accuracy|Recall (Bad)|Recall (Good)|Macro F1|
|-|-|-|-|-|
|Naive Bayes|0.735|0.00|1.00|0.42|
|Linear SVM|**0.810**|0.43|0.95|0.71|

**Trained on VADER labels:**

|Model|Accuracy|Recall (bad)|Recall (good)|Macro F1|
|-|-|-|-|-|
|Naive Bayes|0.635|0.03|1.00|0.28|
|Linear SVM|**0.755**|0.58|0.86|0.49|

Supporting analysis includes confusion matrices, a misclassification table, and a disagreement table showing the 31 reviews where the two models diverge.

\---

## Findings

**Naive Bayes collapses to the majority class in both runs.** Its confusion matrices show it predicting "good" for every single test review under TextBlob labels (0 / 53 negatives caught) and all but two under VADER. The 0.735 and 0.635 accuracies are pure class-prior artefacts — the model learned nothing. This is what the `UndefinedMetricWarning` in the output is reporting.

**Linear SVM is the clear winner** on both label sets, and the gap is widest where it matters — negative-class recall of 0.43 and 0.58 versus effectively zero.

**SVM improves when trained on VADER labels** despite lower headline accuracy (0.755 vs 0.810). Negative recall rises from 0.43 to 0.58, because VADER's more balanced label distribution gives the classifier more negative examples to learn from. Another case where accuracy moves opposite to actual model quality.

**The two lexicons disagree substantially.** TextBlob calls 26% of reviews negative; VADER calls 37%. Both skew positive on a dataset that is close to balanced in reality.

\---

## Known issues and next steps

The most important one first:

* **The models are never evaluated against ground truth.** The `sentiment` column — the actual human labels — is dropped in the second cell, and every classifier is trained and scored against TextBlob or VADER output. So "SVM accuracy: 0.81" means *the SVM agrees with TextBlob 81% of the time*, not that it is 81% correct. Since TextBlob is itself a rough heuristic, the pipeline is measuring agreement with a weak baseline. **Keeping `sentiment` and scoring against it would turn this from a plausibility check into a real evaluation** — and would let you measure how accurate TextBlob and VADER actually are, which is the more interesting question.

Smaller items:

* **Dead code in the first TextBlob cell.** A three-way `conditions`/`labels` block is defined and then immediately overwritten by a two-way `pd.cut`, so the "No answer" category never materializes.
* **Neutral labels assigned by hardcoded row index** — `neutral\_indices = \[1, 2]` manually forces rows 1 and 2 to "NO answer" despite both having clearly positive polarity scores (0.11 and 0.35). This should be a threshold band (e.g. |polarity| < 0.05), not two chosen rows.
* **The "no answer" class has 1–4 samples**, which makes its precision undefined and drags the macro average down misleadingly. VADER's SVM macro F1 of 0.49 looks worse than TextBlob's 0.71 largely because of this empty third class. Either drop the class before splitting or report macro F1 over the two real classes.
* **No `stratify` in the train/test split**, despite the inline comment saying it keeps class balance — the argument isn't actually passed.
* **`sentiment\_counts` is referenced before assignment** in the evaluation cell; it works only if an earlier cell defined it.
* **Check the average-compound if/elif block** — "Overall Sentiment: No Answer" appears to sit outside the conditional, which would print it unconditionally.
* **Next step:** `MultinomialNB(class\_prior=...)` or `LinearSVC(class\_weight='balanced')` would directly address the majority-class collapse, and `ngram\_range=(1,2)` on the vectorizer typically adds several points on sentiment tasks by catching negations like "not good".

