#Data extraction
#Load shinydigitise
devtools::install_github("EIvimeyCook/ShinyDigitise", force = TRUE)
install.packages("promises")
df<-shinyDigitise("C:/Users/muhta/OneDrive/Desktop/Meta analysis/paper/figure")
shinyDigitise::shinyDigitise()

# === Load Required Packages ===
setwd("C:/Users/muhta/Downloads")
# === Load Data ===
data <- read_excel("AlphaDiversity_MetaAnalysis_Input.xlsx")

# === Load Required Packages ===
library(metafor)
library(readxl)
library(dplyr)
library(ggplot2)

# === Set Working Directory ===
setwd("C:/Users/muhta/Downloads")  # adjust if needed

# === Load Dataset ===
data <- read_excel("MetaAnalysis_Shannon_ByPaper.xlsx")

# === Ensure Numeric Columns Are Properly Set ===
data <- data %>%
  mutate(across(c(m1i, sd1i, n1i, m2i, sd2i, n2i), as.numeric))

# === Calculate Effect Sizes (Hedges' g) ===
res <- escalc(measure = "SMDH",
              m1i = m1i, sd1i = sd1i, n1i = n1i,
              m2i = m2i, sd2i = sd2i, n2i = n2i,
              data = data)

# === Random-Effects Model (using Paper as grouping factor) ===
model <- rma(yi, vi, data = res, random = ~1 | Paper, method = "REML")

# === Save Forest Plot ===
pdf("forest_alpha_diversity.pdf", width = 7, height = 5)
forest(model,
       slab = paste(res$Paper),
       xlab = "Effect Size (Hedges' g)",
       main = "Meta-Analysis of Alpha Diversity")
dev.off()

# === Save Funnel Plot ===
pdf("funnel_alpha_diversity.pdf", width = 6, height = 5)
funnel(model,
       xlab = "Effect Size (Hedges' g)",
       main = "Funnel Plot - Alpha Diversity")
dev.off()

# === Leave-One-Paper-Out (LOPO) Sensitivity Analysis ===
unique_papers <- unique(res$Paper)
lopo_results <- data.frame()

for (paper in unique_papers) {
  res_subset <- res %>% filter(Paper != paper)
  model_lopo <- rma(yi, vi, data = res_subset, method = "REML")
  lopo_results <- rbind(lopo_results, data.frame(
    Paper_Excluded = paper,
    Estimate = model_lopo$b,
    CI_lb = model_lopo$ci.lb,
    CI_ub = model_lopo$ci.ub
  ))
}

# === Save LOPO Plot ===
pdf("leave_one_out_alpha_diversity.pdf", width = 8, height = 5)
ggplot(lopo_results, aes(x = Paper_Excluded, y = Estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = CI_lb, ymax = CI_ub), width = 0.2) +
  theme_minimal() +
  labs(title = "Leave-One-Paper-Out Sensitivity Analysis",
       x = "Study Excluded",
       y = "Pooled Effect Size (Hedges' g)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()
