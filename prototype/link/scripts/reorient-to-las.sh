#!/bin/bash
# author: Alexa Tompary
# modified by kimghootae@gmail.com (Dec 21, 2018)

set -e  # fail immediately on error

source globals.sh
nifti_folder=$NIFTI_DIR

ORIENTATION=LAS

for bxh_file in `ls $nifti_folder/*.bxh`; do

  # reorient each scan
  temp_output=$nifti_folder/temp_reoriented
  $BXH_DIR/bxhreorient --orientation=$ORIENTATION $bxh_file $temp_output  1>/dev/null 2>/dev/null

  #delete the originals
  file_prefix=${bxh_file%%.*}
  rm -rf $file_prefix*
  #rename the reoriented outputs
  mv $nifti_folder/temp_reoriented.bxh $file_prefix.bxh
  mv $nifti_folder/temp_reoriented.nii.gz $file_prefix.nii.gz

done