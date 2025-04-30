# Step 0: Install necessary packages
install.packages(c("readxl", "metafor", "dplyr", "ggplot2", "writexl", "devtools"))
devtools::install_github("daniel1noble/orchard")

# Load libraries
library(readxl)
library(dplyr)
library(metafor)
library(ggplot2)
library(writexl)
library(orchaRd)

# Step 1: Read Excel file
file_path <- "relativeabundance.xlsx"
df <- read_excel(file_path)

# Step 2: Clean/rename columns if needed
df <- df %>%
  rename(
    Control_Firmicutes = Control_Firmicutes,
    Control_Bacteroidetes = Control_Bacteroidetes,
    Treatment_Firmicutes = Treatment_Firmicutes,
    Treatment_Bacteroidetes = treatement_Bacteroidetes,
    Control_Sample = Control_Sample,
    Treatment_Sample = Treatment_Sample
  )

# Step 3: Proportions & F:B ratio
df <- df %>%
  mutate(
    p_firm_control = Control_Firmicutes / (Control_Firmicutes + Control_Bacteroidetes),
    p_firm_treat   = Treatment_Firmicutes / (Treatment_Firmicutes + Treatment_Bacteroidetes),
    
    p_bact_control = Control_Bacteroidetes / (Control_Firmicutes + Control_Bacteroidetes),
    p_bact_treat   = Treatment_Bacteroidetes / (Treatment_Firmicutes + Treatment_Bacteroidetes),
    
    fb_control = Control_Firmicutes / Control_Bacteroidetes,
    fb_treat   = Treatment_Firmicutes / Treatment_Bacteroidetes
  )

# Step 4: Log response ratios
df <- df %>%
  mutate(
    yi_firm = log(p_firm_treat / p_firm_control),
    yi_bact = log(p_bact_treat / p_bact_control),
    yi_fb   = log(fb_treat / fb_control)
  )

# Step 5: Delta-method SEs
df <- df %>%
  mutate(
    se_firm = sqrt(((1 - p_firm_treat) / (Treatment_Sample * p_firm_treat))^2 +
                     ((1 - p_firm_control) / (Control_Sample * p_firm_control))^2),
    
    se_bact = sqrt(((1 - p_bact_treat) / (Treatment_Sample * p_bact_treat))^2 +
                     ((1 - p_bact_control) / (Control_Sample * p_bact_control))^2),
    
    se_fb = sqrt(
      ((1 / Treatment_Bacteroidetes)^2 + (1 / Treatment_Firmicutes)^2) / Treatment_Sample +
        ((1 / Control_Bacteroidetes)^2 + (1 / Control_Firmicutes)^2) / Control_Sample
    )
  )

# Step 6: Meta-analysis
res_firm <- rma(yi = yi_firm, sei = se_firm, data = df, method = "REML")
res_bact <- rma(yi = yi_bact, sei = se_bact, data = df, method = "REML")
res_fb <- rma(yi = yi_fb, sei = se_fb, data = df, method = "REML")

# Step 7: Egger's test
egger_firm <- regtest(res_firm, model = "rma")
egger_bact <- regtest(res_bact, model = "rma")
egger_fb <- regtest(res_fb, model = "rma")

print(egger_firm)
print(egger_bact)
print(egger_fb)

# Step 8: Trim-and-fill
tf_firm <- trimfill(res_firm)
tf_bact <- trimfill(res_bact)
tf_fb <- trimfill(res_fb)
print(tf_firm)
print(tf_bact)
print(tf_fb)
# Step 9: Funnel plots
pdf("Firmicutes_Funnel.pdf")
funnel(res_firm, main = "Funnel Plot: Firmicutes")
dev.off()

pdf("Bacteroidetes_Funnel.pdf")
funnel(res_bact, main = "Funnel Plot: Bacteroidetes")
dev.off()

pdf("FB_Ratio_Funnel.pdf")
funnel(res_fb, main = "Funnel Plot: F:B Ratio")
dev.off()
#Step 10: Orchard plot
# Firmicutes Orchard Plot
pdf("Firmicutes_Orchard.pdf")
orchard_plot(res_firm, mod = "1", group = "Study_ID",
             angle = 90, xlab = "Log Ratio (Firmicutes)", transfm = "none")
