
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 29 5e 00 00       	call   c0105e8b <memset>

    cons_init();                // init the console
c0100062:	e8 82 15 00 00       	call   c01015e9 <cons_init>

    const char *message = "liangximin os is loading ...";
c0100067:	c7 45 f4 20 60 10 c0 	movl   $0xc0106020,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 3d 60 10 c0 	movl   $0xc010603d,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 66 43 00 00       	call   c01043f6 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bd 16 00 00       	call   c0101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 0f 18 00 00       	call   c01018a9 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 00 0d 00 00       	call   c0100d9f <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 1c 16 00 00       	call   c01016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 f8 0b 00 00       	call   c0100cc0 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 42 60 10 c0 	movl   $0xc0106042,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 50 60 10 c0 	movl   $0xc0106050,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 5e 60 10 c0 	movl   $0xc010605e,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 6c 60 10 c0 	movl   $0xc010606c,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 7a 60 10 c0 	movl   $0xc010607a,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 88 60 10 c0 	movl   $0xc0106088,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 a8 60 10 c0 	movl   $0xc01060a8,(%esp)
c010022e:	e8 15 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100249:	74 13                	je     c010025e <readline+0x1f>
        cprintf("%s", prompt);
c010024b:	8b 45 08             	mov    0x8(%ebp),%eax
c010024e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100252:	c7 04 24 c7 60 10 c0 	movl   $0xc01060c7,(%esp)
c0100259:	e8 ea 00 00 00       	call   c0100348 <cprintf>
    }
    int i = 0, c;
c010025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100265:	e8 66 01 00 00       	call   c01003d0 <getchar>
c010026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100271:	79 07                	jns    c010027a <readline+0x3b>
            return NULL;
c0100273:	b8 00 00 00 00       	mov    $0x0,%eax
c0100278:	eb 79                	jmp    c01002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027e:	7e 28                	jle    c01002a8 <readline+0x69>
c0100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100287:	7f 1f                	jg     c01002a8 <readline+0x69>
            cputchar(c);
c0100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028c:	89 04 24             	mov    %eax,(%esp)
c010028f:	e8 da 00 00 00       	call   c010036e <cputchar>
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002a6:	eb 46                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 17                	jne    c01002c5 <readline+0x86>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 11                	jle    c01002c5 <readline+0x86>
            cputchar(c);
c01002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
            i --;
c01002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c3:	eb 29                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c9:	74 06                	je     c01002d1 <readline+0x92>
c01002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002cf:	75 1d                	jne    c01002ee <readline+0xaf>
            cputchar(c);
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	89 04 24             	mov    %eax,(%esp)
c01002d7:	e8 92 00 00 00       	call   c010036e <cputchar>
            buf[i] = '\0';
c01002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002df:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002ec:	eb 05                	jmp    c01002f3 <readline+0xb4>
        }
    }
c01002ee:	e9 72 ff ff ff       	jmp    c0100265 <readline+0x26>
}
c01002f3:	c9                   	leave  
c01002f4:	c3                   	ret    

c01002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f5:	55                   	push   %ebp
c01002f6:	89 e5                	mov    %esp,%ebp
c01002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fe:	89 04 24             	mov    %eax,(%esp)
c0100301:	e8 0f 13 00 00       	call   c0101615 <cons_putc>
    (*cnt) ++;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 00                	mov    (%eax),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100311:	89 10                	mov    %edx,(%eax)
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100329:	8b 45 08             	mov    0x8(%ebp),%eax
c010032c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100337:	c7 04 24 f5 02 10 c0 	movl   $0xc01002f5,(%esp)
c010033e:	e8 61 53 00 00       	call   c01056a4 <vprintfmt>
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 04 24             	mov    %eax,(%esp)
c0100361:	e8 af ff ff ff       	call   c0100315 <vcprintf>
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100374:	8b 45 08             	mov    0x8(%ebp),%eax
c0100377:	89 04 24             	mov    %eax,(%esp)
c010037a:	e8 96 12 00 00       	call   c0101615 <cons_putc>
}
c010037f:	c9                   	leave  
c0100380:	c3                   	ret    

c0100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038e:	eb 13                	jmp    c01003a3 <cputs+0x22>
        cputch(c, &cnt);
c0100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100397:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 52 ff ff ff       	call   c01002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ac:	0f b6 00             	movzbl (%eax),%eax
c01003af:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b6:	75 d8                	jne    c0100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c6:	e8 2a ff ff ff       	call   c01002f5 <cputch>
    return cnt;
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ce:	c9                   	leave  
c01003cf:	c3                   	ret    

c01003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d0:	55                   	push   %ebp
c01003d1:	89 e5                	mov    %esp,%ebp
c01003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d6:	e8 76 12 00 00       	call   c0101651 <cons_getc>
c01003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e2:	74 f2                	je     c01003d6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f2:	8b 00                	mov    (%eax),%eax
c01003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fa:	8b 00                	mov    (%eax),%eax
c01003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100406:	e9 d2 00 00 00       	jmp    c01004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100411:	01 d0                	add    %edx,%eax
c0100413:	89 c2                	mov    %eax,%edx
c0100415:	c1 ea 1f             	shr    $0x1f,%edx
c0100418:	01 d0                	add    %edx,%eax
c010041a:	d1 f8                	sar    %eax
c010041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100425:	eb 04                	jmp    c010042b <stab_binsearch+0x42>
            m --;
c0100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100431:	7c 1f                	jl     c0100452 <stab_binsearch+0x69>
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044a:	0f b6 c0             	movzbl %al,%eax
c010044d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100450:	75 d5                	jne    c0100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100458:	7d 0b                	jge    c0100465 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045d:	83 c0 01             	add    $0x1,%eax
c0100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100463:	eb 78                	jmp    c01004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	8b 40 08             	mov    0x8(%eax),%eax
c0100482:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100485:	73 13                	jae    c010049a <stab_binsearch+0xb1>
            *region_left = m;
c0100487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100492:	83 c0 01             	add    $0x1,%eax
c0100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100498:	eb 43                	jmp    c01004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 d0                	mov    %edx,%eax
c010049f:	01 c0                	add    %eax,%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	c1 e0 02             	shl    $0x2,%eax
c01004a6:	89 c2                	mov    %eax,%edx
c01004a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ab:	01 d0                	add    %edx,%eax
c01004ad:	8b 40 08             	mov    0x8(%eax),%eax
c01004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b3:	76 16                	jbe    c01004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	83 e8 01             	sub    $0x1,%eax
c01004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c9:	eb 12                	jmp    c01004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e3:	0f 8e 22 ff ff ff    	jle    c010040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ed:	75 0f                	jne    c01004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f2:	8b 00                	mov    (%eax),%eax
c01004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fa:	89 10                	mov    %edx,(%eax)
c01004fc:	eb 3f                	jmp    c010053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100506:	eb 04                	jmp    c010050c <stab_binsearch+0x123>
c0100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050f:	8b 00                	mov    (%eax),%eax
c0100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100514:	7d 1f                	jge    c0100535 <stab_binsearch+0x14c>
c0100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100519:	89 d0                	mov    %edx,%eax
c010051b:	01 c0                	add    %eax,%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	c1 e0 02             	shl    $0x2,%eax
c0100522:	89 c2                	mov    %eax,%edx
c0100524:	8b 45 08             	mov    0x8(%ebp),%eax
c0100527:	01 d0                	add    %edx,%eax
c0100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052d:	0f b6 c0             	movzbl %al,%eax
c0100530:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100533:	75 d3                	jne    c0100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053b:	89 10                	mov    %edx,(%eax)
    }
}
c010053d:	c9                   	leave  
c010053e:	c3                   	ret    

c010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053f:	55                   	push   %ebp
c0100540:	89 e5                	mov    %esp,%ebp
c0100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	c7 00 cc 60 10 c0    	movl   $0xc01060cc,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 cc 60 10 c0 	movl   $0xc01060cc,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057f:	c7 45 f4 64 73 10 c0 	movl   $0xc0107364,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 78 1f 11 c0 	movl   $0xc0111f78,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec 79 1f 11 c0 	movl   $0xc0111f79,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 a0 49 11 c0 	movl   $0xc01149a0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a1:	76 0d                	jbe    c01005b0 <debuginfo_eip+0x71>
c01005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a6:	83 e8 01             	sub    $0x1,%eax
c01005a9:	0f b6 00             	movzbl (%eax),%eax
c01005ac:	84 c0                	test   %al,%al
c01005ae:	74 0a                	je     c01005ba <debuginfo_eip+0x7b>
        return -1;
c01005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b5:	e9 c0 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c7:	29 c2                	sub    %eax,%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	c1 f8 02             	sar    $0x2,%eax
c01005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d4:	83 e8 01             	sub    $0x1,%eax
c01005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005da:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e8:	00 
c01005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005fa:	89 04 24             	mov    %eax,(%esp)
c01005fd:	e8 e7 fd ff ff       	call   c01003e9 <stab_binsearch>
    if (lfile == 0)
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	85 c0                	test   %eax,%eax
c0100607:	75 0a                	jne    c0100613 <debuginfo_eip+0xd4>
        return -1;
c0100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060e:	e9 67 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100622:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062d:	00 
c010062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100631:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100638:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063f:	89 04 24             	mov    %eax,(%esp)
c0100642:	e8 a2 fd ff ff       	call   c01003e9 <stab_binsearch>

    if (lfun <= rfun) {
c0100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064d:	39 c2                	cmp    %eax,%edx
c010064f:	7f 7c                	jg     c01006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100654:	89 c2                	mov    %eax,%edx
c0100656:	89 d0                	mov    %edx,%eax
c0100658:	01 c0                	add    %eax,%eax
c010065a:	01 d0                	add    %edx,%eax
c010065c:	c1 e0 02             	shl    $0x2,%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	8b 10                	mov    (%eax),%edx
c0100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066e:	29 c1                	sub    %eax,%ecx
c0100670:	89 c8                	mov    %ecx,%eax
c0100672:	39 c2                	cmp    %eax,%edx
c0100674:	73 22                	jae    c0100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100679:	89 c2                	mov    %eax,%edx
c010067b:	89 d0                	mov    %edx,%eax
c010067d:	01 c0                	add    %eax,%eax
c010067f:	01 d0                	add    %edx,%eax
c0100681:	c1 e0 02             	shl    $0x2,%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100689:	01 d0                	add    %edx,%eax
c010068b:	8b 10                	mov    (%eax),%edx
c010068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100690:	01 c2                	add    %eax,%edx
c0100692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	01 c0                	add    %eax,%eax
c01006a1:	01 d0                	add    %edx,%eax
c01006a3:	c1 e0 02             	shl    $0x2,%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	01 d0                	add    %edx,%eax
c01006ad:	8b 50 08             	mov    0x8(%eax),%edx
c01006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	8b 40 10             	mov    0x10(%eax),%eax
c01006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006cb:	eb 15                	jmp    c01006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 40 08             	mov    0x8(%eax),%eax
c01006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ef:	00 
c01006f0:	89 04 24             	mov    %eax,(%esp)
c01006f3:	e8 07 56 00 00       	call   c0105cff <strfind>
c01006f8:	89 c2                	mov    %eax,%edx
c01006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100700:	29 c2                	sub    %eax,%edx
c0100702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100708:	8b 45 08             	mov    0x8(%ebp),%eax
c010070b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100716:	00 
c0100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010071a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 b9 fc ff ff       	call   c01003e9 <stab_binsearch>
    if (lline <= rline) {
c0100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100736:	39 c2                	cmp    %eax,%edx
c0100738:	7f 24                	jg     c010075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073d:	89 c2                	mov    %eax,%edx
c010073f:	89 d0                	mov    %edx,%eax
c0100741:	01 c0                	add    %eax,%eax
c0100743:	01 d0                	add    %edx,%eax
c0100745:	c1 e0 02             	shl    $0x2,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100753:	0f b7 d0             	movzwl %ax,%edx
c0100756:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075c:	eb 13                	jmp    c0100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100763:	e9 12 01 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	83 e8 01             	sub    $0x1,%eax
c010076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100777:	39 c2                	cmp    %eax,%edx
c0100779:	7c 56                	jl     c01007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	89 d0                	mov    %edx,%eax
c0100782:	01 c0                	add    %eax,%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	c1 e0 02             	shl    $0x2,%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100794:	3c 84                	cmp    $0x84,%al
c0100796:	74 39                	je     c01007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	01 c0                	add    %eax,%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	c1 e0 02             	shl    $0x2,%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ab:	01 d0                	add    %edx,%eax
c01007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b1:	3c 64                	cmp    $0x64,%al
c01007b3:	75 b3                	jne    c0100768 <debuginfo_eip+0x229>
c01007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	89 d0                	mov    %edx,%eax
c01007bc:	01 c0                	add    %eax,%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	c1 e0 02             	shl    $0x2,%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c8:	01 d0                	add    %edx,%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	85 c0                	test   %eax,%eax
c01007cf:	74 97                	je     c0100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d7:	39 c2                	cmp    %eax,%edx
c01007d9:	7c 46                	jl     c0100821 <debuginfo_eip+0x2e2>
c01007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	89 d0                	mov    %edx,%eax
c01007e2:	01 c0                	add    %eax,%eax
c01007e4:	01 d0                	add    %edx,%eax
c01007e6:	c1 e0 02             	shl    $0x2,%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ee:	01 d0                	add    %edx,%eax
c01007f0:	8b 10                	mov    (%eax),%edx
c01007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f8:	29 c1                	sub    %eax,%ecx
c01007fa:	89 c8                	mov    %ecx,%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	73 21                	jae    c0100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010081a:	01 c2                	add    %eax,%edx
c010081c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7d 4a                	jge    c0100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082e:	83 c0 01             	add    $0x1,%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	eb 18                	jmp    c010084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100839:	8b 40 14             	mov    0x14(%eax),%eax
c010083c:	8d 50 01             	lea    0x1(%eax),%edx
c010083f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	83 c0 01             	add    $0x1,%eax
c010084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100854:	39 c2                	cmp    %eax,%edx
c0100856:	7d 1d                	jge    c0100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c a0                	cmp    $0xa0,%al
c0100873:	74 c1                	je     c0100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010087a:	c9                   	leave  
c010087b:	c3                   	ret    

c010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087c:	55                   	push   %ebp
c010087d:	89 e5                	mov    %esp,%ebp
c010087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100882:	c7 04 24 d6 60 10 c0 	movl   $0xc01060d6,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 ef 60 10 c0 	movl   $0xc01060ef,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 14 60 10 	movl   $0xc0106014,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 07 61 10 c0 	movl   $0xc0106107,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 1f 61 10 c0 	movl   $0xc010611f,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 37 61 10 c0 	movl   $0xc0106137,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 50 61 10 c0 	movl   $0xc0106150,(%esp)
c010090b:	e8 38 fa ff ff       	call   c0100348 <cprintf>
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100922:	8b 45 08             	mov    0x8(%ebp),%eax
c0100925:	89 04 24             	mov    %eax,(%esp)
c0100928:	e8 12 fc ff ff       	call   c010053f <debuginfo_eip>
c010092d:	85 c0                	test   %eax,%eax
c010092f:	74 15                	je     c0100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100938:	c7 04 24 7a 61 10 c0 	movl   $0xc010617a,(%esp)
c010093f:	e8 04 fa ff ff       	call   c0100348 <cprintf>
c0100944:	eb 6d                	jmp    c01009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094d:	eb 1c                	jmp    c010096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100955:	01 d0                	add    %edx,%eax
c0100957:	0f b6 00             	movzbl (%eax),%eax
c010095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100963:	01 ca                	add    %ecx,%edx
c0100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100971:	7f dc                	jg     c010094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100984:	8b 55 08             	mov    0x8(%ebp),%edx
c0100987:	89 d1                	mov    %edx,%ecx
c0100989:	29 c1                	sub    %eax,%ecx
c010098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a7:	c7 04 24 96 61 10 c0 	movl   $0xc0106196,(%esp)
c01009ae:	e8 95 f9 ff ff       	call   c0100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b3:	c9                   	leave  
c01009b4:	c3                   	ret    

c01009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b5:	55                   	push   %ebp
c01009b6:	89 e5                	mov    %esp,%ebp
c01009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009bb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
c01009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cc:	89 e8                	mov    %ebp,%eax
c01009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();
c01009d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009d7:	e8 d9 ff ff ff       	call   c01009b5 <read_eip>
c01009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)

	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c01009df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e6:	e9 88 00 00 00       	jmp    c0100a73 <print_stackframe+0xad>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
c01009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f9:	c7 04 24 a8 61 10 c0 	movl   $0xc01061a8,(%esp)
c0100a00:	e8 43 f9 ff ff       	call   c0100348 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
c0100a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a08:	83 c0 08             	add    $0x8,%eax
c0100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for(j = 0; j < 4; j++)
c0100a0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a15:	eb 25                	jmp    c0100a3c <print_stackframe+0x76>
		{
			cprintf("0x%08x ",args[j]);
c0100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a24:	01 d0                	add    %edx,%eax
c0100a26:	8b 00                	mov    (%eax),%eax
c0100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2c:	c7 04 24 c4 61 10 c0 	movl   $0xc01061c4,(%esp)
c0100a33:	e8 10 f9 ff ff       	call   c0100348 <cprintf>
	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
		uint32_t *args = (uint32_t *)ebp + 2;
		for(j = 0; j < 4; j++)
c0100a38:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a3c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a40:	7e d5                	jle    c0100a17 <print_stackframe+0x51>
		{
			cprintf("0x%08x ",args[j]);
		}
		cprintf("\n");
c0100a42:	c7 04 24 cc 61 10 c0 	movl   $0xc01061cc,(%esp)
c0100a49:	e8 fa f8 ff ff       	call   c0100348 <cprintf>
		print_debuginfo(eip - 1);
c0100a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a51:	83 e8 01             	sub    $0x1,%eax
c0100a54:	89 04 24             	mov    %eax,(%esp)
c0100a57:	e8 b6 fe ff ff       	call   c0100912 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5f:	83 c0 04             	add    $0x4,%eax
c0100a62:	8b 00                	mov    (%eax),%eax
c0100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6a:	8b 00                	mov    (%eax),%eax
c0100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();

	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a77:	74 0a                	je     c0100a83 <print_stackframe+0xbd>
c0100a79:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a7d:	0f 8e 68 ff ff ff    	jle    c01009eb <print_stackframe+0x25>
		cprintf("\n");
		print_debuginfo(eip - 1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a92:	eb 0c                	jmp    c0100aa0 <parse+0x1b>
            *buf ++ = '\0';
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	8d 50 01             	lea    0x1(%eax),%edx
c0100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa3:	0f b6 00             	movzbl (%eax),%eax
c0100aa6:	84 c0                	test   %al,%al
c0100aa8:	74 1d                	je     c0100ac7 <parse+0x42>
c0100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aad:	0f b6 00             	movzbl (%eax),%eax
c0100ab0:	0f be c0             	movsbl %al,%eax
c0100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab7:	c7 04 24 50 62 10 c0 	movl   $0xc0106250,(%esp)
c0100abe:	e8 09 52 00 00       	call   c0105ccc <strchr>
c0100ac3:	85 c0                	test   %eax,%eax
c0100ac5:	75 cd                	jne    c0100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aca:	0f b6 00             	movzbl (%eax),%eax
c0100acd:	84 c0                	test   %al,%al
c0100acf:	75 02                	jne    c0100ad3 <parse+0x4e>
            break;
c0100ad1:	eb 67                	jmp    c0100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad7:	75 14                	jne    c0100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ae0:	00 
c0100ae1:	c7 04 24 55 62 10 c0 	movl   $0xc0106255,(%esp)
c0100ae8:	e8 5b f8 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af0:	8d 50 01             	lea    0x1(%eax),%edx
c0100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b00:	01 c2                	add    %eax,%edx
c0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b07:	eb 04                	jmp    c0100b0d <parse+0x88>
            buf ++;
c0100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	0f b6 00             	movzbl (%eax),%eax
c0100b13:	84 c0                	test   %al,%al
c0100b15:	74 1d                	je     c0100b34 <parse+0xaf>
c0100b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1a:	0f b6 00             	movzbl (%eax),%eax
c0100b1d:	0f be c0             	movsbl %al,%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 50 62 10 c0 	movl   $0xc0106250,(%esp)
c0100b2b:	e8 9c 51 00 00       	call   c0105ccc <strchr>
c0100b30:	85 c0                	test   %eax,%eax
c0100b32:	74 d5                	je     c0100b09 <parse+0x84>
            buf ++;
        }
    }
c0100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b35:	e9 66 ff ff ff       	jmp    c0100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2e ff ff ff       	call   c0100a85 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2b>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 85 00 00 00       	jmp    c0100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5c                	jmp    c0100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b79:	89 d0                	mov    %edx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 d0                	add    %edx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 98 50 00 00       	call   c0105c2d <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 32                	jne    c0100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100baa:	8b 40 08             	mov    0x8(%eax),%eax
c0100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbd:	83 c2 04             	add    $0x4,%edx
c0100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc4:	89 0c 24             	mov    %ecx,(%esp)
c0100bc7:	ff d0                	call   *%eax
c0100bc9:	eb 24                	jmp    c0100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	83 f8 02             	cmp    $0x2,%eax
c0100bd5:	76 9c                	jbe    c0100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bde:	c7 04 24 73 62 10 c0 	movl   $0xc0106273,(%esp)
c0100be5:	e8 5e f7 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bef:	c9                   	leave  
c0100bf0:	c3                   	ret    

c0100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf1:	55                   	push   %ebp
c0100bf2:	89 e5                	mov    %esp,%ebp
c0100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf7:	c7 04 24 8c 62 10 c0 	movl   $0xc010628c,(%esp)
c0100bfe:	e8 45 f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c03:	c7 04 24 b4 62 10 c0 	movl   $0xc01062b4,(%esp)
c0100c0a:	e8 39 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c13:	74 0b                	je     c0100c20 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	89 04 24             	mov    %eax,(%esp)
c0100c1b:	e8 41 0e 00 00       	call   c0101a61 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c20:	c7 04 24 d9 62 10 c0 	movl   $0xc01062d9,(%esp)
c0100c27:	e8 13 f6 ff ff       	call   c010023f <readline>
c0100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c33:	74 18                	je     c0100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3f:	89 04 24             	mov    %eax,(%esp)
c0100c42:	e8 f8 fe ff ff       	call   c0100b3f <runcmd>
c0100c47:	85 c0                	test   %eax,%eax
c0100c49:	79 02                	jns    c0100c4d <kmonitor+0x5c>
                break;
c0100c4b:	eb 02                	jmp    c0100c4f <kmonitor+0x5e>
            }
        }
    }
c0100c4d:	eb d1                	jmp    c0100c20 <kmonitor+0x2f>
}
c0100c4f:	c9                   	leave  
c0100c50:	c3                   	ret    

c0100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c51:	55                   	push   %ebp
c0100c52:	89 e5                	mov    %esp,%ebp
c0100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5e:	eb 3f                	jmp    c0100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c63:	89 d0                	mov    %edx,%eax
c0100c65:	01 c0                	add    %eax,%eax
c0100c67:	01 d0                	add    %edx,%eax
c0100c69:	c1 e0 02             	shl    $0x2,%eax
c0100c6c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c71:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c85:	8b 00                	mov    (%eax),%eax
c0100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	c7 04 24 dd 62 10 c0 	movl   $0xc01062dd,(%esp)
c0100c96:	e8 ad f6 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca2:	83 f8 02             	cmp    $0x2,%eax
c0100ca5:	76 b9                	jbe    c0100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cac:	c9                   	leave  
c0100cad:	c3                   	ret    

c0100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cae:	55                   	push   %ebp
c0100caf:	89 e5                	mov    %esp,%ebp
c0100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb4:	e8 c3 fb ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbe:	c9                   	leave  
c0100cbf:	c3                   	ret    

c0100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc0:	55                   	push   %ebp
c0100cc1:	89 e5                	mov    %esp,%ebp
c0100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc6:	e8 fb fc ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd0:	c9                   	leave  
c0100cd1:	c3                   	ret    

c0100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd2:	55                   	push   %ebp
c0100cd3:	89 e5                	mov    %esp,%ebp
c0100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd8:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cdd:	85 c0                	test   %eax,%eax
c0100cdf:	74 02                	je     c0100ce3 <__panic+0x11>
        goto panic_dead;
c0100ce1:	eb 59                	jmp    c0100d3c <__panic+0x6a>
    }
    is_panic = 1;
c0100ce3:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ced:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d01:	c7 04 24 e6 62 10 c0 	movl   $0xc01062e6,(%esp)
c0100d08:	e8 3b f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d17:	89 04 24             	mov    %eax,(%esp)
c0100d1a:	e8 f6 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d1f:	c7 04 24 02 63 10 c0 	movl   $0xc0106302,(%esp)
c0100d26:	e8 1d f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d2b:	c7 04 24 04 63 10 c0 	movl   $0xc0106304,(%esp)
c0100d32:	e8 11 f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100d37:	e8 8a fc ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3c:	e8 85 09 00 00       	call   c01016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d48:	e8 a4 fe ff ff       	call   c0100bf1 <kmonitor>
    }
c0100d4d:	eb f2                	jmp    c0100d41 <__panic+0x6f>

c0100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4f:	55                   	push   %ebp
c0100d50:	89 e5                	mov    %esp,%ebp
c0100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d55:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d69:	c7 04 24 16 63 10 c0 	movl   $0xc0106316,(%esp)
c0100d70:	e8 d3 f5 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7f:	89 04 24             	mov    %eax,(%esp)
c0100d82:	e8 8e f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d87:	c7 04 24 02 63 10 c0 	movl   $0xc0106302,(%esp)
c0100d8e:	e8 b5 f5 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100d93:	c9                   	leave  
c0100d94:	c3                   	ret    

c0100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d95:	55                   	push   %ebp
c0100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d98:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100d9d:	5d                   	pop    %ebp
c0100d9e:	c3                   	ret    

c0100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9f:	55                   	push   %ebp
c0100da0:	89 e5                	mov    %esp,%ebp
c0100da2:	83 ec 28             	sub    $0x28,%esp
c0100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
c0100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dca:	ee                   	out    %al,(%dx)
c0100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dde:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de8:	c7 04 24 34 63 10 c0 	movl   $0xc0106334,(%esp)
c0100def:	e8 54 f5 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dfb:	e8 24 09 00 00       	call   c0101724 <pic_enable>
}
c0100e00:	c9                   	leave  
c0100e01:	c3                   	ret    

c0100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e02:	55                   	push   %ebp
c0100e03:	89 e5                	mov    %esp,%ebp
c0100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e08:	9c                   	pushf  
c0100e09:	58                   	pop    %eax
c0100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e10:	25 00 02 00 00       	and    $0x200,%eax
c0100e15:	85 c0                	test   %eax,%eax
c0100e17:	74 0c                	je     c0100e25 <__intr_save+0x23>
        intr_disable();
c0100e19:	e8 a8 08 00 00       	call   c01016c6 <intr_disable>
        return 1;
c0100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e23:	eb 05                	jmp    c0100e2a <__intr_save+0x28>
    }
    return 0;
c0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e36:	74 05                	je     c0100e3d <__intr_restore+0x11>
        intr_enable();
c0100e38:	e8 83 08 00 00       	call   c01016c0 <intr_enable>
    }
}
c0100e3d:	c9                   	leave  
c0100e3e:	c3                   	ret    

c0100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3f:	55                   	push   %ebp
c0100e40:	89 e5                	mov    %esp,%ebp
c0100e42:	83 ec 10             	sub    $0x10,%esp
c0100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e4f:	89 c2                	mov    %eax,%edx
c0100e51:	ec                   	in     (%dx),%al
c0100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	89 c2                	mov    %eax,%edx
c0100e71:	ec                   	in     (%dx),%al
c0100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
c0100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 00             	movzwl (%eax),%eax
c0100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eb0:	74 12                	je     c0100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb9:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ec0:	b4 03 
c0100ec2:	eb 13                	jmp    c0100ed7 <cga_init+0x50>
    } else {
        *cp = was;
c0100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ece:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed7:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef9:	83 c0 01             	add    $0x1,%eax
c0100efc:	0f b7 c0             	movzwl %ax,%eax
c0100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f07:	89 c2                	mov    %eax,%edx
c0100f09:	ec                   	in     (%dx),%al
c0100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f11:	0f b6 c0             	movzbl %al,%eax
c0100f14:	c1 e0 08             	shl    $0x8,%eax
c0100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f1a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f35:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3c:	83 c0 01             	add    $0x1,%eax
c0100f3f:	0f b7 c0             	movzwl %ax,%eax
c0100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f4a:	89 c2                	mov    %eax,%edx
c0100f4c:	ec                   	in     (%dx),%al
c0100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f54:	0f b6 c0             	movzbl %al,%eax
c0100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5d:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f65:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f6b:	c9                   	leave  
c0100f6c:	c3                   	ret    

c0100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f6d:	55                   	push   %ebp
c0100f6e:	89 e5                	mov    %esp,%ebp
c0100f70:	83 ec 48             	sub    $0x48,%esp
c0100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f85:	ee                   	out    %al,(%dx)
c0100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f98:	ee                   	out    %al,(%dx)
c0100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fab:	ee                   	out    %al,(%dx)
c0100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fbe:	ee                   	out    %al,(%dx)
c0100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd1:	ee                   	out    %al,(%dx)
c0100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
c0100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff7:	ee                   	out    %al,(%dx)
c0100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101002:	89 c2                	mov    %eax,%edx
c0101004:	ec                   	in     (%dx),%al
c0101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010100c:	3c ff                	cmp    $0xff,%al
c010100e:	0f 95 c0             	setne  %al
c0101011:	0f b6 c0             	movzbl %al,%eax
c0101014:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101023:	89 c2                	mov    %eax,%edx
c0101025:	ec                   	in     (%dx),%al
c0101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101033:	89 c2                	mov    %eax,%edx
c0101035:	ec                   	in     (%dx),%al
c0101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101039:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010103e:	85 c0                	test   %eax,%eax
c0101040:	74 0c                	je     c010104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101049:	e8 d6 06 00 00       	call   c0101724 <pic_enable>
    }
}
c010104e:	c9                   	leave  
c010104f:	c3                   	ret    

c0101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101050:	55                   	push   %ebp
c0101051:	89 e5                	mov    %esp,%ebp
c0101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105d:	eb 09                	jmp    c0101068 <lpt_putc_sub+0x18>
        delay();
c010105f:	e8 db fd ff ff       	call   c0100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101072:	89 c2                	mov    %eax,%edx
c0101074:	ec                   	in     (%dx),%al
c0101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010107c:	84 c0                	test   %al,%al
c010107e:	78 09                	js     c0101089 <lpt_putc_sub+0x39>
c0101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101087:	7e d6                	jle    c010105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101089:	8b 45 08             	mov    0x8(%ebp),%eax
c010108c:	0f b6 c0             	movzbl %al,%eax
c010108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010a0:	ee                   	out    %al,(%dx)
c01010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b3:	ee                   	out    %al,(%dx)
c01010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c7:	c9                   	leave  
c01010c8:	c3                   	ret    

c01010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c9:	55                   	push   %ebp
c01010ca:	89 e5                	mov    %esp,%ebp
c01010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d3:	74 0d                	je     c01010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d8:	89 04 24             	mov    %eax,(%esp)
c01010db:	e8 70 ff ff ff       	call   c0101050 <lpt_putc_sub>
c01010e0:	eb 24                	jmp    c0101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e9:	e8 62 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f5:	e8 56 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101101:	e8 4a ff ff ff       	call   c0101050 <lpt_putc_sub>
    }
}
c0101106:	c9                   	leave  
c0101107:	c3                   	ret    

c0101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101108:	55                   	push   %ebp
c0101109:	89 e5                	mov    %esp,%ebp
c010110b:	53                   	push   %ebx
c010110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101112:	b0 00                	mov    $0x0,%al
c0101114:	85 c0                	test   %eax,%eax
c0101116:	75 07                	jne    c010111f <cga_putc+0x17>
        c |= 0x0700;
c0101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010111f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101122:	0f b6 c0             	movzbl %al,%eax
c0101125:	83 f8 0a             	cmp    $0xa,%eax
c0101128:	74 4c                	je     c0101176 <cga_putc+0x6e>
c010112a:	83 f8 0d             	cmp    $0xd,%eax
c010112d:	74 57                	je     c0101186 <cga_putc+0x7e>
c010112f:	83 f8 08             	cmp    $0x8,%eax
c0101132:	0f 85 88 00 00 00    	jne    c01011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101138:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113f:	66 85 c0             	test   %ax,%ax
c0101142:	74 30                	je     c0101174 <cga_putc+0x6c>
            crt_pos --;
c0101144:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010114b:	83 e8 01             	sub    $0x1,%eax
c010114e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101154:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101159:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101160:	0f b7 d2             	movzwl %dx,%edx
c0101163:	01 d2                	add    %edx,%edx
c0101165:	01 c2                	add    %eax,%edx
c0101167:	8b 45 08             	mov    0x8(%ebp),%eax
c010116a:	b0 00                	mov    $0x0,%al
c010116c:	83 c8 20             	or     $0x20,%eax
c010116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101172:	eb 72                	jmp    c01011e6 <cga_putc+0xde>
c0101174:	eb 70                	jmp    c01011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101176:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010117d:	83 c0 50             	add    $0x50,%eax
c0101180:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101186:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101194:	0f b7 c1             	movzwl %cx,%eax
c0101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010119d:	c1 e8 10             	shr    $0x10,%eax
c01011a0:	89 c2                	mov    %eax,%edx
c01011a2:	66 c1 ea 06          	shr    $0x6,%dx
c01011a6:	89 d0                	mov    %edx,%eax
c01011a8:	c1 e0 02             	shl    $0x2,%eax
c01011ab:	01 d0                	add    %edx,%eax
c01011ad:	c1 e0 04             	shl    $0x4,%eax
c01011b0:	29 c1                	sub    %eax,%ecx
c01011b2:	89 ca                	mov    %ecx,%edx
c01011b4:	89 d8                	mov    %ebx,%eax
c01011b6:	29 d0                	sub    %edx,%eax
c01011b8:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011be:	eb 26                	jmp    c01011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011c0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011cd:	8d 50 01             	lea    0x1(%eax),%edx
c01011d0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011d7:	0f b7 c0             	movzwl %ax,%eax
c01011da:	01 c0                	add    %eax,%eax
c01011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011df:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011f1:	76 5b                	jbe    c010124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f3:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fe:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120a:	00 
c010120b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120f:	89 04 24             	mov    %eax,(%esp)
c0101212:	e8 b3 4c 00 00       	call   c0105eca <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121e:	eb 15                	jmp    c0101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101220:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101228:	01 d2                	add    %edx,%edx
c010122a:	01 d0                	add    %edx,%eax
c010122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123c:	7e e2                	jle    c0101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101245:	83 e8 50             	sub    $0x50,%eax
c0101248:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101255:	0f b7 c0             	movzwl %ax,%eax
c0101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101269:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101270:	66 c1 e8 08          	shr    $0x8,%ax
c0101274:	0f b6 c0             	movzbl %al,%eax
c0101277:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127e:	83 c2 01             	add    $0x1,%edx
c0101281:	0f b7 d2             	movzwl %dx,%edx
c0101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101288:	88 45 ed             	mov    %al,-0x13(%ebp)
c010128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101294:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010129b:	0f b7 c0             	movzwl %ax,%eax
c010129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012af:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b6:	0f b6 c0             	movzbl %al,%eax
c01012b9:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012c0:	83 c2 01             	add    $0x1,%edx
c01012c3:	0f b7 d2             	movzwl %dx,%edx
c01012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012d5:	ee                   	out    %al,(%dx)
}
c01012d6:	83 c4 34             	add    $0x34,%esp
c01012d9:	5b                   	pop    %ebx
c01012da:	5d                   	pop    %ebp
c01012db:	c3                   	ret    

c01012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012dc:	55                   	push   %ebp
c01012dd:	89 e5                	mov    %esp,%ebp
c01012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e9:	eb 09                	jmp    c01012f4 <serial_putc_sub+0x18>
        delay();
c01012eb:	e8 4f fb ff ff       	call   c0100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fe:	89 c2                	mov    %eax,%edx
c0101300:	ec                   	in     (%dx),%al
c0101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101308:	0f b6 c0             	movzbl %al,%eax
c010130b:	83 e0 20             	and    $0x20,%eax
c010130e:	85 c0                	test   %eax,%eax
c0101310:	75 09                	jne    c010131b <serial_putc_sub+0x3f>
c0101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101319:	7e d0                	jle    c01012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010131b:	8b 45 08             	mov    0x8(%ebp),%eax
c010131e:	0f b6 c0             	movzbl %al,%eax
c0101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101332:	ee                   	out    %al,(%dx)
}
c0101333:	c9                   	leave  
c0101334:	c3                   	ret    

c0101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101335:	55                   	push   %ebp
c0101336:	89 e5                	mov    %esp,%ebp
c0101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133f:	74 0d                	je     c010134e <serial_putc+0x19>
        serial_putc_sub(c);
c0101341:	8b 45 08             	mov    0x8(%ebp),%eax
c0101344:	89 04 24             	mov    %eax,(%esp)
c0101347:	e8 90 ff ff ff       	call   c01012dc <serial_putc_sub>
c010134c:	eb 24                	jmp    c0101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101355:	e8 82 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub(' ');
c010135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101361:	e8 76 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub('\b');
c0101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136d:	e8 6a ff ff ff       	call   c01012dc <serial_putc_sub>
    }
}
c0101372:	c9                   	leave  
c0101373:	c3                   	ret    

c0101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101374:	55                   	push   %ebp
c0101375:	89 e5                	mov    %esp,%ebp
c0101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010137a:	eb 33                	jmp    c01013af <cons_intr+0x3b>
        if (c != 0) {
c010137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101380:	74 2d                	je     c01013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101382:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101387:	8d 50 01             	lea    0x1(%eax),%edx
c010138a:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101393:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101399:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139e:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a3:	75 0a                	jne    c01013af <cons_intr+0x3b>
                cons.wpos = 0;
c01013a5:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013af:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b2:	ff d0                	call   *%eax
c01013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013bb:	75 bf                	jne    c010137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 43 ff ff ff       	call   c0101374 <cons_intr>
    }
}
c0101431:	c9                   	leave  
c0101432:	c3                   	ret    

c0101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101433:	55                   	push   %ebp
c0101434:	89 e5                	mov    %esp,%ebp
c0101436:	83 ec 38             	sub    $0x38,%esp
c0101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2e>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 59 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010146b:	89 c2                	mov    %eax,%edx
c010146d:	ec                   	in     (%dx),%al
c010146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147c:	75 17                	jne    c0101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010147e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101483:	83 c8 40             	or     $0x40,%eax
c0101486:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010148b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101490:	e9 25 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101499:	84 c0                	test   %al,%al
c010149b:	79 47                	jns    c01014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a2:	83 e0 40             	and    $0x40,%eax
c01014a5:	85 c0                	test   %eax,%eax
c01014a7:	75 09                	jne    c01014b2 <kbd_proc_data+0x7f>
c01014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ad:	83 e0 7f             	and    $0x7f,%eax
c01014b0:	eb 04                	jmp    c01014b6 <kbd_proc_data+0x83>
c01014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bd:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c4:	83 c8 40             	or     $0x40,%eax
c01014c7:	0f b6 c0             	movzbl %al,%eax
c01014ca:	f7 d0                	not    %eax
c01014cc:	89 c2                	mov    %eax,%edx
c01014ce:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d3:	21 d0                	and    %edx,%eax
c01014d5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014da:	b8 00 00 00 00       	mov    $0x0,%eax
c01014df:	e9 d6 00 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014e4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e9:	83 e0 40             	and    $0x40,%eax
c01014ec:	85 c0                	test   %eax,%eax
c01014ee:	74 11                	je     c0101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f9:	83 e0 bf             	and    $0xffffffbf,%eax
c01014fc:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101505:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010150c:	0f b6 d0             	movzbl %al,%edx
c010150f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101514:	09 d0                	or     %edx,%eax
c0101516:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101526:	0f b6 d0             	movzbl %al,%edx
c0101529:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152e:	31 d0                	xor    %edx,%eax
c0101530:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101535:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010153a:	83 e0 03             	and    $0x3,%eax
c010153d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101548:	01 d0                	add    %edx,%eax
c010154a:	0f b6 00             	movzbl (%eax),%eax
c010154d:	0f b6 c0             	movzbl %al,%eax
c0101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101553:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101558:	83 e0 08             	and    $0x8,%eax
c010155b:	85 c0                	test   %eax,%eax
c010155d:	74 22                	je     c0101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101563:	7e 0c                	jle    c0101571 <kbd_proc_data+0x13e>
c0101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101569:	7f 06                	jg     c0101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156f:	eb 10                	jmp    c0101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101575:	7e 0a                	jle    c0101581 <kbd_proc_data+0x14e>
c0101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010157b:	7f 04                	jg     c0101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101581:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101586:	f7 d0                	not    %eax
c0101588:	83 e0 06             	and    $0x6,%eax
c010158b:	85 c0                	test   %eax,%eax
c010158d:	75 28                	jne    c01015b7 <kbd_proc_data+0x184>
c010158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101596:	75 1f                	jne    c01015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101598:	c7 04 24 4f 63 10 c0 	movl   $0xc010634f,(%esp)
c010159f:	e8 a4 ed ff ff       	call   c0100348 <cprintf>
c01015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ba:	c9                   	leave  
c01015bb:	c3                   	ret    

c01015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015bc:	55                   	push   %ebp
c01015bd:	89 e5                	mov    %esp,%ebp
c01015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015c2:	c7 04 24 33 14 10 c0 	movl   $0xc0101433,(%esp)
c01015c9:	e8 a6 fd ff ff       	call   c0101374 <cons_intr>
}
c01015ce:	c9                   	leave  
c01015cf:	c3                   	ret    

c01015d0 <kbd_init>:

static void
kbd_init(void) {
c01015d0:	55                   	push   %ebp
c01015d1:	89 e5                	mov    %esp,%ebp
c01015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d6:	e8 e1 ff ff ff       	call   c01015bc <kbd_intr>
    pic_enable(IRQ_KBD);
c01015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015e2:	e8 3d 01 00 00       	call   c0101724 <pic_enable>
}
c01015e7:	c9                   	leave  
c01015e8:	c3                   	ret    

c01015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e9:	55                   	push   %ebp
c01015ea:	89 e5                	mov    %esp,%ebp
c01015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ef:	e8 93 f8 ff ff       	call   c0100e87 <cga_init>
    serial_init();
c01015f4:	e8 74 f9 ff ff       	call   c0100f6d <serial_init>
    kbd_init();
c01015f9:	e8 d2 ff ff ff       	call   c01015d0 <kbd_init>
    if (!serial_exists) {
c01015fe:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101603:	85 c0                	test   %eax,%eax
c0101605:	75 0c                	jne    c0101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101607:	c7 04 24 5b 63 10 c0 	movl   $0xc010635b,(%esp)
c010160e:	e8 35 ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101613:	c9                   	leave  
c0101614:	c3                   	ret    

c0101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101615:	55                   	push   %ebp
c0101616:	89 e5                	mov    %esp,%ebp
c0101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161b:	e8 e2 f7 ff ff       	call   c0100e02 <__intr_save>
c0101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101623:	8b 45 08             	mov    0x8(%ebp),%eax
c0101626:	89 04 24             	mov    %eax,(%esp)
c0101629:	e8 9b fa ff ff       	call   c01010c9 <lpt_putc>
        cga_putc(c);
c010162e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101631:	89 04 24             	mov    %eax,(%esp)
c0101634:	e8 cf fa ff ff       	call   c0101108 <cga_putc>
        serial_putc(c);
c0101639:	8b 45 08             	mov    0x8(%ebp),%eax
c010163c:	89 04 24             	mov    %eax,(%esp)
c010163f:	e8 f1 fc ff ff       	call   c0101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 dd f7 ff ff       	call   c0100e2c <__intr_restore>
}
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 9f f7 ff ff       	call   c0100e02 <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 4c ff ff ff       	call   c01015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101676:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168d:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 71 f7 ff ff       	call   c0100e2c <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016c3:	fb                   	sti    
    sti();
}
c01016c4:	5d                   	pop    %ebp
c01016c5:	c3                   	ret    

c01016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016c6:	55                   	push   %ebp
c01016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016c9:	fa                   	cli    
    cli();
}
c01016ca:	5d                   	pop    %ebp
c01016cb:	c3                   	ret    

c01016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016cc:	55                   	push   %ebp
c01016cd:	89 e5                	mov    %esp,%ebp
c01016cf:	83 ec 14             	sub    $0x14,%esp
c01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016dd:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e3:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e8:	85 c0                	test   %eax,%eax
c01016ea:	74 36                	je     c0101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101709:	66 c1 e8 08          	shr    $0x8,%ax
c010170d:	0f b6 c0             	movzbl %al,%eax
c0101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101716:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101721:	ee                   	out    %al,(%dx)
    }
}
c0101722:	c9                   	leave  
c0101723:	c3                   	ret    

c0101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101724:	55                   	push   %ebp
c0101725:	89 e5                	mov    %esp,%ebp
c0101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010172a:	8b 45 08             	mov    0x8(%ebp),%eax
c010172d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101732:	89 c1                	mov    %eax,%ecx
c0101734:	d3 e2                	shl    %cl,%edx
c0101736:	89 d0                	mov    %edx,%eax
c0101738:	f7 d0                	not    %eax
c010173a:	89 c2                	mov    %eax,%edx
c010173c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101743:	21 d0                	and    %edx,%eax
c0101745:	0f b7 c0             	movzwl %ax,%eax
c0101748:	89 04 24             	mov    %eax,(%esp)
c010174b:	e8 7c ff ff ff       	call   c01016cc <pic_setmask>
}
c0101750:	c9                   	leave  
c0101751:	c3                   	ret    

c0101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101752:	55                   	push   %ebp
c0101753:	89 e5                	mov    %esp,%ebp
c0101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101758:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175f:	00 00 00 
c0101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101774:	ee                   	out    %al,(%dx)
c0101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
c0101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010179a:	ee                   	out    %al,(%dx)
c010179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ad:	ee                   	out    %al,(%dx)
c01017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017c0:	ee                   	out    %al,(%dx)
c01017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d3:	ee                   	out    %al,(%dx)
c01017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e6:	ee                   	out    %al,(%dx)
c01017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
c01017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
c0101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101845:	ee                   	out    %al,(%dx)
c0101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101858:	ee                   	out    %al,(%dx)
c0101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101873:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101877:	74 12                	je     c010188b <pic_init+0x139>
        pic_setmask(irq_mask);
c0101879:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 04 24             	mov    %eax,(%esp)
c0101886:	e8 41 fe ff ff       	call   c01016cc <pic_setmask>
    }
}
c010188b:	c9                   	leave  
c010188c:	c3                   	ret    

c010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
c0101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010189a:	00 
c010189b:	c7 04 24 80 63 10 c0 	movl   $0xc0106380,(%esp)
c01018a2:	e8 a1 ea ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018a7:	c9                   	leave  
c01018a8:	c3                   	ret    

c01018a9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018a9:	55                   	push   %ebp
c01018aa:	89 e5                	mov    %esp,%ebp
c01018ac:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c01018af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018b6:	e9 c3 00 00 00       	jmp    c010197e <idt_init+0xd5>
	{
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c01018bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018be:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018c5:	89 c2                	mov    %eax,%edx
c01018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ca:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018d1:	c0 
c01018d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018d5:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c01018dc:	c0 08 00 
c01018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e2:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018e9:	c0 
c01018ea:	83 e2 e0             	and    $0xffffffe0,%edx
c01018ed:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c01018f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f7:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c01018fe:	c0 
c01018ff:	83 e2 1f             	and    $0x1f,%edx
c0101902:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101909:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010190c:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101913:	c0 
c0101914:	83 e2 f0             	and    $0xfffffff0,%edx
c0101917:	83 ca 0e             	or     $0xe,%edx
c010191a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101921:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101924:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010192b:	c0 
c010192c:	83 e2 ef             	and    $0xffffffef,%edx
c010192f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101936:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101939:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101940:	c0 
c0101941:	83 e2 9f             	and    $0xffffff9f,%edx
c0101944:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010194b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194e:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101955:	c0 
c0101956:	83 ca 80             	or     $0xffffff80,%edx
c0101959:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101960:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101963:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010196a:	c1 e8 10             	shr    $0x10,%eax
c010196d:	89 c2                	mov    %eax,%edx
c010196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101972:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c0101979:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c010197a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010197e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101981:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101986:	0f 86 2f ff ff ff    	jbe    c01018bb <idt_init+0x12>
	{
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
	}
	SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
c010198c:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101991:	66 a3 48 aa 11 c0    	mov    %ax,0xc011aa48
c0101997:	66 c7 05 4a aa 11 c0 	movw   $0x8,0xc011aa4a
c010199e:	08 00 
c01019a0:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019a7:	83 e0 e0             	and    $0xffffffe0,%eax
c01019aa:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019af:	0f b6 05 4c aa 11 c0 	movzbl 0xc011aa4c,%eax
c01019b6:	83 e0 1f             	and    $0x1f,%eax
c01019b9:	a2 4c aa 11 c0       	mov    %al,0xc011aa4c
c01019be:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019c5:	83 e0 f0             	and    $0xfffffff0,%eax
c01019c8:	83 c8 0e             	or     $0xe,%eax
c01019cb:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019d0:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019d7:	83 e0 ef             	and    $0xffffffef,%eax
c01019da:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019df:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019e6:	83 c8 60             	or     $0x60,%eax
c01019e9:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019ee:	0f b6 05 4d aa 11 c0 	movzbl 0xc011aa4d,%eax
c01019f5:	83 c8 80             	or     $0xffffff80,%eax
c01019f8:	a2 4d aa 11 c0       	mov    %al,0xc011aa4d
c01019fd:	a1 c4 77 11 c0       	mov    0xc01177c4,%eax
c0101a02:	c1 e8 10             	shr    $0x10,%eax
c0101a05:	66 a3 4e aa 11 c0    	mov    %ax,0xc011aa4e
c0101a0b:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101a12:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101a15:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
c0101a18:	c9                   	leave  
c0101a19:	c3                   	ret    

c0101a1a <trapname>:

static const char *
trapname(int trapno) {
c0101a1a:	55                   	push   %ebp
c0101a1b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a20:	83 f8 13             	cmp    $0x13,%eax
c0101a23:	77 0c                	ja     c0101a31 <trapname+0x17>
        return excnames[trapno];
c0101a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a28:	8b 04 85 e0 66 10 c0 	mov    -0x3fef9920(,%eax,4),%eax
c0101a2f:	eb 18                	jmp    c0101a49 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101a31:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101a35:	7e 0d                	jle    c0101a44 <trapname+0x2a>
c0101a37:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101a3b:	7f 07                	jg     c0101a44 <trapname+0x2a>
        return "Hardware Interrupt";
c0101a3d:	b8 8a 63 10 c0       	mov    $0xc010638a,%eax
c0101a42:	eb 05                	jmp    c0101a49 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101a44:	b8 9d 63 10 c0       	mov    $0xc010639d,%eax
}
c0101a49:	5d                   	pop    %ebp
c0101a4a:	c3                   	ret    

c0101a4b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101a4b:	55                   	push   %ebp
c0101a4c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a51:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a55:	66 83 f8 08          	cmp    $0x8,%ax
c0101a59:	0f 94 c0             	sete   %al
c0101a5c:	0f b6 c0             	movzbl %al,%eax
}
c0101a5f:	5d                   	pop    %ebp
c0101a60:	c3                   	ret    

c0101a61 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a61:	55                   	push   %ebp
c0101a62:	89 e5                	mov    %esp,%ebp
c0101a64:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a6e:	c7 04 24 de 63 10 c0 	movl   $0xc01063de,(%esp)
c0101a75:	e8 ce e8 ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7d:	89 04 24             	mov    %eax,(%esp)
c0101a80:	e8 a1 01 00 00       	call   c0101c26 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a88:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a8c:	0f b7 c0             	movzwl %ax,%eax
c0101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a93:	c7 04 24 ef 63 10 c0 	movl   $0xc01063ef,(%esp)
c0101a9a:	e8 a9 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101aa6:	0f b7 c0             	movzwl %ax,%eax
c0101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aad:	c7 04 24 02 64 10 c0 	movl   $0xc0106402,(%esp)
c0101ab4:	e8 8f e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abc:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101ac0:	0f b7 c0             	movzwl %ax,%eax
c0101ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac7:	c7 04 24 15 64 10 c0 	movl   $0xc0106415,(%esp)
c0101ace:	e8 75 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad6:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101ada:	0f b7 c0             	movzwl %ax,%eax
c0101add:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae1:	c7 04 24 28 64 10 c0 	movl   $0xc0106428,(%esp)
c0101ae8:	e8 5b e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af0:	8b 40 30             	mov    0x30(%eax),%eax
c0101af3:	89 04 24             	mov    %eax,(%esp)
c0101af6:	e8 1f ff ff ff       	call   c0101a1a <trapname>
c0101afb:	8b 55 08             	mov    0x8(%ebp),%edx
c0101afe:	8b 52 30             	mov    0x30(%edx),%edx
c0101b01:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101b05:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b09:	c7 04 24 3b 64 10 c0 	movl   $0xc010643b,(%esp)
c0101b10:	e8 33 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101b15:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b18:	8b 40 34             	mov    0x34(%eax),%eax
c0101b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b1f:	c7 04 24 4d 64 10 c0 	movl   $0xc010644d,(%esp)
c0101b26:	e8 1d e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2e:	8b 40 38             	mov    0x38(%eax),%eax
c0101b31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b35:	c7 04 24 5c 64 10 c0 	movl   $0xc010645c,(%esp)
c0101b3c:	e8 07 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b44:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b48:	0f b7 c0             	movzwl %ax,%eax
c0101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b4f:	c7 04 24 6b 64 10 c0 	movl   $0xc010646b,(%esp)
c0101b56:	e8 ed e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5e:	8b 40 40             	mov    0x40(%eax),%eax
c0101b61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b65:	c7 04 24 7e 64 10 c0 	movl   $0xc010647e,(%esp)
c0101b6c:	e8 d7 e7 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b78:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b7f:	eb 3e                	jmp    c0101bbf <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b84:	8b 50 40             	mov    0x40(%eax),%edx
c0101b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b8a:	21 d0                	and    %edx,%eax
c0101b8c:	85 c0                	test   %eax,%eax
c0101b8e:	74 28                	je     c0101bb8 <print_trapframe+0x157>
c0101b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b93:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b9a:	85 c0                	test   %eax,%eax
c0101b9c:	74 1a                	je     c0101bb8 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ba1:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bac:	c7 04 24 8d 64 10 c0 	movl   $0xc010648d,(%esp)
c0101bb3:	e8 90 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101bb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101bbc:	d1 65 f0             	shll   -0x10(%ebp)
c0101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bc2:	83 f8 17             	cmp    $0x17,%eax
c0101bc5:	76 ba                	jbe    c0101b81 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bca:	8b 40 40             	mov    0x40(%eax),%eax
c0101bcd:	25 00 30 00 00       	and    $0x3000,%eax
c0101bd2:	c1 e8 0c             	shr    $0xc,%eax
c0101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd9:	c7 04 24 91 64 10 c0 	movl   $0xc0106491,(%esp)
c0101be0:	e8 63 e7 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be8:	89 04 24             	mov    %eax,(%esp)
c0101beb:	e8 5b fe ff ff       	call   c0101a4b <trap_in_kernel>
c0101bf0:	85 c0                	test   %eax,%eax
c0101bf2:	75 30                	jne    c0101c24 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf7:	8b 40 44             	mov    0x44(%eax),%eax
c0101bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfe:	c7 04 24 9a 64 10 c0 	movl   $0xc010649a,(%esp)
c0101c05:	e8 3e e7 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101c11:	0f b7 c0             	movzwl %ax,%eax
c0101c14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c18:	c7 04 24 a9 64 10 c0 	movl   $0xc01064a9,(%esp)
c0101c1f:	e8 24 e7 ff ff       	call   c0100348 <cprintf>
    }
}
c0101c24:	c9                   	leave  
c0101c25:	c3                   	ret    

c0101c26 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101c26:	55                   	push   %ebp
c0101c27:	89 e5                	mov    %esp,%ebp
c0101c29:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2f:	8b 00                	mov    (%eax),%eax
c0101c31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c35:	c7 04 24 bc 64 10 c0 	movl   $0xc01064bc,(%esp)
c0101c3c:	e8 07 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101c41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c44:	8b 40 04             	mov    0x4(%eax),%eax
c0101c47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4b:	c7 04 24 cb 64 10 c0 	movl   $0xc01064cb,(%esp)
c0101c52:	e8 f1 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c57:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5a:	8b 40 08             	mov    0x8(%eax),%eax
c0101c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c61:	c7 04 24 da 64 10 c0 	movl   $0xc01064da,(%esp)
c0101c68:	e8 db e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c70:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c77:	c7 04 24 e9 64 10 c0 	movl   $0xc01064e9,(%esp)
c0101c7e:	e8 c5 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c86:	8b 40 10             	mov    0x10(%eax),%eax
c0101c89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c8d:	c7 04 24 f8 64 10 c0 	movl   $0xc01064f8,(%esp)
c0101c94:	e8 af e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c9c:	8b 40 14             	mov    0x14(%eax),%eax
c0101c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ca3:	c7 04 24 07 65 10 c0 	movl   $0xc0106507,(%esp)
c0101caa:	e8 99 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb2:	8b 40 18             	mov    0x18(%eax),%eax
c0101cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cb9:	c7 04 24 16 65 10 c0 	movl   $0xc0106516,(%esp)
c0101cc0:	e8 83 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cc8:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccf:	c7 04 24 25 65 10 c0 	movl   $0xc0106525,(%esp)
c0101cd6:	e8 6d e6 ff ff       	call   c0100348 <cprintf>
}
c0101cdb:	c9                   	leave  
c0101cdc:	c3                   	ret    

c0101cdd <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101cdd:	55                   	push   %ebp
c0101cde:	89 e5                	mov    %esp,%ebp
c0101ce0:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce6:	8b 40 30             	mov    0x30(%eax),%eax
c0101ce9:	83 f8 2f             	cmp    $0x2f,%eax
c0101cec:	77 21                	ja     c0101d0f <trap_dispatch+0x32>
c0101cee:	83 f8 2e             	cmp    $0x2e,%eax
c0101cf1:	0f 83 04 01 00 00    	jae    c0101dfb <trap_dispatch+0x11e>
c0101cf7:	83 f8 21             	cmp    $0x21,%eax
c0101cfa:	0f 84 81 00 00 00    	je     c0101d81 <trap_dispatch+0xa4>
c0101d00:	83 f8 24             	cmp    $0x24,%eax
c0101d03:	74 56                	je     c0101d5b <trap_dispatch+0x7e>
c0101d05:	83 f8 20             	cmp    $0x20,%eax
c0101d08:	74 16                	je     c0101d20 <trap_dispatch+0x43>
c0101d0a:	e9 b4 00 00 00       	jmp    c0101dc3 <trap_dispatch+0xe6>
c0101d0f:	83 e8 78             	sub    $0x78,%eax
c0101d12:	83 f8 01             	cmp    $0x1,%eax
c0101d15:	0f 87 a8 00 00 00    	ja     c0101dc3 <trap_dispatch+0xe6>
c0101d1b:	e9 87 00 00 00       	jmp    c0101da7 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
		++ticks;
c0101d20:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101d25:	83 c0 01             	add    $0x1,%eax
c0101d28:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
		if(ticks % TICK_NUM == 0)
c0101d2d:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101d33:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101d38:	89 c8                	mov    %ecx,%eax
c0101d3a:	f7 e2                	mul    %edx
c0101d3c:	89 d0                	mov    %edx,%eax
c0101d3e:	c1 e8 05             	shr    $0x5,%eax
c0101d41:	6b c0 64             	imul   $0x64,%eax,%eax
c0101d44:	29 c1                	sub    %eax,%ecx
c0101d46:	89 c8                	mov    %ecx,%eax
c0101d48:	85 c0                	test   %eax,%eax
c0101d4a:	75 0a                	jne    c0101d56 <trap_dispatch+0x79>
		{
			print_ticks();
c0101d4c:	e8 3c fb ff ff       	call   c010188d <print_ticks>
		}
        break;
c0101d51:	e9 a6 00 00 00       	jmp    c0101dfc <trap_dispatch+0x11f>
c0101d56:	e9 a1 00 00 00       	jmp    c0101dfc <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d5b:	e8 f1 f8 ff ff       	call   c0101651 <cons_getc>
c0101d60:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d63:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d67:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d73:	c7 04 24 34 65 10 c0 	movl   $0xc0106534,(%esp)
c0101d7a:	e8 c9 e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101d7f:	eb 7b                	jmp    c0101dfc <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d81:	e8 cb f8 ff ff       	call   c0101651 <cons_getc>
c0101d86:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d89:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d8d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d91:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d99:	c7 04 24 46 65 10 c0 	movl   $0xc0106546,(%esp)
c0101da0:	e8 a3 e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101da5:	eb 55                	jmp    c0101dfc <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101da7:	c7 44 24 08 55 65 10 	movl   $0xc0106555,0x8(%esp)
c0101dae:	c0 
c0101daf:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0101db6:	00 
c0101db7:	c7 04 24 65 65 10 c0 	movl   $0xc0106565,(%esp)
c0101dbe:	e8 0f ef ff ff       	call   c0100cd2 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101dca:	0f b7 c0             	movzwl %ax,%eax
c0101dcd:	83 e0 03             	and    $0x3,%eax
c0101dd0:	85 c0                	test   %eax,%eax
c0101dd2:	75 28                	jne    c0101dfc <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd7:	89 04 24             	mov    %eax,(%esp)
c0101dda:	e8 82 fc ff ff       	call   c0101a61 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101ddf:	c7 44 24 08 76 65 10 	movl   $0xc0106576,0x8(%esp)
c0101de6:	c0 
c0101de7:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0101dee:	00 
c0101def:	c7 04 24 65 65 10 c0 	movl   $0xc0106565,(%esp)
c0101df6:	e8 d7 ee ff ff       	call   c0100cd2 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101dfb:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101dfc:	c9                   	leave  
c0101dfd:	c3                   	ret    

c0101dfe <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101dfe:	55                   	push   %ebp
c0101dff:	89 e5                	mov    %esp,%ebp
c0101e01:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101e04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e07:	89 04 24             	mov    %eax,(%esp)
c0101e0a:	e8 ce fe ff ff       	call   c0101cdd <trap_dispatch>
}
c0101e0f:	c9                   	leave  
c0101e10:	c3                   	ret    

c0101e11 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101e11:	1e                   	push   %ds
    pushl %es
c0101e12:	06                   	push   %es
    pushl %fs
c0101e13:	0f a0                	push   %fs
    pushl %gs
c0101e15:	0f a8                	push   %gs
    pushal
c0101e17:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101e18:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101e1d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101e1f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101e21:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101e22:	e8 d7 ff ff ff       	call   c0101dfe <trap>

    # pop the pushed stack pointer
    popl %esp
c0101e27:	5c                   	pop    %esp

c0101e28 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101e28:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101e29:	0f a9                	pop    %gs
    popl %fs
c0101e2b:	0f a1                	pop    %fs
    popl %es
c0101e2d:	07                   	pop    %es
    popl %ds
c0101e2e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101e2f:	83 c4 08             	add    $0x8,%esp
    iret
c0101e32:	cf                   	iret   

c0101e33 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101e33:	6a 00                	push   $0x0
  pushl $0
c0101e35:	6a 00                	push   $0x0
  jmp __alltraps
c0101e37:	e9 d5 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e3c <vector1>:
.globl vector1
vector1:
  pushl $0
c0101e3c:	6a 00                	push   $0x0
  pushl $1
c0101e3e:	6a 01                	push   $0x1
  jmp __alltraps
c0101e40:	e9 cc ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e45 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101e45:	6a 00                	push   $0x0
  pushl $2
c0101e47:	6a 02                	push   $0x2
  jmp __alltraps
c0101e49:	e9 c3 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e4e <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e4e:	6a 00                	push   $0x0
  pushl $3
c0101e50:	6a 03                	push   $0x3
  jmp __alltraps
c0101e52:	e9 ba ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e57 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e57:	6a 00                	push   $0x0
  pushl $4
c0101e59:	6a 04                	push   $0x4
  jmp __alltraps
c0101e5b:	e9 b1 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e60 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e60:	6a 00                	push   $0x0
  pushl $5
c0101e62:	6a 05                	push   $0x5
  jmp __alltraps
c0101e64:	e9 a8 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e69 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $6
c0101e6b:	6a 06                	push   $0x6
  jmp __alltraps
c0101e6d:	e9 9f ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e72 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e72:	6a 00                	push   $0x0
  pushl $7
c0101e74:	6a 07                	push   $0x7
  jmp __alltraps
c0101e76:	e9 96 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e7b <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e7b:	6a 08                	push   $0x8
  jmp __alltraps
c0101e7d:	e9 8f ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e82 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e82:	6a 00                	push   $0x0
  pushl $9
c0101e84:	6a 09                	push   $0x9
  jmp __alltraps
c0101e86:	e9 86 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e8b <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e8b:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e8d:	e9 7f ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e92 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e92:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e94:	e9 78 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101e99 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e99:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e9b:	e9 71 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ea0 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101ea0:	6a 0d                	push   $0xd
  jmp __alltraps
c0101ea2:	e9 6a ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ea7 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101ea7:	6a 0e                	push   $0xe
  jmp __alltraps
c0101ea9:	e9 63 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101eae <vector15>:
.globl vector15
vector15:
  pushl $0
c0101eae:	6a 00                	push   $0x0
  pushl $15
c0101eb0:	6a 0f                	push   $0xf
  jmp __alltraps
c0101eb2:	e9 5a ff ff ff       	jmp    c0101e11 <__alltraps>

c0101eb7 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101eb7:	6a 00                	push   $0x0
  pushl $16
c0101eb9:	6a 10                	push   $0x10
  jmp __alltraps
c0101ebb:	e9 51 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ec0 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101ec0:	6a 11                	push   $0x11
  jmp __alltraps
c0101ec2:	e9 4a ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ec7 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101ec7:	6a 00                	push   $0x0
  pushl $18
c0101ec9:	6a 12                	push   $0x12
  jmp __alltraps
c0101ecb:	e9 41 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ed0 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101ed0:	6a 00                	push   $0x0
  pushl $19
c0101ed2:	6a 13                	push   $0x13
  jmp __alltraps
c0101ed4:	e9 38 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ed9 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101ed9:	6a 00                	push   $0x0
  pushl $20
c0101edb:	6a 14                	push   $0x14
  jmp __alltraps
c0101edd:	e9 2f ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ee2 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101ee2:	6a 00                	push   $0x0
  pushl $21
c0101ee4:	6a 15                	push   $0x15
  jmp __alltraps
c0101ee6:	e9 26 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101eeb <vector22>:
.globl vector22
vector22:
  pushl $0
c0101eeb:	6a 00                	push   $0x0
  pushl $22
c0101eed:	6a 16                	push   $0x16
  jmp __alltraps
c0101eef:	e9 1d ff ff ff       	jmp    c0101e11 <__alltraps>

c0101ef4 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101ef4:	6a 00                	push   $0x0
  pushl $23
c0101ef6:	6a 17                	push   $0x17
  jmp __alltraps
c0101ef8:	e9 14 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101efd <vector24>:
.globl vector24
vector24:
  pushl $0
c0101efd:	6a 00                	push   $0x0
  pushl $24
c0101eff:	6a 18                	push   $0x18
  jmp __alltraps
c0101f01:	e9 0b ff ff ff       	jmp    c0101e11 <__alltraps>

