# Software Versions and Databases

## Overview
This document reports the software versions, reference databases and computational environment used for the reconstruction, annotation and analysis of metagenome-assembled genomes (MAGs) 

---

# Software Versions

## Pre-processing
| Software    | Version | Purpose                      |
| ----------- | ------- | ---------------------------- |
| FastQC      | v0.11.7  | Raw reads quality assessment |
| Trimmomatic | v0.38 | Read trimming and filtering  |
---

## Assembly
| Software | Version | Purpose             |
| -------- | ------- | ------------------- |
| MEGAHIT  | v1.1.1   | Metagenome assembly |
---

## Reads mapping, Binning and Refinement
| Software | Version | Purpose                            |
| -------- | ------- | ---------------------------------- |
| Bowtie2  | 2.5.5  | assembly indexing and read mapping |
| Samtool  | 1.23.1 | read mapping |
| MetaBAT2 | v2.18   | Genome binning                     |
| SemiBin2 | v2.2.1   | Deep-learning based genome binning |
| DAS Tool | v1.1.7  | Bin refinement and selection       |
| dRep     | v3.6   | MAG dereplication                  |
---

## Quality Assessment
| Software | Version | Purpose                                   |
| -------- | ------- | ----------------------------------------- |
| CheckM2  | v1.1   | Machine learning-based quality estimation |
---

## Taxonomic Annotation
| Software | Version | Purpose                          |
| -------- | ------- | -------------------------------- |
| GTDB-Tk  | v2.6.1   | Taxonomic classification of MAGs |
---

## Functional Annotation
| Software | Version | Purpose                      |
| -------- | ------- | ---------------------------- |
| Bakta    | v1.12   | Genome annotation            |
| CoverM   | v0.7.0   | MAG abundance estimation     |
---

## Giant Virus Detection
| Software | Version | Purpose                    |
| -------- | ------- | -------------------------- |
| GVClass  | v1.2.2   | Giant virus classification |
---

# Reference Databases

## Quality Assessment
| Database | Release |
| --------- | --------- |
| CheckM2 | v3.0  | 
---

## Taxonomy
| Database      | Release  |
| ------------- | ----------------- |
| GTDB          | Release R226      |
---

## Functional Annotation
| Database / Ressource      | Version |
| -------------- | ----------------- |
| Bakta database | v6.0              |
| AMRFinderPlus database| Included in Bakta database|
| VFDB homologs | Included in Bakta database | 
---


