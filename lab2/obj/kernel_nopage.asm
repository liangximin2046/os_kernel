
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 29 5e 00 00       	call   105e8b <memset>

    cons_init();                // init the console
  100062:	e8 82 15 00 00       	call   1015e9 <cons_init>

    const char *message = "liangximin os is loading ...";
  100067:	c7 45 f4 20 60 10 00 	movl   $0x106020,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 3d 60 10 00 	movl   $0x10603d,(%esp)
  10007c:	e8 c7 02 00 00       	call   100348 <cprintf>

    print_kerninfo();
  100081:	e8 f6 07 00 00       	call   10087c <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 66 43 00 00       	call   1043f6 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 bd 16 00 00       	call   101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 0f 18 00 00       	call   1018a9 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 00 0d 00 00       	call   100d9f <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 1c 16 00 00       	call   1016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 f8 0b 00 00       	call   100cc0 <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 42 60 10 00 	movl   $0x106042,(%esp)
  100168:	e8 db 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 50 60 10 00 	movl   $0x106050,(%esp)
  100188:	e8 bb 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 5e 60 10 00 	movl   $0x10605e,(%esp)
  1001a8:	e8 9b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 6c 60 10 00 	movl   $0x10606c,(%esp)
  1001c8:	e8 7b 01 00 00       	call   100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 7a 60 10 00 	movl   $0x10607a,(%esp)
  1001e8:	e8 5b 01 00 00       	call   100348 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  1001ff:	5d                   	pop    %ebp
  100200:	c3                   	ret    

00100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100201:	55                   	push   %ebp
  100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100204:	5d                   	pop    %ebp
  100205:	c3                   	ret    

00100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100206:	55                   	push   %ebp
  100207:	89 e5                	mov    %esp,%ebp
  100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020c:	e8 25 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100211:	c7 04 24 88 60 10 00 	movl   $0x106088,(%esp)
  100218:	e8 2b 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_user();
  10021d:	e8 da ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  100222:	e8 0f ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100227:	c7 04 24 a8 60 10 00 	movl   $0x1060a8,(%esp)
  10022e:	e8 15 01 00 00       	call   100348 <cprintf>
    lab1_switch_to_kernel();
  100233:	e8 c9 ff ff ff       	call   100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 f9 fe ff ff       	call   100136 <lab1_print_cur_status>
}
  10023d:	c9                   	leave  
  10023e:	c3                   	ret    

0010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10023f:	55                   	push   %ebp
  100240:	89 e5                	mov    %esp,%ebp
  100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100249:	74 13                	je     10025e <readline+0x1f>
        cprintf("%s", prompt);
  10024b:	8b 45 08             	mov    0x8(%ebp),%eax
  10024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100252:	c7 04 24 c7 60 10 00 	movl   $0x1060c7,(%esp)
  100259:	e8 ea 00 00 00       	call   100348 <cprintf>
    }
    int i = 0, c;
  10025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100265:	e8 66 01 00 00       	call   1003d0 <getchar>
  10026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100271:	79 07                	jns    10027a <readline+0x3b>
            return NULL;
  100273:	b8 00 00 00 00       	mov    $0x0,%eax
  100278:	eb 79                	jmp    1002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10027e:	7e 28                	jle    1002a8 <readline+0x69>
  100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100287:	7f 1f                	jg     1002a8 <readline+0x69>
            cputchar(c);
  100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10028c:	89 04 24             	mov    %eax,(%esp)
  10028f:	e8 da 00 00 00       	call   10036e <cputchar>
            buf[i ++] = c;
  100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100297:	8d 50 01             	lea    0x1(%eax),%edx
  10029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a0:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002a6:	eb 46                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002ac:	75 17                	jne    1002c5 <readline+0x86>
  1002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b2:	7e 11                	jle    1002c5 <readline+0x86>
            cputchar(c);
  1002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002b7:	89 04 24             	mov    %eax,(%esp)
  1002ba:	e8 af 00 00 00       	call   10036e <cputchar>
            i --;
  1002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002c3:	eb 29                	jmp    1002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002c9:	74 06                	je     1002d1 <readline+0x92>
  1002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002cf:	75 1d                	jne    1002ee <readline+0xaf>
            cputchar(c);
  1002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d4:	89 04 24             	mov    %eax,(%esp)
  1002d7:	e8 92 00 00 00       	call   10036e <cputchar>
            buf[i] = '\0';
  1002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002df:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002e7:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002ec:	eb 05                	jmp    1002f3 <readline+0xb4>
        }
    }
  1002ee:	e9 72 ff ff ff       	jmp    100265 <readline+0x26>
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fe:	89 04 24             	mov    %eax,(%esp)
  100301:	e8 0f 13 00 00       	call   101615 <cons_putc>
    (*cnt) ++;
  100306:	8b 45 0c             	mov    0xc(%ebp),%eax
  100309:	8b 00                	mov    (%eax),%eax
  10030b:	8d 50 01             	lea    0x1(%eax),%edx
  10030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100311:	89 10                	mov    %edx,(%eax)
}
  100313:	c9                   	leave  
  100314:	c3                   	ret    

00100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100315:	55                   	push   %ebp
  100316:	89 e5                	mov    %esp,%ebp
  100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100322:	8b 45 0c             	mov    0xc(%ebp),%eax
  100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100329:	8b 45 08             	mov    0x8(%ebp),%eax
  10032c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100333:	89 44 24 04          	mov    %eax,0x4(%esp)
  100337:	c7 04 24 f5 02 10 00 	movl   $0x1002f5,(%esp)
  10033e:	e8 61 53 00 00       	call   1056a4 <vprintfmt>
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10034e:	8d 45 0c             	lea    0xc(%ebp),%eax
  100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100357:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035b:	8b 45 08             	mov    0x8(%ebp),%eax
  10035e:	89 04 24             	mov    %eax,(%esp)
  100361:	e8 af ff ff ff       	call   100315 <vcprintf>
  100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10036c:	c9                   	leave  
  10036d:	c3                   	ret    

0010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10036e:	55                   	push   %ebp
  10036f:	89 e5                	mov    %esp,%ebp
  100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100374:	8b 45 08             	mov    0x8(%ebp),%eax
  100377:	89 04 24             	mov    %eax,(%esp)
  10037a:	e8 96 12 00 00       	call   101615 <cons_putc>
}
  10037f:	c9                   	leave  
  100380:	c3                   	ret    

00100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10038e:	eb 13                	jmp    1003a3 <cputs+0x22>
        cputch(c, &cnt);
  100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100397:	89 54 24 04          	mov    %edx,0x4(%esp)
  10039b:	89 04 24             	mov    %eax,(%esp)
  10039e:	e8 52 ff ff ff       	call   1002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1003a6:	8d 50 01             	lea    0x1(%eax),%edx
  1003a9:	89 55 08             	mov    %edx,0x8(%ebp)
  1003ac:	0f b6 00             	movzbl (%eax),%eax
  1003af:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003b6:	75 d8                	jne    100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003c6:	e8 2a ff ff ff       	call   1002f5 <cputch>
    return cnt;
  1003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003ce:	c9                   	leave  
  1003cf:	c3                   	ret    

001003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003d0:	55                   	push   %ebp
  1003d1:	89 e5                	mov    %esp,%ebp
  1003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003d6:	e8 76 12 00 00       	call   101651 <cons_getc>
  1003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003e2:	74 f2                	je     1003d6 <getchar+0x6>
        /* do nothing */;
    return c;
  1003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003e7:	c9                   	leave  
  1003e8:	c3                   	ret    

001003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003e9:	55                   	push   %ebp
  1003ea:	89 e5                	mov    %esp,%ebp
  1003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003f2:	8b 00                	mov    (%eax),%eax
  1003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1003fa:	8b 00                	mov    (%eax),%eax
  1003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100406:	e9 d2 00 00 00       	jmp    1004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  10040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100411:	01 d0                	add    %edx,%eax
  100413:	89 c2                	mov    %eax,%edx
  100415:	c1 ea 1f             	shr    $0x1f,%edx
  100418:	01 d0                	add    %edx,%eax
  10041a:	d1 f8                	sar    %eax
  10041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100425:	eb 04                	jmp    10042b <stab_binsearch+0x42>
            m --;
  100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100431:	7c 1f                	jl     100452 <stab_binsearch+0x69>
  100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100436:	89 d0                	mov    %edx,%eax
  100438:	01 c0                	add    %eax,%eax
  10043a:	01 d0                	add    %edx,%eax
  10043c:	c1 e0 02             	shl    $0x2,%eax
  10043f:	89 c2                	mov    %eax,%edx
  100441:	8b 45 08             	mov    0x8(%ebp),%eax
  100444:	01 d0                	add    %edx,%eax
  100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10044a:	0f b6 c0             	movzbl %al,%eax
  10044d:	3b 45 14             	cmp    0x14(%ebp),%eax
  100450:	75 d5                	jne    100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100458:	7d 0b                	jge    100465 <stab_binsearch+0x7c>
            l = true_m + 1;
  10045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10045d:	83 c0 01             	add    $0x1,%eax
  100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100463:	eb 78                	jmp    1004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10046f:	89 d0                	mov    %edx,%eax
  100471:	01 c0                	add    %eax,%eax
  100473:	01 d0                	add    %edx,%eax
  100475:	c1 e0 02             	shl    $0x2,%eax
  100478:	89 c2                	mov    %eax,%edx
  10047a:	8b 45 08             	mov    0x8(%ebp),%eax
  10047d:	01 d0                	add    %edx,%eax
  10047f:	8b 40 08             	mov    0x8(%eax),%eax
  100482:	3b 45 18             	cmp    0x18(%ebp),%eax
  100485:	73 13                	jae    10049a <stab_binsearch+0xb1>
            *region_left = m;
  100487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100492:	83 c0 01             	add    $0x1,%eax
  100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100498:	eb 43                	jmp    1004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  10049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049d:	89 d0                	mov    %edx,%eax
  10049f:	01 c0                	add    %eax,%eax
  1004a1:	01 d0                	add    %edx,%eax
  1004a3:	c1 e0 02             	shl    $0x2,%eax
  1004a6:	89 c2                	mov    %eax,%edx
  1004a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ab:	01 d0                	add    %edx,%eax
  1004ad:	8b 40 08             	mov    0x8(%eax),%eax
  1004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004b3:	76 16                	jbe    1004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	83 e8 01             	sub    $0x1,%eax
  1004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004c9:	eb 12                	jmp    1004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d1:	89 10                	mov    %edx,(%eax)
            l = m;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004e3:	0f 8e 22 ff ff ff    	jle    10040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004ed:	75 0f                	jne    1004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004f2:	8b 00                	mov    (%eax),%eax
  1004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  1004fa:	89 10                	mov    %edx,(%eax)
  1004fc:	eb 3f                	jmp    10053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004fe:	8b 45 10             	mov    0x10(%ebp),%eax
  100501:	8b 00                	mov    (%eax),%eax
  100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100506:	eb 04                	jmp    10050c <stab_binsearch+0x123>
  100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  10050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10050f:	8b 00                	mov    (%eax),%eax
  100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100514:	7d 1f                	jge    100535 <stab_binsearch+0x14c>
  100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100519:	89 d0                	mov    %edx,%eax
  10051b:	01 c0                	add    %eax,%eax
  10051d:	01 d0                	add    %edx,%eax
  10051f:	c1 e0 02             	shl    $0x2,%eax
  100522:	89 c2                	mov    %eax,%edx
  100524:	8b 45 08             	mov    0x8(%ebp),%eax
  100527:	01 d0                	add    %edx,%eax
  100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10052d:	0f b6 c0             	movzbl %al,%eax
  100530:	3b 45 14             	cmp    0x14(%ebp),%eax
  100533:	75 d3                	jne    100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100535:	8b 45 0c             	mov    0xc(%ebp),%eax
  100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053b:	89 10                	mov    %edx,(%eax)
    }
}
  10053d:	c9                   	leave  
  10053e:	c3                   	ret    

0010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10053f:	55                   	push   %ebp
  100540:	89 e5                	mov    %esp,%ebp
  100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100545:	8b 45 0c             	mov    0xc(%ebp),%eax
  100548:	c7 00 cc 60 10 00    	movl   $0x1060cc,(%eax)
    info->eip_line = 0;
  10054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	c7 40 08 cc 60 10 00 	movl   $0x1060cc,0x8(%eax)
    info->eip_fn_namelen = 9;
  100562:	8b 45 0c             	mov    0xc(%ebp),%eax
  100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10056c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056f:	8b 55 08             	mov    0x8(%ebp),%edx
  100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100575:	8b 45 0c             	mov    0xc(%ebp),%eax
  100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10057f:	c7 45 f4 64 73 10 00 	movl   $0x107364,-0xc(%ebp)
    stab_end = __STAB_END__;
  100586:	c7 45 f0 78 1f 11 00 	movl   $0x111f78,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10058d:	c7 45 ec 79 1f 11 00 	movl   $0x111f79,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100594:	c7 45 e8 a0 49 11 00 	movl   $0x1149a0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005a1:	76 0d                	jbe    1005b0 <debuginfo_eip+0x71>
  1005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a6:	83 e8 01             	sub    $0x1,%eax
  1005a9:	0f b6 00             	movzbl (%eax),%eax
  1005ac:	84 c0                	test   %al,%al
  1005ae:	74 0a                	je     1005ba <debuginfo_eip+0x7b>
        return -1;
  1005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005b5:	e9 c0 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005c7:	29 c2                	sub    %eax,%edx
  1005c9:	89 d0                	mov    %edx,%eax
  1005cb:	c1 f8 02             	sar    $0x2,%eax
  1005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005d4:	83 e8 01             	sub    $0x1,%eax
  1005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005da:	8b 45 08             	mov    0x8(%ebp),%eax
  1005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005e8:	00 
  1005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005fa:	89 04 24             	mov    %eax,(%esp)
  1005fd:	e8 e7 fd ff ff       	call   1003e9 <stab_binsearch>
    if (lfile == 0)
  100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100605:	85 c0                	test   %eax,%eax
  100607:	75 0a                	jne    100613 <debuginfo_eip+0xd4>
        return -1;
  100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10060e:	e9 67 02 00 00       	jmp    10087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10061f:	8b 45 08             	mov    0x8(%ebp),%eax
  100622:	89 44 24 10          	mov    %eax,0x10(%esp)
  100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10062d:	00 
  10062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100631:	89 44 24 08          	mov    %eax,0x8(%esp)
  100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100638:	89 44 24 04          	mov    %eax,0x4(%esp)
  10063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063f:	89 04 24             	mov    %eax,(%esp)
  100642:	e8 a2 fd ff ff       	call   1003e9 <stab_binsearch>

    if (lfun <= rfun) {
  100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10064d:	39 c2                	cmp    %eax,%edx
  10064f:	7f 7c                	jg     1006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100654:	89 c2                	mov    %eax,%edx
  100656:	89 d0                	mov    %edx,%eax
  100658:	01 c0                	add    %eax,%eax
  10065a:	01 d0                	add    %edx,%eax
  10065c:	c1 e0 02             	shl    $0x2,%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	8b 10                	mov    (%eax),%edx
  100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066e:	29 c1                	sub    %eax,%ecx
  100670:	89 c8                	mov    %ecx,%eax
  100672:	39 c2                	cmp    %eax,%edx
  100674:	73 22                	jae    100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100679:	89 c2                	mov    %eax,%edx
  10067b:	89 d0                	mov    %edx,%eax
  10067d:	01 c0                	add    %eax,%eax
  10067f:	01 d0                	add    %edx,%eax
  100681:	c1 e0 02             	shl    $0x2,%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100689:	01 d0                	add    %edx,%eax
  10068b:	8b 10                	mov    (%eax),%edx
  10068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100690:	01 c2                	add    %eax,%edx
  100692:	8b 45 0c             	mov    0xc(%ebp),%eax
  100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069b:	89 c2                	mov    %eax,%edx
  10069d:	89 d0                	mov    %edx,%eax
  10069f:	01 c0                	add    %eax,%eax
  1006a1:	01 d0                	add    %edx,%eax
  1006a3:	c1 e0 02             	shl    $0x2,%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ab:	01 d0                	add    %edx,%eax
  1006ad:	8b 50 08             	mov    0x8(%eax),%edx
  1006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	8b 40 10             	mov    0x10(%eax),%eax
  1006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006cb:	eb 15                	jmp    1006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d0:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e5:	8b 40 08             	mov    0x8(%eax),%eax
  1006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006ef:	00 
  1006f0:	89 04 24             	mov    %eax,(%esp)
  1006f3:	e8 07 56 00 00       	call   105cff <strfind>
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006fd:	8b 40 08             	mov    0x8(%eax),%eax
  100700:	29 c2                	sub    %eax,%edx
  100702:	8b 45 0c             	mov    0xc(%ebp),%eax
  100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100708:	8b 45 08             	mov    0x8(%ebp),%eax
  10070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100716:	00 
  100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100721:	89 44 24 04          	mov    %eax,0x4(%esp)
  100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100728:	89 04 24             	mov    %eax,(%esp)
  10072b:	e8 b9 fc ff ff       	call   1003e9 <stab_binsearch>
    if (lline <= rline) {
  100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100736:	39 c2                	cmp    %eax,%edx
  100738:	7f 24                	jg     10075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  10073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	89 d0                	mov    %edx,%eax
  100741:	01 c0                	add    %eax,%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	c1 e0 02             	shl    $0x2,%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100753:	0f b7 d0             	movzwl %ax,%edx
  100756:	8b 45 0c             	mov    0xc(%ebp),%eax
  100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10075c:	eb 13                	jmp    100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100763:	e9 12 01 00 00       	jmp    10087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076b:	83 e8 01             	sub    $0x1,%eax
  10076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100777:	39 c2                	cmp    %eax,%edx
  100779:	7c 56                	jl     1007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  10077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077e:	89 c2                	mov    %eax,%edx
  100780:	89 d0                	mov    %edx,%eax
  100782:	01 c0                	add    %eax,%eax
  100784:	01 d0                	add    %edx,%eax
  100786:	c1 e0 02             	shl    $0x2,%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078e:	01 d0                	add    %edx,%eax
  100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100794:	3c 84                	cmp    $0x84,%al
  100796:	74 39                	je     1007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079b:	89 c2                	mov    %eax,%edx
  10079d:	89 d0                	mov    %edx,%eax
  10079f:	01 c0                	add    %eax,%eax
  1007a1:	01 d0                	add    %edx,%eax
  1007a3:	c1 e0 02             	shl    $0x2,%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ab:	01 d0                	add    %edx,%eax
  1007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b1:	3c 64                	cmp    $0x64,%al
  1007b3:	75 b3                	jne    100768 <debuginfo_eip+0x229>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	85 c0                	test   %eax,%eax
  1007cf:	74 97                	je     100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d7:	39 c2                	cmp    %eax,%edx
  1007d9:	7c 46                	jl     100821 <debuginfo_eip+0x2e2>
  1007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007de:	89 c2                	mov    %eax,%edx
  1007e0:	89 d0                	mov    %edx,%eax
  1007e2:	01 c0                	add    %eax,%eax
  1007e4:	01 d0                	add    %edx,%eax
  1007e6:	c1 e0 02             	shl    $0x2,%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ee:	01 d0                	add    %edx,%eax
  1007f0:	8b 10                	mov    (%eax),%edx
  1007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f8:	29 c1                	sub    %eax,%ecx
  1007fa:	89 c8                	mov    %ecx,%eax
  1007fc:	39 c2                	cmp    %eax,%edx
  1007fe:	73 21                	jae    100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100803:	89 c2                	mov    %eax,%edx
  100805:	89 d0                	mov    %edx,%eax
  100807:	01 c0                	add    %eax,%eax
  100809:	01 d0                	add    %edx,%eax
  10080b:	c1 e0 02             	shl    $0x2,%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100813:	01 d0                	add    %edx,%eax
  100815:	8b 10                	mov    (%eax),%edx
  100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10081a:	01 c2                	add    %eax,%edx
  10081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100827:	39 c2                	cmp    %eax,%edx
  100829:	7d 4a                	jge    100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  10082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082e:	83 c0 01             	add    $0x1,%eax
  100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100834:	eb 18                	jmp    10084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100836:	8b 45 0c             	mov    0xc(%ebp),%eax
  100839:	8b 40 14             	mov    0x14(%eax),%eax
  10083c:	8d 50 01             	lea    0x1(%eax),%edx
  10083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100848:	83 c0 01             	add    $0x1,%eax
  10084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100854:	39 c2                	cmp    %eax,%edx
  100856:	7d 1d                	jge    100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10085b:	89 c2                	mov    %eax,%edx
  10085d:	89 d0                	mov    %edx,%eax
  10085f:	01 c0                	add    %eax,%eax
  100861:	01 d0                	add    %edx,%eax
  100863:	c1 e0 02             	shl    $0x2,%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10086b:	01 d0                	add    %edx,%eax
  10086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100871:	3c a0                	cmp    $0xa0,%al
  100873:	74 c1                	je     100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10087a:	c9                   	leave  
  10087b:	c3                   	ret    

0010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10087c:	55                   	push   %ebp
  10087d:	89 e5                	mov    %esp,%ebp
  10087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100882:	c7 04 24 d6 60 10 00 	movl   $0x1060d6,(%esp)
  100889:	e8 ba fa ff ff       	call   100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088e:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100895:	00 
  100896:	c7 04 24 ef 60 10 00 	movl   $0x1060ef,(%esp)
  10089d:	e8 a6 fa ff ff       	call   100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008a2:	c7 44 24 04 14 60 10 	movl   $0x106014,0x4(%esp)
  1008a9:	00 
  1008aa:	c7 04 24 07 61 10 00 	movl   $0x106107,(%esp)
  1008b1:	e8 92 fa ff ff       	call   100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b6:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008bd:	00 
  1008be:	c7 04 24 1f 61 10 00 	movl   $0x10611f,(%esp)
  1008c5:	e8 7e fa ff ff       	call   100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008ca:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  1008d1:	00 
  1008d2:	c7 04 24 37 61 10 00 	movl   $0x106137,(%esp)
  1008d9:	e8 6a fa ff ff       	call   100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008de:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008e9:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008ee:	29 c2                	sub    %eax,%edx
  1008f0:	89 d0                	mov    %edx,%eax
  1008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f8:	85 c0                	test   %eax,%eax
  1008fa:	0f 48 c2             	cmovs  %edx,%eax
  1008fd:	c1 f8 0a             	sar    $0xa,%eax
  100900:	89 44 24 04          	mov    %eax,0x4(%esp)
  100904:	c7 04 24 50 61 10 00 	movl   $0x106150,(%esp)
  10090b:	e8 38 fa ff ff       	call   100348 <cprintf>
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  10091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100922:	8b 45 08             	mov    0x8(%ebp),%eax
  100925:	89 04 24             	mov    %eax,(%esp)
  100928:	e8 12 fc ff ff       	call   10053f <debuginfo_eip>
  10092d:	85 c0                	test   %eax,%eax
  10092f:	74 15                	je     100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100931:	8b 45 08             	mov    0x8(%ebp),%eax
  100934:	89 44 24 04          	mov    %eax,0x4(%esp)
  100938:	c7 04 24 7a 61 10 00 	movl   $0x10617a,(%esp)
  10093f:	e8 04 fa ff ff       	call   100348 <cprintf>
  100944:	eb 6d                	jmp    1009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10094d:	eb 1c                	jmp    10096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100955:	01 d0                	add    %edx,%eax
  100957:	0f b6 00             	movzbl (%eax),%eax
  10095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100963:	01 ca                	add    %ecx,%edx
  100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100971:	7f dc                	jg     10094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097c:	01 d0                	add    %edx,%eax
  10097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100984:	8b 55 08             	mov    0x8(%ebp),%edx
  100987:	89 d1                	mov    %edx,%ecx
  100989:	29 c1                	sub    %eax,%ecx
  10098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  10099f:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a7:	c7 04 24 96 61 10 00 	movl   $0x106196,(%esp)
  1009ae:	e8 95 f9 ff ff       	call   100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009b3:	c9                   	leave  
  1009b4:	c3                   	ret    

001009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b5:	55                   	push   %ebp
  1009b6:	89 e5                	mov    %esp,%ebp
  1009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009bb:	8b 45 04             	mov    0x4(%ebp),%eax
  1009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c4:	c9                   	leave  
  1009c5:	c3                   	ret    

001009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c6:	55                   	push   %ebp
  1009c7:	89 e5                	mov    %esp,%ebp
  1009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cc:	89 e8                	mov    %ebp,%eax
  1009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();
  1009d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009d7:	e8 d9 ff ff ff       	call   1009b5 <read_eip>
  1009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)

	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  1009df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e6:	e9 88 00 00 00       	jmp    100a73 <print_stackframe+0xad>
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
  1009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f9:	c7 04 24 a8 61 10 00 	movl   $0x1061a8,(%esp)
  100a00:	e8 43 f9 ff ff       	call   100348 <cprintf>
		uint32_t *args = (uint32_t *)ebp + 2;
  100a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a08:	83 c0 08             	add    $0x8,%eax
  100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for(j = 0; j < 4; j++)
  100a0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a15:	eb 25                	jmp    100a3c <print_stackframe+0x76>
		{
			cprintf("0x%08x ",args[j]);
  100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a24:	01 d0                	add    %edx,%eax
  100a26:	8b 00                	mov    (%eax),%eax
  100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a2c:	c7 04 24 c4 61 10 00 	movl   $0x1061c4,(%esp)
  100a33:	e8 10 f9 ff ff       	call   100348 <cprintf>
	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
	{
		cprintf("ebp:0x%08x eip:0x%08x args:",ebp,eip);
		uint32_t *args = (uint32_t *)ebp + 2;
		for(j = 0; j < 4; j++)
  100a38:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100a3c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a40:	7e d5                	jle    100a17 <print_stackframe+0x51>
		{
			cprintf("0x%08x ",args[j]);
		}
		cprintf("\n");
  100a42:	c7 04 24 cc 61 10 00 	movl   $0x1061cc,(%esp)
  100a49:	e8 fa f8 ff ff       	call   100348 <cprintf>
		print_debuginfo(eip - 1);
  100a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a51:	83 e8 01             	sub    $0x1,%eax
  100a54:	89 04 24             	mov    %eax,(%esp)
  100a57:	e8 b6 fe ff ff       	call   100912 <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
  100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5f:	83 c0 04             	add    $0x4,%eax
  100a62:	8b 00                	mov    (%eax),%eax
  100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
  100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6a:	8b 00                	mov    (%eax),%eax
  100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();

	int i,j;
	for(i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  100a6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a77:	74 0a                	je     100a83 <print_stackframe+0xbd>
  100a79:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a7d:	0f 8e 68 ff ff ff    	jle    1009eb <print_stackframe+0x25>
		cprintf("\n");
		print_debuginfo(eip - 1);
		eip = ((uint32_t *)ebp)[1];
		ebp = ((uint32_t *)ebp)[0];
	}
}
  100a83:	c9                   	leave  
  100a84:	c3                   	ret    

00100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a85:	55                   	push   %ebp
  100a86:	89 e5                	mov    %esp,%ebp
  100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a92:	eb 0c                	jmp    100aa0 <parse+0x1b>
            *buf ++ = '\0';
  100a94:	8b 45 08             	mov    0x8(%ebp),%eax
  100a97:	8d 50 01             	lea    0x1(%eax),%edx
  100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
  100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa3:	0f b6 00             	movzbl (%eax),%eax
  100aa6:	84 c0                	test   %al,%al
  100aa8:	74 1d                	je     100ac7 <parse+0x42>
  100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  100aad:	0f b6 00             	movzbl (%eax),%eax
  100ab0:	0f be c0             	movsbl %al,%eax
  100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ab7:	c7 04 24 50 62 10 00 	movl   $0x106250,(%esp)
  100abe:	e8 09 52 00 00       	call   105ccc <strchr>
  100ac3:	85 c0                	test   %eax,%eax
  100ac5:	75 cd                	jne    100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  100aca:	0f b6 00             	movzbl (%eax),%eax
  100acd:	84 c0                	test   %al,%al
  100acf:	75 02                	jne    100ad3 <parse+0x4e>
            break;
  100ad1:	eb 67                	jmp    100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ad7:	75 14                	jne    100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ae0:	00 
  100ae1:	c7 04 24 55 62 10 00 	movl   $0x106255,(%esp)
  100ae8:	e8 5b f8 ff ff       	call   100348 <cprintf>
        }
        argv[argc ++] = buf;
  100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af0:	8d 50 01             	lea    0x1(%eax),%edx
  100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b00:	01 c2                	add    %eax,%edx
  100b02:	8b 45 08             	mov    0x8(%ebp),%eax
  100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b07:	eb 04                	jmp    100b0d <parse+0x88>
            buf ++;
  100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b10:	0f b6 00             	movzbl (%eax),%eax
  100b13:	84 c0                	test   %al,%al
  100b15:	74 1d                	je     100b34 <parse+0xaf>
  100b17:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1a:	0f b6 00             	movzbl (%eax),%eax
  100b1d:	0f be c0             	movsbl %al,%eax
  100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b24:	c7 04 24 50 62 10 00 	movl   $0x106250,(%esp)
  100b2b:	e8 9c 51 00 00       	call   105ccc <strchr>
  100b30:	85 c0                	test   %eax,%eax
  100b32:	74 d5                	je     100b09 <parse+0x84>
            buf ++;
        }
    }
  100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b35:	e9 66 ff ff ff       	jmp    100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b3d:	c9                   	leave  
  100b3e:	c3                   	ret    

00100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b3f:	55                   	push   %ebp
  100b40:	89 e5                	mov    %esp,%ebp
  100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4f:	89 04 24             	mov    %eax,(%esp)
  100b52:	e8 2e ff ff ff       	call   100a85 <parse>
  100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b5e:	75 0a                	jne    100b6a <runcmd+0x2b>
        return 0;
  100b60:	b8 00 00 00 00       	mov    $0x0,%eax
  100b65:	e9 85 00 00 00       	jmp    100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b71:	eb 5c                	jmp    100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b79:	89 d0                	mov    %edx,%eax
  100b7b:	01 c0                	add    %eax,%eax
  100b7d:	01 d0                	add    %edx,%eax
  100b7f:	c1 e0 02             	shl    $0x2,%eax
  100b82:	05 00 70 11 00       	add    $0x117000,%eax
  100b87:	8b 00                	mov    (%eax),%eax
  100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b8d:	89 04 24             	mov    %eax,(%esp)
  100b90:	e8 98 50 00 00       	call   105c2d <strcmp>
  100b95:	85 c0                	test   %eax,%eax
  100b97:	75 32                	jne    100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b9c:	89 d0                	mov    %edx,%eax
  100b9e:	01 c0                	add    %eax,%eax
  100ba0:	01 d0                	add    %edx,%eax
  100ba2:	c1 e0 02             	shl    $0x2,%eax
  100ba5:	05 00 70 11 00       	add    $0x117000,%eax
  100baa:	8b 40 08             	mov    0x8(%eax),%eax
  100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bbd:	83 c2 04             	add    $0x4,%edx
  100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bc4:	89 0c 24             	mov    %ecx,(%esp)
  100bc7:	ff d0                	call   *%eax
  100bc9:	eb 24                	jmp    100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bd2:	83 f8 02             	cmp    $0x2,%eax
  100bd5:	76 9c                	jbe    100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bde:	c7 04 24 73 62 10 00 	movl   $0x106273,(%esp)
  100be5:	e8 5e f7 ff ff       	call   100348 <cprintf>
    return 0;
  100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bef:	c9                   	leave  
  100bf0:	c3                   	ret    

00100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bf1:	55                   	push   %ebp
  100bf2:	89 e5                	mov    %esp,%ebp
  100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bf7:	c7 04 24 8c 62 10 00 	movl   $0x10628c,(%esp)
  100bfe:	e8 45 f7 ff ff       	call   100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c03:	c7 04 24 b4 62 10 00 	movl   $0x1062b4,(%esp)
  100c0a:	e8 39 f7 ff ff       	call   100348 <cprintf>

    if (tf != NULL) {
  100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c13:	74 0b                	je     100c20 <kmonitor+0x2f>
        print_trapframe(tf);
  100c15:	8b 45 08             	mov    0x8(%ebp),%eax
  100c18:	89 04 24             	mov    %eax,(%esp)
  100c1b:	e8 41 0e 00 00       	call   101a61 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c20:	c7 04 24 d9 62 10 00 	movl   $0x1062d9,(%esp)
  100c27:	e8 13 f6 ff ff       	call   10023f <readline>
  100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c33:	74 18                	je     100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c35:	8b 45 08             	mov    0x8(%ebp),%eax
  100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c3f:	89 04 24             	mov    %eax,(%esp)
  100c42:	e8 f8 fe ff ff       	call   100b3f <runcmd>
  100c47:	85 c0                	test   %eax,%eax
  100c49:	79 02                	jns    100c4d <kmonitor+0x5c>
                break;
  100c4b:	eb 02                	jmp    100c4f <kmonitor+0x5e>
            }
        }
    }
  100c4d:	eb d1                	jmp    100c20 <kmonitor+0x2f>
}
  100c4f:	c9                   	leave  
  100c50:	c3                   	ret    

00100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c51:	55                   	push   %ebp
  100c52:	89 e5                	mov    %esp,%ebp
  100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c5e:	eb 3f                	jmp    100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c63:	89 d0                	mov    %edx,%eax
  100c65:	01 c0                	add    %eax,%eax
  100c67:	01 d0                	add    %edx,%eax
  100c69:	c1 e0 02             	shl    $0x2,%eax
  100c6c:	05 00 70 11 00       	add    $0x117000,%eax
  100c71:	8b 48 04             	mov    0x4(%eax),%ecx
  100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c77:	89 d0                	mov    %edx,%eax
  100c79:	01 c0                	add    %eax,%eax
  100c7b:	01 d0                	add    %edx,%eax
  100c7d:	c1 e0 02             	shl    $0x2,%eax
  100c80:	05 00 70 11 00       	add    $0x117000,%eax
  100c85:	8b 00                	mov    (%eax),%eax
  100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c8f:	c7 04 24 dd 62 10 00 	movl   $0x1062dd,(%esp)
  100c96:	e8 ad f6 ff ff       	call   100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ca2:	83 f8 02             	cmp    $0x2,%eax
  100ca5:	76 b9                	jbe    100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cac:	c9                   	leave  
  100cad:	c3                   	ret    

00100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cae:	55                   	push   %ebp
  100caf:	89 e5                	mov    %esp,%ebp
  100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cb4:	e8 c3 fb ff ff       	call   10087c <print_kerninfo>
    return 0;
  100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbe:	c9                   	leave  
  100cbf:	c3                   	ret    

00100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cc0:	55                   	push   %ebp
  100cc1:	89 e5                	mov    %esp,%ebp
  100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc6:	e8 fb fc ff ff       	call   1009c6 <print_stackframe>
    return 0;
  100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cd0:	c9                   	leave  
  100cd1:	c3                   	ret    

00100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cd2:	55                   	push   %ebp
  100cd3:	89 e5                	mov    %esp,%ebp
  100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd8:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100cdd:	85 c0                	test   %eax,%eax
  100cdf:	74 02                	je     100ce3 <__panic+0x11>
        goto panic_dead;
  100ce1:	eb 59                	jmp    100d3c <__panic+0x6a>
    }
    is_panic = 1;
  100ce3:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ced:	8d 45 14             	lea    0x14(%ebp),%eax
  100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d01:	c7 04 24 e6 62 10 00 	movl   $0x1062e6,(%esp)
  100d08:	e8 3b f6 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d14:	8b 45 10             	mov    0x10(%ebp),%eax
  100d17:	89 04 24             	mov    %eax,(%esp)
  100d1a:	e8 f6 f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d1f:	c7 04 24 02 63 10 00 	movl   $0x106302,(%esp)
  100d26:	e8 1d f6 ff ff       	call   100348 <cprintf>
    
    cprintf("stack trackback:\n");
  100d2b:	c7 04 24 04 63 10 00 	movl   $0x106304,(%esp)
  100d32:	e8 11 f6 ff ff       	call   100348 <cprintf>
    print_stackframe();
  100d37:	e8 8a fc ff ff       	call   1009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d3c:	e8 85 09 00 00       	call   1016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d48:	e8 a4 fe ff ff       	call   100bf1 <kmonitor>
    }
  100d4d:	eb f2                	jmp    100d41 <__panic+0x6f>

00100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d55:	8d 45 14             	lea    0x14(%ebp),%eax
  100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d62:	8b 45 08             	mov    0x8(%ebp),%eax
  100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d69:	c7 04 24 16 63 10 00 	movl   $0x106316,(%esp)
  100d70:	e8 d3 f5 ff ff       	call   100348 <cprintf>
    vcprintf(fmt, ap);
  100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7f:	89 04 24             	mov    %eax,(%esp)
  100d82:	e8 8e f5 ff ff       	call   100315 <vcprintf>
    cprintf("\n");
  100d87:	c7 04 24 02 63 10 00 	movl   $0x106302,(%esp)
  100d8e:	e8 b5 f5 ff ff       	call   100348 <cprintf>
    va_end(ap);
}
  100d93:	c9                   	leave  
  100d94:	c3                   	ret    

00100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d95:	55                   	push   %ebp
  100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d98:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100d9d:	5d                   	pop    %ebp
  100d9e:	c3                   	ret    

00100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9f:	55                   	push   %ebp
  100da0:	89 e5                	mov    %esp,%ebp
  100da2:	83 ec 28             	sub    $0x28,%esp
  100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
  100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dca:	ee                   	out    %al,(%dx)
  100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dde:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100de8:	c7 04 24 34 63 10 00 	movl   $0x106334,(%esp)
  100def:	e8 54 f5 ff ff       	call   100348 <cprintf>
    pic_enable(IRQ_TIMER);
  100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dfb:	e8 24 09 00 00       	call   101724 <pic_enable>
}
  100e00:	c9                   	leave  
  100e01:	c3                   	ret    