c0101f06 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101f06:	6a 00                	push   $0x0
  pushl $25
c0101f08:	6a 19                	push   $0x19
  jmp __alltraps
c0101f0a:	e9 02 ff ff ff       	jmp    c0101e11 <__alltraps>

c0101f0f <vector26>:
.globl vector26
vector26:
  pushl $0
c0101f0f:	6a 00                	push   $0x0
  pushl $26
c0101f11:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101f13:	e9 f9 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f18 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101f18:	6a 00                	push   $0x0
  pushl $27
c0101f1a:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101f1c:	e9 f0 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f21 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101f21:	6a 00                	push   $0x0
  pushl $28
c0101f23:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101f25:	e9 e7 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f2a <vector29>:
.globl vector29
vector29:
  pushl $0
c0101f2a:	6a 00                	push   $0x0
  pushl $29
c0101f2c:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101f2e:	e9 de fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f33 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101f33:	6a 00                	push   $0x0
  pushl $30
c0101f35:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101f37:	e9 d5 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f3c <vector31>:
.globl vector31
vector31:
  pushl $0
c0101f3c:	6a 00                	push   $0x0
  pushl $31
c0101f3e:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101f40:	e9 cc fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f45 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101f45:	6a 00                	push   $0x0
  pushl $32
c0101f47:	6a 20                	push   $0x20
  jmp __alltraps
c0101f49:	e9 c3 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f4e <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f4e:	6a 00                	push   $0x0
  pushl $33
c0101f50:	6a 21                	push   $0x21
  jmp __alltraps
c0101f52:	e9 ba fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f57 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f57:	6a 00                	push   $0x0
  pushl $34
c0101f59:	6a 22                	push   $0x22
  jmp __alltraps
c0101f5b:	e9 b1 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f60 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f60:	6a 00                	push   $0x0
  pushl $35
c0101f62:	6a 23                	push   $0x23
  jmp __alltraps
c0101f64:	e9 a8 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f69 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f69:	6a 00                	push   $0x0
  pushl $36
c0101f6b:	6a 24                	push   $0x24
  jmp __alltraps
c0101f6d:	e9 9f fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f72 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f72:	6a 00                	push   $0x0
  pushl $37
c0101f74:	6a 25                	push   $0x25
  jmp __alltraps
c0101f76:	e9 96 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f7b <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f7b:	6a 00                	push   $0x0
  pushl $38
c0101f7d:	6a 26                	push   $0x26
  jmp __alltraps
c0101f7f:	e9 8d fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f84 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f84:	6a 00                	push   $0x0
  pushl $39
c0101f86:	6a 27                	push   $0x27
  jmp __alltraps
c0101f88:	e9 84 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f8d <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f8d:	6a 00                	push   $0x0
  pushl $40
c0101f8f:	6a 28                	push   $0x28
  jmp __alltraps
c0101f91:	e9 7b fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f96 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f96:	6a 00                	push   $0x0
  pushl $41
c0101f98:	6a 29                	push   $0x29
  jmp __alltraps
c0101f9a:	e9 72 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101f9f <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f9f:	6a 00                	push   $0x0
  pushl $42
c0101fa1:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101fa3:	e9 69 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fa8 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101fa8:	6a 00                	push   $0x0
  pushl $43
c0101faa:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101fac:	e9 60 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fb1 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101fb1:	6a 00                	push   $0x0
  pushl $44
c0101fb3:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101fb5:	e9 57 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fba <vector45>:
.globl vector45
vector45:
  pushl $0
c0101fba:	6a 00                	push   $0x0
  pushl $45
c0101fbc:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101fbe:	e9 4e fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fc3 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101fc3:	6a 00                	push   $0x0
  pushl $46
c0101fc5:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101fc7:	e9 45 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fcc <vector47>:
.globl vector47
vector47:
  pushl $0
c0101fcc:	6a 00                	push   $0x0
  pushl $47
c0101fce:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101fd0:	e9 3c fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fd5 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101fd5:	6a 00                	push   $0x0
  pushl $48
c0101fd7:	6a 30                	push   $0x30
  jmp __alltraps
c0101fd9:	e9 33 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fde <vector49>:
.globl vector49
vector49:
  pushl $0
c0101fde:	6a 00                	push   $0x0
  pushl $49
c0101fe0:	6a 31                	push   $0x31
  jmp __alltraps
c0101fe2:	e9 2a fe ff ff       	jmp    c0101e11 <__alltraps>

c0101fe7 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101fe7:	6a 00                	push   $0x0
  pushl $50
c0101fe9:	6a 32                	push   $0x32
  jmp __alltraps
c0101feb:	e9 21 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101ff0 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101ff0:	6a 00                	push   $0x0
  pushl $51
c0101ff2:	6a 33                	push   $0x33
  jmp __alltraps
c0101ff4:	e9 18 fe ff ff       	jmp    c0101e11 <__alltraps>

c0101ff9 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101ff9:	6a 00                	push   $0x0
  pushl $52
c0101ffb:	6a 34                	push   $0x34
  jmp __alltraps
c0101ffd:	e9 0f fe ff ff       	jmp    c0101e11 <__alltraps>

c0102002 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102002:	6a 00                	push   $0x0
  pushl $53
c0102004:	6a 35                	push   $0x35
  jmp __alltraps
c0102006:	e9 06 fe ff ff       	jmp    c0101e11 <__alltraps>

c010200b <vector54>:
.globl vector54
vector54:
  pushl $0
c010200b:	6a 00                	push   $0x0
  pushl $54
c010200d:	6a 36                	push   $0x36
  jmp __alltraps
c010200f:	e9 fd fd ff ff       	jmp    c0101e11 <__alltraps>

c0102014 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102014:	6a 00                	push   $0x0
  pushl $55
c0102016:	6a 37                	push   $0x37
  jmp __alltraps
c0102018:	e9 f4 fd ff ff       	jmp    c0101e11 <__alltraps>

c010201d <vector56>:
.globl vector56
vector56:
  pushl $0
c010201d:	6a 00                	push   $0x0
  pushl $56
c010201f:	6a 38                	push   $0x38
  jmp __alltraps
c0102021:	e9 eb fd ff ff       	jmp    c0101e11 <__alltraps>

c0102026 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102026:	6a 00                	push   $0x0
  pushl $57
c0102028:	6a 39                	push   $0x39
  jmp __alltraps
c010202a:	e9 e2 fd ff ff       	jmp    c0101e11 <__alltraps>

c010202f <vector58>:
.globl vector58
vector58:
  pushl $0
c010202f:	6a 00                	push   $0x0
  pushl $58
c0102031:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102033:	e9 d9 fd ff ff       	jmp    c0101e11 <__alltraps>

c0102038 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102038:	6a 00                	push   $0x0
  pushl $59
c010203a:	6a 3b                	push   $0x3b
  jmp __alltraps
c010203c:	e9 d0 fd ff ff       	jmp    c0101e11 <__alltraps>

c0102041 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102041:	6a 00                	push   $0x0
  pushl $60
c0102043:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102045:	e9 c7 fd ff ff       	jmp    c0101e11 <__alltraps>

c010204a <vector61>:
.globl vector61
vector61:
  pushl $0
c010204a:	6a 00                	push   $0x0
  pushl $61
c010204c:	6a 3d                	push   $0x3d
  jmp __alltraps
c010204e:	e9 be fd ff ff       	jmp    c0101e11 <__alltraps>

c0102053 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102053:	6a 00                	push   $0x0
  pushl $62
c0102055:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102057:	e9 b5 fd ff ff       	jmp    c0101e11 <__alltraps>

c010205c <vector63>:
.globl vector63
vector63:
  pushl $0
c010205c:	6a 00                	push   $0x0
  pushl $63
c010205e:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102060:	e9 ac fd ff ff       	jmp    c0101e11 <__alltraps>

c0102065 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102065:	6a 00                	push   $0x0
  pushl $64
c0102067:	6a 40                	push   $0x40
  jmp __alltraps
c0102069:	e9 a3 fd ff ff       	jmp    c0101e11 <__alltraps>

c010206e <vector65>:
.globl vector65
vector65:
  pushl $0
c010206e:	6a 00                	push   $0x0
  pushl $65
c0102070:	6a 41                	push   $0x41
  jmp __alltraps
c0102072:	e9 9a fd ff ff       	jmp    c0101e11 <__alltraps>

c0102077 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102077:	6a 00                	push   $0x0
  pushl $66
c0102079:	6a 42                	push   $0x42
  jmp __alltraps
c010207b:	e9 91 fd ff ff       	jmp    c0101e11 <__alltraps>

c0102080 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102080:	6a 00                	push   $0x0
  pushl $67
c0102082:	6a 43                	push   $0x43
  jmp __alltraps
c0102084:	e9 88 fd ff ff       	jmp    c0101e11 <__alltraps>

c0102089 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102089:	6a 00                	push   $0x0
  pushl $68
c010208b:	6a 44                	push   $0x44
  jmp __alltraps
c010208d:	e9 7f fd ff ff       	jmp    c0101e11 <__alltraps>

c0102092 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102092:	6a 00                	push   $0x0
  pushl $69
c0102094:	6a 45                	push   $0x45
  jmp __alltraps
c0102096:	e9 76 fd ff ff       	jmp    c0101e11 <__alltraps>

c010209b <vector70>:
.globl vector70
vector70:
  pushl $0
c010209b:	6a 00                	push   $0x0
  pushl $70
c010209d:	6a 46                	push   $0x46
  jmp __alltraps
c010209f:	e9 6d fd ff ff       	jmp    c0101e11 <__alltraps>

c01020a4 <vector71>:
.globl vector71
vector71:
  pushl $0
c01020a4:	6a 00                	push   $0x0
  pushl $71
c01020a6:	6a 47                	push   $0x47
  jmp __alltraps
c01020a8:	e9 64 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020ad <vector72>:
.globl vector72
vector72:
  pushl $0
c01020ad:	6a 00                	push   $0x0
  pushl $72
c01020af:	6a 48                	push   $0x48
  jmp __alltraps
c01020b1:	e9 5b fd ff ff       	jmp    c0101e11 <__alltraps>

c01020b6 <vector73>:
.globl vector73
vector73:
  pushl $0
c01020b6:	6a 00                	push   $0x0
  pushl $73
c01020b8:	6a 49                	push   $0x49
  jmp __alltraps
c01020ba:	e9 52 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020bf <vector74>:
.globl vector74
vector74:
  pushl $0
c01020bf:	6a 00                	push   $0x0
  pushl $74
c01020c1:	6a 4a                	push   $0x4a
  jmp __alltraps
c01020c3:	e9 49 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020c8 <vector75>:
.globl vector75
vector75:
  pushl $0
c01020c8:	6a 00                	push   $0x0
  pushl $75
c01020ca:	6a 4b                	push   $0x4b
  jmp __alltraps
c01020cc:	e9 40 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020d1 <vector76>:
.globl vector76
vector76:
  pushl $0
c01020d1:	6a 00                	push   $0x0
  pushl $76
c01020d3:	6a 4c                	push   $0x4c
  jmp __alltraps
c01020d5:	e9 37 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020da <vector77>:
.globl vector77
vector77:
  pushl $0
c01020da:	6a 00                	push   $0x0
  pushl $77
c01020dc:	6a 4d                	push   $0x4d
  jmp __alltraps
c01020de:	e9 2e fd ff ff       	jmp    c0101e11 <__alltraps>

c01020e3 <vector78>:
.globl vector78
vector78:
  pushl $0
c01020e3:	6a 00                	push   $0x0
  pushl $78
c01020e5:	6a 4e                	push   $0x4e
  jmp __alltraps
c01020e7:	e9 25 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020ec <vector79>:
.globl vector79
vector79:
  pushl $0
c01020ec:	6a 00                	push   $0x0
  pushl $79
c01020ee:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020f0:	e9 1c fd ff ff       	jmp    c0101e11 <__alltraps>

c01020f5 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020f5:	6a 00                	push   $0x0
  pushl $80
c01020f7:	6a 50                	push   $0x50
  jmp __alltraps
c01020f9:	e9 13 fd ff ff       	jmp    c0101e11 <__alltraps>

c01020fe <vector81>:
.globl vector81
vector81:
  pushl $0
c01020fe:	6a 00                	push   $0x0
  pushl $81
c0102100:	6a 51                	push   $0x51
  jmp __alltraps
c0102102:	e9 0a fd ff ff       	jmp    c0101e11 <__alltraps>

c0102107 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102107:	6a 00                	push   $0x0
  pushl $82
c0102109:	6a 52                	push   $0x52
  jmp __alltraps
c010210b:	e9 01 fd ff ff       	jmp    c0101e11 <__alltraps>

c0102110 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102110:	6a 00                	push   $0x0
  pushl $83
c0102112:	6a 53                	push   $0x53
  jmp __alltraps
c0102114:	e9 f8 fc ff ff       	jmp    c0101e11 <__alltraps>

c0102119 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102119:	6a 00                	push   $0x0
  pushl $84
c010211b:	6a 54                	push   $0x54
  jmp __alltraps
c010211d:	e9 ef fc ff ff       	jmp    c0101e11 <__alltraps>

c0102122 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102122:	6a 00                	push   $0x0
  pushl $85
c0102124:	6a 55                	push   $0x55
  jmp __alltraps
c0102126:	e9 e6 fc ff ff       	jmp    c0101e11 <__alltraps>

c010212b <vector86>:
.globl vector86
vector86:
  pushl $0
c010212b:	6a 00                	push   $0x0
  pushl $86
c010212d:	6a 56                	push   $0x56
  jmp __alltraps
c010212f:	e9 dd fc ff ff       	jmp    c0101e11 <__alltraps>

c0102134 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102134:	6a 00                	push   $0x0
  pushl $87
c0102136:	6a 57                	push   $0x57
  jmp __alltraps
c0102138:	e9 d4 fc ff ff       	jmp    c0101e11 <__alltraps>

c010213d <vector88>:
.globl vector88
vector88:
  pushl $0
c010213d:	6a 00                	push   $0x0
  pushl $88
c010213f:	6a 58                	push   $0x58
  jmp __alltraps
c0102141:	e9 cb fc ff ff       	jmp    c0101e11 <__alltraps>

c0102146 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102146:	6a 00                	push   $0x0
  pushl $89
c0102148:	6a 59                	push   $0x59
  jmp __alltraps
c010214a:	e9 c2 fc ff ff       	jmp    c0101e11 <__alltraps>

c010214f <vector90>:
.globl vector90
vector90:
  pushl $0
c010214f:	6a 00                	push   $0x0
  pushl $90
c0102151:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102153:	e9 b9 fc ff ff       	jmp    c0101e11 <__alltraps>

c0102158 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102158:	6a 00                	push   $0x0
  pushl $91
c010215a:	6a 5b                	push   $0x5b
  jmp __alltraps
c010215c:	e9 b0 fc ff ff       	jmp    c0101e11 <__alltraps>

c0102161 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102161:	6a 00                	push   $0x0
  pushl $92
c0102163:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102165:	e9 a7 fc ff ff       	jmp    c0101e11 <__alltraps>

c010216a <vector93>:
.globl vector93
vector93:
  pushl $0
c010216a:	6a 00                	push   $0x0
  pushl $93
c010216c:	6a 5d                	push   $0x5d
  jmp __alltraps
c010216e:	e9 9e fc ff ff       	jmp    c0101e11 <__alltraps>

c0102173 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102173:	6a 00                	push   $0x0
  pushl $94
c0102175:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102177:	e9 95 fc ff ff       	jmp    c0101e11 <__alltraps>

c010217c <vector95>:
.globl vector95
vector95:
  pushl $0
c010217c:	6a 00                	push   $0x0
  pushl $95
c010217e:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102180:	e9 8c fc ff ff       	jmp    c0101e11 <__alltraps>

c0102185 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102185:	6a 00                	push   $0x0
  pushl $96
c0102187:	6a 60                	push   $0x60
  jmp __alltraps
c0102189:	e9 83 fc ff ff       	jmp    c0101e11 <__alltraps>

c010218e <vector97>:
.globl vector97
vector97:
  pushl $0
c010218e:	6a 00                	push   $0x0
  pushl $97
c0102190:	6a 61                	push   $0x61
  jmp __alltraps
c0102192:	e9 7a fc ff ff       	jmp    c0101e11 <__alltraps>

c0102197 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102197:	6a 00                	push   $0x0
  pushl $98
c0102199:	6a 62                	push   $0x62
  jmp __alltraps
c010219b:	e9 71 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021a0 <vector99>:
.globl vector99
vector99:
  pushl $0
c01021a0:	6a 00                	push   $0x0
  pushl $99
c01021a2:	6a 63                	push   $0x63
  jmp __alltraps
c01021a4:	e9 68 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021a9 <vector100>:
.globl vector100
vector100:
  pushl $0
c01021a9:	6a 00                	push   $0x0
  pushl $100
c01021ab:	6a 64                	push   $0x64
  jmp __alltraps
c01021ad:	e9 5f fc ff ff       	jmp    c0101e11 <__alltraps>

c01021b2 <vector101>:
.globl vector101
vector101:
  pushl $0
c01021b2:	6a 00                	push   $0x0
  pushl $101
c01021b4:	6a 65                	push   $0x65
  jmp __alltraps
c01021b6:	e9 56 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021bb <vector102>:
.globl vector102
vector102:
  pushl $0
c01021bb:	6a 00                	push   $0x0
  pushl $102
c01021bd:	6a 66                	push   $0x66
  jmp __alltraps
c01021bf:	e9 4d fc ff ff       	jmp    c0101e11 <__alltraps>

c01021c4 <vector103>:
.globl vector103
vector103:
  pushl $0
c01021c4:	6a 00                	push   $0x0
  pushl $103
c01021c6:	6a 67                	push   $0x67
  jmp __alltraps
c01021c8:	e9 44 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021cd <vector104>:
.globl vector104
vector104:
  pushl $0
c01021cd:	6a 00                	push   $0x0
  pushl $104
c01021cf:	6a 68                	push   $0x68
  jmp __alltraps
c01021d1:	e9 3b fc ff ff       	jmp    c0101e11 <__alltraps>

c01021d6 <vector105>:
.globl vector105
vector105:
  pushl $0
c01021d6:	6a 00                	push   $0x0
  pushl $105
c01021d8:	6a 69                	push   $0x69
  jmp __alltraps
c01021da:	e9 32 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021df <vector106>:
.globl vector106
vector106:
  pushl $0
c01021df:	6a 00                	push   $0x0
  pushl $106
c01021e1:	6a 6a                	push   $0x6a
  jmp __alltraps
c01021e3:	e9 29 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021e8 <vector107>:
.globl vector107
vector107:
  pushl $0
c01021e8:	6a 00                	push   $0x0
  pushl $107
c01021ea:	6a 6b                	push   $0x6b
  jmp __alltraps
c01021ec:	e9 20 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021f1 <vector108>:
.globl vector108
vector108:
  pushl $0
c01021f1:	6a 00                	push   $0x0
  pushl $108
c01021f3:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021f5:	e9 17 fc ff ff       	jmp    c0101e11 <__alltraps>

c01021fa <vector109>:
.globl vector109
vector109:
  pushl $0
c01021fa:	6a 00                	push   $0x0
  pushl $109
c01021fc:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021fe:	e9 0e fc ff ff       	jmp    c0101e11 <__alltraps>

c0102203 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102203:	6a 00                	push   $0x0
  pushl $110
c0102205:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102207:	e9 05 fc ff ff       	jmp    c0101e11 <__alltraps>

c010220c <vector111>:
.globl vector111
vector111:
  pushl $0
c010220c:	6a 00                	push   $0x0
  pushl $111
c010220e:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102210:	e9 fc fb ff ff       	jmp    c0101e11 <__alltraps>

c0102215 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102215:	6a 00                	push   $0x0
  pushl $112
c0102217:	6a 70                	push   $0x70
  jmp __alltraps
c0102219:	e9 f3 fb ff ff       	jmp    c0101e11 <__alltraps>

c010221e <vector113>:
.globl vector113
vector113:
  pushl $0
c010221e:	6a 00                	push   $0x0
  pushl $113
c0102220:	6a 71                	push   $0x71
  jmp __alltraps
c0102222:	e9 ea fb ff ff       	jmp    c0101e11 <__alltraps>

c0102227 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102227:	6a 00                	push   $0x0
  pushl $114
c0102229:	6a 72                	push   $0x72
  jmp __alltraps
c010222b:	e9 e1 fb ff ff       	jmp    c0101e11 <__alltraps>

c0102230 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102230:	6a 00                	push   $0x0
  pushl $115
c0102232:	6a 73                	push   $0x73
  jmp __alltraps
c0102234:	e9 d8 fb ff ff       	jmp    c0101e11 <__alltraps>

c0102239 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $116
c010223b:	6a 74                	push   $0x74
  jmp __alltraps
c010223d:	e9 cf fb ff ff       	jmp    c0101e11 <__alltraps>

c0102242 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102242:	6a 00                	push   $0x0
  pushl $117
c0102244:	6a 75                	push   $0x75
  jmp __alltraps
c0102246:	e9 c6 fb ff ff       	jmp    c0101e11 <__alltraps>

c010224b <vector118>:
.globl vector118
vector118:
  pushl $0
c010224b:	6a 00                	push   $0x0
  pushl $118
c010224d:	6a 76                	push   $0x76
  jmp __alltraps
c010224f:	e9 bd fb ff ff       	jmp    c0101e11 <__alltraps>

c0102254 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102254:	6a 00                	push   $0x0
  pushl $119
c0102256:	6a 77                	push   $0x77
  jmp __alltraps
c0102258:	e9 b4 fb ff ff       	jmp    c0101e11 <__alltraps>

c010225d <vector120>:
.globl vector120
vector120:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $120
c010225f:	6a 78                	push   $0x78
  jmp __alltraps
c0102261:	e9 ab fb ff ff       	jmp    c0101e11 <__alltraps>

c0102266 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102266:	6a 00                	push   $0x0
  pushl $121
c0102268:	6a 79                	push   $0x79
  jmp __alltraps
c010226a:	e9 a2 fb ff ff       	jmp    c0101e11 <__alltraps>

c010226f <vector122>:
.globl vector122
vector122:
  pushl $0
c010226f:	6a 00                	push   $0x0
  pushl $122
c0102271:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102273:	e9 99 fb ff ff       	jmp    c0101e11 <__alltraps>

c0102278 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102278:	6a 00                	push   $0x0
  pushl $123
c010227a:	6a 7b                	push   $0x7b
  jmp __alltraps
c010227c:	e9 90 fb ff ff       	jmp    c0101e11 <__alltraps>

c0102281 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102281:	6a 00                	push   $0x0
  pushl $124
c0102283:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102285:	e9 87 fb ff ff       	jmp    c0101e11 <__alltraps>

c010228a <vector125>:
.globl vector125
vector125:
  pushl $0
c010228a:	6a 00                	push   $0x0
  pushl $125
c010228c:	6a 7d                	push   $0x7d
  jmp __alltraps
c010228e:	e9 7e fb ff ff       	jmp    c0101e11 <__alltraps>

c0102293 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102293:	6a 00                	push   $0x0
  pushl $126
c0102295:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102297:	e9 75 fb ff ff       	jmp    c0101e11 <__alltraps>

c010229c <vector127>:
.globl vector127
vector127:
  pushl $0
c010229c:	6a 00                	push   $0x0
  pushl $127
c010229e:	6a 7f                	push   $0x7f
  jmp __alltraps
c01022a0:	e9 6c fb ff ff       	jmp    c0101e11 <__alltraps>

c01022a5 <vector128>:
.globl vector128
vector128:
  pushl $0
c01022a5:	6a 00                	push   $0x0
  pushl $128
c01022a7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01022ac:	e9 60 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022b1 <vector129>:
.globl vector129
vector129:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $129
c01022b3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01022b8:	e9 54 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022bd <vector130>:
.globl vector130
vector130:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $130
c01022bf:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01022c4:	e9 48 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022c9 <vector131>:
.globl vector131
vector131:
  pushl $0
c01022c9:	6a 00                	push   $0x0
  pushl $131
c01022cb:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01022d0:	e9 3c fb ff ff       	jmp    c0101e11 <__alltraps>

c01022d5 <vector132>:
.globl vector132
vector132:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $132
c01022d7:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01022dc:	e9 30 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022e1 <vector133>:
.globl vector133
vector133:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $133
c01022e3:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01022e8:	e9 24 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022ed <vector134>:
.globl vector134
vector134:
  pushl $0
c01022ed:	6a 00                	push   $0x0
  pushl $134
c01022ef:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022f4:	e9 18 fb ff ff       	jmp    c0101e11 <__alltraps>

c01022f9 <vector135>:
.globl vector135
vector135:
  pushl $0
c01022f9:	6a 00                	push   $0x0
  pushl $135
c01022fb:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102300:	e9 0c fb ff ff       	jmp    c0101e11 <__alltraps>

c0102305 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $136
c0102307:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010230c:	e9 00 fb ff ff       	jmp    c0101e11 <__alltraps>

c0102311 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102311:	6a 00                	push   $0x0
  pushl $137
c0102313:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102318:	e9 f4 fa ff ff       	jmp    c0101e11 <__alltraps>

c010231d <vector138>:
.globl vector138
vector138:
  pushl $0
c010231d:	6a 00                	push   $0x0
  pushl $138
c010231f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102324:	e9 e8 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102329 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $139
c010232b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102330:	e9 dc fa ff ff       	jmp    c0101e11 <__alltraps>

c0102335 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102335:	6a 00                	push   $0x0
  pushl $140
c0102337:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010233c:	e9 d0 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102341 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102341:	6a 00                	push   $0x0
  pushl $141
c0102343:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102348:	e9 c4 fa ff ff       	jmp    c0101e11 <__alltraps>

c010234d <vector142>:
.globl vector142
vector142:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $142
c010234f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102354:	e9 b8 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102359 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102359:	6a 00                	push   $0x0
  pushl $143
c010235b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102360:	e9 ac fa ff ff       	jmp    c0101e11 <__alltraps>

c0102365 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102365:	6a 00                	push   $0x0
  pushl $144
c0102367:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010236c:	e9 a0 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102371 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $145
c0102373:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102378:	e9 94 fa ff ff       	jmp    c0101e11 <__alltraps>

c010237d <vector146>:
.globl vector146
vector146:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $146
c010237f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102384:	e9 88 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102389 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102389:	6a 00                	push   $0x0
  pushl $147
c010238b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102390:	e9 7c fa ff ff       	jmp    c0101e11 <__alltraps>

c0102395 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $148
c0102397:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010239c:	e9 70 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023a1 <vector149>:
.globl vector149
vector149:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $149
c01023a3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01023a8:	e9 64 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023ad <vector150>:
.globl vector150
vector150:
  pushl $0
c01023ad:	6a 00                	push   $0x0
  pushl $150
c01023af:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01023b4:	e9 58 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023b9 <vector151>:
.globl vector151
vector151:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $151
c01023bb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01023c0:	e9 4c fa ff ff       	jmp    c0101e11 <__alltraps>

c01023c5 <vector152>:
.globl vector152
vector152:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $152
c01023c7:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01023cc:	e9 40 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023d1 <vector153>:
.globl vector153
vector153:
  pushl $0
c01023d1:	6a 00                	push   $0x0
  pushl $153
c01023d3:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01023d8:	e9 34 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023dd <vector154>:
.globl vector154
vector154:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $154
c01023df:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01023e4:	e9 28 fa ff ff       	jmp    c0101e11 <__alltraps>

c01023e9 <vector155>:
.globl vector155
vector155:
  pushl $0
c01023e9:	6a 00                	push   $0x0
  pushl $155
c01023eb:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023f0:	e9 1c fa ff ff       	jmp    c0101e11 <__alltraps>

c01023f5 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023f5:	6a 00                	push   $0x0
  pushl $156
c01023f7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023fc:	e9 10 fa ff ff       	jmp    c0101e11 <__alltraps>

c0102401 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $157
c0102403:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102408:	e9 04 fa ff ff       	jmp    c0101e11 <__alltraps>

c010240d <vector158>:
.globl vector158
vector158:
  pushl $0
c010240d:	6a 00                	push   $0x0
  pushl $158
c010240f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102414:	e9 f8 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102419 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102419:	6a 00                	push   $0x0
  pushl $159
c010241b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102420:	e9 ec f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102425 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102425:	6a 00                	push   $0x0
  pushl $160
c0102427:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010242c:	e9 e0 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102431 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102431:	6a 00                	push   $0x0
  pushl $161
c0102433:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102438:	e9 d4 f9 ff ff       	jmp    c0101e11 <__alltraps>

c010243d <vector162>:
.globl vector162
vector162:
  pushl $0
c010243d:	6a 00                	push   $0x0
  pushl $162
c010243f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102444:	e9 c8 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102449 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102449:	6a 00                	push   $0x0
  pushl $163
c010244b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102450:	e9 bc f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102455 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102455:	6a 00                	push   $0x0
  pushl $164
c0102457:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010245c:	e9 b0 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102461 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102461:	6a 00                	push   $0x0
  pushl $165
c0102463:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102468:	e9 a4 f9 ff ff       	jmp    c0101e11 <__alltraps>

c010246d <vector166>:
.globl vector166
vector166:
  pushl $0
c010246d:	6a 00                	push   $0x0
  pushl $166
c010246f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102474:	e9 98 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102479 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102479:	6a 00                	push   $0x0
  pushl $167
c010247b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102480:	e9 8c f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102485 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102485:	6a 00                	push   $0x0
  pushl $168
c0102487:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010248c:	e9 80 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102491 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102491:	6a 00                	push   $0x0
  pushl $169
c0102493:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102498:	e9 74 f9 ff ff       	jmp    c0101e11 <__alltraps>

c010249d <vector170>:
.globl vector170
vector170:
  pushl $0
c010249d:	6a 00                	push   $0x0
  pushl $170
c010249f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01024a4:	e9 68 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024a9 <vector171>:
.globl vector171
vector171:
  pushl $0
c01024a9:	6a 00                	push   $0x0
  pushl $171
c01024ab:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01024b0:	e9 5c f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024b5 <vector172>:
.globl vector172
vector172:
  pushl $0
c01024b5:	6a 00                	push   $0x0
  pushl $172
c01024b7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01024bc:	e9 50 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024c1 <vector173>:
.globl vector173
vector173:
  pushl $0
c01024c1:	6a 00                	push   $0x0
  pushl $173
c01024c3:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01024c8:	e9 44 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024cd <vector174>:
.globl vector174
vector174:
  pushl $0
c01024cd:	6a 00                	push   $0x0
  pushl $174
c01024cf:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01024d4:	e9 38 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024d9 <vector175>:
.globl vector175
vector175:
  pushl $0
c01024d9:	6a 00                	push   $0x0
  pushl $175
c01024db:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01024e0:	e9 2c f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024e5 <vector176>:
.globl vector176
vector176:
  pushl $0
c01024e5:	6a 00                	push   $0x0
  pushl $176
c01024e7:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01024ec:	e9 20 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024f1 <vector177>:
.globl vector177
vector177:
  pushl $0
c01024f1:	6a 00                	push   $0x0
  pushl $177
c01024f3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024f8:	e9 14 f9 ff ff       	jmp    c0101e11 <__alltraps>

c01024fd <vector178>:
.globl vector178
vector178:
  pushl $0
c01024fd:	6a 00                	push   $0x0
  pushl $178
c01024ff:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102504:	e9 08 f9 ff ff       	jmp    c0101e11 <__alltraps>

c0102509 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102509:	6a 00                	push   $0x0
  pushl $179
c010250b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102510:	e9 fc f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102515 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102515:	6a 00                	push   $0x0
  pushl $180
c0102517:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010251c:	e9 f0 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102521 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102521:	6a 00                	push   $0x0
  pushl $181
c0102523:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102528:	e9 e4 f8 ff ff       	jmp    c0101e11 <__alltraps>

c010252d <vector182>:
.globl vector182
vector182:
  pushl $0
c010252d:	6a 00                	push   $0x0
  pushl $182
c010252f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102534:	e9 d8 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102539 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102539:	6a 00                	push   $0x0
  pushl $183
c010253b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102540:	e9 cc f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102545 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102545:	6a 00                	push   $0x0
  pushl $184
c0102547:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010254c:	e9 c0 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102551 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102551:	6a 00                	push   $0x0
  pushl $185
c0102553:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102558:	e9 b4 f8 ff ff       	jmp    c0101e11 <__alltraps>

c010255d <vector186>:
.globl vector186
vector186:
  pushl $0
c010255d:	6a 00                	push   $0x0
  pushl $186
c010255f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102564:	e9 a8 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102569 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102569:	6a 00                	push   $0x0
  pushl $187
c010256b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102570:	e9 9c f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102575 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102575:	6a 00                	push   $0x0
  pushl $188
c0102577:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010257c:	e9 90 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102581 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102581:	6a 00                	push   $0x0
  pushl $189
c0102583:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102588:	e9 84 f8 ff ff       	jmp    c0101e11 <__alltraps>

c010258d <vector190>:
.globl vector190
vector190:
  pushl $0
c010258d:	6a 00                	push   $0x0
  pushl $190
c010258f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102594:	e9 78 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102599 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102599:	6a 00                	push   $0x0
  pushl $191
c010259b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01025a0:	e9 6c f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025a5 <vector192>:
.globl vector192
vector192:
  pushl $0
c01025a5:	6a 00                	push   $0x0
  pushl $192
c01025a7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01025ac:	e9 60 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025b1 <vector193>:
.globl vector193
vector193:
  pushl $0
c01025b1:	6a 00                	push   $0x0
  pushl $193
c01025b3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01025b8:	e9 54 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025bd <vector194>:
.globl vector194
vector194:
  pushl $0
c01025bd:	6a 00                	push   $0x0
  pushl $194
c01025bf:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01025c4:	e9 48 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025c9 <vector195>:
.globl vector195
vector195:
  pushl $0
c01025c9:	6a 00                	push   $0x0
  pushl $195
