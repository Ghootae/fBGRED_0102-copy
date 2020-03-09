#!/bin/bash
source globals.sh

bet $NIFTI_DIR/${SUBJ}_t1_mprage.nii.gz $NIFTI_DIR/${SUBJ}_t1_mprage_brain.nii.gz -R

feat $FSF_DIR/fs_01.fsf
feat $FSF_DIR/fs_02.fsf

# Wait for two first-level analyses to finish
scripts/wait-for-feat.sh $FIRSTLEVEL_DIR/FS_01.feat
scripts/wait-for-feat.sh $FIRSTLEVEL_DIR/FS_02.feat

STANDARD_BRAIN=/usr/share/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz

pushd $SUBJECT_DIR > /dev/null
subj_dir=$(pwd)

# This function defines variables needed to render
# higher-level fsf templates.
function define_vars {
 output_dir=$1

 echo "
 <?php
 \$OUTPUT_DIR = '$output_dir';
 \$STANDARD_BRAIN = '$STANDARD_BRAIN';
 \$SUBJECTS_DIR = '$subj_dir';
 "

 echo '$runs = array();'
 cd $FIRSTLEVEL_DIR
 for runs in `ls -d FS*`; do
   echo "array_push(\$runs, '$runs');";
 done

cd ../..

 echo "
 ?>
 "
}

# Form a complete template by prepending variable
# definitions to the template,
# then render it with PHP and run FEAT on the rendered fsf file.
fsf_template=$subj_dir/$FSF_DIR/FS_secondlevel.fsf.template
fsf_file=$subj_dir/$FSF_DIR/FS_secondlevel.fsf
output_dir=$subj_dir/analysis/secondlevel/FS.gfeat
define_vars $output_dir | cat - "$fsf_template" | php > "$fsf_file"
feat "$fsf_file"

cp -R $FIRSTLEVEL_DIR/FS_01.feat/reg analysis/secondlevel/FS.gfeat
cp $FIRSTLEVEL_DIR/FS_01.feat/example_func.nii.gz analysis/secondlevel/FS.gfeat

popd > /dev/null  # return to whatever directory this script was run from