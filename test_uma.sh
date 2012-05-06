#!/bin/bash

adx=0
bdx=0
cdx=0

cdx_e()
{
cdx=0
while [ $cdx -lt 8 ]
	do
		#echo 0$adx$bdx$cdx
		umask 0$adx$bdx$cdx
		mkdir dir_$adx$bdx$cdx
		touch file_$adx$bdx$cdx
		cdx=`expr $cdx + 1`	
	done
}

bdx_e()
{
bdx=0
cdx=0
while [ $bdx -lt 8 ]
	do
		cdx_e
		#echo 0$adx$bdx$cdx			
		bdx=`expr $bdx + 1`
	done
}

adx_e()
{
adx=0
bdx=0
cdx=0
while [ $adx -lt 8 ]
	do
		bdx_e
		#echo 0$adx$bdx$cdx
		adx=`expr $adx + 1`
done
}

adx_e

ls -l | awk '{print $1" "$8}' > umask_info.txt