c01025cb:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01025d0:	e9 3c f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025d5 <vector196>:
.globl vector196
vector196:
  pushl $0
c01025d5:	6a 00                	push   $0x0
  pushl $196
c01025d7:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01025dc:	e9 30 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025e1 <vector197>:
.globl vector197
vector197:
  pushl $0
c01025e1:	6a 00                	push   $0x0
  pushl $197
c01025e3:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01025e8:	e9 24 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025ed <vector198>:
.globl vector198
vector198:
  pushl $0
c01025ed:	6a 00                	push   $0x0
  pushl $198
c01025ef:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025f4:	e9 18 f8 ff ff       	jmp    c0101e11 <__alltraps>

c01025f9 <vector199>:
.globl vector199
vector199:
  pushl $0
c01025f9:	6a 00                	push   $0x0
  pushl $199
c01025fb:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102600:	e9 0c f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102605 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102605:	6a 00                	push   $0x0
  pushl $200
c0102607:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010260c:	e9 00 f8 ff ff       	jmp    c0101e11 <__alltraps>

c0102611 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102611:	6a 00                	push   $0x0
  pushl $201
c0102613:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102618:	e9 f4 f7 ff ff       	jmp    c0101e11 <__alltraps>

c010261d <vector202>:
.globl vector202
vector202:
  pushl $0
c010261d:	6a 00                	push   $0x0
  pushl $202
c010261f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102624:	e9 e8 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102629 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102629:	6a 00                	push   $0x0
  pushl $203
c010262b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102630:	e9 dc f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102635 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102635:	6a 00                	push   $0x0
  pushl $204
c0102637:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010263c:	e9 d0 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102641 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102641:	6a 00                	push   $0x0
  pushl $205
c0102643:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102648:	e9 c4 f7 ff ff       	jmp    c0101e11 <__alltraps>

c010264d <vector206>:
.globl vector206
vector206:
  pushl $0
c010264d:	6a 00                	push   $0x0
  pushl $206
c010264f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102654:	e9 b8 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102659 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102659:	6a 00                	push   $0x0
  pushl $207
c010265b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102660:	e9 ac f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102665 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102665:	6a 00                	push   $0x0
  pushl $208
c0102667:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010266c:	e9 a0 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102671 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $209
c0102673:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102678:	e9 94 f7 ff ff       	jmp    c0101e11 <__alltraps>

c010267d <vector210>:
.globl vector210
vector210:
  pushl $0
c010267d:	6a 00                	push   $0x0
  pushl $210
c010267f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102684:	e9 88 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102689 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102689:	6a 00                	push   $0x0
  pushl $211
c010268b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102690:	e9 7c f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102695 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $212
c0102697:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010269c:	e9 70 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026a1 <vector213>:
.globl vector213
vector213:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $213
c01026a3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01026a8:	e9 64 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026ad <vector214>:
.globl vector214
vector214:
  pushl $0
c01026ad:	6a 00                	push   $0x0
  pushl $214
c01026af:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01026b4:	e9 58 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026b9 <vector215>:
.globl vector215
vector215:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $215
c01026bb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01026c0:	e9 4c f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026c5 <vector216>:
.globl vector216
vector216:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $216
c01026c7:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01026cc:	e9 40 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026d1 <vector217>:
.globl vector217
vector217:
  pushl $0
c01026d1:	6a 00                	push   $0x0
  pushl $217
c01026d3:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01026d8:	e9 34 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026dd <vector218>:
.globl vector218
vector218:
  pushl $0
c01026dd:	6a 00                	push   $0x0
  pushl $218
c01026df:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01026e4:	e9 28 f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026e9 <vector219>:
.globl vector219
vector219:
  pushl $0
c01026e9:	6a 00                	push   $0x0
  pushl $219
c01026eb:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026f0:	e9 1c f7 ff ff       	jmp    c0101e11 <__alltraps>

c01026f5 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $220
c01026f7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026fc:	e9 10 f7 ff ff       	jmp    c0101e11 <__alltraps>

c0102701 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102701:	6a 00                	push   $0x0
  pushl $221
c0102703:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102708:	e9 04 f7 ff ff       	jmp    c0101e11 <__alltraps>

c010270d <vector222>:
.globl vector222
vector222:
  pushl $0
c010270d:	6a 00                	push   $0x0
  pushl $222
c010270f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102714:	e9 f8 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102719 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $223
c010271b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102720:	e9 ec f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102725 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $224
c0102727:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010272c:	e9 e0 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102731 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $225
c0102733:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102738:	e9 d4 f6 ff ff       	jmp    c0101e11 <__alltraps>

c010273d <vector226>:
.globl vector226
vector226:
  pushl $0
c010273d:	6a 00                	push   $0x0
  pushl $226
c010273f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102744:	e9 c8 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102749 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $227
c010274b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102750:	e9 bc f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102755 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $228
c0102757:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010275c:	e9 b0 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102761 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $229
c0102763:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102768:	e9 a4 f6 ff ff       	jmp    c0101e11 <__alltraps>

c010276d <vector230>:
.globl vector230
vector230:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $230
c010276f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102774:	e9 98 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102779 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102779:	6a 00                	push   $0x0
  pushl $231
c010277b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102780:	e9 8c f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102785 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $232
c0102787:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010278c:	e9 80 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102791 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $233
c0102793:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102798:	e9 74 f6 ff ff       	jmp    c0101e11 <__alltraps>

c010279d <vector234>:
.globl vector234
vector234:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $234
c010279f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01027a4:	e9 68 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027a9 <vector235>:
.globl vector235
vector235:
  pushl $0
c01027a9:	6a 00                	push   $0x0
  pushl $235
c01027ab:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01027b0:	e9 5c f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027b5 <vector236>:
.globl vector236
vector236:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $236
c01027b7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01027bc:	e9 50 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027c1 <vector237>:
.globl vector237
vector237:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $237
c01027c3:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01027c8:	e9 44 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027cd <vector238>:
.globl vector238
vector238:
  pushl $0
c01027cd:	6a 00                	push   $0x0
  pushl $238
c01027cf:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01027d4:	e9 38 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027d9 <vector239>:
.globl vector239
vector239:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $239
c01027db:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01027e0:	e9 2c f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027e5 <vector240>:
.globl vector240
vector240:
  pushl $0
c01027e5:	6a 00                	push   $0x0
  pushl $240
c01027e7:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01027ec:	e9 20 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027f1 <vector241>:
.globl vector241
vector241:
  pushl $0
c01027f1:	6a 00                	push   $0x0
  pushl $241
c01027f3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027f8:	e9 14 f6 ff ff       	jmp    c0101e11 <__alltraps>

c01027fd <vector242>:
.globl vector242
vector242:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $242
c01027ff:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102804:	e9 08 f6 ff ff       	jmp    c0101e11 <__alltraps>

c0102809 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102809:	6a 00                	push   $0x0
  pushl $243
c010280b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102810:	e9 fc f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102815 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102815:	6a 00                	push   $0x0
  pushl $244
c0102817:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010281c:	e9 f0 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102821 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102821:	6a 00                	push   $0x0
  pushl $245
c0102823:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102828:	e9 e4 f5 ff ff       	jmp    c0101e11 <__alltraps>

c010282d <vector246>:
.globl vector246
vector246:
  pushl $0
c010282d:	6a 00                	push   $0x0
  pushl $246
c010282f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102834:	e9 d8 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102839 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102839:	6a 00                	push   $0x0
  pushl $247
c010283b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102840:	e9 cc f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102845 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102845:	6a 00                	push   $0x0
  pushl $248
c0102847:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010284c:	e9 c0 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102851 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102851:	6a 00                	push   $0x0
  pushl $249
c0102853:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102858:	e9 b4 f5 ff ff       	jmp    c0101e11 <__alltraps>

c010285d <vector250>:
.globl vector250
vector250:
  pushl $0
c010285d:	6a 00                	push   $0x0
  pushl $250
c010285f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102864:	e9 a8 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102869 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102869:	6a 00                	push   $0x0
  pushl $251
c010286b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102870:	e9 9c f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102875 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102875:	6a 00                	push   $0x0
  pushl $252
c0102877:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010287c:	e9 90 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102881 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102881:	6a 00                	push   $0x0
  pushl $253
c0102883:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102888:	e9 84 f5 ff ff       	jmp    c0101e11 <__alltraps>

c010288d <vector254>:
.globl vector254
vector254:
  pushl $0
c010288d:	6a 00                	push   $0x0
  pushl $254
c010288f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102894:	e9 78 f5 ff ff       	jmp    c0101e11 <__alltraps>

c0102899 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102899:	6a 00                	push   $0x0
  pushl $255
c010289b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01028a0:	e9 6c f5 ff ff       	jmp    c0101e11 <__alltraps>

c01028a5 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01028a5:	55                   	push   %ebp
c01028a6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01028a8:	8b 55 08             	mov    0x8(%ebp),%edx
c01028ab:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01028b0:	29 c2                	sub    %eax,%edx
c01028b2:	89 d0                	mov    %edx,%eax
c01028b4:	c1 f8 02             	sar    $0x2,%eax
c01028b7:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01028bd:	5d                   	pop    %ebp
c01028be:	c3                   	ret    

c01028bf <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01028bf:	55                   	push   %ebp
c01028c0:	89 e5                	mov    %esp,%ebp
c01028c2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01028c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01028c8:	89 04 24             	mov    %eax,(%esp)
c01028cb:	e8 d5 ff ff ff       	call   c01028a5 <page2ppn>
c01028d0:	c1 e0 0c             	shl    $0xc,%eax
}
c01028d3:	c9                   	leave  
c01028d4:	c3                   	ret    

c01028d5 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01028d5:	55                   	push   %ebp
c01028d6:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01028d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01028db:	8b 00                	mov    (%eax),%eax
}
c01028dd:	5d                   	pop    %ebp
c01028de:	c3                   	ret    

c01028df <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01028df:	55                   	push   %ebp
c01028e0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01028e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01028e8:	89 10                	mov    %edx,(%eax)
}
c01028ea:	5d                   	pop    %ebp
c01028eb:	c3                   	ret    

c01028ec <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01028ec:	55                   	push   %ebp
c01028ed:	89 e5                	mov    %esp,%ebp
c01028ef:	83 ec 10             	sub    $0x10,%esp
c01028f2:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01028f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01028ff:	89 50 04             	mov    %edx,0x4(%eax)
c0102902:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102905:	8b 50 04             	mov    0x4(%eax),%edx
c0102908:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010290b:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010290d:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0102914:	00 00 00 
}
c0102917:	c9                   	leave  
c0102918:	c3                   	ret    

c0102919 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102919:	55                   	push   %ebp
c010291a:	89 e5                	mov    %esp,%ebp
c010291c:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010291f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102923:	75 24                	jne    c0102949 <default_init_memmap+0x30>
c0102925:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c010292c:	c0 
c010292d:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102934:	c0 
c0102935:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010293c:	00 
c010293d:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102944:	e8 89 e3 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c0102949:	8b 45 08             	mov    0x8(%ebp),%eax
c010294c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010294f:	eb 7d                	jmp    c01029ce <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102951:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102954:	83 c0 04             	add    $0x4,%eax
c0102957:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010295e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102961:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102964:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102967:	0f a3 10             	bt     %edx,(%eax)
c010296a:	19 c0                	sbb    %eax,%eax
c010296c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010296f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102973:	0f 95 c0             	setne  %al
c0102976:	0f b6 c0             	movzbl %al,%eax
c0102979:	85 c0                	test   %eax,%eax
c010297b:	75 24                	jne    c01029a1 <default_init_memmap+0x88>
c010297d:	c7 44 24 0c 61 67 10 	movl   $0xc0106761,0xc(%esp)
c0102984:	c0 
c0102985:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010298c:	c0 
c010298d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102994:	00 
c0102995:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010299c:	e8 31 e3 ff ff       	call   c0100cd2 <__panic>
        p->flags = p->property = 0;
c01029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029a4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01029ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029ae:	8b 50 08             	mov    0x8(%eax),%edx
c01029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029b4:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01029b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01029be:	00 
c01029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029c2:	89 04 24             	mov    %eax,(%esp)
c01029c5:	e8 15 ff ff ff       	call   c01028df <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01029ca:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01029ce:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029d1:	89 d0                	mov    %edx,%eax
c01029d3:	c1 e0 02             	shl    $0x2,%eax
c01029d6:	01 d0                	add    %edx,%eax
c01029d8:	c1 e0 02             	shl    $0x2,%eax
c01029db:	89 c2                	mov    %eax,%edx
c01029dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e0:	01 d0                	add    %edx,%eax
c01029e2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029e5:	0f 85 66 ff ff ff    	jne    c0102951 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01029eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ee:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029f1:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01029f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f7:	83 c0 04             	add    $0x4,%eax
c01029fa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0102a01:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a04:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102a0a:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0102a0d:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102a13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a16:	01 d0                	add    %edx,%eax
c0102a18:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    list_add_before(&free_list, &(base->page_link));
c0102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a20:	83 c0 0c             	add    $0xc,%eax
c0102a23:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c0102a2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102a2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a30:	8b 00                	mov    (%eax),%eax
c0102a32:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102a35:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102a38:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102a3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102a3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102a41:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a47:	89 10                	mov    %edx,(%eax)
c0102a49:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a4c:	8b 10                	mov    (%eax),%edx
c0102a4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a51:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a57:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a60:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a63:	89 10                	mov    %edx,(%eax)
}
c0102a65:	c9                   	leave  
c0102a66:	c3                   	ret    

c0102a67 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102a67:	55                   	push   %ebp
c0102a68:	89 e5                	mov    %esp,%ebp
c0102a6a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a71:	75 24                	jne    c0102a97 <default_alloc_pages+0x30>
c0102a73:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c0102a7a:	c0 
c0102a7b:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102a82:	c0 
c0102a83:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102a8a:	00 
c0102a8b:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102a92:	e8 3b e2 ff ff       	call   c0100cd2 <__panic>
    if (n > nr_free) {
c0102a97:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102a9c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a9f:	73 0a                	jae    c0102aab <default_alloc_pages+0x44>
        return NULL;
c0102aa1:	b8 00 00 00 00       	mov    $0x0,%eax
c0102aa6:	e9 3d 01 00 00       	jmp    c0102be8 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0102aab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102ab2:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102ab9:	eb 1c                	jmp    c0102ad7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102abe:	83 e8 0c             	sub    $0xc,%eax
c0102ac1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ac7:	8b 40 08             	mov    0x8(%eax),%eax
c0102aca:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102acd:	72 08                	jb     c0102ad7 <default_alloc_pages+0x70>
            page = p;
c0102acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102ad5:	eb 18                	jmp    c0102aef <default_alloc_pages+0x88>
c0102ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102ae0:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0102ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102ae6:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102aed:	75 cc                	jne    c0102abb <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102af3:	0f 84 ec 00 00 00    	je     c0102be5 <default_alloc_pages+0x17e>
        if (page->property > n) {
c0102af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102afc:	8b 40 08             	mov    0x8(%eax),%eax
c0102aff:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b02:	0f 86 8c 00 00 00    	jbe    c0102b94 <default_alloc_pages+0x12d>
            struct Page* p = page + n;
c0102b08:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b0b:	89 d0                	mov    %edx,%eax
c0102b0d:	c1 e0 02             	shl    $0x2,%eax
c0102b10:	01 d0                	add    %edx,%eax
c0102b12:	c1 e0 02             	shl    $0x2,%eax
c0102b15:	89 c2                	mov    %eax,%edx
c0102b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b1a:	01 d0                	add    %edx,%eax
c0102b1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
			p->property = page->property - n;
c0102b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b22:	8b 40 08             	mov    0x8(%eax),%eax
c0102b25:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b28:	89 c2                	mov    %eax,%edx
c0102b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b2d:	89 50 08             	mov    %edx,0x8(%eax)
			SetPageProperty(p);
c0102b30:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b33:	83 c0 04             	add    $0x4,%eax
c0102b36:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102b3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102b40:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b43:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102b46:	0f ab 10             	bts    %edx,(%eax)
			list_add_after(&(page->page_link),&(p->page_link));
c0102b49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b4c:	83 c0 0c             	add    $0xc,%eax
c0102b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b52:	83 c2 0c             	add    $0xc,%edx
c0102b55:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102b58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b5e:	8b 40 04             	mov    0x4(%eax),%eax
c0102b61:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b64:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b6a:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102b6d:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b70:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b73:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b76:	89 10                	mov    %edx,(%eax)
c0102b78:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b7b:	8b 10                	mov    (%eax),%edx
c0102b7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b80:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b83:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b86:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b89:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b8f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b92:	89 10                	mov    %edx,(%eax)
    }
		list_del(&(page->page_link));
c0102b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b97:	83 c0 0c             	add    $0xc,%eax
c0102b9a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102b9d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102ba0:	8b 40 04             	mov    0x4(%eax),%eax
c0102ba3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102ba6:	8b 12                	mov    (%edx),%edx
c0102ba8:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102bab:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102bae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102bb1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102bb4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102bb7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102bba:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102bbd:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0102bbf:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102bc4:	2b 45 08             	sub    0x8(%ebp),%eax
c0102bc7:	a3 18 af 11 c0       	mov    %eax,0xc011af18
        ClearPageProperty(page);
c0102bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bcf:	83 c0 04             	add    $0x4,%eax
c0102bd2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102bd9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102bdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102bdf:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102be2:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102be8:	c9                   	leave  
c0102be9:	c3                   	ret    

c0102bea <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102bea:	55                   	push   %ebp
c0102beb:	89 e5                	mov    %esp,%ebp
c0102bed:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102bf3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102bf7:	75 24                	jne    c0102c1d <default_free_pages+0x33>
c0102bf9:	c7 44 24 0c 30 67 10 	movl   $0xc0106730,0xc(%esp)
c0102c00:	c0 
c0102c01:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102c08:	c0 
c0102c09:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0102c10:	00 
c0102c11:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102c18:	e8 b5 e0 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c0102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102c23:	e9 9d 00 00 00       	jmp    c0102cc5 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c2b:	83 c0 04             	add    $0x4,%eax
c0102c2e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102c35:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102c3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102c3e:	0f a3 10             	bt     %edx,(%eax)
c0102c41:	19 c0                	sbb    %eax,%eax
c0102c43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102c46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102c4a:	0f 95 c0             	setne  %al
c0102c4d:	0f b6 c0             	movzbl %al,%eax
c0102c50:	85 c0                	test   %eax,%eax
c0102c52:	75 2c                	jne    c0102c80 <default_free_pages+0x96>
c0102c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c57:	83 c0 04             	add    $0x4,%eax
c0102c5a:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102c61:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c67:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102c6a:	0f a3 10             	bt     %edx,(%eax)
c0102c6d:	19 c0                	sbb    %eax,%eax
c0102c6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102c72:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102c76:	0f 95 c0             	setne  %al
c0102c79:	0f b6 c0             	movzbl %al,%eax
c0102c7c:	85 c0                	test   %eax,%eax
c0102c7e:	74 24                	je     c0102ca4 <default_free_pages+0xba>
c0102c80:	c7 44 24 0c 74 67 10 	movl   $0xc0106774,0xc(%esp)
c0102c87:	c0 
c0102c88:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102c8f:	c0 
c0102c90:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0102c97:	00 
c0102c98:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102c9f:	e8 2e e0 ff ff       	call   c0100cd2 <__panic>
        p->flags = 0;
c0102ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ca7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102cae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102cb5:	00 
c0102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cb9:	89 04 24             	mov    %eax,(%esp)
c0102cbc:	e8 1e fc ff ff       	call   c01028df <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102cc1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cc8:	89 d0                	mov    %edx,%eax
c0102cca:	c1 e0 02             	shl    $0x2,%eax
c0102ccd:	01 d0                	add    %edx,%eax
c0102ccf:	c1 e0 02             	shl    $0x2,%eax
c0102cd2:	89 c2                	mov    %eax,%edx
c0102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cd7:	01 d0                	add    %edx,%eax
c0102cd9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102cdc:	0f 85 46 ff ff ff    	jne    c0102c28 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ce8:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cee:	83 c0 04             	add    $0x4,%eax
c0102cf1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102cf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cfb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cfe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102d01:	0f ab 10             	bts    %edx,(%eax)
c0102d04:	c7 45 cc 10 af 11 c0 	movl   $0xc011af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102d0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102d0e:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102d14:	e9 08 01 00 00       	jmp    c0102e21 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0102d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d1c:	83 e8 0c             	sub    $0xc,%eax
c0102d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d25:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102d28:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102d2b:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102d2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0102d31:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d34:	8b 50 08             	mov    0x8(%eax),%edx
c0102d37:	89 d0                	mov    %edx,%eax
c0102d39:	c1 e0 02             	shl    $0x2,%eax
c0102d3c:	01 d0                	add    %edx,%eax
c0102d3e:	c1 e0 02             	shl    $0x2,%eax
c0102d41:	89 c2                	mov    %eax,%edx
c0102d43:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d46:	01 d0                	add    %edx,%eax
c0102d48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102d4b:	75 5a                	jne    c0102da7 <default_free_pages+0x1bd>
            base->property += p->property;
c0102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d50:	8b 50 08             	mov    0x8(%eax),%edx
c0102d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d56:	8b 40 08             	mov    0x8(%eax),%eax
c0102d59:	01 c2                	add    %eax,%edx
c0102d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d5e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d64:	83 c0 04             	add    $0x4,%eax
c0102d67:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102d6e:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d71:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d74:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d77:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d7d:	83 c0 0c             	add    $0xc,%eax
c0102d80:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d83:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d86:	8b 40 04             	mov    0x4(%eax),%eax
c0102d89:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d8c:	8b 12                	mov    (%edx),%edx
c0102d8e:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102d91:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102d94:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d9a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102d9d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102da0:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102da3:	89 10                	mov    %edx,(%eax)
c0102da5:	eb 7a                	jmp    c0102e21 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102daa:	8b 50 08             	mov    0x8(%eax),%edx
c0102dad:	89 d0                	mov    %edx,%eax
c0102daf:	c1 e0 02             	shl    $0x2,%eax
c0102db2:	01 d0                	add    %edx,%eax
c0102db4:	c1 e0 02             	shl    $0x2,%eax
c0102db7:	89 c2                	mov    %eax,%edx
c0102db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbc:	01 d0                	add    %edx,%eax
c0102dbe:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102dc1:	75 5e                	jne    c0102e21 <default_free_pages+0x237>
            p->property += base->property;
c0102dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dc6:	8b 50 08             	mov    0x8(%eax),%edx
c0102dc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dcc:	8b 40 08             	mov    0x8(%eax),%eax
c0102dcf:	01 c2                	add    %eax,%edx
c0102dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dd4:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dda:	83 c0 04             	add    $0x4,%eax
c0102ddd:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102de4:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102de7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102dea:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102ded:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102df3:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102df9:	83 c0 0c             	add    $0xc,%eax
c0102dfc:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102dff:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102e02:	8b 40 04             	mov    0x4(%eax),%eax
c0102e05:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102e08:	8b 12                	mov    (%edx),%edx
c0102e0a:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102e0d:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102e10:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e13:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102e16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102e19:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102e1c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102e1f:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102e21:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102e28:	0f 85 eb fe ff ff    	jne    c0102d19 <default_free_pages+0x12f>
c0102e2e:	c7 45 9c 10 af 11 c0 	movl   $0xc011af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102e35:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102e38:	8b 40 04             	mov    0x4(%eax),%eax
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
	le = list_next(&free_list);
c0102e3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(le != &free_list)
c0102e3e:	eb 73                	jmp    c0102eb3 <default_free_pages+0x2c9>
	{
		p = le2page(le,page_link);
c0102e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e43:	83 e8 0c             	sub    $0xc,%eax
c0102e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(base + base->property <= p)
c0102e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e4c:	8b 50 08             	mov    0x8(%eax),%edx
c0102e4f:	89 d0                	mov    %edx,%eax
c0102e51:	c1 e0 02             	shl    $0x2,%eax
c0102e54:	01 d0                	add    %edx,%eax
c0102e56:	c1 e0 02             	shl    $0x2,%eax
c0102e59:	89 c2                	mov    %eax,%edx
c0102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e5e:	01 d0                	add    %edx,%eax
c0102e60:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e63:	77 3f                	ja     c0102ea4 <default_free_pages+0x2ba>
		{
			assert(base + n < p);
c0102e65:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e68:	89 d0                	mov    %edx,%eax
c0102e6a:	c1 e0 02             	shl    $0x2,%eax
c0102e6d:	01 d0                	add    %edx,%eax
c0102e6f:	c1 e0 02             	shl    $0x2,%eax
c0102e72:	89 c2                	mov    %eax,%edx
c0102e74:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e77:	01 d0                	add    %edx,%eax
c0102e79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e7c:	72 24                	jb     c0102ea2 <default_free_pages+0x2b8>
c0102e7e:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c0102e85:	c0 
c0102e86:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102e8d:	c0 
c0102e8e:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0102e95:	00 
c0102e96:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102e9d:	e8 30 de ff ff       	call   c0100cd2 <__panic>
			break;
c0102ea2:	eb 18                	jmp    c0102ebc <default_free_pages+0x2d2>
c0102ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ea7:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102eaa:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102ead:	8b 40 04             	mov    0x4(%eax),%eax
		}
		le = list_next(le);
c0102eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
            base = p;
            list_del(&(p->page_link));
        }
    }
	le = list_next(&free_list);
	while(le != &free_list)
c0102eb3:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102eba:	75 84                	jne    c0102e40 <default_free_pages+0x256>
			assert(base + n < p);
			break;
		}
		le = list_next(le);
	}
    nr_free += n;
c0102ebc:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ec5:	01 d0                	add    %edx,%eax
c0102ec7:	a3 18 af 11 c0       	mov    %eax,0xc011af18
	list_add_before(le,&(base->page_link));
c0102ecc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ecf:	8d 50 0c             	lea    0xc(%eax),%edx
c0102ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ed5:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102ed8:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102edb:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102ede:	8b 00                	mov    (%eax),%eax
c0102ee0:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102ee3:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102ee6:	89 45 88             	mov    %eax,-0x78(%ebp)
c0102ee9:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102eec:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102eef:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102ef2:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102ef5:	89 10                	mov    %edx,(%eax)
c0102ef7:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102efa:	8b 10                	mov    (%eax),%edx
c0102efc:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102eff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102f02:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f05:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102f08:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102f0b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102f0e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102f11:	89 10                	mov    %edx,(%eax)
}
c0102f13:	c9                   	leave  
c0102f14:	c3                   	ret    

c0102f15 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102f15:	55                   	push   %ebp
c0102f16:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102f18:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102f1d:	5d                   	pop    %ebp
c0102f1e:	c3                   	ret    

c0102f1f <basic_check>:

static void
basic_check(void) {
c0102f1f:	55                   	push   %ebp
c0102f20:	89 e5                	mov    %esp,%ebp
c0102f22:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102f25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102f38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f3f:	e8 db 0e 00 00       	call   c0103e1f <alloc_pages>
c0102f44:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102f47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102f4b:	75 24                	jne    c0102f71 <basic_check+0x52>
c0102f4d:	c7 44 24 0c a6 67 10 	movl   $0xc01067a6,0xc(%esp)
c0102f54:	c0 
c0102f55:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102f5c:	c0 
c0102f5d:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0102f64:	00 
c0102f65:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102f6c:	e8 61 dd ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102f71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f78:	e8 a2 0e 00 00       	call   c0103e1f <alloc_pages>
c0102f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f84:	75 24                	jne    c0102faa <basic_check+0x8b>
c0102f86:	c7 44 24 0c c2 67 10 	movl   $0xc01067c2,0xc(%esp)
c0102f8d:	c0 
c0102f8e:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102f95:	c0 
c0102f96:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0102f9d:	00 
c0102f9e:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102fa5:	e8 28 dd ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102faa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102fb1:	e8 69 0e 00 00       	call   c0103e1f <alloc_pages>
c0102fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102fb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102fbd:	75 24                	jne    c0102fe3 <basic_check+0xc4>
c0102fbf:	c7 44 24 0c de 67 10 	movl   $0xc01067de,0xc(%esp)
c0102fc6:	c0 
c0102fc7:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0102fce:	c0 
c0102fcf:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0102fd6:	00 
c0102fd7:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0102fde:	e8 ef dc ff ff       	call   c0100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fe6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102fe9:	74 10                	je     c0102ffb <basic_check+0xdc>
c0102feb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ff1:	74 08                	je     c0102ffb <basic_check+0xdc>
c0102ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ff6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ff9:	75 24                	jne    c010301f <basic_check+0x100>
c0102ffb:	c7 44 24 0c fc 67 10 	movl   $0xc01067fc,0xc(%esp)
c0103002:	c0 
c0103003:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010300a:	c0 
c010300b:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103012:	00 
c0103013:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010301a:	e8 b3 dc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010301f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103022:	89 04 24             	mov    %eax,(%esp)
c0103025:	e8 ab f8 ff ff       	call   c01028d5 <page_ref>
c010302a:	85 c0                	test   %eax,%eax
c010302c:	75 1e                	jne    c010304c <basic_check+0x12d>
c010302e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103031:	89 04 24             	mov    %eax,(%esp)
c0103034:	e8 9c f8 ff ff       	call   c01028d5 <page_ref>
c0103039:	85 c0                	test   %eax,%eax
c010303b:	75 0f                	jne    c010304c <basic_check+0x12d>
c010303d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103040:	89 04 24             	mov    %eax,(%esp)
c0103043:	e8 8d f8 ff ff       	call   c01028d5 <page_ref>
c0103048:	85 c0                	test   %eax,%eax
c010304a:	74 24                	je     c0103070 <basic_check+0x151>
c010304c:	c7 44 24 0c 20 68 10 	movl   $0xc0106820,0xc(%esp)
c0103053:	c0 
c0103054:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010305b:	c0 
c010305c:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0103063:	00 
c0103064:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010306b:	e8 62 dc ff ff       	call   c0100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103070:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103073:	89 04 24             	mov    %eax,(%esp)
c0103076:	e8 44 f8 ff ff       	call   c01028bf <page2pa>
c010307b:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103081:	c1 e2 0c             	shl    $0xc,%edx
c0103084:	39 d0                	cmp    %edx,%eax
c0103086:	72 24                	jb     c01030ac <basic_check+0x18d>
c0103088:	c7 44 24 0c 5c 68 10 	movl   $0xc010685c,0xc(%esp)
c010308f:	c0 
c0103090:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103097:	c0 
c0103098:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010309f:	00 
c01030a0:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01030a7:	e8 26 dc ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01030ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030af:	89 04 24             	mov    %eax,(%esp)
c01030b2:	e8 08 f8 ff ff       	call   c01028bf <page2pa>
c01030b7:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01030bd:	c1 e2 0c             	shl    $0xc,%edx
c01030c0:	39 d0                	cmp    %edx,%eax
c01030c2:	72 24                	jb     c01030e8 <basic_check+0x1c9>
c01030c4:	c7 44 24 0c 79 68 10 	movl   $0xc0106879,0xc(%esp)
c01030cb:	c0 
c01030cc:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01030d3:	c0 
c01030d4:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01030db:	00 
c01030dc:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01030e3:	e8 ea db ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01030e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030eb:	89 04 24             	mov    %eax,(%esp)
c01030ee:	e8 cc f7 ff ff       	call   c01028bf <page2pa>
c01030f3:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01030f9:	c1 e2 0c             	shl    $0xc,%edx
c01030fc:	39 d0                	cmp    %edx,%eax
c01030fe:	72 24                	jb     c0103124 <basic_check+0x205>
c0103100:	c7 44 24 0c 96 68 10 	movl   $0xc0106896,0xc(%esp)
c0103107:	c0 
c0103108:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010310f:	c0 
c0103110:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103117:	00 
c0103118:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010311f:	e8 ae db ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c0103124:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0103129:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c010312f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103132:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103135:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010313c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010313f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103142:	89 50 04             	mov    %edx,0x4(%eax)
c0103145:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103148:	8b 50 04             	mov    0x4(%eax),%edx
c010314b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010314e:	89 10                	mov    %edx,(%eax)
c0103150:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103157:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010315a:	8b 40 04             	mov    0x4(%eax),%eax
c010315d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103160:	0f 94 c0             	sete   %al
c0103163:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103166:	85 c0                	test   %eax,%eax
c0103168:	75 24                	jne    c010318e <basic_check+0x26f>
c010316a:	c7 44 24 0c b3 68 10 	movl   $0xc01068b3,0xc(%esp)
c0103171:	c0 
c0103172:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103179:	c0 
c010317a:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103181:	00 
c0103182:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103189:	e8 44 db ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c010318e:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103193:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103196:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c010319d:	00 00 00 

    assert(alloc_page() == NULL);
c01031a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031a7:	e8 73 0c 00 00       	call   c0103e1f <alloc_pages>
c01031ac:	85 c0                	test   %eax,%eax
c01031ae:	74 24                	je     c01031d4 <basic_check+0x2b5>
c01031b0:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c01031b7:	c0 
c01031b8:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01031bf:	c0 
c01031c0:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01031c7:	00 
c01031c8:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01031cf:	e8 fe da ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c01031d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031db:	00 
c01031dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031df:	89 04 24             	mov    %eax,(%esp)
c01031e2:	e8 70 0c 00 00       	call   c0103e57 <free_pages>
    free_page(p1);
c01031e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031ee:	00 
c01031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031f2:	89 04 24             	mov    %eax,(%esp)
c01031f5:	e8 5d 0c 00 00       	call   c0103e57 <free_pages>
    free_page(p2);
c01031fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103201:	00 
c0103202:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103205:	89 04 24             	mov    %eax,(%esp)
c0103208:	e8 4a 0c 00 00       	call   c0103e57 <free_pages>
    assert(nr_free == 3);
c010320d:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103212:	83 f8 03             	cmp    $0x3,%eax
c0103215:	74 24                	je     c010323b <basic_check+0x31c>
c0103217:	c7 44 24 0c df 68 10 	movl   $0xc01068df,0xc(%esp)
c010321e:	c0 
c010321f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103226:	c0 
c0103227:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c010322e:	00 
c010322f:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103236:	e8 97 da ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010323b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103242:	e8 d8 0b 00 00       	call   c0103e1f <alloc_pages>
c0103247:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010324a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010324e:	75 24                	jne    c0103274 <basic_check+0x355>
c0103250:	c7 44 24 0c a6 67 10 	movl   $0xc01067a6,0xc(%esp)
c0103257:	c0 
c0103258:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010325f:	c0 
c0103260:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103267:	00 
c0103268:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010326f:	e8 5e da ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103274:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010327b:	e8 9f 0b 00 00       	call   c0103e1f <alloc_pages>
c0103280:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103283:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103287:	75 24                	jne    c01032ad <basic_check+0x38e>
c0103289:	c7 44 24 0c c2 67 10 	movl   $0xc01067c2,0xc(%esp)
c0103290:	c0 
c0103291:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103298:	c0 
c0103299:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01032a0:	00 
c01032a1:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01032a8:	e8 25 da ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01032ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032b4:	e8 66 0b 00 00       	call   c0103e1f <alloc_pages>
c01032b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01032bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032c0:	75 24                	jne    c01032e6 <basic_check+0x3c7>
c01032c2:	c7 44 24 0c de 67 10 	movl   $0xc01067de,0xc(%esp)
c01032c9:	c0 
c01032ca:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01032d1:	c0 
c01032d2:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c01032d9:	00 
c01032da:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01032e1:	e8 ec d9 ff ff       	call   c0100cd2 <__panic>

    assert(alloc_page() == NULL);
c01032e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032ed:	e8 2d 0b 00 00       	call   c0103e1f <alloc_pages>
c01032f2:	85 c0                	test   %eax,%eax
c01032f4:	74 24                	je     c010331a <basic_check+0x3fb>
c01032f6:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c01032fd:	c0 
c01032fe:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103305:	c0 
c0103306:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010330d:	00 
c010330e:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103315:	e8 b8 d9 ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c010331a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103321:	00 
c0103322:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103325:	89 04 24             	mov    %eax,(%esp)
c0103328:	e8 2a 0b 00 00       	call   c0103e57 <free_pages>
c010332d:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c0103334:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103337:	8b 40 04             	mov    0x4(%eax),%eax
c010333a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010333d:	0f 94 c0             	sete   %al
c0103340:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103343:	85 c0                	test   %eax,%eax
c0103345:	74 24                	je     c010336b <basic_check+0x44c>
c0103347:	c7 44 24 0c ec 68 10 	movl   $0xc01068ec,0xc(%esp)
c010334e:	c0 
c010334f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103356:	c0 
c0103357:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c010335e:	00 
c010335f:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103366:	e8 67 d9 ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c010336b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103372:	e8 a8 0a 00 00       	call   c0103e1f <alloc_pages>
c0103377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010337a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010337d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103380:	74 24                	je     c01033a6 <basic_check+0x487>
c0103382:	c7 44 24 0c 04 69 10 	movl   $0xc0106904,0xc(%esp)
c0103389:	c0 
c010338a:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103391:	c0 
c0103392:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103399:	00 
c010339a:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01033a1:	e8 2c d9 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01033a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033ad:	e8 6d 0a 00 00       	call   c0103e1f <alloc_pages>
c01033b2:	85 c0                	test   %eax,%eax
c01033b4:	74 24                	je     c01033da <basic_check+0x4bb>
c01033b6:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c01033bd:	c0 
c01033be:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01033c5:	c0 
c01033c6:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c01033cd:	00 
c01033ce:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01033d5:	e8 f8 d8 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c01033da:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01033df:	85 c0                	test   %eax,%eax
c01033e1:	74 24                	je     c0103407 <basic_check+0x4e8>
c01033e3:	c7 44 24 0c 1d 69 10 	movl   $0xc010691d,0xc(%esp)
c01033ea:	c0 
c01033eb:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01033f2:	c0 
c01033f3:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01033fa:	00 
c01033fb:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103402:	e8 cb d8 ff ff       	call   c0100cd2 <__panic>
    free_list = free_list_store;
c0103407:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010340a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010340d:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c0103412:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c0103418:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010341b:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c0103420:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103427:	00 
c0103428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010342b:	89 04 24             	mov    %eax,(%esp)
c010342e:	e8 24 0a 00 00       	call   c0103e57 <free_pages>
    free_page(p1);
c0103433:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010343a:	00 
c010343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010343e:	89 04 24             	mov    %eax,(%esp)
c0103441:	e8 11 0a 00 00       	call   c0103e57 <free_pages>
    free_page(p2);
c0103446:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010344d:	00 
c010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103451:	89 04 24             	mov    %eax,(%esp)
c0103454:	e8 fe 09 00 00       	call   c0103e57 <free_pages>
}
c0103459:	c9                   	leave  
c010345a:	c3                   	ret    

