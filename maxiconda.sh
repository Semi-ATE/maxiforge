#!/bin/bash

USAGE_TXT="
usage: $0 [--pypy]

This is a front-end for Linux- and MacOS- maxiconda installers. 
It fetches the appropriate and most recent maxiconda installer for the 
current OS/CPU, checks the SHA256 signature and then runs it.

--pypy     Use PyPy instead of the default CPython implementation.
"

IMPL=""
for i in "$@"
do
case $i in
    --pypy|-pypy|--PyPy|-PyPy)
    IMPL="-pypy"
    shift
    ;;
    *)
    printf "%s\\n" "$USAGE_TXT"
    exit
    ;;
esac
done

OS=`uname -s`
case $OS in
    "Linux")
        OS_NAME="Linux"
        ;;
    "Darwin")
        OS_NAME="MacOS"
        ;;
    *)
        printf "WOOPS: OS '%s' is not yet implemented...\\n" $OS
        exit 1
        ;;
esac

CPU=`uname -m`
case $CPU in
    "x86_64")
        CPU_NAME="x86_64"
        ;;
    "aarch64")
        CPU_NAME="aarch64"
        ;;
    "ppc64le")
        CPU_NAME="ppc64le"
        ;;
    *)
        printf "WOOPS: CPU '%s' is not yet implemented...\\n" $OS
        exit 1
        ;;
esac

## URI's & COMMANDS ###
BASE_URL="https://github.com/Semi-ATE/maxiconda/releases/latest/download/"
VERSION_URL="https://github.com/Semi-ATE/maxiconda/releases/latest/"
[[ `curl -s $VERSION_URL` =~ [^0-9]+([^\"]+)\" ]]
VERSION=${BASH_REMATCH[1]}
INSTALLER="maxiconda$IMPL-$VERSION-$OS_NAME-$CPU_NAME.sh"
RUN_INSTALLER="bash $INSTALLER"
SHA256="$INSTALLER.sha256"
INSTALLER_URL="$BASE_URL$INSTALLER"
DOWNLOAD_INSTALLER="curl -SL $INSTALLER_URL --output $INSTALLER"
SHA256_URL="$BASE_URL$SHA256"
DOWNLOAD_SHA256="curl -SL $SHA256_URL --output $SHA256"
SHA256SUM="sha256sum ./$INSTALLER"

printf "\\nStep #1: Downloading '$INSTALLER'\\n"
printf -- "-------------------------------------------------------------------------------\\n"
$DOWNLOAD_INSTALLER

printf "\\nStep #2: Downloading '$SHA256'\\n"
printf -- "-------------------------------------------------------------------------------\\n"
$DOWNLOAD_SHA256

printf "\\nStep #3: Checking installer integrity ..."
CALCULATED_CHECKSUM=`$SHA256SUM`
GIVEN_CHECKSUM=$(head -n 1 $SHA256)
if [ "$CALCULATED_CHECKSUM" == "$GIVEN_CHECKSUM" ]
then
    printf "PASS\\n"
else
    printf "FAIL:\\n"
    printf "Calculated: '%s'\\n" $CALCULATED_CHECKSUM
    printf "     Given: '%s'\\n" $GIVEN_CHECKSUM
    exit 1
fi
printf -- "-------------------------------------------------------------------------------\\n"

printf "\\nStep #4: Installing '$INSTALLER $PTA'\\n"
printf -- "-------------------------------------------------------------------------------\\n"
$RUN_INSTALLER

printf "\\nStep #5: Cleaning up ... "
`rm -f $INSTALLER`
`rm -f $SHA256`
printf "Done.\\n"
printf -- "-------------------------------------------------------------------------------\\n"

printf "\\nYou are all set and ready to go!\\n"