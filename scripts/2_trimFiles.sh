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


## bbduk leaves too many reads with adapter sequences
## change back to AdapterRemoval
## After that step use bbduk to remove phiX and length trim

# Remove the adapters and length trim in the same step
for R1 in $(ls ${DEMUXFQ}/*1.fq.gz)
    do

    echo -e "R1 file is:\n${R1}\n"
    R2=${R1%1.fq.gz}2.fq.gz
    echo -e "R2 file is:\n${R2}\n"
    OUT1=${TRIMFQ}/$(basename ${R1})
    OUT2=${TRIMFQ}/$(basename ${R2})

    # Now run bbduk
    bbduk.sh \
        in1=${R1} \
        in2=${R2} \
        literal=${ADAPT1},${ADAPT2} \
	usejni=t \
        ktrim=r \
        trimq=20 \
        minlen=85 \
        ftr=84 \
	k=25 \
	mink=2 \
        out1=${OUT1} \
        out2=${OUT2}

    # Write an exit here just to check things        
    exit

done

# Run FastQC on the trimmed files
fastqc \
    -t ${CORES} \
    --no-extract \
    -o ${TRIMQC} \
    ${TRIMFQ}/*gz



    
