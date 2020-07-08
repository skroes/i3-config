#!/bin/bash
perl -lne 'print $1 if /([^,@"]+@[^,@"]+)/' ring1contacts.csv  > alltheemails.txt

echo -n "from:("
for i in `cat alltheemails.txt`; do
  echo -ne "$i OR "
done
echo -ne "blabla@bla.com"
echo ")"
