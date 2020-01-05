#!/bin/bash
# splits TSVs with categorical column from 2008.tsv -> $splitdir/2008/T/TEST
# runs in parallel as 1 process per TSV file

tsvdir="tsvs"       # input directory of TSV files
splitdir="singles"  # output directory (will be created)

if [[ -d $splitdir ]]; then
    read -p "delete $splitdir?"
    rm -r $splitdir
fi
mkdir $splitdir

for file in $(ls $tsvdir); do
  echo $file
  year=$(echo $file | awk '{gsub(/.tsv/,"");print}')
  mkdir -p "$splitdir/$year"/_
  for x in {A..Z}; do mkdir "$splitdir/$year"/$x; done
  awk -F'\t' -v splitdir="$splitdir/$year" 'NR > 1 {
sfn = $2
sub(/\//, "_fwd_", sfn);
sub(/\./, "_dot_", sfn);
sub(/\$/,  "_dlr_", sfn);
fname = splitdir"/"toupper(substr(sfn,1,1))"/"sfn;
print >>fname;
close(fname);
}' $tsvdir/"$file" &
done
wait
