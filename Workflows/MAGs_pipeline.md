
# Pipeline for metagenome assembly and genome reconstruction from metagenomic data

## Preprocessing and preparation of metagenomic data
In this step, **FastQC** is used to assess the quality of the sequencing reads. **Trimmomatic** is then applied to remove low-quality bases and adapter sequences, retaining only high-quality reads for subsequent analysis


### [FastQC](https://github.com/s-andrews/FastQC) : quality control
```bash
fastqc /path/reads/*.fastq.gz -o /path/output_fastqc/ -t 16
```

### [Trimmomatic](https://github.com/usadellab/Trimmomatic) : cleaning reads
```bash
# Paired end
trimmomatic PE -threads 16 \
/path/sample_R1.fastq /path/sample_R2.fastq \
/path/output/sample_R1_paired.fastq /path/output/sample_R1_unpaired.fastq \
/path/output/sample_R2_paired.fastq /path/output/sample_R2_unpaired.fastq \
ILLUMINACLIP:/path/adapters.fa:2:30:10 \
LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:36
```


## Read assembly
The reads assembly step is performed using **MEGAHIT**

### [MEGAHIT](https://github.com/voutcn/megahit)
```bash
megahit -1 /path/sample_R1.fastq -2 /path/sample_R2.fastq -o /path/output_megahit --threads 16
```


## Combined assembly

For co-assembly based genome reconstruction, individual sample assemblies are reformatted to include the sample name in the headers and merged into a single assembly file.
See the [Fasta concatenation](scripts/01_concat_fasta.sh) for the automated loop script 




## Assembly indexing & Reads mapping

The combined assembly is indexed using **Bowtie2** before read mapping quality-filtered reads to estimate contig coverage required for genome binning

### [Bowtie2](https://github.com/benlangmead/bowtie2) & [Samtools](https://github.com/samtools/samtools)

```bash
# Indexing
bowtie2-build --large-index /path/to/assemble.fasta /path/to/contigs_index -p 16

# Mapping (Example for on sample)
bowtie2 \
    -x /path/to/contigs_index \
    -1 /path/to/sample_R1.fastq.gz \
    -2 /path/to/sample_R2.fastq.gz \
    -p 16 \
| samtools sort -@ 16 -o /path/to/sample.bam

samtools index /path/to/sample.bam

```


## Genome reconstruction
For multi-sample genomes reconstruction, two binning tools are used : **MetaBAT2** , **SemiBin2**


### [MetaBAT2](https://bitbucket.org/berkeleylab/metabat/src/master/)
```bash
# Calculating contigs coverage from BAM files
jgi_summarise_bam_contig_depths --outputDepth /path/depth.txt /path/bam_files 

# Contigs binning
metabat2 -i /path/fasta_file -a /path/depth.txt -o /path/output_dir -t 16 --unbinned -m 2500 -s 200000

# Key parameters :
# `-m 2500` : minimum contig length (bp)
# `-s 200000` : minimun bin size (bp)
# `--unbinned` saves contigs not assigned to any bin

```


### [SemiBin2](https://github.com/BigDataBiology/SemiBin)
```bash
SemiBin2 multi_easy_bin -i /path/fasta_file -b /path/bam_files -o /path/output_dir -m 2500 -p 16

# Key parameters :
# `-m 2500` : minimum contig length (bp)

```


## Bins refinement 
**DAS_Tool** is used to integrate bins produced by multiple binning tools
See the [prepare TSV](scripts/02_das_tool_prepare.sh)  for the automated input preparation script

### [DAS_Tool](https://github.com/cmks/DAS_Tool)
```bash
DAS_Tool \
  -i /path/file_metabat.tsv, /path/file_semibin.tsv \
  -l semibin,metabat \
  -c /path/fasta_file \
  -o /path/output_dir \
  -t 16 \
  --write_bins
  
# Key parameters :
# `-i`: list of TSV files (one per binning tool). Each TSV file contains the assignment of contigs to bin in the format 
# `-l`: labels corresponding to each binning tool (same order as `-i`)
  
```


## MAG dereplication 
**dRep** used for 95% deduplication of MAGs

### [dRep](https://github.com/MrOlm/drep)
```bash
dRep dereplicate /path/output_dir -g /path/bins/*.fa --ignoreGenomeQuality -p 16 

# Key parameters : `--ignoreGenomeQuality` dereplicate bins without considering genome quality (CheckM)

```


## MAG quality
**CheckM2** are used to assess the quality of metagenome-assembled genomes (MAGs), including completeness and contamination

### [CheckM2](https://github.com/chklovski/CheckM2)
```bash
checkm2 predict /path/genome_dir -o /path/output_dir -x fa --database_path /path/database_chechkm2 -t 16

# Key parameters :
# `-x` specifies the genome/bins file extension
# `--database_path` CheckM2 references database

```


## Taxonomic assignment
Taxonomic classification of MAGs is performed using **GTDB-Tk**


### [GTDB-Tk](https://github.com/Ecogenomics/GTDBTk)
```bash
gtdbtk classify_wf --genome_dir /path/genome_dir --out_dir /path/output_gtdbtk --extension fa --cpus 16  
```


## Giant virus detection
Detection and taxonomic classification of giant viruses (NCLDV) from metagenome-assembled genomes (MAGs) using **GVClass**

### [GVClass](https://github.com/NeLLi-team/gvclass)
```bash
/path/to/gvclass-a /path/to/genome_dir /path/to/output_gvclass -t 16

```


## Functional annotation
Functional annotation of MAGs is performed with **Bakta**, using VFDB and AMRFinder for virulence and antimicrobial resistance gene detection.
See the [bakta loop](scripts/03_bakta_loop.sh) for the automated bacth annotation loop script 

### [Bakta](https://github.com/oschwengers/bakta)
```bash
bakta \
  --db /path/database_bakta \
  --threads 16 \
  --meta \
  --output /path/output_dir \
  /path/genome.fa

# Key parameters :
# `--db` path to Bakta database
# `--meta` run in metagenome mode

```

## MAGs abundance profiling (Mapping & CoverM)
To analyze the spatio-temporal dynamics of the reconstructed genomes, individual sequencing reads from each sample are mapped against a non-redundant reference catalogue containing all concatenated MAGs.

#### Step 1: Concatenate and Index the MAG Catalogue
Before mapping, all individual MAG FASTA files are combined into a single reference global file, which is then indexed using Bowtie2.

```bash
# 1. Concatenate all individual MAGs into a single reference global file
cat /path/to/individual_mags/*.fasta > /path/to/concatenated_MAGs.fasta

# 2. Build a large Bowtie2 index for the concatenated MAG catalogue
bowtie2-build --large-index /path/to/concatenated_MAGs.fasta /path/to/MAGs_index -p 16
```


#### Step 2: Read Mapping and BAM Generation (Example for one sample)

Clean reads from each sample are mapped against the co-indexed MAG catalogue. The output is directly piped into Samtools to generate a sorted and indexed BAM file.

```bash
# Map paired-end reads against the MAG catalogue, sort, and output directly to a BAM file
bowtie2 \
    -x /path/to/MAGs_index \
    -1 /path/to/sample_R1.fastq.gz \
    -2 /path/to/sample_R2.fastq.gz \
    -p 16 \
| samtools sort -@ 16 -o /path/to/sample.bam

# Index the resulting BAM file
samtools index /path/to/sample.bam
```


#### Step 3: Coverage and Abundance Estimation

Finally, MAG relative abundances across all samples are calculated from the pre-mapped BAM files using **CoverM**.

### [CoverM](https://github.com/wwood/CoverM)

``` bash
# Option A
coverm genome \
  --genome-fasta-directory /path/genome_dir \
  --bam-files /path/bam_files/*.bam \
  -m relative_abundance covered_fraction \
  --threads 16 \
  --output-file /path/output_file

```

```bash
# Option B
# (Requires a genome definition file, see scripts/04_genome_def.sh )
coverm genome \
  --bam-files /path/bam_files/*.bam \
  --genome-definition genome_def_all.tsv \
  --methods relative_abundance covered_fraction \
  --threads 16 \
  --output-file /path/output_file

```



# Downstream Analyses & Data Mining

## 1. Quality Filtering of MAGs

High-quality bacterial MAGs (based on CheckM quality criteria) and NCLDV genomes (based on CheckV quality criteria) are automatically extracted from the assembly results, avoiding manual inspection of individual reports.

```bash
bash scripts/05_filter_quality_mags.sh
```



### 2. Screening of Virulence and Antibiotic Resistance Genes

This step screens the high-quality genomes for genes of interest, including virulence factors (VFDB) and antibiotic resistance genes (ARGs). The resulting gene profiles are then used to identify and select genomes harboring virulence- and resistance-associated determinants.

```bash
bash scripts/06_extract_resistance_virulence.sh
```



### 3. Data Visualization

After all upstream analyses and functional screenings have been completed, the visualization script generates the final figures used for data exploration and reporting, including intersection plots (ComplexUpset) and multi-panel figures (patchwork).

```bash
Rscript scripts/07_script_visualisation.R
```




