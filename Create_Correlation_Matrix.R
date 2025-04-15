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

Correlation Test

R

cor.test(merged_data$Autism_SCORE, merged_data$Sleep_SCORE)
cor.test(...): Performs a Pearson correlation test to assess the linear relationship between two PGS scores.
Correlation Matrix Visualization

R

# Create a data frame from correlation results
correlation_data <- data.frame(
  Variable1 = c("Autism PGS", "Autism PGS", "Insomnia PGS"),
  Variable2 = c("Insomnia PGS", "Chronotype PGS", "Chronotype PGS"),
  cor = c(-0.1426087, 0.01881833, -0.00957133),
  p_value = c(2.23e-06, 0.5345, 0.7521)
)

# Add significance labels
correlation_data$significance <- ifelse(correlation_data$p_value < 0.001, "***",
                                      ifelse(correlation_data$p_value < 0.01, "**",
                                             ifelse(correlation_data$p_value < 0.05, "*", "ns")))

# Load necessary library
library(ggplot2)

# Create the correlation matrix visualization
ggplot(data = correlation_data, aes(x = Variable1, y = Variable2, fill = cor)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                      midpoint = 0, limit = c(-1, 1)) +
  geom_text(aes(label = round(cor, 2)), color = "black", size = 4) +
  geom_text(aes(label = significance), y = 0.8, color = "black", size = 6) +
  labs(title = "Correlation Matrix of Polygenic Scores",
       x = "", y = "", fill = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
This code creates a correlation matrix visualization using ggplot2 to display the correlations between different PGS scores.
