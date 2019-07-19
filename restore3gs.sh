#!/bin/bash
echo "**** s0meiyoshino v4.0 alpha-2 restore.sh ****"
echo "iPhone2,1 only"

OSXVer=`sw_vers -productVersion | awk -F. '{print $2}'`
SRTG="0"
ECID="0"
echo "Select restore iOS version"
select iOSVer in "3.0 [7A341]" "6.1.6 [10B500]" exit
do

    if [ "$iOSVer" = "3.0 [7A341]" ]; then
        iOSList=3
        iOSVersion="3.0"
        iOS_IPSW="iPhone2,1_3.0_7A341"
        break
    fi

    if [ "$iOSVer" = "6.1.6 [10B500]" ]; then
        iOSList=6
        iOSVersion="6.1.6"
        iOS_IPSW="iPhone2,1_6.1.6_10B500"
        break
    fi

    if [ "$iOSVer" = "exit" ]; then
        exit
    fi

done

cd ipwndfu
echo "Exploiting with limera1n..."
echo "*** based on limera1n exploit (heap overflow) by geohot ***"
SRTG="$((./ipwndfu -p) | sed -n -e 's/^.*SRTG://p')"
cd ..

### get shsh
echo "getting shsh..."
ECID="$((./bin/idevicerestore -t "$iOS_IPSW"_Custom.ipsw) | sed -n -e 's/^.*Found ECID //p')"
if [ $iOSList -lt 5 ]; then
cp -a -v shsh/.shsh shsh/$ECID-iPhone2,1-$iOSVersion.shsh
fi
if [ $iOSList -ge 5 ]; then
cp -a -v shsh/.apticket shsh/$ECID-iPhone2,1-$iOSVersion.shsh
fi
### Restore
if [ "$OSXVer" -lt "11" ]; then
    ./bin/idevicerestore_old -e -w "$iOS_IPSW"_Custom.ipsw
else
    ./bin/idevicerestore -e -w "$iOS_IPSW"_Custom.ipsw
fi

if [ $SRTG = "[iBoot-359.3.2]" ]; then
    echo "Your device will be stuck with a black screen.\nYou must apply alloc8 exploit with ipwndfu."
    echo "Put device in DFU mode, and execute \"bin/alloc8.sh\""
fi

echo "Done!"
