install.packages(c("readxl", "metafor", "dplyr", "ggplot2"))
# Load packages
getwd()
# Load necessary packages
library(readxl)
library(dplyr)
library(metafor)

# Step 1: Read the Excel file
file_path <- "C:/Users/muhta/OneDrive/Desktop/Meta analysis/paper/data/relativeabundance.xlsx"
df <- read_excel(file_path)

# Step 2: Calculate proportions and F:B ratio
df <- df %>%
  mutate(
    p_firm_control = Control.Firmicutes / (Control.Firmicutes + Control.Bacteroidetes),
    p_firm_treat   = Treatment.Firmicutes / (Treatment.Firmicutes + treatement.Bacteroidetes),
    
    p_bact_control = Control.Bacteroidetes / (Control.Firmicutes + Control.Bacteroidetes),
    p_bact_treat   = treatement.Bacteroidetes / (Treatment.Firmicutes + treatement.Bacteroidetes),
    
    fb_control = Control.Firmicutes / Control.Bacteroidetes,
    fb_treat   = Treatment.Firmicutes / treatement.Bacteroidetes
  )

# Step 3: Log response ratios (effect sizes)
df <- df %>%
  mutate(
    yi_firm = log(p_firm_treat / p_firm_control),
    yi_bact = log(p_bact_treat / p_bact_control),
    yi_fb   = log(fb_treat / fb_control)
  )

# Step 4: Delta-method SEs
df <- df %>%
  mutate(
    se_firm = sqrt(
      ((1 - p_firm_treat) / (Treatment.Sample * p_firm_treat))^2 +
        ((1 - p_firm_control) / (Control.Sample * p_firm_control))^2
    ),
    se_bact = sqrt(
      ((1 - p_bact_treat) / (Treatment.Sample * p_bact_treat))^2 +
        ((1 - p_bact_control) / (Control.Sample * p_bact_control))^2
    ),
    se_fb = sqrt(
      ((1 / treatement.Bacteroidetes)^2 + (1 / Treatment.Firmicutes)^2) / Treatment.Sample +
        ((1 / Control.Bacteroidetes)^2 + (1 / Control.Firmicutes)^2) / Control.Sample
    )
  )

# Step 5: Meta-analysis
res_firm <- rma(yi = yi_firm, sei = se_firm, data = df, method = "REML")
res_bact <- rma(yi = yi_bact, sei = se_bact, data = df, method = "REML")
res_fb <- rma(yi = yi_fb, sei = se_fb, data = df, method = "REML")

# Step 6: Summary
summary(res_firm)
summary(res_bact)
summary(res_fb)

# Step 7: Forest plots
forest(res_firm, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (Firmicutes)", main = "Firmicutes Effect Size")
forest(res_bact, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (Bacteroidetes)", main = "Bacteroidetes Effect Size")
forest(res_fb, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (F:B Ratio)", main = "Firmicutes:Bacteroidetes Ratio")
#Plot
# Load library
library(ggplot2)

# ========== Firmicutes ==========
loo_firm <- leave1out(res_firm)
loo_firm_df <- as.data.frame(loo_firm)
loo_firm_df$Study <- paste(df$Study_ID, df$Treatment)

ggplot(loo_firm_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_firm$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    title = "Leave-One-Out Analysis (Firmicutes)",
    x = "Excluded Comparison",
    y = "Effect Size (Log Ratio)"
  ) +
  theme_minimal()

# ========== Bacteroidetes ==========
loo_bact <- leave1out(res_bact)
loo_bact_df <- as.data.frame(loo_bact)
loo_bact_df$Study <- paste(df$Study_ID, df$Treatment)

ggplot(loo_bact_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_bact$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    title = "Leave-One-Out Analysis (Bacteroidetes)",
    x = "Excluded Comparison",
    y = "Effect Size (Log Ratio)"
  ) +
  theme_minimal()

# ========== F:B Ratio ==========
loo_fb <- leave1out(res_fb)
loo_fb_df <- as.data.frame(loo_fb)
loo_fb_df$Study <- paste(df$Study_ID, df$Treatment)

ggplot(loo_fb_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_fb$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    title = "Leave-One-Out Analysis (F:B Ratio)",
    x = "Excluded Comparison",
    y = "Effect Size (Log Ratio)"
  ) +
  theme_minimal()
