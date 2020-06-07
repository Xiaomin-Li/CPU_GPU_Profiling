DSTPATH=/usr/bin/k20LoggerToFile

echo "Installing to $DSTPATH"

printf 'Permissions before: '
ls -lad $DSTPATH

cp k20LoggerToFile $DSTPATH
chown root:metermen $DSTPATH
chmod 110 $DSTPATH

printf 'Permissions after:  '
ls -lad $DSTPATH

echo 'Please check that the before/after permissions are correct.'
