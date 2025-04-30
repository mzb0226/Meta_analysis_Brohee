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

- `Data/` –  Raw and processed data files
- `Scripts/` – R scripts for:
  - Effect size calculations
  - Random-effects meta-analysis
  - Forest plots, funnel plots, and leave-one-out sensitivity analyses
- `Plots/` – Publication-ready figure files (PNG, PDF)
- `Results/` – Excel summary tables and PDF outputs
  - Forest plots for alpha diversity and taxonomic outcomes
  - Funnel plots to assess publication bias
  - Leave-one-out (LOO) plots for sensitivity analysis
- `Supplementary/` – Supplementary figures (S1–S12) and tables (S1–S2)
- `Reference/` – EndNote library files for citation management

## Software and Environment

- **R version:** 4.4.2  
- **Key R packages:**  
  - metafor (v4.8-0)  
  - readxl (v1.4.3)  
  - dplyr (v1.1.4)  
  - ggplot2 (v3.4.4)  
  - writexl (v1.4.2)  
  - orchaRd (v2.0)  
  - devtools (v2.4.5)  

## Acknowledgments

The author gratefully acknowledges the support and guidance of **Dr. Alan Wilson** for providing essential materials and mentorship throughout this project. Special thanks to Auburn University librarians **Adelia Grabowsky** and **Patricia Hartmen** for their expertise in literature searching and data acquisition. Additional gratitude goes to all classmates for their constructive feedback and discussions. Finally, thanks to ChatGPT for assistance with script debugging and optimization.

## Citation
If you use this github project/script in your research, please cite it as:
Muhtarin Khayer Brohee. (2025). mzb0226/Meta_analysis_Brohee: v1.0.0 – The Influence of Diet on the Gut Microbiome of *Periplaneta americana* (American Cockroach): A Meta-Analysis (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.15306932

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15306932.svg)](https://doi.org/10.5281/zenodo.15306932)

---

