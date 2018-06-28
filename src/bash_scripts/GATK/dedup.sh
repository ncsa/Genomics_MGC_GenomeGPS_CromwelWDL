#!/bin/bash

################################################################################################################################
#
# Deduplicate BAM using Picard MarkDuplicates. Part of the MayomicsVC Workflow.
# 
# Usage:
# dedup.sh -s <sample_name> -b <aligned.sorted.bam> -T <temp_directory> -O <output_directory> -J </path/to/java> -P </path/to/picard> -t <threads> -e </path/to/error_log>
#
################################################################################################################################

## Input and Output parameters
while getopts ":h:s:b:T:O:J:P:t:e:" OPT
do
        case ${OPT} in
                h )
                        echo "Usage:"
                        echo "  bash dedup.sh -h       Display this help message."
                        echo "  bash dedup.sh [-s sample_name] [-b <aligned.sorted.bam>] [-T <temp_directory>] [-O <output_directory>] [-J </path/to/java>] [-P </path/to/picard>] [-t threads] [-e </path/to/error_log>] "
                        ;;
		s )
			s=${OPTARG}
			echo $s
			;;
                b )
                        b=${OPTARG}
                        echo $b
                        ;;
		T )
			T=${OPTARG}
			echo $T
			;;
                O )
                        O=${OPTARG}
                        echo $O
                        ;;
		J )
			J=${OPTARG}
			echo $J
			;;
                P )
                        P=${OPTARG}
                        echo $P
                        ;;
                t )
                        t=${OPTARG}
                        echo $t
                        ;;
                e )
                        e=${OPTARG}
                        echo $e
                        ;;
        esac
done



INPUTBAM=${b}
SAMPLE=${s}
TMPDIR=${T}
OUTDIR=${O}
JAVA=${J}
PICARD=${P}
THR=${t}
ERRLOG=${e}

#set -x

## Check if input files, directories, and variables are non-zero
if [[ ! -s ${INPUTBAM} ]]
then 
        echo -e "$0 stopped at line $LINENO. \nREASON=Input sorted BAM file ${INPUTBAM} is empty." >> ${ERRLOG}
	exit 1;
fi
if [[ ! -d ${TMPDIR} ]]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Temporary directory ${TMPDIR} does not exist." >> ${ERRLOG}
        exit 1;
fi
if [[ ! -d ${OUTDIR} ]]
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Output directory ${OUTDIR} does not exist." >> ${ERRLOG}
	exit 1;
fi
if [[ ! -d ${JAVA} ]]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Java directory ${JAVA} does not exist." >> ${ERRLOG}
        exit 1;
fi
if [[ ! -d ${PICARD} ]]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Picard directory ${PICARD} does not exist." >> ${ERRLOG}
	exit 1;
fi
if (( ${THR} % 2 != 0 ))
then
	THR=$((THR-1))
fi
if [[ ! -f ${ERRLOG} ]]
then
        echo -e "$0 stopped at line $LINENO. \nREASON=Error log file ${ERRLOG} does not exist." >> ${ERRLOG}
        exit 1;
fi

## Parse filename without full path
name=$(echo "${INPUTBAM}" | sed "s/.*\///")
full=${INPUTBAM}
sample=${full##*/}
samplename=${sample%.*}
OUT=${OUTDIR}/${SAMPLE}.deduped.bam
OUTBAMIDX=${OUTDIR}/${SAMPLE}.deduped.bai
PICARDMETRICS=${OUTDIR}/${SAMPLE}.picard.metrics

## Record start time
START_TIME=`date "+%m-%d-%Y %H:%M:%S"`
echo "[PICARD] Deduplicating BAM with MarkDuplicates. ${START_TIME}"

## Picard MarkDuplicates command.
${JAVA}/java -Djava.io.tmpdir=${TMPDIR} -jar ${PICARD}/picard.jar MarkDuplicates INPUT=${INPUTBAM} OUTPUT=${OUT} TMP_DIR=${TMPDIR} METRICS_FILE=${PICARDMETRICS} ASSUME_SORTED=true MAX_RECORDS_IN_RAM=null CREATE_INDEX=true &
wait
echo "[PICARD] Deduplicated BAM found at ${OUT}."

## Record end of the program execution
END_TIME=`date "+%m-%d-%Y %H:%M:%S"`

## Open read permissions to the user group
chmod g+r ${OUT}
chmod g+r ${OUTBAMIDX}
chmod g+r ${PICARDMETRICS}

echo "[PICARD] Finished. ${END_TIME}"
