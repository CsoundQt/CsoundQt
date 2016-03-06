# CsoundQt 0.9.2 released
 

version 0.9.2 is mostly a bug-fix release, adding also a number of new convenience features. The author of most of the commits is **Tarmo Johannes**. 
The work with html5 support has been carried on and many improvements introduced by **Michael Gogins**. Html5 support works currently only on Windows. Examples and documentation have been added or edited by **Joachim Heintz**, there have been commits by **Felipe Sateler** and **Johannes Schütt**.
 
The source and upcoming binaries can be downloaded from: <https://github.com/CsoundQt/CsoundQt/releases/tag/0.9.2>.

**CsoundQt Web page** has been moved to <http://csoundqt.github.io/> and updated. 

**Github** page is now <https://github.com/CsoundQt/CsoundQt>

Please note that from 0.9.2 on there is **develop branch** in CsoundQt's repository for latest improvements and fixes.

**Documentation and build instruction** have been improved and extended thoroughly, see 
<https://github.com/CsoundQt/CsoundQt/blob/master/BUILDING.md>      
<https://github.com/CsoundQt/CsoundQt/wiki>


Please note that from 0.9.2 on there is **develop branch** in CsoundQt's repository for latest improvements or, the stable release can be found from master branch. For instructions see  
<https://github.com/CsoundQt/CsoundQt/wiki/Checking-out-develop-branch>

### New in version 0.9.2:

* CsoundQt tries to keep **one running instance**. When new Csound file is opened in file manager, it forwards the file name to the running instance and it opens the file **in a new tab**. You can start also more than one instances of CsoundQt if you start the program without any arguments (i.e not opening a file).    

* For Unix/Linux builds there is now the **install target** for system wide installation (Run `sudo make install`). It installs and registers also mime-types for Csound files, a desktop start-up file and icon for CsoundQt. So it is now easy to open CsoundQt or any Csound files with CsoundQt.

