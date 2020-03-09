#!/bin/bash
# author: GTK
# getting FFA and PPA rois (note that the rois are already based on the standard space)

set -e

source globals.sh
CURR_DIR=$SECONDLEVEL_DIR/FS.gfeat

value=`cat $CURR_DIR/rFFA.txt`
fslmaths $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -mul 0 -add 1 -roi $value 0 1 $CURR_DIR/tempPoint -odt float
fslmaths $CURR_DIR/tempPoint -kernel $ROI_KERNEL_TYPE $ROI_KERNEL_SIZE -fmean $CURR_DIR/ffaSphere -odt float
fslmaths $CURR_DIR/ffaSphere -bin $CURR_DIR/ffaSphere
fslmaths $CURR_DIR/tempPoint -kernel gauss 3 -fmean $CURR_DIR/ffaSphere_gauss -odt float
fslmaths $CURR_DIR/ffaSphere_gauss -thr 0.002 $CURR_DIR/ffaSphere_gauss
fslmaths $CURR_DIR/ffaSphere_gauss -mul 53.1533 $CURR_DIR/ffaSphere_gauss
rm -rf $CURR_DIR/tempPoint.nii.gz

value=`cat $CURR_DIR/rPPA.txt`
fslmaths $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -mul 0 -add 1 -roi $value 0 1 $CURR_DIR/tempPoint -odt float
fslmaths $CURR_DIR/tempPoint -kernel $ROI_KERNEL_TYPE $ROI_KERNEL_SIZE -fmean $CURR_DIR/ppaSphere -odt float
fslmaths $CURR_DIR/ppaSphere -bin $CURR_DIR/ppaSphere
fslmaths $CURR_DIR/tempPoint -kernel gauss 3 -fmean $CURR_DIR/ppaSphere_gauss -odt float
fslmaths $CURR_DIR/ppaSphere_gauss -thr 0.002 $CURR_DIR/ppaSphere_gauss
fslmaths $CURR_DIR/ppaSphere_gauss -mul 53.1533 $CURR_DIR/ppaSphere_gauss
rm -rf $CURR_DIR/tempPoint.nii.gz
