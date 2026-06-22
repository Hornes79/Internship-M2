## ==============================================================================
## Script Name:  script_visualisation_example.R
## Purpose:      Example template for taxonomic profiling, quality assessment, 
##               and AMR/VF analysis of Metagenome-Assembled Genomes (MAGs).
## Author:       Hornes
## Date:         June 2026
## Note:         Input data files are not included in this repository. 
##               Users must provide their own tsv/csv files to run the code.
## ==============================================================================

## ==============================================================================
## INITIAL CONFIGURATION & PACKAGES LOADING
## ==============================================================================

# Set your working directory here
# setwd("/path/to/your/data")

# Define required packages
required_packages <- c(
  "dplyr", "ggplot2", "tidyr", "stringr", "patchwork", 
  "ComplexUpset", "data.table", "RColorBrewer", "scales", "purrr", "grid"
)

# Load packages silently
invisible(lapply(required_packages, library, character_only = TRUE))

# Session information for reproducibility and traceability
sessionInfo()

## ==============================================================================
## 1. GLOBAL BACTERIAL TAXONOMY (BY ENVIRONMENT/SITE)
## ==============================================================================

# Function to generate the taxonomy barplot by phylum
make_taxo_plot_all_bac <- function(file_taxo, title_plot) {
  taxo_df <- read.table(file_taxo, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  taxo_phylum <- taxo_df %>% count(Phylum, sort = TRUE)
  
  p <- ggplot(taxo_phylum, aes(x = reorder(Phylum, n), y = n)) +
    geom_bar(stat = "identity") + 
    coord_flip() +
    labs(title = title_plot, x = "Phylum", y = "Number of MAGs") + 
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 28),
      axis.text.y = element_text(size = 26, face = "bold"),
      axis.text.x = element_text(size = 20, face = "bold"),
      axis.title = element_text(size = 20, face = "bold"),
      legend.position = "none"
    )
  return(p)
}

# Example of how to call the function (requires input files)
# p_dissemin   <- make_taxo_plot_all_bac("taxo_clean_dissemin.tsv", "Guéry Site")
# p_reseaux    <- make_taxo_plot_all_bac("taxo_clean_reseaux.tsv", "Wastewater")
# p_plasticome <- make_taxo_plot_all_bac("taxo_clean_plasticome.tsv", "Lake Aydat")
# p_microstore <- make_taxo_plot_all_bac("taxo_clean_microstore.tsv", "Lake Pavin")

# Example of plot assembly using patchwork
# (p_plasticome | p_microstore)

## ==============================================================================
## 2. TAXONOMY OF UNCLASSIFIED MAGS AT SPECIES LEVEL
## ==============================================================================

# Example structure for merging datasets and filtering for unclassified species
run_unclassified_analysis <- function() {
  # taxo_aydat    <- read.delim("taxo_clean_plasticome.tsv") %>% mutate(Projet = "Lake Aydat")
  # taxo_pavin    <- read.delim("taxo_clean_microstore.tsv") %>% mutate(Projet = "Lake Pavin")
  # taxo_reseaux  <- read.delim("taxo_clean_reseaux.tsv")    %>% mutate(Projet = "Wastewater")
  # taxo_dissemin <- read.delim("taxo_clean_dissemin.tsv")   %>% mutate(Projet = "Guéry Site")
  
  # df_plot <- bind_rows(taxo_aydat, taxo_pavin, taxo_reseaux, taxo_dissemin) %>%
  #   filter(Species == "unclassified") %>%
  #   group_by(Phylum, Projet) %>%
  #   summarise(n = n(), .groups = "drop")
  
  # ordre_phylum <- df_plot %>% group_by(Phylum) %>% summarise(total = sum(n)) %>% arrange(total) %>% pull(Phylum)
  # df_plot$Phylum <- factor(df_plot$Phylum, levels = ordre_phylum)
  
  # plot_mag_new <- ggplot(df_plot, aes(x = n, y = Phylum, fill = Projet)) +
  #   geom_bar(stat = "identity", position = "stack") +
  #   scale_fill_manual(values = c("Lake Aydat" = "#1b9e77", "Lake Pavin" = "#d95f02", "Guéry Site" = "#7570b3", "Wastewater" = "#e7298a")) +
  #   theme_minimal() + labs(x = "Number of MAGs", y = "Phylum", fill = "Environment")
  
  # print(plot_mag_new)
}

## ==============================================================================
## 3. UPSET ANALYSES (DREP CLUSTERING & GLOBAL SAMPLE COVERAGE)
## ==============================================================================

# --- Upset dRep Template ---
run_drep_upset <- function() {
  # df_drep <- read.csv("Cdb.csv") %>% ...
  # upset(mat_drep, intersect = c("Lake Aydat", "Guéry Site", "Lake Pavin", "Wastewater"))
}