* **Virtual MIDI keyboard** has been improved -  new sliders for control channels, possibility to **play notes on computer keys** (keyboard mapping is similar to Csound's VirtualMidi (Z - lowest C, S - C#, X - lowest D etc), see <http://www.csounds.com/manual/html/MidiTop.html>, Table 6

* There is ** Virtual MIDI keyboard button on toolbar**

* **Midi Learn button** is straight accessible from widget's properties dialog window.
 
* **MIDI button** (or similar controller) can **start a Csound event** defined in a Button Widget properties, if the type of the button is set to "event".



### Fixes

* *sensekey* works now when CsoundQt is launched  via desktop file or from Applications (Linux, OSX)

* Better search paths in project files to find *rtmidi* and *pythonqt* sources

* Fixed some paths and configuration for OSX build

* Fixed occasional pink widget panel background

* Restore cursor position after evaluating a section (on an arrow key press).

* Virtual Midi Keyboard is shown/hidden correctly on toggling the button/menu item, destroyed correctly on exit.

* Parenthesis markup is corrected so that it does not brake undo chain any more.

* Fixed selection end (mouse release) outside editor panel.

* Show Midi Learn and midi controls only for widgets that accept MIDI.

* Widgetpanel shown/hidden state gets restored correctly on strartup.

* Fixed Midi Learn CC number detection.

* Fixed indentation (many Tab presses actually create tabs)



### Plans for further development
* Table editor for GEN7 and GEN5 tables
* Import/export Cabbage files (conversion between CsoundQt widgets and Cabbage widgets -  partly done: Insert/Update Cabbage text)
* Work with QMLwidget 
* Test debugger and html5
* Work on UI and usability

### Full ChangeLog:

commit 4c99be421d3297706001afcac40881c40392d9a7
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Mar 6 13:39:50 2016 +0200

    Added Download manual act to help menu

commit 3a9179cd55b6464f57b2af87b7a7fecd0337078d
Author: joachim heintz <jh@joachimheintz.de>
Date:   Sat Mar 5 20:08:39 2016 +0100

    made ascii key example working with current csound

commit df2e027bd198f235e4bf29377af66c76009c12a0
Merge: 16979d6 abf5f6a
Author: tarmoj <tarmo@otsakool.edu.ee>
Date:   Fri Mar 4 23:47:28 2016 +0200

    Merge pull request #200 from ukelady/patch-1
    
    Add a link to detailed instructions for QtCreator

commit abf5f6a310a10bd75aa6281aa494324310ac984f
Author: mfl <ukelady@gmail.com>
Date:   Fri Mar 4 17:47:38 2016 +0100

    Add a link to detailed instructions for QtCreator
    
    It is not clear at this paragraph how to build CsoundQt with QtCreator - when I first read it, I didn't find a way to build it with QtCreator, so I went ahead building it with the command line, which failed after a few hours of trying different configurations. So a link at this paragraph to the wiki page would be helpful for newbies like me :)

commit 16979d6cbc0084271f06bfab1a559fd1df864d73
Author: joachim heintz <jh@joachimheintz.de>
Date:   Fri Mar 4 06:11:55 2016 +0100

    example working again

commit 3bde2739868b1138b29e36bcab912df7b00a2c48
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Mar 4 01:52:56 2016 +0200

    Updated opcode definitions from latest state in Csound Manual repository
    (plusbecomes and src_convole exludes, since had errors).

commit 896dbf91dc0eb391d7d26b1765348441484fffdf
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Thu Mar 3 01:14:15 2016 +0200

    Disable shadow build instruction for OSX

commit 87c1044878e334883121222169d5031399c9b181
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Mar 2 02:43:56 2016 +0200

    Info about develop branch, updated release notes

commit 7e255ce8180924f9435b7e516dcbbf1504c4895f
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Mar 1 03:18:44 2016 +0200

    Changed version number to 0.9.2

commit aa2b5c6c95e945ca92949871594b409f8361e6f2
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Mar 1 03:18:14 2016 +0200

    Small fix to bring VirtualMidiKeyboard to focus when switched on.

commit 0924e41894f7f1f793390e2d11d9e7ac3b682468
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Mar 1 03:02:43 2016 +0200

    Fixed sensekey problem. Now works also when launched via desktop.

commit cdc8ca4a387cb278ac10d87988fd8b5ccad14180
Merge: becf31c 63ec883
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 26 02:39:58 2016 +0200

    Merge branch 'master' of https://github.com/CsoundQt/CsoundQt

commit becf31ce99e0086457849c9b219c7aaca80448d2
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 26 02:39:26 2016 +0200

    draft for release notes

commit 63ec883174c54e04ecaf19c9c037a1c0190cef14
Author: Johannes Schütt <johannes.schuett@zhdk.ch>
Date:   Thu Feb 25 13:36:50 2016 +0100

    Update BUILDING.md
    
    I commit the changes for the User-Path:
    ex. /home/jh/src/PythonQt3.0/lib/ --->  shut be ~/src/PythonQt3.0/lib/
    In this case it works on all Users.

commit fe4004593c380fc7b7e46b0cf8ac0156b57e64c5
Author: Johannes Schütt <johannes.schuett@zhdk.ch>
Date:   Thu Feb 25 13:33:50 2016 +0100

    Update BUILDING.md

commit 7757dba93eb38726f4e60a51628b04cdee3237c3
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Feb 23 21:53:55 2016 +0200

    Minor clarification in Config dialog about MIDI

commit 4bb592ac1b7febb1a343716a8894b855944ffdac
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Feb 23 21:50:24 2016 +0200

    Small clarification for UNIX make install

commit db0af58fe59546ed512ffaf939d9fa3ccc06bae4
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 16:45:45 2016 +0100

    Update README.md

commit 14c2a149b50cafc1fba6adfed99744c036725ad2
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 16:43:10 2016 +0100

    Create README.md

commit ee09f7304b7664ca0a66d382cb52950bfed2129b
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 16:01:15 2016 +0100

    minor edit

commit 29dd01113b18980aed4afb33fc4df5a191237200
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 15:58:43 2016 +0100

    added a link to the wiki

commit 530266af5086ab33df35d573cc0f169979205a61
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 12:39:29 2016 +0100

    moved to wiki

commit 14539edad3156ad98c6a78670ad7916c630a9bfe
Author: joachimheintz <jh@joachimheintz.de>
Date:   Tue Feb 23 10:46:15 2016 +0100

    trying to unify the different instructions

commit dbfa9bcea3bb44fb80d1b2f7f85371855d96e073
Author: joachim heintz <jh@joachimheintz.de>
Date:   Tue Feb 23 09:44:38 2016 +0100

    updated build instructions

commit 45b2340e4013b0252b26917c5aabf0b64ce990ef
Author: joachimheintz <jh@joachimheintz.de>
Date:   Mon Feb 22 20:12:35 2016 +0100

    Update BUILDING.md

commit 0aaa11f459b71cf6541bd952a21e635b5bca146f
Author: joachimheintz <jh@joachimheintz.de>
Date:   Mon Feb 22 20:02:27 2016 +0100

    finished mac install instructions

commit 5e32c6806397e99ff08e541044e873d748ec1e4e
Author: joachimheintz <jh@joachimheintz.de>
Date:   Mon Feb 22 19:38:40 2016 +0100

    added some descriptions for mac

commit 3d650614121bcf7d659046202133834155100af5
Author: joachimheintz <jh@joachimheintz.de>
Date:   Mon Feb 22 18:31:31 2016 +0100

    started new build instructions and renamed to .md

commit 2ecc89267cdd3ce0d34b161b16483c2320b5b49f
Author: tarmoj <tarmo@otsakool.edu.ee>
Date:   Sat Feb 20 18:35:10 2016 +0200

    Put back comment marks for neutral build

commit 348b27d22a4082282ca5a92bba6a77a7ae6d1316
Merge: 2da3a69 ae3812a
Author: In Con Tri <fmsbw@fmsbw-15s-Mac-Pro.local>
Date:   Sat Feb 20 17:31:20 2016 +0100

    Merge branch 'master' of https://github.com/CsoundQt/CsoundQt

commit 2da3a691c1a81fb6209db55fbfe23b49b6667f7c
Author: In Con Tri <fmsbw@fmsbw-15s-Mac-Pro.local>
Date:   Sat Feb 20 17:27:50 2016 +0100

    nothing new

commit ae3812adddfd52ec3772551271e7b0765c01374f
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sat Feb 20 02:45:45 2016 +0200

    VirtualKeyboard now playable from computer keyboard

commit 34a5a5c3c4405f4861b423d029436cd867673a7c
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 19 11:21:48 2016 +0200

    Bring window to front, if called to open new file from other instance

commit 37778d387beccb5c380a33ab224fe11b829fa22c
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 19 03:25:21 2016 +0200

    Got rid of occasional pink widget panel pink backgrounds.

commit dad14883908fd01d0d40b9cc59f7e43c4a8acb90
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 19 02:13:43 2016 +0200

    Changed install target ('make install' on Linux) system wide. Now
    installs to /usr/local/bin and /usr/share

commit 30c05b9b3dd407d7dc3a9926a82a586acffb1cf8
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 19 01:11:13 2016 +0200

    Better syntax (for loop) for detecting rtmidi and pythonqt dirs

commit 40c5b1e00c36db6a18a8ac5e5b21c2c6719bf723
Merge: 313e7e5 2962d45
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 19 00:24:07 2016 +0200

    Merge branch 'master' of https://github.com/CsoundQt/CsoundQt

commit 2962d45a6d64140bfddf03709b1e2135ba0a8495
Author: In Con Tri <fmsbw@fmsbw-15s-Mac-Pro.local>
Date:   Thu Feb 18 18:11:25 2016 +0100

    clarified some paths for building with pythonqt support

commit 313e7e588b306b5ad03983a43586583b07b54b93
Merge: 67a1dae 3ebbc29
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Thu Feb 18 16:28:41 2016 +0200

    Merge branch 'master' of https://github.com/CsoundQt/CsoundQt

commit 3ebbc298c006181ef4aa874e01d4b22f531c4b38
Author: joachimheintz <jh@joachimheintz.de>
Date:   Thu Feb 18 14:23:58 2016 +0100

    changed building paths for osx

commit 67a1dae6b454128aa9bf580692e887757f78ae81
Merge: 39af108 6dceba8
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Thu Feb 18 12:10:23 2016 +0200

    Merge branch 'master' of https://github.com/CsoundQt/CsoundQt

commit 6dceba80f5b67071b6b7cd2eb5172b8b6f3adcdd
Merge: 62cfb29 2e31b2d
Author: tarmoj <tarmo@otsakool.edu.ee>
Date:   Thu Feb 18 11:48:10 2016 +0200

    Merge pull request #198 from jieunnueij/master
    
    Added comment marks in options section, changed CONFIG += html5 (was -=)

commit 2e31b2ddab41afd8dae06989ce317ccb13601ae0
Author: jieunnueij <jieun.nueij@gmail.com>
Date:   Thu Feb 18 11:38:50 2016 +0200

    Added comment marks in options section

commit 39af108b0d5b28fc749b8fecf887feb92714080c
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Feb 16 09:52:22 2016 +0200

    Added sliders to virtual midi keyboard

commit 62cfb2907a54565d6df59d2d27eca8f02e68c035
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Mon Feb 15 14:37:23 2016 +0200

    Fixed error with m_virtualKeyboardPointer not declared  (added #ifdef
    USE_QT_GT_53)

commit 7631dbcb81f29d0d20464d50c5a899d55c2af795
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Feb 14 03:48:07 2016 +0200

    Added control sliders to Virtual Midi keyboard. Not working properly
    yet...

commit e3caf156f89a6e68ad7dbd6fd9c0a72657b6beb1
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Feb 14 00:53:00 2016 +0200

    Added QLocalServer/QLocalSocket communication to try to open documents
    in one instance, not to open a new window. Fixes to mimetype script +

commit 9be0f061fc8e2bf304ac8821320de53b68c6f072
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Thu Feb 11 14:23:24 2016 +0200

    Corrected #ifdef USE_QT_GT_53 (similar to declaration)

commit 8d1b0cf62f0ab9821bd45bcc782fb76a29989543
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Thu Feb 11 12:47:10 2016 +0200

    Better mimetype icon (csound.png) and small change in the mimetype
    script.

commit f64c03ab4d7fc913a287bd6a7560f3c1239a656c
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Feb 10 16:02:47 2016 +0200

    Added mimetypes and icons for csound files + installscript, csoundqt desktop file; Added install insructions for linux (now to home folder).

commit bbf8300f983d8646a299a73558262e00710b55c0
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Mon Feb 8 21:36:06 2016 +0200

    Corrected some links to new github address and web page.

commit ad594102e138f0da1caae6bc668dee920e56f2df
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Fri Feb 5 01:12:16 2016 +0200

    new repo test

commit 8c3d0e7f3adda66aa9d5781827da409f7a9f9700
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Feb 3 16:46:37 2016 +0200

    Restore cursor position after evaluate section on arrowKeyPressed

commit 3276625a566ae728281701537be9c8857ca79145
Merge: 3532058 82250a6
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Feb 3 10:12:44 2016 +0200

    Merge branch 'master' of https://github.com/mantaraya36/CsoundQt

commit 3532058e787a7d89b51ea148ba5a25d097b666fd
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Feb 3 10:12:25 2016 +0200

    Corrected exiting with/without virtual keyboard shown.

commit aaddd0a3f851bd94de11f09409d4873a023fb09f
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Feb 3 08:04:59 2016 +0200

    Added virtual keyboard to toolbar, better closing of keyboard

commit 82250a6372b4d549548c8c0346c008f0f6c7ad4a
Author: joachim heintz <jh@joachimheintz.de>
Date:   Sun Jan 31 21:05:46 2016 +0100

    new spatialization example by karin daum included

commit f51eeac5e42210534913a37ed6bd0c83eeb19797
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Jan 27 16:41:41 2016 +0200

    Correct version of qcs.pro

commit 07db477a87b38d055cade490435b11eaf5c9b512
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Jan 27 16:20:55 2016 +0200

    Changes in project files for better pythonqt and rtmidi detection.

commit 9cc469dadb42e05cbe9463066ce487946d78725a
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Jan 26 12:46:36 2016 +0200

    Corrected links in Help menu and About CsoundQt.

commit 33ac9072ecc06272897c26cb997c9d1bdb2ac8b2
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Jan 20 14:53:35 2016 +0200

    Mark left parethesis when cursor BEFORE it. Added <Cabbage> to keywords

commit 84461633ef9b65008b5b2bbbe53fa68af04332f2
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Jan 13 11:20:08 2016 +0200

    Fixed selection end (mouse release) outside of editor Panel.

commit a5aef475e36a8f4670e61500e9970d0be1739018
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Wed Jan 13 08:59:03 2016 +0200

    Show midi controls and midi learn only on widgets that accept midi

commit d787f0cfe52350040911bc6c795cc1df0ad467ec
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Jan 12 13:19:42 2016 +0200

    Parethesis matching does not block undo chain any more.

commit 90985d754e01bf2ed05df84862a03f1a59692813
Merge: e767a80 d50623a
Author: joachim heintz <jh@joachimheintz.de>
Date:   Mon Jan 11 14:52:20 2016 +0100

    Merge branch 'master' of https://github.com/mantaraya36/CsoundQt

commit e767a80d732ecbe079f17076a37e1d67f66014c0
Author: joachim heintz <jh@joachimheintz.de>
Date:   Mon Jan 11 14:51:51 2016 +0100

    added entry to gitignore

commit d50623af67e18959738cad96345c9654c771340f
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Jan 10 12:05:01 2016 +0200

    WidgetPanel gets restored correctly on startup

commit 22baed73100fe60bd9d56d152753523dc815606e
Author: joachim heintz <jh@joachimheintz.de>
Date:   Sat Jan 9 18:05:42 2016 +0100

    small fixes for some floss manual examples

commit fb2eed7a381acba3b6960b58d4e52aa2e8c881c7
Author: joachim heintz <jh@joachimheintz.de>
Date:   Sat Jan 9 18:04:14 2016 +0100

    replaced ksmps by a pow-of-two for better jack support

commit 3dac043364ffc87712f0b654fd4a016ae943a002
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Tue Jan 5 18:05:10 2016 +0200

    Added midi learn to widget properties dialog

commit e90587686be0507a29dd939210771c1d0248b7e8
Merge: b223c64 bf72a41
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Dec 27 19:32:03 2015 +0200

    Merge branch 'master' of https://github.com/mantaraya36/CsoundQt

commit b223c64c0fd77c712a2e0fd6659c2247f3871229
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Dec 27 19:30:51 2015 +0200

    Fixed Midi Learn CC number detection above 15

commit 31b015a5e9688fde60bd85a6391b06e9a557078f
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Dec 27 11:23:51 2015 +0200

    Fixed stuck indent (now pressing <Tab> works)

commit 68ad64bfd49f79f84b11aa8861e880670d8bde92
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Sun Dec 27 11:19:39 2015 +0200

    MIDI controllers can now start/stop events via QuteButton

commit bf72a41668b9fca08e9d52eb581ad05ab8bf5be6
Author: gogins <michael.gogins@gmail.com>
Date:   Fri Dec 25 16:30:38 2015 -0500

    Added 2 missing files... oops!
    Corrected crash caused by closing tabs with HTML.

commit 26d63021a7841e94a4da5a7d4140d705eecbd6a8
Merge: 4bc24b1 bed91a3
Author: gogins <michael.gogins@gmail.com>
Date:   Thu Dec 24 07:50:20 2015 -0500

    Merge branch 'master' of github.com:mantaraya36/CsoundQt

commit 4bc24b13d576ee5f235613288822c8d2325fce79
Author: gogins <michael.gogins@gmail.com>
Date:   Thu Dec 24 07:50:14 2015 -0500

    Delayed commit.

commit bed91a362a5450af4891adde84f6da69fe8e510c
Author: Tarmo Johannes <tarmo@otsakool.edu.ee>
Date:   Mon Dec 14 12:43:30 2015 +0200

    Does not create extra sliders any more

commit e6b5382684a32096ae32d79c0417670f7ca40277
Merge: 31d14cf 5ba1517
Author: gogins <michael.gogins@gmail.com>
Date:   Wed Nov 11 20:10:15 2015 -0500

    Merge branch 'master' of github.com:mantaraya36/CsoundQt
    
    Conflicts:
    	src/configlists.h

commit 31d14cfc3f03fa1d2e007df6e520c3aa9f3056ca
Author: gogins <michael.gogins@gmail.com>
Date:   Wed Nov 11 20:03:56 2015 -0500

    Changes for updated Chromium Embedded Framework.

commit 5ba1517a8264fd2bb8baf2eb4ab3eeeb588ec5c7
Merge: bf1f541 1843e8a
Author: Andres Cabrera <mantaraya36@gmail.com>
Date:   Fri Nov 6 21:04:50 2015 -0800

    Merge pull request #193 from fsateler/delete-bak-file
    
    Remove bak file

commit bf1f541faecab1f23698c2795b8fee1d6a4f083f
Merge: a05c60a 1477ad6
Author: Andres Cabrera <mantaraya36@gmail.com>
Date:   Fri Nov 6 21:03:10 2015 -0800

    Merge pull request #192 from fsateler/patch-1
    
    configlists.h: Add missing QHash include

commit 1843e8afa80d28db9142b17ff1361da863770f59
Author: Felipe Sateler <fsateler@gmail.com>
Date:   Fri Nov 6 21:36:07 2015 -0300

    Remove bak file

commit 1477ad6aaff41e647a63f9695b92c939c6e772a2
Author: Felipe Sateler <fsateler@users.noreply.github.com>
Date:   Fri Nov 6 21:26:44 2015 -0300

    configlists.h: Add missing QHash include

commit a05c60aeff1ed773035e071818dbff3fa150ae09
Author: Andres Cabrera <mantaraya36@gmail.com>
Date:   Wed Oct 14 21:31:24 2015 -0700

    Added Matrix example by Alessandro Petrolati
