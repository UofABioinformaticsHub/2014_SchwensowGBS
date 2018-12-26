#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=8:00:00
#SBATCH --mem=64GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

module load BBMap/36.62-intel-2017.01-Java-1.8.0_121
module load FastQC/0.11.7

CORES=16
ADAPT1=AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCTTG
ADAPT2=AGATCGGAAGAGCGGCGTGTAGGGAAAGAAGGTAGATCTCGGTGGTCGCCGTATCATT

# Define the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
DEMUXFQ=${ROOTDIR}/1_demux/fastq
TRIMFQ=${ROOTDIR}/2_trimmed/fastq
TRIMQC=${ROOTDIR}/2_trimmed/FastQC

# Make the directories
mkdir -p ${TRIMFQ}
mkdir -p ${TRIMQC}

# Remove the adapters and length trim in the same step
for R1 in $(ls ${DEMUXFQ}/*1.fq.gz)
    do

    echo -e "R1 file is:\n${R1}\n"
    R2=${R1%1.fq.gz}.2.fq.gz
    echo -e "R2 file is:\n${R2}\n"

    # Now run bbduk
    bbduk.sh \
        reads=1000 \
        in1=${DEMUXFQ}/${R1} \
        in2=${DEMUXFQ}/${R2} \
        literal=${ADAPT1},${ADAPT2} \
        ktrim=r \
        trimq=20 \
        minlen=85 \
        ftr=85 \
        out1=${TRIMFQ}/${R1} \
        out2=${TRIMFQ}/${R2}

    # Write an exit here just to check things        
    exit
done

# Run FastQC on the trimmed files
fastqc \
    -t ${CORES} \
    --no-extract \
    -o ${TRIMQC} \
    ${TRIMFQ}/*gz



    