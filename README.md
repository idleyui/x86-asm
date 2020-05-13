# 「x86汇编语言-从实模式到保护模式」一书的代码 & 阅读注释

## WorkFlow

WSL + [NASM(2.13.03)](https://www.nasm.us/) + QEMU(5.0.0) + VSCode

使用 QEmu 替换了书中的 VirtualBox，使用 VSCode 中的 [hexdump](https://marketplace.visualstudio.com/items?itemName=slevesque.vscode-hexdump) 替换了书中的 HexDump（用 VritualBox 有的时候还更方便的感觉 ）

### prepare

- 配套的代码和工具下载

    https://blog.csdn.net/longintchar/article/details/50452801

- download and install qemu

    > 不完全参考 [install qemu on ubuntu](https://askubuntu.com/questions/1067722/how-do-i-install-qemu-3-0-on-ubuntu-18-04) (完全参考可能意味着重新编译五小时 :smile:) 
    >
    > boot loader 中输出字符可以由 直接写入显存 和 使用 BIOS 中断两种方式
    >
    > qemu 默认 configure 可能是没有 enable sdl 和 curses 的，写入显存的代码就不 work，需要在 configure 的时候 添加参数 --enable-sdl 和 --enable-curses

    download, configure and compile

    ```bash
    wget https://download.qemu.org/qemu-5.0.0.tar.xz
    tar -xf qemu-5.0.0.tar.xz
    cd qemu-5.0.0
    # 这里能装 libncurses6 就装 6
    sudo apt install libsdl2-dev libncurses5-dev libncursesw5-dev
    ./configure --enable-sdl --enable-curses
    # 确保 configure 的输出中有 SDL support yes / curses support yes
    make
    # 10 years later
    ```


    then use checkinstall

    ```bash
    sudo apt install checkinstall
    sudo checkinstall make install
    sudo apt install ./*.deb
    ```

    then check

    ```bash
    qemu-system-x86_64 --version
    ```

- install

    ```bash
    sudo apt install nasm
    ```

### usage

```bash
# -f bin 表示纯粹的面向 CPU 的二进制文件
# compile
nasm -f bin xxx.asm -o xxx.bin
# run with video display
qemu-system-x86_64 -fda boot.bin -display curses
# run without video display
qemu-system-x86_64 -fda boot.bin -nographic
# run with sdl display: need XMing for WSL
qemu-sysyem-x86_64 -fda boot.bin -display sdl
```

note:

- ubuntu 上可能会有版本的问题, 因为 ubuntu 上只有 libncurses 的 5，所以出现 `error while loading shared libraries libncursesw.so.6` 的时候可以软连接一下，

    > https://stackoverflow.com/questions/17005654/error-while-loading-shared-libraries-libncurses-so-5
    > https://askubuntu.com/questions/771047/erlang-error-while-loading-shared-libraries-libncursesw-so-6

    ```bash
    sudo ln -s /lib/x86_64-linux-gnu/libncursesw.so.5  	/lib/x86_64-linux-gnu/libncursesw.so.6
    sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.5 		/lib/x86_64-linux-gnu/libtinfo.so.6
    sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.5 		/lib/x86_64-linux-gnu/libtinfow.so.6
    ```

- WSL 上使用 sdl 需要 [XMing](https://sourceforge.net/projects/xming/)，配置环境变量 `DISPLAY=127.0.0.1:0.0` (:0 好像就可以，没试)

### qemu cheatsheet

exit ctrl+A X

docs 

https://www.qemu.org/docs/master/

https://www.qemu.org/docs/master/system/index.html

https://qemu.weilnetz.de/doc/qemu-doc.html

display option

https://www.qemu.org/docs/master/system/invocation.html?highlight=video

https://wiki.gentoo.org/wiki/QEMU/Options

```bash
qemu -display sdl # 额外弹出窗口，需要 XMing
qemu -display curses # text mode graphics devices
none
gtk
-nographic # 不显示显卡输出
```

disk

```bash
qemu -hda xxx.img # 硬盘
qemu -fda xxx.img # 软盘
qemu -drive format=raw,file=xxx.img # advanced configure
```

## other references:

1. [写一个引导程序（boot loader）](   https://segmentfault.com/a/1190000015560552)
   
   原版
   http://3zanders.co.uk/2017/10/13/writing-a-bootloader/
   
   这个是个直接能用 qemu 跑起来的代码
   
2. 轻松的开发一个操作系统(一) 环境 引导扇区 - Josefa的文章 - 知乎 https://zhuanlan.zhihu.com/p/51725653

    也是个能跑的 demo / 虽然啥也没做

3. 显示模式 https://www.cnblogs.com/mlzrq/p/10223020.html

4. 从零开始自制操作系统（7）：实模式下的第一个简易内核 - 不吃香菜的大头怪的文章 - 知乎 https://zhuanlan.zhihu.com/p/102162186

5. [Writing an x86 “Hello world” boot loader with assembly](https://medium.com/@g33konaut/writing-an-x86-hello-world-boot-loader-with-assembly-3e4c5bdd96cf)
   没看，有空看看

6. https://github.com/rivalak/x86-asm
   一个据说也用的 qemu 的 github repo，不过 好像 not work

7. https://yifengyou.gitbooks.io/learn-kvm/content/

   一个中文 kvm 笔记