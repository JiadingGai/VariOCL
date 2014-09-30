#!/bin/bash

GAIDIR=/home/jiading/Desktop/projects/socl-llvm/precompiler/
FileCount=1
for afile in `ls opencvall/*.cl`
do
 
  echo "\n\n=========================== [$FileCount. $afile] =================================="

  $GAIDIR/gaibuild_kernel.sh $afile kbin 4 $afile.opt

  FileCount=$(($FileCount + 1))
done
