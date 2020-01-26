# Comparison of 1996 and 2012 Rabbit Populations

This is best viewed using the [github pages site](https://uofabioinformaticshub.github.io/2014_SchwensowGBS/)

## Description

This is the repository for all code used in the analysis of the GBS dataset used in the comparison between rabbits from the 1996 (n = 55) and 2012 (n = 53) populations from the Gum Creek / Oraparrina region of South Australia.

In addition, some samples from [a previous analysis of the Turretfield rabbit population](https://onlinelibrary.wiley.com/doi/abs/10.1111/mec.14228), sampled in 2010 were included as an outgroup.

## Data processing scripts

All bash scripts are available in the folder [scripts](scripts) with four main process being undertaken: 1) [Demultiplexing](scripts/1_demultiplex.sh); 2) [Read Trimming](scripts/2_trimAfterDeMux.sh); 3) [Read Alignment](scripts/3_alignTrimmed.sh), and 4) [Running the Stacks Pipeline](scripts/4_stacksPipeline.sh)

## Analytic scripts

The bulk of the data analysis was performed in R with code available inthe following locations:

1. [Checking the results of Demultiplexing](R/01_checkDemux)
2. [Checking the quality of alignments](R/02_checkAlignments)
3. [Filtering of SNPs](R/03_SNPFiltering)
4. [Analysis of filtered SNPs](R/04_SNP_Analysis)
5. [Assessment of linkage](R/05_Linkage_Analysis)
6. [Simulation of Genetic Drift](R/06_GeneticDrift)

In addition, a [supplementary analysis](S1_FLK) was performed using the [FLK algorithm](https://www.genetics.org/content/186/1/241.long), however these results were not included in the submitted paper.