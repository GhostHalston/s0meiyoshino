#!/bin/bash
echo "**** s0meiyoshino v4.0 alpha-5 restore4.sh ****"
echo "iPhone3,1 only"

OSXVer=`sw_vers -productVersion | awk -F. '{print $2}'`

echo "Select restore iOS version"
select iOSVer in "4.3.3 [8J2]" "4.3.4 [8K2]" "4.3.5 [8L1]" "5.1.1 [9B206]" "6.0 [10A403]" "6.0.1 [10A523]" "6.1 [10B144]" "6.1.2 [10B146]" "6.1.3 [10B329]" "7.0 [11A465]" "7.0.2 [11A501]" "7.0.3 [11B511]" "7.0.4 [11B554a]" "7.0.6 [11B651]" "7.1 [11D169]" "7.1.1 [11D201]" "7.1.2 [11D257]" exit
do

####if [ "$iOSVer" = "4.2 [8C134]" ]; then
########iOSList="4"
########iOSVersion="4.2"
########iOS_IPSW="iPhone3,1_4.2_8C134"
########break
####fi

    if [ "$iOSVer" = "4.3.3 [8J2]" ]; then
        iOSList="4"
        iOSVersion="4.3.3"
        iOS_IPSW="iPhone3,1_4.3.3_8J2"
        break
    fi

    if [ "$iOSVer" = "4.3.4 [8K2]" ]; then
        iOSList="4"
        iOSVersion="4.3.4"
        iOS_IPSW="iPhone3,1_4.3.4_8K2"
        break
        fi

    if [ "$iOSVer" = "4.3.5 [8L1]" ]; then
        iOSList="4"
        iOSVersion="4.3.5"
        iOS_IPSW="iPhone3,1_4.3.5_8L1"
        break
    fi

    if [ "$iOSVer" = "5.1.1 [9B206]" ]; then
        iOSVersion="5.1.1"
        iOS_IPSW="iPhone3,1_5.1.1_9B206"
        break
    fi

    if [ "$iOSVer" = "6.0 [10A403]" ]; then
        iOSVersion="6.0"
        iOS_IPSW="iPhone3,1_6.0_10A403"
        break
    fi

    if [ "$iOSVer" = "6.0.1 [10A523]" ]; then
        iOSVersion="6.0.1"
        iOS_IPSW="iPhone3,1_6.0.1_10A523"
        break
    fi

    if [ "$iOSVer" = "6.1 [10B144]" ]; then
        iOSVersion="6.1"
        iOS_IPSW="iPhone3,1_6.1_10B144"
        break
    fi

    if [ "$iOSVer" = "6.1.2 [10B146]" ]; then
        iOSVersion="6.1.2"
        iOS_IPSW="iPhone3,1_6.1.2_10B146"
        break
    fi

    if [ "$iOSVer" = "6.1.3 [10B329]" ]; then
        iOSVersion="6.1.3"
        iOS_IPSW="iPhone3,1_6.1.3_10B329"
        break
    fi

    if [ "$iOSVer" = "7.0 [11A465]" ]; then
        iOSVersion="7.0"
        iOS_IPSW="iPhone3,1_7.0_11A465"
        break
    fi

    if [ "$iOSVer" = "7.0.2 [11A501]" ]; then
        iOSVersion="7.0.2"
        iOS_IPSW="iPhone3,1_7.0.2_11A501"
        break
    fi

    if [ "$iOSVer" = "7.0.3 [11B511]" ]; then
        iOSVersion="7.0.3"
        iOS_IPSW="iPhone3,1_7.0.3_11B511"
        break
    fi

    if [ "$iOSVer" = "7.0.4 [11B554a]" ]; then
        iOSVersion="7.0.4"
        iOS_IPSW="iPhone3,1_7.0.4_11B554a"
        break
    fi

    if [ "$iOSVer" = "7.0.6 [11B651]" ]; then
        iOSVersion="7.0.6"
        iOS_IPSW="iPhone3,1_7.0.6_11B651"
        break
    fi

    if [ "$iOSVer" = "7.1 [11D169]" ]; then
        iOSVersion="7.1"
        iOS_IPSW="iPhone3,1_7.1_11D169"
        break
    fi

    if [ "$iOSVer" = "7.1.1 [11D201]" ]; then
        iOSVersion="7.1.1"
        iOS_IPSW="iPhone3,1_7.1.1_11D201"
        break
    fi

    if [ "$iOSVer" = "7.1.2 [11D257]" ]; then
        iOSVersion="7.1.2"
        iOS_IPSW="iPhone3,1_7.1.2_11D257"
        break
    fi

    if [ "$iOSVer" = "exit" ]; then
        exit
    fi

done

cd ipwndfu
./ipwndfu -p
cd ../

### get shsh
if [ -e "iPhone3,1_7.1.2_11D257_Restore.ipsw" ]; then
    echo "getting shsh..."
    ECID="$((./bin/idevicerestore -t iPhone3,1_7.1.2_11D257_Restore.ipsw) | sed -n -e 's/^.*Found ECID //p')"
    if [ "$iOSVersion" != "7.1.2" ]; then
        mv -v shsh/$ECID-iPhone3,1-7.1.2.shsh shsh/$ECID-iPhone3,1-$iOSVersion.shsh
    fi
else
    echo "iPhone3,1_7.1.2_11D257_Restore.ipsw does not exist"
fi

### Restore
if [ "$OSXVer" -lt "11" ]; then
    ./bin/idevicerestore_old -e -w "$iOS_IPSW"_Custom.ipsw
else
    ./bin/idevicerestore -e -w "$iOS_IPSW"_Custom.ipsw
fi

echo "Done!"
