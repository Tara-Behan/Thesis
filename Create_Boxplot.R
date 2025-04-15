R Code

This code was used for data visualization and statistical analysis.

Loading Data

#load in autism data and rename columns
autism_pgs_data <- read.table("adhd_1kg_PRS.sscore", header=FALSE)

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
