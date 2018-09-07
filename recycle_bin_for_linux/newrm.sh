#!/bin/bash
archive_dir="$HOME/.deleted_files"
realrm="$(which rm)"
copy="$(which cp) -R"
if [ $# -eq 0 ]
then
	exec $realrm
fi
flags=""
while getopts "dfiPRrvW" opt
do
	case $opt in
	f)flags="$flag-f";;
	*)flags="$flags-$opt" ;; 
	esac
done
shift $(($OPTIND-1))

if [ ! -d $archive_dir ]
then 
	if [ ! -w $HOME ]
	then
		echo "$0 failed:can't create $archive_dir in $HOME ">&2
		exit 1
	fi
	mkdir $archive_dir
	chmod 700 $archive_dir
fi

for arg in $@
do 
	newname="$archive_dir/$(date "+%S.%M.%d.%m").$(basename "$arg")"
	if [ -f "$arg" -o -d "$arg" ]
	then
		$copy "$arg" "$newname"
	fi
done
exec $realrm $flags "$@"
alias rm="/bin/newrm"





































 