c010345b <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010345b:	55                   	push   %ebp
c010345c:	89 e5                	mov    %esp,%ebp
c010345e:	53                   	push   %ebx
c010345f:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010346c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103473:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010347a:	eb 6b                	jmp    c01034e7 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c010347c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010347f:	83 e8 0c             	sub    $0xc,%eax
c0103482:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103485:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103488:	83 c0 04             	add    $0x4,%eax
c010348b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103492:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103495:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103498:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010349b:	0f a3 10             	bt     %edx,(%eax)
c010349e:	19 c0                	sbb    %eax,%eax
c01034a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01034a3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01034a7:	0f 95 c0             	setne  %al
c01034aa:	0f b6 c0             	movzbl %al,%eax
c01034ad:	85 c0                	test   %eax,%eax
c01034af:	75 24                	jne    c01034d5 <default_check+0x7a>
c01034b1:	c7 44 24 0c 2a 69 10 	movl   $0xc010692a,0xc(%esp)
c01034b8:	c0 
c01034b9:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01034c0:	c0 
c01034c1:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01034c8:	00 
c01034c9:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01034d0:	e8 fd d7 ff ff       	call   c0100cd2 <__panic>
        count ++, total += p->property;
c01034d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01034d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034dc:	8b 50 08             	mov    0x8(%eax),%edx
c01034df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034e2:	01 d0                	add    %edx,%eax
c01034e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01034ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034f0:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01034f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01034f6:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c01034fd:	0f 85 79 ff ff ff    	jne    c010347c <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103503:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103506:	e8 7e 09 00 00       	call   c0103e89 <nr_free_pages>
c010350b:	39 c3                	cmp    %eax,%ebx
c010350d:	74 24                	je     c0103533 <default_check+0xd8>
c010350f:	c7 44 24 0c 3a 69 10 	movl   $0xc010693a,0xc(%esp)
c0103516:	c0 
c0103517:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010351e:	c0 
c010351f:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0103526:	00 
c0103527:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010352e:	e8 9f d7 ff ff       	call   c0100cd2 <__panic>

    basic_check();
c0103533:	e8 e7 f9 ff ff       	call   c0102f1f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103538:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010353f:	e8 db 08 00 00       	call   c0103e1f <alloc_pages>
c0103544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010354b:	75 24                	jne    c0103571 <default_check+0x116>
c010354d:	c7 44 24 0c 53 69 10 	movl   $0xc0106953,0xc(%esp)
c0103554:	c0 
c0103555:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010355c:	c0 
c010355d:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103564:	00 
c0103565:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010356c:	e8 61 d7 ff ff       	call   c0100cd2 <__panic>
    assert(!PageProperty(p0));
c0103571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103574:	83 c0 04             	add    $0x4,%eax
c0103577:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010357e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103581:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103584:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103587:	0f a3 10             	bt     %edx,(%eax)
c010358a:	19 c0                	sbb    %eax,%eax
c010358c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010358f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103593:	0f 95 c0             	setne  %al
c0103596:	0f b6 c0             	movzbl %al,%eax
c0103599:	85 c0                	test   %eax,%eax
c010359b:	74 24                	je     c01035c1 <default_check+0x166>
c010359d:	c7 44 24 0c 5e 69 10 	movl   $0xc010695e,0xc(%esp)
c01035a4:	c0 
c01035a5:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01035ac:	c0 
c01035ad:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01035b4:	00 
c01035b5:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01035bc:	e8 11 d7 ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c01035c1:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01035c6:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c01035cc:	89 45 80             	mov    %eax,-0x80(%ebp)
c01035cf:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01035d2:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01035d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035dc:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01035df:	89 50 04             	mov    %edx,0x4(%eax)
c01035e2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035e5:	8b 50 04             	mov    0x4(%eax),%edx
c01035e8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035eb:	89 10                	mov    %edx,(%eax)
c01035ed:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01035f4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035f7:	8b 40 04             	mov    0x4(%eax),%eax
c01035fa:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01035fd:	0f 94 c0             	sete   %al
c0103600:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103603:	85 c0                	test   %eax,%eax
c0103605:	75 24                	jne    c010362b <default_check+0x1d0>
c0103607:	c7 44 24 0c b3 68 10 	movl   $0xc01068b3,0xc(%esp)
c010360e:	c0 
c010360f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103616:	c0 
c0103617:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c010361e:	00 
c010361f:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103626:	e8 a7 d6 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010362b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103632:	e8 e8 07 00 00       	call   c0103e1f <alloc_pages>
c0103637:	85 c0                	test   %eax,%eax
c0103639:	74 24                	je     c010365f <default_check+0x204>
c010363b:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c0103642:	c0 
c0103643:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010364a:	c0 
c010364b:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103652:	00 
c0103653:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010365a:	e8 73 d6 ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c010365f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103664:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0103667:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c010366e:	00 00 00 

    free_pages(p0 + 2, 3);
c0103671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103674:	83 c0 28             	add    $0x28,%eax
c0103677:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010367e:	00 
c010367f:	89 04 24             	mov    %eax,(%esp)
c0103682:	e8 d0 07 00 00       	call   c0103e57 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103687:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010368e:	e8 8c 07 00 00       	call   c0103e1f <alloc_pages>
c0103693:	85 c0                	test   %eax,%eax
c0103695:	74 24                	je     c01036bb <default_check+0x260>
c0103697:	c7 44 24 0c 70 69 10 	movl   $0xc0106970,0xc(%esp)
c010369e:	c0 
c010369f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01036a6:	c0 
c01036a7:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01036ae:	00 
c01036af:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01036b6:	e8 17 d6 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01036bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036be:	83 c0 28             	add    $0x28,%eax
c01036c1:	83 c0 04             	add    $0x4,%eax
c01036c4:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01036cb:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01036d1:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01036d4:	0f a3 10             	bt     %edx,(%eax)
c01036d7:	19 c0                	sbb    %eax,%eax
c01036d9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01036dc:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01036e0:	0f 95 c0             	setne  %al
c01036e3:	0f b6 c0             	movzbl %al,%eax
c01036e6:	85 c0                	test   %eax,%eax
c01036e8:	74 0e                	je     c01036f8 <default_check+0x29d>
c01036ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036ed:	83 c0 28             	add    $0x28,%eax
c01036f0:	8b 40 08             	mov    0x8(%eax),%eax
c01036f3:	83 f8 03             	cmp    $0x3,%eax
c01036f6:	74 24                	je     c010371c <default_check+0x2c1>
c01036f8:	c7 44 24 0c 88 69 10 	movl   $0xc0106988,0xc(%esp)
c01036ff:	c0 
c0103700:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103707:	c0 
c0103708:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010370f:	00 
c0103710:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103717:	e8 b6 d5 ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010371c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103723:	e8 f7 06 00 00       	call   c0103e1f <alloc_pages>
c0103728:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010372b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010372f:	75 24                	jne    c0103755 <default_check+0x2fa>
c0103731:	c7 44 24 0c b4 69 10 	movl   $0xc01069b4,0xc(%esp)
c0103738:	c0 
c0103739:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103740:	c0 
c0103741:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0103748:	00 
c0103749:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103750:	e8 7d d5 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c0103755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010375c:	e8 be 06 00 00       	call   c0103e1f <alloc_pages>
c0103761:	85 c0                	test   %eax,%eax
c0103763:	74 24                	je     c0103789 <default_check+0x32e>
c0103765:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c010376c:	c0 
c010376d:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103774:	c0 
c0103775:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c010377c:	00 
c010377d:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103784:	e8 49 d5 ff ff       	call   c0100cd2 <__panic>
    assert(p0 + 2 == p1);
c0103789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010378c:	83 c0 28             	add    $0x28,%eax
c010378f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103792:	74 24                	je     c01037b8 <default_check+0x35d>
c0103794:	c7 44 24 0c d2 69 10 	movl   $0xc01069d2,0xc(%esp)
c010379b:	c0 
c010379c:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01037a3:	c0 
c01037a4:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01037ab:	00 
c01037ac:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01037b3:	e8 1a d5 ff ff       	call   c0100cd2 <__panic>

    p2 = p0 + 1;
c01037b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037bb:	83 c0 14             	add    $0x14,%eax
c01037be:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01037c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037c8:	00 
c01037c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037cc:	89 04 24             	mov    %eax,(%esp)
c01037cf:	e8 83 06 00 00       	call   c0103e57 <free_pages>
    free_pages(p1, 3);
c01037d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01037db:	00 
c01037dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037df:	89 04 24             	mov    %eax,(%esp)
c01037e2:	e8 70 06 00 00       	call   c0103e57 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01037e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037ea:	83 c0 04             	add    $0x4,%eax
c01037ed:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01037f4:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037f7:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01037fa:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01037fd:	0f a3 10             	bt     %edx,(%eax)
c0103800:	19 c0                	sbb    %eax,%eax
c0103802:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103805:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103809:	0f 95 c0             	setne  %al
c010380c:	0f b6 c0             	movzbl %al,%eax
c010380f:	85 c0                	test   %eax,%eax
c0103811:	74 0b                	je     c010381e <default_check+0x3c3>
c0103813:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103816:	8b 40 08             	mov    0x8(%eax),%eax
c0103819:	83 f8 01             	cmp    $0x1,%eax
c010381c:	74 24                	je     c0103842 <default_check+0x3e7>
c010381e:	c7 44 24 0c e0 69 10 	movl   $0xc01069e0,0xc(%esp)
c0103825:	c0 
c0103826:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c010382d:	c0 
c010382e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0103835:	00 
c0103836:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c010383d:	e8 90 d4 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103842:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103845:	83 c0 04             	add    $0x4,%eax
c0103848:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010384f:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103852:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103855:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103858:	0f a3 10             	bt     %edx,(%eax)
c010385b:	19 c0                	sbb    %eax,%eax
c010385d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103860:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103864:	0f 95 c0             	setne  %al
c0103867:	0f b6 c0             	movzbl %al,%eax
c010386a:	85 c0                	test   %eax,%eax
c010386c:	74 0b                	je     c0103879 <default_check+0x41e>
c010386e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103871:	8b 40 08             	mov    0x8(%eax),%eax
c0103874:	83 f8 03             	cmp    $0x3,%eax
c0103877:	74 24                	je     c010389d <default_check+0x442>
c0103879:	c7 44 24 0c 08 6a 10 	movl   $0xc0106a08,0xc(%esp)
c0103880:	c0 
c0103881:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103888:	c0 
c0103889:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0103890:	00 
c0103891:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103898:	e8 35 d4 ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010389d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038a4:	e8 76 05 00 00       	call   c0103e1f <alloc_pages>
c01038a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038af:	83 e8 14             	sub    $0x14,%eax
c01038b2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01038b5:	74 24                	je     c01038db <default_check+0x480>
c01038b7:	c7 44 24 0c 2e 6a 10 	movl   $0xc0106a2e,0xc(%esp)
c01038be:	c0 
c01038bf:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01038c6:	c0 
c01038c7:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c01038ce:	00 
c01038cf:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01038d6:	e8 f7 d3 ff ff       	call   c0100cd2 <__panic>
    free_page(p0);
c01038db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038e2:	00 
c01038e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038e6:	89 04 24             	mov    %eax,(%esp)
c01038e9:	e8 69 05 00 00       	call   c0103e57 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01038ee:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01038f5:	e8 25 05 00 00       	call   c0103e1f <alloc_pages>
c01038fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103900:	83 c0 14             	add    $0x14,%eax
c0103903:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103906:	74 24                	je     c010392c <default_check+0x4d1>
c0103908:	c7 44 24 0c 4c 6a 10 	movl   $0xc0106a4c,0xc(%esp)
c010390f:	c0 
c0103910:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103917:	c0 
c0103918:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c010391f:	00 
c0103920:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103927:	e8 a6 d3 ff ff       	call   c0100cd2 <__panic>

    free_pages(p0, 2);
c010392c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103933:	00 
c0103934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103937:	89 04 24             	mov    %eax,(%esp)
c010393a:	e8 18 05 00 00       	call   c0103e57 <free_pages>
    free_page(p2);
c010393f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103946:	00 
c0103947:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010394a:	89 04 24             	mov    %eax,(%esp)
c010394d:	e8 05 05 00 00       	call   c0103e57 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103952:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103959:	e8 c1 04 00 00       	call   c0103e1f <alloc_pages>
c010395e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103961:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103965:	75 24                	jne    c010398b <default_check+0x530>
c0103967:	c7 44 24 0c 6c 6a 10 	movl   $0xc0106a6c,0xc(%esp)
c010396e:	c0 
c010396f:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103976:	c0 
c0103977:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010397e:	00 
c010397f:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103986:	e8 47 d3 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010398b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103992:	e8 88 04 00 00       	call   c0103e1f <alloc_pages>
c0103997:	85 c0                	test   %eax,%eax
c0103999:	74 24                	je     c01039bf <default_check+0x564>
c010399b:	c7 44 24 0c ca 68 10 	movl   $0xc01068ca,0xc(%esp)
c01039a2:	c0 
c01039a3:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01039aa:	c0 
c01039ab:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01039b2:	00 
c01039b3:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01039ba:	e8 13 d3 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c01039bf:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01039c4:	85 c0                	test   %eax,%eax
c01039c6:	74 24                	je     c01039ec <default_check+0x591>
c01039c8:	c7 44 24 0c 1d 69 10 	movl   $0xc010691d,0xc(%esp)
c01039cf:	c0 
c01039d0:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c01039d7:	c0 
c01039d8:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01039df:	00 
c01039e0:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c01039e7:	e8 e6 d2 ff ff       	call   c0100cd2 <__panic>
    nr_free = nr_free_store;
c01039ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039ef:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c01039f4:	8b 45 80             	mov    -0x80(%ebp),%eax
c01039f7:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01039fa:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01039ff:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c0103a05:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103a0c:	00 
c0103a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a10:	89 04 24             	mov    %eax,(%esp)
c0103a13:	e8 3f 04 00 00       	call   c0103e57 <free_pages>

    le = &free_list;
c0103a18:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103a1f:	eb 5b                	jmp    c0103a7c <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
c0103a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a24:	8b 40 04             	mov    0x4(%eax),%eax
c0103a27:	8b 00                	mov    (%eax),%eax
c0103a29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103a2c:	75 0d                	jne    c0103a3b <default_check+0x5e0>
c0103a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a31:	8b 00                	mov    (%eax),%eax
c0103a33:	8b 40 04             	mov    0x4(%eax),%eax
c0103a36:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103a39:	74 24                	je     c0103a5f <default_check+0x604>
c0103a3b:	c7 44 24 0c 8c 6a 10 	movl   $0xc0106a8c,0xc(%esp)
c0103a42:	c0 
c0103a43:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103a4a:	c0 
c0103a4b:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0103a52:	00 
c0103a53:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103a5a:	e8 73 d2 ff ff       	call   c0100cd2 <__panic>
        struct Page *p = le2page(le, page_link);
c0103a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a62:	83 e8 0c             	sub    $0xc,%eax
c0103a65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0103a68:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0103a6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103a6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103a72:	8b 40 08             	mov    0x8(%eax),%eax
c0103a75:	29 c2                	sub    %eax,%edx
c0103a77:	89 d0                	mov    %edx,%eax
c0103a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a7f:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103a82:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103a85:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103a88:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a8b:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0103a92:	75 8d                	jne    c0103a21 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103a94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a98:	74 24                	je     c0103abe <default_check+0x663>
c0103a9a:	c7 44 24 0c b9 6a 10 	movl   $0xc0106ab9,0xc(%esp)
c0103aa1:	c0 
c0103aa2:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103aa9:	c0 
c0103aaa:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0103ab1:	00 
c0103ab2:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103ab9:	e8 14 d2 ff ff       	call   c0100cd2 <__panic>
    assert(total == 0);
c0103abe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ac2:	74 24                	je     c0103ae8 <default_check+0x68d>
c0103ac4:	c7 44 24 0c c4 6a 10 	movl   $0xc0106ac4,0xc(%esp)
c0103acb:	c0 
c0103acc:	c7 44 24 08 36 67 10 	movl   $0xc0106736,0x8(%esp)
c0103ad3:	c0 
c0103ad4:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c0103adb:	00 
c0103adc:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0103ae3:	e8 ea d1 ff ff       	call   c0100cd2 <__panic>
}
c0103ae8:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103aee:	5b                   	pop    %ebx
c0103aef:	5d                   	pop    %ebp
c0103af0:	c3                   	ret    

c0103af1 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103af1:	55                   	push   %ebp
c0103af2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103af4:	8b 55 08             	mov    0x8(%ebp),%edx
c0103af7:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103afc:	29 c2                	sub    %eax,%edx
c0103afe:	89 d0                	mov    %edx,%eax
c0103b00:	c1 f8 02             	sar    $0x2,%eax
c0103b03:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103b09:	5d                   	pop    %ebp
c0103b0a:	c3                   	ret    

c0103b0b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103b0b:	55                   	push   %ebp
c0103b0c:	89 e5                	mov    %esp,%ebp
c0103b0e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b14:	89 04 24             	mov    %eax,(%esp)
c0103b17:	e8 d5 ff ff ff       	call   c0103af1 <page2ppn>
c0103b1c:	c1 e0 0c             	shl    $0xc,%eax
}
c0103b1f:	c9                   	leave  
c0103b20:	c3                   	ret    

c0103b21 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103b21:	55                   	push   %ebp
c0103b22:	89 e5                	mov    %esp,%ebp
c0103b24:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103b27:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b2a:	c1 e8 0c             	shr    $0xc,%eax
c0103b2d:	89 c2                	mov    %eax,%edx
c0103b2f:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b34:	39 c2                	cmp    %eax,%edx
c0103b36:	72 1c                	jb     c0103b54 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103b38:	c7 44 24 08 00 6b 10 	movl   $0xc0106b00,0x8(%esp)
c0103b3f:	c0 
c0103b40:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103b47:	00 
c0103b48:	c7 04 24 1f 6b 10 c0 	movl   $0xc0106b1f,(%esp)
c0103b4f:	e8 7e d1 ff ff       	call   c0100cd2 <__panic>
    }
    return &pages[PPN(pa)];
c0103b54:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b5d:	c1 e8 0c             	shr    $0xc,%eax
c0103b60:	89 c2                	mov    %eax,%edx
c0103b62:	89 d0                	mov    %edx,%eax
c0103b64:	c1 e0 02             	shl    $0x2,%eax
c0103b67:	01 d0                	add    %edx,%eax
c0103b69:	c1 e0 02             	shl    $0x2,%eax
c0103b6c:	01 c8                	add    %ecx,%eax
}
c0103b6e:	c9                   	leave  
c0103b6f:	c3                   	ret    

c0103b70 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103b70:	55                   	push   %ebp
c0103b71:	89 e5                	mov    %esp,%ebp
c0103b73:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103b76:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b79:	89 04 24             	mov    %eax,(%esp)
c0103b7c:	e8 8a ff ff ff       	call   c0103b0b <page2pa>
c0103b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b87:	c1 e8 0c             	shr    $0xc,%eax
c0103b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b8d:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b92:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b95:	72 23                	jb     c0103bba <page2kva+0x4a>
c0103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b9e:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c0103ba5:	c0 
c0103ba6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103bad:	00 
c0103bae:	c7 04 24 1f 6b 10 c0 	movl   $0xc0106b1f,(%esp)
c0103bb5:	e8 18 d1 ff ff       	call   c0100cd2 <__panic>
c0103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bbd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103bc2:	c9                   	leave  
c0103bc3:	c3                   	ret    

c0103bc4 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103bc4:	55                   	push   %ebp
c0103bc5:	89 e5                	mov    %esp,%ebp
c0103bc7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bcd:	83 e0 01             	and    $0x1,%eax
c0103bd0:	85 c0                	test   %eax,%eax
c0103bd2:	75 1c                	jne    c0103bf0 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103bd4:	c7 44 24 08 54 6b 10 	movl   $0xc0106b54,0x8(%esp)
c0103bdb:	c0 
c0103bdc:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103be3:	00 
c0103be4:	c7 04 24 1f 6b 10 c0 	movl   $0xc0106b1f,(%esp)
c0103beb:	e8 e2 d0 ff ff       	call   c0100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103bf8:	89 04 24             	mov    %eax,(%esp)
c0103bfb:	e8 21 ff ff ff       	call   c0103b21 <pa2page>
}
c0103c00:	c9                   	leave  
c0103c01:	c3                   	ret    

c0103c02 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103c02:	55                   	push   %ebp
c0103c03:	89 e5                	mov    %esp,%ebp
c0103c05:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103c08:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c10:	89 04 24             	mov    %eax,(%esp)
c0103c13:	e8 09 ff ff ff       	call   c0103b21 <pa2page>
}
c0103c18:	c9                   	leave  
c0103c19:	c3                   	ret    

c0103c1a <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103c1a:	55                   	push   %ebp
c0103c1b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c20:	8b 00                	mov    (%eax),%eax
}
c0103c22:	5d                   	pop    %ebp
c0103c23:	c3                   	ret    

c0103c24 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103c24:	55                   	push   %ebp
c0103c25:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c2d:	89 10                	mov    %edx,(%eax)
}
c0103c2f:	5d                   	pop    %ebp
c0103c30:	c3                   	ret    

c0103c31 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103c31:	55                   	push   %ebp
c0103c32:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c37:	8b 00                	mov    (%eax),%eax
c0103c39:	8d 50 01             	lea    0x1(%eax),%edx
c0103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c3f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103c41:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c44:	8b 00                	mov    (%eax),%eax
}
c0103c46:	5d                   	pop    %ebp
c0103c47:	c3                   	ret    

c0103c48 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103c48:	55                   	push   %ebp
c0103c49:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c4e:	8b 00                	mov    (%eax),%eax
c0103c50:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103c53:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c56:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103c58:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c5b:	8b 00                	mov    (%eax),%eax
}
c0103c5d:	5d                   	pop    %ebp
c0103c5e:	c3                   	ret    

c0103c5f <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103c5f:	55                   	push   %ebp
c0103c60:	89 e5                	mov    %esp,%ebp
c0103c62:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103c65:	9c                   	pushf  
c0103c66:	58                   	pop    %eax
c0103c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103c6d:	25 00 02 00 00       	and    $0x200,%eax
c0103c72:	85 c0                	test   %eax,%eax
c0103c74:	74 0c                	je     c0103c82 <__intr_save+0x23>
        intr_disable();
c0103c76:	e8 4b da ff ff       	call   c01016c6 <intr_disable>
        return 1;
c0103c7b:	b8 01 00 00 00       	mov    $0x1,%eax
c0103c80:	eb 05                	jmp    c0103c87 <__intr_save+0x28>
    }
    return 0;
c0103c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103c87:	c9                   	leave  
c0103c88:	c3                   	ret    

c0103c89 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103c89:	55                   	push   %ebp
c0103c8a:	89 e5                	mov    %esp,%ebp
c0103c8c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103c8f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c93:	74 05                	je     c0103c9a <__intr_restore+0x11>
        intr_enable();
c0103c95:	e8 26 da ff ff       	call   c01016c0 <intr_enable>
    }
}
c0103c9a:	c9                   	leave  
c0103c9b:	c3                   	ret    

c0103c9c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103c9c:	55                   	push   %ebp
c0103c9d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103c9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ca2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103ca5:	b8 23 00 00 00       	mov    $0x23,%eax
c0103caa:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103cac:	b8 23 00 00 00       	mov    $0x23,%eax
c0103cb1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103cb3:	b8 10 00 00 00       	mov    $0x10,%eax
c0103cb8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103cba:	b8 10 00 00 00       	mov    $0x10,%eax
c0103cbf:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103cc1:	b8 10 00 00 00       	mov    $0x10,%eax
c0103cc6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103cc8:	ea cf 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103ccf
}
c0103ccf:	5d                   	pop    %ebp
c0103cd0:	c3                   	ret    

c0103cd1 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103cd1:	55                   	push   %ebp
c0103cd2:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cd7:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103cdc:	5d                   	pop    %ebp
c0103cdd:	c3                   	ret    

c0103cde <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103cde:	55                   	push   %ebp
c0103cdf:	89 e5                	mov    %esp,%ebp
c0103ce1:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103ce4:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103ce9:	89 04 24             	mov    %eax,(%esp)
c0103cec:	e8 e0 ff ff ff       	call   c0103cd1 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103cf1:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103cf8:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103cfa:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103d01:	68 00 
c0103d03:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103d08:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103d0e:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103d13:	c1 e8 10             	shr    $0x10,%eax
c0103d16:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103d1b:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d22:	83 e0 f0             	and    $0xfffffff0,%eax
c0103d25:	83 c8 09             	or     $0x9,%eax
c0103d28:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d2d:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d34:	83 e0 ef             	and    $0xffffffef,%eax
c0103d37:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d3c:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d43:	83 e0 9f             	and    $0xffffff9f,%eax
c0103d46:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d4b:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103d52:	83 c8 80             	or     $0xffffff80,%eax
c0103d55:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103d5a:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d61:	83 e0 f0             	and    $0xfffffff0,%eax
c0103d64:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d69:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d70:	83 e0 ef             	and    $0xffffffef,%eax
c0103d73:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d78:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d7f:	83 e0 df             	and    $0xffffffdf,%eax
c0103d82:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d87:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d8e:	83 c8 40             	or     $0x40,%eax
c0103d91:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d96:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d9d:	83 e0 7f             	and    $0x7f,%eax
c0103da0:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103da5:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103daa:	c1 e8 18             	shr    $0x18,%eax
c0103dad:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103db2:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103db9:	e8 de fe ff ff       	call   c0103c9c <lgdt>
c0103dbe:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103dc4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103dc8:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103dcb:	c9                   	leave  
c0103dcc:	c3                   	ret    

c0103dcd <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103dcd:	55                   	push   %ebp
c0103dce:	89 e5                	mov    %esp,%ebp
c0103dd0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103dd3:	c7 05 1c af 11 c0 e4 	movl   $0xc0106ae4,0xc011af1c
c0103dda:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103ddd:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103de2:	8b 00                	mov    (%eax),%eax
c0103de4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103de8:	c7 04 24 80 6b 10 c0 	movl   $0xc0106b80,(%esp)
c0103def:	e8 54 c5 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103df4:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103df9:	8b 40 04             	mov    0x4(%eax),%eax
c0103dfc:	ff d0                	call   *%eax
}
c0103dfe:	c9                   	leave  
c0103dff:	c3                   	ret    

c0103e00 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103e00:	55                   	push   %ebp
c0103e01:	89 e5                	mov    %esp,%ebp
c0103e03:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103e06:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e0b:	8b 40 08             	mov    0x8(%eax),%eax
c0103e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e15:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e18:	89 14 24             	mov    %edx,(%esp)
c0103e1b:	ff d0                	call   *%eax
}
c0103e1d:	c9                   	leave  
c0103e1e:	c3                   	ret    

c0103e1f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103e1f:	55                   	push   %ebp
c0103e20:	89 e5                	mov    %esp,%ebp
c0103e22:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e2c:	e8 2e fe ff ff       	call   c0103c5f <__intr_save>
c0103e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103e34:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e39:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e3c:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e3f:	89 14 24             	mov    %edx,(%esp)
c0103e42:	ff d0                	call   *%eax
c0103e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e4a:	89 04 24             	mov    %eax,(%esp)
c0103e4d:	e8 37 fe ff ff       	call   c0103c89 <__intr_restore>
    return page;
c0103e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103e55:	c9                   	leave  
c0103e56:	c3                   	ret    

c0103e57 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103e57:	55                   	push   %ebp
c0103e58:	89 e5                	mov    %esp,%ebp
c0103e5a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e5d:	e8 fd fd ff ff       	call   c0103c5f <__intr_save>
c0103e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103e65:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e6a:	8b 40 10             	mov    0x10(%eax),%eax
c0103e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e70:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e74:	8b 55 08             	mov    0x8(%ebp),%edx
c0103e77:	89 14 24             	mov    %edx,(%esp)
c0103e7a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e7f:	89 04 24             	mov    %eax,(%esp)
c0103e82:	e8 02 fe ff ff       	call   c0103c89 <__intr_restore>
}
c0103e87:	c9                   	leave  
c0103e88:	c3                   	ret    

c0103e89 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103e89:	55                   	push   %ebp
c0103e8a:	89 e5                	mov    %esp,%ebp
c0103e8c:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e8f:	e8 cb fd ff ff       	call   c0103c5f <__intr_save>
c0103e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103e97:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e9c:	8b 40 14             	mov    0x14(%eax),%eax
c0103e9f:	ff d0                	call   *%eax
c0103ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ea7:	89 04 24             	mov    %eax,(%esp)
c0103eaa:	e8 da fd ff ff       	call   c0103c89 <__intr_restore>
    return ret;
c0103eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103eb2:	c9                   	leave  
c0103eb3:	c3                   	ret    

