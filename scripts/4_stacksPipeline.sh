#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=12:00:00
#SBATCH --mem=64GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

## This script is to be run after demultiplexing, trimming and aligning using bwa
## Reads were not trimed to a fixed length, going by comments made by Julian Catchen
## on the Google Groups page

## Load stacks
module load Stacks/1.40-GCC-5.3.0-binutils-2.25

## Define existing folders and variables
CORES=16
PROJROOT=/data/biohub/2014_SchwensowGBS
BAMDIR=${PROJROOT}/4_aligned/bam
POPMAP=${PROJROOT}/pop_map

## Define the output folder
OUTDIR=${PROJROOT}/5_stacks
mkdir -p ${OUTDIR}

## Collect the list of files
FILES=$(ls ${BAMDIR}/*bam)

## Now run the ref_map pipeline
## This is set to merge overlapping sites from separate 'stacks' and order the output
ref_map.pl \
    -b 1 \
    -T ${CORES} \
    -S \
    -m 5 \
    -O ${POPMAP} \
    -o ${OUTDIR} \
    -X "populations:--genepop" \
    -X "populations:--vcf" \
    -X "populations:--plink" \
    -X "populations:-p 2" \
    -X "populations:-r 0.75" \
    -X "populations:-f p_value" \
    -X "populations:-k" \
    -X "populations:--merge-sites" \
    -X "populations:--ordered-export" \
    --samples ${BAMDIR}

## Now tidy the output from it's ridiculous form
mkdir -p ${OUTDIR}/genepop
mkdir -p ${OUTDIR}/plink
mkdir -p ${OUTDIR}/stacks
mkdir -p ${OUTDIR}/vcf
mkdir -p ${OUTDIR}/logs
mv ${OUTDIR}/*plink* ${OUTDIR}/plink
mv ${OUTDIR}/*genepop ${OUTDIR}/genepop
mv ${OUTDIR}/*log ${OUTDIR}/logs
mv ${OUTDIR}/*vcf ${OUTDIR}/vcf
mv ${OUTDIR}/batch* ${OUTDIR}/stacks
mv ${OUTDIR}/*tsv.gz ${OUTDIR}/stacks

# Compress where appropriate
gzip ${OUTDIR}/stacks/*tsv
gzip ${OUTDIR}/genepop/*
gzip ${OUTDIR}/vcf/*
