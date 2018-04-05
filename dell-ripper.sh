#!/bin/bash
# Dell ISO clean URL list processor 
# This script will rip driver code (5 digit code every driver has) and serach download.dell.com
# for direct .BIN link

mytime=$(date)
bold=$(tput bold)
normal=$(tput sgr0)

echo ${bold}
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo Dell ISO clean URL list processor
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo ${normal}

# confirmation
read -p "Would you like to mount $1 at /mnt? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
umount /mnt > /dev/null 2>&1 || /bin/true
mount -t iso9660 -o loop $1 /mnt
fi 

echo

ac=$(find /mnt -name 'apply_components.sh')

for x in $( 
cat $ac \
	| sed -s 's/REBOOT//g' \
	| sed -s 's/REEBOOT//g' \
	| sed -s 's/STATUS//g' \
	| sed -s 's/RETURN//g' \
	| sed -s 's/STDME//g' \
	| sed -s 's/SSAGE//g' \
	| grep -Eo '([A-Z1-9]{5})')
do curl -s https://www.dell.com/support/home/us/en/19/drivers/driversdetails?driverId=$x \
	| grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" \
	| grep '.BIN' | sort | uniq \
	| grep -v '.sign'
done

echo

cat $ac | grep 'ExecuteDup '

echo

umount /mnt
