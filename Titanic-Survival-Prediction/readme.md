# Titanic Survival Prediction Project

## Project Goal

The objective of this project is to create a *small yet performant model* that predicts the survival of passengers aboard the Titanic. Emphasis is placed on building an *efficient model* that balances predictive performance with model simplicity (i.e., using fewer features and simpler models where possible).


## Dataset

This dataset is an *augmented version* of the well-known Titanic dataset originally from [Data Science Dojo](https://github.com/datasciencedojo/datasets/blob/master/titanic.csv). It contains information about passengers aboard the Titanic, including demographics, family relationships, ticket and cabin details, and additional attributes designed to support modeling.

**Columns:**

| Column Name           | Description |
|-----------------------|-------------|
| PassengerId           | Unique identifier for each passenger. |
| Survived              | Survival status (0 = No, 1 = Yes). This is the target variable. |
| Pclass                | Passenger class (1 = 1st, 2 = 2nd, 3 = 3rd). |
| Name                  | Full name of the passenger. |
| Sex                   | Gender of the passenger. |
| Age                   | Age in years. |
| SibSp                 | Number of siblings or spouses aboard. |
| Parch                 | Number of parents or children aboard. |
| Ticket                | Ticket number. |
| Fare                  | Fare paid for the ticket. |
| Cabin                 | Cabin number. |
| Embarked              | Port of embarkation (C = Cherbourg, Q = Queenstown, S = Southampton). |
| name_length           | Number of characters in the passenger's name. |
| title_group           | Title extracted from the passenger's name (e.g., Mr, Mrs, Miss, Other). |
| family_size           | Total number of family members aboard (SibSp + Parch + 1). |
| is_alone              | Indicates if the passenger was traveling alone (1 = yes, 0 = no). |
| ticket_group_size     | Number of passengers sharing the same ticket. |
| fare_per_person       | Fare divided by the number of passengers on the same ticket. |
| age_fare_ratio        | Ratio of age to fare. |
| cabin_deck            | First character of the cabin (deck letter, e.g., A, B, C, ...). |
| cabin_room_number     | Numeric part of the cabin. |
| booking_reference     | Numeric hash generated from the ticket number. |
| service_id            | Unique numeric identifier assigned to each passenger. |
| cabin_score           | Numeric score associated with the cabin (custom-generated for this project). |
| name_word_count       | Number of words in the passenger's name. |

---

## Data Cleaning

The raw data underwent several cleaning and preprocessing steps to ensure quality and suitability for modelling:

*   **Dropped Columns**: The following columns were removed due to being arbitrary, having high missing values, or not adding predictive value:
    *   `PassengerId`, `Name`, `Ticket`, `name_length`, `booking_reference`, `service_id`, `name_word_count`, `title`, `title_group`, `cabin_deck`.
*   **Categorical Processing**:
    *   `Sex`: Mapped to binary values (0/1).
    *   `Embarked` and `Pclass`: Transformed using One-Hot Encoding.
*   **Multicollinearity Removal**: To reduce feature redundancy, the following correlated columns were dropped:
    *   `Fare`, `age_fare_ratio`, `SibSp`, `Parch`.
*   **Imputation**: Missing values in the `Age` column were imputed using the median age.
*   **Final Feature Set**: The models were trained on 13 engineered features, including `Survived` (target), `Pclass` indicators, `Sex`, `Age`, `family_size`, `is_alone`, `ticket_group_size`, `fare_per_person`, `cabin_score`, and `Embarked` indicators.

## Data Modelling

We experimented with multiple models to find the best predictor for survival.

### 1. Logistic Regression
*   **Baseline**: Established a baseline model.
*   **Hyperparameter Tuning**: Performed `GridSearchCV` to optimize `C`, `penalty`, and `solver`.
    *   **Best Parameters**: `{'C': 0.1, 'penalty': 'l2', 'solver': 'lbfgs'}`.
*   **Feature Reduction**: Features were selected based on coefficient magnitude (threshold > 0.05), reducing the feature set from 13 to 12.

### 2. Random Forest
*   **Baseline**: Achieved ~94% accuracy on training data with 100 estimators.
*   **Hyperparameter Tuning**: Optimized `n_estimators`, `max_depth`, `min_samples_split`, and `min_samples_leaf`.
    *   **Best Parameters**: `{'max_depth': None, 'min_samples_leaf': 2, 'min_samples_split': 5, 'n_estimators': 200}`.
*   **Feature Reduction**: Validated feature importance (threshold > 0.01) and reduced features to 12, confirming `Sex`, `fare_per_person`, and `Age` as top predictors.

### 3. K-Nearest Neighbors (KNN)
*   **Pipeline**: Implemented a pipeline with `StandardScaler` to normalize features.
*   **Tuning**: Optimized neighbor count and distance metrics.
    *   **Best Parameters**: `{'knn__metric': 'manhattan', 'knn__n_neighbors': 15, 'knn__weights': 'uniform'}`.

### 4. Transformer
*   **Architecture**: Custom `TransformerClassifier` neural network.
*   **Tuning**: Experimented with model depth and regularization.
    *   **Best Parameters**: `{'d_model': 32, 'dropout': 0.3, 'lr': 0.01, 'num_layers': 1}`.
*   **Feature Reduction**: Used Permutation Importance to select the top 5 most critical features: `Sex`, `Age`, `ticket_group_size`, `Pclass_3`, `Pclass_1`.

## Data Analysis

*   **Feature Importance**: Across linear and tree-based models, **Sex** and **Socio-economic status** (proxied by `fare_per_person` and `Pclass`) consistently emerged as the most significant predictors of survival.
*   **Model Performance**:
    *   Random Forest showed strong performance but required tuning to manage overfitting.
    *   Logistic Regression provided a robust and interpretable baseline.
    *   The Transformer model demonstrated that deep learning architectures could also be effective, especially when focused on key features.
    *   The tuned KNN model reported the highest accuracy on the test set.

## Conclusion

This project successfully explored multiple machine learning approaches to predict survival on the Titanic. By combining domain knowledge with rigorous data preprocessing and hyperparameter tuning, we identified key predictors and evaluated different modeling strategies. The results highlight the importance of feature engineering and model selection in achieving optimal performance on classification tasks.



