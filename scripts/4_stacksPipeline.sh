#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=24:00:00
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
ref_map.pl \
    -d \
    -b 1 \
    -T ${CORES} \
    -S \
    -m 10 \
    -O ${POPMAP} \
    -o ${OUTDIR} \
    -X "populations:--genepop" \
    -X "populations:--vcf" \
    -X "populations:--plink" \
    -X "populations:--beagle" \
    -X "populations:-p 3" \
    -X "populations:-r 0.75" \
    -X "populations:-f p_value" \
    -X "populations:-k" \
    --samples ${BAMDIR}

