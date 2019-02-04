#!/bin/bash

## This script is to be run after demultiplexing, trimming and aligning using bwa
## Reads were not trimed to a fixed length, going by comments made by Julian Catchen
## on the Google Groups page

## This is now set to run locally using stacks-2.3b due to disruptions on the phoenix HPC

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
    --samples ${BAMDIR} \
    --popmap ${POPMAP} \
    -T ${CORES} \
    -o ${OUTDIR} \
    -X "populations:-p 2" \
    -X "populations:-r 0.75" \
    -X "populations:--min_maf 0.05" \
    -X "populations:-e pstI" \
    -X "populations:--merge_sites" \
    -X "populations:--hwe" \
    -X "populations:--fstats" \
    -X "populations:--fst_correction p_value" \
    -X "populations:-k" \
    -X "populations:--ordered_export" \
    -X "populations:--genepop" \
    -X "populations:--vcf" \
    -X "populations:--plink" 

## Now tidy the output
mkdir -p ${OUTDIR}/genepop
mkdir -p ${OUTDIR}/plink
mkdir -p ${OUTDIR}/stacks
mkdir -p ${OUTDIR}/vcf
mkdir -p ${OUTDIR}/logs
mv ${OUTDIR}/?*plink* ${OUTDIR}/plink
mv ${OUTDIR}/?*genepop ${OUTDIR}/genepop
mv ${OUTDIR}/*log ${OUTDIR}/logs
mv ${OUTDIR}/?*vcf ${OUTDIR}/vcf
mv ${OUTDIR}/populations* ${OUTDIR}/stacks
mv ${OUTDIR}/gstacks* ${OUTDIR}/stacks
mv ${OUTDIR}/catalog* ${OUTDIR}/stacks

# Compress where appropriate
gzip ${OUTDIR}/genepop/*
gzip ${OUTDIR}/vcf/*
gzip ${OUTDIR}/stacks/*tsv
