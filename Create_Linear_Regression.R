R Code

This code was used for data visualization and statistical analysis.

Loading Data

R

library(ggplot2)
pgs_data <- read.table("1000G_Autism_PGS.profile", header=TRUE)
pca_data <- read.table("1000G_PCA.eigenvec", header=FALSE)
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:10))
library(ggplot2): Loads the ggplot2 package for plotting.
pgs_data <- read.table("1000G_Autism_PGS.profile", header=TRUE): Reads the PGS data from a file.
pca_data <- read.table("1000G_PCA.eigenvec", header=FALSE): Reads the PCA results from a file.
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:10)): Assigns column names to the PCA data (FID = Family ID, IID = Individual ID, PC1-PC10 = Principal Components).
Merging Data

R

merged_data <- merge(pgs_data, pca_data, by=c("FID", "IID"))
merge(...): Merges the PGS data and PCA data based on the individual identifiers (FID and IID).

Linear Regression Graph

R

library(ggplot2)

ggplot(merged_data, aes(x = predict(lm_result), y = `Score Average`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = paste0("Predicted vs. Observed Autism PGS Scores (R-squared = ", round(summary(lm_result)$r.squared, 4), ")"),
       x = "Autism PGS Predicted by PCs",
       y = "Observed Autism PGS") +
  theme_minimal()
This code generates a scatter plot showing the relationship between predicted and observed Autism PGS scores, with a linear regression line.