00100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e02:	55                   	push   %ebp
  100e03:	89 e5                	mov    %esp,%ebp
  100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e08:	9c                   	pushf  
  100e09:	58                   	pop    %eax
  100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e10:	25 00 02 00 00       	and    $0x200,%eax
  100e15:	85 c0                	test   %eax,%eax
  100e17:	74 0c                	je     100e25 <__intr_save+0x23>
        intr_disable();
  100e19:	e8 a8 08 00 00       	call   1016c6 <intr_disable>
        return 1;
  100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  100e23:	eb 05                	jmp    100e2a <__intr_save+0x28>
    }
    return 0;
  100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e2a:	c9                   	leave  
  100e2b:	c3                   	ret    

00100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e2c:	55                   	push   %ebp
  100e2d:	89 e5                	mov    %esp,%ebp
  100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e36:	74 05                	je     100e3d <__intr_restore+0x11>
        intr_enable();
  100e38:	e8 83 08 00 00       	call   1016c0 <intr_enable>
    }
}
  100e3d:	c9                   	leave  
  100e3e:	c3                   	ret    

00100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e3f:	55                   	push   %ebp
  100e40:	89 e5                	mov    %esp,%ebp
  100e42:	83 ec 10             	sub    $0x10,%esp
  100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e4f:	89 c2                	mov    %eax,%edx
  100e51:	ec                   	in     (%dx),%al
  100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e5f:	89 c2                	mov    %eax,%edx
  100e61:	ec                   	in     (%dx),%al
  100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6f:	89 c2                	mov    %eax,%edx
  100e71:	ec                   	in     (%dx),%al
  100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e7f:	89 c2                	mov    %eax,%edx
  100e81:	ec                   	in     (%dx),%al
  100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e85:	c9                   	leave  
  100e86:	c3                   	ret    

00100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e87:	55                   	push   %ebp
  100e88:	89 e5                	mov    %esp,%ebp
  100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 00             	movzwl (%eax),%eax
  100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea9:	0f b7 00             	movzwl (%eax),%eax
  100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100eb0:	74 12                	je     100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eb9:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ec0:	b4 03 
  100ec2:	eb 13                	jmp    100ed7 <cga_init+0x50>
    } else {
        *cp = was;
  100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ece:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ed7:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ede:	0f b7 c0             	movzwl %ax,%eax
  100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ef2:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ef9:	83 c0 01             	add    $0x1,%eax
  100efc:	0f b7 c0             	movzwl %ax,%eax
  100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f07:	89 c2                	mov    %eax,%edx
  100f09:	ec                   	in     (%dx),%al
  100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f11:	0f b6 c0             	movzbl %al,%eax
  100f14:	c1 e0 08             	shl    $0x8,%eax
  100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f1a:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f21:	0f b7 c0             	movzwl %ax,%eax
  100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f35:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f3c:	83 c0 01             	add    $0x1,%eax
  100f3f:	0f b7 c0             	movzwl %ax,%eax
  100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f4a:	89 c2                	mov    %eax,%edx
  100f4c:	ec                   	in     (%dx),%al
  100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f54:	0f b6 c0             	movzbl %al,%eax
  100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f5d:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f65:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f6b:	c9                   	leave  
  100f6c:	c3                   	ret    

00100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f6d:	55                   	push   %ebp
  100f6e:	89 e5                	mov    %esp,%ebp
  100f70:	83 ec 48             	sub    $0x48,%esp
  100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f85:	ee                   	out    %al,(%dx)
  100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f98:	ee                   	out    %al,(%dx)
  100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fab:	ee                   	out    %al,(%dx)
  100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fbe:	ee                   	out    %al,(%dx)
  100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fd1:	ee                   	out    %al,(%dx)
  100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
  100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100ff7:	ee                   	out    %al,(%dx)
  100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  101002:	89 c2                	mov    %eax,%edx
  101004:	ec                   	in     (%dx),%al
  101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10100c:	3c ff                	cmp    $0xff,%al
  10100e:	0f 95 c0             	setne  %al
  101011:	0f b6 c0             	movzbl %al,%eax
  101014:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  101023:	89 c2                	mov    %eax,%edx
  101025:	ec                   	in     (%dx),%al
  101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  101033:	89 c2                	mov    %eax,%edx
  101035:	ec                   	in     (%dx),%al
  101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101039:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10103e:	85 c0                	test   %eax,%eax
  101040:	74 0c                	je     10104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101049:	e8 d6 06 00 00       	call   101724 <pic_enable>
    }
}
  10104e:	c9                   	leave  
  10104f:	c3                   	ret    

00101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101050:	55                   	push   %ebp
  101051:	89 e5                	mov    %esp,%ebp
  101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10105d:	eb 09                	jmp    101068 <lpt_putc_sub+0x18>
        delay();
  10105f:	e8 db fd ff ff       	call   100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101072:	89 c2                	mov    %eax,%edx
  101074:	ec                   	in     (%dx),%al
  101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10107c:	84 c0                	test   %al,%al
  10107e:	78 09                	js     101089 <lpt_putc_sub+0x39>
  101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101087:	7e d6                	jle    10105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101089:	8b 45 08             	mov    0x8(%ebp),%eax
  10108c:	0f b6 c0             	movzbl %al,%eax
  10108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010a0:	ee                   	out    %al,(%dx)
  1010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010b3:	ee                   	out    %al,(%dx)
  1010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010c7:	c9                   	leave  
  1010c8:	c3                   	ret    

001010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010c9:	55                   	push   %ebp
  1010ca:	89 e5                	mov    %esp,%ebp
  1010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010d3:	74 0d                	je     1010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1010d8:	89 04 24             	mov    %eax,(%esp)
  1010db:	e8 70 ff ff ff       	call   101050 <lpt_putc_sub>
  1010e0:	eb 24                	jmp    101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e9:	e8 62 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010f5:	e8 56 ff ff ff       	call   101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101101:	e8 4a ff ff ff       	call   101050 <lpt_putc_sub>
    }
}
  101106:	c9                   	leave  
  101107:	c3                   	ret    

00101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101108:	55                   	push   %ebp
  101109:	89 e5                	mov    %esp,%ebp
  10110b:	53                   	push   %ebx
  10110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10110f:	8b 45 08             	mov    0x8(%ebp),%eax
  101112:	b0 00                	mov    $0x0,%al
  101114:	85 c0                	test   %eax,%eax
  101116:	75 07                	jne    10111f <cga_putc+0x17>
        c |= 0x0700;
  101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10111f:	8b 45 08             	mov    0x8(%ebp),%eax
  101122:	0f b6 c0             	movzbl %al,%eax
  101125:	83 f8 0a             	cmp    $0xa,%eax
  101128:	74 4c                	je     101176 <cga_putc+0x6e>
  10112a:	83 f8 0d             	cmp    $0xd,%eax
  10112d:	74 57                	je     101186 <cga_putc+0x7e>
  10112f:	83 f8 08             	cmp    $0x8,%eax
  101132:	0f 85 88 00 00 00    	jne    1011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101138:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10113f:	66 85 c0             	test   %ax,%ax
  101142:	74 30                	je     101174 <cga_putc+0x6c>
            crt_pos --;
  101144:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10114b:	83 e8 01             	sub    $0x1,%eax
  10114e:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101154:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101159:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  101160:	0f b7 d2             	movzwl %dx,%edx
  101163:	01 d2                	add    %edx,%edx
  101165:	01 c2                	add    %eax,%edx
  101167:	8b 45 08             	mov    0x8(%ebp),%eax
  10116a:	b0 00                	mov    $0x0,%al
  10116c:	83 c8 20             	or     $0x20,%eax
  10116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101172:	eb 72                	jmp    1011e6 <cga_putc+0xde>
  101174:	eb 70                	jmp    1011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101176:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10117d:	83 c0 50             	add    $0x50,%eax
  101180:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101186:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  10118d:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  101194:	0f b7 c1             	movzwl %cx,%eax
  101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10119d:	c1 e8 10             	shr    $0x10,%eax
  1011a0:	89 c2                	mov    %eax,%edx
  1011a2:	66 c1 ea 06          	shr    $0x6,%dx
  1011a6:	89 d0                	mov    %edx,%eax
  1011a8:	c1 e0 02             	shl    $0x2,%eax
  1011ab:	01 d0                	add    %edx,%eax
  1011ad:	c1 e0 04             	shl    $0x4,%eax
  1011b0:	29 c1                	sub    %eax,%ecx
  1011b2:	89 ca                	mov    %ecx,%edx
  1011b4:	89 d8                	mov    %ebx,%eax
  1011b6:	29 d0                	sub    %edx,%eax
  1011b8:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011be:	eb 26                	jmp    1011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011c0:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011c6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011cd:	8d 50 01             	lea    0x1(%eax),%edx
  1011d0:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011d7:	0f b7 c0             	movzwl %ax,%eax
  1011da:	01 c0                	add    %eax,%eax
  1011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011df:	8b 45 08             	mov    0x8(%ebp),%eax
  1011e2:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e6:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011f1:	76 5b                	jbe    10124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f3:	a1 40 a4 11 00       	mov    0x11a440,%eax
  1011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fe:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120a:	00 
  10120b:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120f:	89 04 24             	mov    %eax,(%esp)
  101212:	e8 b3 4c 00 00       	call   105eca <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121e:	eb 15                	jmp    101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  101220:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101228:	01 d2                	add    %edx,%edx
  10122a:	01 d0                	add    %edx,%eax
  10122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123c:	7e e2                	jle    101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10123e:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101245:	83 e8 50             	sub    $0x50,%eax
  101248:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124e:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101255:	0f b7 c0             	movzwl %ax,%eax
  101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101269:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101270:	66 c1 e8 08          	shr    $0x8,%ax
  101274:	0f b6 c0             	movzbl %al,%eax
  101277:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  10127e:	83 c2 01             	add    $0x1,%edx
  101281:	0f b7 d2             	movzwl %dx,%edx
  101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101288:	88 45 ed             	mov    %al,-0x13(%ebp)
  10128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101294:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  10129b:	0f b7 c0             	movzwl %ax,%eax
  10129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012af:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012b6:	0f b6 c0             	movzbl %al,%eax
  1012b9:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012c0:	83 c2 01             	add    $0x1,%edx
  1012c3:	0f b7 d2             	movzwl %dx,%edx
  1012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012d5:	ee                   	out    %al,(%dx)
}
  1012d6:	83 c4 34             	add    $0x34,%esp
  1012d9:	5b                   	pop    %ebx
  1012da:	5d                   	pop    %ebp
  1012db:	c3                   	ret    

001012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012dc:	55                   	push   %ebp
  1012dd:	89 e5                	mov    %esp,%ebp
  1012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e9:	eb 09                	jmp    1012f4 <serial_putc_sub+0x18>
        delay();
  1012eb:	e8 4f fb ff ff       	call   100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012fe:	89 c2                	mov    %eax,%edx
  101300:	ec                   	in     (%dx),%al
  101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101308:	0f b6 c0             	movzbl %al,%eax
  10130b:	83 e0 20             	and    $0x20,%eax
  10130e:	85 c0                	test   %eax,%eax
  101310:	75 09                	jne    10131b <serial_putc_sub+0x3f>
  101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101319:	7e d0                	jle    1012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10131b:	8b 45 08             	mov    0x8(%ebp),%eax
  10131e:	0f b6 c0             	movzbl %al,%eax
  101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101332:	ee                   	out    %al,(%dx)
}
  101333:	c9                   	leave  
  101334:	c3                   	ret    

00101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101335:	55                   	push   %ebp
  101336:	89 e5                	mov    %esp,%ebp
  101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10133f:	74 0d                	je     10134e <serial_putc+0x19>
        serial_putc_sub(c);
  101341:	8b 45 08             	mov    0x8(%ebp),%eax
  101344:	89 04 24             	mov    %eax,(%esp)
  101347:	e8 90 ff ff ff       	call   1012dc <serial_putc_sub>
  10134c:	eb 24                	jmp    101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  10134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101355:	e8 82 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub(' ');
  10135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101361:	e8 76 ff ff ff       	call   1012dc <serial_putc_sub>
        serial_putc_sub('\b');
  101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10136d:	e8 6a ff ff ff       	call   1012dc <serial_putc_sub>
    }
}
  101372:	c9                   	leave  
  101373:	c3                   	ret    

00101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101374:	55                   	push   %ebp
  101375:	89 e5                	mov    %esp,%ebp
  101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10137a:	eb 33                	jmp    1013af <cons_intr+0x3b>
        if (c != 0) {
  10137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101380:	74 2d                	je     1013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101382:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101387:	8d 50 01             	lea    0x1(%eax),%edx
  10138a:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101393:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101399:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10139e:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013a3:	75 0a                	jne    1013af <cons_intr+0x3b>
                cons.wpos = 0;
  1013a5:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013af:	8b 45 08             	mov    0x8(%ebp),%eax
  1013b2:	ff d0                	call   *%eax
  1013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013bb:	75 bf                	jne    10137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 10             	sub    $0x10,%esp
  1013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013cf:	89 c2                	mov    %eax,%edx
  1013d1:	ec                   	in     (%dx),%al
  1013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d9:	0f b6 c0             	movzbl %al,%eax
  1013dc:	83 e0 01             	and    $0x1,%eax
  1013df:	85 c0                	test   %eax,%eax
  1013e1:	75 07                	jne    1013ea <serial_proc_data+0x2b>
        return -1;
  1013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e8:	eb 2a                	jmp    101414 <serial_proc_data+0x55>
  1013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013f4:	89 c2                	mov    %eax,%edx
  1013f6:	ec                   	in     (%dx),%al
  1013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013fe:	0f b6 c0             	movzbl %al,%eax
  101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101408:	75 07                	jne    101411 <serial_proc_data+0x52>
        c = '\b';
  10140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101414:	c9                   	leave  
  101415:	c3                   	ret    

00101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101416:	55                   	push   %ebp
  101417:	89 e5                	mov    %esp,%ebp
  101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10141c:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101421:	85 c0                	test   %eax,%eax
  101423:	74 0c                	je     101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101425:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  10142c:	e8 43 ff ff ff       	call   101374 <cons_intr>
    }
}
  101431:	c9                   	leave  
  101432:	c3                   	ret    

00101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101433:	55                   	push   %ebp
  101434:	89 e5                	mov    %esp,%ebp
  101436:	83 ec 38             	sub    $0x38,%esp
  101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  101443:	89 c2                	mov    %eax,%edx
  101445:	ec                   	in     (%dx),%al
  101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10144d:	0f b6 c0             	movzbl %al,%eax
  101450:	83 e0 01             	and    $0x1,%eax
  101453:	85 c0                	test   %eax,%eax
  101455:	75 0a                	jne    101461 <kbd_proc_data+0x2e>
        return -1;
  101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10145c:	e9 59 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
  101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10146b:	89 c2                	mov    %eax,%edx
  10146d:	ec                   	in     (%dx),%al
  10146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10147c:	75 17                	jne    101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10147e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101483:	83 c8 40             	or     $0x40,%eax
  101486:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  10148b:	b8 00 00 00 00       	mov    $0x0,%eax
  101490:	e9 25 01 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101499:	84 c0                	test   %al,%al
  10149b:	79 47                	jns    1014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10149d:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014a2:	83 e0 40             	and    $0x40,%eax
  1014a5:	85 c0                	test   %eax,%eax
  1014a7:	75 09                	jne    1014b2 <kbd_proc_data+0x7f>
  1014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ad:	83 e0 7f             	and    $0x7f,%eax
  1014b0:	eb 04                	jmp    1014b6 <kbd_proc_data+0x83>
  1014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bd:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014c4:	83 c8 40             	or     $0x40,%eax
  1014c7:	0f b6 c0             	movzbl %al,%eax
  1014ca:	f7 d0                	not    %eax
  1014cc:	89 c2                	mov    %eax,%edx
  1014ce:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014d3:	21 d0                	and    %edx,%eax
  1014d5:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014da:	b8 00 00 00 00       	mov    $0x0,%eax
  1014df:	e9 d6 00 00 00       	jmp    1015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014e4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014e9:	83 e0 40             	and    $0x40,%eax
  1014ec:	85 c0                	test   %eax,%eax
  1014ee:	74 11                	je     101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014f4:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f9:	83 e0 bf             	and    $0xffffffbf,%eax
  1014fc:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101505:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  10150c:	0f b6 d0             	movzbl %al,%edx
  10150f:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101514:	09 d0                	or     %edx,%eax
  101516:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  10151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151f:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101526:	0f b6 d0             	movzbl %al,%edx
  101529:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10152e:	31 d0                	xor    %edx,%eax
  101530:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101535:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10153a:	83 e0 03             	and    $0x3,%eax
  10153d:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101548:	01 d0                	add    %edx,%eax
  10154a:	0f b6 00             	movzbl (%eax),%eax
  10154d:	0f b6 c0             	movzbl %al,%eax
  101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101553:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101558:	83 e0 08             	and    $0x8,%eax
  10155b:	85 c0                	test   %eax,%eax
  10155d:	74 22                	je     101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101563:	7e 0c                	jle    101571 <kbd_proc_data+0x13e>
  101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101569:	7f 06                	jg     101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10156f:	eb 10                	jmp    101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101575:	7e 0a                	jle    101581 <kbd_proc_data+0x14e>
  101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10157b:	7f 04                	jg     101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101581:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101586:	f7 d0                	not    %eax
  101588:	83 e0 06             	and    $0x6,%eax
  10158b:	85 c0                	test   %eax,%eax
  10158d:	75 28                	jne    1015b7 <kbd_proc_data+0x184>
  10158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101596:	75 1f                	jne    1015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101598:	c7 04 24 4f 63 10 00 	movl   $0x10634f,(%esp)
  10159f:	e8 a4 ed ff ff       	call   100348 <cprintf>
  1015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015ba:	c9                   	leave  
  1015bb:	c3                   	ret    

001015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015bc:	55                   	push   %ebp
  1015bd:	89 e5                	mov    %esp,%ebp
  1015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015c2:	c7 04 24 33 14 10 00 	movl   $0x101433,(%esp)
  1015c9:	e8 a6 fd ff ff       	call   101374 <cons_intr>
}
  1015ce:	c9                   	leave  
  1015cf:	c3                   	ret    

001015d0 <kbd_init>:

static void
kbd_init(void) {
  1015d0:	55                   	push   %ebp
  1015d1:	89 e5                	mov    %esp,%ebp
  1015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015d6:	e8 e1 ff ff ff       	call   1015bc <kbd_intr>
    pic_enable(IRQ_KBD);
  1015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015e2:	e8 3d 01 00 00       	call   101724 <pic_enable>
}
  1015e7:	c9                   	leave  
  1015e8:	c3                   	ret    

001015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e9:	55                   	push   %ebp
  1015ea:	89 e5                	mov    %esp,%ebp
  1015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015ef:	e8 93 f8 ff ff       	call   100e87 <cga_init>
    serial_init();
  1015f4:	e8 74 f9 ff ff       	call   100f6d <serial_init>
    kbd_init();
  1015f9:	e8 d2 ff ff ff       	call   1015d0 <kbd_init>
    if (!serial_exists) {
  1015fe:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101603:	85 c0                	test   %eax,%eax
  101605:	75 0c                	jne    101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101607:	c7 04 24 5b 63 10 00 	movl   $0x10635b,(%esp)
  10160e:	e8 35 ed ff ff       	call   100348 <cprintf>
    }
}
  101613:	c9                   	leave  
  101614:	c3                   	ret    

00101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101615:	55                   	push   %ebp
  101616:	89 e5                	mov    %esp,%ebp
  101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10161b:	e8 e2 f7 ff ff       	call   100e02 <__intr_save>
  101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101623:	8b 45 08             	mov    0x8(%ebp),%eax
  101626:	89 04 24             	mov    %eax,(%esp)
  101629:	e8 9b fa ff ff       	call   1010c9 <lpt_putc>
        cga_putc(c);
  10162e:	8b 45 08             	mov    0x8(%ebp),%eax
  101631:	89 04 24             	mov    %eax,(%esp)
  101634:	e8 cf fa ff ff       	call   101108 <cga_putc>
        serial_putc(c);
  101639:	8b 45 08             	mov    0x8(%ebp),%eax
  10163c:	89 04 24             	mov    %eax,(%esp)
  10163f:	e8 f1 fc ff ff       	call   101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101647:	89 04 24             	mov    %eax,(%esp)
  10164a:	e8 dd f7 ff ff       	call   100e2c <__intr_restore>
}
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101651:	55                   	push   %ebp
  101652:	89 e5                	mov    %esp,%ebp
  101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10165e:	e8 9f f7 ff ff       	call   100e02 <__intr_save>
  101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101666:	e8 ab fd ff ff       	call   101416 <serial_intr>
        kbd_intr();
  10166b:	e8 4c ff ff ff       	call   1015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101670:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101676:	a1 64 a6 11 00       	mov    0x11a664,%eax
  10167b:	39 c2                	cmp    %eax,%edx
  10167d:	74 31                	je     1016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10167f:	a1 60 a6 11 00       	mov    0x11a660,%eax
  101684:	8d 50 01             	lea    0x1(%eax),%edx
  101687:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  10168d:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  101694:	0f b6 c0             	movzbl %al,%eax
  101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10169a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10169f:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016a4:	75 0a                	jne    1016b0 <cons_getc+0x5f>
                cons.rpos = 0;
  1016a6:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016b3:	89 04 24             	mov    %eax,(%esp)
  1016b6:	e8 71 f7 ff ff       	call   100e2c <__intr_restore>
    return c;
  1016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016be:	c9                   	leave  
  1016bf:	c3                   	ret    

001016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016c0:	55                   	push   %ebp
  1016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016c3:	fb                   	sti    
    sti();
}
  1016c4:	5d                   	pop    %ebp
  1016c5:	c3                   	ret    

001016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016c6:	55                   	push   %ebp
  1016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016c9:	fa                   	cli    
    cli();
}
  1016ca:	5d                   	pop    %ebp
  1016cb:	c3                   	ret    

001016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016cc:	55                   	push   %ebp
  1016cd:	89 e5                	mov    %esp,%ebp
  1016cf:	83 ec 14             	sub    $0x14,%esp
  1016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016dd:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016e3:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016e8:	85 c0                	test   %eax,%eax
  1016ea:	74 36                	je     101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f0:	0f b6 c0             	movzbl %al,%eax
  1016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101709:	66 c1 e8 08          	shr    $0x8,%ax
  10170d:	0f b6 c0             	movzbl %al,%eax
  101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101716:	88 45 f9             	mov    %al,-0x7(%ebp)
  101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101721:	ee                   	out    %al,(%dx)
    }
}
  101722:	c9                   	leave  
  101723:	c3                   	ret    

00101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101724:	55                   	push   %ebp
  101725:	89 e5                	mov    %esp,%ebp
  101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10172a:	8b 45 08             	mov    0x8(%ebp),%eax
  10172d:	ba 01 00 00 00       	mov    $0x1,%edx
  101732:	89 c1                	mov    %eax,%ecx
  101734:	d3 e2                	shl    %cl,%edx
  101736:	89 d0                	mov    %edx,%eax
  101738:	f7 d0                	not    %eax
  10173a:	89 c2                	mov    %eax,%edx
  10173c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101743:	21 d0                	and    %edx,%eax
  101745:	0f b7 c0             	movzwl %ax,%eax
  101748:	89 04 24             	mov    %eax,(%esp)
  10174b:	e8 7c ff ff ff       	call   1016cc <pic_setmask>
}
  101750:	c9                   	leave  
  101751:	c3                   	ret    

00101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101752:	55                   	push   %ebp
  101753:	89 e5                	mov    %esp,%ebp
  101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101758:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10175f:	00 00 00 
  101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  10176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101774:	ee                   	out    %al,(%dx)
  101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101787:	ee                   	out    %al,(%dx)
  101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10179a:	ee                   	out    %al,(%dx)
  10179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017ad:	ee                   	out    %al,(%dx)
  1017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017c0:	ee                   	out    %al,(%dx)
  1017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017d3:	ee                   	out    %al,(%dx)
  1017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017e6:	ee                   	out    %al,(%dx)
  1017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f9:	ee                   	out    %al,(%dx)
  1017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10180c:	ee                   	out    %al,(%dx)
  10180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181f:	ee                   	out    %al,(%dx)
  101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  10182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101832:	ee                   	out    %al,(%dx)
  101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  10183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101845:	ee                   	out    %al,(%dx)
  101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  10184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101858:	ee                   	out    %al,(%dx)
  101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10186c:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101873:	66 83 f8 ff          	cmp    $0xffff,%ax
  101877:	74 12                	je     10188b <pic_init+0x139>
        pic_setmask(irq_mask);
  101879:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  101880:	0f b7 c0             	movzwl %ax,%eax
  101883:	89 04 24             	mov    %eax,(%esp)
  101886:	e8 41 fe ff ff       	call   1016cc <pic_setmask>
    }
}
  10188b:	c9                   	leave  
  10188c:	c3                   	ret    

0010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10188d:	55                   	push   %ebp
  10188e:	89 e5                	mov    %esp,%ebp
  101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10189a:	00 
  10189b:	c7 04 24 80 63 10 00 	movl   $0x106380,(%esp)
  1018a2:	e8 a1 ea ff ff       	call   100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018a7:	c9                   	leave  
  1018a8:	c3                   	ret    

001018a9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018a9:	55                   	push   %ebp
  1018aa:	89 e5                	mov    %esp,%ebp
  1018ac:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  1018af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018b6:	e9 c3 00 00 00       	jmp    10197e <idt_init+0xd5>
	{
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
  1018bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018be:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018c5:	89 c2                	mov    %eax,%edx
  1018c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ca:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  1018d1:	00 
  1018d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d5:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  1018dc:	00 08 00 
  1018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e2:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018e9:	00 
  1018ea:	83 e2 e0             	and    $0xffffffe0,%edx
  1018ed:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  1018f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f7:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  1018fe:	00 
  1018ff:	83 e2 1f             	and    $0x1f,%edx
  101902:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101909:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190c:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101913:	00 
  101914:	83 e2 f0             	and    $0xfffffff0,%edx
  101917:	83 ca 0e             	or     $0xe,%edx
  10191a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101921:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101924:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10192b:	00 
  10192c:	83 e2 ef             	and    $0xffffffef,%edx
  10192f:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101936:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101939:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101940:	00 
  101941:	83 e2 9f             	and    $0xffffff9f,%edx
  101944:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10194b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194e:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101955:	00 
  101956:	83 ca 80             	or     $0xffffff80,%edx
  101959:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101960:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101963:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10196a:	c1 e8 10             	shr    $0x10,%eax
  10196d:	89 c2                	mov    %eax,%edx
  10196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101972:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  101979:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
	int i;
	for(i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  10197a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10197e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101981:	3d ff 00 00 00       	cmp    $0xff,%eax
  101986:	0f 86 2f ff ff ff    	jbe    1018bb <idt_init+0x12>
	{
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
	}
	SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);
  10198c:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101991:	66 a3 48 aa 11 00    	mov    %ax,0x11aa48
  101997:	66 c7 05 4a aa 11 00 	movw   $0x8,0x11aa4a
  10199e:	08 00 
  1019a0:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019a7:	83 e0 e0             	and    $0xffffffe0,%eax
  1019aa:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019af:	0f b6 05 4c aa 11 00 	movzbl 0x11aa4c,%eax
  1019b6:	83 e0 1f             	and    $0x1f,%eax
  1019b9:	a2 4c aa 11 00       	mov    %al,0x11aa4c
  1019be:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019c5:	83 e0 f0             	and    $0xfffffff0,%eax
  1019c8:	83 c8 0e             	or     $0xe,%eax
  1019cb:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019d0:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019d7:	83 e0 ef             	and    $0xffffffef,%eax
  1019da:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019df:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019e6:	83 c8 60             	or     $0x60,%eax
  1019e9:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019ee:	0f b6 05 4d aa 11 00 	movzbl 0x11aa4d,%eax
  1019f5:	83 c8 80             	or     $0xffffff80,%eax
  1019f8:	a2 4d aa 11 00       	mov    %al,0x11aa4d
  1019fd:	a1 c4 77 11 00       	mov    0x1177c4,%eax
  101a02:	c1 e8 10             	shr    $0x10,%eax
  101a05:	66 a3 4e aa 11 00    	mov    %ax,0x11aa4e
  101a0b:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101a12:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a15:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
  101a18:	c9                   	leave  
  101a19:	c3                   	ret    

00101a1a <trapname>:

static const char *
trapname(int trapno) {
  101a1a:	55                   	push   %ebp
  101a1b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a20:	83 f8 13             	cmp    $0x13,%eax
  101a23:	77 0c                	ja     101a31 <trapname+0x17>
        return excnames[trapno];
  101a25:	8b 45 08             	mov    0x8(%ebp),%eax
  101a28:	8b 04 85 e0 66 10 00 	mov    0x1066e0(,%eax,4),%eax
  101a2f:	eb 18                	jmp    101a49 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101a31:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a35:	7e 0d                	jle    101a44 <trapname+0x2a>
  101a37:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a3b:	7f 07                	jg     101a44 <trapname+0x2a>
        return "Hardware Interrupt";
  101a3d:	b8 8a 63 10 00       	mov    $0x10638a,%eax
  101a42:	eb 05                	jmp    101a49 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a44:	b8 9d 63 10 00       	mov    $0x10639d,%eax
}
  101a49:	5d                   	pop    %ebp
  101a4a:	c3                   	ret    

00101a4b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101a4b:	55                   	push   %ebp
  101a4c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a51:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a55:	66 83 f8 08          	cmp    $0x8,%ax
  101a59:	0f 94 c0             	sete   %al
  101a5c:	0f b6 c0             	movzbl %al,%eax
}
  101a5f:	5d                   	pop    %ebp
  101a60:	c3                   	ret    

00101a61 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a61:	55                   	push   %ebp
  101a62:	89 e5                	mov    %esp,%ebp
  101a64:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a67:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6e:	c7 04 24 de 63 10 00 	movl   $0x1063de,(%esp)
  101a75:	e8 ce e8 ff ff       	call   100348 <cprintf>
    print_regs(&tf->tf_regs);
  101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7d:	89 04 24             	mov    %eax,(%esp)
  101a80:	e8 a1 01 00 00       	call   101c26 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a85:	8b 45 08             	mov    0x8(%ebp),%eax
  101a88:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a8c:	0f b7 c0             	movzwl %ax,%eax
  101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a93:	c7 04 24 ef 63 10 00 	movl   $0x1063ef,(%esp)
  101a9a:	e8 a9 e8 ff ff       	call   100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101aa6:	0f b7 c0             	movzwl %ax,%eax
  101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aad:	c7 04 24 02 64 10 00 	movl   $0x106402,(%esp)
  101ab4:	e8 8f e8 ff ff       	call   100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  101abc:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101ac0:	0f b7 c0             	movzwl %ax,%eax
  101ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac7:	c7 04 24 15 64 10 00 	movl   $0x106415,(%esp)
  101ace:	e8 75 e8 ff ff       	call   100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad6:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101ada:	0f b7 c0             	movzwl %ax,%eax
  101add:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae1:	c7 04 24 28 64 10 00 	movl   $0x106428,(%esp)
  101ae8:	e8 5b e8 ff ff       	call   100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101aed:	8b 45 08             	mov    0x8(%ebp),%eax
  101af0:	8b 40 30             	mov    0x30(%eax),%eax
  101af3:	89 04 24             	mov    %eax,(%esp)
  101af6:	e8 1f ff ff ff       	call   101a1a <trapname>
  101afb:	8b 55 08             	mov    0x8(%ebp),%edx
  101afe:	8b 52 30             	mov    0x30(%edx),%edx
  101b01:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b05:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b09:	c7 04 24 3b 64 10 00 	movl   $0x10643b,(%esp)
  101b10:	e8 33 e8 ff ff       	call   100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b15:	8b 45 08             	mov    0x8(%ebp),%eax
  101b18:	8b 40 34             	mov    0x34(%eax),%eax
  101b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b1f:	c7 04 24 4d 64 10 00 	movl   $0x10644d,(%esp)
  101b26:	e8 1d e8 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2e:	8b 40 38             	mov    0x38(%eax),%eax
  101b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b35:	c7 04 24 5c 64 10 00 	movl   $0x10645c,(%esp)
  101b3c:	e8 07 e8 ff ff       	call   100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b48:	0f b7 c0             	movzwl %ax,%eax
  101b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4f:	c7 04 24 6b 64 10 00 	movl   $0x10646b,(%esp)
  101b56:	e8 ed e7 ff ff       	call   100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5e:	8b 40 40             	mov    0x40(%eax),%eax
  101b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b65:	c7 04 24 7e 64 10 00 	movl   $0x10647e,(%esp)
  101b6c:	e8 d7 e7 ff ff       	call   100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b78:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b7f:	eb 3e                	jmp    101bbf <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b81:	8b 45 08             	mov    0x8(%ebp),%eax
  101b84:	8b 50 40             	mov    0x40(%eax),%edx
  101b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b8a:	21 d0                	and    %edx,%eax
  101b8c:	85 c0                	test   %eax,%eax
  101b8e:	74 28                	je     101bb8 <print_trapframe+0x157>
  101b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b93:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b9a:	85 c0                	test   %eax,%eax
  101b9c:	74 1a                	je     101bb8 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ba1:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bac:	c7 04 24 8d 64 10 00 	movl   $0x10648d,(%esp)
  101bb3:	e8 90 e7 ff ff       	call   100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101bb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101bbc:	d1 65 f0             	shll   -0x10(%ebp)
  101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bc2:	83 f8 17             	cmp    $0x17,%eax
  101bc5:	76 ba                	jbe    101b81 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bca:	8b 40 40             	mov    0x40(%eax),%eax
  101bcd:	25 00 30 00 00       	and    $0x3000,%eax
  101bd2:	c1 e8 0c             	shr    $0xc,%eax
  101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd9:	c7 04 24 91 64 10 00 	movl   $0x106491,(%esp)
  101be0:	e8 63 e7 ff ff       	call   100348 <cprintf>

    if (!trap_in_kernel(tf)) {
  101be5:	8b 45 08             	mov    0x8(%ebp),%eax
  101be8:	89 04 24             	mov    %eax,(%esp)
  101beb:	e8 5b fe ff ff       	call   101a4b <trap_in_kernel>
  101bf0:	85 c0                	test   %eax,%eax
  101bf2:	75 30                	jne    101c24 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf7:	8b 40 44             	mov    0x44(%eax),%eax
  101bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfe:	c7 04 24 9a 64 10 00 	movl   $0x10649a,(%esp)
  101c05:	e8 3e e7 ff ff       	call   100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c11:	0f b7 c0             	movzwl %ax,%eax
  101c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c18:	c7 04 24 a9 64 10 00 	movl   $0x1064a9,(%esp)
  101c1f:	e8 24 e7 ff ff       	call   100348 <cprintf>
    }
}
  101c24:	c9                   	leave  
  101c25:	c3                   	ret    

00101c26 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101c26:	55                   	push   %ebp
  101c27:	89 e5                	mov    %esp,%ebp
  101c29:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2f:	8b 00                	mov    (%eax),%eax
  101c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c35:	c7 04 24 bc 64 10 00 	movl   $0x1064bc,(%esp)
  101c3c:	e8 07 e7 ff ff       	call   100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c41:	8b 45 08             	mov    0x8(%ebp),%eax
  101c44:	8b 40 04             	mov    0x4(%eax),%eax
  101c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4b:	c7 04 24 cb 64 10 00 	movl   $0x1064cb,(%esp)
  101c52:	e8 f1 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c57:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5a:	8b 40 08             	mov    0x8(%eax),%eax
  101c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c61:	c7 04 24 da 64 10 00 	movl   $0x1064da,(%esp)
  101c68:	e8 db e6 ff ff       	call   100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101c70:	8b 40 0c             	mov    0xc(%eax),%eax
  101c73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c77:	c7 04 24 e9 64 10 00 	movl   $0x1064e9,(%esp)
  101c7e:	e8 c5 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c83:	8b 45 08             	mov    0x8(%ebp),%eax
  101c86:	8b 40 10             	mov    0x10(%eax),%eax
  101c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c8d:	c7 04 24 f8 64 10 00 	movl   $0x1064f8,(%esp)
  101c94:	e8 af e6 ff ff       	call   100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c99:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9c:	8b 40 14             	mov    0x14(%eax),%eax
  101c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca3:	c7 04 24 07 65 10 00 	movl   $0x106507,(%esp)
  101caa:	e8 99 e6 ff ff       	call   100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101caf:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb2:	8b 40 18             	mov    0x18(%eax),%eax
  101cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cb9:	c7 04 24 16 65 10 00 	movl   $0x106516,(%esp)
  101cc0:	e8 83 e6 ff ff       	call   100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc8:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccf:	c7 04 24 25 65 10 00 	movl   $0x106525,(%esp)
  101cd6:	e8 6d e6 ff ff       	call   100348 <cprintf>
}
  101cdb:	c9                   	leave  
  101cdc:	c3                   	ret    

