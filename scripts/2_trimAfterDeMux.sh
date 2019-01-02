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

module load FASTX-Toolkit/0.0.14-foss-2015b
module load FastQC/0.11.7

# Setup the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
MAINSOURCE=${ROOTDIR}/2_demux/fastq
TFSOURCE=${ROOTDIR}/fastq/samples/tf
DEST=${ROOTDIR}/3_demuxTrimmed/fastq
DESTQC=${ROOTDIR}/3_demuxTrimmed/FastQC

## Make any required directories
mkdir -p ${DEST}
mkdir -p ${DESTQC}

## Now setup the gc/ora files
R1=$(ls ${MAINSOURCE}/*1.fq.gz)
echo -e "Found:\n\t${R1}"

for F1 in ${R1}
    do

    F2=${F1%1.fq.gz}2.fq.gz
    echo "Moving ${F1}"
    cp ${F1} ${DEST}/$(basename ${F1})

    echo "Trimming ${F2}"
    zcat ${F2} | \
      fastx_trimmer -f 6 | \
      gzip > ${DEST}/$(basename ${F2})

done

## And use the same strategy for the Turretfield files
## This should be in a PE fashion, but given the TF files have sequence
## headers which are incompatible with bwa, this can be changed by running on 
## stdout/stdin
FQ=$(ls ${TFSOURCE}/*.fq.gz)
echo -e "Found:\n\t${FQ}"

for F in ${FQ}
    do
        
    O=${DEST}/$(basename ${F})

    echo -e "Trimming: ${F}"
    zcat ${F} | \
        fastx_trimmer -f 6  | \
        sed -r 's|([^_]+)_([0-9]+)_([0-9]+)_([0-9]+)_([12])|\1:\2:\3:\4/\5|g' | \
        gzip > ${O}
    
done

# Run FastQC o the final set of files
fastqc \
    -t 1 \
    --no-extract \
    -o ${DESTQC} \
    ${DEST}/*fq.gz
