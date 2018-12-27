#!/bin/bash
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --time=12:00:00
#SBATCH --mem=32GB
#SBATCH -o /data/biohub/2014_SchwensowGBS/slurm/%x_%j.out
#SBATCH -e /data/biohub/2014_SchwensowGBS/slurm/%x_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=stephen.pederson@adelaide.edu.au

module load AdapterRemoval/2.2.1-foss-2016b
module load BBMap/36.62-intel-2017.01-Java-1.8.0_121
module load sabre/1.0-foss-2016b
module load FastQC/0.11.7

CORES=16

# Setup the paths
ROOTDIR=/data/biohub/2014_SchwensowGBS
RAWFQ=${ROOTDIR}/0_rawData/fastq
TRIMFQ=${ROOTDIR}/1_trimmed/fastq
TRIMQC=${ROOTDIR}/1_trimmed/FastQC
TRIMLOG=${ROOTDIR}/1_trimmed/logs
DEMUXFQ=${ROOTDIR}/2_demux/fastq
DEMUXQC=${ROOTDIR}/2_demux/FastQC

# Make directories 
mkdir -p ${TRIMFQ}
mkdir -p ${TRIMQC}
mkdir -p ${TRIMLOG}
mkdir -p ${DEMUXFQ}
mkdir -p ${DEMUXQC}

# Get the barcode files
BC=$(ls ${ROOTDIR}/barcodes/)

echo -e "Found barcode files \n${BC}\n"

# In this loop, for each library:
# 1 - Identify the adapters
# 2 - Remove the adapters
# 3 - Demultiplex
for f in ${BC}
  do

    LIB1=${RAWFQ}/${f%.barcodes}_1.fq.gz
    LIB2=${RAWFQ}/${f%.barcodes}_2.fq.gz
    echo "R1 reads will be in ${LIB1}"
    echo "R2 reads will be in ${LIB2}"
    
    # First detect the adapters
    bbmerge.sh \
        in1=${LIB1} \
        in2=${LIB2} \
        outa=adapters.fa

    # Remove the adapters, discarding any < 70bp
    # Final read lengths will be determined later
    TRIM1=${TRIMFQ}/$(basename ${LIB1})
    TRIM2=${TRIMFQ}/$(basename ${LIB2})
    echo -e "R1 Trimmed output will be in:\n\t${TRIM1}"
    echo -e "R2 Trimmed output will be in:\n\t${TRIM2}"
    A1=$(sed -n '2p' adapters.fa)
    A2=$(sed -n '4p' adapters.fa)
    echo -e "Adapters read from adapters.fa as:\nAdapter1\t${A1}\nAdapter2\t{A2}"
    BNAME=${TRIMFQ}/${f%barcodes}
    AdapterRemoval \
        --gzip \
        --qualitybase 64 \
        --trimqualities \
        --minquality 20 \
        --minlength 70 \
        --basename ${BNAME} \
        --settings ${TRIMLOG}/${f%barcodes}_adapterRemoval.log \
        --threads ${CORES} \
        --adapter1 ${A1} \
        --adapter2 ${A2} \
        --output1 ${TRIM1} \
        --output2 ${TRIM2} \
        --file1 ${LIB1} \
        --file2 ${LIB2}

    # Demultiplex each library
    # Note the the output path is hardcoded into the barcodes file
    echo "Running sabre on ${f}"
    sabre pe \
      -m 1 \
      -f ${TRIM1} \
      -r ${TRIM2} \
      -b ${ROOTDIR}/barcodes/${f} \
      -u ${LIB1%_1.fq.gz}_unknown_1.fq \
      -w ${LIB2%_2.fq.gz}_unknown_2.fq

  done

# Compress all demultiplexed fastq files
gzip ${DEMUXFQ}/*fq

# Run FastQC on the trimmed files
fastqc \
    -t ${CORES} \
    --no-extract \
    -o ${TRIMQC} \
    ${TRIMFQ}/*gz

# Run FastQC on the demultiplexed files
fastqc \
    -t ${CORES} \
    --no-extract \
    -o ${DEMUXQC} \
    ${DEMUXFQ}/*gz
