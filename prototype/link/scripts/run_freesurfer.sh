#!/bin/bash
# kimghootae@gmail.com (Dec 21, 2018)

set -e  # fail immediately on error

source globals.sh
recon-all -i data/nifti/*t1_mprage.nii.gz -s bert -sd freesurfer -all 