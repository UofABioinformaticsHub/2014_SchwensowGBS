#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=24:00:00
#SBATCH --mem=4GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

## This script is setup to:
## 1 - Move R1 files from 2_demux to 3_demuxTrimmed
## 2 - Trim the first 5 bases (i.e. TGCAG) from R2 files
## 3 - Trim the fist 5 bases from Turretfield samples in both R1 & R2

module load BWA/0.7.15-foss-2017a
module load FastQC/0.11.7

# Setup the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
FQDIR=${ROOTDIR}/3_demuxTrimmed/fastq
ALNDIR=${ROOTDIR}/4_aligned/bam
ALNQC=${ROOTDIR}/4_aligned/FastQC

## Make any required directories
mkdir -p ${ALNDIR}
mkdir -p ${ALNQC}

## Now setup the gc/ora files
R1=$(ls ${MAINSOURCE}/*1.fq.gz)
echo -e "Found:\n\t${R1}"

for F1 in ${R1}
    do

    F2=${F1%1.fq.gz}2.fq.gz
    echo -e "Aligning:\n\t${F1}\n\t${F2}"


done

exit

## Index all the files

# Run FastQC o the final set of files
fastqc \
    -t 1 \
    --no-extract \
    -o ${ALNQC} \
    ${ALNDIR}/*bam
