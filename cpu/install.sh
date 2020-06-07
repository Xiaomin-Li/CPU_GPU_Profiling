DSTPATH=/usr/bin/cpuLogToFile
echo "Installing to $DSTPATH"

printf 'Permissions before: '
ls -lad $DSTPATH

cp cpuLoggerToFile $DSTPATH
#chown root:metermen $DSTPATH
#chmod 110 $DSTPATH
chmod 0777 $DSTPATH
chmod +s $DSTPATH
setcap cap_sys_rawio=ep cpuLogToFile

printf 'Permissions after:  '
ls -lad $DSTPATH

echo 'Please check that the before/after permissions are correct.'
