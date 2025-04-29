# Meta-Analysis Repository

Welcome to my repository!  
My name is Muhtarin Khayer Brohee, and I am a Ph.D. student in the Department of Biological Sciences at Auburn University.

This repository was created as part of my class (FISH-7350) project and manuscript titled:  
**"The Influence of Diet on the Gut Microbiome of *Periplaneta americana* (American Cockroach): A Meta-Analysis."**

## Project Overview

This meta-analysis systematically evaluates how dietary interventions affect the gut microbiota of *Periplaneta americana*, focusing on:
- Changes in alpha diversity (Shannon Index)
- Phylum-level shifts in Firmicutes and Bacteroidetes proportions
- The Firmicutes:Bacteroidetes (F:B) ratio

Effect sizes were calculated using Hedges' g for alpha diversity and log response ratios (log RR) for relative abundance data. A random-effects meta-analysis model was applied using the **`metafor`** package in R, with heterogeneity assessments (I², tau², Q-statistic) performed following REML estimation. The analysis adhered to PRISMA guidelines for systematic reviews and meta-analyses.

## Repository Contents

- `Data/` – Extracted raw data files
- `Scripts/` – R scripts for:
  - Effect size calculations
  - Random-effects meta-analysis
  - Forest plots, funnel plots, and leave-one-out sensitivity analyses
- `Figures/` – 
  - Forest plots for alpha diversity and taxonomic outcomes
  - Funnel plots to assess publication bias
  - Leave-one-out (LOO) plots for sensitivity analysis
- `Supplement/` – Supplementary figures and tables
- `EndNote_Library/` – Reference library used for citations

## Software and Packages

All analyses were performed in **R version 4.x.x**, using the following packages:
- `metafor`
- `readxl`
- `dplyr`
- `ggplot2`

## Citation
If you use this github project in your research, please cite it as:
Muhtarin Khayer Brohee. (2025). mzb0226/Meta_analysis_Brohee: v1.0.0 – The Influence of Diet on the Gut Microbiome of *Periplaneta americana* (American Cockroach): A Meta-Analysis (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.15306932

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15306932.svg)](https://doi.org/10.5281/zenodo.15306932)

---

