<h1>s0meiyoshino v3.5.8~2</h1>
<p>It is a downgrade and untethered jailbreak tool to iOS 4-9 that exploited the boot chain of iOS 7 iBoot using @xerub's De Rebus Antiquis.</p>
<p>Operation confirmed with OS X 10.10.5 and MacOS 10.13.5. It may <s>not</s> work??? in 10.14. <s>Please downgrade to High Sierra.</s></p>
<p>Please secure about 10 GB of free space.</p>
<br/>
<h2>Warning</h2>
<p>This tool enables exploit of iBoot.</p>
<p>Therefore your device can be attacked from iBoot.</p>
<p>If you have a blob, downgrade it using it is much safer.</p>
<p>In the case of iPhone 4, it does not matter because it is already pwned by Bootrom vulnerability.</p>
<br/>
<h2>Request</h2>
<p>OS X (macOS) 10.10.5 - 10.13.6</p>
<p>10 GB of free space</p>
<p>wget</p>
<br/>
<h2>Supported version</h2>
<h3>iPhone 4 (iPhone3,1)</h3>
<p>*Downgrade only</p>
<p>iOS 4: 4.3.5</p>
<p>iOS 5: 5.1.1 (9B206)</p>
<p>iOS 6: 6.0 - 6.1.3</p>
<p>iOS 7: 7.0 - 7.1.2</p>
<br/>
<h3>iPhone 5 (iPhone5,2)</h3>
<p>For iPhone 5, SHSH of either iOS 7.0 - 7.0.6 is required.</p>
<p>But, downgrade target SHSH is unnecessary!</p>
<br/>
<p>*Downgrade only</p>
<p>iOS 6: 6.0 - 6.1.2, 6.1.4</p>
<p>iOS 7: 7.0 - 7.1.2</p>
<p>iOS 8: 8.0.2</p>
<p>*Downgrade and untethered jailbreak</p>
<p>iOS 9: 9.0 - 9.3.5</p>
<br/>
<h3>iPhone 5 (iPhone5,1)</h3>
<p>*Downgrade only</p>
<p>iOS 6.1.4 (untest)</p>
<br/>
<p>The bundle is provided from <a href="https://github.com/dora2-iOS/xpwn/tree/master/ipsw-patch/FirmwareBundles">here</a>.</p>
<br/>
<h2>How to use</h2>
<h3>Download IPSW</h3>
<a href="https://ipsw.me">ipsw download (https://ipsw.me)</a><br/>
<p>Prepare put it firmware (base-ipsw, downgrade-ver-ipsw) in s0meiyoshino.<br/></p>
<br/>
<h3>Install packages</h3>
./install.sh<br/>
<br/>
<h3>make ipsw</h3>
<p>./make_ipsw.sh [device model] [downgrade-iOS] [base-iOS] [args]<br/>
<p></p>
<p>[OPTION]</p>
<p>--verbose                 : Inject Boot-args "-v"</p>
<p>--jb                      : Jailbreak iOS (iPhone5,2 9.x only) (BETA)</p>
<p></p>
<p>example: ./make_ipsw.sh iPhone5,2 6.1.4 7.0.4 --verbose</p>
<br/>
<h3>Restore (iPhone 4)</h3>
<p>First, put in device "DFU mode".</p>
<p>Then, execute the following.</p>
<p>./restore4.sh</p>
<br/>
<h3>Restore (iPhone 5)</h3>
<p>First, put shsh of 7.x in the shsh/ directory.</p>
<p>And, change shsh file name. If you want to downgrade to 6.1.4 on iPhone 5 (Global), it will be as follows.</p>
<p>[ECID]-iPhone5,2-7.0.x.shsh -> [ECID]-iPhone5,2-6.1.4.shsh</p>
<p></p>
<p>Next, put in device "kDFU mode" or "Pwned recovery mode".</p>
<p>Then, execute the following.</p>
<p>bin/idevicerestore -e -w [CUSTOM_IPSW]</p>
<br/>
<h2>How to delete exploit (iPhone 4)</h2>
<p>This method adds "boot-partition=2" to the nvram variable.</p>
<p>Even if you restore it with OFW in iTunes, it will be in recovery mode as it is.</p>
<p></p>
<p>It can be deleted in the following way.</p>
<p>(1) Make Remove Custom Firmware [./make_ipsw.sh iPhone3,1 7.1.2 7.1.2 --remove]</p>
<p>(2) Restore using RCFW</p>
<br/>
<h2>How to delete exploit (iPhone 5)</h2>
<p>This method adds "boot-partition", and "boot-ramdisk" to the nvram variable.</p>
<p>However, since iOS 9 and later ignore this, if you want to restore it, do as follows.</p>
<p>(1) Restore iOS 9.0 - 10.3.3</p>
<p>(2) Jailbreak</p>
<p>(4) Execution command "nvram -d boot-ramdisk"</p>
<p>(5) Reboot</p>
<br/>
<h2>Credit</h2>
<p>@xerub for <a href="https://xerub.github.io/ios/iboot/2018/05/10/de-rebus-antiquis.html">De Rebus Antiquis</a></p>
<p>@danzatt for <a href="https://github.com/danzatt/ios-dualboot">ios-dualboot(hfs_resize etc.)</a></p>
<p>Roderick W. Smith - for gptfdisk</p>
<p>@iH8sn0w for <a href="https://github.com/iH8sn0w/iBoot32Patcher">iBoot32Patcher</a></p>
<p>@tihmstar for <a href="https://github.com/tihmstar/iBoot32Patcher">Improvement of iBoot32Patcher</a>, and partialZipBrowser</p>
<p>@nyan_satan for <a href="https://github.com/NyanSatan/iBoot32Patcher">Improvement of iBoot32Patcher</a> and <a href="https://github.com/NyanSatan/TwistedMind2">TwistedMind2</a></p>
<p>@ShadowLee19 for bypass boot-partition and boot-ramdisk value iBoot patch</p>
<p>@JonathanSeals for <a href="https://github.com/JonathanSeals/CBPatcher">CBPatcher</a>, disable kaslr patch, and many tips</p>
<p>@Benfxmth for bypass reset boot-partition value iBoot patch, and many tips</p>
<p>@alitek123 for many Odysseus Bundles</p>
<p>@nyanko_kota for Tester on iPhone 4s</p>
<p>@winocm for opensn0w jailbreak patch</p>
<p>@daytonhasty for <a href="https://dayt0n.com/articles/Odysseus/">Odysseus</a></p>
<p>@libimobiledev for idevicerestore</p>
<p>@planetbeing for xpwn</p>
<p>@axi0mX for <a href="https://github.com/axi0mX/ipwndfu">ipwndfu</a></p>
<p>@posixninja and @pod2g for SHAtter exploit</p>
<br/>