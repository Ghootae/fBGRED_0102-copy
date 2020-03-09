#!/bin/bash
# author: Alexa Tompary
# modified by kimghootae@gmail.com (Dec 21, 2018)

set -e  # fail immediately on error

source globals.sh

mri_convert $FREESURF_DIR/bert/mri/brainmask.mgz $NIFTI_DIR/freesurfer_t1_brain_mprage.nii
gzip $NIFTI_DIR/freesurfer_t1_brain_mprage.nii
fslreorient2std $NIFTI_DIR/freesurfer_t1_brain_mprage.nii.gz $NIFTI_DIR/freesurfer_t1_brain_mprage.nii.gz

mri_convert $FREESURF_DIR/bert/mri/aseg.mgz $NIFTI_DIR/freesurfer_aseg.nii
gzip $NIFTI_DIR/freesurfer_aseg.nii
fslreorient2std $NIFTI_DIR/freesurfer_aseg.nii.gz $NIFTI_DIR/freesurfer_aseg.nii.gz

#segmentation
#1. white matter
fslmaths $NIFTI_DIR/freesurfer_aseg -thr 41 -uthr 41 $NIFTI_DIR/freesurfer_aseg_rWhite
fslmaths $NIFTI_DIR/freesurfer_aseg -thr 2 -uthr 2 $NIFTI_DIR/freesurfer_aseg_lWhite
fslmaths $NIFTI_DIR/freesurfer_aseg_rWhite -add $NIFTI_DIR/freesurfer_aseg_lWhite $NIFTI_DIR/freesurfer_aseg_white
fslmaths $NIFTI_DIR/freesurfer_aseg_white -bin $NIFTI_DIR/freesurfer_aseg_white
rm -rf $NIFTI_DIR/freesurfer_aseg_rWhite.nii.gz
rm -rf $NIFTI_DIR/freesurfer_aseg_lWhite.nii.gz

#2. ventricals
fslmaths $NIFTI_DIR/freesurfer_aseg -thr 43 -uthr 43 $NIFTI_DIR/freesurfer_aseg_rVent
fslmaths $NIFTI_DIR/freesurfer_aseg -thr 4 -uthr 4 $NIFTI_DIR/freesurfer_aseg_lVent
fslmaths $NIFTI_DIR/freesurfer_aseg_rVent -add $NIFTI_DIR/freesurfer_aseg_lVent $NIFTI_DIR/freesurfer_aseg_vent
fslmaths $NIFTI_DIR/freesurfer_aseg_vent -bin $NIFTI_DIR/freesurfer_aseg_vent
rm -rf $NIFTI_DIR/freesurfer_aseg_rVent.nii.gz
rm -rf $NIFTI_DIR/freesurfer_aseg_lVent.nii.gz

# whole brain mask
fslmaths $NIFTI_DIR/freesurfer_aseg -bin $NIFTI_DIR/freesurfer_whole_mask
