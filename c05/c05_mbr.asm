         ;代码清单5-1 
         ;文件名：c05_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-3-31 21:15 
         
         ; 显存映射到 内存空间 的 0xb8000 - 0xbffff
         mov ax,0xb800                 ;es寄存器指向文本模式的显示缓冲区
         mov es,ax

         ;以下显示字符串"Label offset:"
         ;字符的显示属性分为两个字节
         ;第一个字节是字符的ASCII码，第二个字节是字符的显示属性 (汇编中可以直接使用字符，编译器会替换为 ASCII 码值)
         ;下面的0x07表示字符以黑底白字，无闪烁无加亮的方式显示
         mov byte [es:0x00],'L'
         mov byte [es:0x01],0x07
         mov byte [es:0x02],'a'
         mov byte [es:0x03],0x07
         mov byte [es:0x04],'b'
         mov byte [es:0x05],0x07
         mov byte [es:0x06],'e'
         mov byte [es:0x07],0x07
         mov byte [es:0x08],'l'
         mov byte [es:0x09],0x07
         mov byte [es:0x0a],' '
         mov byte [es:0x0b],0x07
         mov byte [es:0x0c],"o"
         mov byte [es:0x0d],0x07
         mov byte [es:0x0e],'f'
         mov byte [es:0x0f],0x07
         mov byte [es:0x10],'f'
         mov byte [es:0x11],0x07
         mov byte [es:0x12],'s'
         mov byte [es:0x13],0x07
         mov byte [es:0x14],'e'
         mov byte [es:0x15],0x07
         mov byte [es:0x16],'t'
         mov byte [es:0x17],0x07
         mov byte [es:0x18],':'
         mov byte [es:0x19],0x07

         ; number 这样的汇编标号，代表所在位置的汇编地址（因为汇编文件中无法直接看到指令地址，因此使用标号表示）
         mov ax,number                 ;取得标号number的偏移地址
         ; 等价于 mov ax, 0x012E（书中 p58）
         mov bx,10                     ;bx保存被除数,div指令使用bx寄存器的值作为被除数

         ;设置数据段的基地址
         ;将 ds 设置为 cs 的值，因为我们的数据声明和指令混在一起，在 cs 中，不过默认访问数据又是使用 ds
         mov cx,cs
         mov ds,cx

         ;32位除法中，被除数的低16位在ax寄存器中，高16位在dx寄存器中
         ;前面已经将number的地址赋值给ax，下面将dx清零
         ;求个位上的数字
         mov dx,0
         div bx
         mov [0x7c00+number+0x00],dl   ;保存个位上的数字
         ; 0x7c00 是因为 cs=0x0000 ip=0x7c00 因此取指是没问题的，但是利用 ds 访问数据的时候 就少了 0x7c00

         ;求十位上的数字
         xor dx,dx
         div bx
         mov [0x7c00+number+0x01],dl   ;保存十位上的数字

         ;求百位上的数字
         xor dx,dx
         div bx
         mov [0x7c00+number+0x02],dl   ;保存百位上的数字

         ;求千位上的数字
         xor dx,dx
         div bx
         mov [0x7c00+number+0x03],dl   ;保存千位上的数字

         ;求万位上的数字 
         xor dx,dx
         div bx
         mov [0x7c00+number+0x04],dl   ;保存万位上的数字

         ;以下用十进制显示标号的偏移地址
         mov al,[0x7c00+number+0x04]    ;将计算结果送到al寄存器中
         add al,0x30                    ;加上0x30得到这个数字的ASCII码
         mov [es:0x1a],al               ;得到的ASCII码送到指定的位置
         mov byte [es:0x1b],0x04        ;显示属性为黑底红字，无闪烁无加亮
         
         mov al,[0x7c00+number+0x03]
         add al,0x30
         mov [es:0x1c],al
         mov byte [es:0x1d],0x04
         
         mov al,[0x7c00+number+0x02]
         add al,0x30
         mov [es:0x1e],al
         mov byte [es:0x1f],0x04

         mov al,[0x7c00+number+0x01]
         add al,0x30
         mov [es:0x20],al
         mov byte [es:0x21],0x04

         mov al,[0x7c00+number+0x00]
         add al,0x30
         mov [es:0x22],al
         mov byte [es:0x23],0x04
         
         mov byte [es:0x24],'D'
         mov byte [es:0x25],0x07
          
   infi: jmp near infi                 ;无限循环
   ; 避免 cpu 继续执行非指令数据
      
  number db 0,0,0,0,0
  ; db dw dd 分别定义 字节/字/双字类型变量
  ; 这句就定义了 5 个字节的变量，值都为 0
  ; 如果是 0,?,?,?,0 ?就表示预分配空间但是没有值
  ; https://zhidao.baidu.com/question/1860453381957521507.html
  
  times 203 db 0
            db 0x55,0xaa
  ; 因为 引导扇区最后两个字节需要等于 0x55 0xaa（也就是 512 字节的最后）
  ; times 在中间插入了 203 个 0 填充