# --- Upset Coverage Template ---
process_file_upset_all <- function(file, dataset_name) {
  df <- read.table(file, header = TRUE, sep = "\t", check.names = FALSE)
  colnames(df)[1] <- "MAG"
  cov_cols <- grep("Covered[._ ]Fraction", colnames(df), value = TRUE)
  
  df_long <- df %>%
    select(MAG, all_of(cov_cols)) %>%
    pivot_longer(cols = -MAG, names_to = "Sample", values_to = "Coverage") %>%
    filter(Coverage > 0) %>%
    mutate(Environnement = dataset_name)
  return(df_long)
}

## ==============================================================================
## 4. VIRAL AND ARCHAEAL TAXONOMY
## ==============================================================================

# code example for plotting viral order distribution
# taxo_virus <- read.table("taxo_virus_all_clean.tsv", header = TRUE, sep = "\t")
# ggplot(df_virus, aes(x = Projet, y = n, fill = Order)) + geom_bar(stat = "identity")

## ==============================================================================
## 5. AMR / VF DISTRIBUTION AND TAXONOMY (DONUT & BAR PLOTS)
## ==============================================================================

# Clean single donut plot generator function
make_donut <- function(data, title, colors_vec) {
  data <- data %>% filter(count > 0)
  ggplot(data, aes(x = 2, y = count, fill = category)) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") + xlim(0.5, 3) +
    scale_fill_manual(values = colors_vec) +
    theme_void() + ggtitle(title)
}

# Taxonomic Barplots for ARG / VF Carrying MAGs
make_arg_bar_plot <- function(file_arg, titre_plot) {
  arg_df <- read.table(file_arg, header = TRUE, sep = "\t", fill = TRUE, quote = "", stringsAsFactors = FALSE)
  phylum_counts <- arg_df %>% group_by(Phylum, Type) %>% summarise(n = n(), .groups = "drop")
  
  p <- ggplot(phylum_counts, aes(x = Phylum, y = n, fill = Type)) +
    geom_bar(stat = "identity", position = "stack") + coord_flip() + theme_minimal()
  return(p)
}

## ==============================================================================
## 6. AMR CLASSES PROFILING & GLOBAL SCALE STANDARDIZATION
## ==============================================================================

# Regex-based normalization helper for gene annotation string parsing
standardize_arg_groups <- function(df) {
  df %>% mutate(
    group = case_when(
      str_detect(annotation, regex("beta-lactamase", TRUE)) ~ "beta-lactamase",
      str_detect(annotation, regex("fosfomycin", TRUE))     ~ "fosfomycin",
      str_detect(annotation, regex("vancomycin", TRUE))     ~ "vancomycin",
      str_detect(annotation, regex("aminoglycoside|kasugamycin", TRUE)) ~ "aminoglycoside",
      str_detect(annotation, regex("rifampin|polymerase", TRUE))        ~ "rifamycin",
      str_detect(annotation, regex("tetracycline", TRUE))   ~ "tetracycline",
      str_detect(annotation, regex("macrolide", TRUE))      ~ "macrolide",
      str_detect(annotation, regex("ribosomal", TRUE))      ~ "MLS",
      str_detect(annotation, regex("streptogramin", TRUE))  ~ "streptogramin",
      str_detect(annotation, regex("chloramphenicol", TRUE))~ "chloramphenicol",
      str_detect(annotation, regex("multidrug", TRUE))      ~ "multidrug",
      TRUE ~ "other"
    )
  )
}

## ==============================================================================
## 7. COMPLEX UPSET PLOTS (PHYLUM-SPECIFIC ARG & VF/ARG+VF CLASS BREAKDOWNS)
## ==============================================================================

# Wide format coverage data integration helper
process_file_wide <- function(file, dataset_name) {
  df <- read.table(file, header = TRUE, sep = "\t", check.names = FALSE)
  colnames(df)[1] <- "MAG"
  cov_cols <- grep("Covered[._ ]Fraction", colnames(df), value = TRUE)
  df %>% select(MAG, all_of(cov_cols)) %>% rename_with(~ paste0(dataset_name, "_", .), -MAG)
}

## ==============================================================================
## 8. GENOME QUALITY ASSESSMENT & COMPARATIVE METRICS (BOXPLOTS)
## ==============================================================================

make_boxplot <- function(data, yvar, ylab) {
  ggplot(data, aes(x = Environment, y = .data[[yvar]], fill = Environment)) +
    geom_boxplot(alpha = 0.85, outlier.size = 1) +
    labs(x = "Environment", y = ylab) + theme_minimal()
}

## ==============================================================================
## 9. METHODOLOGICAL EVALUATION (BINNING TOOLS & DAS TOOL PERFORMANCE)
## ==============================================================================

make_quality_pie <- function(total_bins, hq_mq_bins, tool_name) {
  df <- data.frame(categorie = c("HQ + MQ bins", "LQ bins"), nombre = c(hq_mq_bins, total_bins - hq_mq_bins))
  ggplot(df, aes(x = "", y = nombre, fill = categorie)) +
    geom_bar(stat = "identity", width = 1, color = "white") + coord_polar(theta = "y") +
    theme_void() + labs(title = tool_name)
}
