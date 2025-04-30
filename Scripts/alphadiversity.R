# ===============================
# Alpha Diversity Meta‐Analysis
# ===============================

# 1) Install & load packages (run once)
if (!require("metafor")) install.packages("metafor")
if (!require("readxl"))  install.packages("readxl")
if (!require("dplyr"))   install.packages("dplyr")
if (!require("ggplot2")) install.packages("ggplot2")

library(metafor)
library(readxl)
library(dplyr)
library(ggplot2)

# 2) File paths
alpha_fn   <- "AlphaDiversity_MetaAnalysis_Input.xlsx"
output_dir <- "results"

# Create results directory if it doesn't exist
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# 3) Read & prepare data
dat <- read_excel(alpha_fn) %>%
  mutate(across(c(m1i, sd1i, n1i, m2i, sd2i, n2i), as.numeric))

# 4) Compute effect sizes (Hedges' g)
es <- escalc(
  measure = "SMDH",
  m1i     = m1i, sd1i = sd1i, n1i = n1i,
  m2i     = m2i, sd2i = sd2i, n2i = n2i,
  data    = dat
)

# 5) Save the dataset with effect sizes & variances
write.csv(es,
          file = file.path(output_dir, "AlphaDiversity_effect_sizes.csv"),
          row.names = FALSE)

# 6) Fit random-effects meta-analysis
mod <- rma.uni(yi, vi, data = es, method = "REML")
print(summary(mod))

# 7) Forest plot → PDF
pdf(file.path(output_dir, "AlphaDiversity_forest.pdf"),
    width = 7, height = 5)
forest(mod,
       slab  = paste(es$Study_ID),
       xlab  = "Hedges' g",
       main  = "Forest Plot: Alpha Diversity")
dev.off()

# 8) Funnel plot → PDF + Egger’s test
pdf(file.path(output_dir, "AlphaDiversity_funnel.pdf"),
    width = 6, height = 5)
funnel(mod,
       xlab = "Hedges' g",
       main = "Funnel Plot: Alpha Diversity")
dev.off()

egger <- regtest(mod, model = "lm")
cat("\nEgger’s test for funnel asymmetry:\n")
print(egger)


# 9) Leave‐one‐out sensitivity analysis
loo_df <- tibble(
  Study_Excluded = character(),
  Estimate       = numeric(),
  CI_lb          = numeric(),
  CI_ub          = numeric()
)

for (stud in unique(es$Study_ID)) {
  es_sub  <- filter(es, Study_ID != stud)
  sub_mod <- rma.uni(yi, vi, data = es_sub, method = "REML")
  loo_df  <- loo_df %>% add_row(
    Study_Excluded = stud,
    Estimate       = sub_mod$b,
    CI_lb          = sub_mod$ci.lb,
    CI_ub          = sub_mod$ci.ub
  )
}

# Save LOO results
write.csv(loo_df,
          file = file.path(output_dir, "AlphaDiversity_results.csv"),
          row.names = FALSE)

# 10) LOO plot with overall estimate → PDF
overall_est <- as.numeric(mod$b)

p_loo <- ggplot(loo_df, aes(x = reorder(Study_Excluded, Estimate), y = Estimate)) +
  geom_errorbar(aes(ymin = CI_lb, ymax = CI_ub), width = 0.2) +
  geom_point(size = 2) +
  geom_hline(yintercept = overall_est,
             linetype    = "dashed",
             color       = "red") +
  coord_flip() +
  theme_minimal(base_size = 12) +
  labs(
    title = "LOO Sensitivity:Alpha Diversity",
    x     = "Dropped Study",
    y     = "Hedges' g"
  )

ggsave(filename = file.path(output_dir, "AlphaDiversity_LOO_plot.pdf"),
       plot     = p_loo,
       width    = 7, height = 5)


# 11) Orchard-style plot → PDF
# ==========================================
# Alpha Diversity Meta-Analysis Orchard Plot
# ==========================================

# 1) Install & load dependencies
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("metafor", quietly = TRUE)) install.packages("metafor")

# Install the latest version of orchaRd
if (!requireNamespace("orchaRd", quietly = TRUE)) {
  devtools::install_github("daniel1noble/orchaRd")
}

# Load libraries
library(readxl)
library(dplyr)
library(metafor)
library(orchaRd)
library(ggplot2)
# 2) File paths
input_xlsx <- "AlphaDiversity_MetaAnalysis_Input.xlsx"
#output_pdf <- "C:/Users/muhta/OneDrive/Desktop/Meta analysis/paper/results/AlphaDiversity_OrchardPlot.pdf"

# 3) Read and prepare data
dat <- read_excel(input_xlsx) %>%
  mutate(across(c(m1i, sd1i, n1i, m2i, sd2i, n2i), as.numeric))

# 4) Compute Hedges' g (yi) and variance (vi)
es <- escalc(
  measure = "SMDH",
  m1i = m1i, sd1i = sd1i, n1i = n1i,
  m2i = m2i, sd2i = sd2i, n2i = n2i,
  data = dat
)
es$Study_ID <- dat$Study_ID   # keep Study_ID for grouping
es$N <- es$n1i + es$n2i      # calculate total sample size for each study

# 5) Fit random-effects meta-analysis
mod <- rma(yi, vi, data = es, method = "REML")

# 6) Generate & save the orchard plot
pdf(output_pdf, width = 7, height = 5)

# ==========================================
# Alpha Diversity Meta-Analysis Orchard Plot
# ==========================================

# [Previous code for loading packages and preparing data remains the same until the plotting section]

# 6) Generate & save the orchard plot with skyblue points
pdf(output_pdf, width = 7, height = 5)

# First create the basic plot and store it
orchard_plot(
  object = mod,
  mod = "1",                  # intercept only model
  group = "Study_ID",         # grouping variable
  xlab = "Hedges' g (Alpha Diversity)",
  # transparency of points
  angle = 90,    
  g= FALSE,
  # angle of y-axis labels
  # size of prediction intervals
  transfm = "none")        # no transformation

dev.off()