c0103eb4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103eb4:	55                   	push   %ebp
c0103eb5:	89 e5                	mov    %esp,%ebp
c0103eb7:	57                   	push   %edi
c0103eb8:	56                   	push   %esi
c0103eb9:	53                   	push   %ebx
c0103eba:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103ec0:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103ec7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103ece:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103ed5:	c7 04 24 97 6b 10 c0 	movl   $0xc0106b97,(%esp)
c0103edc:	e8 67 c4 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103ee1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103ee8:	e9 15 01 00 00       	jmp    c0104002 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103eed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ef0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ef3:	89 d0                	mov    %edx,%eax
c0103ef5:	c1 e0 02             	shl    $0x2,%eax
c0103ef8:	01 d0                	add    %edx,%eax
c0103efa:	c1 e0 02             	shl    $0x2,%eax
c0103efd:	01 c8                	add    %ecx,%eax
c0103eff:	8b 50 08             	mov    0x8(%eax),%edx
c0103f02:	8b 40 04             	mov    0x4(%eax),%eax
c0103f05:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103f08:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103f0b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f11:	89 d0                	mov    %edx,%eax
c0103f13:	c1 e0 02             	shl    $0x2,%eax
c0103f16:	01 d0                	add    %edx,%eax
c0103f18:	c1 e0 02             	shl    $0x2,%eax
c0103f1b:	01 c8                	add    %ecx,%eax
c0103f1d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f20:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f23:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f26:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f29:	01 c8                	add    %ecx,%eax
c0103f2b:	11 da                	adc    %ebx,%edx
c0103f2d:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103f30:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103f33:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f39:	89 d0                	mov    %edx,%eax
c0103f3b:	c1 e0 02             	shl    $0x2,%eax
c0103f3e:	01 d0                	add    %edx,%eax
c0103f40:	c1 e0 02             	shl    $0x2,%eax
c0103f43:	01 c8                	add    %ecx,%eax
c0103f45:	83 c0 14             	add    $0x14,%eax
c0103f48:	8b 00                	mov    (%eax),%eax
c0103f4a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103f50:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f53:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f56:	83 c0 ff             	add    $0xffffffff,%eax
c0103f59:	83 d2 ff             	adc    $0xffffffff,%edx
c0103f5c:	89 c6                	mov    %eax,%esi
c0103f5e:	89 d7                	mov    %edx,%edi
c0103f60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f63:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f66:	89 d0                	mov    %edx,%eax
c0103f68:	c1 e0 02             	shl    $0x2,%eax
c0103f6b:	01 d0                	add    %edx,%eax
c0103f6d:	c1 e0 02             	shl    $0x2,%eax
c0103f70:	01 c8                	add    %ecx,%eax
c0103f72:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f75:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f78:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103f7e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103f82:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103f86:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103f8a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f8d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f94:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103f98:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103f9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103fa0:	c7 04 24 a4 6b 10 c0 	movl   $0xc0106ba4,(%esp)
c0103fa7:	e8 9c c3 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103fac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103faf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fb2:	89 d0                	mov    %edx,%eax
c0103fb4:	c1 e0 02             	shl    $0x2,%eax
c0103fb7:	01 d0                	add    %edx,%eax
c0103fb9:	c1 e0 02             	shl    $0x2,%eax
c0103fbc:	01 c8                	add    %ecx,%eax
c0103fbe:	83 c0 14             	add    $0x14,%eax
c0103fc1:	8b 00                	mov    (%eax),%eax
c0103fc3:	83 f8 01             	cmp    $0x1,%eax
c0103fc6:	75 36                	jne    c0103ffe <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103fce:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103fd1:	77 2b                	ja     c0103ffe <page_init+0x14a>
c0103fd3:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103fd6:	72 05                	jb     c0103fdd <page_init+0x129>
c0103fd8:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103fdb:	73 21                	jae    c0103ffe <page_init+0x14a>
c0103fdd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103fe1:	77 1b                	ja     c0103ffe <page_init+0x14a>
c0103fe3:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103fe7:	72 09                	jb     c0103ff2 <page_init+0x13e>
c0103fe9:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103ff0:	77 0c                	ja     c0103ffe <page_init+0x14a>
                maxpa = end;
c0103ff2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103ff5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103ffb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103ffe:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104002:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104005:	8b 00                	mov    (%eax),%eax
c0104007:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010400a:	0f 8f dd fe ff ff    	jg     c0103eed <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104010:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104014:	72 1d                	jb     c0104033 <page_init+0x17f>
c0104016:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010401a:	77 09                	ja     c0104025 <page_init+0x171>
c010401c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0104023:	76 0e                	jbe    c0104033 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0104025:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010402c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104033:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104039:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010403d:	c1 ea 0c             	shr    $0xc,%edx
c0104040:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104045:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010404c:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0104051:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104054:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104057:	01 d0                	add    %edx,%eax
c0104059:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010405c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010405f:	ba 00 00 00 00       	mov    $0x0,%edx
c0104064:	f7 75 ac             	divl   -0x54(%ebp)
c0104067:	89 d0                	mov    %edx,%eax
c0104069:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010406c:	29 c2                	sub    %eax,%edx
c010406e:	89 d0                	mov    %edx,%eax
c0104070:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0104075:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010407c:	eb 2f                	jmp    c01040ad <page_init+0x1f9>
        SetPageReserved(pages + i);
c010407e:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0104084:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104087:	89 d0                	mov    %edx,%eax
c0104089:	c1 e0 02             	shl    $0x2,%eax
c010408c:	01 d0                	add    %edx,%eax
c010408e:	c1 e0 02             	shl    $0x2,%eax
c0104091:	01 c8                	add    %ecx,%eax
c0104093:	83 c0 04             	add    $0x4,%eax
c0104096:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c010409d:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01040a0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01040a3:	8b 55 90             	mov    -0x70(%ebp),%edx
c01040a6:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01040a9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01040ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040b0:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01040b5:	39 c2                	cmp    %eax,%edx
c01040b7:	72 c5                	jb     c010407e <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01040b9:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01040bf:	89 d0                	mov    %edx,%eax
c01040c1:	c1 e0 02             	shl    $0x2,%eax
c01040c4:	01 d0                	add    %edx,%eax
c01040c6:	c1 e0 02             	shl    $0x2,%eax
c01040c9:	89 c2                	mov    %eax,%edx
c01040cb:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c01040d0:	01 d0                	add    %edx,%eax
c01040d2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01040d5:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01040dc:	77 23                	ja     c0104101 <page_init+0x24d>
c01040de:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01040e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01040e5:	c7 44 24 08 d4 6b 10 	movl   $0xc0106bd4,0x8(%esp)
c01040ec:	c0 
c01040ed:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01040f4:	00 
c01040f5:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01040fc:	e8 d1 cb ff ff       	call   c0100cd2 <__panic>
c0104101:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104104:	05 00 00 00 40       	add    $0x40000000,%eax
c0104109:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010410c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104113:	e9 74 01 00 00       	jmp    c010428c <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104118:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010411b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010411e:	89 d0                	mov    %edx,%eax
c0104120:	c1 e0 02             	shl    $0x2,%eax
c0104123:	01 d0                	add    %edx,%eax
c0104125:	c1 e0 02             	shl    $0x2,%eax
c0104128:	01 c8                	add    %ecx,%eax
c010412a:	8b 50 08             	mov    0x8(%eax),%edx
c010412d:	8b 40 04             	mov    0x4(%eax),%eax
c0104130:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104133:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104136:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104139:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010413c:	89 d0                	mov    %edx,%eax
c010413e:	c1 e0 02             	shl    $0x2,%eax
c0104141:	01 d0                	add    %edx,%eax
c0104143:	c1 e0 02             	shl    $0x2,%eax
c0104146:	01 c8                	add    %ecx,%eax
c0104148:	8b 48 0c             	mov    0xc(%eax),%ecx
c010414b:	8b 58 10             	mov    0x10(%eax),%ebx
c010414e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104151:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104154:	01 c8                	add    %ecx,%eax
c0104156:	11 da                	adc    %ebx,%edx
c0104158:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010415b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010415e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104161:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104164:	89 d0                	mov    %edx,%eax
c0104166:	c1 e0 02             	shl    $0x2,%eax
c0104169:	01 d0                	add    %edx,%eax
c010416b:	c1 e0 02             	shl    $0x2,%eax
c010416e:	01 c8                	add    %ecx,%eax
c0104170:	83 c0 14             	add    $0x14,%eax
c0104173:	8b 00                	mov    (%eax),%eax
c0104175:	83 f8 01             	cmp    $0x1,%eax
c0104178:	0f 85 0a 01 00 00    	jne    c0104288 <page_init+0x3d4>
            if (begin < freemem) {
c010417e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104181:	ba 00 00 00 00       	mov    $0x0,%edx
c0104186:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104189:	72 17                	jb     c01041a2 <page_init+0x2ee>
c010418b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010418e:	77 05                	ja     c0104195 <page_init+0x2e1>
c0104190:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104193:	76 0d                	jbe    c01041a2 <page_init+0x2ee>
                begin = freemem;
c0104195:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104198:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010419b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01041a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01041a6:	72 1d                	jb     c01041c5 <page_init+0x311>
c01041a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01041ac:	77 09                	ja     c01041b7 <page_init+0x303>
c01041ae:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01041b5:	76 0e                	jbe    c01041c5 <page_init+0x311>
                end = KMEMSIZE;
c01041b7:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01041be:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01041c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041cb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041ce:	0f 87 b4 00 00 00    	ja     c0104288 <page_init+0x3d4>
c01041d4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041d7:	72 09                	jb     c01041e2 <page_init+0x32e>
c01041d9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041dc:	0f 83 a6 00 00 00    	jae    c0104288 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c01041e2:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c01041e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041ec:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01041ef:	01 d0                	add    %edx,%eax
c01041f1:	83 e8 01             	sub    $0x1,%eax
c01041f4:	89 45 98             	mov    %eax,-0x68(%ebp)
c01041f7:	8b 45 98             	mov    -0x68(%ebp),%eax
c01041fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01041ff:	f7 75 9c             	divl   -0x64(%ebp)
c0104202:	89 d0                	mov    %edx,%eax
c0104204:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104207:	29 c2                	sub    %eax,%edx
c0104209:	89 d0                	mov    %edx,%eax
c010420b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104210:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104213:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104216:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104219:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010421c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010421f:	ba 00 00 00 00       	mov    $0x0,%edx
c0104224:	89 c7                	mov    %eax,%edi
c0104226:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010422c:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010422f:	89 d0                	mov    %edx,%eax
c0104231:	83 e0 00             	and    $0x0,%eax
c0104234:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104237:	8b 45 80             	mov    -0x80(%ebp),%eax
c010423a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010423d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104240:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104243:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104246:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104249:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010424c:	77 3a                	ja     c0104288 <page_init+0x3d4>
c010424e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104251:	72 05                	jb     c0104258 <page_init+0x3a4>
c0104253:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104256:	73 30                	jae    c0104288 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104258:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010425b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c010425e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104261:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104264:	29 c8                	sub    %ecx,%eax
c0104266:	19 da                	sbb    %ebx,%edx
c0104268:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010426c:	c1 ea 0c             	shr    $0xc,%edx
c010426f:	89 c3                	mov    %eax,%ebx
c0104271:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104274:	89 04 24             	mov    %eax,(%esp)
c0104277:	e8 a5 f8 ff ff       	call   c0103b21 <pa2page>
c010427c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104280:	89 04 24             	mov    %eax,(%esp)
c0104283:	e8 78 fb ff ff       	call   c0103e00 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104288:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010428c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010428f:	8b 00                	mov    (%eax),%eax
c0104291:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104294:	0f 8f 7e fe ff ff    	jg     c0104118 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c010429a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01042a0:	5b                   	pop    %ebx
c01042a1:	5e                   	pop    %esi
c01042a2:	5f                   	pop    %edi
c01042a3:	5d                   	pop    %ebp
c01042a4:	c3                   	ret    

c01042a5 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01042a5:	55                   	push   %ebp
c01042a6:	89 e5                	mov    %esp,%ebp
c01042a8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01042ab:	8b 45 14             	mov    0x14(%ebp),%eax
c01042ae:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042b1:	31 d0                	xor    %edx,%eax
c01042b3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01042b8:	85 c0                	test   %eax,%eax
c01042ba:	74 24                	je     c01042e0 <boot_map_segment+0x3b>
c01042bc:	c7 44 24 0c 06 6c 10 	movl   $0xc0106c06,0xc(%esp)
c01042c3:	c0 
c01042c4:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01042cb:	c0 
c01042cc:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01042d3:	00 
c01042d4:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01042db:	e8 f2 c9 ff ff       	call   c0100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01042e0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042ea:	25 ff 0f 00 00       	and    $0xfff,%eax
c01042ef:	89 c2                	mov    %eax,%edx
c01042f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01042f4:	01 c2                	add    %eax,%edx
c01042f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042f9:	01 d0                	add    %edx,%eax
c01042fb:	83 e8 01             	sub    $0x1,%eax
c01042fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104301:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104304:	ba 00 00 00 00       	mov    $0x0,%edx
c0104309:	f7 75 f0             	divl   -0x10(%ebp)
c010430c:	89 d0                	mov    %edx,%eax
c010430e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104311:	29 c2                	sub    %eax,%edx
c0104313:	89 d0                	mov    %edx,%eax
c0104315:	c1 e8 0c             	shr    $0xc,%eax
c0104318:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010431b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010431e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104321:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104324:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104329:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010432c:	8b 45 14             	mov    0x14(%ebp),%eax
c010432f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104335:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010433a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010433d:	eb 6b                	jmp    c01043aa <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010433f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104346:	00 
c0104347:	8b 45 0c             	mov    0xc(%ebp),%eax
c010434a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010434e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104351:	89 04 24             	mov    %eax,(%esp)
c0104354:	e8 82 01 00 00       	call   c01044db <get_pte>
c0104359:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010435c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104360:	75 24                	jne    c0104386 <boot_map_segment+0xe1>
c0104362:	c7 44 24 0c 32 6c 10 	movl   $0xc0106c32,0xc(%esp)
c0104369:	c0 
c010436a:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104371:	c0 
c0104372:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104379:	00 
c010437a:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104381:	e8 4c c9 ff ff       	call   c0100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
c0104386:	8b 45 18             	mov    0x18(%ebp),%eax
c0104389:	8b 55 14             	mov    0x14(%ebp),%edx
c010438c:	09 d0                	or     %edx,%eax
c010438e:	83 c8 01             	or     $0x1,%eax
c0104391:	89 c2                	mov    %eax,%edx
c0104393:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104396:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104398:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010439c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01043a3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01043aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01043ae:	75 8f                	jne    c010433f <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01043b0:	c9                   	leave  
c01043b1:	c3                   	ret    

c01043b2 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01043b2:	55                   	push   %ebp
c01043b3:	89 e5                	mov    %esp,%ebp
c01043b5:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01043b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043bf:	e8 5b fa ff ff       	call   c0103e1f <alloc_pages>
c01043c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01043c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01043cb:	75 1c                	jne    c01043e9 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01043cd:	c7 44 24 08 3f 6c 10 	movl   $0xc0106c3f,0x8(%esp)
c01043d4:	c0 
c01043d5:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01043dc:	00 
c01043dd:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01043e4:	e8 e9 c8 ff ff       	call   c0100cd2 <__panic>
    }
    return page2kva(p);
c01043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043ec:	89 04 24             	mov    %eax,(%esp)
c01043ef:	e8 7c f7 ff ff       	call   c0103b70 <page2kva>
}
c01043f4:	c9                   	leave  
c01043f5:	c3                   	ret    

c01043f6 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01043f6:	55                   	push   %ebp
c01043f7:	89 e5                	mov    %esp,%ebp
c01043f9:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01043fc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104401:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104404:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010440b:	77 23                	ja     c0104430 <pmm_init+0x3a>
c010440d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104410:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104414:	c7 44 24 08 d4 6b 10 	movl   $0xc0106bd4,0x8(%esp)
c010441b:	c0 
c010441c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104423:	00 
c0104424:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010442b:	e8 a2 c8 ff ff       	call   c0100cd2 <__panic>
c0104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104433:	05 00 00 00 40       	add    $0x40000000,%eax
c0104438:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010443d:	e8 8b f9 ff ff       	call   c0103dcd <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104442:	e8 6d fa ff ff       	call   c0103eb4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104447:	e8 db 03 00 00       	call   c0104827 <check_alloc_page>

    check_pgdir();
c010444c:	e8 f4 03 00 00       	call   c0104845 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104451:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104456:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010445c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104461:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104464:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010446b:	77 23                	ja     c0104490 <pmm_init+0x9a>
c010446d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104470:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104474:	c7 44 24 08 d4 6b 10 	movl   $0xc0106bd4,0x8(%esp)
c010447b:	c0 
c010447c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104483:	00 
c0104484:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010448b:	e8 42 c8 ff ff       	call   c0100cd2 <__panic>
c0104490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104493:	05 00 00 00 40       	add    $0x40000000,%eax
c0104498:	83 c8 03             	or     $0x3,%eax
c010449b:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010449d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01044a2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01044a9:	00 
c01044aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01044b1:	00 
c01044b2:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01044b9:	38 
c01044ba:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01044c1:	c0 
c01044c2:	89 04 24             	mov    %eax,(%esp)
c01044c5:	e8 db fd ff ff       	call   c01042a5 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01044ca:	e8 0f f8 ff ff       	call   c0103cde <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01044cf:	e8 0c 0a 00 00       	call   c0104ee0 <check_boot_pgdir>

    print_pgdir();
c01044d4:	e8 94 0e 00 00       	call   c010536d <print_pgdir>

}
c01044d9:	c9                   	leave  
c01044da:	c3                   	ret    

c01044db <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01044db:	55                   	push   %ebp
c01044dc:	89 e5                	mov    %esp,%ebp
c01044de:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
	pde_t *pde = &pgdir[PDX(la)];
c01044e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044e4:	c1 e8 16             	shr    $0x16,%eax
c01044e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01044ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01044f1:	01 d0                	add    %edx,%eax
c01044f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!(*pde & PTE_P))
c01044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f9:	8b 00                	mov    (%eax),%eax
c01044fb:	83 e0 01             	and    $0x1,%eax
c01044fe:	85 c0                	test   %eax,%eax
c0104500:	0f 85 af 00 00 00    	jne    c01045b5 <get_pte+0xda>
	{
		struct Page* page;
		if(!create || (page = alloc_page()) == NULL)
c0104506:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010450a:	74 15                	je     c0104521 <get_pte+0x46>
c010450c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104513:	e8 07 f9 ff ff       	call   c0103e1f <alloc_pages>
c0104518:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010451b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010451f:	75 0a                	jne    c010452b <get_pte+0x50>
			return NULL;
c0104521:	b8 00 00 00 00       	mov    $0x0,%eax
c0104526:	e9 e6 00 00 00       	jmp    c0104611 <get_pte+0x136>
		set_page_ref(page,1);
c010452b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104532:	00 
c0104533:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104536:	89 04 24             	mov    %eax,(%esp)
c0104539:	e8 e6 f6 ff ff       	call   c0103c24 <set_page_ref>
		uintptr_t pa = page2pa(page);
c010453e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104541:	89 04 24             	mov    %eax,(%esp)
c0104544:	e8 c2 f5 ff ff       	call   c0103b0b <page2pa>
c0104549:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memset(KADDR(pa),0,PGSIZE);
c010454c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010454f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104552:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104555:	c1 e8 0c             	shr    $0xc,%eax
c0104558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010455b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104560:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104563:	72 23                	jb     c0104588 <get_pte+0xad>
c0104565:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104568:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010456c:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c0104573:	c0 
c0104574:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c010457b:	00 
c010457c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104583:	e8 4a c7 ff ff       	call   c0100cd2 <__panic>
c0104588:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010458b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104590:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104597:	00 
c0104598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010459f:	00 
c01045a0:	89 04 24             	mov    %eax,(%esp)
c01045a3:	e8 e3 18 00 00       	call   c0105e8b <memset>
		*pde = pa | PTE_P | PTE_U | PTE_W;
c01045a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01045ab:	83 c8 07             	or     $0x7,%eax
c01045ae:	89 c2                	mov    %eax,%edx
c01045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b3:	89 10                	mov    %edx,(%eax)
	}
	return &((pte_t *)KADDR(PDE_ADDR(*pde)))[PTX(la)];
c01045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b8:	8b 00                	mov    (%eax),%eax
c01045ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01045bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01045c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045c5:	c1 e8 0c             	shr    $0xc,%eax
c01045c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01045cb:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01045d0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01045d3:	72 23                	jb     c01045f8 <get_pte+0x11d>
c01045d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045dc:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c01045e3:	c0 
c01045e4:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c01045eb:	00 
c01045ec:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01045f3:	e8 da c6 ff ff       	call   c0100cd2 <__panic>
c01045f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045fb:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104600:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104603:	c1 ea 0c             	shr    $0xc,%edx
c0104606:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c010460c:	c1 e2 02             	shl    $0x2,%edx
c010460f:	01 d0                	add    %edx,%eax
}
c0104611:	c9                   	leave  
c0104612:	c3                   	ret    

c0104613 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104613:	55                   	push   %ebp
c0104614:	89 e5                	mov    %esp,%ebp
c0104616:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104619:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104620:	00 
c0104621:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104624:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104628:	8b 45 08             	mov    0x8(%ebp),%eax
c010462b:	89 04 24             	mov    %eax,(%esp)
c010462e:	e8 a8 fe ff ff       	call   c01044db <get_pte>
c0104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104636:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010463a:	74 08                	je     c0104644 <get_page+0x31>
        *ptep_store = ptep;
c010463c:	8b 45 10             	mov    0x10(%ebp),%eax
c010463f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104642:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104644:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104648:	74 1b                	je     c0104665 <get_page+0x52>
c010464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010464d:	8b 00                	mov    (%eax),%eax
c010464f:	83 e0 01             	and    $0x1,%eax
c0104652:	85 c0                	test   %eax,%eax
c0104654:	74 0f                	je     c0104665 <get_page+0x52>
        return pte2page(*ptep);
c0104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104659:	8b 00                	mov    (%eax),%eax
c010465b:	89 04 24             	mov    %eax,(%esp)
c010465e:	e8 61 f5 ff ff       	call   c0103bc4 <pte2page>
c0104663:	eb 05                	jmp    c010466a <get_page+0x57>
    }
    return NULL;
c0104665:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010466a:	c9                   	leave  
c010466b:	c3                   	ret    

c010466c <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010466c:	55                   	push   %ebp
c010466d:	89 e5                	mov    %esp,%ebp
c010466f:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
	if(*ptep & PTE_P)
c0104672:	8b 45 10             	mov    0x10(%ebp),%eax
c0104675:	8b 00                	mov    (%eax),%eax
c0104677:	83 e0 01             	and    $0x1,%eax
c010467a:	85 c0                	test   %eax,%eax
c010467c:	74 4d                	je     c01046cb <page_remove_pte+0x5f>
	{
		struct Page* page = pte2page(*ptep);
c010467e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104681:	8b 00                	mov    (%eax),%eax
c0104683:	89 04 24             	mov    %eax,(%esp)
c0104686:	e8 39 f5 ff ff       	call   c0103bc4 <pte2page>
c010468b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(page_ref_dec(page) == 0)
c010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104691:	89 04 24             	mov    %eax,(%esp)
c0104694:	e8 af f5 ff ff       	call   c0103c48 <page_ref_dec>
c0104699:	85 c0                	test   %eax,%eax
c010469b:	75 13                	jne    c01046b0 <page_remove_pte+0x44>
		{
			free_page(page);
c010469d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01046a4:	00 
c01046a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a8:	89 04 24             	mov    %eax,(%esp)
c01046ab:	e8 a7 f7 ff ff       	call   c0103e57 <free_pages>
		}
		*ptep = 0;
c01046b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01046b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,la);
c01046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c3:	89 04 24             	mov    %eax,(%esp)
c01046c6:	e8 ff 00 00 00       	call   c01047ca <tlb_invalidate>
	}
}
c01046cb:	c9                   	leave  
c01046cc:	c3                   	ret    

c01046cd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01046cd:	55                   	push   %ebp
c01046ce:	89 e5                	mov    %esp,%ebp
c01046d0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01046d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01046da:	00 
c01046db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e5:	89 04 24             	mov    %eax,(%esp)
c01046e8:	e8 ee fd ff ff       	call   c01044db <get_pte>
c01046ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01046f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046f4:	74 19                	je     c010470f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104700:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104704:	8b 45 08             	mov    0x8(%ebp),%eax
c0104707:	89 04 24             	mov    %eax,(%esp)
c010470a:	e8 5d ff ff ff       	call   c010466c <page_remove_pte>
    }
}
c010470f:	c9                   	leave  
c0104710:	c3                   	ret    

c0104711 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104711:	55                   	push   %ebp
c0104712:	89 e5                	mov    %esp,%ebp
c0104714:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104717:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010471e:	00 
c010471f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104722:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104726:	8b 45 08             	mov    0x8(%ebp),%eax
c0104729:	89 04 24             	mov    %eax,(%esp)
c010472c:	e8 aa fd ff ff       	call   c01044db <get_pte>
c0104731:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104738:	75 0a                	jne    c0104744 <page_insert+0x33>
        return -E_NO_MEM;
c010473a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010473f:	e9 84 00 00 00       	jmp    c01047c8 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104744:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104747:	89 04 24             	mov    %eax,(%esp)
c010474a:	e8 e2 f4 ff ff       	call   c0103c31 <page_ref_inc>
    if (*ptep & PTE_P) {
c010474f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104752:	8b 00                	mov    (%eax),%eax
c0104754:	83 e0 01             	and    $0x1,%eax
c0104757:	85 c0                	test   %eax,%eax
c0104759:	74 3e                	je     c0104799 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010475e:	8b 00                	mov    (%eax),%eax
c0104760:	89 04 24             	mov    %eax,(%esp)
c0104763:	e8 5c f4 ff ff       	call   c0103bc4 <pte2page>
c0104768:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010476b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010476e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104771:	75 0d                	jne    c0104780 <page_insert+0x6f>
            page_ref_dec(page);
c0104773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104776:	89 04 24             	mov    %eax,(%esp)
c0104779:	e8 ca f4 ff ff       	call   c0103c48 <page_ref_dec>
c010477e:	eb 19                	jmp    c0104799 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104783:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104787:	8b 45 10             	mov    0x10(%ebp),%eax
c010478a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010478e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104791:	89 04 24             	mov    %eax,(%esp)
c0104794:	e8 d3 fe ff ff       	call   c010466c <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104799:	8b 45 0c             	mov    0xc(%ebp),%eax
c010479c:	89 04 24             	mov    %eax,(%esp)
c010479f:	e8 67 f3 ff ff       	call   c0103b0b <page2pa>
c01047a4:	0b 45 14             	or     0x14(%ebp),%eax
c01047a7:	83 c8 01             	or     $0x1,%eax
c01047aa:	89 c2                	mov    %eax,%edx
c01047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047af:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01047b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01047b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01047b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01047bb:	89 04 24             	mov    %eax,(%esp)
c01047be:	e8 07 00 00 00       	call   c01047ca <tlb_invalidate>
    return 0;
c01047c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047c8:	c9                   	leave  
c01047c9:	c3                   	ret    

c01047ca <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01047ca:	55                   	push   %ebp
c01047cb:	89 e5                	mov    %esp,%ebp
c01047cd:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01047d0:	0f 20 d8             	mov    %cr3,%eax
c01047d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01047d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c01047d9:	89 c2                	mov    %eax,%edx
c01047db:	8b 45 08             	mov    0x8(%ebp),%eax
c01047de:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047e1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01047e8:	77 23                	ja     c010480d <tlb_invalidate+0x43>
c01047ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047f1:	c7 44 24 08 d4 6b 10 	movl   $0xc0106bd4,0x8(%esp)
c01047f8:	c0 
c01047f9:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c0104800:	00 
c0104801:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104808:	e8 c5 c4 ff ff       	call   c0100cd2 <__panic>
c010480d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104810:	05 00 00 00 40       	add    $0x40000000,%eax
c0104815:	39 c2                	cmp    %eax,%edx
c0104817:	75 0c                	jne    c0104825 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104819:	8b 45 0c             	mov    0xc(%ebp),%eax
c010481c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010481f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104822:	0f 01 38             	invlpg (%eax)
    }
}
c0104825:	c9                   	leave  
c0104826:	c3                   	ret    

c0104827 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104827:	55                   	push   %ebp
c0104828:	89 e5                	mov    %esp,%ebp
c010482a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010482d:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0104832:	8b 40 18             	mov    0x18(%eax),%eax
c0104835:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104837:	c7 04 24 58 6c 10 c0 	movl   $0xc0106c58,(%esp)
c010483e:	e8 05 bb ff ff       	call   c0100348 <cprintf>
}
c0104843:	c9                   	leave  
c0104844:	c3                   	ret    

c0104845 <check_pgdir>:

static void
check_pgdir(void) {
c0104845:	55                   	push   %ebp
c0104846:	89 e5                	mov    %esp,%ebp
c0104848:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010484b:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104850:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104855:	76 24                	jbe    c010487b <check_pgdir+0x36>
c0104857:	c7 44 24 0c 77 6c 10 	movl   $0xc0106c77,0xc(%esp)
c010485e:	c0 
c010485f:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104866:	c0 
c0104867:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c010486e:	00 
c010486f:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104876:	e8 57 c4 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010487b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104880:	85 c0                	test   %eax,%eax
c0104882:	74 0e                	je     c0104892 <check_pgdir+0x4d>
c0104884:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104889:	25 ff 0f 00 00       	and    $0xfff,%eax
c010488e:	85 c0                	test   %eax,%eax
c0104890:	74 24                	je     c01048b6 <check_pgdir+0x71>
c0104892:	c7 44 24 0c 94 6c 10 	movl   $0xc0106c94,0xc(%esp)
c0104899:	c0 
c010489a:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01048a1:	c0 
c01048a2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c01048a9:	00 
c01048aa:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01048b1:	e8 1c c4 ff ff       	call   c0100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01048b6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048c2:	00 
c01048c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048ca:	00 
c01048cb:	89 04 24             	mov    %eax,(%esp)
c01048ce:	e8 40 fd ff ff       	call   c0104613 <get_page>
c01048d3:	85 c0                	test   %eax,%eax
c01048d5:	74 24                	je     c01048fb <check_pgdir+0xb6>
c01048d7:	c7 44 24 0c cc 6c 10 	movl   $0xc0106ccc,0xc(%esp)
c01048de:	c0 
c01048df:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01048e6:	c0 
c01048e7:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c01048ee:	00 
c01048ef:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01048f6:	e8 d7 c3 ff ff       	call   c0100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01048fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104902:	e8 18 f5 ff ff       	call   c0103e1f <alloc_pages>
c0104907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010490a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010490f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104916:	00 
c0104917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010491e:	00 
c010491f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104922:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104926:	89 04 24             	mov    %eax,(%esp)
c0104929:	e8 e3 fd ff ff       	call   c0104711 <page_insert>
c010492e:	85 c0                	test   %eax,%eax
c0104930:	74 24                	je     c0104956 <check_pgdir+0x111>
c0104932:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c0104939:	c0 
c010493a:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104941:	c0 
c0104942:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0104949:	00 
c010494a:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104951:	e8 7c c3 ff ff       	call   c0100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104956:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010495b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104962:	00 
c0104963:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010496a:	00 
c010496b:	89 04 24             	mov    %eax,(%esp)
c010496e:	e8 68 fb ff ff       	call   c01044db <get_pte>
c0104973:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104976:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010497a:	75 24                	jne    c01049a0 <check_pgdir+0x15b>
c010497c:	c7 44 24 0c 20 6d 10 	movl   $0xc0106d20,0xc(%esp)
c0104983:	c0 
c0104984:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c010498b:	c0 
c010498c:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0104993:	00 
c0104994:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010499b:	e8 32 c3 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c01049a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049a3:	8b 00                	mov    (%eax),%eax
c01049a5:	89 04 24             	mov    %eax,(%esp)
c01049a8:	e8 17 f2 ff ff       	call   c0103bc4 <pte2page>
c01049ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01049b0:	74 24                	je     c01049d6 <check_pgdir+0x191>
c01049b2:	c7 44 24 0c 4d 6d 10 	movl   $0xc0106d4d,0xc(%esp)
c01049b9:	c0 
c01049ba:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01049c1:	c0 
c01049c2:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c01049c9:	00 
c01049ca:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01049d1:	e8 fc c2 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 1);
c01049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d9:	89 04 24             	mov    %eax,(%esp)
c01049dc:	e8 39 f2 ff ff       	call   c0103c1a <page_ref>
c01049e1:	83 f8 01             	cmp    $0x1,%eax
c01049e4:	74 24                	je     c0104a0a <check_pgdir+0x1c5>
c01049e6:	c7 44 24 0c 63 6d 10 	movl   $0xc0106d63,0xc(%esp)
c01049ed:	c0 
c01049ee:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01049f5:	c0 
c01049f6:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01049fd:	00 
c01049fe:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104a05:	e8 c8 c2 ff ff       	call   c0100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104a0a:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a0f:	8b 00                	mov    (%eax),%eax
c0104a11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a1c:	c1 e8 0c             	shr    $0xc,%eax
c0104a1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104a22:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104a27:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104a2a:	72 23                	jb     c0104a4f <check_pgdir+0x20a>
c0104a2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104a33:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c0104a3a:	c0 
c0104a3b:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c0104a42:	00 
c0104a43:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104a4a:	e8 83 c2 ff ff       	call   c0100cd2 <__panic>
c0104a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a52:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104a57:	83 c0 04             	add    $0x4,%eax
c0104a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104a5d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a69:	00 
c0104a6a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a71:	00 
c0104a72:	89 04 24             	mov    %eax,(%esp)
c0104a75:	e8 61 fa ff ff       	call   c01044db <get_pte>
c0104a7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a7d:	74 24                	je     c0104aa3 <check_pgdir+0x25e>
c0104a7f:	c7 44 24 0c 78 6d 10 	movl   $0xc0106d78,0xc(%esp)
c0104a86:	c0 
c0104a87:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104a8e:	c0 
c0104a8f:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104a96:	00 
c0104a97:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104a9e:	e8 2f c2 ff ff       	call   c0100cd2 <__panic>

    p2 = alloc_page();
