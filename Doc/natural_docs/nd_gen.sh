#!/bin/bash -f

export mvau_root=`pwd | sed "s?/Doc/natural_docs??"`
export out_dir=$mvau_root/Doc/api
export src_dir=$mvau_root/proj/src
rm -rf $out_dir
sed "s?MVAU_ROOT?$mvau_root?g" $mvau_root/Doc/natural_docs/Proj/MVAU_Menu.txt > $mvau_root/Doc/natural_docs/Proj/Menu.txt
cp $mvau_root/Doc/natural_docs/Proj/MVAU_Topics.txt $mvau_root/Doc/natural_docs/Proj/Topics.txt
cp $mvau_root/Doc/natural_docs/Proj/MVAU_Languages.txt $mvau_root/Doc/natural_docs/Proj/Languages.txt
chmod 666 $mvau_root/Doc/natural_docs/Proj/Languages.txt
chmod 666 $mvau_root/Doc/natural_docs/Proj/Menu.txt     
chmod 666 $mvau_root/Doc/natural_docs/Proj/Topics.txt   

mkdir -p $out_dir
perl $WITH_ND -do -ro -i $src_dir -o FramedHTML $out_dir -p Proj/

