#!/bin/bash -f

export mvau_root=`pwd | sed "s?/Doc/natural_docs??"`
export out_dir=$mvau_root/docs
export src_dir=$mvau_root/proj/src
rm -rf $out_dir
sed "s?MVAU_ROOT?$mvau_root?g" $mvau_root/Doc/natural_docs/Proj/MVAU_Project.txt > $mvau_root/Doc/natural_docs/Proj/Project.txt
cp $mvau_root/Doc/natural_docs/Proj/MVAU_Comments.txt $mvau_root/Doc/natural_docs/Proj/Comments.txt
cp $mvau_root/Doc/natural_docs/Proj/MVAU_Languages.txt $mvau_root/Doc/natural_docs/Proj/Languages.txt
chmod 666 $mvau_root/Doc/natural_docs/Proj/Languages.txt
chmod 666 $mvau_root/Doc/natural_docs/Proj/Project.txt
chmod 666 $mvau_root/Doc/natural_docs/Proj/Comments.txt

mkdir -p $out_dir
mono $WITH_ND -do -ro -o FramedHTML $out_dir -p Proj/

