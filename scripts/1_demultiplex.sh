#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=4:00:00
#SBATCH --mem=32GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

module load sabre/1.0-foss-2016b
module load FastQC/0.11.7

CORES=16

# Setup the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
RAWFQ=${ROOTDIR}/0_rawData/fastq
RAWQC=${ROOTDIR}/0_rawData/FastQC
DEMUXFQ=${ROOTDIR}/1_demux/fastq
DEMUXQC=${ROOTDIR}/1_demux/FastQC

# Make directories for FastQC. The others already exist
mkdir -p ${RAWQC}
mkdir -p ${DEMUXQC}

# Get the barcode files
BC=$(ls ${ROOTDIR}/barcodes/)

echo -e "Found barcode files \n${BC}\n"

# Demultiplex each library
# Note the the output path is hardcoded into the barcodes file
for f in ${BC}
  do

    LIB1=${RAWFQ}/${f%.barcodes}_1.fq.gz
    LIB2=${RAWFQ}/${f%.barcodes}_2.fq.gz
    echo "R1 reads will be in ${LIB1}"
    echo "R2 reads will be in ${LIB2}"

    echo "Running sabre on ${f}"
    sabre pe \
      -m 1 \
      -f ${LIB1} \
      -r ${LIB2} \
      -b ${ROOTDIR}/barcodes/${f} \
      -u ${LIB1%_1.fq.gz}_unknown_1.fq \
      -w ${LIB2%_2.fq.gz}_unknown_2.fq

  done

gzip ${DEMUXFQ}/*fq

# Run FastQC on the demultiplexed files
fastqc \
  -t ${CORES} \
  --no-extract \
  -o ${DEMUXQC} \
  ${DEMUXFQ}/*gz

# And also make sure it's been run on the raw files
fastqc \
  -t ${CORES} \
  --no-extract \
  -o ${RAWQC} \
  ${RAWFQ}/*gz