00101cdd <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101cdd:	55                   	push   %ebp
  101cde:	89 e5                	mov    %esp,%ebp
  101ce0:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce6:	8b 40 30             	mov    0x30(%eax),%eax
  101ce9:	83 f8 2f             	cmp    $0x2f,%eax
  101cec:	77 21                	ja     101d0f <trap_dispatch+0x32>
  101cee:	83 f8 2e             	cmp    $0x2e,%eax
  101cf1:	0f 83 04 01 00 00    	jae    101dfb <trap_dispatch+0x11e>
  101cf7:	83 f8 21             	cmp    $0x21,%eax
  101cfa:	0f 84 81 00 00 00    	je     101d81 <trap_dispatch+0xa4>
  101d00:	83 f8 24             	cmp    $0x24,%eax
  101d03:	74 56                	je     101d5b <trap_dispatch+0x7e>
  101d05:	83 f8 20             	cmp    $0x20,%eax
  101d08:	74 16                	je     101d20 <trap_dispatch+0x43>
  101d0a:	e9 b4 00 00 00       	jmp    101dc3 <trap_dispatch+0xe6>
  101d0f:	83 e8 78             	sub    $0x78,%eax
  101d12:	83 f8 01             	cmp    $0x1,%eax
  101d15:	0f 87 a8 00 00 00    	ja     101dc3 <trap_dispatch+0xe6>
  101d1b:	e9 87 00 00 00       	jmp    101da7 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
		++ticks;
  101d20:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101d25:	83 c0 01             	add    $0x1,%eax
  101d28:	a3 0c af 11 00       	mov    %eax,0x11af0c
		if(ticks % TICK_NUM == 0)
  101d2d:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101d33:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d38:	89 c8                	mov    %ecx,%eax
  101d3a:	f7 e2                	mul    %edx
  101d3c:	89 d0                	mov    %edx,%eax
  101d3e:	c1 e8 05             	shr    $0x5,%eax
  101d41:	6b c0 64             	imul   $0x64,%eax,%eax
  101d44:	29 c1                	sub    %eax,%ecx
  101d46:	89 c8                	mov    %ecx,%eax
  101d48:	85 c0                	test   %eax,%eax
  101d4a:	75 0a                	jne    101d56 <trap_dispatch+0x79>
		{
			print_ticks();
  101d4c:	e8 3c fb ff ff       	call   10188d <print_ticks>
		}
        break;
  101d51:	e9 a6 00 00 00       	jmp    101dfc <trap_dispatch+0x11f>
  101d56:	e9 a1 00 00 00       	jmp    101dfc <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d5b:	e8 f1 f8 ff ff       	call   101651 <cons_getc>
  101d60:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d63:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d67:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d73:	c7 04 24 34 65 10 00 	movl   $0x106534,(%esp)
  101d7a:	e8 c9 e5 ff ff       	call   100348 <cprintf>
        break;
  101d7f:	eb 7b                	jmp    101dfc <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d81:	e8 cb f8 ff ff       	call   101651 <cons_getc>
  101d86:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d89:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d8d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d91:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d99:	c7 04 24 46 65 10 00 	movl   $0x106546,(%esp)
  101da0:	e8 a3 e5 ff ff       	call   100348 <cprintf>
        break;
  101da5:	eb 55                	jmp    101dfc <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101da7:	c7 44 24 08 55 65 10 	movl   $0x106555,0x8(%esp)
  101dae:	00 
  101daf:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
  101db6:	00 
  101db7:	c7 04 24 65 65 10 00 	movl   $0x106565,(%esp)
  101dbe:	e8 0f ef ff ff       	call   100cd2 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dca:	0f b7 c0             	movzwl %ax,%eax
  101dcd:	83 e0 03             	and    $0x3,%eax
  101dd0:	85 c0                	test   %eax,%eax
  101dd2:	75 28                	jne    101dfc <trap_dispatch+0x11f>
            print_trapframe(tf);
  101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd7:	89 04 24             	mov    %eax,(%esp)
  101dda:	e8 82 fc ff ff       	call   101a61 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101ddf:	c7 44 24 08 76 65 10 	movl   $0x106576,0x8(%esp)
  101de6:	00 
  101de7:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
  101dee:	00 
  101def:	c7 04 24 65 65 10 00 	movl   $0x106565,(%esp)
  101df6:	e8 d7 ee ff ff       	call   100cd2 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101dfb:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101dfc:	c9                   	leave  
  101dfd:	c3                   	ret    

00101dfe <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101dfe:	55                   	push   %ebp
  101dff:	89 e5                	mov    %esp,%ebp
  101e01:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e04:	8b 45 08             	mov    0x8(%ebp),%eax
  101e07:	89 04 24             	mov    %eax,(%esp)
  101e0a:	e8 ce fe ff ff       	call   101cdd <trap_dispatch>
}
  101e0f:	c9                   	leave  
  101e10:	c3                   	ret    

00101e11 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e11:	1e                   	push   %ds
    pushl %es
  101e12:	06                   	push   %es
    pushl %fs
  101e13:	0f a0                	push   %fs
    pushl %gs
  101e15:	0f a8                	push   %gs
    pushal
  101e17:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e18:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e1d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e1f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e21:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e22:	e8 d7 ff ff ff       	call   101dfe <trap>

    # pop the pushed stack pointer
    popl %esp
  101e27:	5c                   	pop    %esp

00101e28 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101e28:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101e29:	0f a9                	pop    %gs
    popl %fs
  101e2b:	0f a1                	pop    %fs
    popl %es
  101e2d:	07                   	pop    %es
    popl %ds
  101e2e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101e2f:	83 c4 08             	add    $0x8,%esp
    iret
  101e32:	cf                   	iret   

00101e33 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $0
  101e35:	6a 00                	push   $0x0
  jmp __alltraps
  101e37:	e9 d5 ff ff ff       	jmp    101e11 <__alltraps>

00101e3c <vector1>:
.globl vector1
vector1:
  pushl $0
  101e3c:	6a 00                	push   $0x0
  pushl $1
  101e3e:	6a 01                	push   $0x1
  jmp __alltraps
  101e40:	e9 cc ff ff ff       	jmp    101e11 <__alltraps>

00101e45 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e45:	6a 00                	push   $0x0
  pushl $2
  101e47:	6a 02                	push   $0x2
  jmp __alltraps
  101e49:	e9 c3 ff ff ff       	jmp    101e11 <__alltraps>

00101e4e <vector3>:
.globl vector3
vector3:
  pushl $0
  101e4e:	6a 00                	push   $0x0
  pushl $3
  101e50:	6a 03                	push   $0x3
  jmp __alltraps
  101e52:	e9 ba ff ff ff       	jmp    101e11 <__alltraps>

00101e57 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e57:	6a 00                	push   $0x0
  pushl $4
  101e59:	6a 04                	push   $0x4
  jmp __alltraps
  101e5b:	e9 b1 ff ff ff       	jmp    101e11 <__alltraps>

00101e60 <vector5>:
.globl vector5
vector5:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $5
  101e62:	6a 05                	push   $0x5
  jmp __alltraps
  101e64:	e9 a8 ff ff ff       	jmp    101e11 <__alltraps>

00101e69 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $6
  101e6b:	6a 06                	push   $0x6
  jmp __alltraps
  101e6d:	e9 9f ff ff ff       	jmp    101e11 <__alltraps>

00101e72 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e72:	6a 00                	push   $0x0
  pushl $7
  101e74:	6a 07                	push   $0x7
  jmp __alltraps
  101e76:	e9 96 ff ff ff       	jmp    101e11 <__alltraps>

00101e7b <vector8>:
.globl vector8
vector8:
  pushl $8
  101e7b:	6a 08                	push   $0x8
  jmp __alltraps
  101e7d:	e9 8f ff ff ff       	jmp    101e11 <__alltraps>

00101e82 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e82:	6a 00                	push   $0x0
  pushl $9
  101e84:	6a 09                	push   $0x9
  jmp __alltraps
  101e86:	e9 86 ff ff ff       	jmp    101e11 <__alltraps>

00101e8b <vector10>:
.globl vector10
vector10:
  pushl $10
  101e8b:	6a 0a                	push   $0xa
  jmp __alltraps
  101e8d:	e9 7f ff ff ff       	jmp    101e11 <__alltraps>

00101e92 <vector11>:
.globl vector11
vector11:
  pushl $11
  101e92:	6a 0b                	push   $0xb
  jmp __alltraps
  101e94:	e9 78 ff ff ff       	jmp    101e11 <__alltraps>

00101e99 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e99:	6a 0c                	push   $0xc
  jmp __alltraps
  101e9b:	e9 71 ff ff ff       	jmp    101e11 <__alltraps>

00101ea0 <vector13>:
.globl vector13
vector13:
  pushl $13
  101ea0:	6a 0d                	push   $0xd
  jmp __alltraps
  101ea2:	e9 6a ff ff ff       	jmp    101e11 <__alltraps>

00101ea7 <vector14>:
.globl vector14
vector14:
  pushl $14
  101ea7:	6a 0e                	push   $0xe
  jmp __alltraps
  101ea9:	e9 63 ff ff ff       	jmp    101e11 <__alltraps>

00101eae <vector15>:
.globl vector15
vector15:
  pushl $0
  101eae:	6a 00                	push   $0x0
  pushl $15
  101eb0:	6a 0f                	push   $0xf
  jmp __alltraps
  101eb2:	e9 5a ff ff ff       	jmp    101e11 <__alltraps>

00101eb7 <vector16>:
.globl vector16
vector16:
  pushl $0
  101eb7:	6a 00                	push   $0x0
  pushl $16
  101eb9:	6a 10                	push   $0x10
  jmp __alltraps
  101ebb:	e9 51 ff ff ff       	jmp    101e11 <__alltraps>

00101ec0 <vector17>:
.globl vector17
vector17:
  pushl $17
  101ec0:	6a 11                	push   $0x11
  jmp __alltraps
  101ec2:	e9 4a ff ff ff       	jmp    101e11 <__alltraps>

00101ec7 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ec7:	6a 00                	push   $0x0
  pushl $18
  101ec9:	6a 12                	push   $0x12
  jmp __alltraps
  101ecb:	e9 41 ff ff ff       	jmp    101e11 <__alltraps>

00101ed0 <vector19>:
.globl vector19
vector19:
  pushl $0
  101ed0:	6a 00                	push   $0x0
  pushl $19
  101ed2:	6a 13                	push   $0x13
  jmp __alltraps
  101ed4:	e9 38 ff ff ff       	jmp    101e11 <__alltraps>

00101ed9 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ed9:	6a 00                	push   $0x0
  pushl $20
  101edb:	6a 14                	push   $0x14
  jmp __alltraps
  101edd:	e9 2f ff ff ff       	jmp    101e11 <__alltraps>

00101ee2 <vector21>:
.globl vector21
vector21:
  pushl $0
  101ee2:	6a 00                	push   $0x0
  pushl $21
  101ee4:	6a 15                	push   $0x15
  jmp __alltraps
  101ee6:	e9 26 ff ff ff       	jmp    101e11 <__alltraps>

00101eeb <vector22>:
.globl vector22
vector22:
  pushl $0
  101eeb:	6a 00                	push   $0x0
  pushl $22
  101eed:	6a 16                	push   $0x16
  jmp __alltraps
  101eef:	e9 1d ff ff ff       	jmp    101e11 <__alltraps>

00101ef4 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ef4:	6a 00                	push   $0x0
  pushl $23
  101ef6:	6a 17                	push   $0x17
  jmp __alltraps
  101ef8:	e9 14 ff ff ff       	jmp    101e11 <__alltraps>

00101efd <vector24>:
.globl vector24
vector24:
  pushl $0
  101efd:	6a 00                	push   $0x0
  pushl $24
  101eff:	6a 18                	push   $0x18
  jmp __alltraps
  101f01:	e9 0b ff ff ff       	jmp    101e11 <__alltraps>

00101f06 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f06:	6a 00                	push   $0x0
  pushl $25
  101f08:	6a 19                	push   $0x19
  jmp __alltraps
  101f0a:	e9 02 ff ff ff       	jmp    101e11 <__alltraps>

00101f0f <vector26>:
.globl vector26
vector26:
  pushl $0
  101f0f:	6a 00                	push   $0x0
  pushl $26
  101f11:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f13:	e9 f9 fe ff ff       	jmp    101e11 <__alltraps>

00101f18 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f18:	6a 00                	push   $0x0
  pushl $27
  101f1a:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f1c:	e9 f0 fe ff ff       	jmp    101e11 <__alltraps>

00101f21 <vector28>:
.globl vector28
vector28:
  pushl $0
  101f21:	6a 00                	push   $0x0
  pushl $28
  101f23:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f25:	e9 e7 fe ff ff       	jmp    101e11 <__alltraps>

00101f2a <vector29>:
.globl vector29
vector29:
  pushl $0
  101f2a:	6a 00                	push   $0x0
  pushl $29
  101f2c:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f2e:	e9 de fe ff ff       	jmp    101e11 <__alltraps>

00101f33 <vector30>:
.globl vector30
vector30:
  pushl $0
  101f33:	6a 00                	push   $0x0
  pushl $30
  101f35:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f37:	e9 d5 fe ff ff       	jmp    101e11 <__alltraps>

00101f3c <vector31>:
.globl vector31
vector31:
  pushl $0
  101f3c:	6a 00                	push   $0x0
  pushl $31
  101f3e:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f40:	e9 cc fe ff ff       	jmp    101e11 <__alltraps>

00101f45 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f45:	6a 00                	push   $0x0
  pushl $32
  101f47:	6a 20                	push   $0x20
  jmp __alltraps
  101f49:	e9 c3 fe ff ff       	jmp    101e11 <__alltraps>

00101f4e <vector33>:
.globl vector33
vector33:
  pushl $0
  101f4e:	6a 00                	push   $0x0
  pushl $33
  101f50:	6a 21                	push   $0x21
  jmp __alltraps
  101f52:	e9 ba fe ff ff       	jmp    101e11 <__alltraps>

00101f57 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f57:	6a 00                	push   $0x0
  pushl $34
  101f59:	6a 22                	push   $0x22
  jmp __alltraps
  101f5b:	e9 b1 fe ff ff       	jmp    101e11 <__alltraps>

00101f60 <vector35>:
.globl vector35
vector35:
  pushl $0
  101f60:	6a 00                	push   $0x0
  pushl $35
  101f62:	6a 23                	push   $0x23
  jmp __alltraps
  101f64:	e9 a8 fe ff ff       	jmp    101e11 <__alltraps>

00101f69 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f69:	6a 00                	push   $0x0
  pushl $36
  101f6b:	6a 24                	push   $0x24
  jmp __alltraps
  101f6d:	e9 9f fe ff ff       	jmp    101e11 <__alltraps>

00101f72 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f72:	6a 00                	push   $0x0
  pushl $37
  101f74:	6a 25                	push   $0x25
  jmp __alltraps
  101f76:	e9 96 fe ff ff       	jmp    101e11 <__alltraps>

00101f7b <vector38>:
.globl vector38
vector38:
  pushl $0
  101f7b:	6a 00                	push   $0x0
  pushl $38
  101f7d:	6a 26                	push   $0x26
  jmp __alltraps
  101f7f:	e9 8d fe ff ff       	jmp    101e11 <__alltraps>

00101f84 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f84:	6a 00                	push   $0x0
  pushl $39
  101f86:	6a 27                	push   $0x27
  jmp __alltraps
  101f88:	e9 84 fe ff ff       	jmp    101e11 <__alltraps>

00101f8d <vector40>:
.globl vector40
vector40:
  pushl $0
  101f8d:	6a 00                	push   $0x0
  pushl $40
  101f8f:	6a 28                	push   $0x28
  jmp __alltraps
  101f91:	e9 7b fe ff ff       	jmp    101e11 <__alltraps>

00101f96 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f96:	6a 00                	push   $0x0
  pushl $41
  101f98:	6a 29                	push   $0x29
  jmp __alltraps
  101f9a:	e9 72 fe ff ff       	jmp    101e11 <__alltraps>

00101f9f <vector42>:
.globl vector42
vector42:
  pushl $0
  101f9f:	6a 00                	push   $0x0
  pushl $42
  101fa1:	6a 2a                	push   $0x2a
  jmp __alltraps
  101fa3:	e9 69 fe ff ff       	jmp    101e11 <__alltraps>

00101fa8 <vector43>:
.globl vector43
vector43:
  pushl $0
  101fa8:	6a 00                	push   $0x0
  pushl $43
  101faa:	6a 2b                	push   $0x2b
  jmp __alltraps
  101fac:	e9 60 fe ff ff       	jmp    101e11 <__alltraps>

00101fb1 <vector44>:
.globl vector44
vector44:
  pushl $0
  101fb1:	6a 00                	push   $0x0
  pushl $44
  101fb3:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fb5:	e9 57 fe ff ff       	jmp    101e11 <__alltraps>

00101fba <vector45>:
.globl vector45
vector45:
  pushl $0
  101fba:	6a 00                	push   $0x0
  pushl $45
  101fbc:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fbe:	e9 4e fe ff ff       	jmp    101e11 <__alltraps>

00101fc3 <vector46>:
.globl vector46
vector46:
  pushl $0
  101fc3:	6a 00                	push   $0x0
  pushl $46
  101fc5:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fc7:	e9 45 fe ff ff       	jmp    101e11 <__alltraps>

00101fcc <vector47>:
.globl vector47
vector47:
  pushl $0
  101fcc:	6a 00                	push   $0x0
  pushl $47
  101fce:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fd0:	e9 3c fe ff ff       	jmp    101e11 <__alltraps>

00101fd5 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fd5:	6a 00                	push   $0x0
  pushl $48
  101fd7:	6a 30                	push   $0x30
  jmp __alltraps
  101fd9:	e9 33 fe ff ff       	jmp    101e11 <__alltraps>

00101fde <vector49>:
.globl vector49
vector49:
  pushl $0
  101fde:	6a 00                	push   $0x0
  pushl $49
  101fe0:	6a 31                	push   $0x31
  jmp __alltraps
  101fe2:	e9 2a fe ff ff       	jmp    101e11 <__alltraps>

00101fe7 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fe7:	6a 00                	push   $0x0
  pushl $50
  101fe9:	6a 32                	push   $0x32
  jmp __alltraps
  101feb:	e9 21 fe ff ff       	jmp    101e11 <__alltraps>

00101ff0 <vector51>:
.globl vector51
vector51:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $51
  101ff2:	6a 33                	push   $0x33
  jmp __alltraps
  101ff4:	e9 18 fe ff ff       	jmp    101e11 <__alltraps>

00101ff9 <vector52>:
.globl vector52
vector52:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $52
  101ffb:	6a 34                	push   $0x34
  jmp __alltraps
  101ffd:	e9 0f fe ff ff       	jmp    101e11 <__alltraps>

00102002 <vector53>:
.globl vector53
vector53:
  pushl $0
  102002:	6a 00                	push   $0x0
  pushl $53
  102004:	6a 35                	push   $0x35
  jmp __alltraps
  102006:	e9 06 fe ff ff       	jmp    101e11 <__alltraps>

0010200b <vector54>:
.globl vector54
vector54:
  pushl $0
  10200b:	6a 00                	push   $0x0
  pushl $54
  10200d:	6a 36                	push   $0x36
  jmp __alltraps
  10200f:	e9 fd fd ff ff       	jmp    101e11 <__alltraps>

00102014 <vector55>:
.globl vector55
vector55:
  pushl $0
  102014:	6a 00                	push   $0x0
  pushl $55
  102016:	6a 37                	push   $0x37
  jmp __alltraps
  102018:	e9 f4 fd ff ff       	jmp    101e11 <__alltraps>

0010201d <vector56>:
.globl vector56
vector56:
  pushl $0
  10201d:	6a 00                	push   $0x0
  pushl $56
  10201f:	6a 38                	push   $0x38
  jmp __alltraps
  102021:	e9 eb fd ff ff       	jmp    101e11 <__alltraps>

00102026 <vector57>:
.globl vector57
vector57:
  pushl $0
  102026:	6a 00                	push   $0x0
  pushl $57
  102028:	6a 39                	push   $0x39
  jmp __alltraps
  10202a:	e9 e2 fd ff ff       	jmp    101e11 <__alltraps>

0010202f <vector58>:
.globl vector58
vector58:
  pushl $0
  10202f:	6a 00                	push   $0x0
  pushl $58
  102031:	6a 3a                	push   $0x3a
  jmp __alltraps
  102033:	e9 d9 fd ff ff       	jmp    101e11 <__alltraps>

00102038 <vector59>:
.globl vector59
vector59:
  pushl $0
  102038:	6a 00                	push   $0x0
  pushl $59
  10203a:	6a 3b                	push   $0x3b
  jmp __alltraps
  10203c:	e9 d0 fd ff ff       	jmp    101e11 <__alltraps>

00102041 <vector60>:
.globl vector60
vector60:
  pushl $0
  102041:	6a 00                	push   $0x0
  pushl $60
  102043:	6a 3c                	push   $0x3c
  jmp __alltraps
  102045:	e9 c7 fd ff ff       	jmp    101e11 <__alltraps>

0010204a <vector61>:
.globl vector61
vector61:
  pushl $0
  10204a:	6a 00                	push   $0x0
  pushl $61
  10204c:	6a 3d                	push   $0x3d
  jmp __alltraps
  10204e:	e9 be fd ff ff       	jmp    101e11 <__alltraps>

00102053 <vector62>:
.globl vector62
vector62:
  pushl $0
  102053:	6a 00                	push   $0x0
  pushl $62
  102055:	6a 3e                	push   $0x3e
  jmp __alltraps
  102057:	e9 b5 fd ff ff       	jmp    101e11 <__alltraps>

0010205c <vector63>:
.globl vector63
vector63:
  pushl $0
  10205c:	6a 00                	push   $0x0
  pushl $63
  10205e:	6a 3f                	push   $0x3f
  jmp __alltraps
  102060:	e9 ac fd ff ff       	jmp    101e11 <__alltraps>

00102065 <vector64>:
.globl vector64
vector64:
  pushl $0
  102065:	6a 00                	push   $0x0
  pushl $64
  102067:	6a 40                	push   $0x40
  jmp __alltraps
  102069:	e9 a3 fd ff ff       	jmp    101e11 <__alltraps>

0010206e <vector65>:
.globl vector65
vector65:
  pushl $0
  10206e:	6a 00                	push   $0x0
  pushl $65
  102070:	6a 41                	push   $0x41
  jmp __alltraps
  102072:	e9 9a fd ff ff       	jmp    101e11 <__alltraps>

00102077 <vector66>:
.globl vector66
vector66:
  pushl $0
  102077:	6a 00                	push   $0x0
  pushl $66
  102079:	6a 42                	push   $0x42
  jmp __alltraps
  10207b:	e9 91 fd ff ff       	jmp    101e11 <__alltraps>

00102080 <vector67>:
.globl vector67
vector67:
  pushl $0
  102080:	6a 00                	push   $0x0
  pushl $67
  102082:	6a 43                	push   $0x43
  jmp __alltraps
  102084:	e9 88 fd ff ff       	jmp    101e11 <__alltraps>

00102089 <vector68>:
.globl vector68
vector68:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $68
  10208b:	6a 44                	push   $0x44
  jmp __alltraps
  10208d:	e9 7f fd ff ff       	jmp    101e11 <__alltraps>

00102092 <vector69>:
.globl vector69
vector69:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $69
  102094:	6a 45                	push   $0x45
  jmp __alltraps
  102096:	e9 76 fd ff ff       	jmp    101e11 <__alltraps>

0010209b <vector70>:
.globl vector70
vector70:
  pushl $0
  10209b:	6a 00                	push   $0x0
  pushl $70
  10209d:	6a 46                	push   $0x46
  jmp __alltraps
  10209f:	e9 6d fd ff ff       	jmp    101e11 <__alltraps>

001020a4 <vector71>:
.globl vector71
vector71:
  pushl $0
  1020a4:	6a 00                	push   $0x0
  pushl $71
  1020a6:	6a 47                	push   $0x47
  jmp __alltraps
  1020a8:	e9 64 fd ff ff       	jmp    101e11 <__alltraps>

001020ad <vector72>:
.globl vector72
vector72:
  pushl $0
  1020ad:	6a 00                	push   $0x0
  pushl $72
  1020af:	6a 48                	push   $0x48
  jmp __alltraps
  1020b1:	e9 5b fd ff ff       	jmp    101e11 <__alltraps>

001020b6 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020b6:	6a 00                	push   $0x0
  pushl $73
  1020b8:	6a 49                	push   $0x49
  jmp __alltraps
  1020ba:	e9 52 fd ff ff       	jmp    101e11 <__alltraps>

001020bf <vector74>:
.globl vector74
vector74:
  pushl $0
  1020bf:	6a 00                	push   $0x0
  pushl $74
  1020c1:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020c3:	e9 49 fd ff ff       	jmp    101e11 <__alltraps>

001020c8 <vector75>:
.globl vector75
vector75:
  pushl $0
  1020c8:	6a 00                	push   $0x0
  pushl $75
  1020ca:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020cc:	e9 40 fd ff ff       	jmp    101e11 <__alltraps>

001020d1 <vector76>:
.globl vector76
vector76:
  pushl $0
  1020d1:	6a 00                	push   $0x0
  pushl $76
  1020d3:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020d5:	e9 37 fd ff ff       	jmp    101e11 <__alltraps>

001020da <vector77>:
.globl vector77
vector77:
  pushl $0
  1020da:	6a 00                	push   $0x0
  pushl $77
  1020dc:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020de:	e9 2e fd ff ff       	jmp    101e11 <__alltraps>

001020e3 <vector78>:
.globl vector78
vector78:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $78
  1020e5:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020e7:	e9 25 fd ff ff       	jmp    101e11 <__alltraps>

001020ec <vector79>:
.globl vector79
vector79:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $79
  1020ee:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020f0:	e9 1c fd ff ff       	jmp    101e11 <__alltraps>

001020f5 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $80
  1020f7:	6a 50                	push   $0x50
  jmp __alltraps
  1020f9:	e9 13 fd ff ff       	jmp    101e11 <__alltraps>

001020fe <vector81>:
.globl vector81
vector81:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $81
  102100:	6a 51                	push   $0x51
  jmp __alltraps
  102102:	e9 0a fd ff ff       	jmp    101e11 <__alltraps>

00102107 <vector82>:
.globl vector82
vector82:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $82
  102109:	6a 52                	push   $0x52
  jmp __alltraps
  10210b:	e9 01 fd ff ff       	jmp    101e11 <__alltraps>

00102110 <vector83>:
.globl vector83
vector83:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $83
  102112:	6a 53                	push   $0x53
  jmp __alltraps
  102114:	e9 f8 fc ff ff       	jmp    101e11 <__alltraps>

00102119 <vector84>:
.globl vector84
vector84:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $84
  10211b:	6a 54                	push   $0x54
  jmp __alltraps
  10211d:	e9 ef fc ff ff       	jmp    101e11 <__alltraps>

00102122 <vector85>:
.globl vector85
vector85:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $85
  102124:	6a 55                	push   $0x55
  jmp __alltraps
  102126:	e9 e6 fc ff ff       	jmp    101e11 <__alltraps>

0010212b <vector86>:
.globl vector86
vector86:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $86
  10212d:	6a 56                	push   $0x56
  jmp __alltraps
  10212f:	e9 dd fc ff ff       	jmp    101e11 <__alltraps>

00102134 <vector87>:
.globl vector87
vector87:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $87
  102136:	6a 57                	push   $0x57
  jmp __alltraps
  102138:	e9 d4 fc ff ff       	jmp    101e11 <__alltraps>

0010213d <vector88>:
.globl vector88
vector88:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $88
  10213f:	6a 58                	push   $0x58
  jmp __alltraps
  102141:	e9 cb fc ff ff       	jmp    101e11 <__alltraps>

00102146 <vector89>:
.globl vector89
vector89:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $89
  102148:	6a 59                	push   $0x59
  jmp __alltraps
  10214a:	e9 c2 fc ff ff       	jmp    101e11 <__alltraps>

0010214f <vector90>:
.globl vector90
vector90:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $90
  102151:	6a 5a                	push   $0x5a
  jmp __alltraps
  102153:	e9 b9 fc ff ff       	jmp    101e11 <__alltraps>

00102158 <vector91>:
.globl vector91
vector91:
  pushl $0
  102158:	6a 00                	push   $0x0
  pushl $91
  10215a:	6a 5b                	push   $0x5b
  jmp __alltraps
  10215c:	e9 b0 fc ff ff       	jmp    101e11 <__alltraps>

00102161 <vector92>:
.globl vector92
vector92:
  pushl $0
  102161:	6a 00                	push   $0x0
  pushl $92
  102163:	6a 5c                	push   $0x5c
  jmp __alltraps
  102165:	e9 a7 fc ff ff       	jmp    101e11 <__alltraps>

0010216a <vector93>:
.globl vector93
vector93:
  pushl $0
  10216a:	6a 00                	push   $0x0
  pushl $93
  10216c:	6a 5d                	push   $0x5d
  jmp __alltraps
  10216e:	e9 9e fc ff ff       	jmp    101e11 <__alltraps>

00102173 <vector94>:
.globl vector94
vector94:
  pushl $0
  102173:	6a 00                	push   $0x0
  pushl $94
  102175:	6a 5e                	push   $0x5e
  jmp __alltraps
  102177:	e9 95 fc ff ff       	jmp    101e11 <__alltraps>

0010217c <vector95>:
.globl vector95
vector95:
  pushl $0
  10217c:	6a 00                	push   $0x0
  pushl $95
  10217e:	6a 5f                	push   $0x5f
  jmp __alltraps
  102180:	e9 8c fc ff ff       	jmp    101e11 <__alltraps>

00102185 <vector96>:
.globl vector96
vector96:
  pushl $0
  102185:	6a 00                	push   $0x0
  pushl $96
  102187:	6a 60                	push   $0x60
  jmp __alltraps
  102189:	e9 83 fc ff ff       	jmp    101e11 <__alltraps>

0010218e <vector97>:
.globl vector97
vector97:
  pushl $0
  10218e:	6a 00                	push   $0x0
  pushl $97
  102190:	6a 61                	push   $0x61
  jmp __alltraps
  102192:	e9 7a fc ff ff       	jmp    101e11 <__alltraps>

00102197 <vector98>:
.globl vector98
vector98:
  pushl $0
  102197:	6a 00                	push   $0x0
  pushl $98
  102199:	6a 62                	push   $0x62
  jmp __alltraps
  10219b:	e9 71 fc ff ff       	jmp    101e11 <__alltraps>

001021a0 <vector99>:
.globl vector99
vector99:
  pushl $0
  1021a0:	6a 00                	push   $0x0
  pushl $99
  1021a2:	6a 63                	push   $0x63
  jmp __alltraps
  1021a4:	e9 68 fc ff ff       	jmp    101e11 <__alltraps>

001021a9 <vector100>:
.globl vector100
vector100:
  pushl $0
  1021a9:	6a 00                	push   $0x0
  pushl $100
  1021ab:	6a 64                	push   $0x64
  jmp __alltraps
  1021ad:	e9 5f fc ff ff       	jmp    101e11 <__alltraps>

001021b2 <vector101>:
.globl vector101
vector101:
  pushl $0
  1021b2:	6a 00                	push   $0x0
  pushl $101
  1021b4:	6a 65                	push   $0x65
  jmp __alltraps
  1021b6:	e9 56 fc ff ff       	jmp    101e11 <__alltraps>

001021bb <vector102>:
.globl vector102
vector102:
  pushl $0
  1021bb:	6a 00                	push   $0x0
  pushl $102
  1021bd:	6a 66                	push   $0x66
  jmp __alltraps
  1021bf:	e9 4d fc ff ff       	jmp    101e11 <__alltraps>

001021c4 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021c4:	6a 00                	push   $0x0
  pushl $103
  1021c6:	6a 67                	push   $0x67
  jmp __alltraps
  1021c8:	e9 44 fc ff ff       	jmp    101e11 <__alltraps>

001021cd <vector104>:
.globl vector104
vector104:
  pushl $0
  1021cd:	6a 00                	push   $0x0
  pushl $104
  1021cf:	6a 68                	push   $0x68
  jmp __alltraps
  1021d1:	e9 3b fc ff ff       	jmp    101e11 <__alltraps>

001021d6 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021d6:	6a 00                	push   $0x0
  pushl $105
  1021d8:	6a 69                	push   $0x69
  jmp __alltraps
  1021da:	e9 32 fc ff ff       	jmp    101e11 <__alltraps>

001021df <vector106>:
.globl vector106
vector106:
  pushl $0
  1021df:	6a 00                	push   $0x0
  pushl $106
  1021e1:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021e3:	e9 29 fc ff ff       	jmp    101e11 <__alltraps>

001021e8 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021e8:	6a 00                	push   $0x0
  pushl $107
  1021ea:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021ec:	e9 20 fc ff ff       	jmp    101e11 <__alltraps>

001021f1 <vector108>:
.globl vector108
vector108:
  pushl $0
  1021f1:	6a 00                	push   $0x0
  pushl $108
  1021f3:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021f5:	e9 17 fc ff ff       	jmp    101e11 <__alltraps>

001021fa <vector109>:
.globl vector109
vector109:
  pushl $0
  1021fa:	6a 00                	push   $0x0
  pushl $109
  1021fc:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021fe:	e9 0e fc ff ff       	jmp    101e11 <__alltraps>

00102203 <vector110>:
.globl vector110
vector110:
  pushl $0
  102203:	6a 00                	push   $0x0
  pushl $110
  102205:	6a 6e                	push   $0x6e
  jmp __alltraps
  102207:	e9 05 fc ff ff       	jmp    101e11 <__alltraps>

0010220c <vector111>:
.globl vector111
vector111:
  pushl $0
  10220c:	6a 00                	push   $0x0
  pushl $111
  10220e:	6a 6f                	push   $0x6f
  jmp __alltraps
  102210:	e9 fc fb ff ff       	jmp    101e11 <__alltraps>

00102215 <vector112>:
.globl vector112
vector112:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $112
  102217:	6a 70                	push   $0x70
  jmp __alltraps
  102219:	e9 f3 fb ff ff       	jmp    101e11 <__alltraps>

0010221e <vector113>:
.globl vector113
vector113:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $113
  102220:	6a 71                	push   $0x71
  jmp __alltraps
  102222:	e9 ea fb ff ff       	jmp    101e11 <__alltraps>

00102227 <vector114>:
.globl vector114
vector114:
  pushl $0
  102227:	6a 00                	push   $0x0
  pushl $114
  102229:	6a 72                	push   $0x72
  jmp __alltraps
  10222b:	e9 e1 fb ff ff       	jmp    101e11 <__alltraps>

00102230 <vector115>:
.globl vector115
vector115:
  pushl $0
  102230:	6a 00                	push   $0x0
  pushl $115
  102232:	6a 73                	push   $0x73
  jmp __alltraps
  102234:	e9 d8 fb ff ff       	jmp    101e11 <__alltraps>

00102239 <vector116>:
.globl vector116
vector116:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $116
  10223b:	6a 74                	push   $0x74
  jmp __alltraps
  10223d:	e9 cf fb ff ff       	jmp    101e11 <__alltraps>

00102242 <vector117>:
.globl vector117
vector117:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $117
  102244:	6a 75                	push   $0x75
  jmp __alltraps
  102246:	e9 c6 fb ff ff       	jmp    101e11 <__alltraps>

0010224b <vector118>:
.globl vector118
vector118:
  pushl $0
  10224b:	6a 00                	push   $0x0
  pushl $118
  10224d:	6a 76                	push   $0x76
  jmp __alltraps
  10224f:	e9 bd fb ff ff       	jmp    101e11 <__alltraps>

00102254 <vector119>:
.globl vector119
vector119:
  pushl $0
  102254:	6a 00                	push   $0x0
  pushl $119
  102256:	6a 77                	push   $0x77
  jmp __alltraps
  102258:	e9 b4 fb ff ff       	jmp    101e11 <__alltraps>

0010225d <vector120>:
.globl vector120
vector120:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $120
  10225f:	6a 78                	push   $0x78
  jmp __alltraps
  102261:	e9 ab fb ff ff       	jmp    101e11 <__alltraps>

00102266 <vector121>:
.globl vector121
vector121:
  pushl $0
  102266:	6a 00                	push   $0x0
  pushl $121
  102268:	6a 79                	push   $0x79
  jmp __alltraps
  10226a:	e9 a2 fb ff ff       	jmp    101e11 <__alltraps>

0010226f <vector122>:
.globl vector122
vector122:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $122
  102271:	6a 7a                	push   $0x7a
  jmp __alltraps
  102273:	e9 99 fb ff ff       	jmp    101e11 <__alltraps>

00102278 <vector123>:
.globl vector123
vector123:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $123
  10227a:	6a 7b                	push   $0x7b
  jmp __alltraps
  10227c:	e9 90 fb ff ff       	jmp    101e11 <__alltraps>

00102281 <vector124>:
.globl vector124
vector124:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $124
  102283:	6a 7c                	push   $0x7c
  jmp __alltraps
  102285:	e9 87 fb ff ff       	jmp    101e11 <__alltraps>

0010228a <vector125>:
.globl vector125
vector125:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $125
  10228c:	6a 7d                	push   $0x7d
  jmp __alltraps
  10228e:	e9 7e fb ff ff       	jmp    101e11 <__alltraps>

00102293 <vector126>:
.globl vector126
vector126:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $126
  102295:	6a 7e                	push   $0x7e
  jmp __alltraps
  102297:	e9 75 fb ff ff       	jmp    101e11 <__alltraps>

0010229c <vector127>:
.globl vector127
vector127:
  pushl $0
  10229c:	6a 00                	push   $0x0
  pushl $127
  10229e:	6a 7f                	push   $0x7f
  jmp __alltraps
  1022a0:	e9 6c fb ff ff       	jmp    101e11 <__alltraps>

001022a5 <vector128>:
.globl vector128
vector128:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $128
  1022a7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022ac:	e9 60 fb ff ff       	jmp    101e11 <__alltraps>

