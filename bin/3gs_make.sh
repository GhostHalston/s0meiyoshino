#!/bin/bash

## VERSION
# 3.0, 6.1.6
# 3.0.1, 4.3.4, 4.3.5

## 3gs_make.sh <downgrade-iOS> <Bootrom_version>
iOSLIST=0
DD=0
iOSVersion="0"
iOSBuild="0"
LLB_IV="0"
LLB_Key="0"
TOOL="--"

if [ $2 == "--oldBR" ]; then
    echo "Old Bootrom (Bootrom 359.3). This device uses \"0x24000 Segment Overflow\""
fi

if [ $2 == "--newBR" ]; then
    echo "New Bootrom (Bootrom 359.3.2). This device uses \"alloc8 exploit\""
fi

if [ $1 = "3.0" ]; then
    iOSLIST=3
    iOSVersion="3.0"
    iOSBuild="7A341"
    LLB_IV="fc4efef9fd245dc038ecb26f25f795c7"
    LLB_Key="783970ed70d151e65cdd0f52019f026cbc0ece5c604603117d677b6a85ea4d95"
    DD=1
fi

if [ $1 = "3.0.1" ]; then
    iOSLIST=3
    iOSVersion="3.0.1"
    iOSBuild="7A400"
    LLB_IV="fc4efef9fd245dc038ecb26f25f795c7"
    LLB_Key="783970ed70d151e65cdd0f52019f026cbc0ece5c604603117d677b6a85ea4d95"
    DD=0
fi

if [ $1 = "4.3.4" ]; then
    iOSLIST=4
    iOSVersion="4.3.4"
    iOSBuild="8K2"
    LLB_IV="74677f567d2a2224840e55bbd30da3fe"
    LLB_Key="0d8ea4f0b10111472570cd0fb058a71ad131f4cf5b44d8f8a75eaed1f30fc5c2"
    DD=0
fi

if [ $1 = "4.3.5" ]; then
    iOSLIST=4
    iOSVersion="4.3.5"
    iOSBuild="8L1"
    LLB_IV="74677f567d2a2224840e55bbd30da3fe"
    LLB_Key="0d8ea4f0b10111472570cd0fb058a71ad131f4cf5b44d8f8a75eaed1f30fc5c2"
    DD=0
fi

if [ $1 = "6.1.6" ]; then
    iOSLIST=6
    iOSVersion="6.1.6"
    iOSBuild="10B500"
    LLB_IV="6cd7721b9a689e7cc8667fb9ee8724bf"
    LLB_Key="af6889f21968a37165b17b148722ce2d4ef59ec4bdd3932c6e0dc5c60cab7413"
    DD=1
fi


if [ $1 = "3.1" ]; then
TOOL="PwnageTool 3.1.3"
fi
if [ $1 = "3.1.2" ]; then
TOOL="PwnageTool 3.1.5"
fi
if [ $1 = "3.1.3" ]; then
TOOL="PwnageTool 3.1.5 or sn0wbreeze"
fi
if [ $1 = "4.0" ]; then
TOOL="PwnageTool 4.01 or sn0wbreeze"
fi
if [ $1 = "4.1" ]; then
TOOL="PwnageTool 4.1.3 or sn0wbreeze"
fi
if [ $1 = "4.2.1" ]||[ $1 = "4.3" ]; then
TOOL="PwnageTool 4.2 or sn0wbreeze"
fi
if [ $1 = "4.3.1" ]; then
TOOL="PwnageTool 4.3 or sn0wbreeze"
fi
if [ $1 = "4.3.2" ]; then
TOOL="PwnageTool 4.3.2 or sn0wbreeze"
fi
if [ $1 = "4.3.3" ]; then
TOOL="PwnageTool 4.3.3.1 or redsn0w or sn0wbreeze"
fi
if [ $1 = "5.0.1" ]; then
TOOL="PwnageTool 5.0.1 or redsn0w or sn0wbreeze"
fi
if [ $1 = "5.0" ]||[ $1 = "5.1" ]; then
TOOL="redsn0w or sn0wbreeze"
fi
if [ $1 = "5.1.1" ]; then
TOOL="PwnageTool 5.1.1 or redsn0w or sn0wbreeze"
fi
if [ $1 = "4.0.1" ]||[ $1 = "4.0.2" ]||[ $1 = "6.0" ]||[ $1 = "6.0.1" ]||[ $1 = "6.1" ]||[ $1 = "6.1.2" ]||[ $1 = "6.1.3" ]; then
TOOL="sn0wbreeze"
fi

if [ $DD != 1 ]; then
    echo "[ERROR] This version is not supported. Please use \""$TOOL"\"."
    exit
fi

if [ $iOSLIST == 3 ]&&[ $2 == "--newBR" ]; then
    echo "[ERROR] This version does not support New Bootrom."
    exit
fi

if [ -d "tmp_ipsw" ]; then
    rm -r tmp_ipsw
fi

mkdir tmp_ipsw

./bin/ipsw iPhone2,1_"$iOSVersion"_"$iOSBuild"_Restore.ipsw tmp_ipsw/iPhone2,1_"$iOSVersion"_"$iOSBuild"_1st.ipsw -memory

if [ -e "tmp_ipsw/iPhone2,1_"$iOSVersion"_"$iOSBuild"_1st.ipsw" ]; then
    echo "success"
else
    echo "[ERROR] failed make ipsw"
    exit
fi

## 24k
cd tmp_ipsw

unzip -d $iOSBuild iPhone2,1_"$iOSVersion"_"$iOSBuild"_1st.ipsw

rm iPhone2,1_"$iOSVersion"_"$iOSBuild"_1st.ipsw

mv -v "$iOSBuild"/Firmware/all_flash/all_flash.n88ap.production/LLB.n88ap.RELEASE.img3 ./

../bin/xpwntool LLB.n88ap.RELEASE.img3 LLB.n88ap.RELEASE.dec -iv $LLB_IV -k $LLB_Key
../bin/xpwntool LLB.n88ap.RELEASE.dec "$iOSBuild"/Firmware/all_flash/all_flash.n88ap.production/LLB.n88ap.RELEASE.img3 -xn8824k -t LLB.n88ap.RELEASE.img3 -iv $LLB_IV -k $LLB_Key

rm LLB.n88ap.RELEASE.img3
rm LLB.n88ap.RELEASE.dec

cd $iOSBuild
zip ../../iPhone2,1_"$iOSVersion"_"$iOSBuild"_Custom.ipsw -r0 *

cd ../..

#### clean up ####
rm -r tmp_ipsw

if [ -e "iPhone2,1_"$iOSVersion"_"$iOSBuild"_Custom.ipsw" ]; then
    echo "Done!"
else
    echo "[ERROR] failed make ipsw"
    exit
fi