dev.off()

# Bacteroidetes Orchard Plot
pdf("Bacteroidetes_Orchard.pdf")
orchard_plot(res_bact, mod = "1", group = "Study_ID",
             angle = 90, xlab = "Log Ratio (Bacteroidetes)", transfm = "none")
dev.off()

# F:B Ratio Orchard Plot
pdf("FB_Ratio_Orchard.pdf")
orchard_plot(res_fb, mod = "1", group = "Study_ID",
             angle = 90, xlab = "Log Ratio (Firmicutes:Bacteroidetes)", transfm = "none")
dev.off()

# Step 11: Forest plots
forest(res_firm, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (Firmicutes)", main = "Forest Plot: Firmicutes")
forest(res_bact, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (Bacteroidetes)", main = "Forest Plot:Bacteroidetes")
forest(res_fb, slab = paste(df$Study_ID, df$Treatment), xlab = "Log Ratio (F:B Ratio)", main = "Forest Plot: Firmicutes:Bacteroidetes Ratio")
# Step 12: Leave-one-out
loo_firm <- leave1out(res_firm)
loo_bact <- leave1out(res_bact)
loo_fb <- leave1out(res_fb)

# Add study labels
loo_firm_df <- as.data.frame(loo_firm)
loo_firm_df$Study <- paste(df$Study_ID, df$Treatment)

loo_bact_df <- as.data.frame(loo_bact)
loo_bact_df$Study <- paste(df$Study_ID, df$Treatment)

loo_fb_df <- as.data.frame(loo_fb)
loo_fb_df$Study <- paste(df$Study_ID, df$Treatment)

# Step 13: Save LOO plots
pdf("Firmicutes_LOO.pdf")
ggplot(loo_firm_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_firm$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(title = "Leave-One-Out (Firmicutes)", x = "Excluded Comparison", y = "Effect Size") +
  theme_minimal()
dev.off()

pdf("Bacteroidetes_LOO.pdf")
ggplot(loo_bact_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_bact$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(title = "Leave-One-Out (Bacteroidetes)", x = "Excluded Comparison", y = "Effect Size") +
  theme_minimal()
dev.off()

pdf("FB_Ratio_LOO.pdf")
ggplot(loo_fb_df, aes(x = reorder(Study, estimate), y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = ci.lb, ymax = ci.ub), width = 0.2) +
  geom_hline(yintercept = res_fb$b[1], linetype = "dashed", color = "red") +
  coord_flip() +
  labs(title = "Leave-One-Out (F:B Ratio)", x = "Excluded Comparison", y = "Effect Size") +
  theme_minimal()
dev.off()

# Step 14: Save data outputs
output_list <- list(
  Effect_Sizes = df %>% select(Study_ID, Treatment, yi_firm, se_firm, yi_bact, se_bact, yi_fb, se_fb),
  LOO_Firmicutes = loo_firm_df,
  LOO_Bacteroidetes = loo_bact_df,
  LOO_FB_Ratio = loo_fb_df
)

write_xlsx(output_list, path = "logresponse_Analysis_Results.xlsx")

# Step 14: Summarize meta-analysis results
summary_stats <- function(res, label) {
  s <- summary(res)
  data.frame(
    Measure = label,
    Estimate = round(s$b[1], 4),
    CI_Lower = round(s$ci.lb, 4),
    CI_Upper = round(s$ci.ub, 4),
    Tau2 = round(s$tau2, 4),
    I2 = round(s$I2, 2),
    Q = round(s$QE, 4),
    Q_pval = signif(s$QEp, 4),
    stringsAsFactors = FALSE
  )
}

summary_df <- bind_rows(
     summary_stats(res_firm, "Firmicutes"),
     summary_stats(res_bact, "Bacteroidetes"),
     summary_stats(res_fb, "F:B Ratio")
   )
# Step 15: Add this to the Excel output
output_list$Meta_Analysis_Summary <- summary_df

# Overwrite Excel file with new sheet included
write_xlsx(output_list, path = "logresponse_Analysis_Results.xlsx")