001022b1 <vector129>:
.globl vector129
vector129:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $129
  1022b3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022b8:	e9 54 fb ff ff       	jmp    101e11 <__alltraps>

001022bd <vector130>:
.globl vector130
vector130:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $130
  1022bf:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022c4:	e9 48 fb ff ff       	jmp    101e11 <__alltraps>

001022c9 <vector131>:
.globl vector131
vector131:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $131
  1022cb:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022d0:	e9 3c fb ff ff       	jmp    101e11 <__alltraps>

001022d5 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $132
  1022d7:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022dc:	e9 30 fb ff ff       	jmp    101e11 <__alltraps>

001022e1 <vector133>:
.globl vector133
vector133:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $133
  1022e3:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022e8:	e9 24 fb ff ff       	jmp    101e11 <__alltraps>

001022ed <vector134>:
.globl vector134
vector134:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $134
  1022ef:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022f4:	e9 18 fb ff ff       	jmp    101e11 <__alltraps>

001022f9 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $135
  1022fb:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102300:	e9 0c fb ff ff       	jmp    101e11 <__alltraps>

00102305 <vector136>:
.globl vector136
vector136:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $136
  102307:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10230c:	e9 00 fb ff ff       	jmp    101e11 <__alltraps>

00102311 <vector137>:
.globl vector137
vector137:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $137
  102313:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102318:	e9 f4 fa ff ff       	jmp    101e11 <__alltraps>

0010231d <vector138>:
.globl vector138
vector138:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $138
  10231f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102324:	e9 e8 fa ff ff       	jmp    101e11 <__alltraps>

00102329 <vector139>:
.globl vector139
vector139:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $139
  10232b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102330:	e9 dc fa ff ff       	jmp    101e11 <__alltraps>

00102335 <vector140>:
.globl vector140
vector140:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $140
  102337:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  10233c:	e9 d0 fa ff ff       	jmp    101e11 <__alltraps>

00102341 <vector141>:
.globl vector141
vector141:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $141
  102343:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102348:	e9 c4 fa ff ff       	jmp    101e11 <__alltraps>

0010234d <vector142>:
.globl vector142
vector142:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $142
  10234f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102354:	e9 b8 fa ff ff       	jmp    101e11 <__alltraps>

00102359 <vector143>:
.globl vector143
vector143:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $143
  10235b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102360:	e9 ac fa ff ff       	jmp    101e11 <__alltraps>

00102365 <vector144>:
.globl vector144
vector144:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $144
  102367:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10236c:	e9 a0 fa ff ff       	jmp    101e11 <__alltraps>

00102371 <vector145>:
.globl vector145
vector145:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $145
  102373:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102378:	e9 94 fa ff ff       	jmp    101e11 <__alltraps>

0010237d <vector146>:
.globl vector146
vector146:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $146
  10237f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102384:	e9 88 fa ff ff       	jmp    101e11 <__alltraps>

00102389 <vector147>:
.globl vector147
vector147:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $147
  10238b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102390:	e9 7c fa ff ff       	jmp    101e11 <__alltraps>

00102395 <vector148>:
.globl vector148
vector148:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $148
  102397:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10239c:	e9 70 fa ff ff       	jmp    101e11 <__alltraps>

001023a1 <vector149>:
.globl vector149
vector149:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $149
  1023a3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023a8:	e9 64 fa ff ff       	jmp    101e11 <__alltraps>

001023ad <vector150>:
.globl vector150
vector150:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $150
  1023af:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023b4:	e9 58 fa ff ff       	jmp    101e11 <__alltraps>

001023b9 <vector151>:
.globl vector151
vector151:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $151
  1023bb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023c0:	e9 4c fa ff ff       	jmp    101e11 <__alltraps>

001023c5 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $152
  1023c7:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023cc:	e9 40 fa ff ff       	jmp    101e11 <__alltraps>

001023d1 <vector153>:
.globl vector153
vector153:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $153
  1023d3:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023d8:	e9 34 fa ff ff       	jmp    101e11 <__alltraps>

001023dd <vector154>:
.globl vector154
vector154:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $154
  1023df:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023e4:	e9 28 fa ff ff       	jmp    101e11 <__alltraps>

001023e9 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $155
  1023eb:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023f0:	e9 1c fa ff ff       	jmp    101e11 <__alltraps>

001023f5 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $156
  1023f7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023fc:	e9 10 fa ff ff       	jmp    101e11 <__alltraps>

00102401 <vector157>:
.globl vector157
vector157:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $157
  102403:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102408:	e9 04 fa ff ff       	jmp    101e11 <__alltraps>

0010240d <vector158>:
.globl vector158
vector158:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $158
  10240f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102414:	e9 f8 f9 ff ff       	jmp    101e11 <__alltraps>

00102419 <vector159>:
.globl vector159
vector159:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $159
  10241b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102420:	e9 ec f9 ff ff       	jmp    101e11 <__alltraps>

00102425 <vector160>:
.globl vector160
vector160:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $160
  102427:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  10242c:	e9 e0 f9 ff ff       	jmp    101e11 <__alltraps>

00102431 <vector161>:
.globl vector161
vector161:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $161
  102433:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102438:	e9 d4 f9 ff ff       	jmp    101e11 <__alltraps>

0010243d <vector162>:
.globl vector162
vector162:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $162
  10243f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102444:	e9 c8 f9 ff ff       	jmp    101e11 <__alltraps>

00102449 <vector163>:
.globl vector163
vector163:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $163
  10244b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102450:	e9 bc f9 ff ff       	jmp    101e11 <__alltraps>

00102455 <vector164>:
.globl vector164
vector164:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $164
  102457:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10245c:	e9 b0 f9 ff ff       	jmp    101e11 <__alltraps>

00102461 <vector165>:
.globl vector165
vector165:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $165
  102463:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102468:	e9 a4 f9 ff ff       	jmp    101e11 <__alltraps>

0010246d <vector166>:
.globl vector166
vector166:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $166
  10246f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102474:	e9 98 f9 ff ff       	jmp    101e11 <__alltraps>

00102479 <vector167>:
.globl vector167
vector167:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $167
  10247b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102480:	e9 8c f9 ff ff       	jmp    101e11 <__alltraps>

00102485 <vector168>:
.globl vector168
vector168:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $168
  102487:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10248c:	e9 80 f9 ff ff       	jmp    101e11 <__alltraps>

00102491 <vector169>:
.globl vector169
vector169:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $169
  102493:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102498:	e9 74 f9 ff ff       	jmp    101e11 <__alltraps>

0010249d <vector170>:
.globl vector170
vector170:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $170
  10249f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024a4:	e9 68 f9 ff ff       	jmp    101e11 <__alltraps>

001024a9 <vector171>:
.globl vector171
vector171:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $171
  1024ab:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024b0:	e9 5c f9 ff ff       	jmp    101e11 <__alltraps>

001024b5 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $172
  1024b7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024bc:	e9 50 f9 ff ff       	jmp    101e11 <__alltraps>

001024c1 <vector173>:
.globl vector173
vector173:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $173
  1024c3:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024c8:	e9 44 f9 ff ff       	jmp    101e11 <__alltraps>

001024cd <vector174>:
.globl vector174
vector174:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $174
  1024cf:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024d4:	e9 38 f9 ff ff       	jmp    101e11 <__alltraps>

001024d9 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $175
  1024db:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024e0:	e9 2c f9 ff ff       	jmp    101e11 <__alltraps>

001024e5 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $176
  1024e7:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024ec:	e9 20 f9 ff ff       	jmp    101e11 <__alltraps>

001024f1 <vector177>:
.globl vector177
vector177:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $177
  1024f3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024f8:	e9 14 f9 ff ff       	jmp    101e11 <__alltraps>

001024fd <vector178>:
.globl vector178
vector178:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $178
  1024ff:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102504:	e9 08 f9 ff ff       	jmp    101e11 <__alltraps>

00102509 <vector179>:
.globl vector179
vector179:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $179
  10250b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102510:	e9 fc f8 ff ff       	jmp    101e11 <__alltraps>

00102515 <vector180>:
.globl vector180
vector180:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $180
  102517:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10251c:	e9 f0 f8 ff ff       	jmp    101e11 <__alltraps>

00102521 <vector181>:
.globl vector181
vector181:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $181
  102523:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102528:	e9 e4 f8 ff ff       	jmp    101e11 <__alltraps>

0010252d <vector182>:
.globl vector182
vector182:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $182
  10252f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102534:	e9 d8 f8 ff ff       	jmp    101e11 <__alltraps>

00102539 <vector183>:
.globl vector183
vector183:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $183
  10253b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102540:	e9 cc f8 ff ff       	jmp    101e11 <__alltraps>

00102545 <vector184>:
.globl vector184
vector184:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $184
  102547:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  10254c:	e9 c0 f8 ff ff       	jmp    101e11 <__alltraps>

00102551 <vector185>:
.globl vector185
vector185:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $185
  102553:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102558:	e9 b4 f8 ff ff       	jmp    101e11 <__alltraps>

0010255d <vector186>:
.globl vector186
vector186:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $186
  10255f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102564:	e9 a8 f8 ff ff       	jmp    101e11 <__alltraps>

00102569 <vector187>:
.globl vector187
vector187:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $187
  10256b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102570:	e9 9c f8 ff ff       	jmp    101e11 <__alltraps>

00102575 <vector188>:
.globl vector188
vector188:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $188
  102577:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10257c:	e9 90 f8 ff ff       	jmp    101e11 <__alltraps>

00102581 <vector189>:
.globl vector189
vector189:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $189
  102583:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102588:	e9 84 f8 ff ff       	jmp    101e11 <__alltraps>

0010258d <vector190>:
.globl vector190
vector190:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $190
  10258f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102594:	e9 78 f8 ff ff       	jmp    101e11 <__alltraps>

00102599 <vector191>:
.globl vector191
vector191:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $191
  10259b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1025a0:	e9 6c f8 ff ff       	jmp    101e11 <__alltraps>

001025a5 <vector192>:
.globl vector192
vector192:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $192
  1025a7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025ac:	e9 60 f8 ff ff       	jmp    101e11 <__alltraps>

001025b1 <vector193>:
.globl vector193
vector193:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $193
  1025b3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025b8:	e9 54 f8 ff ff       	jmp    101e11 <__alltraps>

001025bd <vector194>:
.globl vector194
vector194:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $194
  1025bf:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025c4:	e9 48 f8 ff ff       	jmp    101e11 <__alltraps>

001025c9 <vector195>:
.globl vector195
vector195:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $195
  1025cb:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025d0:	e9 3c f8 ff ff       	jmp    101e11 <__alltraps>

001025d5 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $196
  1025d7:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025dc:	e9 30 f8 ff ff       	jmp    101e11 <__alltraps>

001025e1 <vector197>:
.globl vector197
vector197:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $197
  1025e3:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025e8:	e9 24 f8 ff ff       	jmp    101e11 <__alltraps>

001025ed <vector198>:
.globl vector198
vector198:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $198
  1025ef:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025f4:	e9 18 f8 ff ff       	jmp    101e11 <__alltraps>

001025f9 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $199
  1025fb:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102600:	e9 0c f8 ff ff       	jmp    101e11 <__alltraps>

00102605 <vector200>:
.globl vector200
vector200:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $200
  102607:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10260c:	e9 00 f8 ff ff       	jmp    101e11 <__alltraps>

00102611 <vector201>:
.globl vector201
vector201:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $201
  102613:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102618:	e9 f4 f7 ff ff       	jmp    101e11 <__alltraps>

0010261d <vector202>:
.globl vector202
vector202:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $202
  10261f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102624:	e9 e8 f7 ff ff       	jmp    101e11 <__alltraps>

00102629 <vector203>:
.globl vector203
vector203:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $203
  10262b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102630:	e9 dc f7 ff ff       	jmp    101e11 <__alltraps>

00102635 <vector204>:
.globl vector204
vector204:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $204
  102637:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  10263c:	e9 d0 f7 ff ff       	jmp    101e11 <__alltraps>

00102641 <vector205>:
.globl vector205
vector205:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $205
  102643:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102648:	e9 c4 f7 ff ff       	jmp    101e11 <__alltraps>

0010264d <vector206>:
.globl vector206
vector206:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $206
  10264f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102654:	e9 b8 f7 ff ff       	jmp    101e11 <__alltraps>

00102659 <vector207>:
.globl vector207
vector207:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $207
  10265b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102660:	e9 ac f7 ff ff       	jmp    101e11 <__alltraps>

00102665 <vector208>:
.globl vector208
vector208:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $208
  102667:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10266c:	e9 a0 f7 ff ff       	jmp    101e11 <__alltraps>

00102671 <vector209>:
.globl vector209
vector209:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $209
  102673:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102678:	e9 94 f7 ff ff       	jmp    101e11 <__alltraps>

0010267d <vector210>:
.globl vector210
vector210:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $210
  10267f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102684:	e9 88 f7 ff ff       	jmp    101e11 <__alltraps>

00102689 <vector211>:
.globl vector211
vector211:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $211
  10268b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102690:	e9 7c f7 ff ff       	jmp    101e11 <__alltraps>

00102695 <vector212>:
.globl vector212
vector212:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $212
  102697:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10269c:	e9 70 f7 ff ff       	jmp    101e11 <__alltraps>

001026a1 <vector213>:
.globl vector213
vector213:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $213
  1026a3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026a8:	e9 64 f7 ff ff       	jmp    101e11 <__alltraps>

001026ad <vector214>:
.globl vector214
vector214:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $214
  1026af:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026b4:	e9 58 f7 ff ff       	jmp    101e11 <__alltraps>

001026b9 <vector215>:
.globl vector215
vector215:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $215
  1026bb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026c0:	e9 4c f7 ff ff       	jmp    101e11 <__alltraps>

001026c5 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $216
  1026c7:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026cc:	e9 40 f7 ff ff       	jmp    101e11 <__alltraps>

001026d1 <vector217>:
.globl vector217
vector217:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $217
  1026d3:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026d8:	e9 34 f7 ff ff       	jmp    101e11 <__alltraps>

001026dd <vector218>:
.globl vector218
vector218:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $218
  1026df:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026e4:	e9 28 f7 ff ff       	jmp    101e11 <__alltraps>

001026e9 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $219
  1026eb:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026f0:	e9 1c f7 ff ff       	jmp    101e11 <__alltraps>

001026f5 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $220
  1026f7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026fc:	e9 10 f7 ff ff       	jmp    101e11 <__alltraps>

00102701 <vector221>:
.globl vector221
vector221:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $221
  102703:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102708:	e9 04 f7 ff ff       	jmp    101e11 <__alltraps>

0010270d <vector222>:
.globl vector222
vector222:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $222
  10270f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102714:	e9 f8 f6 ff ff       	jmp    101e11 <__alltraps>

00102719 <vector223>:
.globl vector223
vector223:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $223
  10271b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102720:	e9 ec f6 ff ff       	jmp    101e11 <__alltraps>

00102725 <vector224>:
.globl vector224
vector224:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $224
  102727:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  10272c:	e9 e0 f6 ff ff       	jmp    101e11 <__alltraps>

00102731 <vector225>:
.globl vector225
vector225:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $225
  102733:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102738:	e9 d4 f6 ff ff       	jmp    101e11 <__alltraps>

0010273d <vector226>:
.globl vector226
vector226:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $226
  10273f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102744:	e9 c8 f6 ff ff       	jmp    101e11 <__alltraps>

00102749 <vector227>:
.globl vector227
vector227:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $227
  10274b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102750:	e9 bc f6 ff ff       	jmp    101e11 <__alltraps>

00102755 <vector228>:
.globl vector228
vector228:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $228
  102757:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10275c:	e9 b0 f6 ff ff       	jmp    101e11 <__alltraps>

00102761 <vector229>:
.globl vector229
vector229:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $229
  102763:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102768:	e9 a4 f6 ff ff       	jmp    101e11 <__alltraps>

0010276d <vector230>:
.globl vector230
vector230:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $230
  10276f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102774:	e9 98 f6 ff ff       	jmp    101e11 <__alltraps>

00102779 <vector231>:
.globl vector231
vector231:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $231
  10277b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102780:	e9 8c f6 ff ff       	jmp    101e11 <__alltraps>

00102785 <vector232>:
.globl vector232
vector232:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $232
  102787:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10278c:	e9 80 f6 ff ff       	jmp    101e11 <__alltraps>

00102791 <vector233>:
.globl vector233
vector233:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $233
  102793:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102798:	e9 74 f6 ff ff       	jmp    101e11 <__alltraps>

0010279d <vector234>:
.globl vector234
vector234:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $234
  10279f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027a4:	e9 68 f6 ff ff       	jmp    101e11 <__alltraps>

001027a9 <vector235>:
.globl vector235
vector235:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $235
  1027ab:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027b0:	e9 5c f6 ff ff       	jmp    101e11 <__alltraps>

001027b5 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $236
  1027b7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027bc:	e9 50 f6 ff ff       	jmp    101e11 <__alltraps>

001027c1 <vector237>:
.globl vector237
vector237:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $237
  1027c3:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027c8:	e9 44 f6 ff ff       	jmp    101e11 <__alltraps>

001027cd <vector238>:
.globl vector238
vector238:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $238
  1027cf:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027d4:	e9 38 f6 ff ff       	jmp    101e11 <__alltraps>

001027d9 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $239
  1027db:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027e0:	e9 2c f6 ff ff       	jmp    101e11 <__alltraps>

001027e5 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $240
  1027e7:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027ec:	e9 20 f6 ff ff       	jmp    101e11 <__alltraps>

001027f1 <vector241>:
.globl vector241
vector241:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $241
  1027f3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027f8:	e9 14 f6 ff ff       	jmp    101e11 <__alltraps>

001027fd <vector242>:
.globl vector242
vector242:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $242
  1027ff:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102804:	e9 08 f6 ff ff       	jmp    101e11 <__alltraps>

00102809 <vector243>:
.globl vector243
vector243:
  pushl $0
  102809:	6a 00                	push   $0x0
  pushl $243
  10280b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102810:	e9 fc f5 ff ff       	jmp    101e11 <__alltraps>

00102815 <vector244>:
.globl vector244
vector244:
  pushl $0
  102815:	6a 00                	push   $0x0
  pushl $244
  102817:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10281c:	e9 f0 f5 ff ff       	jmp    101e11 <__alltraps>

00102821 <vector245>:
.globl vector245
vector245:
  pushl $0
  102821:	6a 00                	push   $0x0
  pushl $245
  102823:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102828:	e9 e4 f5 ff ff       	jmp    101e11 <__alltraps>

0010282d <vector246>:
.globl vector246
vector246:
  pushl $0
  10282d:	6a 00                	push   $0x0
  pushl $246
  10282f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102834:	e9 d8 f5 ff ff       	jmp    101e11 <__alltraps>

00102839 <vector247>:
.globl vector247
vector247:
  pushl $0
  102839:	6a 00                	push   $0x0
  pushl $247
  10283b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102840:	e9 cc f5 ff ff       	jmp    101e11 <__alltraps>

00102845 <vector248>:
.globl vector248
vector248:
  pushl $0
  102845:	6a 00                	push   $0x0
  pushl $248
  102847:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  10284c:	e9 c0 f5 ff ff       	jmp    101e11 <__alltraps>

00102851 <vector249>:
.globl vector249
vector249:
  pushl $0
  102851:	6a 00                	push   $0x0
  pushl $249
  102853:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102858:	e9 b4 f5 ff ff       	jmp    101e11 <__alltraps>

0010285d <vector250>:
.globl vector250
vector250:
  pushl $0
  10285d:	6a 00                	push   $0x0
  pushl $250
  10285f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102864:	e9 a8 f5 ff ff       	jmp    101e11 <__alltraps>

00102869 <vector251>:
.globl vector251
vector251:
  pushl $0
  102869:	6a 00                	push   $0x0
  pushl $251
  10286b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102870:	e9 9c f5 ff ff       	jmp    101e11 <__alltraps>

00102875 <vector252>:
.globl vector252
vector252:
  pushl $0
  102875:	6a 00                	push   $0x0
  pushl $252
  102877:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  10287c:	e9 90 f5 ff ff       	jmp    101e11 <__alltraps>

00102881 <vector253>:
.globl vector253
vector253:
  pushl $0
  102881:	6a 00                	push   $0x0
  pushl $253
  102883:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102888:	e9 84 f5 ff ff       	jmp    101e11 <__alltraps>

0010288d <vector254>:
.globl vector254
vector254:
  pushl $0
  10288d:	6a 00                	push   $0x0
  pushl $254
  10288f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102894:	e9 78 f5 ff ff       	jmp    101e11 <__alltraps>

00102899 <vector255>:
.globl vector255
vector255:
  pushl $0
  102899:	6a 00                	push   $0x0
  pushl $255
  10289b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1028a0:	e9 6c f5 ff ff       	jmp    101e11 <__alltraps>

001028a5 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  1028a5:	55                   	push   %ebp
  1028a6:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1028a8:	8b 55 08             	mov    0x8(%ebp),%edx
  1028ab:	a1 24 af 11 00       	mov    0x11af24,%eax
  1028b0:	29 c2                	sub    %eax,%edx
  1028b2:	89 d0                	mov    %edx,%eax
  1028b4:	c1 f8 02             	sar    $0x2,%eax
  1028b7:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1028bd:	5d                   	pop    %ebp
  1028be:	c3                   	ret    

001028bf <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  1028bf:	55                   	push   %ebp
  1028c0:	89 e5                	mov    %esp,%ebp
  1028c2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1028c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1028c8:	89 04 24             	mov    %eax,(%esp)
  1028cb:	e8 d5 ff ff ff       	call   1028a5 <page2ppn>
  1028d0:	c1 e0 0c             	shl    $0xc,%eax
}
  1028d3:	c9                   	leave  
  1028d4:	c3                   	ret    

001028d5 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  1028d5:	55                   	push   %ebp
  1028d6:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1028d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1028db:	8b 00                	mov    (%eax),%eax
}
  1028dd:	5d                   	pop    %ebp
  1028de:	c3                   	ret    

001028df <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  1028df:	55                   	push   %ebp
  1028e0:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1028e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1028e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1028e8:	89 10                	mov    %edx,(%eax)
}
  1028ea:	5d                   	pop    %ebp
  1028eb:	c3                   	ret    

001028ec <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1028ec:	55                   	push   %ebp
  1028ed:	89 e5                	mov    %esp,%ebp
  1028ef:	83 ec 10             	sub    $0x10,%esp
  1028f2:	c7 45 fc 10 af 11 00 	movl   $0x11af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1028f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1028ff:	89 50 04             	mov    %edx,0x4(%eax)
  102902:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102905:	8b 50 04             	mov    0x4(%eax),%edx
  102908:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10290b:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10290d:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  102914:	00 00 00 
}
  102917:	c9                   	leave  
  102918:	c3                   	ret    

00102919 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102919:	55                   	push   %ebp
  10291a:	89 e5                	mov    %esp,%ebp
  10291c:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  10291f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102923:	75 24                	jne    102949 <default_init_memmap+0x30>
  102925:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  10292c:	00 
  10292d:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102934:	00 
  102935:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  10293c:	00 
  10293d:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102944:	e8 89 e3 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  102949:	8b 45 08             	mov    0x8(%ebp),%eax
  10294c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  10294f:	eb 7d                	jmp    1029ce <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102954:	83 c0 04             	add    $0x4,%eax
  102957:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10295e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102964:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102967:	0f a3 10             	bt     %edx,(%eax)
  10296a:	19 c0                	sbb    %eax,%eax
  10296c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  10296f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102973:	0f 95 c0             	setne  %al
  102976:	0f b6 c0             	movzbl %al,%eax
  102979:	85 c0                	test   %eax,%eax
  10297b:	75 24                	jne    1029a1 <default_init_memmap+0x88>
  10297d:	c7 44 24 0c 61 67 10 	movl   $0x106761,0xc(%esp)
  102984:	00 
  102985:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10298c:	00 
  10298d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102994:	00 
  102995:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10299c:	e8 31 e3 ff ff       	call   100cd2 <__panic>
        p->flags = p->property = 0;
  1029a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029a4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1029ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029ae:	8b 50 08             	mov    0x8(%eax),%edx
  1029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029b4:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  1029b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1029be:	00 
  1029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029c2:	89 04 24             	mov    %eax,(%esp)
  1029c5:	e8 15 ff ff ff       	call   1028df <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  1029ca:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1029ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029d1:	89 d0                	mov    %edx,%eax
  1029d3:	c1 e0 02             	shl    $0x2,%eax
  1029d6:	01 d0                	add    %edx,%eax
  1029d8:	c1 e0 02             	shl    $0x2,%eax
  1029db:	89 c2                	mov    %eax,%edx
  1029dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e0:	01 d0                	add    %edx,%eax
  1029e2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1029e5:	0f 85 66 ff ff ff    	jne    102951 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  1029eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029f1:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1029f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f7:	83 c0 04             	add    $0x4,%eax
  1029fa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  102a01:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102a04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102a0a:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  102a0d:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a16:	01 d0                	add    %edx,%eax
  102a18:	a3 18 af 11 00       	mov    %eax,0x11af18
    list_add_before(&free_list, &(base->page_link));
  102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a20:	83 c0 0c             	add    $0xc,%eax
  102a23:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
  102a2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102a2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a30:	8b 00                	mov    (%eax),%eax
  102a32:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102a35:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102a38:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102a41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a47:	89 10                	mov    %edx,(%eax)
  102a49:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102a4c:	8b 10                	mov    (%eax),%edx
  102a4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a51:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102a54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a57:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102a5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a60:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102a63:	89 10                	mov    %edx,(%eax)
}
  102a65:	c9                   	leave  
  102a66:	c3                   	ret    

00102a67 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102a67:	55                   	push   %ebp
  102a68:	89 e5                	mov    %esp,%ebp
  102a6a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102a6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a71:	75 24                	jne    102a97 <default_alloc_pages+0x30>
  102a73:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  102a7a:	00 
  102a7b:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102a82:	00 
  102a83:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102a8a:	00 
  102a8b:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102a92:	e8 3b e2 ff ff       	call   100cd2 <__panic>
    if (n > nr_free) {
  102a97:	a1 18 af 11 00       	mov    0x11af18,%eax
  102a9c:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a9f:	73 0a                	jae    102aab <default_alloc_pages+0x44>
        return NULL;
  102aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  102aa6:	e9 3d 01 00 00       	jmp    102be8 <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  102aab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102ab2:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  102ab9:	eb 1c                	jmp    102ad7 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102abe:	83 e8 0c             	sub    $0xc,%eax
  102ac1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ac7:	8b 40 08             	mov    0x8(%eax),%eax
  102aca:	3b 45 08             	cmp    0x8(%ebp),%eax
  102acd:	72 08                	jb     102ad7 <default_alloc_pages+0x70>
            page = p;
  102acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102ad5:	eb 18                	jmp    102aef <default_alloc_pages+0x88>
  102ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ada:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ae0:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  102ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ae6:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102aed:	75 cc                	jne    102abb <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102af3:	0f 84 ec 00 00 00    	je     102be5 <default_alloc_pages+0x17e>
        if (page->property > n) {
  102af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102afc:	8b 40 08             	mov    0x8(%eax),%eax
  102aff:	3b 45 08             	cmp    0x8(%ebp),%eax
  102b02:	0f 86 8c 00 00 00    	jbe    102b94 <default_alloc_pages+0x12d>
            struct Page* p = page + n;
  102b08:	8b 55 08             	mov    0x8(%ebp),%edx
  102b0b:	89 d0                	mov    %edx,%eax
  102b0d:	c1 e0 02             	shl    $0x2,%eax
  102b10:	01 d0                	add    %edx,%eax
  102b12:	c1 e0 02             	shl    $0x2,%eax
  102b15:	89 c2                	mov    %eax,%edx
  102b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b1a:	01 d0                	add    %edx,%eax
  102b1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
			p->property = page->property - n;
  102b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b22:	8b 40 08             	mov    0x8(%eax),%eax
  102b25:	2b 45 08             	sub    0x8(%ebp),%eax
  102b28:	89 c2                	mov    %eax,%edx
  102b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b2d:	89 50 08             	mov    %edx,0x8(%eax)
			SetPageProperty(p);
  102b30:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b33:	83 c0 04             	add    $0x4,%eax
  102b36:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102b3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102b40:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b43:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102b46:	0f ab 10             	bts    %edx,(%eax)
			list_add_after(&(page->page_link),&(p->page_link));
  102b49:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b4c:	83 c0 0c             	add    $0xc,%eax
  102b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b52:	83 c2 0c             	add    $0xc,%edx
  102b55:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102b58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b5e:	8b 40 04             	mov    0x4(%eax),%eax
  102b61:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b64:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102b6a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102b6d:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b70:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b73:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b76:	89 10                	mov    %edx,(%eax)
  102b78:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b7b:	8b 10                	mov    (%eax),%edx
  102b7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b80:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b83:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b86:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b89:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b8f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b92:	89 10                	mov    %edx,(%eax)
    }
		list_del(&(page->page_link));
  102b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b97:	83 c0 0c             	add    $0xc,%eax
  102b9a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102b9d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102ba0:	8b 40 04             	mov    0x4(%eax),%eax
  102ba3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102ba6:	8b 12                	mov    (%edx),%edx
  102ba8:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102bab:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102bae:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102bb1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102bb4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102bb7:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102bba:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102bbd:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  102bbf:	a1 18 af 11 00       	mov    0x11af18,%eax
  102bc4:	2b 45 08             	sub    0x8(%ebp),%eax
  102bc7:	a3 18 af 11 00       	mov    %eax,0x11af18
        ClearPageProperty(page);
  102bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bcf:	83 c0 04             	add    $0x4,%eax
  102bd2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102bd9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102bdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102bdf:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102be2:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102be8:	c9                   	leave  
  102be9:	c3                   	ret    

00102bea <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102bea:	55                   	push   %ebp
  102beb:	89 e5                	mov    %esp,%ebp
  102bed:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102bf3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102bf7:	75 24                	jne    102c1d <default_free_pages+0x33>
  102bf9:	c7 44 24 0c 30 67 10 	movl   $0x106730,0xc(%esp)
  102c00:	00 
  102c01:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102c08:	00 
  102c09:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  102c10:	00 
  102c11:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102c18:	e8 b5 e0 ff ff       	call   100cd2 <__panic>
    struct Page *p = base;
  102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102c23:	e9 9d 00 00 00       	jmp    102cc5 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c2b:	83 c0 04             	add    $0x4,%eax
  102c2e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102c35:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c38:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102c3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102c3e:	0f a3 10             	bt     %edx,(%eax)
  102c41:	19 c0                	sbb    %eax,%eax
  102c43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102c46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102c4a:	0f 95 c0             	setne  %al
  102c4d:	0f b6 c0             	movzbl %al,%eax
  102c50:	85 c0                	test   %eax,%eax
  102c52:	75 2c                	jne    102c80 <default_free_pages+0x96>
  102c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c57:	83 c0 04             	add    $0x4,%eax
  102c5a:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102c61:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c67:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c6a:	0f a3 10             	bt     %edx,(%eax)
  102c6d:	19 c0                	sbb    %eax,%eax
  102c6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102c72:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c76:	0f 95 c0             	setne  %al
  102c79:	0f b6 c0             	movzbl %al,%eax
  102c7c:	85 c0                	test   %eax,%eax
  102c7e:	74 24                	je     102ca4 <default_free_pages+0xba>
  102c80:	c7 44 24 0c 74 67 10 	movl   $0x106774,0xc(%esp)
  102c87:	00 
  102c88:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102c8f:	00 
  102c90:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  102c97:	00 
  102c98:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102c9f:	e8 2e e0 ff ff       	call   100cd2 <__panic>
        p->flags = 0;
  102ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ca7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102cae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102cb5:	00 
  102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cb9:	89 04 24             	mov    %eax,(%esp)
  102cbc:	e8 1e fc ff ff       	call   1028df <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102cc1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cc8:	89 d0                	mov    %edx,%eax
  102cca:	c1 e0 02             	shl    $0x2,%eax
  102ccd:	01 d0                	add    %edx,%eax
  102ccf:	c1 e0 02             	shl    $0x2,%eax
  102cd2:	89 c2                	mov    %eax,%edx
  102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd7:	01 d0                	add    %edx,%eax
  102cd9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102cdc:	0f 85 46 ff ff ff    	jne    102c28 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ce8:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cee:	83 c0 04             	add    $0x4,%eax
  102cf1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102cf8:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cfb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102cfe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102d01:	0f ab 10             	bts    %edx,(%eax)
  102d04:	c7 45 cc 10 af 11 00 	movl   $0x11af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102d0b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102d0e:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102d14:	e9 08 01 00 00       	jmp    102e21 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d1c:	83 e8 0c             	sub    $0xc,%eax
  102d1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d25:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102d28:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102d2b:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102d2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  102d31:	8b 45 08             	mov    0x8(%ebp),%eax
  102d34:	8b 50 08             	mov    0x8(%eax),%edx
  102d37:	89 d0                	mov    %edx,%eax
  102d39:	c1 e0 02             	shl    $0x2,%eax
  102d3c:	01 d0                	add    %edx,%eax
  102d3e:	c1 e0 02             	shl    $0x2,%eax
  102d41:	89 c2                	mov    %eax,%edx
  102d43:	8b 45 08             	mov    0x8(%ebp),%eax
  102d46:	01 d0                	add    %edx,%eax
  102d48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102d4b:	75 5a                	jne    102da7 <default_free_pages+0x1bd>
            base->property += p->property;
  102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d50:	8b 50 08             	mov    0x8(%eax),%edx
  102d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d56:	8b 40 08             	mov    0x8(%eax),%eax
  102d59:	01 c2                	add    %eax,%edx
  102d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d5e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d64:	83 c0 04             	add    $0x4,%eax
  102d67:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102d6e:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d71:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d74:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d77:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d7d:	83 c0 0c             	add    $0xc,%eax
  102d80:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d83:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d86:	8b 40 04             	mov    0x4(%eax),%eax
  102d89:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d8c:	8b 12                	mov    (%edx),%edx
  102d8e:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102d91:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d94:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d97:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d9a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102d9d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102da0:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102da3:	89 10                	mov    %edx,(%eax)
  102da5:	eb 7a                	jmp    102e21 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102daa:	8b 50 08             	mov    0x8(%eax),%edx
  102dad:	89 d0                	mov    %edx,%eax
  102daf:	c1 e0 02             	shl    $0x2,%eax
  102db2:	01 d0                	add    %edx,%eax
  102db4:	c1 e0 02             	shl    $0x2,%eax
  102db7:	89 c2                	mov    %eax,%edx
  102db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dbc:	01 d0                	add    %edx,%eax
  102dbe:	3b 45 08             	cmp    0x8(%ebp),%eax
  102dc1:	75 5e                	jne    102e21 <default_free_pages+0x237>
            p->property += base->property;
  102dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dc6:	8b 50 08             	mov    0x8(%eax),%edx
  102dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  102dcc:	8b 40 08             	mov    0x8(%eax),%eax
  102dcf:	01 c2                	add    %eax,%edx
  102dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dd4:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  102dda:	83 c0 04             	add    $0x4,%eax
  102ddd:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102de4:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102de7:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102dea:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102ded:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102df3:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102df9:	83 c0 0c             	add    $0xc,%eax
  102dfc:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102dff:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102e02:	8b 40 04             	mov    0x4(%eax),%eax
  102e05:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102e08:	8b 12                	mov    (%edx),%edx
  102e0a:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102e0d:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102e10:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e13:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102e16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102e19:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102e1c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102e1f:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102e21:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102e28:	0f 85 eb fe ff ff    	jne    102d19 <default_free_pages+0x12f>
  102e2e:	c7 45 9c 10 af 11 00 	movl   $0x11af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102e35:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102e38:	8b 40 04             	mov    0x4(%eax),%eax
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
	le = list_next(&free_list);
  102e3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(le != &free_list)
  102e3e:	eb 73                	jmp    102eb3 <default_free_pages+0x2c9>
	{
		p = le2page(le,page_link);
  102e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e43:	83 e8 0c             	sub    $0xc,%eax
  102e46:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(base + base->property <= p)
  102e49:	8b 45 08             	mov    0x8(%ebp),%eax
  102e4c:	8b 50 08             	mov    0x8(%eax),%edx
  102e4f:	89 d0                	mov    %edx,%eax
  102e51:	c1 e0 02             	shl    $0x2,%eax
  102e54:	01 d0                	add    %edx,%eax
  102e56:	c1 e0 02             	shl    $0x2,%eax
  102e59:	89 c2                	mov    %eax,%edx
  102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e5e:	01 d0                	add    %edx,%eax
  102e60:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e63:	77 3f                	ja     102ea4 <default_free_pages+0x2ba>
		{
			assert(base + n < p);
  102e65:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e68:	89 d0                	mov    %edx,%eax
  102e6a:	c1 e0 02             	shl    $0x2,%eax
  102e6d:	01 d0                	add    %edx,%eax
  102e6f:	c1 e0 02             	shl    $0x2,%eax
  102e72:	89 c2                	mov    %eax,%edx
  102e74:	8b 45 08             	mov    0x8(%ebp),%eax
  102e77:	01 d0                	add    %edx,%eax
  102e79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e7c:	72 24                	jb     102ea2 <default_free_pages+0x2b8>
  102e7e:	c7 44 24 0c 99 67 10 	movl   $0x106799,0xc(%esp)
  102e85:	00 
  102e86:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102e8d:	00 
  102e8e:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
  102e95:	00 
  102e96:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102e9d:	e8 30 de ff ff       	call   100cd2 <__panic>
			break;
  102ea2:	eb 18                	jmp    102ebc <default_free_pages+0x2d2>
  102ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ea7:	89 45 98             	mov    %eax,-0x68(%ebp)
  102eaa:	8b 45 98             	mov    -0x68(%ebp),%eax
  102ead:	8b 40 04             	mov    0x4(%eax),%eax
		}
		le = list_next(le);
  102eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
            base = p;
            list_del(&(p->page_link));
        }
    }
	le = list_next(&free_list);
	while(le != &free_list)
  102eb3:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102eba:	75 84                	jne    102e40 <default_free_pages+0x256>
			assert(base + n < p);
			break;
		}
		le = list_next(le);
	}
    nr_free += n;
  102ebc:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ec5:	01 d0                	add    %edx,%eax
  102ec7:	a3 18 af 11 00       	mov    %eax,0x11af18
	list_add_before(le,&(base->page_link));
  102ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  102ecf:	8d 50 0c             	lea    0xc(%eax),%edx
  102ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ed5:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102ed8:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102edb:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102ede:	8b 00                	mov    (%eax),%eax
  102ee0:	8b 55 90             	mov    -0x70(%ebp),%edx
  102ee3:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102ee6:	89 45 88             	mov    %eax,-0x78(%ebp)
  102ee9:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102eec:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102eef:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102ef2:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102ef5:	89 10                	mov    %edx,(%eax)
  102ef7:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102efa:	8b 10                	mov    (%eax),%edx
  102efc:	8b 45 88             	mov    -0x78(%ebp),%eax
  102eff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102f02:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f05:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102f08:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102f0b:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102f0e:	8b 55 88             	mov    -0x78(%ebp),%edx
  102f11:	89 10                	mov    %edx,(%eax)
}
  102f13:	c9                   	leave  
  102f14:	c3                   	ret    

