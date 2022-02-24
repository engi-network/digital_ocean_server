# This script rotates the backups if there are 20 GB or more of backups
# It is run by a crontab job. It lives on the Digital Ocean server
# Here is the crontab job's entry (to happen 1 hr before the ThinkPad backup):
# 0 0 * * * /bin/bash rotation.sh

firstdir=/thinkpad
maindir=$firstdir/previous
nd=$(date | awk '{print $2"_"$3"_"$6}')  # get today's date 
newdir=$maindir'/'$nd  # draft name of new dir (full path) 

cd $maindir 
preletter=$(du -sh | awk '{print $1}')
if [ "${preletter: -1}" == "G" ]; then  #
    presize=$(du -sh | awk '{print $1}' | tr -d [:alpha:]) # remove M or G
    size=$(echo $presize | awk -F"." '{print $1}') #obtain GB left of "."
    if [ $size -gt 20 ]; then # Delete oldest dir of backups if >20 GB of backups
            dir2del=$(ls -lh $maindir --sort=time | tail -n 1 | awk '{print $NF}')
	    # above command gets oldest directory name
            rm -rf $maindir/$dir2del
    fi
fi


mkdir $newdir
tlist=$(ls $firstdir | grep tar.gz) # build an array of files to be moved
eval "slist=($tlist)"

len=${#slist[@]}
for (( i=0; i<$len; i++ )); 
  do
  mv $firstdir/${slist[i]} $newdir  # Move files so next backup won't overwrite them
  done

mv $firstdir/readme.txt $newdir

