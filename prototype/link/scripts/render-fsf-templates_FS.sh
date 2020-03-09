#!/bin/bash
#
# render-fsf-templates.sh fills in templated fsf files so FEAT can use them
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs
#
# refer to the secondlevel neuropipe tutorial to see an example of how
# to use this script

set -e

source globals.sh

 
function render_firstlevel {
  fsf_template=$1
  output_dir=$2
  standard_brain=$3
  data_file_prefix=$4
  initial_highres_file=$5
  highres_file=$6
  ev_dir1=$7
  ev_dir2=$8
  ev_dir=$9

  subject_dir=$(pwd)

  # note: the following replacements put absolute paths into the fsf file. this
  #       is necessary because FEAT changes directories internally
  cat $fsf_template \
    | sed "s:<?= \$OUTPUT_DIR ?>:$subject_dir/$output_dir:g" \
    | sed "s:<?= \$STANDARD_BRAIN ?>:$standard_brain:g" \
    | sed "s:<?= \$DATA_FILE_PREFIX ?>:$subject_dir/$data_file_prefix:g" \
    | sed "s:<?= \$INITIAL_HIGHRES_FILE ?>:$subject_dir/$initial_highres_file:g" \
    | sed "s:<?= \$HIGHRES_FILE ?>:$subject_dir/$highres_file:g" \
    | sed "s:<?= \$EV1 ?>:$subject_dir/$ev_dir1:g" \
    | sed "s:<?= \$EV2 ?>:$subject_dir/$ev_dir2:g" \
    | sed "s:<?= \$EV_DIR ?>:$subject_dir/$ev_dir:g" 

}

render_firstlevel $FSF_DIR/FS.fsf.template \
                  $FIRSTLEVEL_DIR/FS_01.feat \
                  $FSLDIR/data/standard/MNI152_T1_2mm_brain \
                  $NIFTI_DIR/${SUBJ}_fs01 \
                  $NIFTI_DIR/${SUBJ}_t1_flash01_brain.nii.gz \
                  $NIFTI_DIR/${SUBJ}_t1_mprage_brain.nii.gz \
                  . \
                  . \
                  $EV_DIR/FS_run1 \
                  > $FSF_DIR/fs_01.fsf

render_firstlevel $FSF_DIR/FS.fsf.template \
                  $FIRSTLEVEL_DIR/FS_02.feat \
                  $FSLDIR/data/standard/MNI152_T1_2mm_brain \
                  $NIFTI_DIR/${SUBJ}_fs02 \
                  $NIFTI_DIR/${SUBJ}_t1_flash01_brain.nii.gz \
                  $NIFTI_DIR/${SUBJ}_t1_mprage_brain.nii.gz \
                  . \
                  . \
                  $EV_DIR/FS_run2 \
                  > $FSF_DIR/fs_02.fsf