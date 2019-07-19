#!/bin/bash


echo "****************** s0meiyoshino v4.0 alpha-5 make_ipsw ******************"

if [ $# == 1 ]; then
    if [ $1 = "--help" ];then
        echo "**HOW TO USE**"
        echo "./make_ipsw.sh <device model> <downgrade-iOS> <base-iOS> [arg1]"
        echo ""
        echo "If you select iOS 4.3.x, the value of \"cs_enforcement_disable=1 amfi=0xff -v\" will be forced into boot-args."
        echo "This will be resolved in a future update."
        echo ""
        echo "[OPTION]"
        echo "  --verbose               : [arg1] Enable verbose boot (for iOS 5 or later)"
        echo "                            *Inject Boot-args=\"-v\" to iBoot."
        echo "  ----csdisable           : [arg1] Inject cs_disable into boot-args"
        echo "                            *Inject Boot-args=\"cs_enforcement_disable=1 amfi=0xff\" to iBoot. (for iOS 5/6)"
        echo "                            *Inject Boot-args=\"cs_enforcement_disable=1 amfi_get_out_of_my_way=1\" to iBoot. (for iOS 7 or later)"
        echo "  ----verbose-csdisable   : [arg1] Enable verbose boot and inject cs_disable into boot-args"
        echo "                            *Inject Boot-args \"cs_enforcement_disable=1 amfi=0xff -v\" (for iOS 4/5/6)"
        echo "                            *Inject Boot-args \"cs_enforcement_disable=1 amfi_get_out_of_my_way=1 -v\" (for iOS 7 or later)"
        echo "                            *iOS 4.3.x enforces this option."
        echo "  --jb                    : [arg1] Jailbreak iOS 9.x (iPhone5,2 only) [BETA]"
        echo "                            *This jailbreak is \"UNTETHERED\" jailbreak."
        echo "                            *Untether is provided by iBoot vulnerability."
        echo "  --remove                : [arg1] Remove nvram variable (iPhone3,1 7.1.2 only)"
        echo "                            *Once this tool is applied, official Firmware cannot boot unless the nvram boot-partition (and boot-ramdisk) value is removed."
        echo "                            *This option removes the boot-partition value from iPhone3,1."
        echo "                            *Downgrade-iOS needs to select 7.1.2."
        echo "                            *This option is NOT available on iPhone 5. Please read the README for the remove method."
        echo ""
        echo "[example]"
        echo "./make_ipsw.sh iPhone5,2 6.1.4 7.0.4 --verbose"
        echo "./make_ipsw.sh iPhone3,1 6.1.2 7.1.2 ----verbose-csdisable"
        echo "./make_ipsw.sh iPhone5,2 9.3.5 7.0.3 --jb"
        echo "./make_ipsw.sh iPhone3,1 7.1.2 7.1.2 --remove"
        echo ""
        echo "[Show detailed help]"
        echo "./make_ipsw.sh --help"
        exit
    fi

    if [ $1 = "--n88help" ];then
        echo "**HOW TO USE**"
        echo "./make_ipsw.sh iPhone2,1 <downgrade-iOS> <Bootrom_version>"
        echo ""
        echo "[Bootrom_version]"
        echo "  --oldBR             : Old Bootrom (Bootrom 359.3). This device uses \"0x24000 Segment Overflow\" for downgrade."
        echo "  --newBR             : New Bootrom (Bootrom 359.3.2). This device uses \"alloc8 exploit\" for downgrade."
        echo ""
        echo "[example]"
        echo "./make_ipsw.sh iPhone2,1 3.0 --oldBR"
        echo "./make_ipsw.sh iPhone2,1 6.1.6 --newBR"
        exit
    fi

fi


if [ $# -lt 3 ]; then
    echo "**HOW TO USE** (iPhone 4 or later)"
    echo "./make_ipsw.sh <device model> <downgrade-iOS> <base-iOS> [arg1]"
    echo ""
    echo "[OPTION] (for iOS 5 or later)"
    echo "  --verbose       : [arg1] Enable verbose boot"
    echo "  --jb            : [arg1] Jailbreak iOS 9.x (iPhone5,2 only)[BETA]"
    echo "  --remove        : [arg1] Remove exploit (iPhone3,1 only)"
    echo ""
    echo "[example]"
    echo "./make_ipsw.sh iPhone5,2 6.1.4 7.0.4 --verbose"
    echo ""
    echo "[Show detailed help]"
    echo "./make_ipsw.sh --help"
    echo ""
    echo "[Show 3GS help]"
    echo "./make_ipsw.sh --n88help"
    exit
fi

Remove_Exploit=0

if [ $1 = "iPhone2,1" ]; then
    if [ $# != 3 ]; then
        echo "[ERROR] Bad arguments"
        exit
    fi

    if [ $3 != "--oldBR" ] && [ $3 != "--newBR" ]; then
        echo "[ERROR] Bad arguments"
        exit
    fi

bin/3gs_make.sh $2 $3

    exit
fi

echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  WARNING  !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!This tool uses iOS 7 iBoot vulnerability. USE AT YOUR OWN RISK !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

if [ $# == 4 ]; then
    if [ $4 != "--verbose" ] && [ $4 != "--jb" ] && [ $4 != "--remove" ] && [ $4 != "----csdisable" ] && [ $4 != "----verbose-csdisable" ]; then
        echo "[ERROR] Invalid argument"
        exit
    fi

    if [ $4 = "--remove" ]; then
        Remove_Exploit=1
    fi
fi

if [ $# -gt 4 ]; then
    echo "[ERROR] Too many arguments"
    exit
fi

Chip="0"

#### Set support device information ####
if [ $1 = "iPhone3,1" ]; then
    if [ $3 != "7.1.2" ]; then
        echo "[ERROR] Please use \"7.1.2\" for base iOS"
        exit
    fi
    Identifier="iPhone3,1"
    InternalName="n90ap"
    iBootInternalName="n90ap"
    SoC="s5l8930x"
    Image="2x~iphone-30pin"
    BaseFWVer="7.1.2"
    BaseFWBuild="11D257"
    Size="2x"
    Chip="A4"
fi

if [ $1 = "iPhone5,2" ]; then
    if [ $3 = "7.0" ] || [ $3 = "7.0.2" ] || [ $3 = "7.0.3" ] || [ $3 = "7.0.4" ] || [ $3 = "7.0.6" ]; then
        Identifier="iPhone5,2"
        InternalName="n42ap"
        iBootInternalName="n42ap"
        SoC="s5l8950x"
        Image="1136~iphone-lightning"
        Size="1136"
        Chip="A6"
        if [ $3 = "7.0" ]; then
            BaseFWVer="7.0"
            BaseFWBuild="11A465"
        fi
        if [ $3 = "7.0.2" ]; then
            BaseFWVer="7.0.2"
            BaseFWBuild="11A501"
        fi
        if [ $3 = "7.0.3" ]; then
            BaseFWVer="7.0.3"
            BaseFWBuild="11B511"
        fi
        if [ $3 = "7.0.4" ]; then
            BaseFWVer="7.0.4"
            BaseFWBuild="11B554a"
        fi
        if [ $3 = "7.0.6" ]; then
            BaseFWVer="7.0.6"
            BaseFWBuild="11B651"
        fi
    else
        echo "[ERROR] This base-iOS is NOT supported!"
        exit
    fi
fi

if [ $1 = "iPhone5,1" ]; then
    if [ $3 = "7.0" ] || [ $3 = "7.0.2" ] || [ $3 = "7.0.3" ] || [ $3 = "7.0.4" ] || [ $3 = "7.0.6" ]; then
        Identifier="iPhone5,1"
        InternalName="n41ap"
        iBootInternalName="n41ap"
        SoC="s5l8950x"
        Image="1136~iphone-lightning"
        Size="1136"
        Chip="A6"
        if [ $3 = "7.0" ]; then
            BaseFWVer="7.0"
            BaseFWBuild="11A465"
        fi
        if [ $3 = "7.0.2" ]; then
            BaseFWVer="7.0.2"
            BaseFWBuild="11A501"
        fi
        if [ $3 = "7.0.3" ]; then
            BaseFWVer="7.0.3"
            BaseFWBuild="11B511"
        fi
        if [ $3 = "7.0.4" ]; then
            BaseFWVer="7.0.4"
            BaseFWBuild="11B554a"
        fi
        if [ $3 = "7.0.6" ]; then
            BaseFWVer="7.0.6"
            BaseFWBuild="11B651"
        fi
    else
        echo "[ERROR] This base-iOS is NOT supported!"
        exit
    fi
fi

if [ $1 != "iPhone3,1" ] && [ $1 != "iPhone5,2" ] && [ $1 != "iPhone5,1" ]; then
    echo "[ERROR] This device is NOT supported!!"
    exit
fi

#### Find base firmware ####
if [ -e ""$Identifier"_"$BaseFWVer"_"$BaseFWBuild"_Restore.ipsw" ]; then
    echo ""$Identifier"_"$BaseFWVer"_"$BaseFWBuild"_Restore.ipsw OK"
else
    echo ""$Identifier"_"$BaseFWVer"_"$BaseFWBuild"_Restore.ipsw does not exist"
    exit
fi

#### Set macOS version ####
OSXVer=`sw_vers -productVersion | awk -F. '{print $2}'`
DD=0
JB=0
disablekaslr=0
sbops_patch=0
iBoot9=0
DeveloperBeta=0
pangu9=0
iBoot9_Partition_patch="0"
iBoot_KASLR="0"
iOSLIST="0"

BundleType="Down"
# BundleType == Down; Base on odysseus bundle
# BundleType == New; Base on s0meiyoshino custom bundle

#### iPhone 4 ####
if [ $Identifier = "iPhone3,1" ]; then

####if [ $2 = "4.0" ]; then
########iOSLIST="4"
########iOSVersion="4.0_8A293"
########iOSBuild="8A293"
########RestoreRamdisk="018-6306-403.dmg"
########iBoot_IV="127785de92315f6921e8ecd0d2ca35f2"
########iBoot_Key="2d995cd307840ab0ef2369775aa9d00605ac0df7160b68933404dfbe2e1fe969"
########DD=1
####fi

####if [ $2 = "4.2" ]; then
########iOSLIST="4"
########iOSVersion="4.2_8C134"
########iOSBuild="8C134"
########RestoreRamdisk="018-9746-004.dmg"
########iBoot_IV="dadfae4f4967eff4f149b606cbe34060"
########iBoot_Key="65b69a67acc72771aea43b15b70a566139a42257bdab7659cdab1ab2537713af"
########DD=1
####fi

    if [ $2 = "4.3.3" ]; then
        #### iOS 4.3.3 ####
        ## iBoot-1072.61~2
        iOSLIST="4"
        iOSVersion="4.3.3_8J2"
        iOSBuild="8J2"
        RestoreRamdisk="038-1449-003.dmg"
        iBoot_IV="bb3fc29dd226fac56086790060d5c744"
        iBoot_Key="c2ead1d3b228a05b665c91b4b1ab54b570a81dffaf06eaf1736767bcb86e50de"
        DD=1
    fi

    if [ $2 = "4.3.4" ]; then
        ## iBoot-1072.61~6
        iOSLIST="4"
        iOSVersion="4.3.4_8K2"
        iOSBuild="8K2"
        RestoreRamdisk="038-2174-001.dmg"
        iBoot_IV="986032eecd861c37ca2a86b6496a3c0d"
        iBoot_Key="b4e300c54a9dd2e648ead50794e9bf2205a489c310a1c70a9fae687368229468"
        DD=1
    fi

    if [ $2 = "4.3.5" ]; then
        #### iOS 4.3.5 ####
        ## iBoot-1072.61~6
        iOSLIST="4"
        iOSVersion="4.3.5_8L1"
        iOSBuild="8L1"
        RestoreRamdisk="038-2265-002.dmg"
        iBoot_Key="b4e300c54a9dd2e648ead50794e9bf2205a489c310a1c70a9fae687368229468"
        iBoot_IV="986032eecd861c37ca2a86b6496a3c0d"
        DD=1
    fi

    if [ $2 = "5.1.1" ]; then
        #### iOS 5.1.1 ####
        ## iBoot-1219.62.15~2
        iOSLIST="6"
        iOSVersion="5.1.1_9B206"
        iOSBuild="9B206"
        RestoreRamdisk="038-4361-021.dmg"
        iBoot_Key="e8e26976984e83f967b16bdb3a65a3ec45003cdf2aaf8d541104c26797484138"
        iBoot_IV="b1846de299191186ce3bbb22432eca12"
        Boot_Partition_Patch="000081a: 00200020"
        DD=1
    fi

    if [ $2 = "6.0b1" ]; then
        #### iOS 6.0 beta ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a64: 00200020"
        iOSVersion="6.0_10A5316k"
        iOSBuild="10A5316k"
        RestoreRamdisk="038-5050-010.dmg"
        iBoot_Key="0f7c61c07cdd7b0d836ebbb1005131e4c506b807d79d0f590bf6a914ca822e8f"
        iBoot_IV="53263df945c0c501611ecf17b5e31a39"
        DeveloperBeta=1
    fi


    if [ $2 = "6.0" ]; then
        #### iOS 6.0 ####
        ## iBoot-1537.4.18~2
        iOSLIST="6"
        Boot_Partition_Patch="0000a6c: 00200020"
        iOSVersion="6.0_10A403"
        iOSBuild="10A403"
        RestoreRamdisk="038-6451-001.dmg"
        iBoot_Key="838270f668a05a60ff352d8549c06d2f21c3e4f7617c72a78d82c92a3ad3a045"
        iBoot_IV="7891928b9dd0dd919778743a2c8ec6b3"
        DD=1
    fi

    if [ $2 = "6.0.1" ]; then
        #### iOS 6.0.1 ####
        ## iBoot-1537.4.21~3
        iOSLIST="6"
        Boot_Partition_Patch="0000a6c: 00200020"
        iOSVersion="6.0.1_10A523"
        iOSBuild="10A523"
        RestoreRamdisk="038-7924-011.dmg"
        iBoot_Key="8d539232c0e906a9f60caa462f189530f745c4abd81a742b4d1ec1cb8b9ca6c3"
        iBoot_IV="44ffe675d6f31167369787a17725d06c"
        DD=1
    fi

    if [ $2 = "6.1" ]; then
        #### iOS 6.1 ####
        ## iBoot-1537.9.55~4
        iOSLIST="6"
        Boot_Partition_Patch="0000a6c: 00200020"
        iOSVersion="6.1_10B144"
        iOSBuild="10B144"
        RestoreRamdisk="048-0804-001.dmg"
        iBoot_Key="891ed50315763dac51434daeb8543b5975a555fb8388cc578d0f421f833da04d"
        iBoot_IV="4d76b7e25893839cfca478b44ddef3dd"
        DD=1
    fi

    if [ $2 = "6.1.2" ]; then
        #### iOS 6.1.2 ####
        ## iBoot-1537.9.55~4
        iOSLIST="6"
        Boot_Partition_Patch="0000a6c: 00200020"
        iOSVersion="6.1.2_10B146"
        iOSBuild="10B146"
        RestoreRamdisk="048-1037-002.dmg"
        iBoot_Key="cbcd007712618cb6ab3be147f0317e22e7cceadb344e99ea1a076ef235c2c534"
        iBoot_IV="c939629e3473fdb67deae0c45582506d"
        DD=1
    fi

    if [ $2 = "6.1.3" ]; then
        #### iOS 6.1.3 ####
        ## iBoot-1537.9.55~11
        iOSLIST="6"
        Boot_Partition_Patch="0000a6c: 00200020"
        iOSVersion="6.1.3_10B329"
        iOSBuild="10B329"
        RestoreRamdisk="048-2441-007.dmg"
        iBoot_Key="3dbe8be17af793b043eed7af865f0b843936659550ad692db96865c00171959f"
        iBoot_IV="b559a2c7dae9b95643c6610b4cf26dbd"
        DD=1
    fi

    if [ $2 = "7.0" ]; then
        #### iOS 7.0 ####
        ## iBoot-1940.1.75~20
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.0_11A465"
        iOSBuild="11A465"
        RestoreRamdisk="038-3373-256.dmg"
        iBoot_Key="e1fef31c8aabcdca2a3887ba21c0e2113c41a5617380657ab6a487993b39f9a8"
        iBoot_IV="5bf099d9db5cf1009329e527a378c8be"
        DD=1
    fi

    if [ $2 = "7.0.2" ]; then
        #### iOS 7.0.2 ####
        ## iBoot-1940.1.75~93
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.0.2_11A501"
        iOSBuild="11A501"
        RestoreRamdisk="048-9414-002.dmg"
        iBoot_Key="5cd910c268813cb4008e5b33e01f761c0794ed1437737b4d386727d17fac79d1"
        iBoot_IV="65db9a4e4f64bb79a55d76d98ce1457b"
        DD=1
    fi

    if [ $2 = "7.0.3" ]; then
        #### iOS 7.0.3 ####
        ## iBoot-1940.3.5~1
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.0.3_11B511"
        iOSBuild="11B511"
        RestoreRamdisk="058-0322-002.dmg"
        iBoot_Key="bd56f0886e21f233f519d4db20fd044b9208882a6fb791553a75eb4e0c45bbc5"
        iBoot_IV="7cb97df787dcc6367816b03492b225f9"
        DD=1
    fi

    if [ $2 = "7.0.4" ]; then
        #### iOS 7.0.4 ####
        ## iBoot-1940.3.5~1
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.0.4_11B554a"
        iOSBuild="11B554a"
        RestoreRamdisk="058-1056-002.dmg"
        iBoot_Key="2a6940252b5cb19b86efb9005cdd5fd713290e573dc760f5a3e05df9e868bb89"
        iBoot_IV="67087ac7f28c77cdf9110356f476540b"
        DD=1
    fi

    if [ $2 = "7.0.6" ]; then
        #### iOS 7.0.6 ####
        ## iBoot-1940.3.5~1
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.0.6_11B651"
        iOSBuild="11B651"
        RestoreRamdisk="058-2320-001.dmg"
        iBoot_Key="d7b5bb9b90f19493449ab17fda63afdb16069ad5b65026bb11b4db223fdd4be1"
        iBoot_IV="12af3a975f0346e89d3a34e73b4e0ae1"
        DD=1
    fi

    if [ $2 = "7.1" ]; then
        #### iOS 7.1 ####
        ## iBoot-1940.10.58~115
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.1_11D169"
        iOSBuild="11D169"
        RestoreRamdisk="058-4107-003.dmg"
        iBoot_Key="b68612f21e377bd1f685e9031be159a724e931eff162db245c63b7b692cefa7e"
        iBoot_IV="9fe5b6785126c8fc5787582df9efcf94"
        DD=1
    fi

    if [ $2 = "7.1.1" ]; then
        #### iOS 7.1.1 ####
        ## iBoot-1940.10.58~122
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.1.1_11D201"
        iOSBuild="11D201"
        RestoreRamdisk="058-00093-002.dmg"
        iBoot_Key="c6fbf428e0105ab22b2abaefd20ca22c2084e200f74e8a3b08298a54f8bfe28f"
        iBoot_IV="b110991061d76f74c1fc05ddd7cff540"
        DD=1
    fi

    if [ $2 = "7.1.2" ]; then
        #### iOS 7.1.1 ####
        ## iBoot-1940.10.58~122
        iOSLIST="7"
        Boot_Partition_Patch="0000a54: 00200020"
        iOSVersion="7.1.2_11D257"
        iOSBuild="11D257"
        RestoreRamdisk="058-4107-013.dmg"
        iBoot_Key="63a44cf6a2b356125aac09289e76c66ee82cffd8567d9e9a7d5fe3f371ebaab5"
        iBoot_IV="2006934d7837f097747679602033800b"
        DD=1
    fi

fi

if [ $iOSLIST = "4" ]; then
    #### make scab ####
    echo "Please connect the target device to USB."
    read -p "<enter>: "
    echo "getting shsh..."
    ECID="$((./bin/idevicerestore -t "$Identifier"_"$BaseFWVer"_"$BaseFWBuild"_Restore.ipsw) | sed -n -e 's/^.*Found ECID //p')"
    if [ -e "shsh/"$ECID"-iPhone3,1-7.1.2.shsh" ]; then
        zcat< shsh/"$ECID"-iPhone3,1-7.1.2.shsh > shsh/"$ECID"-iPhone3,1-7.1.2.plist
        plutil -extract 'APTicket' xml1 shsh/"$ECID"-iPhone3,1-7.1.2.plist -o 'shsh/apticket.plist'
        cat shsh/apticket.plist | sed -ne '/<data>/,/<\/data>/p' | sed -e "s/<data>//" | sed  "s/<\/data>//" | awk '{printf "%s",$0}' | base64 --decode > shsh/apticket.der
        bin/xpwntool shsh/apticket.der src/"$ECID"-apticket.img3 -t src/iPhone3,1/scab_template.img3

        rm shsh/apticket.der
        rm shsh/apticket.plist
        rm shsh/"$ECID"-iPhone3,1-7.1.2.plist
        if [ ! -e "src/"$ECID"-apticket.img3" ]; then
            echo "failed get shsh"
            exit
        fi

    fi
fi

#### iPhone 5 (Global) ####
if [ $Identifier = "iPhone5,2" ]; then

    if [ $2 = "6.0" ]; then
        #### iOS 6.0 ####
        ## iBoot-1537.4.19
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.0_10A405"
        iOSBuild="10A405"
        RestoreRamdisk="038-6463-002.dmg"
        iBoot_Key="2b755c7222f27d0e3e84f10d19eb98a8dc8d2d05f4be67d3f31bec1a5b8f9bb3"
        iBoot_IV="87ac80843ec14b0340170729a3232f42"
        DD=1
    fi

    if [ $2 = "6.0.1" ]; then
        #### iOS 6.0.1 ####
        ## iBoot-1537.4.21
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.0.1_10A525"
        iOSBuild="10A525"
        RestoreRamdisk="038-8911-002.dmg"
        iBoot_Key="ecd996bf7b7ec5bbdfc2f664bf404d17b981cdc74eae9d149c0d59fb9a463de7"
        iBoot_IV="b2a8a5d0b3f93b22b98913fc1d2dfcf2"
        DD=1
    fi

    if [ $2 = "6.0.2" ]; then
        #### iOS 6.0.2 ####
        ## iBoot-1537.4.21
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.0.2_10A551"
        iOSBuild="10A551"
        RestoreRamdisk="038-9066-004.dmg"
        iBoot_Key="ecd996bf7b7ec5bbdfc2f664bf404d17b981cdc74eae9d149c0d59fb9a463de7"
        iBoot_IV="b2a8a5d0b3f93b22b98913fc1d2dfcf2"
        DD=1
    fi

    if [ $2 = "6.1_beta_1" ]; then
        #### iOS 6.1 beta (BrightonVail 10B5095f) ####
        #### This version is beta version         ####
        #### You need to create a bundle yourself ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b66: 00200020"   #* unconfirmed *#
        iOSVersion="6.1_10B5095f"
        iOSBuild="10B5095f"
        RestoreRamdisk="038-8932-002.dmg"
        iBoot_Key="f6ca49203e6e23125b23296517235f2f85c123837be95c2a63cdca3f320b9633"
        iBoot_IV="6100088f2d4baa683b0998b373b297d7"
        DeveloperBeta=1
    fi

    if [ $2 = "6.1_beta_2" ]; then
        #### iOS 6.1 beta 2 (BrightonVail 10B5105c) ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"   
        iOSVersion="6.1_10B5105c"
        iOSBuild="10B5105c"
        RestoreRamdisk="038-8999-003.dmg"
        iBoot_Key="22d5f5189a1a5a941b033b7e6bd459a108a1b0c776fc6da4e8c44d406f96ba68"
        iBoot_IV="6d0044577727bdd4f6679ed06f671786"
        DeveloperBeta=1
    fi

    if [ $2 = "6.1_beta_3" ]; then
        #### iOS 6.1 beta 3 (BrightonVail 10B5117b) ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b66: 00200020"   #* unconfirmed *#
        iOSVersion="6.1_10B5117b"
        iOSBuild="10B5117b"
        RestoreRamdisk="038-9284-002.dmg"
        iBoot_Key="9ada3893825a6d805fbb9a66f611cd8c4d34b19c0c009e101cfe3840f7907793"
        iBoot_IV="b13797c3777a14b7fe5233fef4af293c"
        DeveloperBeta=1
    fi

    if [ $2 = "6.1_beta_4" ]; then
        #### iOS 6.1 beta 4 (BrightonVail 10B5126b) ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b66: 00200020"   #* unconfirmed *#
        iOSVersion="6.1_10B5126b"
        iOSBuild="10B5126b"
        RestoreRamdisk="038-9602-003.dmg"
        iBoot_Key="fb92adba9c6de6b37a4f1130868447ce24eeaa5ef0f9ad4ace13b22f09fc0e45"
        iBoot_IV="31520eab4a17cb041f5724ad09d3122b"
        DeveloperBeta=1
    fi

    if [ $2 = "6.1" ]; then
        #### iOS 6.1 ####
        ## iBoot-1537.9.55
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.1_10B143"
        iOSBuild="10B143"
        RestoreRamdisk="048-0729-001.dmg"
        iBoot_Key="146435916d345fff78ffd2972f0277194cc8cfe512c1d7d8eabc3526a3c75478"
        iBoot_IV="af5ef5fb6b37a5327e7a5f92dc4b1473"
        DD=1
    fi

    if [ $2 = "6.1.1_beta" ]; then
        #### iOS 6.1.1 beta (BrightonMaps 10B311) ####
        #### This version is beta version         ####
        #### You need to create a bundle yourself ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b66: 00200020"   #* unconfirmed *#
        iOSVersion="6.1.1_10B311"
        iOSBuild="10B311"
        RestoreRamdisk="048-0386-012.dmg"
        iBoot_Key="346b76e7b5b2e4200467d8ffe499f671e4dc84440b3fecc21607931f74de446b"
        iBoot_IV="eda2282a528798ba838017567a102dfb"
        DeveloperBeta=1
    fi


    if [ $2 = "6.1.2" ]; then
        #### iOS 6.1.2 ####
        ## iBoot-1537.9.55
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.1.2_10B146"
        iOSBuild="10B146"
        RestoreRamdisk="048-0856-002.dmg"
        iBoot_Key="77b211f89344b83d330586690c972142d420cfd6f9b562b7bd7c087a5ab8e79c"
        iBoot_IV="2d9b731bede6196f54d01cb821a4aa70"
        DD=1
    fi

    if [ $2 = "6.1.3_beta_2" ]; then
        #### iOS 6.1.3 beta 2 (BrightonMaps 10B318) ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b66: 00200020"   #* unconfirmed *#
        iOSVersion="6.1.3_10B311"
        iOSBuild="10B311"
        RestoreRamdisk="048-0987-008.dmg"
        iBoot_Key="f0943a042103e899250e62043ce8a7d24a446eac77366fcdc12cd21a28828af9"
        iBoot_IV="c13c3705190682c2d4253ecea7910c56"
        DeveloperBeta=1
    fi

    if [ $2 = "6.1.3" ]; then
        #### You need to create a bundle yourself   ####
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.1.3_10B329"
        iOSBuild="10B329"
        RestoreRamdisk="048-2548-005.dmg"
        iBoot_Key="f0943a042103e899250e62043ce8a7d24a446eac77366fcdc12cd21a28828af9"
        iBoot_IV="c13c3705190682c2d4253ecea7910c56"
        if [ -d "FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle" ]; then
            DD=1
        else
            echo "[ERROR] Firmwarebundle was not found."
            echo "[ERROR] You need to create a bundle yourself."
        fi
    fi


    if [ $2 = "6.1.4" ]; then
        #### iOS 6.1.4 ####
        ## iBoot-1537.9.55~11
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.1.4_10B350"
        iOSBuild="10B350"
        RestoreRamdisk="048-2930-001.dmg"
        iBoot_Key="f0943a042103e899250e62043ce8a7d24a446eac77366fcdc12cd21a28828af9"
        iBoot_IV="c13c3705190682c2d4253ecea7910c56"
        DD=1
    fi

    if [ $2 = "7.0_beta" ]; then
        #### iOS 7.0 beta (InnsbruckVailPrime 11A4372q) ####
        #### This version is beta version               ####
        #### You need to create a bundle yourself       ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b34: 00200020"
        iOSVersion="7.0_11A4372q"
        iOSBuild="11A4372q"
        RestoreRamdisk="048-3678-029.dmg"
        iBoot_Key="985bc1f5827c541a0937eeb2b336bbec1988d2583024a8cd99e3e838b71c40a1"
        iBoot_IV="0a4fe3b14bd6d73e1d8cf5d77e91d4a0"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0_beta_2" ]; then
        #### iOS 7.0 beta 2 (InnsbruckVailPrime 11A4400f)   ####
        #### This version is beta version                   ####
        #### You need to create a bundle yourself           ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b34: 00200020"
        iOSVersion="7.0_11A4400f"
        iOSBuild="11A4400f"
        RestoreRamdisk="048-6332-010.dmg"
        iBoot_Key="2eca7f9f3c553b8a6ad092c071bcc122b9bcfc81ff6e8c68c737396bea1c58e4"
        iBoot_IV="43b47e54aa5d7e6e9df8a36f2e111e35"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0_beta_3" ]; then
        #### iOS 7.0 beta 3 (InnsbruckVailPrime 11A4414e)   ####
        #### This version is beta version                   ####
        #### You need to create a bundle yourself           ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0_11A4414e"
        iOSBuild="11A4414e"
        RestoreRamdisk="048-7288-001.dmg"
        iBoot_Key="b56b939b94e6797a32f76ad25e4e1eced1ff63f65c081f85bcd92cd43f590fa6"
        iBoot_IV="baa175db8a1988de27270f5cc994db5c"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0_beta_4" ]; then
        #### iOS 7.0 beta 4 (InnsbruckVailPrime 11A4435d)   ####
        #### This version is beta version                   ####
        #### You need to create a bundle yourself           ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0_11A4435d"
        iOSBuild="11A4435d"
        RestoreRamdisk="048-7355-008.dmg"
        iBoot_Key="fee04ddd5ccb82c2d22134ccbc5b694cead6a88d4d93314b7e57aace89ffdb6a"
        iBoot_IV="02ac090e2eafd2e4080a9f6312719ee0"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0_beta_5" ]; then
        #### iOS 7.0 beta 5 (InnsbruckVailPrime 11A4449a)   ####
        #### This version is beta version                   ####
        #### You need to create a bundle yourself           ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0_11A4449a"
        iOSBuild="11A4449a"
        RestoreRamdisk="048-7747-009.dmg"
        iBoot_Key="068b9890c1d08f104b575b528eb83f574306e91445b54c89b623fc2708200ee3"
        iBoot_IV="d086a37e609fedaf1b853c461cc59d79"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0_beta_6" ]; then
        #### iOS 7.0 beta 6 (InnsbruckVailPrime 11A4449d)   ####
        #### This version is beta version                   ####
        #### You need to create a bundle yourself           ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0_11A4449d"
        iOSBuild="11A4449d"
        RestoreRamdisk="048-7885-001.dmg"
        iBoot_Key="068b9890c1d08f104b575b528eb83f574306e91445b54c89b623fc2708200ee3"
        iBoot_IV="d086a37e609fedaf1b853c461cc59d79"
        DeveloperBeta=1
    fi

    if [ $2 = "7.0" ]; then
        #### iOS 7.0 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0_11A465"
        iOSBuild="11A465"
        RestoreRamdisk="038-3474-250.dmg"
        iBoot_Key="2a60116e0f4c6ef3f7773f2f32ae045c665acad5956f285da035b9f34b794e85"
        iBoot_IV="eafb2c963f6d05cc40b1146abd2e7856"
        DD=1
    fi

    if [ $2 = "7.0.2" ]; then
        #### iOS 7.0.2 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0.2_11A501"
        iOSBuild="11A501"
        RestoreRamdisk="048-9014-002.dmg"
        iBoot_Key="eeac299d3c9ec73b04aa6dd16aea599fa88b486032a33cc58b44db7d6ee415de"
        iBoot_IV="4ce21efa022a581bb7db2d4b791b8af3"
        DD=1
    fi

    if [ $2 = "7.0.3" ]; then
        #### iOS 7.0.3 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0.3_11B511"
        iOSBuild="11B511"
        RestoreRamdisk="058-0174-001.dmg"
        iBoot_Key="75f78b0857a98c33e1a728a88c9a738fe3cf2f188baffd12236fa4832db95390"
        iBoot_IV="8f66deb83d46d65c5df4d8ff13ef5614"
        DD=1
    fi

    if [ $2 = "7.0.4_technical_leak" ]; then
        #### iOS 7.0.4 InnsbruckTaos 11B553           ####
        #### it was discovered from a technical leak. ####
        #### You need to create a bundle yourself     ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0.4_11B553"
        iOSBuild="11B553"
        RestoreRamdisk="058-0403-004.dmg"
        iBoot_Key="d2c7dbef4dc6e878869f9cee6d9eb479a5811a1a7d3d5e81daa0b2fcfe6909e4"
        iBoot_IV="b3a9e437802f5aed6b73b6d738b18275"
        if [ -d "FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle" ]; then
            DD=1
        else
            echo "[ERROR] Firmwarebundle was not found."
            echo "[ERROR] You need to create a bundle yourself."
        fi
    fi

    if [ $2 = "7.0.4" ]; then
        #### iOS 7.0.4 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0.4_11B554a"
        iOSBuild="11B554a"
        RestoreRamdisk="058-1089-002.dmg"
        iBoot_Key="d2c7dbef4dc6e878869f9cee6d9eb479a5811a1a7d3d5e81daa0b2fcfe6909e4"
        iBoot_IV="b3a9e437802f5aed6b73b6d738b18275"
        DD=1
    fi

    if [ $2 = "7.0.6" ]; then
        #### iOS 7.0.6 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.0.6_11B651"
        iOSBuild="11B651"
        RestoreRamdisk="058-3121-001.dmg"
        iBoot_Key="be934f7bc2b1837ab061a8b4356b41622a80878c8ed8152a5fb741e488b63dc1"
        iBoot_IV="62da3218997c76cb75e83754df8b7639"
        DD=1
    fi

    if [ $2 = "7.1_beta" ]; then
        #### iOS 7.1 beta (SochiVail 11D5099e)     ####
        #### This version is beta version          ####
        #### You need to create a bundle yourself  ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020" #* unconfirmed *#
        Boot_Ramdisk_Patch="0000b24: 00200020"   #* unconfirmed *#
        iOSVersion="7.1_11D5099e"
        iOSBuild="11D5099e"
        RestoreRamdisk="058-1030-007.dmg"
        iBoot_Key="c101a5c6e2aafa124f26840732274bcf292d22a60058caa6c6ad338c55e52708"
        iBoot_IV="278c761fb58c01f9db1c3edef19af62f"
        DeveloperBeta=1
    fi

    if [ $2 = "7.1_beta_2" ]; then
        #### iOS 7.1 beta 2 (SochiVail 11D5115d)   ####
        #### This version is beta version          ####
        #### You need to create a bundle yourself  ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1_11D5115d"
        iOSBuild="11D5115d"
        RestoreRamdisk="058-1620-005.dmg"
        iBoot_Key="742d36c42fc4fd86ec279a8ec67b451e2025af6188ca8ffbf7ddcdd10d7e349e"
        iBoot_IV="357fa0d3c049473019800db09f0e4d62"
        DeveloperBeta=1
    fi

    if [ $2 = "7.1_beta_3" ]; then
        #### iOS 7.1 beta 3 (SochiVail 11D5127c)   ####
        #### This version is beta version          ####
        #### You need to create a bundle yourself  ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1_11D5127c"
        iOSBuild="11D5127c"
        RestoreRamdisk="058-1953-004.dmg"
        iBoot_Key="6af81ebdfbaa046566cafe4a301e4c2f2c56e47fab327bdeb13dd3d44d17c2b4"
        iBoot_IV="9fc3ed515a7c10a36709c09d0794de54"
        DeveloperBeta=1
    fi

    if [ $2 = "7.1_beta_4" ]; then
        #### iOS 7.1 beta 4 (SochiVail 11D5134c)   ####
        #### This version is beta version          ####
        #### You need to create a bundle yourself  ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1_11D5134c"
        iOSBuild="11D5134c"
        RestoreRamdisk="058-2055-004.dmg"
        iBoot_Key="4e54b1a396f598791ed4392968edf8ef5388cf963cf3ada2177a7c5cd0cd3609"
        iBoot_IV="0b55f5292924478d5b23c763672044e3"
        DeveloperBeta=1
    fi

    if [ $2 = "7.1_beta_5" ]; then
        #### iOS 7.1 beta 5 (SochiVail 11D5145e)   ####
        #### This version is beta version          ####
        #### You need to create a bundle yourself  ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1_11D5145e"
        iOSBuild="11D5145e"
        RestoreRamdisk="058-2445-007.dmg"
        iBoot_Key="2e82aa5e367611b59ea80acf1a2e7168b60b0774a29e297ea18f8236697f2711"
        iBoot_IV="d51a959a1971238bf3a0c20e4805315a"
        DeveloperBeta=1
    fi

    if [ $2 = "7.1" ]; then
        #### iOS 7.1 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1_11D167"
        iOSBuild="11D167"
        RestoreRamdisk="058-4276-001.dmg"
        iBoot_Key="cb43628b21c5e466d311bc494371d0809c82add85e30e1c39336aa7252889627"
        iBoot_IV="48603d58be5e9f04d405a93ad0b2e313"
        DD=1
    fi

    if [ $2 = "7.1.1" ]; then
        #### iOS 7.1.1 ####
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1.1_11D201"
        iOSBuild="11D201"
        RestoreRamdisk="058-00219-002.dmg"
        iBoot_Key="af601e09c5a1374d3a5e601c772b350ee87539b1a8a9929abf5df08c76e73616"
        iBoot_IV="ae9035bbbc18a942fcfda4cdef24af8c"
        DD=1
    fi

    if [ $2 = "7.1.2" ]; then
        #### iOS 7.1.2 ####
        ## iBoot-1940.10.58~132
        iOSLIST="7"
        Boot_Partition_Patch="0000a7c: 00200020"
        Boot_Ramdisk_Patch="0000b24: 00200020"
        iOSVersion="7.1.2_11D257"
        iOSBuild="11D257"
        RestoreRamdisk="058-4276-009.dmg"
        iBoot_Key="b23dbe781086f6000cba372e5e8ae01c3f61c032ab1fb6729129707e3ccb9463"
        iBoot_IV="422b9c5e642ff797dc38b9910f084826"
        DD=1
    fi

    if [ $2 = "8.0.2" ]; then
        #### iOS 8.0.2 ####
        ## iBoot-2261.1.68~1
        iOSLIST="7"
        disablekaslr=1
        sbops_patch=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000a60: 00200020"
        Boot_Ramdisk_Patch="0000b16: 00200020"
        iBEC_KASLR="001c5ff: E0" ## kaslr_patch_addr - ibec_base_addr (0xbff00000) + img3_header(0x40)
        iOSVersion="8.0.2_12A405"
        iOSBuild="12A405"
        RestoreRamdisk="058-04628-039.dmg"
        iBoot_Key="638c6637f20a85d04f7110a50759c79dd94a80e8eef95956c3b6f3dfe3ad353b"
        iBoot_IV="b1dbd4dcb1dc0cc609f7c58073cd1900"
        DD=1
    fi

    if [ $2 = "9.0_beta" ]; then
        #### iOS 9.0 beta                           ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b0e: 00200020"
        Boot_Ramdisk_Patch="0000bca: 00200020"
        iBoot9_Partition_Patch="00013b0: f48cf3bf"
        iOSVersion="9.0_13A4254v"
        iOSBuild="13A4254v"
        RestoreRamdisk="058-20975-024.dmg"
        iBoot_Key="66516901081801e5294d0465af738046778e6661b57f91dfcaf2f0c174580bee"
        iBoot_IV="7c2b36a9fdb6c57021805dbfa6f502ac"
        DeveloperBeta=1
    fi

    if [ $2 = "9.0_beta_2" ]; then
        #### iOS 9.0 beta 2                         ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b0e: 00200020"
        Boot_Ramdisk_Patch="0000c06: 00200020"
        iBoot9_Partition_Patch="00013f0: b391f3bf"
        iOSVersion="9.0_13A4280e"
        iOSBuild="13A4280e"
        RestoreRamdisk="058-20975-033.dmg"
        iBoot_Key="05edaa79aaec4882ac3a628255b09697f9cb1bb3b1def9a98ce7641943e6951d"
        iBoot_IV="ddbe16684e2b37badca22ce2f73b7efa"
        DeveloperBeta=1
    fi

    if [ $2 = "9.0_beta_3" ]; then
        #### iOS 9.0 beta 3                         ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: b391f3bf"
        iOSVersion="9.0_13A4293g"
        iOSBuild="13A4293g"
        RestoreRamdisk="058-20975-042.dmg"
        iBoot_Key="2f67b0693946e3e1b411a22d18ff53bedf44bb6fe0dc4a46d08e220bb9b6adb4"
        iBoot_IV="eee4cd54e5f7a028fc1611f05b63db25"
        DeveloperBeta=1
    fi

    if [ $2 = "9.0_beta_4" ]; then
        #### iOS 9.0 beta 4                         ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: b391f3bf"
        iOSVersion="9.0_13A4305g"
        iOSBuild="13A4305g"
        RestoreRamdisk="058-20975-051.dmg"
        iBoot_Key="0cdd9dce1565f2fccbc80a288ddf4daf5e0a50d1ba7e01c1d3ea4822456492b7"
        iBoot_IV="aadda07a8b3fcb1de0654b0e09ac49ac"
        DeveloperBeta=1
    fi

    if [ $2 = "9.0_beta_5" ]; then
        #### iOS 9.0 beta 5                         ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.0_13A4325c"
        iOSBuild="13A4325c"
        RestoreRamdisk="058-20975-058.dmg"
        iBoot_Key="61583959631576e661055a7be2a6c293237212f2f577a08be31da3007c15cb67"
        iBoot_IV="5e765d509ce413e7ef18f79e4d851b2d"
        DeveloperBeta=1
    fi

    if [ $2 = "9.0_GM" ]; then
        #### iOS 9.0 GM                             ####
        #### This version is beta version           ####
        #### You need to create a bundle yourself   ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        pangu9=0
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.0_13A340"
        iOSBuild="13A340"
        RestoreRamdisk="058-03706-362.dmg"
        iBoot_Key="ee89f3fec20ee389f37689eea8894d3e3c76d2f4ed204c3c5c85d6d19e296647"
        iBoot_IV="df76f53c1983514eb8cf32c19310d2a4"
        DeveloperBeta=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.0" ]; then
        #### iOS 9.0 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        pangu9=0
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.0_13A344"
        iOSBuild="13A344"
        RestoreRamdisk="058-03706-363.dmg"
        iBoot_Key="8667fe328a7dd41fde7dd8b34919718b99143638679c82431a621bb2143ea078"
        iBoot_IV="547e2505ec2c8b0517fad1d308b6abc8"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.0.1" ]; then
        #### iOS 9.0.1 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        pangu9=0
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.0.1_13A404"
        iOSBuild="13A404"
        RestoreRamdisk="058-03706-367.dmg"
        iBoot_Key="cdaefe386c1fc8adc896c7b6088202dfb8b8c0d06042b1bd383e351584e2868f"
        iBoot_IV="ca6241f72e6d34ba923f15faf86d0dbf"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.0.2" ]; then
        #### iOS 9.0.2 ####
        ## iBoot-2817.1.94~1
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        pangu9=0
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.0.2_13A452"
        iOSBuild="13A452"
        RestoreRamdisk="058-03706-369.dmg"
        iBoot_Key="b6a0fecaf54e3ebe46c670e74f92f053433f2b7b32d33453b5dbf75b3bdfe612"
        iBoot_IV="23b4fc8e6f8b6aa20e8ab2380b3ee542"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.1" ]; then
        #### iOS 9.1 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: 3392f3bf"
        iOSVersion="9.1_13B143"
        iOSBuild="13B143"
        RestoreRamdisk="058-25124-078.dmg"
        iBoot_Key="08a8b399604b3f0a645499da9ced989c0286393e2c8d2fcea197fbe4891e1b6d"
        iBoot_IV="4a89aa4c72bf5a6128738f9447f8c6f7"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.2" ]; then
        #### iOS 9.2 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: c392f3bf"
        iOSVersion="9.2_13C75"
        iOSBuild="13C75"
        RestoreRamdisk="058-25952-079.dmg"
        iBoot_Key="43dd2a62ca1bc2ab9dd80237f65d0fcc345bfa8b4b687126974c292fed7de455"
        iBoot_IV="809117c933e30063fdbef74484af8f6d"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.2.1" ]; then
        #### iOS 9.2.1 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b12: 00200020"
        Boot_Ramdisk_Patch="0000c0a: 00200020"
        iBoot9_Partition_Patch="00013f0: c392f3bf"
        iOSVersion="9.2.1_13D15"
        iOSBuild="13D15"
        RestoreRamdisk="058-32359-015.dmg"
        iBoot_Key="c10a16bb567e8e96db7162d44cd666e513df771a9742371f4f84466ad44fd25a"
        iBoot_IV="13420d70c4af0e7c796a66f611889b2f"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3" ]; then
        #### iOS 9.3 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3_13E233"
        iOSBuild="13E233"
        RestoreRamdisk="058-25481-331.dmg"
        iBoot_Key="c1c36ffd890e23a9774b9ce717bfc0e37ed9b6cd8534e61d1ad0b4472caa61d1"
        iBoot_IV="196a1583b56587544d11b931f0c0774a"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3r" ]; then
        #### iOS 9.3 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3_13E237"
        iOSBuild="13E237"
        RestoreRamdisk="058-25481-332.dmg"
        iBoot_Key="c1c36ffd890e23a9774b9ce717bfc0e37ed9b6cd8534e61d1ad0b4472caa61d1"
        iBoot_IV="196a1583b56587544d11b931f0c0774a"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3.1" ]; then
        #### iOS 9.3.1 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3.1_13E238"
        iOSBuild="13E238"
        RestoreRamdisk="058-25481-333.dmg"
        iBoot_Key="c1c36ffd890e23a9774b9ce717bfc0e37ed9b6cd8534e61d1ad0b4472caa61d1"
        iBoot_IV="196a1583b56587544d11b931f0c0774a"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3.2" ]; then
        #### iOS 9.3.2 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3.2_13F69"
        iOSBuild="13F69"
        RestoreRamdisk="058-37546-072.dmg"
        iBoot_Key="3341eef99ca9cd617f767b83cb02dde368eef0a18e87480cea53efc5b39fd954"
        iBoot_IV="9ff772c17dd807f771fc53f6542fafb6"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3.3" ]; then
        #### iOS 9.3.3 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3.3_13G34"
        iOSBuild="13G34"
        RestoreRamdisk="058-49199-034.dmg"
        iBoot_Key="5705c05a5872b903b234edbee2fb75b42fa7ee7b26176f1b79eb2a398f2dbddb"
        iBoot_IV="bfc2716df03cabc915daa041bc0b0865"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3.4" ]; then
        #### iOS 9.3.4 ####
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iOSVersion="9.3.4_13G35"
        iOSBuild="13G35"
        RestoreRamdisk="058-49199-035.dmg"
        iBoot_Key="9a6a8533a01050926af980cdeada174678745487abf9dea019c97e6e8f662f5f"
        iBoot_IV="7ff8a2334f4594dd52a130a8e1e8b6b2"
        BundleType="New"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

    if [ $2 = "9.3.5" ]; then
        #### iOS 9.3.5 ####
        ## iBoot-2817.60.2~2
        iOSLIST="7"
        sbops_patch=1
        iBoot9=1
        iBootInternalName="n42"
        Boot_Partition_Patch="0000b1e: 00200020"
        Boot_Ramdisk_Patch="0000c16: 00200020"
        iBoot9_Partition_Patch="0001400: 439af3bf"
        iBoot_KASLR="001a1fa: 00bf002100bf"
        iOSVersion="9.3.5_13G36"
        iOSBuild="13G36"
        RestoreRamdisk="058-49199-036.dmg"
        iBoot_Key="d958a3bfdf81fc24114183eec0c1a1e994723772129b5719efad04e504c06f08"
        iBoot_IV="7d7d25b9f8d6d3ea15195f97f429e76e"
        DD=1
        if [ $4 = "--jb" ]; then
            JB=1
            sbops_patch=0
        fi
    fi

fi

#### iPhone 5 (GSM) [BETA] ####
if [ $Identifier = "iPhone5,1" ]; then
    if [ $2 = "6.1.4" ]; then
        #### iOS 6.1.4 ####
        ## iBoot-1537.9.55~11
        iOSLIST="6"
        Boot_Partition_Patch="0000a94: 00200020"
        Boot_Ramdisk_Patch="0000b66: 00200020"
        iOSVersion="6.1.4_10B350"
        iOSBuild="10B350"
        RestoreRamdisk="048-2930-001.dmg"
        iBoot_Key="71605675477ca04856736b74d8c058e377efe1b0969c61af57a100634c35a4e3"
        iBoot_IV="d2bddadd45899292efdd0f8349d9cec0"
        DD=1
    fi
fi

if [ $DeveloperBeta == 1 ]; then
    if [ -d "FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle" ]; then
        DD=1
    else
        echo "[ERROR] Firmwarebundle was not found."
        echo "[ERROR] You need to create a bundle yourself."
    fi

fi

if [ $DD == 0 ]; then
    echo "[ERROR] This downgrade-iOS is NOT supported!"
    exit
fi

if [ $# == 4 ]; then
    if [ $4 = "--jb" ]&&[ $JB != 1 ]; then
        echo "[ERROR] This version is NOT supported jailbreak!"
        exit
    fi
fi

if [ $iOSBuild != "11D257" ]&&[ $Identifier != "iPhone3,1" ]&&[ $Remove_Exploit == 1 ]; then
    echo "[ERROR] This version is NOT supported option!"
    exit
fi

### look ipsw??
if [ -e ""$Identifier"_"$iOSVersion"_Restore.ipsw" ]; then
    echo ""$Identifier"_"$iOSVersion"_Restore.ipsw OK"
else
    echo ""$Identifier"_"$iOSVersion"_Restore.ipsw does not exist"
    exit
fi

if [ -d "tmp_ipsw" ]; then
    rm -r tmp_ipsw
fi

echo ""

mkdir tmp_ipsw
cd tmp_ipsw

#### Decrypt iBoot ####
unzip -j ../"$Identifier"_"$iOSVersion"_Restore.ipsw "Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3"
../bin/xpwntool iBoot."$iBootInternalName".RELEASE.img3 iBoot."$iBootInternalName".dec.img3 -k $iBoot_Key -iv $iBoot_IV -decrypt
../bin/xpwntool iBoot."$iBootInternalName".dec.img3 iBoot."$iBootInternalName".dec
echo ""

if [ "$iOSLIST" = "4" ]; then
    #### Patching iBoot - iOS 4.3.5 ####
    bspatch iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec ../FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle/iBoot."$iBootInternalName".RELEASE.patch
    ../bin/xpwntool PwnediBoot."$iBootInternalName".dec iBoot -t iBoot."$iBootInternalName".dec.img3
    echo "0000010: 63656269" | xxd -r - iBoot
    echo "0000020: 63656269" | xxd -r - iBoot
    tar -cvf bootloader.tar iBoot
fi

if [ "$iOSLIST" != "4" ]; then
    #### Patching iBoot5/6/7 ####
    if [ $# -lt 4 ]; then
        ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r
    fi

    if [ $# == 4 ]; then
        if [ $4 = "--verbose" ]; then
            ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -b "-v"
        fi

        if [ $4 = "----csdisable" ]; then
            if [ $iOSLIST = "6" ]; then
                ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -d -b "cs_enforcement_disable=1 amfi=0xff"
            fi
            if [ $iOSLIST = "7" ]; then
                ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -d -b "cs_enforcement_disable=1 amfi_get_out_of_my_way=1"
            fi
        fi

        if [ $4 = "----verbose-csdisable" ]; then
            if [ $iOSLIST = "6" ]; then
                ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -d -b "cs_enforcement_disable=1 amfi=0xff -v"
            fi
            if [ $iOSLIST = "7" ]; then
                ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -d -b "cs_enforcement_disable=1 amfi_get_out_of_my_way=1 -v"
            fi
        fi

        if [ $4 = "--jb" ]; then
            ../bin/iBoot32Patcher iBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec -r -d -b "cs_enforcement_disable=1 amfi_get_out_of_my_way=1 -v"
            echo "$iBoot_KASLR" | xxd -r - PwnediBoot."$iBootInternalName".dec
        fi
    fi

    echo "$Boot_Partition_Patch" | xxd -r - PwnediBoot."$iBootInternalName".dec
    if [ $Identifier != "iPhone3,1" ]; then
        echo "$Boot_Ramdisk_Patch" | xxd -r - PwnediBoot."$iBootInternalName".dec
        if [ $iOSLIST = "6" ]; then
            ../bin/iBoot32Patcher PwnediBoot."$iBootInternalName".dec PwnediBoot2."$iBootInternalName".dec -r
            rm PwnediBoot."$iBootInternalName".dec
            mv PwnediBoot2."$iBootInternalName".dec PwnediBoot."$iBootInternalName".dec
        fi

        if [ $iBoot9 == 1 ]; then
            echo "$iBoot9_Partition_Patch" | xxd -r - PwnediBoot."$iBootInternalName".dec
        fi
    fi

    ../bin/xpwntool PwnediBoot."$iBootInternalName".dec PwnediBoot."$iBootInternalName".img3 -t iBoot."$iBootInternalName".dec.img3
    echo "0000010: 63656269" | xxd -r - PwnediBoot."$iBootInternalName".img3
    echo "0000020: 63656269" | xxd -r - PwnediBoot."$iBootInternalName".img3
    mv -v PwnediBoot."$iBootInternalName".img3 iBEC
    tar -cvf bootloader.tar iBEC
fi

cd ../

#### Make custom ipsw by odysseus ####
if [ $iOSLIST = "4" ]&&[ $Identifier = "iPhone3,1" ]&&[ $Remove_Exploit != 1 ]; then
    ./bin/ipsw "$Identifier"_"$iOSVersion"_Restore.ipsw tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw -memory
fi

if [ $iOSLIST != "4" ]&&[ $Identifier = "iPhone3,1" ]&&[ $Remove_Exploit != 1 ]; then
    ./bin/ipsw "$Identifier"_"$iOSVersion"_Restore.ipsw tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw -memory tmp_ipsw/bootloader.tar
fi

if [ $Identifier = "iPhone3,1" ]&&[ $Remove_Exploit == 1 ]; then
    ./bin/ipsw "$Identifier"_"$iOSVersion"_Restore.ipsw tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw -memory
fi

if [ $Chip != "A4" ]&&[ $JB != 1 ]; then
    ./bin/ipsw "$Identifier"_"$iOSVersion"_Restore.ipsw tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw -bbupdate -memory tmp_ipsw/bootloader.tar
fi

if [ $Identifier = "iPhone5,2" ]&&[ $JB == 1 ]; then
    ./bin/ipsw "$Identifier"_"$iOSVersion"_Restore.ipsw tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw -bbupdate -memory tmp_ipsw/bootloader.tar src/A6/jb9/packages.tar
fi

#### Confirm existence of firmware ####
if [ -e "tmp_ipsw/"$Identifier"_"$iOSVersion"_Odysseus.ipsw" ]; then
    echo "success"
else
    echo "[ERROR] failed make ipsw"
    exit
fi

#### Make CFW ####
cd tmp_ipsw

mkdir BaseFWBuild
unzip -j ../"$Identifier"_"$BaseFWVer"_"$BaseFWBuild"_Restore.ipsw "Firmware/all_flash/all_flash."$InternalName".production/*" -d BaseFWBuild

mkdir $iOSBuild
unzip -d $iOSBuild "$Identifier"_"$iOSVersion"_Odysseus.ipsw

if [ "$iOSLIST" = "4" ]; then
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging0-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging1-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batteryfull-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow0-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow1-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/glyphplugin-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/recoverymode-640x960."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/manifest

    echo "0000010: 34676F6C" | xxd -r - $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo-640x960."$SoC".img3
    echo "0000020: 34676F6C" | xxd -r - $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo-640x960."$SoC".img3

    mv -v ../src/"$ECID"-apticket.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/apticket.img3
    cp -a -v ../src/iPhone3,1/manifest4 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/manifest

    if [ "$OSXVer" -gt "10" ]; then
        mv -v $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/apticket.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogoT-640x960."$SoC".img3
        cp -a -v ../src/iPhone3,1/manifest4x $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/manifest
    fi

    mv -v BaseFWBuild/applelogo@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo7-640x960."$SoC".img3
    mv -v BaseFWBuild/batterycharging0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging0-640x960."$SoC".img3
    mv -v BaseFWBuild/batterycharging1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging1-640x960."$SoC".img3
    mv -v BaseFWBuild/batteryfull@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batteryfull-640x960."$SoC".img3
    mv -v BaseFWBuild/batterylow0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow0-640x960."$SoC".img3
    mv -v BaseFWBuild/batterylow1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow1-640x960."$SoC".img3
    mv -v BaseFWBuild/glyphplugin@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/glyphplugin-640x960."$SoC".img3
    mv -v BaseFWBuild/iBoot."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/LLB."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/recoverymode@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/recoverymode-640x960."$SoC".img3
fi

if [ "$iOSLIST" = "6" ]; then
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging0@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging1@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batteryfull@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow0@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow1@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/glyphplugin@2x."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/recoverymode@"$Size"~iphone."$SoC".img3

    mv -v BaseFWBuild/applelogo@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo@2x."$SoC".img3
    mv -v BaseFWBuild/batterycharging0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging0@2x."$SoC".img3
    mv -v BaseFWBuild/batterycharging1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging1@2x."$SoC".img3
    mv -v BaseFWBuild/batteryfull@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batteryfull@2x."$SoC".img3
    mv -v BaseFWBuild/batterylow0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow0@2x."$SoC".img3
    mv -v BaseFWBuild/batterylow1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow1@2x."$SoC".img3
    mv -v BaseFWBuild/glyphplugin@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/glyphplugin@2x."$SoC".img3
    mv -v BaseFWBuild/iBoot."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/LLB."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/recoverymode@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/recoverymode@"$Size"~iphone."$SoC".img3
fi

if [ "$iOSLIST" = "7" ]; then
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/applelogo@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging0@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterycharging1@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batteryfull@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow0@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/batterylow1@2x~iphone."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/glyphplugin@"$Image"."$SoC".img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    rm $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/recoverymode@"$Image"."$SoC".img3
    mv -v BaseFWBuild/applelogo@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/batterycharging0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/batterycharging1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/batteryfull@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/batterylow0@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/batterylow1@2x~iphone."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/glyphplugin@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
    mv -v BaseFWBuild/iBoot."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/iBoot."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/LLB."$InternalName".RELEASE.img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/LLB."$iBootInternalName".RELEASE.img3
    mv -v BaseFWBuild/recoverymode@"$Image"."$SoC".img3 $iOSBuild/Firmware/all_flash/all_flash."$InternalName".production/
fi

if [ $Identifier = "iPhone5,2" ]; then
    ## iPhone5,2 BB=8.02.00 (8.4.1 full OTA)
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:UniqueBuildID ../src/iPhone5,2/BB/UniqueBuildID" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:APPS-DownloadDigest ../src/iPhone5,2/BB/APPSDownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:APPS-HashTableDigest ../src/iPhone5,2/BB/APPSHashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP1-DownloadDigest ../src/iPhone5,2/BB/DSP1DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP1-HashTableDigest ../src/iPhone5,2/BB/DSP1HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP2-DownloadDigest ../src/iPhone5,2/BB/DSP2DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP2-HashTableDigest ../src/iPhone5,2/BB/DSP2HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP3-DownloadDigest ../src/iPhone5,2/BB/DSP3DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP3-HashTableDigest ../src/iPhone5,2/BB/DSP3HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:RPM-DownloadDigest ../src/iPhone5,2/BB/RPMDownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:RestoreSBL1-PartialDigest ../src/iPhone5,2/BB/RestoreSBL1PartialDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:SBL1-PartialDigest ../src/iPhone5,2/BB/SBL1PartialDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:SBL2-DownloadDigest ../src/iPhone5,2/BB/SBL2DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:RestoreSBL1-Version "-1559152312"" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:SBL1-Version "-1560200888"" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:Info:Path "Firmware/Mav5-8.02.00.Release.bbfw"" $iOSBuild/BuildManifest.plist

    cp -a -v ../src/iPhone5,2/BB/Mav5-8.02.00.Release.bbfw $iOSBuild/Firmware
    cp -a -v ../src/iPhone5,2/BB/Mav5-8.02.00.Release.plist $iOSBuild/Firmware
fi

### iPhone5,2_12H321_OTA ###
#BuildIdentities:0:UniqueBuildID    ybHEo3Fv0y/6IYp0X45hxqDY7zM=

#BuildIdentities:0:Manifest:BasebandFirmware:
#APPS-DownloadDigest                DJiAwPNNOmT4P9RdlHUt3Q2TTHc=
#APPS-HashTableDigest               x5Xkaqqkc+l3NFLL6s3kAi5P7Sk=
#DSP1-DownloadDigest                dFi5J+pSSqOfz31fIvmah2GJO+E=
#DSP1-HashTableDigest               HXUnmGmwIHbVLxkT1rHLm5V6iDM=
#DSP2-DownloadDigest                qtTu6JED2pyocdNVYT1uWN2Back=
#DSP2-HashTableDigest               2rQ7whhh/WrHPUPMwT5lcsIkYDA=
#DSP3-DownloadDigest                MZ1ERfoeFcbe79pFAl/hbWUSYKc=
#DSP3-HashTableDigest               sKmLhQcjfaOliydm+iwxucr9DGw=
#RPM-DownloadDigest                 051DfVgeFDI3DC9Hw35HGXCmgkM=
#RestoreSBL1-PartialDigest          fAAAAEAQAgDAcZDeGqmO8LWlCHcYIPVjFqR87A==
#RestoreSBL1-Version                -1559152312
#SBL1-PartialDigest                 ZAAAAIC9AQACxiFAOjelZm4NtrrLc8bPJIRQNA==
#SBL1-Version                       -1560200888
#SBL2-DownloadDigest                LycXsLwawICZf2dMjev2yhZs+ic=
#Info:Path                          Firmware/Mav5-8.02.00.Release.bbfw

if [ $Identifier = "iPhone5,1" ]; then
    ## iPhone5,1 BB=8.02.00 (8.4.1 full OTA)
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:UniqueBuildID ../src/iPhone5,1/BB/UniqueBuildID" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:APPS-DownloadDigest ../src/iPhone5,1/BB/APPSDownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:APPS-HashTableDigest ../src/iPhone5,1/BB/APPSHashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP1-DownloadDigest ../src/iPhone5,1/BB/DSP1DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP1-HashTableDigest ../src/iPhone5,1/BB/DSP1HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP2-DownloadDigest ../src/iPhone5,1/BB/DSP2DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP2-HashTableDigest ../src/iPhone5,1/BB/DSP2HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP3-DownloadDigest ../src/iPhone5,1/BB/DSP3DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:DSP3-HashTableDigest ../src/iPhone5,1/BB/DSP3HashTableDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:RPM-DownloadDigest ../src/iPhone5,1/BB/RPMDownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:RestoreSBL1-PartialDigest ../src/iPhone5,1/BB/RestoreSBL1PartialDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:SBL1-PartialDigest ../src/iPhone5,1/BB/SBL1PartialDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "Import BuildIdentities:0:Manifest:BasebandFirmware:SBL2-DownloadDigest ../src/iPhone5,1/BB/SBL2DownloadDigest" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:RestoreSBL1-Version "-1559152312"" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:SBL1-Version "-1560200888"" $iOSBuild/BuildManifest.plist
    /usr/libexec/PlistBuddy -c "set BuildIdentities:0:Manifest:BasebandFirmware:Info:Path "Firmware/Mav5-8.02.00.Release.bbfw"" $iOSBuild/BuildManifest.plist

    cp -a -v ../src/iPhone5,1/BB/Mav5-8.02.00.Release.bbfw $iOSBuild/Firmware
    cp -a -v ../src/iPhone5,1/BB/Mav5-8.02.00.Release.plist $iOSBuild/Firmware
fi

if [ $Identifier = "iPhone5,2" ]&&[ $disablekaslr == 1 ]; then
    echo $iBEC_KASLR | xxd -r - $iOSBuild/Firmware/dfu/iBEC.n42.RELEASE.dfu ## N42-iOS 8.0.2
fi

if [ $# == 4 ]; then
    if [ $Identifier = "iPhone5,2" ]&&[ $4 = "--jb" ]; then
        ../bin/xpwntool $iOSBuild/Downgrade/kernelcache.release.n42 $iOSBuild/kernelcache.release.dec
        ## kernelpacth by CBPatcher
        #bspatch $iOSBuild/kernelcache.release.dec $iOSBuild/pwnkernelcache.release.dec ../FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle/kernelcache.patch
        if [ $2 = "9.3r" ];then
            ../bin/CBPatcher $iOSBuild/kernelcache.release.dec $iOSBuild/pwnkernelcache.release.dec 9.3
        else
            ../bin/CBPatcher $iOSBuild/kernelcache.release.dec $iOSBuild/pwnkernelcache.release.dec "$2"
        fi
        mv -v $iOSBuild/Downgrade/kernelcache.release.n42 $iOSBuild/Downgrade/kernelcache.release.n42_
        ../bin/xpwntool $iOSBuild/pwnkernelcache.release.dec $iOSBuild/Downgrade/kernelcache.release.n42 -t $iOSBuild/Downgrade/kernelcache.release.n42_
        rm $iOSBuild/Downgrade/kernelcache.release.n42_
        rm $iOSBuild/kernelcache.release.n42
        cp -a -v $iOSBuild/Downgrade/kernelcache.release.n42 $iOSBuild/kernelcache.release.n42
        rm $iOSBuild/pwnkernelcache.release.dec
        rm $iOSBuild/kernelcache.release.dec
    fi
fi

if [ $Identifier = "iPhone5,2" ]&&[ $sbops_patch == 1 ]; then
    ../bin/xpwntool $iOSBuild/Downgrade/kernelcache.release.n42 $iOSBuild/Downgrade/kernelcache.release.dec
    bspatch $iOSBuild/Downgrade/kernelcache.release.dec $iOSBuild/Downgrade/pwnkernelcache.release.dec ../FirmwareBundles/"$BundleType"_"$Identifier"_"$iOSVersion".bundle/sbops.patch
    mv -v $iOSBuild/Downgrade/kernelcache.release.n42 $iOSBuild/Downgrade/kernelcache.release.n42_
    ../bin/xpwntool $iOSBuild/Downgrade/pwnkernelcache.release.dec $iOSBuild/Downgrade/kernelcache.release.n42 -t $iOSBuild/Downgrade/kernelcache.release.n42_

    rm $iOSBuild/Downgrade/kernelcache.release.n42_
    rm $iOSBuild/Downgrade/pwnkernelcache.release.dec
    rm $iOSBuild/Downgrade/kernelcache.release.dec
fi

#### make ramdisk ####
../bin/xpwntool $iOSBuild/$RestoreRamdisk $iOSBuild/ramdisk.dmg
if [ -e ""$iOSBuild"/ramdisk.dmg" ]; then
    echo "OK"
else
    echo "[ERROR] failed mount restore ramdisk"
    exit
fi

hdiutil resize $iOSBuild/ramdisk.dmg -size 30m
#n90 8l1     : 25 MB
#n90 9B176   : 17 MB
#n90 10B146  : 10 MB
#n42 13a452  : 21 MB
#n42 14A5261v: 24 MB


hdiutil attach -mountpoint ramdisk/ $iOSBuild/ramdisk.dmg

sleep 1s

if [ "$iOSLIST" = "4" ]; then
    mv -v ramdisk/sbin/reboot ramdisk/sbin/._
    tar -xvf ../src/iPhone3,1/bin4.tar -C ramdisk/ --preserve-permissions
    tar -xvf bootloader.tar -C ramdisk/ --preserve-permissions
fi

if [ "$iOSLIST" != "4" ]&&[ $Identifier = "iPhone3,1" ]; then
    tar -xvf ../src/iPhone3,1/bin.tar -C ramdisk/ --preserve-permissions
    mv -v ramdisk/sbin/reboot ramdisk/sbin/reboot_
    cp -a -v ../src/iPhone3,1/partition.sh ramdisk/sbin/reboot
    cp -a -v ../src/iPhone3,1/11D257/ramdiskH.dmg ramdisk/
    chmod 755 ramdisk/sbin/reboot
fi

if [ $Identifier = "iPhone5,2" ]; then
    tar -xvf ../src/A6/bin.tar -C ramdisk/ --preserve-permissions
    mv -v ramdisk/sbin/reboot ramdisk/sbin/reboot_
    if [ $pangu9 == 0 ]; then
        cp -a -v ../src/A6/partition_pg9.sh ramdisk/sbin/reboot
    else
        cp -a -v ../src/A6/partition.sh ramdisk/sbin/reboot
    fi
    cp -a -v ../src/iPhone5,2/11B554a/ramdiskH.dmg ramdisk/
    chmod 755 ramdisk/sbin/reboot
fi

if [ $Identifier = "iPhone5,1" ]; then
    tar -xvf ../src/A6/bin.tar -C ramdisk/ --preserve-permissions
    mv -v ramdisk/sbin/reboot ramdisk/sbin/reboot_
    cp -a -v ../src/A6/partition.sh ramdisk/sbin/reboot
    cp -a -v ../src/iPhone5,1/11B554a/ramdiskH.dmg ramdisk/
    chmod 755 ramdisk/sbin/reboot
fi

if [ "$iOSLIST" = "7" ]; then
    mv -v ramdisk/usr/share/progressui/applelogo@2x.tga ramdisk/usr/share/progressui/applelogo_orig.tga
    bspatch ramdisk/usr/share/progressui/applelogo_orig.tga ramdisk/usr/share/progressui/applelogo@2x.tga ../patch/applelogo7.patch
else
    mv -v ramdisk/usr/share/progressui/images-2x/applelogo.png ramdisk/usr/share/progressui/images-2x/applelogo_orig.png
    bspatch ramdisk/usr/share/progressui/images-2x/applelogo_orig.png ramdisk/usr/share/progressui/images-2x/applelogo.png ../patch/applelogo.patch
fi

if [ $# == 4 ]; then
    if [ $4 = "--jb" ]; then
        rm ramdisk/sbin/reboot
        cp -a -v ../src/A6/jb9/partition.sh ramdisk/sbin/reboot
        mkdir ramdisk/jb
        cp -a -v ../src/A6/jb9/fstab ramdisk/jb
        chmod 755 ramdisk/sbin/reboot
    fi
fi

if [ $Identifier = "iPhone3,1" ]&&[ $Remove_Exploit == 1 ]; then
    rm -rf ramdisk/sbin/reboot
    rm -rf ramdisk/ramdiskH.dmg
    cp -a -v ../src/iPhone3,1/remove_exploit.sh ramdisk/sbin/reboot
    chmod 755 ramdisk/sbin/reboot
fi

sleep 1s

hdiutil detach ramdisk/
sleep 1s

mv $iOSBuild/$RestoreRamdisk $iOSBuild/t.dmg
../bin/xpwntool $iOSBuild/ramdisk.dmg $iOSBuild/$RestoreRamdisk -t $iOSBuild/t.dmg
rm $iOSBuild/ramdisk.dmg
rm $iOSBuild/t.dmg

rm -r BaseFWBuild

#### zipping ipsw ####
cd $iOSBuild
zip ../../"$Identifier"_"$iOSVersion"_Custom.ipsw -r0 *

#### clean up ####
cd ../../
rm -r tmp_ipsw

#### Done ####
echo "Done!"
