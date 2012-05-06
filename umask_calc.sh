#!/bin/sh

# checking arg exist
if [ -z $1 ]; then
	echo "No need arg. Exiting..."
	exit 1 
fi

prep_uma=`printf "$1" | sed -e 's/\(.\{3\}\).*/\1/' | sed -e 's/[^0-7]*//g' | sed -e 's/\(.\)/ \1/g'`

# "inverse" hash need for convert umask value for next "inverse AND" operation
# checking arg correction
inv_dec_bin_con()
{
	case $1 in 
		7)
		printf "000";;
		6)
		printf "001";;
		5)
		printf "010";;
		4)
		printf "011";;
		3)
		printf "100";;
		2)
		printf "101";;
		1)
		printf "110";;
		0)
		printf "111";;
		*)
		echo "bad umask"; exit 1;;
	esac
}

# need for convert final value from bin to dec
bin_dec_con()
{
	case $1 in 
		000)
		printf "0";;
		001)
		printf "1";;
		010)
		printf "2";;
		011)
		printf "3";;
		100)
		printf "4";;
		101)
		printf "5";;
		110)
		printf "6";;
		111)
		printf "7";;
		*)
		echo "What is it?"; exit 1;;
	esac
}

# need for convert final value from bin to letters
bin_lett_con()
{
	case $1 in 
		000)
		echo "---\c" ;;
		001)
		echo "--x\c";;
		010)
		echo "-w-\c";;
		011)
		echo "-wx\c";;
		100)
		echo "r--\c";;
		101)
		echo "r-x\c";;
		110)
		echo "rw-\c";;
		111)
		echo "rwx\c";;
		*)
		echo "What is it?"; exit 1;;
	esac
}

# convertion to "Human-readable"
transcript_perm()
{
	bits=`echo "$1" | sed -e 's/\(.\{3\}\)/ \1/g'`

	if [ $2 = 0 ]; then
		f_type="directories"
		else
		f_type="files"
	fi

	printf "$f_type permissions:\t"

	for bit in $bits
		do
			bin_dec_con $bit
		done

	printf " "

	for lett in $bits
		do
			bin_lett_con $lett
		done
}

# evaluation permissions for directories (binary operations)
dir_perm()
{
	for i in $prep_uma
		do
			for j in `inv_dec_bin_con $i | sed -e 's/\(.\)/ \1/g'`
				do
					echo "$j && 1" | bc | while read -r line; do printf $line; done 
				done
		done
}

# defaul permissions for files (default permissions for dir is "777", "111111" in bin, so enough "1")
file_mas()
{
	case $1 in
		[3,6,9])
		file_m=0;;
		*)
		file_m=1;;
	esac

	echo $file_m
}

# evaluation permissions for files (binary operations)
file_perm()
{
	n=1
	
	for i in $prep_uma
		do
			for j in `inv_dec_bin_con $i | sed -e 's/\(.\)/ \1/g'`
				do
					echo "$j &&" `file_mas $n` | bc | while read -r line; do printf $line; done
					n=`expr $n + 1`
				done
		done
}

di_pe=`dir_perm`
fi_pe=`file_perm`

printf '\n'

transcript_perm $di_pe 0 # operation for evaluation dir permissions

printf '\n'

transcript_perm $fi_pe 1 # operation for evaluation file permissions

printf '\n\n'
