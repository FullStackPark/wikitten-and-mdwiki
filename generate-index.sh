#!/bin/bash
OUTFILE="index.md"

if [ "x$1" = "x" -o ! -d "$1" ]; then
	exit 1
fi

if [ $# -eq 1 ]; then
	find "$1" -type d -printf '%P\n' | while read TDIR; do
		$0 "$1" "$TDIR"
	done
	exit 0
fi

# Check directory
INDIR="$1/$2"
if [ ! -d "$INDIR" ]; then
	exit 1
fi

# Whether already has valid index.md file
if [ -s "$INDIR/$OUTFILE" ]; then
	grep -q "Auto-index of" "$INDIR/$OUTFILE"
	if [ $? -ne 0 ]; then
		exit 0
	fi
fi

OUTTMP=`mktemp /tmp/.gen-index-XXXXX`

PTITLE=`basename "$2"`
if [ "x$PTITLE" = "x" ]; then
	PTITLE="/"
fi
echo -e "\`\`\`\n\"title\": \"$PTITLE\"\n\`\`\`\n" > $OUTTMP

echo -e "# Auto-index of '/$2'\n\n| Name | Last Modified | Size | Type |\n| -------------------- | -------------------- | ---------- | -------- |" >> $OUTTMP

echo "| [&#x21E7; [parent directory]](../index.md) | | | |" >> $OUTTMP

find $INDIR -mindepth 1 -maxdepth 1 -type d -printf "| [&#x1F4C1; %f](%f/index.md) | %TY-%Tm-%Td %TH:%TM:%.2TS | %s | %M |\n" >> $OUTTMP
find $INDIR -maxdepth 1 -type f \( -iname \*.markdown -o -iname \*.md -a ! -name index.md \) -printf "| [&#x1F4D5; %f](%f) | %TY-%Tm-%Td %TH:%TM:%.2TS | %s | %M |\n" >> $OUTTMP

# whether need to overwrite index file
if [ -s "$INDIR/$OUTFILE" ]; then
	diff -q "$INDIR/$OUTFILE" $OUTTMP >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		exit 0
	fi
fi

echo "Generate index file: $INDIR/$OUTFILE"
cat $OUTTMP > "$INDIR/$OUTFILE"
rm -f $OUTTMP
