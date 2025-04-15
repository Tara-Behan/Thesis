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

Boxplot Visualisation

R

ggplot(merged_data, aes(x=Population, y=SCORE)) +
    geom_boxplot() +
    labs(title="Autism PGS Across Populations", x="Population", y="PGS") +
    theme_minimal()
ggplot(...): Creates a ggplot object.
aes(x=Population, y=SCORE): Sets the x-axis to "Population" and the y-axis to "SCORE" (the PGS column).
geom_boxplot(): Adds a boxplot to the plot.
labs(...): Adds labels to the plot.
theme_minimal(): Applies a minimal theme.
