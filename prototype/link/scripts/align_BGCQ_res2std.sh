#!/bin/bash
# author: GTK
# alignning each residual epis (bg-center & quadrant) to standard space

set -e

source globals.sh
for run in {1..4}; do
	#bg-center
	epiDir=$FIRSTLEVEL_DIR/bgc_0$run.feat
	dstDir=$epiDir/stats
	input=$dstDir/res4d
	output=$dstDir/res4d2standard
	ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain
	xMat=$epiDir/reg/example_func2standard.mat

	flirt -in $input -ref $ref -out $output -applyxfm -init $xMat -interp trilinear

	#bg-quad
	epiDir=$FIRSTLEVEL_DIR/bgq_0$run.feat
	dstDir=$epiDir/stats
	input=$dstDir/res4d
	output=$dstDir/res4d2standard
	ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain
	xMat=$epiDir/reg/example_func2standard.mat

	flirt -in $input -ref $ref -out $output -applyxfm -init $xMat -interp trilinear
done