c0104aa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104aaa:	e8 70 f3 ff ff       	call   c0103e1f <alloc_pages>
c0104aaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104ab2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ab7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104abe:	00 
c0104abf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ac6:	00 
c0104ac7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104aca:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ace:	89 04 24             	mov    %eax,(%esp)
c0104ad1:	e8 3b fc ff ff       	call   c0104711 <page_insert>
c0104ad6:	85 c0                	test   %eax,%eax
c0104ad8:	74 24                	je     c0104afe <check_pgdir+0x2b9>
c0104ada:	c7 44 24 0c a0 6d 10 	movl   $0xc0106da0,0xc(%esp)
c0104ae1:	c0 
c0104ae2:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104ae9:	c0 
c0104aea:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104af1:	00 
c0104af2:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104af9:	e8 d4 c1 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104afe:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b0a:	00 
c0104b0b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b12:	00 
c0104b13:	89 04 24             	mov    %eax,(%esp)
c0104b16:	e8 c0 f9 ff ff       	call   c01044db <get_pte>
c0104b1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b22:	75 24                	jne    c0104b48 <check_pgdir+0x303>
c0104b24:	c7 44 24 0c d8 6d 10 	movl   $0xc0106dd8,0xc(%esp)
c0104b2b:	c0 
c0104b2c:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104b33:	c0 
c0104b34:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104b3b:	00 
c0104b3c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104b43:	e8 8a c1 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_U);
c0104b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b4b:	8b 00                	mov    (%eax),%eax
c0104b4d:	83 e0 04             	and    $0x4,%eax
c0104b50:	85 c0                	test   %eax,%eax
c0104b52:	75 24                	jne    c0104b78 <check_pgdir+0x333>
c0104b54:	c7 44 24 0c 08 6e 10 	movl   $0xc0106e08,0xc(%esp)
c0104b5b:	c0 
c0104b5c:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104b63:	c0 
c0104b64:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104b6b:	00 
c0104b6c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104b73:	e8 5a c1 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_W);
c0104b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b7b:	8b 00                	mov    (%eax),%eax
c0104b7d:	83 e0 02             	and    $0x2,%eax
c0104b80:	85 c0                	test   %eax,%eax
c0104b82:	75 24                	jne    c0104ba8 <check_pgdir+0x363>
c0104b84:	c7 44 24 0c 16 6e 10 	movl   $0xc0106e16,0xc(%esp)
c0104b8b:	c0 
c0104b8c:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104b93:	c0 
c0104b94:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104b9b:	00 
c0104b9c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104ba3:	e8 2a c1 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104ba8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bad:	8b 00                	mov    (%eax),%eax
c0104baf:	83 e0 04             	and    $0x4,%eax
c0104bb2:	85 c0                	test   %eax,%eax
c0104bb4:	75 24                	jne    c0104bda <check_pgdir+0x395>
c0104bb6:	c7 44 24 0c 24 6e 10 	movl   $0xc0106e24,0xc(%esp)
c0104bbd:	c0 
c0104bbe:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104bc5:	c0 
c0104bc6:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104bcd:	00 
c0104bce:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104bd5:	e8 f8 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 1);
c0104bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bdd:	89 04 24             	mov    %eax,(%esp)
c0104be0:	e8 35 f0 ff ff       	call   c0103c1a <page_ref>
c0104be5:	83 f8 01             	cmp    $0x1,%eax
c0104be8:	74 24                	je     c0104c0e <check_pgdir+0x3c9>
c0104bea:	c7 44 24 0c 3a 6e 10 	movl   $0xc0106e3a,0xc(%esp)
c0104bf1:	c0 
c0104bf2:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104bf9:	c0 
c0104bfa:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0104c01:	00 
c0104c02:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104c09:	e8 c4 c0 ff ff       	call   c0100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104c0e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c13:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104c1a:	00 
c0104c1b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104c22:	00 
c0104c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c2a:	89 04 24             	mov    %eax,(%esp)
c0104c2d:	e8 df fa ff ff       	call   c0104711 <page_insert>
c0104c32:	85 c0                	test   %eax,%eax
c0104c34:	74 24                	je     c0104c5a <check_pgdir+0x415>
c0104c36:	c7 44 24 0c 4c 6e 10 	movl   $0xc0106e4c,0xc(%esp)
c0104c3d:	c0 
c0104c3e:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104c45:	c0 
c0104c46:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104c4d:	00 
c0104c4e:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104c55:	e8 78 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 2);
c0104c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5d:	89 04 24             	mov    %eax,(%esp)
c0104c60:	e8 b5 ef ff ff       	call   c0103c1a <page_ref>
c0104c65:	83 f8 02             	cmp    $0x2,%eax
c0104c68:	74 24                	je     c0104c8e <check_pgdir+0x449>
c0104c6a:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c0104c71:	c0 
c0104c72:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104c79:	c0 
c0104c7a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0104c81:	00 
c0104c82:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104c89:	e8 44 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c91:	89 04 24             	mov    %eax,(%esp)
c0104c94:	e8 81 ef ff ff       	call   c0103c1a <page_ref>
c0104c99:	85 c0                	test   %eax,%eax
c0104c9b:	74 24                	je     c0104cc1 <check_pgdir+0x47c>
c0104c9d:	c7 44 24 0c 8a 6e 10 	movl   $0xc0106e8a,0xc(%esp)
c0104ca4:	c0 
c0104ca5:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104cac:	c0 
c0104cad:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104cb4:	00 
c0104cb5:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104cbc:	e8 11 c0 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104cc1:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104cc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ccd:	00 
c0104cce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104cd5:	00 
c0104cd6:	89 04 24             	mov    %eax,(%esp)
c0104cd9:	e8 fd f7 ff ff       	call   c01044db <get_pte>
c0104cde:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ce1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ce5:	75 24                	jne    c0104d0b <check_pgdir+0x4c6>
c0104ce7:	c7 44 24 0c d8 6d 10 	movl   $0xc0106dd8,0xc(%esp)
c0104cee:	c0 
c0104cef:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104cf6:	c0 
c0104cf7:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104cfe:	00 
c0104cff:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104d06:	e8 c7 bf ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c0104d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d0e:	8b 00                	mov    (%eax),%eax
c0104d10:	89 04 24             	mov    %eax,(%esp)
c0104d13:	e8 ac ee ff ff       	call   c0103bc4 <pte2page>
c0104d18:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104d1b:	74 24                	je     c0104d41 <check_pgdir+0x4fc>
c0104d1d:	c7 44 24 0c 4d 6d 10 	movl   $0xc0106d4d,0xc(%esp)
c0104d24:	c0 
c0104d25:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104d2c:	c0 
c0104d2d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0104d34:	00 
c0104d35:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104d3c:	e8 91 bf ff ff       	call   c0100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d44:	8b 00                	mov    (%eax),%eax
c0104d46:	83 e0 04             	and    $0x4,%eax
c0104d49:	85 c0                	test   %eax,%eax
c0104d4b:	74 24                	je     c0104d71 <check_pgdir+0x52c>
c0104d4d:	c7 44 24 0c 9c 6e 10 	movl   $0xc0106e9c,0xc(%esp)
c0104d54:	c0 
c0104d55:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104d5c:	c0 
c0104d5d:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104d64:	00 
c0104d65:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104d6c:	e8 61 bf ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104d71:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d7d:	00 
c0104d7e:	89 04 24             	mov    %eax,(%esp)
c0104d81:	e8 47 f9 ff ff       	call   c01046cd <page_remove>
    assert(page_ref(p1) == 1);
c0104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d89:	89 04 24             	mov    %eax,(%esp)
c0104d8c:	e8 89 ee ff ff       	call   c0103c1a <page_ref>
c0104d91:	83 f8 01             	cmp    $0x1,%eax
c0104d94:	74 24                	je     c0104dba <check_pgdir+0x575>
c0104d96:	c7 44 24 0c 63 6d 10 	movl   $0xc0106d63,0xc(%esp)
c0104d9d:	c0 
c0104d9e:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104da5:	c0 
c0104da6:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0104dad:	00 
c0104dae:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104db5:	e8 18 bf ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104dba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dbd:	89 04 24             	mov    %eax,(%esp)
c0104dc0:	e8 55 ee ff ff       	call   c0103c1a <page_ref>
c0104dc5:	85 c0                	test   %eax,%eax
c0104dc7:	74 24                	je     c0104ded <check_pgdir+0x5a8>
c0104dc9:	c7 44 24 0c 8a 6e 10 	movl   $0xc0106e8a,0xc(%esp)
c0104dd0:	c0 
c0104dd1:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104dd8:	c0 
c0104dd9:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104de0:	00 
c0104de1:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104de8:	e8 e5 be ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104ded:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104df2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104df9:	00 
c0104dfa:	89 04 24             	mov    %eax,(%esp)
c0104dfd:	e8 cb f8 ff ff       	call   c01046cd <page_remove>
    assert(page_ref(p1) == 0);
c0104e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e05:	89 04 24             	mov    %eax,(%esp)
c0104e08:	e8 0d ee ff ff       	call   c0103c1a <page_ref>
c0104e0d:	85 c0                	test   %eax,%eax
c0104e0f:	74 24                	je     c0104e35 <check_pgdir+0x5f0>
c0104e11:	c7 44 24 0c b1 6e 10 	movl   $0xc0106eb1,0xc(%esp)
c0104e18:	c0 
c0104e19:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104e20:	c0 
c0104e21:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0104e28:	00 
c0104e29:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104e30:	e8 9d be ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104e35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e38:	89 04 24             	mov    %eax,(%esp)
c0104e3b:	e8 da ed ff ff       	call   c0103c1a <page_ref>
c0104e40:	85 c0                	test   %eax,%eax
c0104e42:	74 24                	je     c0104e68 <check_pgdir+0x623>
c0104e44:	c7 44 24 0c 8a 6e 10 	movl   $0xc0106e8a,0xc(%esp)
c0104e4b:	c0 
c0104e4c:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104e53:	c0 
c0104e54:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104e5b:	00 
c0104e5c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104e63:	e8 6a be ff ff       	call   c0100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104e68:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e6d:	8b 00                	mov    (%eax),%eax
c0104e6f:	89 04 24             	mov    %eax,(%esp)
c0104e72:	e8 8b ed ff ff       	call   c0103c02 <pde2page>
c0104e77:	89 04 24             	mov    %eax,(%esp)
c0104e7a:	e8 9b ed ff ff       	call   c0103c1a <page_ref>
c0104e7f:	83 f8 01             	cmp    $0x1,%eax
c0104e82:	74 24                	je     c0104ea8 <check_pgdir+0x663>
c0104e84:	c7 44 24 0c c4 6e 10 	movl   $0xc0106ec4,0xc(%esp)
c0104e8b:	c0 
c0104e8c:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104e93:	c0 
c0104e94:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104e9b:	00 
c0104e9c:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104ea3:	e8 2a be ff ff       	call   c0100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104ea8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ead:	8b 00                	mov    (%eax),%eax
c0104eaf:	89 04 24             	mov    %eax,(%esp)
c0104eb2:	e8 4b ed ff ff       	call   c0103c02 <pde2page>
c0104eb7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ebe:	00 
c0104ebf:	89 04 24             	mov    %eax,(%esp)
c0104ec2:	e8 90 ef ff ff       	call   c0103e57 <free_pages>
    boot_pgdir[0] = 0;
c0104ec7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ecc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104ed2:	c7 04 24 eb 6e 10 c0 	movl   $0xc0106eeb,(%esp)
c0104ed9:	e8 6a b4 ff ff       	call   c0100348 <cprintf>
}
c0104ede:	c9                   	leave  
c0104edf:	c3                   	ret    

c0104ee0 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104ee0:	55                   	push   %ebp
c0104ee1:	89 e5                	mov    %esp,%ebp
c0104ee3:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104ee6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104eed:	e9 ca 00 00 00       	jmp    c0104fbc <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104efb:	c1 e8 0c             	shr    $0xc,%eax
c0104efe:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104f01:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104f06:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104f09:	72 23                	jb     c0104f2e <check_boot_pgdir+0x4e>
c0104f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f12:	c7 44 24 08 30 6b 10 	movl   $0xc0106b30,0x8(%esp)
c0104f19:	c0 
c0104f1a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104f21:	00 
c0104f22:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104f29:	e8 a4 bd ff ff       	call   c0100cd2 <__panic>
c0104f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f31:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104f36:	89 c2                	mov    %eax,%edx
c0104f38:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f44:	00 
c0104f45:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f49:	89 04 24             	mov    %eax,(%esp)
c0104f4c:	e8 8a f5 ff ff       	call   c01044db <get_pte>
c0104f51:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104f54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104f58:	75 24                	jne    c0104f7e <check_boot_pgdir+0x9e>
c0104f5a:	c7 44 24 0c 08 6f 10 	movl   $0xc0106f08,0xc(%esp)
c0104f61:	c0 
c0104f62:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104f69:	c0 
c0104f6a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104f71:	00 
c0104f72:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104f79:	e8 54 bd ff ff       	call   c0100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104f7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104f81:	8b 00                	mov    (%eax),%eax
c0104f83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f88:	89 c2                	mov    %eax,%edx
c0104f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f8d:	39 c2                	cmp    %eax,%edx
c0104f8f:	74 24                	je     c0104fb5 <check_boot_pgdir+0xd5>
c0104f91:	c7 44 24 0c 45 6f 10 	movl   $0xc0106f45,0xc(%esp)
c0104f98:	c0 
c0104f99:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0104fa0:	c0 
c0104fa1:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104fa8:	00 
c0104fa9:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0104fb0:	e8 1d bd ff ff       	call   c0100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104fb5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104fbf:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104fc4:	39 c2                	cmp    %eax,%edx
c0104fc6:	0f 82 26 ff ff ff    	jb     c0104ef2 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104fcc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fd1:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104fd6:	8b 00                	mov    (%eax),%eax
c0104fd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104fdd:	89 c2                	mov    %eax,%edx
c0104fdf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fe4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104fe7:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104fee:	77 23                	ja     c0105013 <check_boot_pgdir+0x133>
c0104ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ff3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ff7:	c7 44 24 08 d4 6b 10 	movl   $0xc0106bd4,0x8(%esp)
c0104ffe:	c0 
c0104fff:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105006:	00 
c0105007:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010500e:	e8 bf bc ff ff       	call   c0100cd2 <__panic>
c0105013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105016:	05 00 00 00 40       	add    $0x40000000,%eax
c010501b:	39 c2                	cmp    %eax,%edx
c010501d:	74 24                	je     c0105043 <check_boot_pgdir+0x163>
c010501f:	c7 44 24 0c 5c 6f 10 	movl   $0xc0106f5c,0xc(%esp)
c0105026:	c0 
c0105027:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c010502e:	c0 
c010502f:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0105036:	00 
c0105037:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010503e:	e8 8f bc ff ff       	call   c0100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
c0105043:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105048:	8b 00                	mov    (%eax),%eax
c010504a:	85 c0                	test   %eax,%eax
c010504c:	74 24                	je     c0105072 <check_boot_pgdir+0x192>
c010504e:	c7 44 24 0c 90 6f 10 	movl   $0xc0106f90,0xc(%esp)
c0105055:	c0 
c0105056:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c010505d:	c0 
c010505e:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105065:	00 
c0105066:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010506d:	e8 60 bc ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
c0105072:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105079:	e8 a1 ed ff ff       	call   c0103e1f <alloc_pages>
c010507e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105081:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105086:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010508d:	00 
c010508e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105095:	00 
c0105096:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105099:	89 54 24 04          	mov    %edx,0x4(%esp)
c010509d:	89 04 24             	mov    %eax,(%esp)
c01050a0:	e8 6c f6 ff ff       	call   c0104711 <page_insert>
c01050a5:	85 c0                	test   %eax,%eax
c01050a7:	74 24                	je     c01050cd <check_boot_pgdir+0x1ed>
c01050a9:	c7 44 24 0c a4 6f 10 	movl   $0xc0106fa4,0xc(%esp)
c01050b0:	c0 
c01050b1:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01050b8:	c0 
c01050b9:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01050c0:	00 
c01050c1:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01050c8:	e8 05 bc ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 1);
c01050cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050d0:	89 04 24             	mov    %eax,(%esp)
c01050d3:	e8 42 eb ff ff       	call   c0103c1a <page_ref>
c01050d8:	83 f8 01             	cmp    $0x1,%eax
c01050db:	74 24                	je     c0105101 <check_boot_pgdir+0x221>
c01050dd:	c7 44 24 0c d2 6f 10 	movl   $0xc0106fd2,0xc(%esp)
c01050e4:	c0 
c01050e5:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01050ec:	c0 
c01050ed:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01050f4:	00 
c01050f5:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01050fc:	e8 d1 bb ff ff       	call   c0100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105101:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105106:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010510d:	00 
c010510e:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105115:	00 
c0105116:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105119:	89 54 24 04          	mov    %edx,0x4(%esp)
c010511d:	89 04 24             	mov    %eax,(%esp)
c0105120:	e8 ec f5 ff ff       	call   c0104711 <page_insert>
c0105125:	85 c0                	test   %eax,%eax
c0105127:	74 24                	je     c010514d <check_boot_pgdir+0x26d>
c0105129:	c7 44 24 0c e4 6f 10 	movl   $0xc0106fe4,0xc(%esp)
c0105130:	c0 
c0105131:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0105138:	c0 
c0105139:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105140:	00 
c0105141:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0105148:	e8 85 bb ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 2);
c010514d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105150:	89 04 24             	mov    %eax,(%esp)
c0105153:	e8 c2 ea ff ff       	call   c0103c1a <page_ref>
c0105158:	83 f8 02             	cmp    $0x2,%eax
c010515b:	74 24                	je     c0105181 <check_boot_pgdir+0x2a1>
c010515d:	c7 44 24 0c 1b 70 10 	movl   $0xc010701b,0xc(%esp)
c0105164:	c0 
c0105165:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c010516c:	c0 
c010516d:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0105174:	00 
c0105175:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c010517c:	e8 51 bb ff ff       	call   c0100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
c0105181:	c7 45 dc 2c 70 10 c0 	movl   $0xc010702c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105188:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010518b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010518f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105196:	e8 19 0a 00 00       	call   c0105bb4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010519b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01051a2:	00 
c01051a3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01051aa:	e8 7e 0a 00 00       	call   c0105c2d <strcmp>
c01051af:	85 c0                	test   %eax,%eax
c01051b1:	74 24                	je     c01051d7 <check_boot_pgdir+0x2f7>
c01051b3:	c7 44 24 0c 44 70 10 	movl   $0xc0107044,0xc(%esp)
c01051ba:	c0 
c01051bb:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c01051c2:	c0 
c01051c3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c01051ca:	00 
c01051cb:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c01051d2:	e8 fb ba ff ff       	call   c0100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01051d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051da:	89 04 24             	mov    %eax,(%esp)
c01051dd:	e8 8e e9 ff ff       	call   c0103b70 <page2kva>
c01051e2:	05 00 01 00 00       	add    $0x100,%eax
c01051e7:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01051ea:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01051f1:	e8 66 09 00 00       	call   c0105b5c <strlen>
c01051f6:	85 c0                	test   %eax,%eax
c01051f8:	74 24                	je     c010521e <check_boot_pgdir+0x33e>
c01051fa:	c7 44 24 0c 7c 70 10 	movl   $0xc010707c,0xc(%esp)
c0105201:	c0 
c0105202:	c7 44 24 08 1d 6c 10 	movl   $0xc0106c1d,0x8(%esp)
c0105209:	c0 
c010520a:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0105211:	00 
c0105212:	c7 04 24 f8 6b 10 c0 	movl   $0xc0106bf8,(%esp)
c0105219:	e8 b4 ba ff ff       	call   c0100cd2 <__panic>

    free_page(p);
c010521e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105225:	00 
c0105226:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105229:	89 04 24             	mov    %eax,(%esp)
c010522c:	e8 26 ec ff ff       	call   c0103e57 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105231:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105236:	8b 00                	mov    (%eax),%eax
c0105238:	89 04 24             	mov    %eax,(%esp)
c010523b:	e8 c2 e9 ff ff       	call   c0103c02 <pde2page>
c0105240:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105247:	00 
c0105248:	89 04 24             	mov    %eax,(%esp)
c010524b:	e8 07 ec ff ff       	call   c0103e57 <free_pages>
    boot_pgdir[0] = 0;
c0105250:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0105255:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010525b:	c7 04 24 a0 70 10 c0 	movl   $0xc01070a0,(%esp)
c0105262:	e8 e1 b0 ff ff       	call   c0100348 <cprintf>
}
c0105267:	c9                   	leave  
c0105268:	c3                   	ret    

c0105269 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105269:	55                   	push   %ebp
c010526a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010526c:	8b 45 08             	mov    0x8(%ebp),%eax
c010526f:	83 e0 04             	and    $0x4,%eax
c0105272:	85 c0                	test   %eax,%eax
c0105274:	74 07                	je     c010527d <perm2str+0x14>
c0105276:	b8 75 00 00 00       	mov    $0x75,%eax
c010527b:	eb 05                	jmp    c0105282 <perm2str+0x19>
c010527d:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105282:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0105287:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010528e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105291:	83 e0 02             	and    $0x2,%eax
c0105294:	85 c0                	test   %eax,%eax
c0105296:	74 07                	je     c010529f <perm2str+0x36>
c0105298:	b8 77 00 00 00       	mov    $0x77,%eax
c010529d:	eb 05                	jmp    c01052a4 <perm2str+0x3b>
c010529f:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01052a4:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c01052a9:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c01052b0:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c01052b5:	5d                   	pop    %ebp
c01052b6:	c3                   	ret    

c01052b7 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01052b7:	55                   	push   %ebp
c01052b8:	89 e5                	mov    %esp,%ebp
c01052ba:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01052bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01052c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052c3:	72 0a                	jb     c01052cf <get_pgtable_items+0x18>
        return 0;
c01052c5:	b8 00 00 00 00       	mov    $0x0,%eax
c01052ca:	e9 9c 00 00 00       	jmp    c010536b <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c01052cf:	eb 04                	jmp    c01052d5 <get_pgtable_items+0x1e>
        start ++;
c01052d1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01052d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01052d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052db:	73 18                	jae    c01052f5 <get_pgtable_items+0x3e>
c01052dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01052e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052e7:	8b 45 14             	mov    0x14(%ebp),%eax
c01052ea:	01 d0                	add    %edx,%eax
c01052ec:	8b 00                	mov    (%eax),%eax
c01052ee:	83 e0 01             	and    $0x1,%eax
c01052f1:	85 c0                	test   %eax,%eax
c01052f3:	74 dc                	je     c01052d1 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c01052f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01052f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052fb:	73 69                	jae    c0105366 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01052fd:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105301:	74 08                	je     c010530b <get_pgtable_items+0x54>
            *left_store = start;
c0105303:	8b 45 18             	mov    0x18(%ebp),%eax
c0105306:	8b 55 10             	mov    0x10(%ebp),%edx
c0105309:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010530b:	8b 45 10             	mov    0x10(%ebp),%eax
c010530e:	8d 50 01             	lea    0x1(%eax),%edx
c0105311:	89 55 10             	mov    %edx,0x10(%ebp)
c0105314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010531b:	8b 45 14             	mov    0x14(%ebp),%eax
c010531e:	01 d0                	add    %edx,%eax
c0105320:	8b 00                	mov    (%eax),%eax
c0105322:	83 e0 07             	and    $0x7,%eax
c0105325:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105328:	eb 04                	jmp    c010532e <get_pgtable_items+0x77>
            start ++;
c010532a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c010532e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105331:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105334:	73 1d                	jae    c0105353 <get_pgtable_items+0x9c>
c0105336:	8b 45 10             	mov    0x10(%ebp),%eax
c0105339:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105340:	8b 45 14             	mov    0x14(%ebp),%eax
c0105343:	01 d0                	add    %edx,%eax
c0105345:	8b 00                	mov    (%eax),%eax
c0105347:	83 e0 07             	and    $0x7,%eax
c010534a:	89 c2                	mov    %eax,%edx
c010534c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010534f:	39 c2                	cmp    %eax,%edx
c0105351:	74 d7                	je     c010532a <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105353:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105357:	74 08                	je     c0105361 <get_pgtable_items+0xaa>
            *right_store = start;
c0105359:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010535c:	8b 55 10             	mov    0x10(%ebp),%edx
c010535f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105361:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105364:	eb 05                	jmp    c010536b <get_pgtable_items+0xb4>
    }
    return 0;
c0105366:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010536b:	c9                   	leave  
c010536c:	c3                   	ret    

c010536d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010536d:	55                   	push   %ebp
c010536e:	89 e5                	mov    %esp,%ebp
c0105370:	57                   	push   %edi
c0105371:	56                   	push   %esi
c0105372:	53                   	push   %ebx
c0105373:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105376:	c7 04 24 c0 70 10 c0 	movl   $0xc01070c0,(%esp)
c010537d:	e8 c6 af ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c0105382:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105389:	e9 fa 00 00 00       	jmp    c0105488 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010538e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105391:	89 04 24             	mov    %eax,(%esp)
c0105394:	e8 d0 fe ff ff       	call   c0105269 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105399:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010539c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010539f:	29 d1                	sub    %edx,%ecx
c01053a1:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01053a3:	89 d6                	mov    %edx,%esi
c01053a5:	c1 e6 16             	shl    $0x16,%esi
c01053a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053ab:	89 d3                	mov    %edx,%ebx
c01053ad:	c1 e3 16             	shl    $0x16,%ebx
c01053b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01053b3:	89 d1                	mov    %edx,%ecx
c01053b5:	c1 e1 16             	shl    $0x16,%ecx
c01053b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01053bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01053be:	29 d7                	sub    %edx,%edi
c01053c0:	89 fa                	mov    %edi,%edx
c01053c2:	89 44 24 14          	mov    %eax,0x14(%esp)
c01053c6:	89 74 24 10          	mov    %esi,0x10(%esp)
c01053ca:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01053ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01053d2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053d6:	c7 04 24 f1 70 10 c0 	movl   $0xc01070f1,(%esp)
c01053dd:	e8 66 af ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01053e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053e5:	c1 e0 0a             	shl    $0xa,%eax
c01053e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01053eb:	eb 54                	jmp    c0105441 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01053ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053f0:	89 04 24             	mov    %eax,(%esp)
c01053f3:	e8 71 fe ff ff       	call   c0105269 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01053f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01053fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053fe:	29 d1                	sub    %edx,%ecx
c0105400:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105402:	89 d6                	mov    %edx,%esi
c0105404:	c1 e6 0c             	shl    $0xc,%esi
c0105407:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010540a:	89 d3                	mov    %edx,%ebx
c010540c:	c1 e3 0c             	shl    $0xc,%ebx
c010540f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105412:	c1 e2 0c             	shl    $0xc,%edx
c0105415:	89 d1                	mov    %edx,%ecx
c0105417:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010541a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010541d:	29 d7                	sub    %edx,%edi
c010541f:	89 fa                	mov    %edi,%edx
c0105421:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105425:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105429:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010542d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105431:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105435:	c7 04 24 10 71 10 c0 	movl   $0xc0107110,(%esp)
c010543c:	e8 07 af ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105441:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105446:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105449:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010544c:	89 ce                	mov    %ecx,%esi
c010544e:	c1 e6 0a             	shl    $0xa,%esi
c0105451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105454:	89 cb                	mov    %ecx,%ebx
c0105456:	c1 e3 0a             	shl    $0xa,%ebx
c0105459:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c010545c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105460:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105463:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105467:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010546b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010546f:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105473:	89 1c 24             	mov    %ebx,(%esp)
c0105476:	e8 3c fe ff ff       	call   c01052b7 <get_pgtable_items>
c010547b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010547e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105482:	0f 85 65 ff ff ff    	jne    c01053ed <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105488:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c010548d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105490:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105493:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105497:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c010549a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010549e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01054a2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054a6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01054ad:	00 
c01054ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01054b5:	e8 fd fd ff ff       	call   c01052b7 <get_pgtable_items>
c01054ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01054c1:	0f 85 c7 fe ff ff    	jne    c010538e <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01054c7:	c7 04 24 34 71 10 c0 	movl   $0xc0107134,(%esp)
c01054ce:	e8 75 ae ff ff       	call   c0100348 <cprintf>
}
c01054d3:	83 c4 4c             	add    $0x4c,%esp
c01054d6:	5b                   	pop    %ebx
c01054d7:	5e                   	pop    %esi
c01054d8:	5f                   	pop    %edi
c01054d9:	5d                   	pop    %ebp
c01054da:	c3                   	ret    

c01054db <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01054db:	55                   	push   %ebp
c01054dc:	89 e5                	mov    %esp,%ebp
c01054de:	83 ec 58             	sub    $0x58,%esp
c01054e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01054e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054e7:	8b 45 14             	mov    0x14(%ebp),%eax
c01054ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01054ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01054f9:	8b 45 18             	mov    0x18(%ebp),%eax
c01054fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01054ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105502:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105505:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105508:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010550b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010550e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105511:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105515:	74 1c                	je     c0105533 <printnum+0x58>
c0105517:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010551a:	ba 00 00 00 00       	mov    $0x0,%edx
c010551f:	f7 75 e4             	divl   -0x1c(%ebp)
c0105522:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105525:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105528:	ba 00 00 00 00       	mov    $0x0,%edx
c010552d:	f7 75 e4             	divl   -0x1c(%ebp)
c0105530:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105533:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105536:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105539:	f7 75 e4             	divl   -0x1c(%ebp)
c010553c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010553f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105542:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105545:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105548:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010554b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010554e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105551:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105554:	8b 45 18             	mov    0x18(%ebp),%eax
c0105557:	ba 00 00 00 00       	mov    $0x0,%edx
c010555c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010555f:	77 56                	ja     c01055b7 <printnum+0xdc>
c0105561:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105564:	72 05                	jb     c010556b <printnum+0x90>
c0105566:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105569:	77 4c                	ja     c01055b7 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010556b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010556e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105571:	8b 45 20             	mov    0x20(%ebp),%eax
c0105574:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105578:	89 54 24 14          	mov    %edx,0x14(%esp)
c010557c:	8b 45 18             	mov    0x18(%ebp),%eax
c010557f:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105583:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105586:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105589:	89 44 24 08          	mov    %eax,0x8(%esp)
c010558d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105591:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105594:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105598:	8b 45 08             	mov    0x8(%ebp),%eax
c010559b:	89 04 24             	mov    %eax,(%esp)
c010559e:	e8 38 ff ff ff       	call   c01054db <printnum>
c01055a3:	eb 1c                	jmp    c01055c1 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01055a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01055ac:	8b 45 20             	mov    0x20(%ebp),%eax
c01055af:	89 04 24             	mov    %eax,(%esp)
c01055b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b5:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01055b7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01055bb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01055bf:	7f e4                	jg     c01055a5 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01055c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01055c4:	05 e8 71 10 c0       	add    $0xc01071e8,%eax
c01055c9:	0f b6 00             	movzbl (%eax),%eax
c01055cc:	0f be c0             	movsbl %al,%eax
c01055cf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055d2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055d6:	89 04 24             	mov    %eax,(%esp)
c01055d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055dc:	ff d0                	call   *%eax
}
c01055de:	c9                   	leave  
c01055df:	c3                   	ret    

c01055e0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01055e0:	55                   	push   %ebp
c01055e1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055e3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055e7:	7e 14                	jle    c01055fd <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01055e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ec:	8b 00                	mov    (%eax),%eax
c01055ee:	8d 48 08             	lea    0x8(%eax),%ecx
c01055f1:	8b 55 08             	mov    0x8(%ebp),%edx
c01055f4:	89 0a                	mov    %ecx,(%edx)
c01055f6:	8b 50 04             	mov    0x4(%eax),%edx
c01055f9:	8b 00                	mov    (%eax),%eax
c01055fb:	eb 30                	jmp    c010562d <getuint+0x4d>
    }
    else if (lflag) {
c01055fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105601:	74 16                	je     c0105619 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105603:	8b 45 08             	mov    0x8(%ebp),%eax
c0105606:	8b 00                	mov    (%eax),%eax
c0105608:	8d 48 04             	lea    0x4(%eax),%ecx
c010560b:	8b 55 08             	mov    0x8(%ebp),%edx
c010560e:	89 0a                	mov    %ecx,(%edx)
c0105610:	8b 00                	mov    (%eax),%eax
c0105612:	ba 00 00 00 00       	mov    $0x0,%edx
c0105617:	eb 14                	jmp    c010562d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105619:	8b 45 08             	mov    0x8(%ebp),%eax
c010561c:	8b 00                	mov    (%eax),%eax
c010561e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105621:	8b 55 08             	mov    0x8(%ebp),%edx
c0105624:	89 0a                	mov    %ecx,(%edx)
c0105626:	8b 00                	mov    (%eax),%eax
c0105628:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010562d:	5d                   	pop    %ebp
c010562e:	c3                   	ret    

c010562f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010562f:	55                   	push   %ebp
c0105630:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105632:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105636:	7e 14                	jle    c010564c <getint+0x1d>
        return va_arg(*ap, long long);
c0105638:	8b 45 08             	mov    0x8(%ebp),%eax
c010563b:	8b 00                	mov    (%eax),%eax
c010563d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105640:	8b 55 08             	mov    0x8(%ebp),%edx
c0105643:	89 0a                	mov    %ecx,(%edx)
c0105645:	8b 50 04             	mov    0x4(%eax),%edx
c0105648:	8b 00                	mov    (%eax),%eax
c010564a:	eb 28                	jmp    c0105674 <getint+0x45>
    }
    else if (lflag) {
c010564c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105650:	74 12                	je     c0105664 <getint+0x35>
        return va_arg(*ap, long);
c0105652:	8b 45 08             	mov    0x8(%ebp),%eax
c0105655:	8b 00                	mov    (%eax),%eax
c0105657:	8d 48 04             	lea    0x4(%eax),%ecx
c010565a:	8b 55 08             	mov    0x8(%ebp),%edx
c010565d:	89 0a                	mov    %ecx,(%edx)
c010565f:	8b 00                	mov    (%eax),%eax
c0105661:	99                   	cltd   
c0105662:	eb 10                	jmp    c0105674 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105664:	8b 45 08             	mov    0x8(%ebp),%eax
c0105667:	8b 00                	mov    (%eax),%eax
c0105669:	8d 48 04             	lea    0x4(%eax),%ecx
c010566c:	8b 55 08             	mov    0x8(%ebp),%edx
c010566f:	89 0a                	mov    %ecx,(%edx)
c0105671:	8b 00                	mov    (%eax),%eax
c0105673:	99                   	cltd   
    }
}
c0105674:	5d                   	pop    %ebp
c0105675:	c3                   	ret    

