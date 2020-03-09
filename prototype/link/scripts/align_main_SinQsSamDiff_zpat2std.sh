#!/bin/bash
# author: GTK
# alignning each cope file to standard space

set -e

source globals.sh
for run in {1..4}; do
	epiDir=$FIRSTLEVEL_DIR/main_SinQsSamDiff_0$run.feat
	dstDir=$epiDir/stats
	for contrast in {1..6}; do
		input=$dstDir/zstat$contrast
		output=$dstDir/zstat${contrast}_standard
		ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain
		xMat=$epiDir/reg/example_func2standard.mat

		flirt -in $input -ref $ref -out $output -applyxfm -init $xMat -interp trilinear
		gunzip ${output}.nii.gz
	done
done