00102f15 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102f15:	55                   	push   %ebp
  102f16:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102f18:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102f1d:	5d                   	pop    %ebp
  102f1e:	c3                   	ret    

00102f1f <basic_check>:

static void
basic_check(void) {
  102f1f:	55                   	push   %ebp
  102f20:	89 e5                	mov    %esp,%ebp
  102f22:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102f25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102f38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f3f:	e8 db 0e 00 00       	call   103e1f <alloc_pages>
  102f44:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102f47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102f4b:	75 24                	jne    102f71 <basic_check+0x52>
  102f4d:	c7 44 24 0c a6 67 10 	movl   $0x1067a6,0xc(%esp)
  102f54:	00 
  102f55:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102f5c:	00 
  102f5d:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  102f64:	00 
  102f65:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102f6c:	e8 61 dd ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  102f71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f78:	e8 a2 0e 00 00       	call   103e1f <alloc_pages>
  102f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f84:	75 24                	jne    102faa <basic_check+0x8b>
  102f86:	c7 44 24 0c c2 67 10 	movl   $0x1067c2,0xc(%esp)
  102f8d:	00 
  102f8e:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102f95:	00 
  102f96:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  102f9d:	00 
  102f9e:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102fa5:	e8 28 dd ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  102faa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102fb1:	e8 69 0e 00 00       	call   103e1f <alloc_pages>
  102fb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102fb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102fbd:	75 24                	jne    102fe3 <basic_check+0xc4>
  102fbf:	c7 44 24 0c de 67 10 	movl   $0x1067de,0xc(%esp)
  102fc6:	00 
  102fc7:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  102fce:	00 
  102fcf:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  102fd6:	00 
  102fd7:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  102fde:	e8 ef dc ff ff       	call   100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fe6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102fe9:	74 10                	je     102ffb <basic_check+0xdc>
  102feb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ff1:	74 08                	je     102ffb <basic_check+0xdc>
  102ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ff6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102ff9:	75 24                	jne    10301f <basic_check+0x100>
  102ffb:	c7 44 24 0c fc 67 10 	movl   $0x1067fc,0xc(%esp)
  103002:	00 
  103003:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10300a:	00 
  10300b:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  103012:	00 
  103013:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10301a:	e8 b3 dc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10301f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103022:	89 04 24             	mov    %eax,(%esp)
  103025:	e8 ab f8 ff ff       	call   1028d5 <page_ref>
  10302a:	85 c0                	test   %eax,%eax
  10302c:	75 1e                	jne    10304c <basic_check+0x12d>
  10302e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103031:	89 04 24             	mov    %eax,(%esp)
  103034:	e8 9c f8 ff ff       	call   1028d5 <page_ref>
  103039:	85 c0                	test   %eax,%eax
  10303b:	75 0f                	jne    10304c <basic_check+0x12d>
  10303d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103040:	89 04 24             	mov    %eax,(%esp)
  103043:	e8 8d f8 ff ff       	call   1028d5 <page_ref>
  103048:	85 c0                	test   %eax,%eax
  10304a:	74 24                	je     103070 <basic_check+0x151>
  10304c:	c7 44 24 0c 20 68 10 	movl   $0x106820,0xc(%esp)
  103053:	00 
  103054:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10305b:	00 
  10305c:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  103063:	00 
  103064:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10306b:	e8 62 dc ff ff       	call   100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103070:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103073:	89 04 24             	mov    %eax,(%esp)
  103076:	e8 44 f8 ff ff       	call   1028bf <page2pa>
  10307b:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103081:	c1 e2 0c             	shl    $0xc,%edx
  103084:	39 d0                	cmp    %edx,%eax
  103086:	72 24                	jb     1030ac <basic_check+0x18d>
  103088:	c7 44 24 0c 5c 68 10 	movl   $0x10685c,0xc(%esp)
  10308f:	00 
  103090:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103097:	00 
  103098:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  10309f:	00 
  1030a0:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1030a7:	e8 26 dc ff ff       	call   100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1030ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030af:	89 04 24             	mov    %eax,(%esp)
  1030b2:	e8 08 f8 ff ff       	call   1028bf <page2pa>
  1030b7:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1030bd:	c1 e2 0c             	shl    $0xc,%edx
  1030c0:	39 d0                	cmp    %edx,%eax
  1030c2:	72 24                	jb     1030e8 <basic_check+0x1c9>
  1030c4:	c7 44 24 0c 79 68 10 	movl   $0x106879,0xc(%esp)
  1030cb:	00 
  1030cc:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1030d3:	00 
  1030d4:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  1030db:	00 
  1030dc:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1030e3:	e8 ea db ff ff       	call   100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1030e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030eb:	89 04 24             	mov    %eax,(%esp)
  1030ee:	e8 cc f7 ff ff       	call   1028bf <page2pa>
  1030f3:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1030f9:	c1 e2 0c             	shl    $0xc,%edx
  1030fc:	39 d0                	cmp    %edx,%eax
  1030fe:	72 24                	jb     103124 <basic_check+0x205>
  103100:	c7 44 24 0c 96 68 10 	movl   $0x106896,0xc(%esp)
  103107:	00 
  103108:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10310f:	00 
  103110:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  103117:	00 
  103118:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10311f:	e8 ae db ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  103124:	a1 10 af 11 00       	mov    0x11af10,%eax
  103129:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  10312f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103132:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103135:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10313c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10313f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103142:	89 50 04             	mov    %edx,0x4(%eax)
  103145:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103148:	8b 50 04             	mov    0x4(%eax),%edx
  10314b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10314e:	89 10                	mov    %edx,(%eax)
  103150:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  103157:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10315a:	8b 40 04             	mov    0x4(%eax),%eax
  10315d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103160:	0f 94 c0             	sete   %al
  103163:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103166:	85 c0                	test   %eax,%eax
  103168:	75 24                	jne    10318e <basic_check+0x26f>
  10316a:	c7 44 24 0c b3 68 10 	movl   $0x1068b3,0xc(%esp)
  103171:	00 
  103172:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103179:	00 
  10317a:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  103181:	00 
  103182:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103189:	e8 44 db ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  10318e:	a1 18 af 11 00       	mov    0x11af18,%eax
  103193:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  103196:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  10319d:	00 00 00 

    assert(alloc_page() == NULL);
  1031a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031a7:	e8 73 0c 00 00       	call   103e1f <alloc_pages>
  1031ac:	85 c0                	test   %eax,%eax
  1031ae:	74 24                	je     1031d4 <basic_check+0x2b5>
  1031b0:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  1031b7:	00 
  1031b8:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1031bf:	00 
  1031c0:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1031c7:	00 
  1031c8:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1031cf:	e8 fe da ff ff       	call   100cd2 <__panic>

    free_page(p0);
  1031d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031db:	00 
  1031dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031df:	89 04 24             	mov    %eax,(%esp)
  1031e2:	e8 70 0c 00 00       	call   103e57 <free_pages>
    free_page(p1);
  1031e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031ee:	00 
  1031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031f2:	89 04 24             	mov    %eax,(%esp)
  1031f5:	e8 5d 0c 00 00       	call   103e57 <free_pages>
    free_page(p2);
  1031fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103201:	00 
  103202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103205:	89 04 24             	mov    %eax,(%esp)
  103208:	e8 4a 0c 00 00       	call   103e57 <free_pages>
    assert(nr_free == 3);
  10320d:	a1 18 af 11 00       	mov    0x11af18,%eax
  103212:	83 f8 03             	cmp    $0x3,%eax
  103215:	74 24                	je     10323b <basic_check+0x31c>
  103217:	c7 44 24 0c df 68 10 	movl   $0x1068df,0xc(%esp)
  10321e:	00 
  10321f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103226:	00 
  103227:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  10322e:	00 
  10322f:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103236:	e8 97 da ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
  10323b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103242:	e8 d8 0b 00 00       	call   103e1f <alloc_pages>
  103247:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10324a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10324e:	75 24                	jne    103274 <basic_check+0x355>
  103250:	c7 44 24 0c a6 67 10 	movl   $0x1067a6,0xc(%esp)
  103257:	00 
  103258:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10325f:	00 
  103260:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  103267:	00 
  103268:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10326f:	e8 5e da ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103274:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10327b:	e8 9f 0b 00 00       	call   103e1f <alloc_pages>
  103280:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103283:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103287:	75 24                	jne    1032ad <basic_check+0x38e>
  103289:	c7 44 24 0c c2 67 10 	movl   $0x1067c2,0xc(%esp)
  103290:	00 
  103291:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103298:	00 
  103299:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
  1032a0:	00 
  1032a1:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1032a8:	e8 25 da ff ff       	call   100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1032ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032b4:	e8 66 0b 00 00       	call   103e1f <alloc_pages>
  1032b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1032bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1032c0:	75 24                	jne    1032e6 <basic_check+0x3c7>
  1032c2:	c7 44 24 0c de 67 10 	movl   $0x1067de,0xc(%esp)
  1032c9:	00 
  1032ca:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1032d1:	00 
  1032d2:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  1032d9:	00 
  1032da:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1032e1:	e8 ec d9 ff ff       	call   100cd2 <__panic>

    assert(alloc_page() == NULL);
  1032e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032ed:	e8 2d 0b 00 00       	call   103e1f <alloc_pages>
  1032f2:	85 c0                	test   %eax,%eax
  1032f4:	74 24                	je     10331a <basic_check+0x3fb>
  1032f6:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  1032fd:	00 
  1032fe:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103305:	00 
  103306:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
  10330d:	00 
  10330e:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103315:	e8 b8 d9 ff ff       	call   100cd2 <__panic>

    free_page(p0);
  10331a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103321:	00 
  103322:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103325:	89 04 24             	mov    %eax,(%esp)
  103328:	e8 2a 0b 00 00       	call   103e57 <free_pages>
  10332d:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  103334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103337:	8b 40 04             	mov    0x4(%eax),%eax
  10333a:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10333d:	0f 94 c0             	sete   %al
  103340:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103343:	85 c0                	test   %eax,%eax
  103345:	74 24                	je     10336b <basic_check+0x44c>
  103347:	c7 44 24 0c ec 68 10 	movl   $0x1068ec,0xc(%esp)
  10334e:	00 
  10334f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103356:	00 
  103357:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  10335e:	00 
  10335f:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103366:	e8 67 d9 ff ff       	call   100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  10336b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103372:	e8 a8 0a 00 00       	call   103e1f <alloc_pages>
  103377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10337a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10337d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103380:	74 24                	je     1033a6 <basic_check+0x487>
  103382:	c7 44 24 0c 04 69 10 	movl   $0x106904,0xc(%esp)
  103389:	00 
  10338a:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103391:	00 
  103392:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  103399:	00 
  10339a:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1033a1:	e8 2c d9 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  1033a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033ad:	e8 6d 0a 00 00       	call   103e1f <alloc_pages>
  1033b2:	85 c0                	test   %eax,%eax
  1033b4:	74 24                	je     1033da <basic_check+0x4bb>
  1033b6:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  1033bd:	00 
  1033be:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1033c5:	00 
  1033c6:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  1033cd:	00 
  1033ce:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1033d5:	e8 f8 d8 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  1033da:	a1 18 af 11 00       	mov    0x11af18,%eax
  1033df:	85 c0                	test   %eax,%eax
  1033e1:	74 24                	je     103407 <basic_check+0x4e8>
  1033e3:	c7 44 24 0c 1d 69 10 	movl   $0x10691d,0xc(%esp)
  1033ea:	00 
  1033eb:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1033f2:	00 
  1033f3:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
  1033fa:	00 
  1033fb:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103402:	e8 cb d8 ff ff       	call   100cd2 <__panic>
    free_list = free_list_store;
  103407:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10340a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10340d:	a3 10 af 11 00       	mov    %eax,0x11af10
  103412:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  103418:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10341b:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  103420:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103427:	00 
  103428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10342b:	89 04 24             	mov    %eax,(%esp)
  10342e:	e8 24 0a 00 00       	call   103e57 <free_pages>
    free_page(p1);
  103433:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10343a:	00 
  10343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10343e:	89 04 24             	mov    %eax,(%esp)
  103441:	e8 11 0a 00 00       	call   103e57 <free_pages>
    free_page(p2);
  103446:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10344d:	00 
  10344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103451:	89 04 24             	mov    %eax,(%esp)
  103454:	e8 fe 09 00 00       	call   103e57 <free_pages>
}
  103459:	c9                   	leave  
  10345a:	c3                   	ret    

0010345b <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  10345b:	55                   	push   %ebp
  10345c:	89 e5                	mov    %esp,%ebp
  10345e:	53                   	push   %ebx
  10345f:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  103465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10346c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103473:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10347a:	eb 6b                	jmp    1034e7 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  10347c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10347f:	83 e8 0c             	sub    $0xc,%eax
  103482:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  103485:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103488:	83 c0 04             	add    $0x4,%eax
  10348b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103492:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103495:	8b 45 cc             	mov    -0x34(%ebp),%eax
  103498:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10349b:	0f a3 10             	bt     %edx,(%eax)
  10349e:	19 c0                	sbb    %eax,%eax
  1034a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1034a3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1034a7:	0f 95 c0             	setne  %al
  1034aa:	0f b6 c0             	movzbl %al,%eax
  1034ad:	85 c0                	test   %eax,%eax
  1034af:	75 24                	jne    1034d5 <default_check+0x7a>
  1034b1:	c7 44 24 0c 2a 69 10 	movl   $0x10692a,0xc(%esp)
  1034b8:	00 
  1034b9:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1034c0:	00 
  1034c1:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  1034c8:	00 
  1034c9:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1034d0:	e8 fd d7 ff ff       	call   100cd2 <__panic>
        count ++, total += p->property;
  1034d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1034d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034dc:	8b 50 08             	mov    0x8(%eax),%edx
  1034df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034e2:	01 d0                	add    %edx,%eax
  1034e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1034ed:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1034f0:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1034f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1034f6:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1034fd:	0f 85 79 ff ff ff    	jne    10347c <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  103503:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  103506:	e8 7e 09 00 00       	call   103e89 <nr_free_pages>
  10350b:	39 c3                	cmp    %eax,%ebx
  10350d:	74 24                	je     103533 <default_check+0xd8>
  10350f:	c7 44 24 0c 3a 69 10 	movl   $0x10693a,0xc(%esp)
  103516:	00 
  103517:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10351e:	00 
  10351f:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  103526:	00 
  103527:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10352e:	e8 9f d7 ff ff       	call   100cd2 <__panic>

    basic_check();
  103533:	e8 e7 f9 ff ff       	call   102f1f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103538:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10353f:	e8 db 08 00 00       	call   103e1f <alloc_pages>
  103544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  103547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10354b:	75 24                	jne    103571 <default_check+0x116>
  10354d:	c7 44 24 0c 53 69 10 	movl   $0x106953,0xc(%esp)
  103554:	00 
  103555:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10355c:	00 
  10355d:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  103564:	00 
  103565:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10356c:	e8 61 d7 ff ff       	call   100cd2 <__panic>
    assert(!PageProperty(p0));
  103571:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103574:	83 c0 04             	add    $0x4,%eax
  103577:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10357e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103581:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103584:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103587:	0f a3 10             	bt     %edx,(%eax)
  10358a:	19 c0                	sbb    %eax,%eax
  10358c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  10358f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103593:	0f 95 c0             	setne  %al
  103596:	0f b6 c0             	movzbl %al,%eax
  103599:	85 c0                	test   %eax,%eax
  10359b:	74 24                	je     1035c1 <default_check+0x166>
  10359d:	c7 44 24 0c 5e 69 10 	movl   $0x10695e,0xc(%esp)
  1035a4:	00 
  1035a5:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1035ac:	00 
  1035ad:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1035b4:	00 
  1035b5:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1035bc:	e8 11 d7 ff ff       	call   100cd2 <__panic>

    list_entry_t free_list_store = free_list;
  1035c1:	a1 10 af 11 00       	mov    0x11af10,%eax
  1035c6:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  1035cc:	89 45 80             	mov    %eax,-0x80(%ebp)
  1035cf:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1035d2:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1035d9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035dc:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1035df:	89 50 04             	mov    %edx,0x4(%eax)
  1035e2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035e5:	8b 50 04             	mov    0x4(%eax),%edx
  1035e8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035eb:	89 10                	mov    %edx,(%eax)
  1035ed:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1035f4:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1035f7:	8b 40 04             	mov    0x4(%eax),%eax
  1035fa:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  1035fd:	0f 94 c0             	sete   %al
  103600:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103603:	85 c0                	test   %eax,%eax
  103605:	75 24                	jne    10362b <default_check+0x1d0>
  103607:	c7 44 24 0c b3 68 10 	movl   $0x1068b3,0xc(%esp)
  10360e:	00 
  10360f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103616:	00 
  103617:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  10361e:	00 
  10361f:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103626:	e8 a7 d6 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  10362b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103632:	e8 e8 07 00 00       	call   103e1f <alloc_pages>
  103637:	85 c0                	test   %eax,%eax
  103639:	74 24                	je     10365f <default_check+0x204>
  10363b:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  103642:	00 
  103643:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10364a:	00 
  10364b:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  103652:	00 
  103653:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10365a:	e8 73 d6 ff ff       	call   100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
  10365f:	a1 18 af 11 00       	mov    0x11af18,%eax
  103664:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  103667:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  10366e:	00 00 00 

    free_pages(p0 + 2, 3);
  103671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103674:	83 c0 28             	add    $0x28,%eax
  103677:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10367e:	00 
  10367f:	89 04 24             	mov    %eax,(%esp)
  103682:	e8 d0 07 00 00       	call   103e57 <free_pages>
    assert(alloc_pages(4) == NULL);
  103687:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10368e:	e8 8c 07 00 00       	call   103e1f <alloc_pages>
  103693:	85 c0                	test   %eax,%eax
  103695:	74 24                	je     1036bb <default_check+0x260>
  103697:	c7 44 24 0c 70 69 10 	movl   $0x106970,0xc(%esp)
  10369e:	00 
  10369f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1036a6:	00 
  1036a7:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1036ae:	00 
  1036af:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1036b6:	e8 17 d6 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1036bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036be:	83 c0 28             	add    $0x28,%eax
  1036c1:	83 c0 04             	add    $0x4,%eax
  1036c4:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1036cb:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1036d1:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1036d4:	0f a3 10             	bt     %edx,(%eax)
  1036d7:	19 c0                	sbb    %eax,%eax
  1036d9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1036dc:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1036e0:	0f 95 c0             	setne  %al
  1036e3:	0f b6 c0             	movzbl %al,%eax
  1036e6:	85 c0                	test   %eax,%eax
  1036e8:	74 0e                	je     1036f8 <default_check+0x29d>
  1036ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036ed:	83 c0 28             	add    $0x28,%eax
  1036f0:	8b 40 08             	mov    0x8(%eax),%eax
  1036f3:	83 f8 03             	cmp    $0x3,%eax
  1036f6:	74 24                	je     10371c <default_check+0x2c1>
  1036f8:	c7 44 24 0c 88 69 10 	movl   $0x106988,0xc(%esp)
  1036ff:	00 
  103700:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103707:	00 
  103708:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10370f:	00 
  103710:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103717:	e8 b6 d5 ff ff       	call   100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10371c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103723:	e8 f7 06 00 00       	call   103e1f <alloc_pages>
  103728:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10372b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10372f:	75 24                	jne    103755 <default_check+0x2fa>
  103731:	c7 44 24 0c b4 69 10 	movl   $0x1069b4,0xc(%esp)
  103738:	00 
  103739:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103740:	00 
  103741:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  103748:	00 
  103749:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103750:	e8 7d d5 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  103755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10375c:	e8 be 06 00 00       	call   103e1f <alloc_pages>
  103761:	85 c0                	test   %eax,%eax
  103763:	74 24                	je     103789 <default_check+0x32e>
  103765:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  10376c:	00 
  10376d:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103774:	00 
  103775:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  10377c:	00 
  10377d:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103784:	e8 49 d5 ff ff       	call   100cd2 <__panic>
    assert(p0 + 2 == p1);
  103789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10378c:	83 c0 28             	add    $0x28,%eax
  10378f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103792:	74 24                	je     1037b8 <default_check+0x35d>
  103794:	c7 44 24 0c d2 69 10 	movl   $0x1069d2,0xc(%esp)
  10379b:	00 
  10379c:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1037a3:	00 
  1037a4:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  1037ab:	00 
  1037ac:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1037b3:	e8 1a d5 ff ff       	call   100cd2 <__panic>

    p2 = p0 + 1;
  1037b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037bb:	83 c0 14             	add    $0x14,%eax
  1037be:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  1037c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1037c8:	00 
  1037c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037cc:	89 04 24             	mov    %eax,(%esp)
  1037cf:	e8 83 06 00 00       	call   103e57 <free_pages>
    free_pages(p1, 3);
  1037d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1037db:	00 
  1037dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037df:	89 04 24             	mov    %eax,(%esp)
  1037e2:	e8 70 06 00 00       	call   103e57 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1037e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037ea:	83 c0 04             	add    $0x4,%eax
  1037ed:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1037f4:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037f7:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1037fa:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1037fd:	0f a3 10             	bt     %edx,(%eax)
  103800:	19 c0                	sbb    %eax,%eax
  103802:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103805:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103809:	0f 95 c0             	setne  %al
  10380c:	0f b6 c0             	movzbl %al,%eax
  10380f:	85 c0                	test   %eax,%eax
  103811:	74 0b                	je     10381e <default_check+0x3c3>
  103813:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103816:	8b 40 08             	mov    0x8(%eax),%eax
  103819:	83 f8 01             	cmp    $0x1,%eax
  10381c:	74 24                	je     103842 <default_check+0x3e7>
  10381e:	c7 44 24 0c e0 69 10 	movl   $0x1069e0,0xc(%esp)
  103825:	00 
  103826:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  10382d:	00 
  10382e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  103835:	00 
  103836:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  10383d:	e8 90 d4 ff ff       	call   100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103842:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103845:	83 c0 04             	add    $0x4,%eax
  103848:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  10384f:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103852:	8b 45 90             	mov    -0x70(%ebp),%eax
  103855:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103858:	0f a3 10             	bt     %edx,(%eax)
  10385b:	19 c0                	sbb    %eax,%eax
  10385d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103860:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103864:	0f 95 c0             	setne  %al
  103867:	0f b6 c0             	movzbl %al,%eax
  10386a:	85 c0                	test   %eax,%eax
  10386c:	74 0b                	je     103879 <default_check+0x41e>
  10386e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103871:	8b 40 08             	mov    0x8(%eax),%eax
  103874:	83 f8 03             	cmp    $0x3,%eax
  103877:	74 24                	je     10389d <default_check+0x442>
  103879:	c7 44 24 0c 08 6a 10 	movl   $0x106a08,0xc(%esp)
  103880:	00 
  103881:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103888:	00 
  103889:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  103890:	00 
  103891:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103898:	e8 35 d4 ff ff       	call   100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10389d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038a4:	e8 76 05 00 00       	call   103e1f <alloc_pages>
  1038a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038af:	83 e8 14             	sub    $0x14,%eax
  1038b2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1038b5:	74 24                	je     1038db <default_check+0x480>
  1038b7:	c7 44 24 0c 2e 6a 10 	movl   $0x106a2e,0xc(%esp)
  1038be:	00 
  1038bf:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1038c6:	00 
  1038c7:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  1038ce:	00 
  1038cf:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1038d6:	e8 f7 d3 ff ff       	call   100cd2 <__panic>
    free_page(p0);
  1038db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038e2:	00 
  1038e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038e6:	89 04 24             	mov    %eax,(%esp)
  1038e9:	e8 69 05 00 00       	call   103e57 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1038ee:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1038f5:	e8 25 05 00 00       	call   103e1f <alloc_pages>
  1038fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103900:	83 c0 14             	add    $0x14,%eax
  103903:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  103906:	74 24                	je     10392c <default_check+0x4d1>
  103908:	c7 44 24 0c 4c 6a 10 	movl   $0x106a4c,0xc(%esp)
  10390f:	00 
  103910:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103917:	00 
  103918:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  10391f:	00 
  103920:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103927:	e8 a6 d3 ff ff       	call   100cd2 <__panic>

    free_pages(p0, 2);
  10392c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103933:	00 
  103934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103937:	89 04 24             	mov    %eax,(%esp)
  10393a:	e8 18 05 00 00       	call   103e57 <free_pages>
    free_page(p2);
  10393f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103946:	00 
  103947:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10394a:	89 04 24             	mov    %eax,(%esp)
  10394d:	e8 05 05 00 00       	call   103e57 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103952:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103959:	e8 c1 04 00 00       	call   103e1f <alloc_pages>
  10395e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103961:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103965:	75 24                	jne    10398b <default_check+0x530>
  103967:	c7 44 24 0c 6c 6a 10 	movl   $0x106a6c,0xc(%esp)
  10396e:	00 
  10396f:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103976:	00 
  103977:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  10397e:	00 
  10397f:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103986:	e8 47 d3 ff ff       	call   100cd2 <__panic>
    assert(alloc_page() == NULL);
  10398b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103992:	e8 88 04 00 00       	call   103e1f <alloc_pages>
  103997:	85 c0                	test   %eax,%eax
  103999:	74 24                	je     1039bf <default_check+0x564>
  10399b:	c7 44 24 0c ca 68 10 	movl   $0x1068ca,0xc(%esp)
  1039a2:	00 
  1039a3:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1039aa:	00 
  1039ab:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  1039b2:	00 
  1039b3:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1039ba:	e8 13 d3 ff ff       	call   100cd2 <__panic>

    assert(nr_free == 0);
  1039bf:	a1 18 af 11 00       	mov    0x11af18,%eax
  1039c4:	85 c0                	test   %eax,%eax
  1039c6:	74 24                	je     1039ec <default_check+0x591>
  1039c8:	c7 44 24 0c 1d 69 10 	movl   $0x10691d,0xc(%esp)
  1039cf:	00 
  1039d0:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  1039d7:	00 
  1039d8:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  1039df:	00 
  1039e0:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  1039e7:	e8 e6 d2 ff ff       	call   100cd2 <__panic>
    nr_free = nr_free_store;
  1039ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1039ef:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  1039f4:	8b 45 80             	mov    -0x80(%ebp),%eax
  1039f7:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1039fa:	a3 10 af 11 00       	mov    %eax,0x11af10
  1039ff:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  103a05:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103a0c:	00 
  103a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103a10:	89 04 24             	mov    %eax,(%esp)
  103a13:	e8 3f 04 00 00       	call   103e57 <free_pages>

    le = &free_list;
  103a18:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103a1f:	eb 5b                	jmp    103a7c <default_check+0x621>
        assert(le->next->prev == le && le->prev->next == le);
  103a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a24:	8b 40 04             	mov    0x4(%eax),%eax
  103a27:	8b 00                	mov    (%eax),%eax
  103a29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103a2c:	75 0d                	jne    103a3b <default_check+0x5e0>
  103a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a31:	8b 00                	mov    (%eax),%eax
  103a33:	8b 40 04             	mov    0x4(%eax),%eax
  103a36:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103a39:	74 24                	je     103a5f <default_check+0x604>
  103a3b:	c7 44 24 0c 8c 6a 10 	movl   $0x106a8c,0xc(%esp)
  103a42:	00 
  103a43:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103a4a:	00 
  103a4b:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
  103a52:	00 
  103a53:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103a5a:	e8 73 d2 ff ff       	call   100cd2 <__panic>
        struct Page *p = le2page(le, page_link);
  103a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a62:	83 e8 0c             	sub    $0xc,%eax
  103a65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  103a68:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  103a6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103a6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103a72:	8b 40 08             	mov    0x8(%eax),%eax
  103a75:	29 c2                	sub    %eax,%edx
  103a77:	89 d0                	mov    %edx,%eax
  103a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a7f:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  103a82:	8b 45 88             	mov    -0x78(%ebp),%eax
  103a85:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  103a88:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103a8b:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  103a92:	75 8d                	jne    103a21 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  103a94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103a98:	74 24                	je     103abe <default_check+0x663>
  103a9a:	c7 44 24 0c b9 6a 10 	movl   $0x106ab9,0xc(%esp)
  103aa1:	00 
  103aa2:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103aa9:	00 
  103aaa:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
  103ab1:	00 
  103ab2:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103ab9:	e8 14 d2 ff ff       	call   100cd2 <__panic>
    assert(total == 0);
  103abe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103ac2:	74 24                	je     103ae8 <default_check+0x68d>
  103ac4:	c7 44 24 0c c4 6a 10 	movl   $0x106ac4,0xc(%esp)
  103acb:	00 
  103acc:	c7 44 24 08 36 67 10 	movl   $0x106736,0x8(%esp)
  103ad3:	00 
  103ad4:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  103adb:	00 
  103adc:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  103ae3:	e8 ea d1 ff ff       	call   100cd2 <__panic>
}
  103ae8:	81 c4 94 00 00 00    	add    $0x94,%esp
  103aee:	5b                   	pop    %ebx
  103aef:	5d                   	pop    %ebp
  103af0:	c3                   	ret    

00103af1 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103af1:	55                   	push   %ebp
  103af2:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103af4:	8b 55 08             	mov    0x8(%ebp),%edx
  103af7:	a1 24 af 11 00       	mov    0x11af24,%eax
  103afc:	29 c2                	sub    %eax,%edx
  103afe:	89 d0                	mov    %edx,%eax
  103b00:	c1 f8 02             	sar    $0x2,%eax
  103b03:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103b09:	5d                   	pop    %ebp
  103b0a:	c3                   	ret    

00103b0b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103b0b:	55                   	push   %ebp
  103b0c:	89 e5                	mov    %esp,%ebp
  103b0e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103b11:	8b 45 08             	mov    0x8(%ebp),%eax
  103b14:	89 04 24             	mov    %eax,(%esp)
  103b17:	e8 d5 ff ff ff       	call   103af1 <page2ppn>
  103b1c:	c1 e0 0c             	shl    $0xc,%eax
}
  103b1f:	c9                   	leave  
  103b20:	c3                   	ret    

00103b21 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103b21:	55                   	push   %ebp
  103b22:	89 e5                	mov    %esp,%ebp
  103b24:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103b27:	8b 45 08             	mov    0x8(%ebp),%eax
  103b2a:	c1 e8 0c             	shr    $0xc,%eax
  103b2d:	89 c2                	mov    %eax,%edx
  103b2f:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b34:	39 c2                	cmp    %eax,%edx
  103b36:	72 1c                	jb     103b54 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103b38:	c7 44 24 08 00 6b 10 	movl   $0x106b00,0x8(%esp)
  103b3f:	00 
  103b40:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103b47:	00 
  103b48:	c7 04 24 1f 6b 10 00 	movl   $0x106b1f,(%esp)
  103b4f:	e8 7e d1 ff ff       	call   100cd2 <__panic>
    }
    return &pages[PPN(pa)];
  103b54:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  103b5d:	c1 e8 0c             	shr    $0xc,%eax
  103b60:	89 c2                	mov    %eax,%edx
  103b62:	89 d0                	mov    %edx,%eax
  103b64:	c1 e0 02             	shl    $0x2,%eax
  103b67:	01 d0                	add    %edx,%eax
  103b69:	c1 e0 02             	shl    $0x2,%eax
  103b6c:	01 c8                	add    %ecx,%eax
}
  103b6e:	c9                   	leave  
  103b6f:	c3                   	ret    

00103b70 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103b70:	55                   	push   %ebp
  103b71:	89 e5                	mov    %esp,%ebp
  103b73:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103b76:	8b 45 08             	mov    0x8(%ebp),%eax
  103b79:	89 04 24             	mov    %eax,(%esp)
  103b7c:	e8 8a ff ff ff       	call   103b0b <page2pa>
  103b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b87:	c1 e8 0c             	shr    $0xc,%eax
  103b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b8d:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b92:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103b95:	72 23                	jb     103bba <page2kva+0x4a>
  103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b9e:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  103ba5:	00 
  103ba6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103bad:	00 
  103bae:	c7 04 24 1f 6b 10 00 	movl   $0x106b1f,(%esp)
  103bb5:	e8 18 d1 ff ff       	call   100cd2 <__panic>
  103bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103bbd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103bc2:	c9                   	leave  
  103bc3:	c3                   	ret    

00103bc4 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103bc4:	55                   	push   %ebp
  103bc5:	89 e5                	mov    %esp,%ebp
  103bc7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103bca:	8b 45 08             	mov    0x8(%ebp),%eax
  103bcd:	83 e0 01             	and    $0x1,%eax
  103bd0:	85 c0                	test   %eax,%eax
  103bd2:	75 1c                	jne    103bf0 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103bd4:	c7 44 24 08 54 6b 10 	movl   $0x106b54,0x8(%esp)
  103bdb:	00 
  103bdc:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103be3:	00 
  103be4:	c7 04 24 1f 6b 10 00 	movl   $0x106b1f,(%esp)
  103beb:	e8 e2 d0 ff ff       	call   100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  103bf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103bf8:	89 04 24             	mov    %eax,(%esp)
  103bfb:	e8 21 ff ff ff       	call   103b21 <pa2page>
}
  103c00:	c9                   	leave  
  103c01:	c3                   	ret    

00103c02 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103c02:	55                   	push   %ebp
  103c03:	89 e5                	mov    %esp,%ebp
  103c05:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103c08:	8b 45 08             	mov    0x8(%ebp),%eax
  103c0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c10:	89 04 24             	mov    %eax,(%esp)
  103c13:	e8 09 ff ff ff       	call   103b21 <pa2page>
}
  103c18:	c9                   	leave  
  103c19:	c3                   	ret    

00103c1a <page_ref>:

static inline int
page_ref(struct Page *page) {
  103c1a:	55                   	push   %ebp
  103c1b:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  103c20:	8b 00                	mov    (%eax),%eax
}
  103c22:	5d                   	pop    %ebp
  103c23:	c3                   	ret    

00103c24 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103c24:	55                   	push   %ebp
  103c25:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103c27:	8b 45 08             	mov    0x8(%ebp),%eax
  103c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  103c2d:	89 10                	mov    %edx,(%eax)
}
  103c2f:	5d                   	pop    %ebp
  103c30:	c3                   	ret    

00103c31 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103c31:	55                   	push   %ebp
  103c32:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103c34:	8b 45 08             	mov    0x8(%ebp),%eax
  103c37:	8b 00                	mov    (%eax),%eax
  103c39:	8d 50 01             	lea    0x1(%eax),%edx
  103c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  103c3f:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103c41:	8b 45 08             	mov    0x8(%ebp),%eax
  103c44:	8b 00                	mov    (%eax),%eax
}
  103c46:	5d                   	pop    %ebp
  103c47:	c3                   	ret    

00103c48 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103c48:	55                   	push   %ebp
  103c49:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  103c4e:	8b 00                	mov    (%eax),%eax
  103c50:	8d 50 ff             	lea    -0x1(%eax),%edx
  103c53:	8b 45 08             	mov    0x8(%ebp),%eax
  103c56:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103c58:	8b 45 08             	mov    0x8(%ebp),%eax
  103c5b:	8b 00                	mov    (%eax),%eax
}
  103c5d:	5d                   	pop    %ebp
  103c5e:	c3                   	ret    

00103c5f <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103c5f:	55                   	push   %ebp
  103c60:	89 e5                	mov    %esp,%ebp
  103c62:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103c65:	9c                   	pushf  
  103c66:	58                   	pop    %eax
  103c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103c6d:	25 00 02 00 00       	and    $0x200,%eax
  103c72:	85 c0                	test   %eax,%eax
  103c74:	74 0c                	je     103c82 <__intr_save+0x23>
        intr_disable();
  103c76:	e8 4b da ff ff       	call   1016c6 <intr_disable>
        return 1;
  103c7b:	b8 01 00 00 00       	mov    $0x1,%eax
  103c80:	eb 05                	jmp    103c87 <__intr_save+0x28>
    }
    return 0;
  103c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103c87:	c9                   	leave  
  103c88:	c3                   	ret    

