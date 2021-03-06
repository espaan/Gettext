#!/bin/sh
#########################################################
# copy translate.sh and translate.php to the Zikula root
# remove all non core modules from modules/
# load the foreign language packs for the Core.
#
# gettext must be installed (apt-get install gettext)
#
# ./translatecore.sh deu 
#
#########################################################

# check command line params
if [ $# -ne 1 ]; then
  echo 1>&2 Usage: $0 [foreignlangcode] 
  exit 127
fi

FOR=$1
OUTPUT=/tmp/conversion
rm -f $OUTPUT
rm -f $OUTPUT.tmp
rm -f pofile.po
cat >pofile.header <<EOF
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: Zikula 1.2.x\n"
"Report-Msgid-Bugs-To: PACKAGE VERSION\n"
"POT-Creation-Date: 2009-08-20 14:41-0400\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"X-Poedit-Language: \n"
"X-Poedit-Country: \n"
"X-Poedit-SourceCharset: utf-8\n"
EOF
cp -a pofile.header pofile.po 
if [ -f translate.php ]; then

echo "Scanning for language files..."
find . -type d |grep modules|grep pnlang|awk -F/ '{print $2 "/" $3 "/" $4}'|uniq>dirlist
find . -type d |grep system|grep pnlang|awk -F/ '{print $2 "/" $3 "/" $4}'|uniq>>dirlist
find . -type d |grep themes|grep pnlang|awk -F/ '{print $2 "/" $3 "/" $4}'|uniq>>dirlist
echo "install/pnlang" >>dirlist
echo "languages">>dirlist

for DIR in `cat dirlist`;
do
  for FILE in `ls $DIR/eng/*.php`
  do
    DST=`echo $FILE| sed "s#pnlang/eng#pnlang/$FOR#g"`
    echo "processing $DST..."
    php -f translate.php $FILE $DST $OUTPUT
    if [ $? -eq 1 ]; then
      echo "Merging keys with pofile.po..."
      msgmerge -U pofile.po $OUTPUT
      echo "Done."
      if [ $? -eq 1 ]; then
        echo "FATAL ERROR in msgmerge occured, cannot proceed"
        exit;
      fi
    fi
  done
done
mv -f pofile.po pofile.pot
cp -a pofile.header $FOR.po
echo "Creating the final $FOR.po"
msgmerge -U $FOR.po pofile.pot
if [ -f locale/zikula.pot ]; then
  echo "FOUND zikula.pot, so I'm merging that - you have a final merge file: zikula.po"
  msgmerge -U $FOR.po locale/zikula.pot
  mv $FOR.po zikula.po
fi
else
  echo "helper file translate.php must be in the zikula root directory"
fi
