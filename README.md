# Statistical Genetics Lab Project
Analyses performed for 4th year lab project, "How Do Genetic Factors Associated with Autism Contribute to Sleep and Circadian Rhythm Disruptions?".

## Aims
The main objectives of this project were to:

**.** Investigate the genetic correlations between Polygenic Risk Scores (PGS) for autism, insomnia and chronotype

**.** Analyse PGS distributions across global populations using the 1000 Genomes Project

**.** Examine the influence of population structure on autism PGS interpretation

## Data Preparation
### Download and Convert the 1000 Genomes Project Dataset
In order to calculate PGS, the 1000 Genomes Project had to be downloaded and converted into a compatible format for SBayesRC
```# Download 1000 Genomes VCF files
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/*.vcf.gz
# Convert VCF to PLINK format
plink --vcf ALL.chr*.vcf.gz --make-bed --out 1000G
```

### Quality Control (QC)
QC was carried out to exclude any low quality SNPs and/or individuals, making downstream analyses more robust
```# Filter SNPs and individuals based on missingness and MAF
plink --bfile 1000G --geno 0.05 --mind 0.05 --maf 0.01 --make-bed --out 1000G_QC

# Perform LD pruning to reduce SNP correlation
plink --bfile 1000G_QC --indep-pairwise 50 5 0.2 --out 1000G_pruned
plink --bfile 1000G_QC --extract 1000G_pruned.prune.in --make-bed --out 1000G_LDpruned
```

### Principal Component Analysis (PCA)
The first ten principal components were extracted to investigate whether population had an influence on PGS interpretation. 
This is possible due to PCA capturing population structure.
```
plink --bfile 1000G_LDpruned --pca 10 --out 1000G_PCA
```
## Reformatting GWAS Summary Statistics into COJO Format
The GWAS Summary Statistics are converted into COJO format as this ensures that the SNP IDs, alleles and effect sizes match the 1000 Genomes dataset. Below is an example of the Bash code used for the 
GWAS summary statistics of each trait within the Ubuntu terminal.
```# Input and output file names
INPUT_FILE="input_cojo.txt"
OUTPUT_FILE="formatted_data.txt"

# Set constant N value
N=46351

# Write header to output file
echo -e "SNP\tA1\tA2\tb\tse\tp\tN" > "$OUTPUT_FILE"

# Process the input file, skipping the header
awk -v N="$N" 'NR>1 {
    print $1, $3, $4, log($6), $7, $8, N
}' OFS="\t" "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "Reformatting complete. Output saved to $OUTPUT_FILE."
```

### Filter SNPs from GWAS and 1000 Genomes Dataset
This filtration ensured that only SNPs that were present in both the GWAS and the 1000 Genomes datasets remained
```
plink --bfile 1000G_QC --extract <GWAS_SNP_list.txt> --make-bed --out GWAS_SNPs_filtered
```

## SBayesRC
SBayesRC was then ran using the reformatted data for all three traits to generate weighted effects estimates. Below coding example is for autism, with the same process being 
applied to insomnia and chronotype.
```# Tidy
Rscript -e "SBayesRC::tidy(mafile=‘autism_cojo_tab.txt’, LDdir='../ukbEUR_Imputed', output='autism_tidy.ma', log2file=TRUE)"
 
# Impute
Rscript -e "SBayesRC::impute(mafile='autism_tidy.ma', LDdir='../ukbEUR_Imputed', output='autism_imp.ma', log2file=TRUE)"
 
# Run model
 
Rscript -e "SBayesRC::sbayesrc(mafile='autism_imp.ma', LDdir='../ukbEUR_Imputed', outPrefix='autism_tidy_sbrc', annot='../annot_baseline2.2.txt', log2file=TRUE)"
```

### Extracting Weight Sizes
The SNP weighted effects estimates were then extracted to be used in computing PGS
```
awk '{print $2, $4}' Autism_SBayesRC.snpRes > Autism_PGS_weights.txt
```

## PGS Computation 
The extracted weighted effect sizes were then used to generate individual PGS across autism, insomnia and chronotype. Below example is for the autism scores.
```
plink --bfile 1000G_QC \
      --score Autism_PGS_weights.txt 1 2 3 header \
      --out 1000G_Autism_PGS
```

## Data Visualisation and Analysis 
In order to create a single dataset for autism, the PGS were combined with the PCA components, super-population and population files within RStudio.
```#load in autism data and rename columns
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
```

### Scatter Plot to assess PCA
A Scatter Plot was generated to evaluate whether principal components had an effect on autism PGS
```
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
```

### Histogram of PGS Distribution
A Histogram was created to enable autism PGS distribution to be observed, whether it was normalised or not, and to assess if the polygenic model was supported.
```
library(ggplot2)

ggplot(merged_data, aes(x = `Score Average`)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7) +
  labs(title = "Distribution of Autism PGS",
       x = "Score Average",
       y = "Frequency") +
  theme_minimal()
```

### Correlation Matrix
The correlation matrix was generated to determine the genetic relationships between autism, insomnia and chronotype PGS
```
cor.test(merged_data$Autism_SCORE, merged_data$Sleep_SCORE)

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
```

### Linear Regression Graph
A linear Regression was carried out to determine whether the principal components accurately predicted autism PGS. This was observed by plotting the predicted PGS against the observed autism PGS.
```
library(ggplot2)

ggplot(merged_data, aes(x = predict(lm_result), y = `Score Average`)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(title = paste0("Predicted vs. Observed Autism PGS Scores (R-squared = ", round(summary(lm_result)$r.squared, 4), ")"),
       x = "Autism PGS Predicted by PCs",
       y = "Observed Autism PGS") +
  theme_minimal()
```

### Boxplot of PGS Distribution Across Ancestry
This boxplot allowed for the determination of whether ancestry (super-population) influenced PGS distribution
```
library(ggplot2)

ggplot(merged_data, aes(x=Population, y=SCORE)) +
    geom_boxplot() +
    labs(title="Autism PGS Across Populations", x="Population", y="PGS") +
    theme_minimal()
```