00103c89 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103c89:	55                   	push   %ebp
  103c8a:	89 e5                	mov    %esp,%ebp
  103c8c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103c8f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103c93:	74 05                	je     103c9a <__intr_restore+0x11>
        intr_enable();
  103c95:	e8 26 da ff ff       	call   1016c0 <intr_enable>
    }
}
  103c9a:	c9                   	leave  
  103c9b:	c3                   	ret    

00103c9c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103c9c:	55                   	push   %ebp
  103c9d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  103ca2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103ca5:	b8 23 00 00 00       	mov    $0x23,%eax
  103caa:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103cac:	b8 23 00 00 00       	mov    $0x23,%eax
  103cb1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103cb3:	b8 10 00 00 00       	mov    $0x10,%eax
  103cb8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103cba:	b8 10 00 00 00       	mov    $0x10,%eax
  103cbf:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103cc1:	b8 10 00 00 00       	mov    $0x10,%eax
  103cc6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103cc8:	ea cf 3c 10 00 08 00 	ljmp   $0x8,$0x103ccf
}
  103ccf:	5d                   	pop    %ebp
  103cd0:	c3                   	ret    

00103cd1 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103cd1:	55                   	push   %ebp
  103cd2:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  103cd7:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103cdc:	5d                   	pop    %ebp
  103cdd:	c3                   	ret    

00103cde <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103cde:	55                   	push   %ebp
  103cdf:	89 e5                	mov    %esp,%ebp
  103ce1:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103ce4:	b8 00 70 11 00       	mov    $0x117000,%eax
  103ce9:	89 04 24             	mov    %eax,(%esp)
  103cec:	e8 e0 ff ff ff       	call   103cd1 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103cf1:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103cf8:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103cfa:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103d01:	68 00 
  103d03:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103d08:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103d0e:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103d13:	c1 e8 10             	shr    $0x10,%eax
  103d16:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103d1b:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d22:	83 e0 f0             	and    $0xfffffff0,%eax
  103d25:	83 c8 09             	or     $0x9,%eax
  103d28:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d2d:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d34:	83 e0 ef             	and    $0xffffffef,%eax
  103d37:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d3c:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d43:	83 e0 9f             	and    $0xffffff9f,%eax
  103d46:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d4b:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103d52:	83 c8 80             	or     $0xffffff80,%eax
  103d55:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103d5a:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d61:	83 e0 f0             	and    $0xfffffff0,%eax
  103d64:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d69:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d70:	83 e0 ef             	and    $0xffffffef,%eax
  103d73:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d78:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d7f:	83 e0 df             	and    $0xffffffdf,%eax
  103d82:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d87:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d8e:	83 c8 40             	or     $0x40,%eax
  103d91:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d96:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d9d:	83 e0 7f             	and    $0x7f,%eax
  103da0:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103da5:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103daa:	c1 e8 18             	shr    $0x18,%eax
  103dad:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103db2:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103db9:	e8 de fe ff ff       	call   103c9c <lgdt>
  103dbe:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103dc4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103dc8:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103dcb:	c9                   	leave  
  103dcc:	c3                   	ret    

00103dcd <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103dcd:	55                   	push   %ebp
  103dce:	89 e5                	mov    %esp,%ebp
  103dd0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103dd3:	c7 05 1c af 11 00 e4 	movl   $0x106ae4,0x11af1c
  103dda:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103ddd:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103de2:	8b 00                	mov    (%eax),%eax
  103de4:	89 44 24 04          	mov    %eax,0x4(%esp)
  103de8:	c7 04 24 80 6b 10 00 	movl   $0x106b80,(%esp)
  103def:	e8 54 c5 ff ff       	call   100348 <cprintf>
    pmm_manager->init();
  103df4:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103df9:	8b 40 04             	mov    0x4(%eax),%eax
  103dfc:	ff d0                	call   *%eax
}
  103dfe:	c9                   	leave  
  103dff:	c3                   	ret    

00103e00 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103e00:	55                   	push   %ebp
  103e01:	89 e5                	mov    %esp,%ebp
  103e03:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103e06:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103e0b:	8b 40 08             	mov    0x8(%eax),%eax
  103e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e11:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e15:	8b 55 08             	mov    0x8(%ebp),%edx
  103e18:	89 14 24             	mov    %edx,(%esp)
  103e1b:	ff d0                	call   *%eax
}
  103e1d:	c9                   	leave  
  103e1e:	c3                   	ret    

00103e1f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103e1f:	55                   	push   %ebp
  103e20:	89 e5                	mov    %esp,%ebp
  103e22:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103e25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103e2c:	e8 2e fe ff ff       	call   103c5f <__intr_save>
  103e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103e34:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103e39:	8b 40 0c             	mov    0xc(%eax),%eax
  103e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  103e3f:	89 14 24             	mov    %edx,(%esp)
  103e42:	ff d0                	call   *%eax
  103e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e4a:	89 04 24             	mov    %eax,(%esp)
  103e4d:	e8 37 fe ff ff       	call   103c89 <__intr_restore>
    return page;
  103e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103e55:	c9                   	leave  
  103e56:	c3                   	ret    

00103e57 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103e57:	55                   	push   %ebp
  103e58:	89 e5                	mov    %esp,%ebp
  103e5a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103e5d:	e8 fd fd ff ff       	call   103c5f <__intr_save>
  103e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103e65:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103e6a:	8b 40 10             	mov    0x10(%eax),%eax
  103e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e70:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e74:	8b 55 08             	mov    0x8(%ebp),%edx
  103e77:	89 14 24             	mov    %edx,(%esp)
  103e7a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e7f:	89 04 24             	mov    %eax,(%esp)
  103e82:	e8 02 fe ff ff       	call   103c89 <__intr_restore>
}
  103e87:	c9                   	leave  
  103e88:	c3                   	ret    

00103e89 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103e89:	55                   	push   %ebp
  103e8a:	89 e5                	mov    %esp,%ebp
  103e8c:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103e8f:	e8 cb fd ff ff       	call   103c5f <__intr_save>
  103e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103e97:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103e9c:	8b 40 14             	mov    0x14(%eax),%eax
  103e9f:	ff d0                	call   *%eax
  103ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ea7:	89 04 24             	mov    %eax,(%esp)
  103eaa:	e8 da fd ff ff       	call   103c89 <__intr_restore>
    return ret;
  103eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103eb2:	c9                   	leave  
  103eb3:	c3                   	ret    

00103eb4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103eb4:	55                   	push   %ebp
  103eb5:	89 e5                	mov    %esp,%ebp
  103eb7:	57                   	push   %edi
  103eb8:	56                   	push   %esi
  103eb9:	53                   	push   %ebx
  103eba:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103ec0:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103ec7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103ece:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103ed5:	c7 04 24 97 6b 10 00 	movl   $0x106b97,(%esp)
  103edc:	e8 67 c4 ff ff       	call   100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103ee1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103ee8:	e9 15 01 00 00       	jmp    104002 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103eed:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ef0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ef3:	89 d0                	mov    %edx,%eax
  103ef5:	c1 e0 02             	shl    $0x2,%eax
  103ef8:	01 d0                	add    %edx,%eax
  103efa:	c1 e0 02             	shl    $0x2,%eax
  103efd:	01 c8                	add    %ecx,%eax
  103eff:	8b 50 08             	mov    0x8(%eax),%edx
  103f02:	8b 40 04             	mov    0x4(%eax),%eax
  103f05:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103f08:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103f0b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f11:	89 d0                	mov    %edx,%eax
  103f13:	c1 e0 02             	shl    $0x2,%eax
  103f16:	01 d0                	add    %edx,%eax
  103f18:	c1 e0 02             	shl    $0x2,%eax
  103f1b:	01 c8                	add    %ecx,%eax
  103f1d:	8b 48 0c             	mov    0xc(%eax),%ecx
  103f20:	8b 58 10             	mov    0x10(%eax),%ebx
  103f23:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103f26:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103f29:	01 c8                	add    %ecx,%eax
  103f2b:	11 da                	adc    %ebx,%edx
  103f2d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103f30:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103f33:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f36:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f39:	89 d0                	mov    %edx,%eax
  103f3b:	c1 e0 02             	shl    $0x2,%eax
  103f3e:	01 d0                	add    %edx,%eax
  103f40:	c1 e0 02             	shl    $0x2,%eax
  103f43:	01 c8                	add    %ecx,%eax
  103f45:	83 c0 14             	add    $0x14,%eax
  103f48:	8b 00                	mov    (%eax),%eax
  103f4a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103f50:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f53:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f56:	83 c0 ff             	add    $0xffffffff,%eax
  103f59:	83 d2 ff             	adc    $0xffffffff,%edx
  103f5c:	89 c6                	mov    %eax,%esi
  103f5e:	89 d7                	mov    %edx,%edi
  103f60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f63:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f66:	89 d0                	mov    %edx,%eax
  103f68:	c1 e0 02             	shl    $0x2,%eax
  103f6b:	01 d0                	add    %edx,%eax
  103f6d:	c1 e0 02             	shl    $0x2,%eax
  103f70:	01 c8                	add    %ecx,%eax
  103f72:	8b 48 0c             	mov    0xc(%eax),%ecx
  103f75:	8b 58 10             	mov    0x10(%eax),%ebx
  103f78:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103f7e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103f82:	89 74 24 14          	mov    %esi,0x14(%esp)
  103f86:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103f8a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103f8d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f94:	89 54 24 10          	mov    %edx,0x10(%esp)
  103f98:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103f9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103fa0:	c7 04 24 a4 6b 10 00 	movl   $0x106ba4,(%esp)
  103fa7:	e8 9c c3 ff ff       	call   100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103fac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103faf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103fb2:	89 d0                	mov    %edx,%eax
  103fb4:	c1 e0 02             	shl    $0x2,%eax
  103fb7:	01 d0                	add    %edx,%eax
  103fb9:	c1 e0 02             	shl    $0x2,%eax
  103fbc:	01 c8                	add    %ecx,%eax
  103fbe:	83 c0 14             	add    $0x14,%eax
  103fc1:	8b 00                	mov    (%eax),%eax
  103fc3:	83 f8 01             	cmp    $0x1,%eax
  103fc6:	75 36                	jne    103ffe <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103fce:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103fd1:	77 2b                	ja     103ffe <page_init+0x14a>
  103fd3:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103fd6:	72 05                	jb     103fdd <page_init+0x129>
  103fd8:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103fdb:	73 21                	jae    103ffe <page_init+0x14a>
  103fdd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103fe1:	77 1b                	ja     103ffe <page_init+0x14a>
  103fe3:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103fe7:	72 09                	jb     103ff2 <page_init+0x13e>
  103fe9:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103ff0:	77 0c                	ja     103ffe <page_init+0x14a>
                maxpa = end;
  103ff2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103ff5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103ffb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103ffe:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104002:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104005:	8b 00                	mov    (%eax),%eax
  104007:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10400a:	0f 8f dd fe ff ff    	jg     103eed <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  104010:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104014:	72 1d                	jb     104033 <page_init+0x17f>
  104016:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10401a:	77 09                	ja     104025 <page_init+0x171>
  10401c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  104023:	76 0e                	jbe    104033 <page_init+0x17f>
        maxpa = KMEMSIZE;
  104025:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  10402c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  104033:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104039:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10403d:	c1 ea 0c             	shr    $0xc,%edx
  104040:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  104045:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  10404c:	b8 28 af 11 00       	mov    $0x11af28,%eax
  104051:	8d 50 ff             	lea    -0x1(%eax),%edx
  104054:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104057:	01 d0                	add    %edx,%eax
  104059:	89 45 a8             	mov    %eax,-0x58(%ebp)
  10405c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10405f:	ba 00 00 00 00       	mov    $0x0,%edx
  104064:	f7 75 ac             	divl   -0x54(%ebp)
  104067:	89 d0                	mov    %edx,%eax
  104069:	8b 55 a8             	mov    -0x58(%ebp),%edx
  10406c:	29 c2                	sub    %eax,%edx
  10406e:	89 d0                	mov    %edx,%eax
  104070:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  104075:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10407c:	eb 2f                	jmp    1040ad <page_init+0x1f9>
        SetPageReserved(pages + i);
  10407e:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  104084:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104087:	89 d0                	mov    %edx,%eax
  104089:	c1 e0 02             	shl    $0x2,%eax
  10408c:	01 d0                	add    %edx,%eax
  10408e:	c1 e0 02             	shl    $0x2,%eax
  104091:	01 c8                	add    %ecx,%eax
  104093:	83 c0 04             	add    $0x4,%eax
  104096:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  10409d:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1040a0:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1040a3:	8b 55 90             	mov    -0x70(%ebp),%edx
  1040a6:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  1040a9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  1040ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040b0:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1040b5:	39 c2                	cmp    %eax,%edx
  1040b7:	72 c5                	jb     10407e <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  1040b9:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1040bf:	89 d0                	mov    %edx,%eax
  1040c1:	c1 e0 02             	shl    $0x2,%eax
  1040c4:	01 d0                	add    %edx,%eax
  1040c6:	c1 e0 02             	shl    $0x2,%eax
  1040c9:	89 c2                	mov    %eax,%edx
  1040cb:	a1 24 af 11 00       	mov    0x11af24,%eax
  1040d0:	01 d0                	add    %edx,%eax
  1040d2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  1040d5:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  1040dc:	77 23                	ja     104101 <page_init+0x24d>
  1040de:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1040e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1040e5:	c7 44 24 08 d4 6b 10 	movl   $0x106bd4,0x8(%esp)
  1040ec:	00 
  1040ed:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  1040f4:	00 
  1040f5:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1040fc:	e8 d1 cb ff ff       	call   100cd2 <__panic>
  104101:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104104:	05 00 00 00 40       	add    $0x40000000,%eax
  104109:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  10410c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104113:	e9 74 01 00 00       	jmp    10428c <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104118:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10411b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10411e:	89 d0                	mov    %edx,%eax
  104120:	c1 e0 02             	shl    $0x2,%eax
  104123:	01 d0                	add    %edx,%eax
  104125:	c1 e0 02             	shl    $0x2,%eax
  104128:	01 c8                	add    %ecx,%eax
  10412a:	8b 50 08             	mov    0x8(%eax),%edx
  10412d:	8b 40 04             	mov    0x4(%eax),%eax
  104130:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104133:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104136:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104139:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10413c:	89 d0                	mov    %edx,%eax
  10413e:	c1 e0 02             	shl    $0x2,%eax
  104141:	01 d0                	add    %edx,%eax
  104143:	c1 e0 02             	shl    $0x2,%eax
  104146:	01 c8                	add    %ecx,%eax
  104148:	8b 48 0c             	mov    0xc(%eax),%ecx
  10414b:	8b 58 10             	mov    0x10(%eax),%ebx
  10414e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104151:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104154:	01 c8                	add    %ecx,%eax
  104156:	11 da                	adc    %ebx,%edx
  104158:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10415b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  10415e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104161:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104164:	89 d0                	mov    %edx,%eax
  104166:	c1 e0 02             	shl    $0x2,%eax
  104169:	01 d0                	add    %edx,%eax
  10416b:	c1 e0 02             	shl    $0x2,%eax
  10416e:	01 c8                	add    %ecx,%eax
  104170:	83 c0 14             	add    $0x14,%eax
  104173:	8b 00                	mov    (%eax),%eax
  104175:	83 f8 01             	cmp    $0x1,%eax
  104178:	0f 85 0a 01 00 00    	jne    104288 <page_init+0x3d4>
            if (begin < freemem) {
  10417e:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104181:	ba 00 00 00 00       	mov    $0x0,%edx
  104186:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104189:	72 17                	jb     1041a2 <page_init+0x2ee>
  10418b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10418e:	77 05                	ja     104195 <page_init+0x2e1>
  104190:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  104193:	76 0d                	jbe    1041a2 <page_init+0x2ee>
                begin = freemem;
  104195:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104198:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10419b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1041a2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1041a6:	72 1d                	jb     1041c5 <page_init+0x311>
  1041a8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1041ac:	77 09                	ja     1041b7 <page_init+0x303>
  1041ae:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1041b5:	76 0e                	jbe    1041c5 <page_init+0x311>
                end = KMEMSIZE;
  1041b7:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1041be:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1041c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041cb:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041ce:	0f 87 b4 00 00 00    	ja     104288 <page_init+0x3d4>
  1041d4:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041d7:	72 09                	jb     1041e2 <page_init+0x32e>
  1041d9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041dc:	0f 83 a6 00 00 00    	jae    104288 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  1041e2:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  1041e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1041ec:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1041ef:	01 d0                	add    %edx,%eax
  1041f1:	83 e8 01             	sub    $0x1,%eax
  1041f4:	89 45 98             	mov    %eax,-0x68(%ebp)
  1041f7:	8b 45 98             	mov    -0x68(%ebp),%eax
  1041fa:	ba 00 00 00 00       	mov    $0x0,%edx
  1041ff:	f7 75 9c             	divl   -0x64(%ebp)
  104202:	89 d0                	mov    %edx,%eax
  104204:	8b 55 98             	mov    -0x68(%ebp),%edx
  104207:	29 c2                	sub    %eax,%edx
  104209:	89 d0                	mov    %edx,%eax
  10420b:	ba 00 00 00 00       	mov    $0x0,%edx
  104210:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104213:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104216:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104219:	89 45 94             	mov    %eax,-0x6c(%ebp)
  10421c:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10421f:	ba 00 00 00 00       	mov    $0x0,%edx
  104224:	89 c7                	mov    %eax,%edi
  104226:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  10422c:	89 7d 80             	mov    %edi,-0x80(%ebp)
  10422f:	89 d0                	mov    %edx,%eax
  104231:	83 e0 00             	and    $0x0,%eax
  104234:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104237:	8b 45 80             	mov    -0x80(%ebp),%eax
  10423a:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10423d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104240:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104243:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104246:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104249:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10424c:	77 3a                	ja     104288 <page_init+0x3d4>
  10424e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104251:	72 05                	jb     104258 <page_init+0x3a4>
  104253:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104256:	73 30                	jae    104288 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104258:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  10425b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  10425e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104261:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104264:	29 c8                	sub    %ecx,%eax
  104266:	19 da                	sbb    %ebx,%edx
  104268:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  10426c:	c1 ea 0c             	shr    $0xc,%edx
  10426f:	89 c3                	mov    %eax,%ebx
  104271:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104274:	89 04 24             	mov    %eax,(%esp)
  104277:	e8 a5 f8 ff ff       	call   103b21 <pa2page>
  10427c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104280:	89 04 24             	mov    %eax,(%esp)
  104283:	e8 78 fb ff ff       	call   103e00 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  104288:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  10428c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10428f:	8b 00                	mov    (%eax),%eax
  104291:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  104294:	0f 8f 7e fe ff ff    	jg     104118 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  10429a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1042a0:	5b                   	pop    %ebx
  1042a1:	5e                   	pop    %esi
  1042a2:	5f                   	pop    %edi
  1042a3:	5d                   	pop    %ebp
  1042a4:	c3                   	ret    

001042a5 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1042a5:	55                   	push   %ebp
  1042a6:	89 e5                	mov    %esp,%ebp
  1042a8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1042ab:	8b 45 14             	mov    0x14(%ebp),%eax
  1042ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  1042b1:	31 d0                	xor    %edx,%eax
  1042b3:	25 ff 0f 00 00       	and    $0xfff,%eax
  1042b8:	85 c0                	test   %eax,%eax
  1042ba:	74 24                	je     1042e0 <boot_map_segment+0x3b>
  1042bc:	c7 44 24 0c 06 6c 10 	movl   $0x106c06,0xc(%esp)
  1042c3:	00 
  1042c4:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1042cb:	00 
  1042cc:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1042d3:	00 
  1042d4:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1042db:	e8 f2 c9 ff ff       	call   100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1042e0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1042e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042ea:	25 ff 0f 00 00       	and    $0xfff,%eax
  1042ef:	89 c2                	mov    %eax,%edx
  1042f1:	8b 45 10             	mov    0x10(%ebp),%eax
  1042f4:	01 c2                	add    %eax,%edx
  1042f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1042f9:	01 d0                	add    %edx,%eax
  1042fb:	83 e8 01             	sub    $0x1,%eax
  1042fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104301:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104304:	ba 00 00 00 00       	mov    $0x0,%edx
  104309:	f7 75 f0             	divl   -0x10(%ebp)
  10430c:	89 d0                	mov    %edx,%eax
  10430e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104311:	29 c2                	sub    %eax,%edx
  104313:	89 d0                	mov    %edx,%eax
  104315:	c1 e8 0c             	shr    $0xc,%eax
  104318:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10431b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10431e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104321:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104324:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104329:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10432c:	8b 45 14             	mov    0x14(%ebp),%eax
  10432f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104335:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10433a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10433d:	eb 6b                	jmp    1043aa <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10433f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104346:	00 
  104347:	8b 45 0c             	mov    0xc(%ebp),%eax
  10434a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10434e:	8b 45 08             	mov    0x8(%ebp),%eax
  104351:	89 04 24             	mov    %eax,(%esp)
  104354:	e8 82 01 00 00       	call   1044db <get_pte>
  104359:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10435c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104360:	75 24                	jne    104386 <boot_map_segment+0xe1>
  104362:	c7 44 24 0c 32 6c 10 	movl   $0x106c32,0xc(%esp)
  104369:	00 
  10436a:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104371:	00 
  104372:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104379:	00 
  10437a:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104381:	e8 4c c9 ff ff       	call   100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
  104386:	8b 45 18             	mov    0x18(%ebp),%eax
  104389:	8b 55 14             	mov    0x14(%ebp),%edx
  10438c:	09 d0                	or     %edx,%eax
  10438e:	83 c8 01             	or     $0x1,%eax
  104391:	89 c2                	mov    %eax,%edx
  104393:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104396:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104398:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10439c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1043a3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1043aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1043ae:	75 8f                	jne    10433f <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1043b0:	c9                   	leave  
  1043b1:	c3                   	ret    

001043b2 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1043b2:	55                   	push   %ebp
  1043b3:	89 e5                	mov    %esp,%ebp
  1043b5:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1043b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1043bf:	e8 5b fa ff ff       	call   103e1f <alloc_pages>
  1043c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1043c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1043cb:	75 1c                	jne    1043e9 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1043cd:	c7 44 24 08 3f 6c 10 	movl   $0x106c3f,0x8(%esp)
  1043d4:	00 
  1043d5:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1043dc:	00 
  1043dd:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1043e4:	e8 e9 c8 ff ff       	call   100cd2 <__panic>
    }
    return page2kva(p);
  1043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043ec:	89 04 24             	mov    %eax,(%esp)
  1043ef:	e8 7c f7 ff ff       	call   103b70 <page2kva>
}
  1043f4:	c9                   	leave  
  1043f5:	c3                   	ret    

001043f6 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1043f6:	55                   	push   %ebp
  1043f7:	89 e5                	mov    %esp,%ebp
  1043f9:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1043fc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104401:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104404:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10440b:	77 23                	ja     104430 <pmm_init+0x3a>
  10440d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104414:	c7 44 24 08 d4 6b 10 	movl   $0x106bd4,0x8(%esp)
  10441b:	00 
  10441c:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104423:	00 
  104424:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10442b:	e8 a2 c8 ff ff       	call   100cd2 <__panic>
  104430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104433:	05 00 00 00 40       	add    $0x40000000,%eax
  104438:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10443d:	e8 8b f9 ff ff       	call   103dcd <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104442:	e8 6d fa ff ff       	call   103eb4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104447:	e8 db 03 00 00       	call   104827 <check_alloc_page>

    check_pgdir();
  10444c:	e8 f4 03 00 00       	call   104845 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104451:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104456:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  10445c:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104461:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104464:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  10446b:	77 23                	ja     104490 <pmm_init+0x9a>
  10446d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104470:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104474:	c7 44 24 08 d4 6b 10 	movl   $0x106bd4,0x8(%esp)
  10447b:	00 
  10447c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  104483:	00 
  104484:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10448b:	e8 42 c8 ff ff       	call   100cd2 <__panic>
  104490:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104493:	05 00 00 00 40       	add    $0x40000000,%eax
  104498:	83 c8 03             	or     $0x3,%eax
  10449b:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10449d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1044a2:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1044a9:	00 
  1044aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1044b1:	00 
  1044b2:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1044b9:	38 
  1044ba:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1044c1:	c0 
  1044c2:	89 04 24             	mov    %eax,(%esp)
  1044c5:	e8 db fd ff ff       	call   1042a5 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1044ca:	e8 0f f8 ff ff       	call   103cde <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1044cf:	e8 0c 0a 00 00       	call   104ee0 <check_boot_pgdir>

    print_pgdir();
  1044d4:	e8 94 0e 00 00       	call   10536d <print_pgdir>

}
  1044d9:	c9                   	leave  
  1044da:	c3                   	ret    

001044db <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1044db:	55                   	push   %ebp
  1044dc:	89 e5                	mov    %esp,%ebp
  1044de:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
	pde_t *pde = &pgdir[PDX(la)];
  1044e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044e4:	c1 e8 16             	shr    $0x16,%eax
  1044e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1044ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1044f1:	01 d0                	add    %edx,%eax
  1044f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!(*pde & PTE_P))
  1044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1044f9:	8b 00                	mov    (%eax),%eax
  1044fb:	83 e0 01             	and    $0x1,%eax
  1044fe:	85 c0                	test   %eax,%eax
  104500:	0f 85 af 00 00 00    	jne    1045b5 <get_pte+0xda>
	{
		struct Page* page;
		if(!create || (page = alloc_page()) == NULL)
  104506:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10450a:	74 15                	je     104521 <get_pte+0x46>
  10450c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104513:	e8 07 f9 ff ff       	call   103e1f <alloc_pages>
  104518:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10451b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10451f:	75 0a                	jne    10452b <get_pte+0x50>
			return NULL;
  104521:	b8 00 00 00 00       	mov    $0x0,%eax
  104526:	e9 e6 00 00 00       	jmp    104611 <get_pte+0x136>
		set_page_ref(page,1);
  10452b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104532:	00 
  104533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104536:	89 04 24             	mov    %eax,(%esp)
  104539:	e8 e6 f6 ff ff       	call   103c24 <set_page_ref>
		uintptr_t pa = page2pa(page);
  10453e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104541:	89 04 24             	mov    %eax,(%esp)
  104544:	e8 c2 f5 ff ff       	call   103b0b <page2pa>
  104549:	89 45 ec             	mov    %eax,-0x14(%ebp)
		memset(KADDR(pa),0,PGSIZE);
  10454c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10454f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104552:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104555:	c1 e8 0c             	shr    $0xc,%eax
  104558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10455b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104560:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  104563:	72 23                	jb     104588 <get_pte+0xad>
  104565:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104568:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10456c:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  104573:	00 
  104574:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  10457b:	00 
  10457c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104583:	e8 4a c7 ff ff       	call   100cd2 <__panic>
  104588:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10458b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104590:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104597:	00 
  104598:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10459f:	00 
  1045a0:	89 04 24             	mov    %eax,(%esp)
  1045a3:	e8 e3 18 00 00       	call   105e8b <memset>
		*pde = pa | PTE_P | PTE_U | PTE_W;
  1045a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1045ab:	83 c8 07             	or     $0x7,%eax
  1045ae:	89 c2                	mov    %eax,%edx
  1045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b3:	89 10                	mov    %edx,(%eax)
	}
	return &((pte_t *)KADDR(PDE_ADDR(*pde)))[PTX(la)];
  1045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b8:	8b 00                	mov    (%eax),%eax
  1045ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1045bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1045c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045c5:	c1 e8 0c             	shr    $0xc,%eax
  1045c8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1045cb:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1045d0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1045d3:	72 23                	jb     1045f8 <get_pte+0x11d>
  1045d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1045dc:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  1045e3:	00 
  1045e4:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  1045eb:	00 
  1045ec:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1045f3:	e8 da c6 ff ff       	call   100cd2 <__panic>
  1045f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045fb:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104600:	8b 55 0c             	mov    0xc(%ebp),%edx
  104603:	c1 ea 0c             	shr    $0xc,%edx
  104606:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  10460c:	c1 e2 02             	shl    $0x2,%edx
  10460f:	01 d0                	add    %edx,%eax
}
  104611:	c9                   	leave  
  104612:	c3                   	ret    

00104613 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  104613:	55                   	push   %ebp
  104614:	89 e5                	mov    %esp,%ebp
  104616:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104619:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104620:	00 
  104621:	8b 45 0c             	mov    0xc(%ebp),%eax
  104624:	89 44 24 04          	mov    %eax,0x4(%esp)
  104628:	8b 45 08             	mov    0x8(%ebp),%eax
  10462b:	89 04 24             	mov    %eax,(%esp)
  10462e:	e8 a8 fe ff ff       	call   1044db <get_pte>
  104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  104636:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10463a:	74 08                	je     104644 <get_page+0x31>
        *ptep_store = ptep;
  10463c:	8b 45 10             	mov    0x10(%ebp),%eax
  10463f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104642:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  104644:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104648:	74 1b                	je     104665 <get_page+0x52>
  10464a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10464d:	8b 00                	mov    (%eax),%eax
  10464f:	83 e0 01             	and    $0x1,%eax
  104652:	85 c0                	test   %eax,%eax
  104654:	74 0f                	je     104665 <get_page+0x52>
        return pte2page(*ptep);
  104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104659:	8b 00                	mov    (%eax),%eax
  10465b:	89 04 24             	mov    %eax,(%esp)
  10465e:	e8 61 f5 ff ff       	call   103bc4 <pte2page>
  104663:	eb 05                	jmp    10466a <get_page+0x57>
    }
    return NULL;
  104665:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10466a:	c9                   	leave  
  10466b:	c3                   	ret    

0010466c <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  10466c:	55                   	push   %ebp
  10466d:	89 e5                	mov    %esp,%ebp
  10466f:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
	if(*ptep & PTE_P)
  104672:	8b 45 10             	mov    0x10(%ebp),%eax
  104675:	8b 00                	mov    (%eax),%eax
  104677:	83 e0 01             	and    $0x1,%eax
  10467a:	85 c0                	test   %eax,%eax
  10467c:	74 4d                	je     1046cb <page_remove_pte+0x5f>
	{
		struct Page* page = pte2page(*ptep);
  10467e:	8b 45 10             	mov    0x10(%ebp),%eax
  104681:	8b 00                	mov    (%eax),%eax
  104683:	89 04 24             	mov    %eax,(%esp)
  104686:	e8 39 f5 ff ff       	call   103bc4 <pte2page>
  10468b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(page_ref_dec(page) == 0)
  10468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104691:	89 04 24             	mov    %eax,(%esp)
  104694:	e8 af f5 ff ff       	call   103c48 <page_ref_dec>
  104699:	85 c0                	test   %eax,%eax
  10469b:	75 13                	jne    1046b0 <page_remove_pte+0x44>
		{
			free_page(page);
  10469d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1046a4:	00 
  1046a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046a8:	89 04 24             	mov    %eax,(%esp)
  1046ab:	e8 a7 f7 ff ff       	call   103e57 <free_pages>
		}
		*ptep = 0;
  1046b0:	8b 45 10             	mov    0x10(%ebp),%eax
  1046b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir,la);
  1046b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1046c3:	89 04 24             	mov    %eax,(%esp)
  1046c6:	e8 ff 00 00 00       	call   1047ca <tlb_invalidate>
	}
}
  1046cb:	c9                   	leave  
  1046cc:	c3                   	ret    

001046cd <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1046cd:	55                   	push   %ebp
  1046ce:	89 e5                	mov    %esp,%ebp
  1046d0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1046d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1046da:	00 
  1046db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046de:	89 44 24 04          	mov    %eax,0x4(%esp)
  1046e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e5:	89 04 24             	mov    %eax,(%esp)
  1046e8:	e8 ee fd ff ff       	call   1044db <get_pte>
  1046ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1046f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046f4:	74 19                	je     10470f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  104700:	89 44 24 04          	mov    %eax,0x4(%esp)
  104704:	8b 45 08             	mov    0x8(%ebp),%eax
  104707:	89 04 24             	mov    %eax,(%esp)
  10470a:	e8 5d ff ff ff       	call   10466c <page_remove_pte>
    }
}
  10470f:	c9                   	leave  
  104710:	c3                   	ret    

00104711 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104711:	55                   	push   %ebp
  104712:	89 e5                	mov    %esp,%ebp
  104714:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104717:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10471e:	00 
  10471f:	8b 45 10             	mov    0x10(%ebp),%eax
  104722:	89 44 24 04          	mov    %eax,0x4(%esp)
  104726:	8b 45 08             	mov    0x8(%ebp),%eax
  104729:	89 04 24             	mov    %eax,(%esp)
  10472c:	e8 aa fd ff ff       	call   1044db <get_pte>
  104731:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104738:	75 0a                	jne    104744 <page_insert+0x33>
        return -E_NO_MEM;
  10473a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10473f:	e9 84 00 00 00       	jmp    1047c8 <page_insert+0xb7>
    }
    page_ref_inc(page);
  104744:	8b 45 0c             	mov    0xc(%ebp),%eax
  104747:	89 04 24             	mov    %eax,(%esp)
  10474a:	e8 e2 f4 ff ff       	call   103c31 <page_ref_inc>
    if (*ptep & PTE_P) {
  10474f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104752:	8b 00                	mov    (%eax),%eax
  104754:	83 e0 01             	and    $0x1,%eax
  104757:	85 c0                	test   %eax,%eax
  104759:	74 3e                	je     104799 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10475e:	8b 00                	mov    (%eax),%eax
  104760:	89 04 24             	mov    %eax,(%esp)
  104763:	e8 5c f4 ff ff       	call   103bc4 <pte2page>
  104768:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10476b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10476e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104771:	75 0d                	jne    104780 <page_insert+0x6f>
            page_ref_dec(page);
  104773:	8b 45 0c             	mov    0xc(%ebp),%eax
  104776:	89 04 24             	mov    %eax,(%esp)
  104779:	e8 ca f4 ff ff       	call   103c48 <page_ref_dec>
  10477e:	eb 19                	jmp    104799 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104783:	89 44 24 08          	mov    %eax,0x8(%esp)
  104787:	8b 45 10             	mov    0x10(%ebp),%eax
  10478a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10478e:	8b 45 08             	mov    0x8(%ebp),%eax
  104791:	89 04 24             	mov    %eax,(%esp)
  104794:	e8 d3 fe ff ff       	call   10466c <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104799:	8b 45 0c             	mov    0xc(%ebp),%eax
  10479c:	89 04 24             	mov    %eax,(%esp)
  10479f:	e8 67 f3 ff ff       	call   103b0b <page2pa>
  1047a4:	0b 45 14             	or     0x14(%ebp),%eax
  1047a7:	83 c8 01             	or     $0x1,%eax
  1047aa:	89 c2                	mov    %eax,%edx
  1047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047af:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1047b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1047b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1047b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1047bb:	89 04 24             	mov    %eax,(%esp)
  1047be:	e8 07 00 00 00       	call   1047ca <tlb_invalidate>
    return 0;
  1047c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1047c8:	c9                   	leave  
  1047c9:	c3                   	ret    

001047ca <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1047ca:	55                   	push   %ebp
  1047cb:	89 e5                	mov    %esp,%ebp
  1047cd:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1047d0:	0f 20 d8             	mov    %cr3,%eax
  1047d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1047d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  1047d9:	89 c2                	mov    %eax,%edx
  1047db:	8b 45 08             	mov    0x8(%ebp),%eax
  1047de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1047e1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1047e8:	77 23                	ja     10480d <tlb_invalidate+0x43>
  1047ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1047f1:	c7 44 24 08 d4 6b 10 	movl   $0x106bd4,0x8(%esp)
  1047f8:	00 
  1047f9:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  104800:	00 
  104801:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104808:	e8 c5 c4 ff ff       	call   100cd2 <__panic>
  10480d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104810:	05 00 00 00 40       	add    $0x40000000,%eax
  104815:	39 c2                	cmp    %eax,%edx
  104817:	75 0c                	jne    104825 <tlb_invalidate+0x5b>
        invlpg((void *)la);
  104819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10481c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10481f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104822:	0f 01 38             	invlpg (%eax)
    }
}
  104825:	c9                   	leave  
  104826:	c3                   	ret    

00104827 <check_alloc_page>:

static void
check_alloc_page(void) {
  104827:	55                   	push   %ebp
  104828:	89 e5                	mov    %esp,%ebp
  10482a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10482d:	a1 1c af 11 00       	mov    0x11af1c,%eax
  104832:	8b 40 18             	mov    0x18(%eax),%eax
  104835:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104837:	c7 04 24 58 6c 10 00 	movl   $0x106c58,(%esp)
  10483e:	e8 05 bb ff ff       	call   100348 <cprintf>
}
  104843:	c9                   	leave  
  104844:	c3                   	ret    

00104845 <check_pgdir>:

