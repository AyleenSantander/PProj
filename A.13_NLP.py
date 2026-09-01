# Assignment 13: Natural Language Processing with Python
# Name Ayleen Santander

#Part 1: Text Preprocessing Exercise:
# 1. Choose a text dataset of your choice (e.g., movie reviews, news articles, tweets) and perform text preprocessing using Python. You may use the IMDB dataset attached at the bottom of this page.
# 2. Implement tokenization, remove stopwords, and perform either stemming or lemmatization.
# 3. Document each step of the preprocessing process and provide code snippets along with explanations.
# 4. Discuss any challenges encountered during preprocessing and how you addressed them.


#Import Libraries and Necessary Resources
import pandas as pd
import numpy as np
import nltk
import re
import matplotlib.pyplot as plt
import contractions
import spacy
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from nltk.stem import WordNetLemmatizer
import matplotlib.pyplot as plt
from textblob import TextBlob
from nltk import pos_tag, word_tokenize
from nltk.corpus import wordnet
from textblob import TextBlob

# Download necessary NLTK resources
nltk.download('punkt')
nltk.download('punkt_tab')
nltk.download('averaged_perceptron_tagger')
nltk.download('averaged_perceptron_tagger_eng')
nltk.download('wordnet')
nltk.download('omw-1.4')
nltk.download ('stopwords')

# Load the dataset/ # Load the dataset into Python using pandas
IMDB = pd.read_csv('IMDB_Dataset.csv', nrows=1000)
IMDB.to_html('IMDB_Dataset.html, index = False')
print(IMDB.head())

# clone data, just considerate review column for this analysis
IMDB_clone = IMDB.copy()
IMDB_clone= IMDB_clone.drop(columns=['sentiment'])
print(IMDB_clone.head())

print("Original IMDB columns:", IMDB.columns.tolist())
print("IMDB_clone columns:", IMDB_clone.columns.tolist())

# Convert text to lowercase.
IMDB_clone['review'] = IMDB_clone['review'].str.lower()

#Tokenize the text into words
IMDB_clone['tokens'] = IMDB_clone['review'].apply(word_tokenize)

#Remove stopwords to filter out common words with little meaning.
stop_words = set(stopwords.words('english'))
IMDB_clone['filtered_tokens'] = IMDB_clone['tokens'].apply(lambda x: [word for word in x if word not in stop_words])

#Perform stemming to reduce words to their base forms
stemmer = PorterStemmer()
IMDB_clone['stemmed_tokens'] = IMDB_clone['filtered_tokens'].apply(lambda x: [stemmer.stem(word) for word in x])
(IMDB_clone.head())

#Perform lemmatizer to reduce words to their base forms
stop_words = set(stopwords.words('english'))
lemmatizer = WordNetLemmatizer()
def get_wordnet_pos(treebank_tag):
    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return wordnet.NOUN

def clean_and_lemmatize(review):
    # 1. Remove HTML tags first (<br />, <p>, etc.)
    review = re.sub(r'<.*?>', ' ', review)
    # 2. Expand contractions
    review = contractions.fix(review)
    # 3. Lowercase
    review = review.lower()
    # 4. Remove punctuation/numbers, keep only letters and spaces
    review = re.sub(r'[^a-z\s]', '', review)
    # 5. Tokenize
    tokens = word_tokenize(review)
    # 6. Remove stopwords
    tokens = [t for t in tokens if t not in stop_words]
    # 7. POS tag + lemmatize
    pos_tags = pos_tag(tokens)
    lemmatized = [lemmatizer.lemmatize(word, get_wordnet_pos(tag)) for word, tag in pos_tags]
    return lemmatized

# Apply pipeline
IMDB_clone['filtered_tokens'] = IMDB_clone['review'].apply(clean_and_lemmatize)
IMDB_clone['text_lemmatized'] = IMDB_clone['filtered_tokens'].apply(lambda tokens: ' '.join(tokens))

IMDB_clone[['review', 'filtered_tokens', 'text_lemmatized']].head(10)

# Alternative for lemmatize with Spacy
nlp = spacy.load('en_core_web_sm')

# Expand stopwords with modal verbs and common leftovers
stop_words = set(stopwords.words('english'))
stop_words.update(['would', 'could', 'might', 'shall', 'may', 'must'])

def clean_and_lemmatize_spacy(review):
    review = contractions.fix(review)
    review = review.lower()
    review = re.sub(r'[^a-z\s]', '', review)
    doc = nlp(review)
    tokens = [token.lemma_ for token in doc if token.text not in stop_words and not token.is_space]
    return tokens
IMDB_clone['filtered_tokens'] = IMDB_clone['review'].apply(clean_and_lemmatize_spacy)
IMDB_clone['text_lemmatized'] = IMDB_clone['filtered_tokens'].apply(lambda tokens: ' '.join(tokens))

IMDB_clone[['review', 'filtered_tokens', 'text_lemmatized']].head(10)