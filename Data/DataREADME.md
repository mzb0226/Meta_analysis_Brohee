
# Data README

This repository contains the data and code used for the meta-analysis of diet effects on the gut microbiome of *Periplaneta americana*. The files are organized as follows:

## Raw Data

- **Raw_data_setmeta_analysis_p_americana_brohee.xlsx**  
  The complete, unprocessed data extracted from published studies (e.g., means, standard deviations, sample sizes for alpha diversity metrics; phylum-level abundance values). This file should be considered the primary source of empirical observations.

## Analysis Input

These files contain the processed data tables used directly as input to the R scripts that generated the figures and results.

- **AlphaDiversity_MetaAnalysis_Input.xlsx**  
  Hedges’ g effect size inputs for Shannon diversity (m1i, sd1i, n1i for control; m2i, sd2i, n2i for treatment) prepared from the raw data. This sheet is read by the alpha diversity R analysis script.

- **relativeabundance.xlsx**  
  Relative abundance values for Firmicutes and Bacteroidetes (counts or proportions for control and treatment groups, sample sizes) used to calculate log response ratios and standard errors in the phylum‐level meta-analyses.

## Code and Figures

- **R scripts** (in `scripts/` directory) that read the Analysis Input files, compute effect sizes, run meta-analyses (forest, orchard, funnel, leave-one-out), and export figures and tables.

- **Results** (in `results/` directory) containing the generated PDF figures (forest plots, orchard plots, funnel plots) and Excel summary tables.

## Usage

1. Install required R packages as specified in the R scripts (`metafor`, `dplyr`, `ggplot2`, `orchaRd`, etc.).
2. Place the Analysis Input files in the working directory or update file paths in the scripts.  
3. Run the R scripts to reproduce the figures and summary tables.  
4. Raw data file is provided for reference and verification but is not directly loaded by the scripts.

---

**Note:** If you wish to re-digitize figures or update raw measurements, use the `Raw_data_setmeta_analysis_p_americana_brohee.xlsx` as the starting point and re-run the data processing steps in the scripts.