c0105676 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105676:	55                   	push   %ebp
c0105677:	89 e5                	mov    %esp,%ebp
c0105679:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010567c:	8d 45 14             	lea    0x14(%ebp),%eax
c010567f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105685:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105689:	8b 45 10             	mov    0x10(%ebp),%eax
c010568c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105690:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105693:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105697:	8b 45 08             	mov    0x8(%ebp),%eax
c010569a:	89 04 24             	mov    %eax,(%esp)
c010569d:	e8 02 00 00 00       	call   c01056a4 <vprintfmt>
    va_end(ap);
}
c01056a2:	c9                   	leave  
c01056a3:	c3                   	ret    

c01056a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01056a4:	55                   	push   %ebp
c01056a5:	89 e5                	mov    %esp,%ebp
c01056a7:	56                   	push   %esi
c01056a8:	53                   	push   %ebx
c01056a9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01056ac:	eb 18                	jmp    c01056c6 <vprintfmt+0x22>
            if (ch == '\0') {
c01056ae:	85 db                	test   %ebx,%ebx
c01056b0:	75 05                	jne    c01056b7 <vprintfmt+0x13>
                return;
c01056b2:	e9 d1 03 00 00       	jmp    c0105a88 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01056b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056be:	89 1c 24             	mov    %ebx,(%esp)
c01056c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01056c4:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01056c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01056c9:	8d 50 01             	lea    0x1(%eax),%edx
c01056cc:	89 55 10             	mov    %edx,0x10(%ebp)
c01056cf:	0f b6 00             	movzbl (%eax),%eax
c01056d2:	0f b6 d8             	movzbl %al,%ebx
c01056d5:	83 fb 25             	cmp    $0x25,%ebx
c01056d8:	75 d4                	jne    c01056ae <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01056da:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01056de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01056e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01056eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01056f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056f5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01056f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01056fb:	8d 50 01             	lea    0x1(%eax),%edx
c01056fe:	89 55 10             	mov    %edx,0x10(%ebp)
c0105701:	0f b6 00             	movzbl (%eax),%eax
c0105704:	0f b6 d8             	movzbl %al,%ebx
c0105707:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010570a:	83 f8 55             	cmp    $0x55,%eax
c010570d:	0f 87 44 03 00 00    	ja     c0105a57 <vprintfmt+0x3b3>
c0105713:	8b 04 85 0c 72 10 c0 	mov    -0x3fef8df4(,%eax,4),%eax
c010571a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010571c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105720:	eb d6                	jmp    c01056f8 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105722:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105726:	eb d0                	jmp    c01056f8 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105728:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010572f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105732:	89 d0                	mov    %edx,%eax
c0105734:	c1 e0 02             	shl    $0x2,%eax
c0105737:	01 d0                	add    %edx,%eax
c0105739:	01 c0                	add    %eax,%eax
c010573b:	01 d8                	add    %ebx,%eax
c010573d:	83 e8 30             	sub    $0x30,%eax
c0105740:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105743:	8b 45 10             	mov    0x10(%ebp),%eax
c0105746:	0f b6 00             	movzbl (%eax),%eax
c0105749:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010574c:	83 fb 2f             	cmp    $0x2f,%ebx
c010574f:	7e 0b                	jle    c010575c <vprintfmt+0xb8>
c0105751:	83 fb 39             	cmp    $0x39,%ebx
c0105754:	7f 06                	jg     c010575c <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105756:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010575a:	eb d3                	jmp    c010572f <vprintfmt+0x8b>
            goto process_precision;
c010575c:	eb 33                	jmp    c0105791 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010575e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105761:	8d 50 04             	lea    0x4(%eax),%edx
c0105764:	89 55 14             	mov    %edx,0x14(%ebp)
c0105767:	8b 00                	mov    (%eax),%eax
c0105769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010576c:	eb 23                	jmp    c0105791 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010576e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105772:	79 0c                	jns    c0105780 <vprintfmt+0xdc>
                width = 0;
c0105774:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010577b:	e9 78 ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>
c0105780:	e9 73 ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105785:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010578c:	e9 67 ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0105791:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105795:	79 12                	jns    c01057a9 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010579a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010579d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01057a4:	e9 4f ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>
c01057a9:	e9 4a ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01057ae:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01057b2:	e9 41 ff ff ff       	jmp    c01056f8 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01057b7:	8b 45 14             	mov    0x14(%ebp),%eax
c01057ba:	8d 50 04             	lea    0x4(%eax),%edx
c01057bd:	89 55 14             	mov    %edx,0x14(%ebp)
c01057c0:	8b 00                	mov    (%eax),%eax
c01057c2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057c5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057c9:	89 04 24             	mov    %eax,(%esp)
c01057cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01057cf:	ff d0                	call   *%eax
            break;
c01057d1:	e9 ac 02 00 00       	jmp    c0105a82 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01057d6:	8b 45 14             	mov    0x14(%ebp),%eax
c01057d9:	8d 50 04             	lea    0x4(%eax),%edx
c01057dc:	89 55 14             	mov    %edx,0x14(%ebp)
c01057df:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01057e1:	85 db                	test   %ebx,%ebx
c01057e3:	79 02                	jns    c01057e7 <vprintfmt+0x143>
                err = -err;
c01057e5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01057e7:	83 fb 06             	cmp    $0x6,%ebx
c01057ea:	7f 0b                	jg     c01057f7 <vprintfmt+0x153>
c01057ec:	8b 34 9d cc 71 10 c0 	mov    -0x3fef8e34(,%ebx,4),%esi
c01057f3:	85 f6                	test   %esi,%esi
c01057f5:	75 23                	jne    c010581a <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01057f7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01057fb:	c7 44 24 08 f9 71 10 	movl   $0xc01071f9,0x8(%esp)
c0105802:	c0 
c0105803:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105806:	89 44 24 04          	mov    %eax,0x4(%esp)
c010580a:	8b 45 08             	mov    0x8(%ebp),%eax
c010580d:	89 04 24             	mov    %eax,(%esp)
c0105810:	e8 61 fe ff ff       	call   c0105676 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105815:	e9 68 02 00 00       	jmp    c0105a82 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010581a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010581e:	c7 44 24 08 02 72 10 	movl   $0xc0107202,0x8(%esp)
c0105825:	c0 
c0105826:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105829:	89 44 24 04          	mov    %eax,0x4(%esp)
c010582d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105830:	89 04 24             	mov    %eax,(%esp)
c0105833:	e8 3e fe ff ff       	call   c0105676 <printfmt>
            }
            break;
c0105838:	e9 45 02 00 00       	jmp    c0105a82 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010583d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105840:	8d 50 04             	lea    0x4(%eax),%edx
c0105843:	89 55 14             	mov    %edx,0x14(%ebp)
c0105846:	8b 30                	mov    (%eax),%esi
c0105848:	85 f6                	test   %esi,%esi
c010584a:	75 05                	jne    c0105851 <vprintfmt+0x1ad>
                p = "(null)";
c010584c:	be 05 72 10 c0       	mov    $0xc0107205,%esi
            }
            if (width > 0 && padc != '-') {
c0105851:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105855:	7e 3e                	jle    c0105895 <vprintfmt+0x1f1>
c0105857:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010585b:	74 38                	je     c0105895 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010585d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105863:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105867:	89 34 24             	mov    %esi,(%esp)
c010586a:	e8 15 03 00 00       	call   c0105b84 <strnlen>
c010586f:	29 c3                	sub    %eax,%ebx
c0105871:	89 d8                	mov    %ebx,%eax
c0105873:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105876:	eb 17                	jmp    c010588f <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105878:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010587c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010587f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105883:	89 04 24             	mov    %eax,(%esp)
c0105886:	8b 45 08             	mov    0x8(%ebp),%eax
c0105889:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010588b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010588f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105893:	7f e3                	jg     c0105878 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105895:	eb 38                	jmp    c01058cf <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105897:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010589b:	74 1f                	je     c01058bc <vprintfmt+0x218>
c010589d:	83 fb 1f             	cmp    $0x1f,%ebx
c01058a0:	7e 05                	jle    c01058a7 <vprintfmt+0x203>
c01058a2:	83 fb 7e             	cmp    $0x7e,%ebx
c01058a5:	7e 15                	jle    c01058bc <vprintfmt+0x218>
                    putch('?', putdat);
c01058a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058ae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01058b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b8:	ff d0                	call   *%eax
c01058ba:	eb 0f                	jmp    c01058cb <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c3:	89 1c 24             	mov    %ebx,(%esp)
c01058c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01058c9:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01058cb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01058cf:	89 f0                	mov    %esi,%eax
c01058d1:	8d 70 01             	lea    0x1(%eax),%esi
c01058d4:	0f b6 00             	movzbl (%eax),%eax
c01058d7:	0f be d8             	movsbl %al,%ebx
c01058da:	85 db                	test   %ebx,%ebx
c01058dc:	74 10                	je     c01058ee <vprintfmt+0x24a>
c01058de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058e2:	78 b3                	js     c0105897 <vprintfmt+0x1f3>
c01058e4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01058e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01058ec:	79 a9                	jns    c0105897 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01058ee:	eb 17                	jmp    c0105907 <vprintfmt+0x263>
                putch(' ', putdat);
c01058f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058f7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01058fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105901:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105903:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105907:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010590b:	7f e3                	jg     c01058f0 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010590d:	e9 70 01 00 00       	jmp    c0105a82 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105912:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105915:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105919:	8d 45 14             	lea    0x14(%ebp),%eax
c010591c:	89 04 24             	mov    %eax,(%esp)
c010591f:	e8 0b fd ff ff       	call   c010562f <getint>
c0105924:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105927:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010592d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105930:	85 d2                	test   %edx,%edx
c0105932:	79 26                	jns    c010595a <vprintfmt+0x2b6>
                putch('-', putdat);
c0105934:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105937:	89 44 24 04          	mov    %eax,0x4(%esp)
c010593b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105942:	8b 45 08             	mov    0x8(%ebp),%eax
c0105945:	ff d0                	call   *%eax
                num = -(long long)num;
c0105947:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010594a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010594d:	f7 d8                	neg    %eax
c010594f:	83 d2 00             	adc    $0x0,%edx
c0105952:	f7 da                	neg    %edx
c0105954:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105957:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010595a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105961:	e9 a8 00 00 00       	jmp    c0105a0e <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105966:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105969:	89 44 24 04          	mov    %eax,0x4(%esp)
c010596d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105970:	89 04 24             	mov    %eax,(%esp)
c0105973:	e8 68 fc ff ff       	call   c01055e0 <getuint>
c0105978:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010597b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010597e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105985:	e9 84 00 00 00       	jmp    c0105a0e <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010598a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010598d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105991:	8d 45 14             	lea    0x14(%ebp),%eax
c0105994:	89 04 24             	mov    %eax,(%esp)
c0105997:	e8 44 fc ff ff       	call   c01055e0 <getuint>
c010599c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010599f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01059a2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01059a9:	eb 63                	jmp    c0105a0e <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c01059ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01059b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01059bc:	ff d0                	call   *%eax
            putch('x', putdat);
c01059be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01059cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01059cf:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01059d1:	8b 45 14             	mov    0x14(%ebp),%eax
c01059d4:	8d 50 04             	lea    0x4(%eax),%edx
c01059d7:	89 55 14             	mov    %edx,0x14(%ebp)
c01059da:	8b 00                	mov    (%eax),%eax
c01059dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01059e6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01059ed:	eb 1f                	jmp    c0105a0e <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01059ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059f6:	8d 45 14             	lea    0x14(%ebp),%eax
c01059f9:	89 04 24             	mov    %eax,(%esp)
c01059fc:	e8 df fb ff ff       	call   c01055e0 <getuint>
c0105a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a04:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105a07:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105a0e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a15:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105a19:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105a1c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105a20:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105a32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a39:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a3c:	89 04 24             	mov    %eax,(%esp)
c0105a3f:	e8 97 fa ff ff       	call   c01054db <printnum>
            break;
c0105a44:	eb 3c                	jmp    c0105a82 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105a46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a4d:	89 1c 24             	mov    %ebx,(%esp)
c0105a50:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a53:	ff d0                	call   *%eax
            break;
c0105a55:	eb 2b                	jmp    c0105a82 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105a57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a5e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105a65:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a68:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105a6a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a6e:	eb 04                	jmp    c0105a74 <vprintfmt+0x3d0>
c0105a70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105a74:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a77:	83 e8 01             	sub    $0x1,%eax
c0105a7a:	0f b6 00             	movzbl (%eax),%eax
c0105a7d:	3c 25                	cmp    $0x25,%al
c0105a7f:	75 ef                	jne    c0105a70 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105a81:	90                   	nop
        }
    }
c0105a82:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105a83:	e9 3e fc ff ff       	jmp    c01056c6 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105a88:	83 c4 40             	add    $0x40,%esp
c0105a8b:	5b                   	pop    %ebx
c0105a8c:	5e                   	pop    %esi
c0105a8d:	5d                   	pop    %ebp
c0105a8e:	c3                   	ret    

c0105a8f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105a8f:	55                   	push   %ebp
c0105a90:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105a92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a95:	8b 40 08             	mov    0x8(%eax),%eax
c0105a98:	8d 50 01             	lea    0x1(%eax),%edx
c0105a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a9e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa4:	8b 10                	mov    (%eax),%edx
c0105aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aa9:	8b 40 04             	mov    0x4(%eax),%eax
c0105aac:	39 c2                	cmp    %eax,%edx
c0105aae:	73 12                	jae    c0105ac2 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ab3:	8b 00                	mov    (%eax),%eax
c0105ab5:	8d 48 01             	lea    0x1(%eax),%ecx
c0105ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105abb:	89 0a                	mov    %ecx,(%edx)
c0105abd:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ac0:	88 10                	mov    %dl,(%eax)
    }
}
c0105ac2:	5d                   	pop    %ebp
c0105ac3:	c3                   	ret    

c0105ac4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105ac4:	55                   	push   %ebp
c0105ac5:	89 e5                	mov    %esp,%ebp
c0105ac7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105aca:	8d 45 14             	lea    0x14(%ebp),%eax
c0105acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ad7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ada:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ade:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae8:	89 04 24             	mov    %eax,(%esp)
c0105aeb:	e8 08 00 00 00       	call   c0105af8 <vsnprintf>
c0105af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105af6:	c9                   	leave  
c0105af7:	c3                   	ret    

c0105af8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105af8:	55                   	push   %ebp
c0105af9:	89 e5                	mov    %esp,%ebp
c0105afb:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b07:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0d:	01 d0                	add    %edx,%eax
c0105b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105b19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b1d:	74 0a                	je     c0105b29 <vsnprintf+0x31>
c0105b1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b25:	39 c2                	cmp    %eax,%edx
c0105b27:	76 07                	jbe    c0105b30 <vsnprintf+0x38>
        return -E_INVAL;
c0105b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105b2e:	eb 2a                	jmp    c0105b5a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105b30:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b33:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b37:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105b41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b45:	c7 04 24 8f 5a 10 c0 	movl   $0xc0105a8f,(%esp)
c0105b4c:	e8 53 fb ff ff       	call   c01056a4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b54:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b5a:	c9                   	leave  
c0105b5b:	c3                   	ret    

c0105b5c <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105b5c:	55                   	push   %ebp
c0105b5d:	89 e5                	mov    %esp,%ebp
c0105b5f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105b69:	eb 04                	jmp    c0105b6f <strlen+0x13>
        cnt ++;
c0105b6b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105b6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b72:	8d 50 01             	lea    0x1(%eax),%edx
c0105b75:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b78:	0f b6 00             	movzbl (%eax),%eax
c0105b7b:	84 c0                	test   %al,%al
c0105b7d:	75 ec                	jne    c0105b6b <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b82:	c9                   	leave  
c0105b83:	c3                   	ret    

c0105b84 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105b84:	55                   	push   %ebp
c0105b85:	89 e5                	mov    %esp,%ebp
c0105b87:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b8a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b91:	eb 04                	jmp    c0105b97 <strnlen+0x13>
        cnt ++;
c0105b93:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105b9d:	73 10                	jae    c0105baf <strnlen+0x2b>
c0105b9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba2:	8d 50 01             	lea    0x1(%eax),%edx
c0105ba5:	89 55 08             	mov    %edx,0x8(%ebp)
c0105ba8:	0f b6 00             	movzbl (%eax),%eax
c0105bab:	84 c0                	test   %al,%al
c0105bad:	75 e4                	jne    c0105b93 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105baf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105bb2:	c9                   	leave  
c0105bb3:	c3                   	ret    

c0105bb4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105bb4:	55                   	push   %ebp
c0105bb5:	89 e5                	mov    %esp,%ebp
c0105bb7:	57                   	push   %edi
c0105bb8:	56                   	push   %esi
c0105bb9:	83 ec 20             	sub    $0x20,%esp
c0105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bce:	89 d1                	mov    %edx,%ecx
c0105bd0:	89 c2                	mov    %eax,%edx
c0105bd2:	89 ce                	mov    %ecx,%esi
c0105bd4:	89 d7                	mov    %edx,%edi
c0105bd6:	ac                   	lods   %ds:(%esi),%al
c0105bd7:	aa                   	stos   %al,%es:(%edi)
c0105bd8:	84 c0                	test   %al,%al
c0105bda:	75 fa                	jne    c0105bd6 <strcpy+0x22>
c0105bdc:	89 fa                	mov    %edi,%edx
c0105bde:	89 f1                	mov    %esi,%ecx
c0105be0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105be3:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105be6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105bec:	83 c4 20             	add    $0x20,%esp
c0105bef:	5e                   	pop    %esi
c0105bf0:	5f                   	pop    %edi
c0105bf1:	5d                   	pop    %ebp
c0105bf2:	c3                   	ret    

c0105bf3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105bf3:	55                   	push   %ebp
c0105bf4:	89 e5                	mov    %esp,%ebp
c0105bf6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105bff:	eb 21                	jmp    c0105c22 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c04:	0f b6 10             	movzbl (%eax),%edx
c0105c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105c0a:	88 10                	mov    %dl,(%eax)
c0105c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105c0f:	0f b6 00             	movzbl (%eax),%eax
c0105c12:	84 c0                	test   %al,%al
c0105c14:	74 04                	je     c0105c1a <strncpy+0x27>
            src ++;
c0105c16:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105c1a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105c1e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105c22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c26:	75 d9                	jne    c0105c01 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105c28:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105c2b:	c9                   	leave  
c0105c2c:	c3                   	ret    

c0105c2d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105c2d:	55                   	push   %ebp
c0105c2e:	89 e5                	mov    %esp,%ebp
c0105c30:	57                   	push   %edi
c0105c31:	56                   	push   %esi
c0105c32:	83 ec 20             	sub    $0x20,%esp
c0105c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c47:	89 d1                	mov    %edx,%ecx
c0105c49:	89 c2                	mov    %eax,%edx
c0105c4b:	89 ce                	mov    %ecx,%esi
c0105c4d:	89 d7                	mov    %edx,%edi
c0105c4f:	ac                   	lods   %ds:(%esi),%al
c0105c50:	ae                   	scas   %es:(%edi),%al
c0105c51:	75 08                	jne    c0105c5b <strcmp+0x2e>
c0105c53:	84 c0                	test   %al,%al
c0105c55:	75 f8                	jne    c0105c4f <strcmp+0x22>
c0105c57:	31 c0                	xor    %eax,%eax
c0105c59:	eb 04                	jmp    c0105c5f <strcmp+0x32>
c0105c5b:	19 c0                	sbb    %eax,%eax
c0105c5d:	0c 01                	or     $0x1,%al
c0105c5f:	89 fa                	mov    %edi,%edx
c0105c61:	89 f1                	mov    %esi,%ecx
c0105c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c66:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105c6f:	83 c4 20             	add    $0x20,%esp
c0105c72:	5e                   	pop    %esi
c0105c73:	5f                   	pop    %edi
c0105c74:	5d                   	pop    %ebp
c0105c75:	c3                   	ret    

c0105c76 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105c76:	55                   	push   %ebp
c0105c77:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c79:	eb 0c                	jmp    c0105c87 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105c7b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105c7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c83:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105c87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c8b:	74 1a                	je     c0105ca7 <strncmp+0x31>
c0105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c90:	0f b6 00             	movzbl (%eax),%eax
c0105c93:	84 c0                	test   %al,%al
c0105c95:	74 10                	je     c0105ca7 <strncmp+0x31>
c0105c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9a:	0f b6 10             	movzbl (%eax),%edx
c0105c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ca0:	0f b6 00             	movzbl (%eax),%eax
c0105ca3:	38 c2                	cmp    %al,%dl
c0105ca5:	74 d4                	je     c0105c7b <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105ca7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105cab:	74 18                	je     c0105cc5 <strncmp+0x4f>
c0105cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb0:	0f b6 00             	movzbl (%eax),%eax
c0105cb3:	0f b6 d0             	movzbl %al,%edx
c0105cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb9:	0f b6 00             	movzbl (%eax),%eax
c0105cbc:	0f b6 c0             	movzbl %al,%eax
c0105cbf:	29 c2                	sub    %eax,%edx
c0105cc1:	89 d0                	mov    %edx,%eax
c0105cc3:	eb 05                	jmp    c0105cca <strncmp+0x54>
c0105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cca:	5d                   	pop    %ebp
c0105ccb:	c3                   	ret    

c0105ccc <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105ccc:	55                   	push   %ebp
c0105ccd:	89 e5                	mov    %esp,%ebp
c0105ccf:	83 ec 04             	sub    $0x4,%esp
c0105cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cd5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105cd8:	eb 14                	jmp    c0105cee <strchr+0x22>
        if (*s == c) {
c0105cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cdd:	0f b6 00             	movzbl (%eax),%eax
c0105ce0:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105ce3:	75 05                	jne    c0105cea <strchr+0x1e>
            return (char *)s;
c0105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce8:	eb 13                	jmp    c0105cfd <strchr+0x31>
        }
        s ++;
c0105cea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf1:	0f b6 00             	movzbl (%eax),%eax
c0105cf4:	84 c0                	test   %al,%al
c0105cf6:	75 e2                	jne    c0105cda <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cfd:	c9                   	leave  
c0105cfe:	c3                   	ret    

c0105cff <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105cff:	55                   	push   %ebp
c0105d00:	89 e5                	mov    %esp,%ebp
c0105d02:	83 ec 04             	sub    $0x4,%esp
c0105d05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d08:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105d0b:	eb 11                	jmp    c0105d1e <strfind+0x1f>
        if (*s == c) {
c0105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d10:	0f b6 00             	movzbl (%eax),%eax
c0105d13:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105d16:	75 02                	jne    c0105d1a <strfind+0x1b>
            break;
c0105d18:	eb 0e                	jmp    c0105d28 <strfind+0x29>
        }
        s ++;
c0105d1a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105d1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d21:	0f b6 00             	movzbl (%eax),%eax
c0105d24:	84 c0                	test   %al,%al
c0105d26:	75 e5                	jne    c0105d0d <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105d28:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105d2b:	c9                   	leave  
c0105d2c:	c3                   	ret    

c0105d2d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105d2d:	55                   	push   %ebp
c0105d2e:	89 e5                	mov    %esp,%ebp
c0105d30:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105d33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105d3a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d41:	eb 04                	jmp    c0105d47 <strtol+0x1a>
        s ++;
c0105d43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105d47:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d4a:	0f b6 00             	movzbl (%eax),%eax
c0105d4d:	3c 20                	cmp    $0x20,%al
c0105d4f:	74 f2                	je     c0105d43 <strtol+0x16>
c0105d51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d54:	0f b6 00             	movzbl (%eax),%eax
c0105d57:	3c 09                	cmp    $0x9,%al
c0105d59:	74 e8                	je     c0105d43 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5e:	0f b6 00             	movzbl (%eax),%eax
c0105d61:	3c 2b                	cmp    $0x2b,%al
c0105d63:	75 06                	jne    c0105d6b <strtol+0x3e>
        s ++;
c0105d65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d69:	eb 15                	jmp    c0105d80 <strtol+0x53>
    }
    else if (*s == '-') {
c0105d6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d6e:	0f b6 00             	movzbl (%eax),%eax
c0105d71:	3c 2d                	cmp    $0x2d,%al
c0105d73:	75 0b                	jne    c0105d80 <strtol+0x53>
        s ++, neg = 1;
c0105d75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d79:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d84:	74 06                	je     c0105d8c <strtol+0x5f>
c0105d86:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105d8a:	75 24                	jne    c0105db0 <strtol+0x83>
c0105d8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8f:	0f b6 00             	movzbl (%eax),%eax
c0105d92:	3c 30                	cmp    $0x30,%al
c0105d94:	75 1a                	jne    c0105db0 <strtol+0x83>
c0105d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d99:	83 c0 01             	add    $0x1,%eax
c0105d9c:	0f b6 00             	movzbl (%eax),%eax
c0105d9f:	3c 78                	cmp    $0x78,%al
c0105da1:	75 0d                	jne    c0105db0 <strtol+0x83>
        s += 2, base = 16;
c0105da3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105da7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105dae:	eb 2a                	jmp    c0105dda <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105db4:	75 17                	jne    c0105dcd <strtol+0xa0>
c0105db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db9:	0f b6 00             	movzbl (%eax),%eax
c0105dbc:	3c 30                	cmp    $0x30,%al
c0105dbe:	75 0d                	jne    c0105dcd <strtol+0xa0>
        s ++, base = 8;
c0105dc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105dc4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105dcb:	eb 0d                	jmp    c0105dda <strtol+0xad>
    }
    else if (base == 0) {
c0105dcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105dd1:	75 07                	jne    c0105dda <strtol+0xad>
        base = 10;
c0105dd3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105dda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ddd:	0f b6 00             	movzbl (%eax),%eax
c0105de0:	3c 2f                	cmp    $0x2f,%al
c0105de2:	7e 1b                	jle    c0105dff <strtol+0xd2>
c0105de4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de7:	0f b6 00             	movzbl (%eax),%eax
c0105dea:	3c 39                	cmp    $0x39,%al
c0105dec:	7f 11                	jg     c0105dff <strtol+0xd2>
            dig = *s - '0';
c0105dee:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df1:	0f b6 00             	movzbl (%eax),%eax
c0105df4:	0f be c0             	movsbl %al,%eax
c0105df7:	83 e8 30             	sub    $0x30,%eax
c0105dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105dfd:	eb 48                	jmp    c0105e47 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e02:	0f b6 00             	movzbl (%eax),%eax
c0105e05:	3c 60                	cmp    $0x60,%al
c0105e07:	7e 1b                	jle    c0105e24 <strtol+0xf7>
c0105e09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e0c:	0f b6 00             	movzbl (%eax),%eax
c0105e0f:	3c 7a                	cmp    $0x7a,%al
c0105e11:	7f 11                	jg     c0105e24 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e16:	0f b6 00             	movzbl (%eax),%eax
c0105e19:	0f be c0             	movsbl %al,%eax
c0105e1c:	83 e8 57             	sub    $0x57,%eax
c0105e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e22:	eb 23                	jmp    c0105e47 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105e24:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e27:	0f b6 00             	movzbl (%eax),%eax
c0105e2a:	3c 40                	cmp    $0x40,%al
c0105e2c:	7e 3d                	jle    c0105e6b <strtol+0x13e>
c0105e2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e31:	0f b6 00             	movzbl (%eax),%eax
c0105e34:	3c 5a                	cmp    $0x5a,%al
c0105e36:	7f 33                	jg     c0105e6b <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e3b:	0f b6 00             	movzbl (%eax),%eax
c0105e3e:	0f be c0             	movsbl %al,%eax
c0105e41:	83 e8 37             	sub    $0x37,%eax
c0105e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e4a:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105e4d:	7c 02                	jl     c0105e51 <strtol+0x124>
            break;
c0105e4f:	eb 1a                	jmp    c0105e6b <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105e51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e58:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105e5c:	89 c2                	mov    %eax,%edx
c0105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e61:	01 d0                	add    %edx,%eax
c0105e63:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105e66:	e9 6f ff ff ff       	jmp    c0105dda <strtol+0xad>

    if (endptr) {
c0105e6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105e6f:	74 08                	je     c0105e79 <strtol+0x14c>
        *endptr = (char *) s;
c0105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e74:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e77:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105e79:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105e7d:	74 07                	je     c0105e86 <strtol+0x159>
c0105e7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e82:	f7 d8                	neg    %eax
c0105e84:	eb 03                	jmp    c0105e89 <strtol+0x15c>
c0105e86:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105e89:	c9                   	leave  
c0105e8a:	c3                   	ret    

c0105e8b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105e8b:	55                   	push   %ebp
c0105e8c:	89 e5                	mov    %esp,%ebp
c0105e8e:	57                   	push   %edi
c0105e8f:	83 ec 24             	sub    $0x24,%esp
c0105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e95:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105e98:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105e9c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e9f:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105ea2:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105eab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105eae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105eb2:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105eb5:	89 d7                	mov    %edx,%edi
c0105eb7:	f3 aa                	rep stos %al,%es:(%edi)
c0105eb9:	89 fa                	mov    %edi,%edx
c0105ebb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105ebe:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105ec1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105ec4:	83 c4 24             	add    $0x24,%esp
c0105ec7:	5f                   	pop    %edi
c0105ec8:	5d                   	pop    %ebp
c0105ec9:	c3                   	ret    

c0105eca <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105eca:	55                   	push   %ebp
c0105ecb:	89 e5                	mov    %esp,%ebp
c0105ecd:	57                   	push   %edi
c0105ece:	56                   	push   %esi
c0105ecf:	53                   	push   %ebx
c0105ed0:	83 ec 30             	sub    $0x30,%esp
c0105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105edc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105edf:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ee8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105eeb:	73 42                	jae    c0105f2f <memmove+0x65>
c0105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ef0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ef6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105efc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105eff:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f02:	c1 e8 02             	shr    $0x2,%eax
c0105f05:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105f07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f0d:	89 d7                	mov    %edx,%edi
c0105f0f:	89 c6                	mov    %eax,%esi
c0105f11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f13:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105f16:	83 e1 03             	and    $0x3,%ecx
c0105f19:	74 02                	je     c0105f1d <memmove+0x53>
c0105f1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f1d:	89 f0                	mov    %esi,%eax
c0105f1f:	89 fa                	mov    %edi,%edx
c0105f21:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105f24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105f27:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f2d:	eb 36                	jmp    c0105f65 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f32:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f38:	01 c2                	add    %eax,%edx
c0105f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f3d:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f43:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105f46:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f49:	89 c1                	mov    %eax,%ecx
c0105f4b:	89 d8                	mov    %ebx,%eax
c0105f4d:	89 d6                	mov    %edx,%esi
c0105f4f:	89 c7                	mov    %eax,%edi
c0105f51:	fd                   	std    
c0105f52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f54:	fc                   	cld    
c0105f55:	89 f8                	mov    %edi,%eax
c0105f57:	89 f2                	mov    %esi,%edx
c0105f59:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105f5c:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105f5f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105f65:	83 c4 30             	add    $0x30,%esp
c0105f68:	5b                   	pop    %ebx
c0105f69:	5e                   	pop    %esi
c0105f6a:	5f                   	pop    %edi
c0105f6b:	5d                   	pop    %ebp
c0105f6c:	c3                   	ret    

c0105f6d <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105f6d:	55                   	push   %ebp
c0105f6e:	89 e5                	mov    %esp,%ebp
c0105f70:	57                   	push   %edi
c0105f71:	56                   	push   %esi
c0105f72:	83 ec 20             	sub    $0x20,%esp
c0105f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f81:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f8a:	c1 e8 02             	shr    $0x2,%eax
c0105f8d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105f8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f95:	89 d7                	mov    %edx,%edi
c0105f97:	89 c6                	mov    %eax,%esi
c0105f99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f9b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105f9e:	83 e1 03             	and    $0x3,%ecx
c0105fa1:	74 02                	je     c0105fa5 <memcpy+0x38>
c0105fa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105fa5:	89 f0                	mov    %esi,%eax
c0105fa7:	89 fa                	mov    %edi,%edx
c0105fa9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105fac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105faf:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105fb5:	83 c4 20             	add    $0x20,%esp
c0105fb8:	5e                   	pop    %esi
c0105fb9:	5f                   	pop    %edi
c0105fba:	5d                   	pop    %ebp
c0105fbb:	c3                   	ret    

c0105fbc <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105fbc:	55                   	push   %ebp
c0105fbd:	89 e5                	mov    %esp,%ebp
c0105fbf:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fcb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105fce:	eb 30                	jmp    c0106000 <memcmp+0x44>
        if (*s1 != *s2) {
c0105fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fd3:	0f b6 10             	movzbl (%eax),%edx
c0105fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fd9:	0f b6 00             	movzbl (%eax),%eax
c0105fdc:	38 c2                	cmp    %al,%dl
c0105fde:	74 18                	je     c0105ff8 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105fe0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105fe3:	0f b6 00             	movzbl (%eax),%eax
c0105fe6:	0f b6 d0             	movzbl %al,%edx
c0105fe9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105fec:	0f b6 00             	movzbl (%eax),%eax
c0105fef:	0f b6 c0             	movzbl %al,%eax
c0105ff2:	29 c2                	sub    %eax,%edx
c0105ff4:	89 d0                	mov    %edx,%eax
c0105ff6:	eb 1a                	jmp    c0106012 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105ff8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105ffc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0106000:	8b 45 10             	mov    0x10(%ebp),%eax
c0106003:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106006:	89 55 10             	mov    %edx,0x10(%ebp)
c0106009:	85 c0                	test   %eax,%eax
c010600b:	75 c3                	jne    c0105fd0 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010600d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106012:	c9                   	leave  
c0106013:	c3                   	ret    
