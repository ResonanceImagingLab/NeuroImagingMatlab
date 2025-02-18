#!/bin/bash

DATA_DIR=/user/data/study/
RAW_DIR=/user/data/raw/ # location for your read-only backup

declare -a SUBJECT=('hc01' 'hc02' 'hc03' 'hc04' 'hc05')
declare -a EXAMID=('exam_19248' 'exam_19250' 'exam_19258' 'exam_19266' 'exam_19271')

ITER=0
for i in "${SUBJECT[@]}"
do
    cd $DATA_DIR/$i/
    mkdir $DATA_DIR/$i/ses01
    cp  $DATA_DIR/$i/${SUBID[$ITER]}.tgz  $DATA_DIR/$i/ses01/${SUBID[$ITER]}.tgz

    ITER=$(expr $ITER + 1)
done