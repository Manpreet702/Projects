This project compares different fine-tuning methods for Food101 image classification using ResNet18 and EfficientNetV2-S. We test the models on the clean test set and the transformed test splits.

## Group 1 Members:
- Yihang Wang
- Manpreet Singh
- Anita Zeng

## Methods
- Linear probing
- LoRA
- BatchNorm tuning
- TSA-style adapter tuning
- One improved model with stronger augmentation and weight decay

## Files
- `Project586.ipynb` — main notebook
- `README.md` — project notes

## Data
The dataset is not included in this repository.
Expected test split folders:
- `clean`
- `blur_little`
- `blur_medium`
- `downsampled`
- `masked`
- `noise_rotation`

## Run
1. Open the notebook
2. Check the dataset paths
3. Install the required packages
4. Run all cells in order

## Output
The notebook produces:
- clean test results
- results for each transformed split
- summary tables
- plots
- Grad-CAM figures

## Note
- Full fine-tuning is optional and not included here
- Test sets are only used for evaluation
