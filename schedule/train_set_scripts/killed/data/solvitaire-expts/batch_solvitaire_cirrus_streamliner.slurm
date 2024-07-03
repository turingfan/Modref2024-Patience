#!/bin/bash
#
#SBATCH --job-name=patience
#SBATCH --output=logs/patience_%A_%a.out
#SBATCH --error=logs/patience_%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ian.gent@st-andrews.ac.uk
#SBATCH --account=sc122
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=standard
#SBATCH --qos=standard
##
# for testing 
#SBATCH --time=48:00:00

WORK="/work/sc122/sc122/shared"

PROJ_DIR=$WORK/solvitaire-expts
SR_HOME=$WORK/savilerow-main
SOFT_BIN=$WORK/../shared

export PATH=$SOFT_BIN:$SR_HOME:$PATH

#module load java
#module load gcc
module load gnu-parallel

START=$1
END=$2
CORES=$3
GAME=$4
TIMEOUT=$5
STREAMLINER=$6
DIR=$7
NAME=$8

mkdir -p $PROJ_DIR/$DIR

./solvability-start.sh $START $END $CORES 30G "solvitaire --type $GAME --timeout $TIMEOUT --str $STREAMLINER" $PROJ_DIR/$DIR/$NAME-$GAME-$TIMEOUT-$STREAMLINER-

#LINE=$(tail -n+${SLURM_ARRAY_TASK_ID} ${CHUNKNAME} |head -1)
#srun -u -n1 bash -c "$LINE"
#bash -c "$LINE"

# sbatch batch_cirrus.slurm lines.txt

