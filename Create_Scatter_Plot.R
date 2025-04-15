R Code

This code was used for data visualization and statistical analysis.

Loading Data

#load in autism data and rename columns
autism_pgs_data <- read.table("autism_1kg_PRS.sscore", header=FALSE)

head(autism_pgs_data)

colnames(autism_pgs_data)[1] <- "FID"
colnames(autism_pgs_data)[2] <- "IID"
colnames(autism_pgs_data)[3] <- "ALLELE_CT"
colnames(autism_pgs_data)[4] <- "NAMED_ALLELE_DOSAGE_SUM"
colnames(autism_pgs_data)[5] <- "SCORE_AVERAGE"

#load in population label data
pop_data <- read.table("1000G_Merged_Population_Corrected.txt", header=TRUE)

#load in pca data and rename columns 
pca_data <- read.table("1kg_pca.eigenvec", header=FALSE)

colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:(ncol(pca_data)-2)))

pca_data <- pca_data[, -1]

#merge  Autism PGS, PCA and population labels

merged_data <- merge(pgs_data, pca_data, by=c("FID", "IID"))
merge(...): Merges the PGS data and PCA data based on the individual identifiers (FID and IID).

Scatter Plot

R

library(ggplot2)

ggplot(merged_data, aes(x = PC1, y = PC2, color = `Score Average`)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(title = "PCA of 1000 Genomes with Autism PGS",
       x = "PC1",
       y = "PC2",
       color = "Score Average") +
  scale_color_gradient(low = "blue", high = "red") +
  theme_minimal() +
  geom_smooth(method = "loess", se = FALSE, color = "green")

This code will generate a scatter plot showing the relationship between PC1 and PC2, with the points colored by the "Score Average" (Autism PGS) values and a smoothed line to highlight the general trend.
