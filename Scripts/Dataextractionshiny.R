# === Data Extraction from Figures via ShinyDigitise ===

# 1. Install required packages (run once)
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
if (!requireNamespace("promises", quietly = TRUE)) {
  install.packages("promises")
}
# Install the ShinyDigitise package from GitHub (force reinstall if already present)
devtools::install_github("EIvimeyCook/ShinyDigitise", force = TRUE)

# 2. Load libraries
library(ShinyDigitise)
library(promises)

# 3. Launch interactive digitising app and capture extracted data
#    Point your file browser at the folder containing your figure images.
#    Returns a data.frame of (x, y) coordinates and any grouping metadata.
figure_dir <- "figure"
extracted_df <- shinyDigitise(figure_dir)

# 4. Inspect the extracted data
head(extracted_df)

# 5. (Optional) Save extracted coordinates to disk for downstream analysis
output_path <- file.path(figure_dir, "digitised_coordinates.csv")
write.csv(extracted_df, output_path, row.names = FALSE)
message("Digitised data saved to: ", output_path)
