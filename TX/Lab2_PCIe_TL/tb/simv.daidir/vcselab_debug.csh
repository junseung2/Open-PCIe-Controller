#!/bin/csh -f

cd /home/dlwnstmd2021/UVM/4.PCIe_Controller_UVM/TX/Lab2_PCIe_TL/tb

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/usr/synopsys/vcs/R-2020.12-SP1-1/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -
