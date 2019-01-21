#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=16:00:00
#SBATCH --mem=64GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

## This script is setup to:
## 1 - Align reads to the indexed genome
## 2 - Sort & index the bam file
## 3 - Delete the unsorted bam files
## 4 - Run FastQC on the alignments

module load BWA/0.7.15-foss-2017a
module load SAMtools/0.1.19-GCC-5.3.0-binutils-2.25
module load FastQC/0.11.7

## The set parameters
THREADS=16
INDEX=/data/biorefs/reference_genomes/ensembl-release-94/oryctolagus-cuniculus/bwa/Oryctolagus_cuniculus.OryCun2.0.dna.toplevel

# Setup the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
FQDIR=${ROOTDIR}/3_demuxTrimmed/fastq
ALNDIR=${ROOTDIR}/4_aligned/bam
ALNQC=${ROOTDIR}/4_aligned/FastQC

## Make any required directories
mkdir -p ${ALNDIR}
mkdir -p ${ALNQC}

## Delete any existing files
rm ${ALNDIR}/*
rm ${ALNQC}/*

## Now setup the gc/ora files
R1=$(ls ${FQDIR}/*1.fq.gz)
echo -e "Found:\n\t${R1}"

for F1 in ${R1}
    do

    F2=${F1%1.fq.gz}2.fq.gz
    echo -e "Aligning:\n\t${F1}\n\t${F2}"
    BAM=${ALNDIR}/$(basename ${F1%1.fq.gz}bam)
    echo -e "Alignments are being written to:\n\t${BAM}"
    ## While writing to the BAM file, apply 2 filters:
    ## 1 - Remove any read with a supplementary alignment (i.e. keep unique only) using the "SA" tag
    ## 2 - Only keep reads with a mapping quality > 30 which is 1/1000 being wrong
    bwa mem -M  -t ${THREADS} ${INDEX} ${F1} ${F2} | \
        egrep -v "SA:Z:" | \
        samtools view -bS -q30 - > ${BAM} 
    
    echo -e "Sorting ${BAM}"
    samtools sort -@ ${THREADS} ${BAM} ${BAM%bam}sorted

    echo -e "Deleting the unsorted file ${BAM}"
    rm ${BAM}
    
    echo -e "Renaming and indexing the sorted file"
    mv ${BAM%bam}sorted.bam ${BAM}
    samtools index ${BAM}

done

# Run FastQC o the final set of files
fastqc \
    -t ${THREADS} \
    --no-extract \
    -o ${ALNQC} \
    ${ALNDIR}/*bam
