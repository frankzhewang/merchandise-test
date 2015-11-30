#!/bin/sh
if [ $# -eq 0 ]
then
  echo "Please specify output path."
  exit 1
fi
while read id a m gm; do
  bsub -M8 -q hour -g /gendemand -J "demand${id}" \
    matlab -nodisplay -nosplash -singleCompThread \
    -r "../src/job_gen_demand('${id}', $a, $m, $gm, '${1}')" \
    -logfile "../log/demand/${id}.log"
done < params-demand.txt
