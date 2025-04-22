#Data extraction
#Load shinydigitise
devtools::install_github("EIvimeyCook/ShinyDigitise", force = TRUE)
install.packages("promises")
df<-shinyDigitise("C:/Users/muhta/OneDrive/Desktop/Meta analysis/paper/figure")
shinyDigitise::shinyDigitise()

# === Load Required Packages ===
install.packages("metafor")     # Only if not already installed
library(metafor)
library(readxl)

# === Load Data ===
data <- read_excel("AlphaDiversity_MetaAnalysis_Input.xlsx")

# === Convert Columns to Numeric ===
data$m1i <- as.numeric(data$m1i)       # Treatment mean
data$sd1i <- as.numeric(data$sd1i)     # Treatment SD
data$n1i <- as.numeric(data$n1i)       # Treatment N
data$m2i <- as.numeric(data$m2i)       # Control mean
data$sd2i <- as.numeric(data$sd2i)     # Control SD
data$n2i <- as.numeric(data$n2i)       # Control N

# === Calculate Effect Sizes (Hedges' g) ===
res <- escalc(measure = "SMDH", 
              m1i = m1i, sd1i = sd1i, n1i = n1i,
              m2i = m2i, sd2i = sd2i, n2i = n2i,
              data = data)

# === Run Random-Effects Meta-Analysis ===
model <- rma(yi, vi, data = res, random = ~ 1 | Study_ID, method = "REML")

# === Summary Output ===
summary(model)

# === Forest Plot ===
forest(model,
       slab = paste(data$Study_ID),
       xlab = "Effect Size (Hedges' g)",
       main = "Meta-Analysis of Shannon Diversity")

# === Funnel Plot ===
funnel(model,
       xlab = "Effect Size (Hedges' g)",
       main = "Funnel Plot of Effect Sizes")

# === Heterogeneity Stats ===
cat("\n=== Heterogeneity Statistics ===\n")
cat("Between-study variance (tau²): ", summary(model)$tau2, "\n")
cat("I²: ", summary(model)$I2, "%\n")
cat("Q statistic: ", summary(model)$QE, "\n")
cat("Q-test p-value: ", summary(model)$QEp, "\n")

# === Meta-regression on Mean Sample Size ===
res$mean_n <- (data$n1i + data$n2i) / 2
meta_reg <- rma(yi, vi, mods = ~ mean_n, data = res, method = "REML")
summary(meta_reg)
# Recode treatments into simplified groups
res$Treatment_Group <- ifelse(grepl("starve", tolower(res$TREATMENT)), "Starvation",
                              ifelse(grepl("tuna|protein", tolower(res$TREATMENT)), "Protein",
                                     ifelse(grepl("butter", tolower(res$TREATMENT)), "Fat",
                                            ifelse(grepl("wheat|white|honey", tolower(res$TREATMENT)), "Carbohydrate",
                                                   ifelse(grepl("synthetic|cellulose|bran", tolower(res$TREATMENT)), "Fiber", 
                                                          "Other")))))

# === Meta-regression on Study (categorical) ===
meta_reg_cat <- rma(yi, vi, mods = ~ TREATMENT, data = res, method = "REML")
summary(meta_reg_cat)
meta_reg_grouped <- rma(yi, vi, mods = ~ Treatment_Group, data = res, method = "REML")
summary(meta_reg_grouped)

# Initialize a data frame to store results
#leave one
# === Load Required Packages ===
library(metafor)
library(readxl)
library(dplyr)
library(ggplot2)

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

# === Run Random-Effects Meta-Analysis Using Paper as Group ===
model <- rma(yi, vi, data = res, random = ~1 | Paper, method = "REML")

# === Leave-One-Paper-Out Sensitivity Analysis ===
unique_papers <- unique(res$Paper)
results <- data.frame()

for (paper in unique_papers) {
  res_subset <- res %>% filter(Paper != paper)
  model_lopo <- rma(yi, vi, data = res_subset, method = "REML")
  results <- rbind(results, data.frame(
    Paper_Excluded = paper,
    Estimate = model_lopo$b,
    CI_lb = model_lopo$ci.lb,
    CI_ub = model_lopo$ci.ub
  ))
}

# === Plot the LOPO Results ===
ggplot(results, aes(x = Paper_Excluded, y = Estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = CI_lb, ymax = CI_ub), width = 0.2) +
  theme_minimal() +
  labs(title = "Leave-One-Paper-Out Sensitivity Analysis",
       x = "Study (Paper) Excluded",
       y = "Effect Size (Hedges' g)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