static void
check_pgdir(void) {
  104845:	55                   	push   %ebp
  104846:	89 e5                	mov    %esp,%ebp
  104848:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10484b:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104850:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104855:	76 24                	jbe    10487b <check_pgdir+0x36>
  104857:	c7 44 24 0c 77 6c 10 	movl   $0x106c77,0xc(%esp)
  10485e:	00 
  10485f:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104866:	00 
  104867:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  10486e:	00 
  10486f:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104876:	e8 57 c4 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10487b:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104880:	85 c0                	test   %eax,%eax
  104882:	74 0e                	je     104892 <check_pgdir+0x4d>
  104884:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104889:	25 ff 0f 00 00       	and    $0xfff,%eax
  10488e:	85 c0                	test   %eax,%eax
  104890:	74 24                	je     1048b6 <check_pgdir+0x71>
  104892:	c7 44 24 0c 94 6c 10 	movl   $0x106c94,0xc(%esp)
  104899:	00 
  10489a:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1048a1:	00 
  1048a2:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  1048a9:	00 
  1048aa:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1048b1:	e8 1c c4 ff ff       	call   100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1048b6:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048c2:	00 
  1048c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048ca:	00 
  1048cb:	89 04 24             	mov    %eax,(%esp)
  1048ce:	e8 40 fd ff ff       	call   104613 <get_page>
  1048d3:	85 c0                	test   %eax,%eax
  1048d5:	74 24                	je     1048fb <check_pgdir+0xb6>
  1048d7:	c7 44 24 0c cc 6c 10 	movl   $0x106ccc,0xc(%esp)
  1048de:	00 
  1048df:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1048e6:	00 
  1048e7:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  1048ee:	00 
  1048ef:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1048f6:	e8 d7 c3 ff ff       	call   100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1048fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104902:	e8 18 f5 ff ff       	call   103e1f <alloc_pages>
  104907:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10490a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10490f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104916:	00 
  104917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10491e:	00 
  10491f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104922:	89 54 24 04          	mov    %edx,0x4(%esp)
  104926:	89 04 24             	mov    %eax,(%esp)
  104929:	e8 e3 fd ff ff       	call   104711 <page_insert>
  10492e:	85 c0                	test   %eax,%eax
  104930:	74 24                	je     104956 <check_pgdir+0x111>
  104932:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  104939:	00 
  10493a:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104941:	00 
  104942:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  104949:	00 
  10494a:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104951:	e8 7c c3 ff ff       	call   100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104956:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10495b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104962:	00 
  104963:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10496a:	00 
  10496b:	89 04 24             	mov    %eax,(%esp)
  10496e:	e8 68 fb ff ff       	call   1044db <get_pte>
  104973:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104976:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10497a:	75 24                	jne    1049a0 <check_pgdir+0x15b>
  10497c:	c7 44 24 0c 20 6d 10 	movl   $0x106d20,0xc(%esp)
  104983:	00 
  104984:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  10498b:	00 
  10498c:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  104993:	00 
  104994:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10499b:	e8 32 c3 ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  1049a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1049a3:	8b 00                	mov    (%eax),%eax
  1049a5:	89 04 24             	mov    %eax,(%esp)
  1049a8:	e8 17 f2 ff ff       	call   103bc4 <pte2page>
  1049ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1049b0:	74 24                	je     1049d6 <check_pgdir+0x191>
  1049b2:	c7 44 24 0c 4d 6d 10 	movl   $0x106d4d,0xc(%esp)
  1049b9:	00 
  1049ba:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1049c1:	00 
  1049c2:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  1049c9:	00 
  1049ca:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1049d1:	e8 fc c2 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 1);
  1049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049d9:	89 04 24             	mov    %eax,(%esp)
  1049dc:	e8 39 f2 ff ff       	call   103c1a <page_ref>
  1049e1:	83 f8 01             	cmp    $0x1,%eax
  1049e4:	74 24                	je     104a0a <check_pgdir+0x1c5>
  1049e6:	c7 44 24 0c 63 6d 10 	movl   $0x106d63,0xc(%esp)
  1049ed:	00 
  1049ee:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1049f5:	00 
  1049f6:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  1049fd:	00 
  1049fe:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104a05:	e8 c8 c2 ff ff       	call   100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104a0a:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a0f:	8b 00                	mov    (%eax),%eax
  104a11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a1c:	c1 e8 0c             	shr    $0xc,%eax
  104a1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104a22:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104a27:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104a2a:	72 23                	jb     104a4f <check_pgdir+0x20a>
  104a2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104a33:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  104a3a:	00 
  104a3b:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
  104a42:	00 
  104a43:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104a4a:	e8 83 c2 ff ff       	call   100cd2 <__panic>
  104a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a52:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104a57:	83 c0 04             	add    $0x4,%eax
  104a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104a5d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a69:	00 
  104a6a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a71:	00 
  104a72:	89 04 24             	mov    %eax,(%esp)
  104a75:	e8 61 fa ff ff       	call   1044db <get_pte>
  104a7a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104a7d:	74 24                	je     104aa3 <check_pgdir+0x25e>
  104a7f:	c7 44 24 0c 78 6d 10 	movl   $0x106d78,0xc(%esp)
  104a86:	00 
  104a87:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104a8e:	00 
  104a8f:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104a96:	00 
  104a97:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104a9e:	e8 2f c2 ff ff       	call   100cd2 <__panic>

    p2 = alloc_page();
  104aa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104aaa:	e8 70 f3 ff ff       	call   103e1f <alloc_pages>
  104aaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104ab2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ab7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104abe:	00 
  104abf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104ac6:	00 
  104ac7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104aca:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ace:	89 04 24             	mov    %eax,(%esp)
  104ad1:	e8 3b fc ff ff       	call   104711 <page_insert>
  104ad6:	85 c0                	test   %eax,%eax
  104ad8:	74 24                	je     104afe <check_pgdir+0x2b9>
  104ada:	c7 44 24 0c a0 6d 10 	movl   $0x106da0,0xc(%esp)
  104ae1:	00 
  104ae2:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104ae9:	00 
  104aea:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104af1:	00 
  104af2:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104af9:	e8 d4 c1 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104afe:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b0a:	00 
  104b0b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104b12:	00 
  104b13:	89 04 24             	mov    %eax,(%esp)
  104b16:	e8 c0 f9 ff ff       	call   1044db <get_pte>
  104b1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b22:	75 24                	jne    104b48 <check_pgdir+0x303>
  104b24:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  104b2b:	00 
  104b2c:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104b33:	00 
  104b34:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  104b3b:	00 
  104b3c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104b43:	e8 8a c1 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_U);
  104b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b4b:	8b 00                	mov    (%eax),%eax
  104b4d:	83 e0 04             	and    $0x4,%eax
  104b50:	85 c0                	test   %eax,%eax
  104b52:	75 24                	jne    104b78 <check_pgdir+0x333>
  104b54:	c7 44 24 0c 08 6e 10 	movl   $0x106e08,0xc(%esp)
  104b5b:	00 
  104b5c:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104b63:	00 
  104b64:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104b6b:	00 
  104b6c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104b73:	e8 5a c1 ff ff       	call   100cd2 <__panic>
    assert(*ptep & PTE_W);
  104b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b7b:	8b 00                	mov    (%eax),%eax
  104b7d:	83 e0 02             	and    $0x2,%eax
  104b80:	85 c0                	test   %eax,%eax
  104b82:	75 24                	jne    104ba8 <check_pgdir+0x363>
  104b84:	c7 44 24 0c 16 6e 10 	movl   $0x106e16,0xc(%esp)
  104b8b:	00 
  104b8c:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104b93:	00 
  104b94:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104b9b:	00 
  104b9c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104ba3:	e8 2a c1 ff ff       	call   100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104ba8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104bad:	8b 00                	mov    (%eax),%eax
  104baf:	83 e0 04             	and    $0x4,%eax
  104bb2:	85 c0                	test   %eax,%eax
  104bb4:	75 24                	jne    104bda <check_pgdir+0x395>
  104bb6:	c7 44 24 0c 24 6e 10 	movl   $0x106e24,0xc(%esp)
  104bbd:	00 
  104bbe:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104bc5:	00 
  104bc6:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  104bcd:	00 
  104bce:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104bd5:	e8 f8 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 1);
  104bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104bdd:	89 04 24             	mov    %eax,(%esp)
  104be0:	e8 35 f0 ff ff       	call   103c1a <page_ref>
  104be5:	83 f8 01             	cmp    $0x1,%eax
  104be8:	74 24                	je     104c0e <check_pgdir+0x3c9>
  104bea:	c7 44 24 0c 3a 6e 10 	movl   $0x106e3a,0xc(%esp)
  104bf1:	00 
  104bf2:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104bf9:	00 
  104bfa:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  104c01:	00 
  104c02:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104c09:	e8 c4 c0 ff ff       	call   100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104c0e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c13:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104c1a:	00 
  104c1b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104c22:	00 
  104c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104c26:	89 54 24 04          	mov    %edx,0x4(%esp)
  104c2a:	89 04 24             	mov    %eax,(%esp)
  104c2d:	e8 df fa ff ff       	call   104711 <page_insert>
  104c32:	85 c0                	test   %eax,%eax
  104c34:	74 24                	je     104c5a <check_pgdir+0x415>
  104c36:	c7 44 24 0c 4c 6e 10 	movl   $0x106e4c,0xc(%esp)
  104c3d:	00 
  104c3e:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104c45:	00 
  104c46:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104c4d:	00 
  104c4e:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104c55:	e8 78 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p1) == 2);
  104c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c5d:	89 04 24             	mov    %eax,(%esp)
  104c60:	e8 b5 ef ff ff       	call   103c1a <page_ref>
  104c65:	83 f8 02             	cmp    $0x2,%eax
  104c68:	74 24                	je     104c8e <check_pgdir+0x449>
  104c6a:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  104c71:	00 
  104c72:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104c79:	00 
  104c7a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104c81:	00 
  104c82:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104c89:	e8 44 c0 ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104c8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c91:	89 04 24             	mov    %eax,(%esp)
  104c94:	e8 81 ef ff ff       	call   103c1a <page_ref>
  104c99:	85 c0                	test   %eax,%eax
  104c9b:	74 24                	je     104cc1 <check_pgdir+0x47c>
  104c9d:	c7 44 24 0c 8a 6e 10 	movl   $0x106e8a,0xc(%esp)
  104ca4:	00 
  104ca5:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104cac:	00 
  104cad:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104cb4:	00 
  104cb5:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104cbc:	e8 11 c0 ff ff       	call   100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104cc1:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104cc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ccd:	00 
  104cce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104cd5:	00 
  104cd6:	89 04 24             	mov    %eax,(%esp)
  104cd9:	e8 fd f7 ff ff       	call   1044db <get_pte>
  104cde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ce1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104ce5:	75 24                	jne    104d0b <check_pgdir+0x4c6>
  104ce7:	c7 44 24 0c d8 6d 10 	movl   $0x106dd8,0xc(%esp)
  104cee:	00 
  104cef:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104cf6:	00 
  104cf7:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104cfe:	00 
  104cff:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104d06:	e8 c7 bf ff ff       	call   100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
  104d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d0e:	8b 00                	mov    (%eax),%eax
  104d10:	89 04 24             	mov    %eax,(%esp)
  104d13:	e8 ac ee ff ff       	call   103bc4 <pte2page>
  104d18:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104d1b:	74 24                	je     104d41 <check_pgdir+0x4fc>
  104d1d:	c7 44 24 0c 4d 6d 10 	movl   $0x106d4d,0xc(%esp)
  104d24:	00 
  104d25:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104d2c:	00 
  104d2d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  104d34:	00 
  104d35:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104d3c:	e8 91 bf ff ff       	call   100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
  104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d44:	8b 00                	mov    (%eax),%eax
  104d46:	83 e0 04             	and    $0x4,%eax
  104d49:	85 c0                	test   %eax,%eax
  104d4b:	74 24                	je     104d71 <check_pgdir+0x52c>
  104d4d:	c7 44 24 0c 9c 6e 10 	movl   $0x106e9c,0xc(%esp)
  104d54:	00 
  104d55:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104d5c:	00 
  104d5d:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104d64:	00 
  104d65:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104d6c:	e8 61 bf ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
  104d71:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104d7d:	00 
  104d7e:	89 04 24             	mov    %eax,(%esp)
  104d81:	e8 47 f9 ff ff       	call   1046cd <page_remove>
    assert(page_ref(p1) == 1);
  104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d89:	89 04 24             	mov    %eax,(%esp)
  104d8c:	e8 89 ee ff ff       	call   103c1a <page_ref>
  104d91:	83 f8 01             	cmp    $0x1,%eax
  104d94:	74 24                	je     104dba <check_pgdir+0x575>
  104d96:	c7 44 24 0c 63 6d 10 	movl   $0x106d63,0xc(%esp)
  104d9d:	00 
  104d9e:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104da5:	00 
  104da6:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  104dad:	00 
  104dae:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104db5:	e8 18 bf ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104dba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dbd:	89 04 24             	mov    %eax,(%esp)
  104dc0:	e8 55 ee ff ff       	call   103c1a <page_ref>
  104dc5:	85 c0                	test   %eax,%eax
  104dc7:	74 24                	je     104ded <check_pgdir+0x5a8>
  104dc9:	c7 44 24 0c 8a 6e 10 	movl   $0x106e8a,0xc(%esp)
  104dd0:	00 
  104dd1:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104dd8:	00 
  104dd9:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104de0:	00 
  104de1:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104de8:	e8 e5 be ff ff       	call   100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104ded:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104df2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104df9:	00 
  104dfa:	89 04 24             	mov    %eax,(%esp)
  104dfd:	e8 cb f8 ff ff       	call   1046cd <page_remove>
    assert(page_ref(p1) == 0);
  104e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e05:	89 04 24             	mov    %eax,(%esp)
  104e08:	e8 0d ee ff ff       	call   103c1a <page_ref>
  104e0d:	85 c0                	test   %eax,%eax
  104e0f:	74 24                	je     104e35 <check_pgdir+0x5f0>
  104e11:	c7 44 24 0c b1 6e 10 	movl   $0x106eb1,0xc(%esp)
  104e18:	00 
  104e19:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104e20:	00 
  104e21:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  104e28:	00 
  104e29:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104e30:	e8 9d be ff ff       	call   100cd2 <__panic>
    assert(page_ref(p2) == 0);
  104e35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e38:	89 04 24             	mov    %eax,(%esp)
  104e3b:	e8 da ed ff ff       	call   103c1a <page_ref>
  104e40:	85 c0                	test   %eax,%eax
  104e42:	74 24                	je     104e68 <check_pgdir+0x623>
  104e44:	c7 44 24 0c 8a 6e 10 	movl   $0x106e8a,0xc(%esp)
  104e4b:	00 
  104e4c:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104e53:	00 
  104e54:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104e5b:	00 
  104e5c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104e63:	e8 6a be ff ff       	call   100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104e68:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e6d:	8b 00                	mov    (%eax),%eax
  104e6f:	89 04 24             	mov    %eax,(%esp)
  104e72:	e8 8b ed ff ff       	call   103c02 <pde2page>
  104e77:	89 04 24             	mov    %eax,(%esp)
  104e7a:	e8 9b ed ff ff       	call   103c1a <page_ref>
  104e7f:	83 f8 01             	cmp    $0x1,%eax
  104e82:	74 24                	je     104ea8 <check_pgdir+0x663>
  104e84:	c7 44 24 0c c4 6e 10 	movl   $0x106ec4,0xc(%esp)
  104e8b:	00 
  104e8c:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104e93:	00 
  104e94:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104e9b:	00 
  104e9c:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104ea3:	e8 2a be ff ff       	call   100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104ea8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ead:	8b 00                	mov    (%eax),%eax
  104eaf:	89 04 24             	mov    %eax,(%esp)
  104eb2:	e8 4b ed ff ff       	call   103c02 <pde2page>
  104eb7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ebe:	00 
  104ebf:	89 04 24             	mov    %eax,(%esp)
  104ec2:	e8 90 ef ff ff       	call   103e57 <free_pages>
    boot_pgdir[0] = 0;
  104ec7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ecc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104ed2:	c7 04 24 eb 6e 10 00 	movl   $0x106eeb,(%esp)
  104ed9:	e8 6a b4 ff ff       	call   100348 <cprintf>
}
  104ede:	c9                   	leave  
  104edf:	c3                   	ret    

00104ee0 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104ee0:	55                   	push   %ebp
  104ee1:	89 e5                	mov    %esp,%ebp
  104ee3:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104ee6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104eed:	e9 ca 00 00 00       	jmp    104fbc <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104efb:	c1 e8 0c             	shr    $0xc,%eax
  104efe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104f01:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104f06:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104f09:	72 23                	jb     104f2e <check_boot_pgdir+0x4e>
  104f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f12:	c7 44 24 08 30 6b 10 	movl   $0x106b30,0x8(%esp)
  104f19:	00 
  104f1a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104f21:	00 
  104f22:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104f29:	e8 a4 bd ff ff       	call   100cd2 <__panic>
  104f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f31:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104f36:	89 c2                	mov    %eax,%edx
  104f38:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104f44:	00 
  104f45:	89 54 24 04          	mov    %edx,0x4(%esp)
  104f49:	89 04 24             	mov    %eax,(%esp)
  104f4c:	e8 8a f5 ff ff       	call   1044db <get_pte>
  104f51:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104f54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104f58:	75 24                	jne    104f7e <check_boot_pgdir+0x9e>
  104f5a:	c7 44 24 0c 08 6f 10 	movl   $0x106f08,0xc(%esp)
  104f61:	00 
  104f62:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104f69:	00 
  104f6a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  104f71:	00 
  104f72:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104f79:	e8 54 bd ff ff       	call   100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104f7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104f81:	8b 00                	mov    (%eax),%eax
  104f83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f88:	89 c2                	mov    %eax,%edx
  104f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f8d:	39 c2                	cmp    %eax,%edx
  104f8f:	74 24                	je     104fb5 <check_boot_pgdir+0xd5>
  104f91:	c7 44 24 0c 45 6f 10 	movl   $0x106f45,0xc(%esp)
  104f98:	00 
  104f99:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  104fa0:	00 
  104fa1:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  104fa8:	00 
  104fa9:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  104fb0:	e8 1d bd ff ff       	call   100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104fb5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104fbf:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104fc4:	39 c2                	cmp    %eax,%edx
  104fc6:	0f 82 26 ff ff ff    	jb     104ef2 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104fcc:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fd1:	05 ac 0f 00 00       	add    $0xfac,%eax
  104fd6:	8b 00                	mov    (%eax),%eax
  104fd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104fdd:	89 c2                	mov    %eax,%edx
  104fdf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fe4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104fe7:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104fee:	77 23                	ja     105013 <check_boot_pgdir+0x133>
  104ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104ff3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104ff7:	c7 44 24 08 d4 6b 10 	movl   $0x106bd4,0x8(%esp)
  104ffe:	00 
  104fff:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  105006:	00 
  105007:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10500e:	e8 bf bc ff ff       	call   100cd2 <__panic>
  105013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105016:	05 00 00 00 40       	add    $0x40000000,%eax
  10501b:	39 c2                	cmp    %eax,%edx
  10501d:	74 24                	je     105043 <check_boot_pgdir+0x163>
  10501f:	c7 44 24 0c 5c 6f 10 	movl   $0x106f5c,0xc(%esp)
  105026:	00 
  105027:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  10502e:	00 
  10502f:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  105036:	00 
  105037:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10503e:	e8 8f bc ff ff       	call   100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
  105043:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105048:	8b 00                	mov    (%eax),%eax
  10504a:	85 c0                	test   %eax,%eax
  10504c:	74 24                	je     105072 <check_boot_pgdir+0x192>
  10504e:	c7 44 24 0c 90 6f 10 	movl   $0x106f90,0xc(%esp)
  105055:	00 
  105056:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  10505d:	00 
  10505e:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  105065:	00 
  105066:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10506d:	e8 60 bc ff ff       	call   100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
  105072:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105079:	e8 a1 ed ff ff       	call   103e1f <alloc_pages>
  10507e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  105081:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105086:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10508d:	00 
  10508e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  105095:	00 
  105096:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105099:	89 54 24 04          	mov    %edx,0x4(%esp)
  10509d:	89 04 24             	mov    %eax,(%esp)
  1050a0:	e8 6c f6 ff ff       	call   104711 <page_insert>
  1050a5:	85 c0                	test   %eax,%eax
  1050a7:	74 24                	je     1050cd <check_boot_pgdir+0x1ed>
  1050a9:	c7 44 24 0c a4 6f 10 	movl   $0x106fa4,0xc(%esp)
  1050b0:	00 
  1050b1:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1050b8:	00 
  1050b9:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050c0:	00 
  1050c1:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1050c8:	e8 05 bc ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 1);
  1050cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050d0:	89 04 24             	mov    %eax,(%esp)
  1050d3:	e8 42 eb ff ff       	call   103c1a <page_ref>
  1050d8:	83 f8 01             	cmp    $0x1,%eax
  1050db:	74 24                	je     105101 <check_boot_pgdir+0x221>
  1050dd:	c7 44 24 0c d2 6f 10 	movl   $0x106fd2,0xc(%esp)
  1050e4:	00 
  1050e5:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1050ec:	00 
  1050ed:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  1050f4:	00 
  1050f5:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1050fc:	e8 d1 bb ff ff       	call   100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105101:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105106:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  10510d:	00 
  10510e:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  105115:	00 
  105116:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105119:	89 54 24 04          	mov    %edx,0x4(%esp)
  10511d:	89 04 24             	mov    %eax,(%esp)
  105120:	e8 ec f5 ff ff       	call   104711 <page_insert>
  105125:	85 c0                	test   %eax,%eax
  105127:	74 24                	je     10514d <check_boot_pgdir+0x26d>
  105129:	c7 44 24 0c e4 6f 10 	movl   $0x106fe4,0xc(%esp)
  105130:	00 
  105131:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  105138:	00 
  105139:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  105140:	00 
  105141:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  105148:	e8 85 bb ff ff       	call   100cd2 <__panic>
    assert(page_ref(p) == 2);
  10514d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105150:	89 04 24             	mov    %eax,(%esp)
  105153:	e8 c2 ea ff ff       	call   103c1a <page_ref>
  105158:	83 f8 02             	cmp    $0x2,%eax
  10515b:	74 24                	je     105181 <check_boot_pgdir+0x2a1>
  10515d:	c7 44 24 0c 1b 70 10 	movl   $0x10701b,0xc(%esp)
  105164:	00 
  105165:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  10516c:	00 
  10516d:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  105174:	00 
  105175:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  10517c:	e8 51 bb ff ff       	call   100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
  105181:	c7 45 dc 2c 70 10 00 	movl   $0x10702c,-0x24(%ebp)
    strcpy((void *)0x100, str);
  105188:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10518b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10518f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105196:	e8 19 0a 00 00       	call   105bb4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  10519b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1051a2:	00 
  1051a3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1051aa:	e8 7e 0a 00 00       	call   105c2d <strcmp>
  1051af:	85 c0                	test   %eax,%eax
  1051b1:	74 24                	je     1051d7 <check_boot_pgdir+0x2f7>
  1051b3:	c7 44 24 0c 44 70 10 	movl   $0x107044,0xc(%esp)
  1051ba:	00 
  1051bb:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  1051c2:	00 
  1051c3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  1051ca:	00 
  1051cb:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  1051d2:	e8 fb ba ff ff       	call   100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1051d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051da:	89 04 24             	mov    %eax,(%esp)
  1051dd:	e8 8e e9 ff ff       	call   103b70 <page2kva>
  1051e2:	05 00 01 00 00       	add    $0x100,%eax
  1051e7:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1051ea:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1051f1:	e8 66 09 00 00       	call   105b5c <strlen>
  1051f6:	85 c0                	test   %eax,%eax
  1051f8:	74 24                	je     10521e <check_boot_pgdir+0x33e>
  1051fa:	c7 44 24 0c 7c 70 10 	movl   $0x10707c,0xc(%esp)
  105201:	00 
  105202:	c7 44 24 08 1d 6c 10 	movl   $0x106c1d,0x8(%esp)
  105209:	00 
  10520a:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  105211:	00 
  105212:	c7 04 24 f8 6b 10 00 	movl   $0x106bf8,(%esp)
  105219:	e8 b4 ba ff ff       	call   100cd2 <__panic>

    free_page(p);
  10521e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105225:	00 
  105226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105229:	89 04 24             	mov    %eax,(%esp)
  10522c:	e8 26 ec ff ff       	call   103e57 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  105231:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105236:	8b 00                	mov    (%eax),%eax
  105238:	89 04 24             	mov    %eax,(%esp)
  10523b:	e8 c2 e9 ff ff       	call   103c02 <pde2page>
  105240:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105247:	00 
  105248:	89 04 24             	mov    %eax,(%esp)
  10524b:	e8 07 ec ff ff       	call   103e57 <free_pages>
    boot_pgdir[0] = 0;
  105250:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  105255:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10525b:	c7 04 24 a0 70 10 00 	movl   $0x1070a0,(%esp)
  105262:	e8 e1 b0 ff ff       	call   100348 <cprintf>
}
  105267:	c9                   	leave  
  105268:	c3                   	ret    

00105269 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105269:	55                   	push   %ebp
  10526a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10526c:	8b 45 08             	mov    0x8(%ebp),%eax
  10526f:	83 e0 04             	and    $0x4,%eax
  105272:	85 c0                	test   %eax,%eax
  105274:	74 07                	je     10527d <perm2str+0x14>
  105276:	b8 75 00 00 00       	mov    $0x75,%eax
  10527b:	eb 05                	jmp    105282 <perm2str+0x19>
  10527d:	b8 2d 00 00 00       	mov    $0x2d,%eax
  105282:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  105287:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  10528e:	8b 45 08             	mov    0x8(%ebp),%eax
  105291:	83 e0 02             	and    $0x2,%eax
  105294:	85 c0                	test   %eax,%eax
  105296:	74 07                	je     10529f <perm2str+0x36>
  105298:	b8 77 00 00 00       	mov    $0x77,%eax
  10529d:	eb 05                	jmp    1052a4 <perm2str+0x3b>
  10529f:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1052a4:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  1052a9:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  1052b0:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  1052b5:	5d                   	pop    %ebp
  1052b6:	c3                   	ret    

001052b7 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1052b7:	55                   	push   %ebp
  1052b8:	89 e5                	mov    %esp,%ebp
  1052ba:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1052bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1052c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052c3:	72 0a                	jb     1052cf <get_pgtable_items+0x18>
        return 0;
  1052c5:	b8 00 00 00 00       	mov    $0x0,%eax
  1052ca:	e9 9c 00 00 00       	jmp    10536b <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  1052cf:	eb 04                	jmp    1052d5 <get_pgtable_items+0x1e>
        start ++;
  1052d1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  1052d5:	8b 45 10             	mov    0x10(%ebp),%eax
  1052d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052db:	73 18                	jae    1052f5 <get_pgtable_items+0x3e>
  1052dd:	8b 45 10             	mov    0x10(%ebp),%eax
  1052e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052e7:	8b 45 14             	mov    0x14(%ebp),%eax
  1052ea:	01 d0                	add    %edx,%eax
  1052ec:	8b 00                	mov    (%eax),%eax
  1052ee:	83 e0 01             	and    $0x1,%eax
  1052f1:	85 c0                	test   %eax,%eax
  1052f3:	74 dc                	je     1052d1 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  1052f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1052f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052fb:	73 69                	jae    105366 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1052fd:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105301:	74 08                	je     10530b <get_pgtable_items+0x54>
            *left_store = start;
  105303:	8b 45 18             	mov    0x18(%ebp),%eax
  105306:	8b 55 10             	mov    0x10(%ebp),%edx
  105309:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  10530b:	8b 45 10             	mov    0x10(%ebp),%eax
  10530e:	8d 50 01             	lea    0x1(%eax),%edx
  105311:	89 55 10             	mov    %edx,0x10(%ebp)
  105314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10531b:	8b 45 14             	mov    0x14(%ebp),%eax
  10531e:	01 d0                	add    %edx,%eax
  105320:	8b 00                	mov    (%eax),%eax
  105322:	83 e0 07             	and    $0x7,%eax
  105325:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105328:	eb 04                	jmp    10532e <get_pgtable_items+0x77>
            start ++;
  10532a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  10532e:	8b 45 10             	mov    0x10(%ebp),%eax
  105331:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105334:	73 1d                	jae    105353 <get_pgtable_items+0x9c>
  105336:	8b 45 10             	mov    0x10(%ebp),%eax
  105339:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105340:	8b 45 14             	mov    0x14(%ebp),%eax
  105343:	01 d0                	add    %edx,%eax
  105345:	8b 00                	mov    (%eax),%eax
  105347:	83 e0 07             	and    $0x7,%eax
  10534a:	89 c2                	mov    %eax,%edx
  10534c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10534f:	39 c2                	cmp    %eax,%edx
  105351:	74 d7                	je     10532a <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  105353:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105357:	74 08                	je     105361 <get_pgtable_items+0xaa>
            *right_store = start;
  105359:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10535c:	8b 55 10             	mov    0x10(%ebp),%edx
  10535f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  105361:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105364:	eb 05                	jmp    10536b <get_pgtable_items+0xb4>
    }
    return 0;
  105366:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10536b:	c9                   	leave  
  10536c:	c3                   	ret    

0010536d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10536d:	55                   	push   %ebp
  10536e:	89 e5                	mov    %esp,%ebp
  105370:	57                   	push   %edi
  105371:	56                   	push   %esi
  105372:	53                   	push   %ebx
  105373:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105376:	c7 04 24 c0 70 10 00 	movl   $0x1070c0,(%esp)
  10537d:	e8 c6 af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
  105382:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105389:	e9 fa 00 00 00       	jmp    105488 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10538e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105391:	89 04 24             	mov    %eax,(%esp)
  105394:	e8 d0 fe ff ff       	call   105269 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105399:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10539c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10539f:	29 d1                	sub    %edx,%ecx
  1053a1:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1053a3:	89 d6                	mov    %edx,%esi
  1053a5:	c1 e6 16             	shl    $0x16,%esi
  1053a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1053ab:	89 d3                	mov    %edx,%ebx
  1053ad:	c1 e3 16             	shl    $0x16,%ebx
  1053b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1053b3:	89 d1                	mov    %edx,%ecx
  1053b5:	c1 e1 16             	shl    $0x16,%ecx
  1053b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1053bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1053be:	29 d7                	sub    %edx,%edi
  1053c0:	89 fa                	mov    %edi,%edx
  1053c2:	89 44 24 14          	mov    %eax,0x14(%esp)
  1053c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  1053ca:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1053ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1053d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1053d6:	c7 04 24 f1 70 10 00 	movl   $0x1070f1,(%esp)
  1053dd:	e8 66 af ff ff       	call   100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  1053e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053e5:	c1 e0 0a             	shl    $0xa,%eax
  1053e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1053eb:	eb 54                	jmp    105441 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1053ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1053f0:	89 04 24             	mov    %eax,(%esp)
  1053f3:	e8 71 fe ff ff       	call   105269 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1053f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1053fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1053fe:	29 d1                	sub    %edx,%ecx
  105400:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105402:	89 d6                	mov    %edx,%esi
  105404:	c1 e6 0c             	shl    $0xc,%esi
  105407:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10540a:	89 d3                	mov    %edx,%ebx
  10540c:	c1 e3 0c             	shl    $0xc,%ebx
  10540f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105412:	c1 e2 0c             	shl    $0xc,%edx
  105415:	89 d1                	mov    %edx,%ecx
  105417:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10541a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10541d:	29 d7                	sub    %edx,%edi
  10541f:	89 fa                	mov    %edi,%edx
  105421:	89 44 24 14          	mov    %eax,0x14(%esp)
  105425:	89 74 24 10          	mov    %esi,0x10(%esp)
  105429:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10542d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105431:	89 54 24 04          	mov    %edx,0x4(%esp)
  105435:	c7 04 24 10 71 10 00 	movl   $0x107110,(%esp)
  10543c:	e8 07 af ff ff       	call   100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105441:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  105446:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105449:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10544c:	89 ce                	mov    %ecx,%esi
  10544e:	c1 e6 0a             	shl    $0xa,%esi
  105451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  105454:	89 cb                	mov    %ecx,%ebx
  105456:	c1 e3 0a             	shl    $0xa,%ebx
  105459:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  10545c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105460:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  105463:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105467:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10546b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10546f:	89 74 24 04          	mov    %esi,0x4(%esp)
  105473:	89 1c 24             	mov    %ebx,(%esp)
  105476:	e8 3c fe ff ff       	call   1052b7 <get_pgtable_items>
  10547b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10547e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105482:	0f 85 65 ff ff ff    	jne    1053ed <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105488:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  10548d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105490:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  105493:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  105497:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  10549a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10549e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1054a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1054a6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1054ad:	00 
  1054ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1054b5:	e8 fd fd ff ff       	call   1052b7 <get_pgtable_items>
  1054ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1054bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1054c1:	0f 85 c7 fe ff ff    	jne    10538e <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1054c7:	c7 04 24 34 71 10 00 	movl   $0x107134,(%esp)
  1054ce:	e8 75 ae ff ff       	call   100348 <cprintf>
}
  1054d3:	83 c4 4c             	add    $0x4c,%esp
  1054d6:	5b                   	pop    %ebx
  1054d7:	5e                   	pop    %esi
  1054d8:	5f                   	pop    %edi
  1054d9:	5d                   	pop    %ebp
  1054da:	c3                   	ret    

001054db <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1054db:	55                   	push   %ebp
  1054dc:	89 e5                	mov    %esp,%ebp
  1054de:	83 ec 58             	sub    $0x58,%esp
  1054e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1054e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1054e7:	8b 45 14             	mov    0x14(%ebp),%eax
  1054ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1054ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1054f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1054f9:	8b 45 18             	mov    0x18(%ebp),%eax
  1054fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1054ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105502:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105508:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10550b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10550e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105511:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105515:	74 1c                	je     105533 <printnum+0x58>
  105517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10551a:	ba 00 00 00 00       	mov    $0x0,%edx
  10551f:	f7 75 e4             	divl   -0x1c(%ebp)
  105522:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105528:	ba 00 00 00 00       	mov    $0x0,%edx
  10552d:	f7 75 e4             	divl   -0x1c(%ebp)
  105530:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105533:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105539:	f7 75 e4             	divl   -0x1c(%ebp)
  10553c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10553f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105542:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105545:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105548:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10554b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10554e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105551:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105554:	8b 45 18             	mov    0x18(%ebp),%eax
  105557:	ba 00 00 00 00       	mov    $0x0,%edx
  10555c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10555f:	77 56                	ja     1055b7 <printnum+0xdc>
  105561:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105564:	72 05                	jb     10556b <printnum+0x90>
  105566:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105569:	77 4c                	ja     1055b7 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  10556b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10556e:	8d 50 ff             	lea    -0x1(%eax),%edx
  105571:	8b 45 20             	mov    0x20(%ebp),%eax
  105574:	89 44 24 18          	mov    %eax,0x18(%esp)
  105578:	89 54 24 14          	mov    %edx,0x14(%esp)
  10557c:	8b 45 18             	mov    0x18(%ebp),%eax
  10557f:	89 44 24 10          	mov    %eax,0x10(%esp)
  105583:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105586:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105589:	89 44 24 08          	mov    %eax,0x8(%esp)
  10558d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105591:	8b 45 0c             	mov    0xc(%ebp),%eax
  105594:	89 44 24 04          	mov    %eax,0x4(%esp)
  105598:	8b 45 08             	mov    0x8(%ebp),%eax
  10559b:	89 04 24             	mov    %eax,(%esp)
  10559e:	e8 38 ff ff ff       	call   1054db <printnum>
  1055a3:	eb 1c                	jmp    1055c1 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1055a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1055a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1055ac:	8b 45 20             	mov    0x20(%ebp),%eax
  1055af:	89 04 24             	mov    %eax,(%esp)
  1055b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b5:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  1055b7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1055bb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1055bf:	7f e4                	jg     1055a5 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1055c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1055c4:	05 e8 71 10 00       	add    $0x1071e8,%eax
  1055c9:	0f b6 00             	movzbl (%eax),%eax
  1055cc:	0f be c0             	movsbl %al,%eax
  1055cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  1055d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1055d6:	89 04 24             	mov    %eax,(%esp)
  1055d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055dc:	ff d0                	call   *%eax
}
  1055de:	c9                   	leave  
  1055df:	c3                   	ret    

001055e0 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1055e0:	55                   	push   %ebp
  1055e1:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055e3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055e7:	7e 14                	jle    1055fd <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1055e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ec:	8b 00                	mov    (%eax),%eax
  1055ee:	8d 48 08             	lea    0x8(%eax),%ecx
  1055f1:	8b 55 08             	mov    0x8(%ebp),%edx
  1055f4:	89 0a                	mov    %ecx,(%edx)
  1055f6:	8b 50 04             	mov    0x4(%eax),%edx
  1055f9:	8b 00                	mov    (%eax),%eax
  1055fb:	eb 30                	jmp    10562d <getuint+0x4d>
    }
    else if (lflag) {
  1055fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105601:	74 16                	je     105619 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105603:	8b 45 08             	mov    0x8(%ebp),%eax
  105606:	8b 00                	mov    (%eax),%eax
  105608:	8d 48 04             	lea    0x4(%eax),%ecx
  10560b:	8b 55 08             	mov    0x8(%ebp),%edx
  10560e:	89 0a                	mov    %ecx,(%edx)
  105610:	8b 00                	mov    (%eax),%eax
  105612:	ba 00 00 00 00       	mov    $0x0,%edx
  105617:	eb 14                	jmp    10562d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105619:	8b 45 08             	mov    0x8(%ebp),%eax
  10561c:	8b 00                	mov    (%eax),%eax
  10561e:	8d 48 04             	lea    0x4(%eax),%ecx
  105621:	8b 55 08             	mov    0x8(%ebp),%edx
  105624:	89 0a                	mov    %ecx,(%edx)
  105626:	8b 00                	mov    (%eax),%eax
  105628:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10562d:	5d                   	pop    %ebp
  10562e:	c3                   	ret    

0010562f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10562f:	55                   	push   %ebp
  105630:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105632:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105636:	7e 14                	jle    10564c <getint+0x1d>
        return va_arg(*ap, long long);
  105638:	8b 45 08             	mov    0x8(%ebp),%eax
  10563b:	8b 00                	mov    (%eax),%eax
  10563d:	8d 48 08             	lea    0x8(%eax),%ecx
  105640:	8b 55 08             	mov    0x8(%ebp),%edx
  105643:	89 0a                	mov    %ecx,(%edx)
  105645:	8b 50 04             	mov    0x4(%eax),%edx
  105648:	8b 00                	mov    (%eax),%eax
  10564a:	eb 28                	jmp    105674 <getint+0x45>
    }
    else if (lflag) {
  10564c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105650:	74 12                	je     105664 <getint+0x35>
        return va_arg(*ap, long);
  105652:	8b 45 08             	mov    0x8(%ebp),%eax
  105655:	8b 00                	mov    (%eax),%eax
  105657:	8d 48 04             	lea    0x4(%eax),%ecx
  10565a:	8b 55 08             	mov    0x8(%ebp),%edx
  10565d:	89 0a                	mov    %ecx,(%edx)
  10565f:	8b 00                	mov    (%eax),%eax
  105661:	99                   	cltd   
  105662:	eb 10                	jmp    105674 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105664:	8b 45 08             	mov    0x8(%ebp),%eax
  105667:	8b 00                	mov    (%eax),%eax
  105669:	8d 48 04             	lea    0x4(%eax),%ecx
  10566c:	8b 55 08             	mov    0x8(%ebp),%edx
  10566f:	89 0a                	mov    %ecx,(%edx)
  105671:	8b 00                	mov    (%eax),%eax
  105673:	99                   	cltd   
    }
}
  105674:	5d                   	pop    %ebp
  105675:	c3                   	ret    

