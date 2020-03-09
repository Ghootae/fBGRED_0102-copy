#!/bin/bash
# author: mgsimon@princeton.edu
# this script sets up global variables for the analysis of the current subject

set -e # stop immediately when an error occurs

# add necessary directories to the system path
export BXH_DIR=~/fMRI_analysis/packages/bxh_xcede_tools-1.11.14-MacOSX.i686/bin
export MAGICK_HOME=/jukebox/ntb/packages/ImageMagick-6.5.9-9
export BIAC_HOME=/jukebox/ntb/packages/BIAC_matlab/mr
export DICOM_DIR=~/fMRI_analysis/dicom

source scripts/subject_id.sh  # this loads the variable SUBJ
PROJ_DIR=../..
SUBJECT_DIR=$PROJ_DIR/subjects/$SUBJ

RUNORDER_FILE=run-order.txt

DATA_DIR=data
SCRIPT_DIR=scripts
FSF_DIR=fsf
DICOM_ARCHIVE=data/raw.tar.gz
NIFTI_DIR=data/nifti
QA_DIR=data/qa
BEHAVIORAL_DATA_DIR=data/behavioral
FIRSTLEVEL_DIR=analysis/firstlevel
SECONDLEVEL_DIR=analysis/secondlevel
EV_DIR=design
BEHAVIORAL_OUTPUT_DIR=output/behavioral

# Fill in below variables to fit your roi analysis -- all are used in roi.sh or scripts called within it
ROI_COORDS_FILE=design/roi.txt
LOCALIZER_DIR=analysis/secondlevel/FS.gfeat
ROI_DIR=results/roi
ROI_KERNEL_TYPE=sphere
ROI_KERNEL_SIZE=4

# ROI related
ROI_DIR=$PROJ_DIR/ROIs

# freesurfer output
FREESURF_DIR=freesurfer