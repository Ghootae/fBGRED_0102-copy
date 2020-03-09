#!/bin/bash
# author: mgsimon@princeton.edu
# modified by kimghootae@gmail.com on Dec 21, 2018
# dicoms are directly converted into nifti

set -e  # fail immediately on error

source globals.sh
run_order_file=run-order.txt
output_dir=$NIFTI_DIR
curr_dir=$PWD
output_prefix=$SUBJ

ORIENTATION=LAS
PREFIX=scan
ERROR_FLAG=ERROR_RUN
UNEXPECTED_NUMBER_OF_SCANS=1
UNEXPECTED_NUMBER_OF_TRS=2
#DICOMLIST='0002 0003 0005 0006 0007 0008 0009 0010 0012 0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025'
DICOMLIST='0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019 0020 0021 0022'


if [ -d "$output_dir" ]; then
  read -t 5 -p "data has already been converted. overwrite? (y/N) " overwrite || true
  if [ "$overwrite" != "y" ]; then exit; fi
  rm -rf $output_dir
fi

mkdir -p $output_dir

temp_output_dir=$(mktemp -d -t tmp.XXXXXX)
#to aviod ARG_MAX problem
cd $DICOM_DIR/$SUBJ
t=0
for i in $DICOMLIST
do
  let "t += 1"
$BXH_DIR/dicom2bxh *KBRI.$i*.IMA $temp_output_dir/$PREFIX-$t.bxh 1>/dev/null 2>/dev/null
done
cd $curr_dir

# strip blank lines and comments from run order file
stripped_run_order_file=$(mktemp -t tmp.XXXXX)
sed '/^$/d;/^#/d;s/#.*//' $run_order_file > $stripped_run_order_file

# check that the actual number of scans retrieved matches what's expected, and
# exit with an error if not.
num_actual_scans=$(find $temp_output_dir/*.bxh -maxdepth 1 -type f | wc -l)
num_expected_scans=$(wc -l < $stripped_run_order_file)
if [ $num_actual_scans != $num_expected_scans ]; then
  echo "found $num_actual_scans scans, but $num_expected_scans were described in $run_order_file. check that you're listing enough scans for your circle localizer, etc... because those may convert as more than one scan." >/dev/stderr
  exit $UNEXPECTED_NUMBER_OF_SCANS
fi


# convert all scans to gzipped nifti format, and if the run order file indicates
# how many TRs are expected in a particular scan, check that there are actually
# that many TRs, and exit with an error if not.
number=0
# the sed magic here strips out comments
cat $stripped_run_order_file | while read name num_expected_trs; do
  let "number += 1"
  if [ $name == $ERROR_FLAG ]; then
    continue
  fi

  # convert the scan
  niigz_file_prefix=$temp_output_dir/${output_prefix}_$name
  $BXH_DIR/bxh2analyze --analyzetypes --niigz --niftihdr -s "${temp_output_dir}/${PREFIX}-$number.bxh" $niigz_file_prefix 1>/dev/null 2>/dev/null

  if [ -n "$num_expected_trs" ]; then
    num_actual_trs=$(fslnvols ${niigz_file_prefix}.nii.gz)
    if [ $num_expected_trs -ne $num_actual_trs ]; then
      echo "$name has $num_actual_trs TRs--expected $num_expected_trs" >/dev/stderr
      exit $UNEXPECTED_NUMBER_OF_TRS
    fi
  fi
done

rm -f $temp_output_dir/$PREFIX-*.bxh
rm -f $temp_output_dir/$PREFIX-*.dat
rm -f $stripped_run_order_file
mv $temp_output_dir/* $output_dir

