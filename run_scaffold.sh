#!/bin/bash
# author: kimghootae@gmail.com on Dec 28, 2018
# run scaffold for every subject

set -e  # fail immediately on error

for subj in `ls subjects/`; do
  ./scaffold $subj
done