00105676 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105676:	55                   	push   %ebp
  105677:	89 e5                	mov    %esp,%ebp
  105679:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  10567c:	8d 45 14             	lea    0x14(%ebp),%eax
  10567f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105685:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105689:	8b 45 10             	mov    0x10(%ebp),%eax
  10568c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105690:	8b 45 0c             	mov    0xc(%ebp),%eax
  105693:	89 44 24 04          	mov    %eax,0x4(%esp)
  105697:	8b 45 08             	mov    0x8(%ebp),%eax
  10569a:	89 04 24             	mov    %eax,(%esp)
  10569d:	e8 02 00 00 00       	call   1056a4 <vprintfmt>
    va_end(ap);
}
  1056a2:	c9                   	leave  
  1056a3:	c3                   	ret    

001056a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1056a4:	55                   	push   %ebp
  1056a5:	89 e5                	mov    %esp,%ebp
  1056a7:	56                   	push   %esi
  1056a8:	53                   	push   %ebx
  1056a9:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1056ac:	eb 18                	jmp    1056c6 <vprintfmt+0x22>
            if (ch == '\0') {
  1056ae:	85 db                	test   %ebx,%ebx
  1056b0:	75 05                	jne    1056b7 <vprintfmt+0x13>
                return;
  1056b2:	e9 d1 03 00 00       	jmp    105a88 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  1056b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1056ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  1056be:	89 1c 24             	mov    %ebx,(%esp)
  1056c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1056c4:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1056c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1056c9:	8d 50 01             	lea    0x1(%eax),%edx
  1056cc:	89 55 10             	mov    %edx,0x10(%ebp)
  1056cf:	0f b6 00             	movzbl (%eax),%eax
  1056d2:	0f b6 d8             	movzbl %al,%ebx
  1056d5:	83 fb 25             	cmp    $0x25,%ebx
  1056d8:	75 d4                	jne    1056ae <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  1056da:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1056de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1056e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1056e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1056eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1056f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056f5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1056f8:	8b 45 10             	mov    0x10(%ebp),%eax
  1056fb:	8d 50 01             	lea    0x1(%eax),%edx
  1056fe:	89 55 10             	mov    %edx,0x10(%ebp)
  105701:	0f b6 00             	movzbl (%eax),%eax
  105704:	0f b6 d8             	movzbl %al,%ebx
  105707:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10570a:	83 f8 55             	cmp    $0x55,%eax
  10570d:	0f 87 44 03 00 00    	ja     105a57 <vprintfmt+0x3b3>
  105713:	8b 04 85 0c 72 10 00 	mov    0x10720c(,%eax,4),%eax
  10571a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10571c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105720:	eb d6                	jmp    1056f8 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105722:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105726:	eb d0                	jmp    1056f8 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105728:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10572f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105732:	89 d0                	mov    %edx,%eax
  105734:	c1 e0 02             	shl    $0x2,%eax
  105737:	01 d0                	add    %edx,%eax
  105739:	01 c0                	add    %eax,%eax
  10573b:	01 d8                	add    %ebx,%eax
  10573d:	83 e8 30             	sub    $0x30,%eax
  105740:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105743:	8b 45 10             	mov    0x10(%ebp),%eax
  105746:	0f b6 00             	movzbl (%eax),%eax
  105749:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10574c:	83 fb 2f             	cmp    $0x2f,%ebx
  10574f:	7e 0b                	jle    10575c <vprintfmt+0xb8>
  105751:	83 fb 39             	cmp    $0x39,%ebx
  105754:	7f 06                	jg     10575c <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105756:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  10575a:	eb d3                	jmp    10572f <vprintfmt+0x8b>
            goto process_precision;
  10575c:	eb 33                	jmp    105791 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  10575e:	8b 45 14             	mov    0x14(%ebp),%eax
  105761:	8d 50 04             	lea    0x4(%eax),%edx
  105764:	89 55 14             	mov    %edx,0x14(%ebp)
  105767:	8b 00                	mov    (%eax),%eax
  105769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10576c:	eb 23                	jmp    105791 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  10576e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105772:	79 0c                	jns    105780 <vprintfmt+0xdc>
                width = 0;
  105774:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10577b:	e9 78 ff ff ff       	jmp    1056f8 <vprintfmt+0x54>
  105780:	e9 73 ff ff ff       	jmp    1056f8 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  105785:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10578c:	e9 67 ff ff ff       	jmp    1056f8 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105791:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105795:	79 12                	jns    1057a9 <vprintfmt+0x105>
                width = precision, precision = -1;
  105797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10579a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10579d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1057a4:	e9 4f ff ff ff       	jmp    1056f8 <vprintfmt+0x54>
  1057a9:	e9 4a ff ff ff       	jmp    1056f8 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1057ae:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1057b2:	e9 41 ff ff ff       	jmp    1056f8 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1057b7:	8b 45 14             	mov    0x14(%ebp),%eax
  1057ba:	8d 50 04             	lea    0x4(%eax),%edx
  1057bd:	89 55 14             	mov    %edx,0x14(%ebp)
  1057c0:	8b 00                	mov    (%eax),%eax
  1057c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057c9:	89 04 24             	mov    %eax,(%esp)
  1057cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1057cf:	ff d0                	call   *%eax
            break;
  1057d1:	e9 ac 02 00 00       	jmp    105a82 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1057d6:	8b 45 14             	mov    0x14(%ebp),%eax
  1057d9:	8d 50 04             	lea    0x4(%eax),%edx
  1057dc:	89 55 14             	mov    %edx,0x14(%ebp)
  1057df:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1057e1:	85 db                	test   %ebx,%ebx
  1057e3:	79 02                	jns    1057e7 <vprintfmt+0x143>
                err = -err;
  1057e5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1057e7:	83 fb 06             	cmp    $0x6,%ebx
  1057ea:	7f 0b                	jg     1057f7 <vprintfmt+0x153>
  1057ec:	8b 34 9d cc 71 10 00 	mov    0x1071cc(,%ebx,4),%esi
  1057f3:	85 f6                	test   %esi,%esi
  1057f5:	75 23                	jne    10581a <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  1057f7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1057fb:	c7 44 24 08 f9 71 10 	movl   $0x1071f9,0x8(%esp)
  105802:	00 
  105803:	8b 45 0c             	mov    0xc(%ebp),%eax
  105806:	89 44 24 04          	mov    %eax,0x4(%esp)
  10580a:	8b 45 08             	mov    0x8(%ebp),%eax
  10580d:	89 04 24             	mov    %eax,(%esp)
  105810:	e8 61 fe ff ff       	call   105676 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105815:	e9 68 02 00 00       	jmp    105a82 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  10581a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10581e:	c7 44 24 08 02 72 10 	movl   $0x107202,0x8(%esp)
  105825:	00 
  105826:	8b 45 0c             	mov    0xc(%ebp),%eax
  105829:	89 44 24 04          	mov    %eax,0x4(%esp)
  10582d:	8b 45 08             	mov    0x8(%ebp),%eax
  105830:	89 04 24             	mov    %eax,(%esp)
  105833:	e8 3e fe ff ff       	call   105676 <printfmt>
            }
            break;
  105838:	e9 45 02 00 00       	jmp    105a82 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10583d:	8b 45 14             	mov    0x14(%ebp),%eax
  105840:	8d 50 04             	lea    0x4(%eax),%edx
  105843:	89 55 14             	mov    %edx,0x14(%ebp)
  105846:	8b 30                	mov    (%eax),%esi
  105848:	85 f6                	test   %esi,%esi
  10584a:	75 05                	jne    105851 <vprintfmt+0x1ad>
                p = "(null)";
  10584c:	be 05 72 10 00       	mov    $0x107205,%esi
            }
            if (width > 0 && padc != '-') {
  105851:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105855:	7e 3e                	jle    105895 <vprintfmt+0x1f1>
  105857:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  10585b:	74 38                	je     105895 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10585d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  105860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105863:	89 44 24 04          	mov    %eax,0x4(%esp)
  105867:	89 34 24             	mov    %esi,(%esp)
  10586a:	e8 15 03 00 00       	call   105b84 <strnlen>
  10586f:	29 c3                	sub    %eax,%ebx
  105871:	89 d8                	mov    %ebx,%eax
  105873:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105876:	eb 17                	jmp    10588f <vprintfmt+0x1eb>
                    putch(padc, putdat);
  105878:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  10587c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10587f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105883:	89 04 24             	mov    %eax,(%esp)
  105886:	8b 45 08             	mov    0x8(%ebp),%eax
  105889:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  10588b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10588f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105893:	7f e3                	jg     105878 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105895:	eb 38                	jmp    1058cf <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  105897:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  10589b:	74 1f                	je     1058bc <vprintfmt+0x218>
  10589d:	83 fb 1f             	cmp    $0x1f,%ebx
  1058a0:	7e 05                	jle    1058a7 <vprintfmt+0x203>
  1058a2:	83 fb 7e             	cmp    $0x7e,%ebx
  1058a5:	7e 15                	jle    1058bc <vprintfmt+0x218>
                    putch('?', putdat);
  1058a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058ae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1058b5:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b8:	ff d0                	call   *%eax
  1058ba:	eb 0f                	jmp    1058cb <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  1058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058c3:	89 1c 24             	mov    %ebx,(%esp)
  1058c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1058c9:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1058cb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1058cf:	89 f0                	mov    %esi,%eax
  1058d1:	8d 70 01             	lea    0x1(%eax),%esi
  1058d4:	0f b6 00             	movzbl (%eax),%eax
  1058d7:	0f be d8             	movsbl %al,%ebx
  1058da:	85 db                	test   %ebx,%ebx
  1058dc:	74 10                	je     1058ee <vprintfmt+0x24a>
  1058de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058e2:	78 b3                	js     105897 <vprintfmt+0x1f3>
  1058e4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1058e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1058ec:	79 a9                	jns    105897 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1058ee:	eb 17                	jmp    105907 <vprintfmt+0x263>
                putch(' ', putdat);
  1058f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058f7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1058fe:	8b 45 08             	mov    0x8(%ebp),%eax
  105901:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105903:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105907:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10590b:	7f e3                	jg     1058f0 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  10590d:	e9 70 01 00 00       	jmp    105a82 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105912:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105915:	89 44 24 04          	mov    %eax,0x4(%esp)
  105919:	8d 45 14             	lea    0x14(%ebp),%eax
  10591c:	89 04 24             	mov    %eax,(%esp)
  10591f:	e8 0b fd ff ff       	call   10562f <getint>
  105924:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105927:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10592a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10592d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105930:	85 d2                	test   %edx,%edx
  105932:	79 26                	jns    10595a <vprintfmt+0x2b6>
                putch('-', putdat);
  105934:	8b 45 0c             	mov    0xc(%ebp),%eax
  105937:	89 44 24 04          	mov    %eax,0x4(%esp)
  10593b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105942:	8b 45 08             	mov    0x8(%ebp),%eax
  105945:	ff d0                	call   *%eax
                num = -(long long)num;
  105947:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10594a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10594d:	f7 d8                	neg    %eax
  10594f:	83 d2 00             	adc    $0x0,%edx
  105952:	f7 da                	neg    %edx
  105954:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105957:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10595a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105961:	e9 a8 00 00 00       	jmp    105a0e <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105966:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105969:	89 44 24 04          	mov    %eax,0x4(%esp)
  10596d:	8d 45 14             	lea    0x14(%ebp),%eax
  105970:	89 04 24             	mov    %eax,(%esp)
  105973:	e8 68 fc ff ff       	call   1055e0 <getuint>
  105978:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10597b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10597e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105985:	e9 84 00 00 00       	jmp    105a0e <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10598a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10598d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105991:	8d 45 14             	lea    0x14(%ebp),%eax
  105994:	89 04 24             	mov    %eax,(%esp)
  105997:	e8 44 fc ff ff       	call   1055e0 <getuint>
  10599c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10599f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1059a2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1059a9:	eb 63                	jmp    105a0e <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  1059ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1059b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1059bc:	ff d0                	call   *%eax
            putch('x', putdat);
  1059be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059c5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1059cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1059cf:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1059d1:	8b 45 14             	mov    0x14(%ebp),%eax
  1059d4:	8d 50 04             	lea    0x4(%eax),%edx
  1059d7:	89 55 14             	mov    %edx,0x14(%ebp)
  1059da:	8b 00                	mov    (%eax),%eax
  1059dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1059e6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1059ed:	eb 1f                	jmp    105a0e <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1059ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1059f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059f6:	8d 45 14             	lea    0x14(%ebp),%eax
  1059f9:	89 04 24             	mov    %eax,(%esp)
  1059fc:	e8 df fb ff ff       	call   1055e0 <getuint>
  105a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a04:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105a07:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105a0e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a15:	89 54 24 18          	mov    %edx,0x18(%esp)
  105a19:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105a1c:	89 54 24 14          	mov    %edx,0x14(%esp)
  105a20:	89 44 24 10          	mov    %eax,0x10(%esp)
  105a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a39:	8b 45 08             	mov    0x8(%ebp),%eax
  105a3c:	89 04 24             	mov    %eax,(%esp)
  105a3f:	e8 97 fa ff ff       	call   1054db <printnum>
            break;
  105a44:	eb 3c                	jmp    105a82 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a4d:	89 1c 24             	mov    %ebx,(%esp)
  105a50:	8b 45 08             	mov    0x8(%ebp),%eax
  105a53:	ff d0                	call   *%eax
            break;
  105a55:	eb 2b                	jmp    105a82 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a5e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105a65:	8b 45 08             	mov    0x8(%ebp),%eax
  105a68:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105a6a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a6e:	eb 04                	jmp    105a74 <vprintfmt+0x3d0>
  105a70:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105a74:	8b 45 10             	mov    0x10(%ebp),%eax
  105a77:	83 e8 01             	sub    $0x1,%eax
  105a7a:	0f b6 00             	movzbl (%eax),%eax
  105a7d:	3c 25                	cmp    $0x25,%al
  105a7f:	75 ef                	jne    105a70 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  105a81:	90                   	nop
        }
    }
  105a82:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105a83:	e9 3e fc ff ff       	jmp    1056c6 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  105a88:	83 c4 40             	add    $0x40,%esp
  105a8b:	5b                   	pop    %ebx
  105a8c:	5e                   	pop    %esi
  105a8d:	5d                   	pop    %ebp
  105a8e:	c3                   	ret    

00105a8f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105a8f:	55                   	push   %ebp
  105a90:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a95:	8b 40 08             	mov    0x8(%eax),%eax
  105a98:	8d 50 01             	lea    0x1(%eax),%edx
  105a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a9e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa4:	8b 10                	mov    (%eax),%edx
  105aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aa9:	8b 40 04             	mov    0x4(%eax),%eax
  105aac:	39 c2                	cmp    %eax,%edx
  105aae:	73 12                	jae    105ac2 <sprintputch+0x33>
        *b->buf ++ = ch;
  105ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ab3:	8b 00                	mov    (%eax),%eax
  105ab5:	8d 48 01             	lea    0x1(%eax),%ecx
  105ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
  105abb:	89 0a                	mov    %ecx,(%edx)
  105abd:	8b 55 08             	mov    0x8(%ebp),%edx
  105ac0:	88 10                	mov    %dl,(%eax)
    }
}
  105ac2:	5d                   	pop    %ebp
  105ac3:	c3                   	ret    

00105ac4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105ac4:	55                   	push   %ebp
  105ac5:	89 e5                	mov    %esp,%ebp
  105ac7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105aca:	8d 45 14             	lea    0x14(%ebp),%eax
  105acd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  105ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae8:	89 04 24             	mov    %eax,(%esp)
  105aeb:	e8 08 00 00 00       	call   105af8 <vsnprintf>
  105af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105af6:	c9                   	leave  
  105af7:	c3                   	ret    

00105af8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105af8:	55                   	push   %ebp
  105af9:	89 e5                	mov    %esp,%ebp
  105afb:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105afe:	8b 45 08             	mov    0x8(%ebp),%eax
  105b01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b07:	8d 50 ff             	lea    -0x1(%eax),%edx
  105b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  105b0d:	01 d0                	add    %edx,%eax
  105b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105b19:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105b1d:	74 0a                	je     105b29 <vsnprintf+0x31>
  105b1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b25:	39 c2                	cmp    %eax,%edx
  105b27:	76 07                	jbe    105b30 <vsnprintf+0x38>
        return -E_INVAL;
  105b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105b2e:	eb 2a                	jmp    105b5a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105b30:	8b 45 14             	mov    0x14(%ebp),%eax
  105b33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105b37:	8b 45 10             	mov    0x10(%ebp),%eax
  105b3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105b3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b45:	c7 04 24 8f 5a 10 00 	movl   $0x105a8f,(%esp)
  105b4c:	e8 53 fb ff ff       	call   1056a4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105b54:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105b5a:	c9                   	leave  
  105b5b:	c3                   	ret    

00105b5c <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105b5c:	55                   	push   %ebp
  105b5d:	89 e5                	mov    %esp,%ebp
  105b5f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105b69:	eb 04                	jmp    105b6f <strlen+0x13>
        cnt ++;
  105b6b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  105b72:	8d 50 01             	lea    0x1(%eax),%edx
  105b75:	89 55 08             	mov    %edx,0x8(%ebp)
  105b78:	0f b6 00             	movzbl (%eax),%eax
  105b7b:	84 c0                	test   %al,%al
  105b7d:	75 ec                	jne    105b6b <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b82:	c9                   	leave  
  105b83:	c3                   	ret    

00105b84 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105b84:	55                   	push   %ebp
  105b85:	89 e5                	mov    %esp,%ebp
  105b87:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b8a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b91:	eb 04                	jmp    105b97 <strnlen+0x13>
        cnt ++;
  105b93:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105b97:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b9a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105b9d:	73 10                	jae    105baf <strnlen+0x2b>
  105b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  105ba2:	8d 50 01             	lea    0x1(%eax),%edx
  105ba5:	89 55 08             	mov    %edx,0x8(%ebp)
  105ba8:	0f b6 00             	movzbl (%eax),%eax
  105bab:	84 c0                	test   %al,%al
  105bad:	75 e4                	jne    105b93 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105baf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105bb2:	c9                   	leave  
  105bb3:	c3                   	ret    

00105bb4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105bb4:	55                   	push   %ebp
  105bb5:	89 e5                	mov    %esp,%ebp
  105bb7:	57                   	push   %edi
  105bb8:	56                   	push   %esi
  105bb9:	83 ec 20             	sub    $0x20,%esp
  105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  105bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bce:	89 d1                	mov    %edx,%ecx
  105bd0:	89 c2                	mov    %eax,%edx
  105bd2:	89 ce                	mov    %ecx,%esi
  105bd4:	89 d7                	mov    %edx,%edi
  105bd6:	ac                   	lods   %ds:(%esi),%al
  105bd7:	aa                   	stos   %al,%es:(%edi)
  105bd8:	84 c0                	test   %al,%al
  105bda:	75 fa                	jne    105bd6 <strcpy+0x22>
  105bdc:	89 fa                	mov    %edi,%edx
  105bde:	89 f1                	mov    %esi,%ecx
  105be0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105be3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105be6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105bec:	83 c4 20             	add    $0x20,%esp
  105bef:	5e                   	pop    %esi
  105bf0:	5f                   	pop    %edi
  105bf1:	5d                   	pop    %ebp
  105bf2:	c3                   	ret    

00105bf3 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105bf3:	55                   	push   %ebp
  105bf4:	89 e5                	mov    %esp,%ebp
  105bf6:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105bff:	eb 21                	jmp    105c22 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c04:	0f b6 10             	movzbl (%eax),%edx
  105c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105c0a:	88 10                	mov    %dl,(%eax)
  105c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105c0f:	0f b6 00             	movzbl (%eax),%eax
  105c12:	84 c0                	test   %al,%al
  105c14:	74 04                	je     105c1a <strncpy+0x27>
            src ++;
  105c16:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105c1a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105c1e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105c22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c26:	75 d9                	jne    105c01 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105c28:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105c2b:	c9                   	leave  
  105c2c:	c3                   	ret    

00105c2d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105c2d:	55                   	push   %ebp
  105c2e:	89 e5                	mov    %esp,%ebp
  105c30:	57                   	push   %edi
  105c31:	56                   	push   %esi
  105c32:	83 ec 20             	sub    $0x20,%esp
  105c35:	8b 45 08             	mov    0x8(%ebp),%eax
  105c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c47:	89 d1                	mov    %edx,%ecx
  105c49:	89 c2                	mov    %eax,%edx
  105c4b:	89 ce                	mov    %ecx,%esi
  105c4d:	89 d7                	mov    %edx,%edi
  105c4f:	ac                   	lods   %ds:(%esi),%al
  105c50:	ae                   	scas   %es:(%edi),%al
  105c51:	75 08                	jne    105c5b <strcmp+0x2e>
  105c53:	84 c0                	test   %al,%al
  105c55:	75 f8                	jne    105c4f <strcmp+0x22>
  105c57:	31 c0                	xor    %eax,%eax
  105c59:	eb 04                	jmp    105c5f <strcmp+0x32>
  105c5b:	19 c0                	sbb    %eax,%eax
  105c5d:	0c 01                	or     $0x1,%al
  105c5f:	89 fa                	mov    %edi,%edx
  105c61:	89 f1                	mov    %esi,%ecx
  105c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c66:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105c6f:	83 c4 20             	add    $0x20,%esp
  105c72:	5e                   	pop    %esi
  105c73:	5f                   	pop    %edi
  105c74:	5d                   	pop    %ebp
  105c75:	c3                   	ret    

00105c76 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105c76:	55                   	push   %ebp
  105c77:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c79:	eb 0c                	jmp    105c87 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105c7b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105c7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105c83:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105c87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c8b:	74 1a                	je     105ca7 <strncmp+0x31>
  105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c90:	0f b6 00             	movzbl (%eax),%eax
  105c93:	84 c0                	test   %al,%al
  105c95:	74 10                	je     105ca7 <strncmp+0x31>
  105c97:	8b 45 08             	mov    0x8(%ebp),%eax
  105c9a:	0f b6 10             	movzbl (%eax),%edx
  105c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ca0:	0f b6 00             	movzbl (%eax),%eax
  105ca3:	38 c2                	cmp    %al,%dl
  105ca5:	74 d4                	je     105c7b <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105ca7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105cab:	74 18                	je     105cc5 <strncmp+0x4f>
  105cad:	8b 45 08             	mov    0x8(%ebp),%eax
  105cb0:	0f b6 00             	movzbl (%eax),%eax
  105cb3:	0f b6 d0             	movzbl %al,%edx
  105cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cb9:	0f b6 00             	movzbl (%eax),%eax
  105cbc:	0f b6 c0             	movzbl %al,%eax
  105cbf:	29 c2                	sub    %eax,%edx
  105cc1:	89 d0                	mov    %edx,%eax
  105cc3:	eb 05                	jmp    105cca <strncmp+0x54>
  105cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105cca:	5d                   	pop    %ebp
  105ccb:	c3                   	ret    

00105ccc <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105ccc:	55                   	push   %ebp
  105ccd:	89 e5                	mov    %esp,%ebp
  105ccf:	83 ec 04             	sub    $0x4,%esp
  105cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cd5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105cd8:	eb 14                	jmp    105cee <strchr+0x22>
        if (*s == c) {
  105cda:	8b 45 08             	mov    0x8(%ebp),%eax
  105cdd:	0f b6 00             	movzbl (%eax),%eax
  105ce0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105ce3:	75 05                	jne    105cea <strchr+0x1e>
            return (char *)s;
  105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce8:	eb 13                	jmp    105cfd <strchr+0x31>
        }
        s ++;
  105cea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105cee:	8b 45 08             	mov    0x8(%ebp),%eax
  105cf1:	0f b6 00             	movzbl (%eax),%eax
  105cf4:	84 c0                	test   %al,%al
  105cf6:	75 e2                	jne    105cda <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105cfd:	c9                   	leave  
  105cfe:	c3                   	ret    

00105cff <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105cff:	55                   	push   %ebp
  105d00:	89 e5                	mov    %esp,%ebp
  105d02:	83 ec 04             	sub    $0x4,%esp
  105d05:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d08:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105d0b:	eb 11                	jmp    105d1e <strfind+0x1f>
        if (*s == c) {
  105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d10:	0f b6 00             	movzbl (%eax),%eax
  105d13:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105d16:	75 02                	jne    105d1a <strfind+0x1b>
            break;
  105d18:	eb 0e                	jmp    105d28 <strfind+0x29>
        }
        s ++;
  105d1a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d21:	0f b6 00             	movzbl (%eax),%eax
  105d24:	84 c0                	test   %al,%al
  105d26:	75 e5                	jne    105d0d <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105d28:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105d2b:	c9                   	leave  
  105d2c:	c3                   	ret    

00105d2d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105d2d:	55                   	push   %ebp
  105d2e:	89 e5                	mov    %esp,%ebp
  105d30:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105d33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105d3a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d41:	eb 04                	jmp    105d47 <strtol+0x1a>
        s ++;
  105d43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105d47:	8b 45 08             	mov    0x8(%ebp),%eax
  105d4a:	0f b6 00             	movzbl (%eax),%eax
  105d4d:	3c 20                	cmp    $0x20,%al
  105d4f:	74 f2                	je     105d43 <strtol+0x16>
  105d51:	8b 45 08             	mov    0x8(%ebp),%eax
  105d54:	0f b6 00             	movzbl (%eax),%eax
  105d57:	3c 09                	cmp    $0x9,%al
  105d59:	74 e8                	je     105d43 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5e:	0f b6 00             	movzbl (%eax),%eax
  105d61:	3c 2b                	cmp    $0x2b,%al
  105d63:	75 06                	jne    105d6b <strtol+0x3e>
        s ++;
  105d65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d69:	eb 15                	jmp    105d80 <strtol+0x53>
    }
    else if (*s == '-') {
  105d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d6e:	0f b6 00             	movzbl (%eax),%eax
  105d71:	3c 2d                	cmp    $0x2d,%al
  105d73:	75 0b                	jne    105d80 <strtol+0x53>
        s ++, neg = 1;
  105d75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d79:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d84:	74 06                	je     105d8c <strtol+0x5f>
  105d86:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105d8a:	75 24                	jne    105db0 <strtol+0x83>
  105d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8f:	0f b6 00             	movzbl (%eax),%eax
  105d92:	3c 30                	cmp    $0x30,%al
  105d94:	75 1a                	jne    105db0 <strtol+0x83>
  105d96:	8b 45 08             	mov    0x8(%ebp),%eax
  105d99:	83 c0 01             	add    $0x1,%eax
  105d9c:	0f b6 00             	movzbl (%eax),%eax
  105d9f:	3c 78                	cmp    $0x78,%al
  105da1:	75 0d                	jne    105db0 <strtol+0x83>
        s += 2, base = 16;
  105da3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105da7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105dae:	eb 2a                	jmp    105dda <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105db4:	75 17                	jne    105dcd <strtol+0xa0>
  105db6:	8b 45 08             	mov    0x8(%ebp),%eax
  105db9:	0f b6 00             	movzbl (%eax),%eax
  105dbc:	3c 30                	cmp    $0x30,%al
  105dbe:	75 0d                	jne    105dcd <strtol+0xa0>
        s ++, base = 8;
  105dc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105dc4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105dcb:	eb 0d                	jmp    105dda <strtol+0xad>
    }
    else if (base == 0) {
  105dcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105dd1:	75 07                	jne    105dda <strtol+0xad>
        base = 10;
  105dd3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105dda:	8b 45 08             	mov    0x8(%ebp),%eax
  105ddd:	0f b6 00             	movzbl (%eax),%eax
  105de0:	3c 2f                	cmp    $0x2f,%al
  105de2:	7e 1b                	jle    105dff <strtol+0xd2>
  105de4:	8b 45 08             	mov    0x8(%ebp),%eax
  105de7:	0f b6 00             	movzbl (%eax),%eax
  105dea:	3c 39                	cmp    $0x39,%al
  105dec:	7f 11                	jg     105dff <strtol+0xd2>
            dig = *s - '0';
  105dee:	8b 45 08             	mov    0x8(%ebp),%eax
  105df1:	0f b6 00             	movzbl (%eax),%eax
  105df4:	0f be c0             	movsbl %al,%eax
  105df7:	83 e8 30             	sub    $0x30,%eax
  105dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105dfd:	eb 48                	jmp    105e47 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105dff:	8b 45 08             	mov    0x8(%ebp),%eax
  105e02:	0f b6 00             	movzbl (%eax),%eax
  105e05:	3c 60                	cmp    $0x60,%al
  105e07:	7e 1b                	jle    105e24 <strtol+0xf7>
  105e09:	8b 45 08             	mov    0x8(%ebp),%eax
  105e0c:	0f b6 00             	movzbl (%eax),%eax
  105e0f:	3c 7a                	cmp    $0x7a,%al
  105e11:	7f 11                	jg     105e24 <strtol+0xf7>
            dig = *s - 'a' + 10;
  105e13:	8b 45 08             	mov    0x8(%ebp),%eax
  105e16:	0f b6 00             	movzbl (%eax),%eax
  105e19:	0f be c0             	movsbl %al,%eax
  105e1c:	83 e8 57             	sub    $0x57,%eax
  105e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e22:	eb 23                	jmp    105e47 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105e24:	8b 45 08             	mov    0x8(%ebp),%eax
  105e27:	0f b6 00             	movzbl (%eax),%eax
  105e2a:	3c 40                	cmp    $0x40,%al
  105e2c:	7e 3d                	jle    105e6b <strtol+0x13e>
  105e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  105e31:	0f b6 00             	movzbl (%eax),%eax
  105e34:	3c 5a                	cmp    $0x5a,%al
  105e36:	7f 33                	jg     105e6b <strtol+0x13e>
            dig = *s - 'A' + 10;
  105e38:	8b 45 08             	mov    0x8(%ebp),%eax
  105e3b:	0f b6 00             	movzbl (%eax),%eax
  105e3e:	0f be c0             	movsbl %al,%eax
  105e41:	83 e8 37             	sub    $0x37,%eax
  105e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e4a:	3b 45 10             	cmp    0x10(%ebp),%eax
  105e4d:	7c 02                	jl     105e51 <strtol+0x124>
            break;
  105e4f:	eb 1a                	jmp    105e6b <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105e51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e58:	0f af 45 10          	imul   0x10(%ebp),%eax
  105e5c:	89 c2                	mov    %eax,%edx
  105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105e61:	01 d0                	add    %edx,%eax
  105e63:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105e66:	e9 6f ff ff ff       	jmp    105dda <strtol+0xad>

    if (endptr) {
  105e6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105e6f:	74 08                	je     105e79 <strtol+0x14c>
        *endptr = (char *) s;
  105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e74:	8b 55 08             	mov    0x8(%ebp),%edx
  105e77:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105e79:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105e7d:	74 07                	je     105e86 <strtol+0x159>
  105e7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105e82:	f7 d8                	neg    %eax
  105e84:	eb 03                	jmp    105e89 <strtol+0x15c>
  105e86:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105e89:	c9                   	leave  
  105e8a:	c3                   	ret    

00105e8b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105e8b:	55                   	push   %ebp
  105e8c:	89 e5                	mov    %esp,%ebp
  105e8e:	57                   	push   %edi
  105e8f:	83 ec 24             	sub    $0x24,%esp
  105e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e95:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105e98:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  105e9f:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105ea2:	88 45 f7             	mov    %al,-0x9(%ebp)
  105ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  105ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105eab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105eae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105eb2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105eb5:	89 d7                	mov    %edx,%edi
  105eb7:	f3 aa                	rep stos %al,%es:(%edi)
  105eb9:	89 fa                	mov    %edi,%edx
  105ebb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105ebe:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105ec1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105ec4:	83 c4 24             	add    $0x24,%esp
  105ec7:	5f                   	pop    %edi
  105ec8:	5d                   	pop    %ebp
  105ec9:	c3                   	ret    

00105eca <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105eca:	55                   	push   %ebp
  105ecb:	89 e5                	mov    %esp,%ebp
  105ecd:	57                   	push   %edi
  105ece:	56                   	push   %esi
  105ecf:	53                   	push   %ebx
  105ed0:	83 ec 30             	sub    $0x30,%esp
  105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105edc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105edf:	8b 45 10             	mov    0x10(%ebp),%eax
  105ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ee8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105eeb:	73 42                	jae    105f2f <memmove+0x65>
  105eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ef0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ef6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105efc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105eff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f02:	c1 e8 02             	shr    $0x2,%eax
  105f05:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105f07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105f0d:	89 d7                	mov    %edx,%edi
  105f0f:	89 c6                	mov    %eax,%esi
  105f11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f13:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105f16:	83 e1 03             	and    $0x3,%ecx
  105f19:	74 02                	je     105f1d <memmove+0x53>
  105f1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f1d:	89 f0                	mov    %esi,%eax
  105f1f:	89 fa                	mov    %edi,%edx
  105f21:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105f24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105f27:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105f2d:	eb 36                	jmp    105f65 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f32:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f38:	01 c2                	add    %eax,%edx
  105f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f3d:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f43:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105f46:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105f49:	89 c1                	mov    %eax,%ecx
  105f4b:	89 d8                	mov    %ebx,%eax
  105f4d:	89 d6                	mov    %edx,%esi
  105f4f:	89 c7                	mov    %eax,%edi
  105f51:	fd                   	std    
  105f52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f54:	fc                   	cld    
  105f55:	89 f8                	mov    %edi,%eax
  105f57:	89 f2                	mov    %esi,%edx
  105f59:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105f5c:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105f5f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105f65:	83 c4 30             	add    $0x30,%esp
  105f68:	5b                   	pop    %ebx
  105f69:	5e                   	pop    %esi
  105f6a:	5f                   	pop    %edi
  105f6b:	5d                   	pop    %ebp
  105f6c:	c3                   	ret    

00105f6d <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105f6d:	55                   	push   %ebp
  105f6e:	89 e5                	mov    %esp,%ebp
  105f70:	57                   	push   %edi
  105f71:	56                   	push   %esi
  105f72:	83 ec 20             	sub    $0x20,%esp
  105f75:	8b 45 08             	mov    0x8(%ebp),%eax
  105f78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105f81:	8b 45 10             	mov    0x10(%ebp),%eax
  105f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f8a:	c1 e8 02             	shr    $0x2,%eax
  105f8d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105f8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f95:	89 d7                	mov    %edx,%edi
  105f97:	89 c6                	mov    %eax,%esi
  105f99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f9b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105f9e:	83 e1 03             	and    $0x3,%ecx
  105fa1:	74 02                	je     105fa5 <memcpy+0x38>
  105fa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105fa5:	89 f0                	mov    %esi,%eax
  105fa7:	89 fa                	mov    %edi,%edx
  105fa9:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105fac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105faf:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105fb5:	83 c4 20             	add    $0x20,%esp
  105fb8:	5e                   	pop    %esi
  105fb9:	5f                   	pop    %edi
  105fba:	5d                   	pop    %ebp
  105fbb:	c3                   	ret    

00105fbc <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105fbc:	55                   	push   %ebp
  105fbd:	89 e5                	mov    %esp,%ebp
  105fbf:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fcb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105fce:	eb 30                	jmp    106000 <memcmp+0x44>
        if (*s1 != *s2) {
  105fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fd3:	0f b6 10             	movzbl (%eax),%edx
  105fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105fd9:	0f b6 00             	movzbl (%eax),%eax
  105fdc:	38 c2                	cmp    %al,%dl
  105fde:	74 18                	je     105ff8 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105fe0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105fe3:	0f b6 00             	movzbl (%eax),%eax
  105fe6:	0f b6 d0             	movzbl %al,%edx
  105fe9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105fec:	0f b6 00             	movzbl (%eax),%eax
  105fef:	0f b6 c0             	movzbl %al,%eax
  105ff2:	29 c2                	sub    %eax,%edx
  105ff4:	89 d0                	mov    %edx,%eax
  105ff6:	eb 1a                	jmp    106012 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105ff8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105ffc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  106000:	8b 45 10             	mov    0x10(%ebp),%eax
  106003:	8d 50 ff             	lea    -0x1(%eax),%edx
  106006:	89 55 10             	mov    %edx,0x10(%ebp)
  106009:	85 c0                	test   %eax,%eax
  10600b:	75 c3                	jne    105fd0 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  10600d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  106012:	c9                   	leave  
  106013:	c3                   	ret    
