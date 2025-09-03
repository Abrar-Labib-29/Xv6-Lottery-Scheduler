
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	2d013103          	ld	sp,720(sp) # 8000a2d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdad9f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	3a8020ef          	jal	800024a2 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	1dc50513          	addi	a0,a0,476 # 80012330 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	1d048493          	addi	s1,s1,464 # 80012330 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	26090913          	addi	s2,s2,608 # 800123c8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	1b0020ef          	jal	80002334 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	76f010ef          	jal	800020fc <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	19070713          	addi	a4,a4,400 # 80012330 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	286020ef          	jal	80002458 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	14650513          	addi	a0,a0,326 # 80012330 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	1af72a23          	sw	a5,436(a4) # 800123c8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	10650513          	addi	a0,a0,262 # 80012330 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	0b250513          	addi	a0,a0,178 # 80012330 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	24c020ef          	jal	800024ec <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	08c50513          	addi	a0,a0,140 # 80012330 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	06e70713          	addi	a4,a4,110 # 80012330 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	04878793          	addi	a5,a5,72 # 80012330 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	0b27a783          	lw	a5,178(a5) # 800123c8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	00470713          	addi	a4,a4,4 # 80012330 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	ff448493          	addi	s1,s1,-12 # 80012330 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	fb270713          	addi	a4,a4,-78 # 80012330 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	02f72e23          	sw	a5,60(a4) # 800123d0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	f7e78793          	addi	a5,a5,-130 # 80012330 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	fec7ab23          	sw	a2,-10(a5) # 800123cc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	fea50513          	addi	a0,a0,-22 # 800123c8 <cons+0x98>
    800003e6:	563010ef          	jal	80002148 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	f3450513          	addi	a0,a0,-204 # 80012330 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	4bc78793          	addi	a5,a5,1212 # 800228c8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	f107a783          	lw	a5,-240(a5) # 800123f0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	eac50513          	addi	a0,a0,-340 # 800123d8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	c5250513          	addi	a0,a0,-942 # 800123d8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	c407a823          	sw	zero,-944(a5) # 800123f0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	b2f72623          	sw	a5,-1236(a4) # 8000a2f0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	c0048493          	addi	s1,s1,-1024 # 800123d8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	bb850513          	addi	a0,a0,-1096 # 800123f8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	a8c7a783          	lw	a5,-1396(a5) # 8000a2f0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	a5e7b783          	ld	a5,-1442(a5) # 8000a2f8 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	a5e73703          	ld	a4,-1442(a4) # 8000a300 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	b30a8a93          	addi	s5,s5,-1232 # 800123f8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	a2848493          	addi	s1,s1,-1496 # 8000a2f8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	a2498993          	addi	s3,s3,-1500 # 8000a300 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	04b010ef          	jal	80002148 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	aac50513          	addi	a0,a0,-1364 # 800123f8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	9987a783          	lw	a5,-1640(a5) # 8000a2f0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	99e73703          	ld	a4,-1634(a4) # 8000a300 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	98e7b783          	ld	a5,-1650(a5) # 8000a2f8 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	a8298993          	addi	s3,s3,-1406 # 800123f8 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	97a48493          	addi	s1,s1,-1670 # 8000a2f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	97a90913          	addi	s2,s2,-1670 # 8000a300 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	766010ef          	jal	800020fc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	a5048493          	addi	s1,s1,-1456 # 800123f8 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	94e7b223          	sd	a4,-1724(a5) # 8000a300 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	9d848493          	addi	s1,s1,-1576 # 800123f8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	00a78793          	addi	a5,a5,10 # 80023a60 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	9be90913          	addi	s2,s2,-1602 # 80012430 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	93050513          	addi	a0,a0,-1744 # 80012430 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	f5050513          	addi	a0,a0,-176 # 80023a60 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	90248493          	addi	s1,s1,-1790 # 80012430 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	8ee50513          	addi	a0,a0,-1810 # 80012430 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	8ca50513          	addi	a0,a0,-1846 # 80012430 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb5a1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	49a70713          	addi	a4,a4,1178 # 8000a308 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	786010ef          	jal	8000261e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	60c040ef          	jal	800054a8 <plicinithart>
  }

  scheduler();        
    80000ea0:	048010ef          	jal	80001ee8 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	71a010ef          	jal	800025fa <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	73a010ef          	jal	8000261e <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	5a6040ef          	jal	8000548e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	5bc040ef          	jal	800054a8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	561010ef          	jal	80002c50 <binit>
    iinit();         // inode table
    80000ef4:	352020ef          	jal	80003246 <iinit>
    fileinit();      // file table
    80000ef8:	0fe030ef          	jal	80003ff6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	69c040ef          	jal	80005598 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	609000ef          	jal	80001d08 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	3ef72f23          	sw	a5,1022(a4) # 8000a308 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	3f27b783          	ld	a5,1010(a5) # 8000a310 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb597>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	16a7b323          	sd	a0,358(a5) # 8000a310 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	10448493          	addi	s1,s1,260 # 80012880 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	00a36937          	lui	s2,0xa36
    8000178a:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	46d90913          	addi	s2,s2,1133
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	df590913          	addi	s2,s2,-523
    8000179a:	093a                	slli	s2,s2,0xe
    8000179c:	6cf90913          	addi	s2,s2,1743
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	ed8a8a93          	addi	s5,s5,-296 # 80018680 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if (pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800017d6:	17848493          	addi	s1,s1,376
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	c3650513          	addi	a0,a0,-970 # 80012450 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	c3a50513          	addi	a0,a0,-966 # 80012468 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	04648493          	addi	s1,s1,70 # 80012880 <proc>
  {
    initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	00a36937          	lui	s2,0xa36
    80001850:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	46d90913          	addi	s2,s2,1133
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	df590913          	addi	s2,s2,-523
    80001860:	093a                	slli	s2,s2,0xe
    80001862:	6cf90913          	addi	s2,s2,1743
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	e12a0a13          	addi	s4,s4,-494 # 80018680 <tickslock>
    initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
    p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001898:	17848493          	addi	s1,s1,376
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	bb050513          	addi	a0,a0,-1104 # 80012480 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	b5c70713          	addi	a4,a4,-1188 # 80012450 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first)
    80001920:	00009797          	auipc	a5,0x9
    80001924:	9607a783          	lw	a5,-1696(a5) # 8000a280 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	50d000ef          	jal	80002636 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	0a3010ef          	jal	800031da <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	9407a223          	sw	zero,-1724(a5) # 8000a280 <first.1>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	afa90913          	addi	s2,s2,-1286 # 80012450 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	92478793          	addi	a5,a5,-1756 # 8000a288 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <init_tickets>:
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
  p->tickets_original = 1; // default 1 ticket
    8000198e:	4785                	li	a5,1
    80001990:	16f52423          	sw	a5,360(a0)
  p->tickets_current = 1;
    80001994:	16f52623          	sw	a5,364(a0)
  p->time_slices = 0;
    80001998:	16052823          	sw	zero,368(a0)
};
    8000199c:	6422                	ld	s0,8(sp)
    8000199e:	0141                	addi	sp,sp,16
    800019a0:	8082                	ret

00000000800019a2 <reset_tickets>:
{
    800019a2:	1101                	addi	sp,sp,-32
    800019a4:	ec06                	sd	ra,24(sp)
    800019a6:	e822                	sd	s0,16(sp)
    800019a8:	e426                	sd	s1,8(sp)
    800019aa:	e04a                	sd	s2,0(sp)
    800019ac:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    800019ae:	00011497          	auipc	s1,0x11
    800019b2:	ed248493          	addi	s1,s1,-302 # 80012880 <proc>
    800019b6:	00017917          	auipc	s2,0x17
    800019ba:	cca90913          	addi	s2,s2,-822 # 80018680 <tickslock>
    800019be:	a801                	j	800019ce <reset_tickets+0x2c>
    release(&p->lock);
    800019c0:	8526                	mv	a0,s1
    800019c2:	acaff0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800019c6:	17848493          	addi	s1,s1,376
    800019ca:	01248c63          	beq	s1,s2,800019e2 <reset_tickets+0x40>
    acquire(&p->lock);
    800019ce:	8526                	mv	a0,s1
    800019d0:	a24ff0ef          	jal	80000bf4 <acquire>
    if (p->state != UNUSED)
    800019d4:	4c9c                	lw	a5,24(s1)
    800019d6:	d7ed                	beqz	a5,800019c0 <reset_tickets+0x1e>
      p->tickets_current = p->tickets_original;
    800019d8:	1684a783          	lw	a5,360(s1)
    800019dc:	16f4a623          	sw	a5,364(s1)
    800019e0:	b7c5                	j	800019c0 <reset_tickets+0x1e>
}
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6902                	ld	s2,0(sp)
    800019ea:	6105                	addi	sp,sp,32
    800019ec:	8082                	ret

00000000800019ee <all_tickets_used>:
{
    800019ee:	7179                	addi	sp,sp,-48
    800019f0:	f406                	sd	ra,40(sp)
    800019f2:	f022                	sd	s0,32(sp)
    800019f4:	ec26                	sd	s1,24(sp)
    800019f6:	e84a                	sd	s2,16(sp)
    800019f8:	e44e                	sd	s3,8(sp)
    800019fa:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    800019fc:	00011497          	auipc	s1,0x11
    80001a00:	e8448493          	addi	s1,s1,-380 # 80012880 <proc>
    if (p->state == RUNNABLE && p->tickets_current > 0)
    80001a04:	490d                	li	s2,3
  for (p = proc; p < &proc[NPROC]; p++)
    80001a06:	00017997          	auipc	s3,0x17
    80001a0a:	c7a98993          	addi	s3,s3,-902 # 80018680 <tickslock>
    80001a0e:	a801                	j	80001a1e <all_tickets_used+0x30>
    release(&p->lock);
    80001a10:	8526                	mv	a0,s1
    80001a12:	a7aff0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a16:	17848493          	addi	s1,s1,376
    80001a1a:	03348763          	beq	s1,s3,80001a48 <all_tickets_used+0x5a>
    acquire(&p->lock);
    80001a1e:	8526                	mv	a0,s1
    80001a20:	9d4ff0ef          	jal	80000bf4 <acquire>
    if (p->state == RUNNABLE && p->tickets_current > 0)
    80001a24:	4c9c                	lw	a5,24(s1)
    80001a26:	ff2795e3          	bne	a5,s2,80001a10 <all_tickets_used+0x22>
    80001a2a:	16c4a783          	lw	a5,364(s1)
    80001a2e:	fef051e3          	blez	a5,80001a10 <all_tickets_used+0x22>
      release(&p->lock);
    80001a32:	8526                	mv	a0,s1
    80001a34:	a58ff0ef          	jal	80000c8c <release>
      return 0;
    80001a38:	4501                	li	a0,0
}
    80001a3a:	70a2                	ld	ra,40(sp)
    80001a3c:	7402                	ld	s0,32(sp)
    80001a3e:	64e2                	ld	s1,24(sp)
    80001a40:	6942                	ld	s2,16(sp)
    80001a42:	69a2                	ld	s3,8(sp)
    80001a44:	6145                	addi	sp,sp,48
    80001a46:	8082                	ret
  return 1;
    80001a48:	4505                	li	a0,1
    80001a4a:	bfc5                	j	80001a3a <all_tickets_used+0x4c>

0000000080001a4c <sys_settickets>:
{
    80001a4c:	7179                	addi	sp,sp,-48
    80001a4e:	f406                	sd	ra,40(sp)
    80001a50:	f022                	sd	s0,32(sp)
    80001a52:	1800                	addi	s0,sp,48
  argint(0, &n);
    80001a54:	fdc40593          	addi	a1,s0,-36
    80001a58:	4501                	li	a0,0
    80001a5a:	789000ef          	jal	800029e2 <argint>
  if (n < 1)
    80001a5e:	fdc42783          	lw	a5,-36(s0)
    return -1;
    80001a62:	557d                	li	a0,-1
  if (n < 1)
    80001a64:	02f05363          	blez	a5,80001a8a <sys_settickets+0x3e>
    80001a68:	ec26                	sd	s1,24(sp)
  struct proc *p = myproc();
    80001a6a:	e77ff0ef          	jal	800018e0 <myproc>
    80001a6e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a70:	984ff0ef          	jal	80000bf4 <acquire>
  p->tickets_original = n;
    80001a74:	fdc42783          	lw	a5,-36(s0)
    80001a78:	16f4a423          	sw	a5,360(s1)
  p->tickets_current = n;
    80001a7c:	16f4a623          	sw	a5,364(s1)
  release(&p->lock);
    80001a80:	8526                	mv	a0,s1
    80001a82:	a0aff0ef          	jal	80000c8c <release>
  return 0;
    80001a86:	4501                	li	a0,0
    80001a88:	64e2                	ld	s1,24(sp)
}
    80001a8a:	70a2                	ld	ra,40(sp)
    80001a8c:	7402                	ld	s0,32(sp)
    80001a8e:	6145                	addi	sp,sp,48
    80001a90:	8082                	ret

0000000080001a92 <sys_getpinfo>:
{
    80001a92:	ac010113          	addi	sp,sp,-1344
    80001a96:	52113c23          	sd	ra,1336(sp)
    80001a9a:	52813823          	sd	s0,1328(sp)
    80001a9e:	52913423          	sd	s1,1320(sp)
    80001aa2:	53213023          	sd	s2,1312(sp)
    80001aa6:	51313c23          	sd	s3,1304(sp)
    80001aaa:	54010413          	addi	s0,sp,1344
  argaddr(0, (uint64*)&user_ps);
    80001aae:	ac840593          	addi	a1,s0,-1336
    80001ab2:	4501                	li	a0,0
    80001ab4:	74b000ef          	jal	800029fe <argaddr>
  for (p = proc; p < &proc[NPROC]; p++)
    80001ab8:	ad040913          	addi	s2,s0,-1328
    80001abc:	00011497          	auipc	s1,0x11
    80001ac0:	dc448493          	addi	s1,s1,-572 # 80012880 <proc>
    80001ac4:	00017997          	auipc	s3,0x17
    80001ac8:	bbc98993          	addi	s3,s3,-1092 # 80018680 <tickslock>
    acquire(&p->lock);
    80001acc:	8526                	mv	a0,s1
    80001ace:	926ff0ef          	jal	80000bf4 <acquire>
    ps.pid[i] = p->pid;
    80001ad2:	589c                	lw	a5,48(s1)
    80001ad4:	00f92023          	sw	a5,0(s2)
    ps.inuse[i] = (p->state != UNUSED) ? 1 : 0;
    80001ad8:	4c9c                	lw	a5,24(s1)
    80001ada:	00f037b3          	snez	a5,a5
    80001ade:	10f92023          	sw	a5,256(s2)
    ps.tickets_original[i] = p->tickets_original;
    80001ae2:	1684a783          	lw	a5,360(s1)
    80001ae6:	20f92023          	sw	a5,512(s2)
    ps.tickets_current[i] = p->tickets_current;
    80001aea:	16c4a783          	lw	a5,364(s1)
    80001aee:	30f92023          	sw	a5,768(s2)
    ps.time_slices[i] = p->time_slices;
    80001af2:	1704a783          	lw	a5,368(s1)
    80001af6:	40f92023          	sw	a5,1024(s2)
    release(&p->lock);
    80001afa:	8526                	mv	a0,s1
    80001afc:	990ff0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001b00:	17848493          	addi	s1,s1,376
    80001b04:	0911                	addi	s2,s2,4
    80001b06:	fd3493e3          	bne	s1,s3,80001acc <sys_getpinfo+0x3a>
  if(copyout(myproc()->pagetable, (uint64)user_ps, (char *)&ps, sizeof(ps)) < 0)
    80001b0a:	dd7ff0ef          	jal	800018e0 <myproc>
    80001b0e:	50000693          	li	a3,1280
    80001b12:	ad040613          	addi	a2,s0,-1328
    80001b16:	ac843583          	ld	a1,-1336(s0)
    80001b1a:	6928                	ld	a0,80(a0)
    80001b1c:	a37ff0ef          	jal	80001552 <copyout>
}
    80001b20:	957d                	srai	a0,a0,0x3f
    80001b22:	53813083          	ld	ra,1336(sp)
    80001b26:	53013403          	ld	s0,1328(sp)
    80001b2a:	52813483          	ld	s1,1320(sp)
    80001b2e:	52013903          	ld	s2,1312(sp)
    80001b32:	51813983          	ld	s3,1304(sp)
    80001b36:	54010113          	addi	sp,sp,1344
    80001b3a:	8082                	ret

0000000080001b3c <proc_pagetable>:
{
    80001b3c:	1101                	addi	sp,sp,-32
    80001b3e:	ec06                	sd	ra,24(sp)
    80001b40:	e822                	sd	s0,16(sp)
    80001b42:	e426                	sd	s1,8(sp)
    80001b44:	e04a                	sd	s2,0(sp)
    80001b46:	1000                	addi	s0,sp,32
    80001b48:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b4a:	f2cff0ef          	jal	80001276 <uvmcreate>
    80001b4e:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b50:	cd05                	beqz	a0,80001b88 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b52:	4729                	li	a4,10
    80001b54:	00004697          	auipc	a3,0x4
    80001b58:	4ac68693          	addi	a3,a3,1196 # 80006000 <_trampoline>
    80001b5c:	6605                	lui	a2,0x1
    80001b5e:	040005b7          	lui	a1,0x4000
    80001b62:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b64:	05b2                	slli	a1,a1,0xc
    80001b66:	caeff0ef          	jal	80001014 <mappages>
    80001b6a:	02054663          	bltz	a0,80001b96 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b6e:	4719                	li	a4,6
    80001b70:	05893683          	ld	a3,88(s2)
    80001b74:	6605                	lui	a2,0x1
    80001b76:	020005b7          	lui	a1,0x2000
    80001b7a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b7c:	05b6                	slli	a1,a1,0xd
    80001b7e:	8526                	mv	a0,s1
    80001b80:	c94ff0ef          	jal	80001014 <mappages>
    80001b84:	00054f63          	bltz	a0,80001ba2 <proc_pagetable+0x66>
}
    80001b88:	8526                	mv	a0,s1
    80001b8a:	60e2                	ld	ra,24(sp)
    80001b8c:	6442                	ld	s0,16(sp)
    80001b8e:	64a2                	ld	s1,8(sp)
    80001b90:	6902                	ld	s2,0(sp)
    80001b92:	6105                	addi	sp,sp,32
    80001b94:	8082                	ret
    uvmfree(pagetable, 0);
    80001b96:	4581                	li	a1,0
    80001b98:	8526                	mv	a0,s1
    80001b9a:	8abff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001b9e:	4481                	li	s1,0
    80001ba0:	b7e5                	j	80001b88 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba2:	4681                	li	a3,0
    80001ba4:	4605                	li	a2,1
    80001ba6:	040005b7          	lui	a1,0x4000
    80001baa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bac:	05b2                	slli	a1,a1,0xc
    80001bae:	8526                	mv	a0,s1
    80001bb0:	e0aff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001bb4:	4581                	li	a1,0
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	88dff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001bbc:	4481                	li	s1,0
    80001bbe:	b7e9                	j	80001b88 <proc_pagetable+0x4c>

0000000080001bc0 <proc_freepagetable>:
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	e04a                	sd	s2,0(sp)
    80001bca:	1000                	addi	s0,sp,32
    80001bcc:	84aa                	mv	s1,a0
    80001bce:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bd0:	4681                	li	a3,0
    80001bd2:	4605                	li	a2,1
    80001bd4:	040005b7          	lui	a1,0x4000
    80001bd8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bda:	05b2                	slli	a1,a1,0xc
    80001bdc:	ddeff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001be0:	4681                	li	a3,0
    80001be2:	4605                	li	a2,1
    80001be4:	020005b7          	lui	a1,0x2000
    80001be8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bea:	05b6                	slli	a1,a1,0xd
    80001bec:	8526                	mv	a0,s1
    80001bee:	dccff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf2:	85ca                	mv	a1,s2
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	84fff0ef          	jal	80001444 <uvmfree>
}
    80001bfa:	60e2                	ld	ra,24(sp)
    80001bfc:	6442                	ld	s0,16(sp)
    80001bfe:	64a2                	ld	s1,8(sp)
    80001c00:	6902                	ld	s2,0(sp)
    80001c02:	6105                	addi	sp,sp,32
    80001c04:	8082                	ret

0000000080001c06 <freeproc>:
{
    80001c06:	1101                	addi	sp,sp,-32
    80001c08:	ec06                	sd	ra,24(sp)
    80001c0a:	e822                	sd	s0,16(sp)
    80001c0c:	e426                	sd	s1,8(sp)
    80001c0e:	1000                	addi	s0,sp,32
    80001c10:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c12:	6d28                	ld	a0,88(a0)
    80001c14:	c119                	beqz	a0,80001c1a <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001c16:	e2dfe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001c1a:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c1e:	68a8                	ld	a0,80(s1)
    80001c20:	c501                	beqz	a0,80001c28 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001c22:	64ac                	ld	a1,72(s1)
    80001c24:	f9dff0ef          	jal	80001bc0 <proc_freepagetable>
  p->pagetable = 0;
    80001c28:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c30:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c34:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c38:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c40:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c44:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c48:	0004ac23          	sw	zero,24(s1)
}
    80001c4c:	60e2                	ld	ra,24(sp)
    80001c4e:	6442                	ld	s0,16(sp)
    80001c50:	64a2                	ld	s1,8(sp)
    80001c52:	6105                	addi	sp,sp,32
    80001c54:	8082                	ret

0000000080001c56 <allocproc>:
{
    80001c56:	1101                	addi	sp,sp,-32
    80001c58:	ec06                	sd	ra,24(sp)
    80001c5a:	e822                	sd	s0,16(sp)
    80001c5c:	e426                	sd	s1,8(sp)
    80001c5e:	e04a                	sd	s2,0(sp)
    80001c60:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c62:	00011497          	auipc	s1,0x11
    80001c66:	c1e48493          	addi	s1,s1,-994 # 80012880 <proc>
    80001c6a:	00017917          	auipc	s2,0x17
    80001c6e:	a1690913          	addi	s2,s2,-1514 # 80018680 <tickslock>
    acquire(&p->lock);
    80001c72:	8526                	mv	a0,s1
    80001c74:	f81fe0ef          	jal	80000bf4 <acquire>
    if (p->state == UNUSED)
    80001c78:	4c9c                	lw	a5,24(s1)
    80001c7a:	cb91                	beqz	a5,80001c8e <allocproc+0x38>
      release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	80eff0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c82:	17848493          	addi	s1,s1,376
    80001c86:	ff2496e3          	bne	s1,s2,80001c72 <allocproc+0x1c>
  return 0;
    80001c8a:	4481                	li	s1,0
    80001c8c:	a0b9                	j	80001cda <allocproc+0x84>
  p->pid = allocpid();
    80001c8e:	cbdff0ef          	jal	8000194a <allocpid>
    80001c92:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c94:	4785                	li	a5,1
    80001c96:	cc9c                	sw	a5,24(s1)
  p->tickets_original = 1; // default 1 ticket
    80001c98:	16f4a423          	sw	a5,360(s1)
  p->tickets_current = 1;
    80001c9c:	16f4a623          	sw	a5,364(s1)
  p->time_slices = 0;
    80001ca0:	1604a823          	sw	zero,368(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001ca4:	e81fe0ef          	jal	80000b24 <kalloc>
    80001ca8:	892a                	mv	s2,a0
    80001caa:	eca8                	sd	a0,88(s1)
    80001cac:	cd15                	beqz	a0,80001ce8 <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80001cae:	8526                	mv	a0,s1
    80001cb0:	e8dff0ef          	jal	80001b3c <proc_pagetable>
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001cb8:	c121                	beqz	a0,80001cf8 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80001cba:	07000613          	li	a2,112
    80001cbe:	4581                	li	a1,0
    80001cc0:	06048513          	addi	a0,s1,96
    80001cc4:	804ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001cc8:	00000797          	auipc	a5,0x0
    80001ccc:	c4878793          	addi	a5,a5,-952 # 80001910 <forkret>
    80001cd0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cd2:	60bc                	ld	a5,64(s1)
    80001cd4:	6705                	lui	a4,0x1
    80001cd6:	97ba                	add	a5,a5,a4
    80001cd8:	f4bc                	sd	a5,104(s1)
}
    80001cda:	8526                	mv	a0,s1
    80001cdc:	60e2                	ld	ra,24(sp)
    80001cde:	6442                	ld	s0,16(sp)
    80001ce0:	64a2                	ld	s1,8(sp)
    80001ce2:	6902                	ld	s2,0(sp)
    80001ce4:	6105                	addi	sp,sp,32
    80001ce6:	8082                	ret
    freeproc(p);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	f1dff0ef          	jal	80001c06 <freeproc>
    release(&p->lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	f9dfe0ef          	jal	80000c8c <release>
    return 0;
    80001cf4:	84ca                	mv	s1,s2
    80001cf6:	b7d5                	j	80001cda <allocproc+0x84>
    freeproc(p);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	f0dff0ef          	jal	80001c06 <freeproc>
    release(&p->lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	f8dfe0ef          	jal	80000c8c <release>
    return 0;
    80001d04:	84ca                	mv	s1,s2
    80001d06:	bfd1                	j	80001cda <allocproc+0x84>

0000000080001d08 <userinit>:
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d12:	f45ff0ef          	jal	80001c56 <allocproc>
    80001d16:	84aa                	mv	s1,a0
  initproc = p;
    80001d18:	00008797          	auipc	a5,0x8
    80001d1c:	60a7b023          	sd	a0,1536(a5) # 8000a318 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d20:	03400613          	li	a2,52
    80001d24:	00008597          	auipc	a1,0x8
    80001d28:	56c58593          	addi	a1,a1,1388 # 8000a290 <initcode>
    80001d2c:	6928                	ld	a0,80(a0)
    80001d2e:	d6eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001d32:	6785                	lui	a5,0x1
    80001d34:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d36:	6cb8                	ld	a4,88(s1)
    80001d38:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d3c:	6cb8                	ld	a4,88(s1)
    80001d3e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d40:	4641                	li	a2,16
    80001d42:	00005597          	auipc	a1,0x5
    80001d46:	4de58593          	addi	a1,a1,1246 # 80007220 <etext+0x220>
    80001d4a:	15848513          	addi	a0,s1,344
    80001d4e:	8b8ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001d52:	00005517          	auipc	a0,0x5
    80001d56:	4de50513          	addi	a0,a0,1246 # 80007230 <etext+0x230>
    80001d5a:	58f010ef          	jal	80003ae8 <namei>
    80001d5e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d62:	478d                	li	a5,3
    80001d64:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
}
    80001d6c:	60e2                	ld	ra,24(sp)
    80001d6e:	6442                	ld	s0,16(sp)
    80001d70:	64a2                	ld	s1,8(sp)
    80001d72:	6105                	addi	sp,sp,32
    80001d74:	8082                	ret

0000000080001d76 <growproc>:
{
    80001d76:	1101                	addi	sp,sp,-32
    80001d78:	ec06                	sd	ra,24(sp)
    80001d7a:	e822                	sd	s0,16(sp)
    80001d7c:	e426                	sd	s1,8(sp)
    80001d7e:	e04a                	sd	s2,0(sp)
    80001d80:	1000                	addi	s0,sp,32
    80001d82:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d84:	b5dff0ef          	jal	800018e0 <myproc>
    80001d88:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d8a:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d8c:	01204c63          	bgtz	s2,80001da4 <growproc+0x2e>
  else if (n < 0)
    80001d90:	02094463          	bltz	s2,80001db8 <growproc+0x42>
  p->sz = sz;
    80001d94:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d96:	4501                	li	a0,0
}
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6902                	ld	s2,0(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001da4:	4691                	li	a3,4
    80001da6:	00b90633          	add	a2,s2,a1
    80001daa:	6928                	ld	a0,80(a0)
    80001dac:	d92ff0ef          	jal	8000133e <uvmalloc>
    80001db0:	85aa                	mv	a1,a0
    80001db2:	f16d                	bnez	a0,80001d94 <growproc+0x1e>
      return -1;
    80001db4:	557d                	li	a0,-1
    80001db6:	b7cd                	j	80001d98 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001db8:	00b90633          	add	a2,s2,a1
    80001dbc:	6928                	ld	a0,80(a0)
    80001dbe:	d3cff0ef          	jal	800012fa <uvmdealloc>
    80001dc2:	85aa                	mv	a1,a0
    80001dc4:	bfc1                	j	80001d94 <growproc+0x1e>

0000000080001dc6 <fork>:
{
    80001dc6:	7139                	addi	sp,sp,-64
    80001dc8:	fc06                	sd	ra,56(sp)
    80001dca:	f822                	sd	s0,48(sp)
    80001dcc:	f04a                	sd	s2,32(sp)
    80001dce:	e456                	sd	s5,8(sp)
    80001dd0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dd2:	b0fff0ef          	jal	800018e0 <myproc>
    80001dd6:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001dd8:	e7fff0ef          	jal	80001c56 <allocproc>
    80001ddc:	10050463          	beqz	a0,80001ee4 <fork+0x11e>
    80001de0:	ec4e                	sd	s3,24(sp)
    80001de2:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001de4:	048ab603          	ld	a2,72(s5)
    80001de8:	692c                	ld	a1,80(a0)
    80001dea:	050ab503          	ld	a0,80(s5)
    80001dee:	e88ff0ef          	jal	80001476 <uvmcopy>
    80001df2:	04054a63          	bltz	a0,80001e46 <fork+0x80>
    80001df6:	f426                	sd	s1,40(sp)
    80001df8:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001dfa:	048ab783          	ld	a5,72(s5)
    80001dfe:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e02:	058ab683          	ld	a3,88(s5)
    80001e06:	87b6                	mv	a5,a3
    80001e08:	0589b703          	ld	a4,88(s3)
    80001e0c:	12068693          	addi	a3,a3,288
    80001e10:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e14:	6788                	ld	a0,8(a5)
    80001e16:	6b8c                	ld	a1,16(a5)
    80001e18:	6f90                	ld	a2,24(a5)
    80001e1a:	01073023          	sd	a6,0(a4)
    80001e1e:	e708                	sd	a0,8(a4)
    80001e20:	eb0c                	sd	a1,16(a4)
    80001e22:	ef10                	sd	a2,24(a4)
    80001e24:	02078793          	addi	a5,a5,32
    80001e28:	02070713          	addi	a4,a4,32
    80001e2c:	fed792e3          	bne	a5,a3,80001e10 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001e30:	0589b783          	ld	a5,88(s3)
    80001e34:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e38:	0d0a8493          	addi	s1,s5,208
    80001e3c:	0d098913          	addi	s2,s3,208
    80001e40:	150a8a13          	addi	s4,s5,336
    80001e44:	a831                	j	80001e60 <fork+0x9a>
    freeproc(np);
    80001e46:	854e                	mv	a0,s3
    80001e48:	dbfff0ef          	jal	80001c06 <freeproc>
    release(&np->lock);
    80001e4c:	854e                	mv	a0,s3
    80001e4e:	e3ffe0ef          	jal	80000c8c <release>
    return -1;
    80001e52:	597d                	li	s2,-1
    80001e54:	69e2                	ld	s3,24(sp)
    80001e56:	a041                	j	80001ed6 <fork+0x110>
  for (i = 0; i < NOFILE; i++)
    80001e58:	04a1                	addi	s1,s1,8
    80001e5a:	0921                	addi	s2,s2,8
    80001e5c:	01448963          	beq	s1,s4,80001e6e <fork+0xa8>
    if (p->ofile[i])
    80001e60:	6088                	ld	a0,0(s1)
    80001e62:	d97d                	beqz	a0,80001e58 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e64:	214020ef          	jal	80004078 <filedup>
    80001e68:	00a93023          	sd	a0,0(s2)
    80001e6c:	b7f5                	j	80001e58 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001e6e:	150ab503          	ld	a0,336(s5)
    80001e72:	566010ef          	jal	800033d8 <idup>
    80001e76:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e7a:	4641                	li	a2,16
    80001e7c:	158a8593          	addi	a1,s5,344
    80001e80:	15898513          	addi	a0,s3,344
    80001e84:	f83fe0ef          	jal	80000e06 <safestrcpy>
  np->tickets_original = p->tickets_original;
    80001e88:	168aa783          	lw	a5,360(s5)
    80001e8c:	16f9a423          	sw	a5,360(s3)
  np->tickets_current = p->tickets_current;
    80001e90:	16caa783          	lw	a5,364(s5)
    80001e94:	16f9a623          	sw	a5,364(s3)
  np->time_slices = 0;
    80001e98:	1609a823          	sw	zero,368(s3)
  pid = np->pid;
    80001e9c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ea0:	854e                	mv	a0,s3
    80001ea2:	debfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001ea6:	00010497          	auipc	s1,0x10
    80001eaa:	5c248493          	addi	s1,s1,1474 # 80012468 <wait_lock>
    80001eae:	8526                	mv	a0,s1
    80001eb0:	d45fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001eb4:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	dd3fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001ebe:	854e                	mv	a0,s3
    80001ec0:	d35fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001ec4:	478d                	li	a5,3
    80001ec6:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001eca:	854e                	mv	a0,s3
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>
  return pid;
    80001ed0:	74a2                	ld	s1,40(sp)
    80001ed2:	69e2                	ld	s3,24(sp)
    80001ed4:	6a42                	ld	s4,16(sp)
}
    80001ed6:	854a                	mv	a0,s2
    80001ed8:	70e2                	ld	ra,56(sp)
    80001eda:	7442                	ld	s0,48(sp)
    80001edc:	7902                	ld	s2,32(sp)
    80001ede:	6aa2                	ld	s5,8(sp)
    80001ee0:	6121                	addi	sp,sp,64
    80001ee2:	8082                	ret
    return -1;
    80001ee4:	597d                	li	s2,-1
    80001ee6:	bfc5                	j	80001ed6 <fork+0x110>

0000000080001ee8 <scheduler>:
{
    80001ee8:	7159                	addi	sp,sp,-112
    80001eea:	f486                	sd	ra,104(sp)
    80001eec:	f0a2                	sd	s0,96(sp)
    80001eee:	eca6                	sd	s1,88(sp)
    80001ef0:	e8ca                	sd	s2,80(sp)
    80001ef2:	e4ce                	sd	s3,72(sp)
    80001ef4:	e0d2                	sd	s4,64(sp)
    80001ef6:	fc56                	sd	s5,56(sp)
    80001ef8:	f85a                	sd	s6,48(sp)
    80001efa:	f45e                	sd	s7,40(sp)
    80001efc:	f062                	sd	s8,32(sp)
    80001efe:	ec66                	sd	s9,24(sp)
    80001f00:	e86a                	sd	s10,16(sp)
    80001f02:	e46e                	sd	s11,8(sp)
    80001f04:	1880                	addi	s0,sp,112
    80001f06:	8792                	mv	a5,tp
  int id = r_tp();
    80001f08:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f0a:	00779c93          	slli	s9,a5,0x7
    80001f0e:	00010717          	auipc	a4,0x10
    80001f12:	54270713          	addi	a4,a4,1346 # 80012450 <pid_lock>
    80001f16:	9766                	add	a4,a4,s9
    80001f18:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80001f1c:	00010717          	auipc	a4,0x10
    80001f20:	56c70713          	addi	a4,a4,1388 # 80012488 <cpus+0x8>
    80001f24:	9cba                	add	s9,s9,a4
{
    80001f26:	4a01                	li	s4,0
    for (p = proc; p < &proc[NPROC]; p++)
    80001f28:	00016997          	auipc	s3,0x16
    80001f2c:	75898993          	addi	s3,s3,1880 # 80018680 <tickslock>
  next = next * 1103515245 + 12345;
    80001f30:	00008b97          	auipc	s7,0x8
    80001f34:	354b8b93          	addi	s7,s7,852 # 8000a284 <next.2>
            c->proc = p;
    80001f38:	079e                	slli	a5,a5,0x7
    80001f3a:	00010c17          	auipc	s8,0x10
    80001f3e:	516c0c13          	addi	s8,s8,1302 # 80012450 <pid_lock>
    80001f42:	9c3e                	add	s8,s8,a5
    80001f44:	a0c1                	j	80002004 <scheduler+0x11c>
      reset_tickets();
    80001f46:	a5dff0ef          	jal	800019a2 <reset_tickets>
    80001f4a:	a835                	j	80001f86 <scheduler+0x9e>
      release(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	d3ffe0ef          	jal	80000c8c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f52:	17848493          	addi	s1,s1,376
    80001f56:	01348d63          	beq	s1,s3,80001f70 <scheduler+0x88>
      acquire(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	c99fe0ef          	jal	80000bf4 <acquire>
      if (p->state == RUNNABLE)
    80001f60:	4c9c                	lw	a5,24(s1)
    80001f62:	ff2795e3          	bne	a5,s2,80001f4c <scheduler+0x64>
        total_tickets += p->tickets_current;
    80001f66:	16c4a783          	lw	a5,364(s1)
    80001f6a:	01a78d3b          	addw	s10,a5,s10
    80001f6e:	bff9                	j	80001f4c <scheduler+0x64>
    if (total_tickets > 0)
    80001f70:	03a04163          	bgtz	s10,80001f92 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f7c:	10079073          	csrw	sstatus,a5
    if (all_tickets_used())
    80001f80:	a6fff0ef          	jal	800019ee <all_tickets_used>
    80001f84:	f169                	bnez	a0,80001f46 <scheduler+0x5e>
{
    80001f86:	8d52                	mv	s10,s4
    80001f88:	00011497          	auipc	s1,0x11
    80001f8c:	8f848493          	addi	s1,s1,-1800 # 80012880 <proc>
    80001f90:	b7e9                	j	80001f5a <scheduler+0x72>
  next = next * 1103515245 + 12345;
    80001f92:	000bad83          	lw	s11,0(s7)
    80001f96:	03bb0dbb          	mulw	s11,s6,s11
    80001f9a:	015d8dbb          	addw	s11,s11,s5
    80001f9e:	01bba023          	sw	s11,0(s7)
      int winner = random() % total_tickets;
    80001fa2:	03adfdbb          	remuw	s11,s11,s10
      int current_sum = 0;
    80001fa6:	8d52                	mv	s10,s4
      for (p = proc; p < &proc[NPROC]; p++)
    80001fa8:	00011497          	auipc	s1,0x11
    80001fac:	8d848493          	addi	s1,s1,-1832 # 80012880 <proc>
    80001fb0:	a801                	j	80001fc0 <scheduler+0xd8>
        release(&p->lock);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	cd9fe0ef          	jal	80000c8c <release>
      for (p = proc; p < &proc[NPROC]; p++)
    80001fb8:	17848493          	addi	s1,s1,376
    80001fbc:	fb348ce3          	beq	s1,s3,80001f74 <scheduler+0x8c>
        acquire(&p->lock);
    80001fc0:	8526                	mv	a0,s1
    80001fc2:	c33fe0ef          	jal	80000bf4 <acquire>
        if (p->state == RUNNABLE)
    80001fc6:	4c9c                	lw	a5,24(s1)
    80001fc8:	ff2795e3          	bne	a5,s2,80001fb2 <scheduler+0xca>
          current_sum += p->tickets_current;
    80001fcc:	16c4a783          	lw	a5,364(s1)
    80001fd0:	01a78d3b          	addw	s10,a5,s10
          if (winner < current_sum)
    80001fd4:	fdaddfe3          	bge	s11,s10,80001fb2 <scheduler+0xca>
            p->state = RUNNING;
    80001fd8:	4711                	li	a4,4
    80001fda:	cc98                	sw	a4,24(s1)
            c->proc = p;
    80001fdc:	029c3823          	sd	s1,48(s8)
            p->time_slices++;
    80001fe0:	1704a703          	lw	a4,368(s1)
    80001fe4:	2705                	addiw	a4,a4,1
    80001fe6:	16e4a823          	sw	a4,368(s1)
            p->tickets_current--;
    80001fea:	37fd                	addiw	a5,a5,-1
    80001fec:	16f4a623          	sw	a5,364(s1)
            swtch(&c->context, &p->context);
    80001ff0:	06048593          	addi	a1,s1,96
    80001ff4:	8566                	mv	a0,s9
    80001ff6:	59a000ef          	jal	80002590 <swtch>
            c->proc = 0;
    80001ffa:	020c3823          	sd	zero,48(s8)
            release(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	c8dfe0ef          	jal	80000c8c <release>
      if (p->state == RUNNABLE)
    80002004:	490d                	li	s2,3
  next = next * 1103515245 + 12345;
    80002006:	41c65b37          	lui	s6,0x41c65
    8000200a:	e6db0b1b          	addiw	s6,s6,-403 # 41c64e6d <_entry-0x3e39b193>
    8000200e:	6a8d                	lui	s5,0x3
    80002010:	039a8a9b          	addiw	s5,s5,57 # 3039 <_entry-0x7fffcfc7>
    80002014:	b785                	j	80001f74 <scheduler+0x8c>

0000000080002016 <sched>:
{
    80002016:	7179                	addi	sp,sp,-48
    80002018:	f406                	sd	ra,40(sp)
    8000201a:	f022                	sd	s0,32(sp)
    8000201c:	ec26                	sd	s1,24(sp)
    8000201e:	e84a                	sd	s2,16(sp)
    80002020:	e44e                	sd	s3,8(sp)
    80002022:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002024:	8bdff0ef          	jal	800018e0 <myproc>
    80002028:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000202a:	b61fe0ef          	jal	80000b8a <holding>
    8000202e:	c92d                	beqz	a0,800020a0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002030:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002032:	2781                	sext.w	a5,a5
    80002034:	079e                	slli	a5,a5,0x7
    80002036:	00010717          	auipc	a4,0x10
    8000203a:	41a70713          	addi	a4,a4,1050 # 80012450 <pid_lock>
    8000203e:	97ba                	add	a5,a5,a4
    80002040:	0a87a703          	lw	a4,168(a5)
    80002044:	4785                	li	a5,1
    80002046:	06f71363          	bne	a4,a5,800020ac <sched+0x96>
  if (p->state == RUNNING)
    8000204a:	4c98                	lw	a4,24(s1)
    8000204c:	4791                	li	a5,4
    8000204e:	06f70563          	beq	a4,a5,800020b8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002052:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002056:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002058:	e7b5                	bnez	a5,800020c4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000205a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000205c:	00010917          	auipc	s2,0x10
    80002060:	3f490913          	addi	s2,s2,1012 # 80012450 <pid_lock>
    80002064:	2781                	sext.w	a5,a5
    80002066:	079e                	slli	a5,a5,0x7
    80002068:	97ca                	add	a5,a5,s2
    8000206a:	0ac7a983          	lw	s3,172(a5)
    8000206e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002070:	2781                	sext.w	a5,a5
    80002072:	079e                	slli	a5,a5,0x7
    80002074:	00010597          	auipc	a1,0x10
    80002078:	41458593          	addi	a1,a1,1044 # 80012488 <cpus+0x8>
    8000207c:	95be                	add	a1,a1,a5
    8000207e:	06048513          	addi	a0,s1,96
    80002082:	50e000ef          	jal	80002590 <swtch>
    80002086:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002088:	2781                	sext.w	a5,a5
    8000208a:	079e                	slli	a5,a5,0x7
    8000208c:	993e                	add	s2,s2,a5
    8000208e:	0b392623          	sw	s3,172(s2)
}
    80002092:	70a2                	ld	ra,40(sp)
    80002094:	7402                	ld	s0,32(sp)
    80002096:	64e2                	ld	s1,24(sp)
    80002098:	6942                	ld	s2,16(sp)
    8000209a:	69a2                	ld	s3,8(sp)
    8000209c:	6145                	addi	sp,sp,48
    8000209e:	8082                	ret
    panic("sched p->lock");
    800020a0:	00005517          	auipc	a0,0x5
    800020a4:	19850513          	addi	a0,a0,408 # 80007238 <etext+0x238>
    800020a8:	eecfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    800020ac:	00005517          	auipc	a0,0x5
    800020b0:	19c50513          	addi	a0,a0,412 # 80007248 <etext+0x248>
    800020b4:	ee0fe0ef          	jal	80000794 <panic>
    panic("sched running");
    800020b8:	00005517          	auipc	a0,0x5
    800020bc:	1a050513          	addi	a0,a0,416 # 80007258 <etext+0x258>
    800020c0:	ed4fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    800020c4:	00005517          	auipc	a0,0x5
    800020c8:	1a450513          	addi	a0,a0,420 # 80007268 <etext+0x268>
    800020cc:	ec8fe0ef          	jal	80000794 <panic>

00000000800020d0 <yield>:
{
    800020d0:	1101                	addi	sp,sp,-32
    800020d2:	ec06                	sd	ra,24(sp)
    800020d4:	e822                	sd	s0,16(sp)
    800020d6:	e426                	sd	s1,8(sp)
    800020d8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020da:	807ff0ef          	jal	800018e0 <myproc>
    800020de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e0:	b15fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    800020e4:	478d                	li	a5,3
    800020e6:	cc9c                	sw	a5,24(s1)
  sched();
    800020e8:	f2fff0ef          	jal	80002016 <sched>
  release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	b9ffe0ef          	jal	80000c8c <release>
}
    800020f2:	60e2                	ld	ra,24(sp)
    800020f4:	6442                	ld	s0,16(sp)
    800020f6:	64a2                	ld	s1,8(sp)
    800020f8:	6105                	addi	sp,sp,32
    800020fa:	8082                	ret

00000000800020fc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020fc:	7179                	addi	sp,sp,-48
    800020fe:	f406                	sd	ra,40(sp)
    80002100:	f022                	sd	s0,32(sp)
    80002102:	ec26                	sd	s1,24(sp)
    80002104:	e84a                	sd	s2,16(sp)
    80002106:	e44e                	sd	s3,8(sp)
    80002108:	1800                	addi	s0,sp,48
    8000210a:	89aa                	mv	s3,a0
    8000210c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000210e:	fd2ff0ef          	jal	800018e0 <myproc>
    80002112:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002114:	ae1fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80002118:	854a                	mv	a0,s2
    8000211a:	b73fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    8000211e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002122:	4789                	li	a5,2
    80002124:	cc9c                	sw	a5,24(s1)

  sched();
    80002126:	ef1ff0ef          	jal	80002016 <sched>

  // Tidy up.
  p->chan = 0;
    8000212a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	b5dfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80002134:	854a                	mv	a0,s2
    80002136:	abffe0ef          	jal	80000bf4 <acquire>
}
    8000213a:	70a2                	ld	ra,40(sp)
    8000213c:	7402                	ld	s0,32(sp)
    8000213e:	64e2                	ld	s1,24(sp)
    80002140:	6942                	ld	s2,16(sp)
    80002142:	69a2                	ld	s3,8(sp)
    80002144:	6145                	addi	sp,sp,48
    80002146:	8082                	ret

0000000080002148 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002148:	7139                	addi	sp,sp,-64
    8000214a:	fc06                	sd	ra,56(sp)
    8000214c:	f822                	sd	s0,48(sp)
    8000214e:	f426                	sd	s1,40(sp)
    80002150:	f04a                	sd	s2,32(sp)
    80002152:	ec4e                	sd	s3,24(sp)
    80002154:	e852                	sd	s4,16(sp)
    80002156:	e456                	sd	s5,8(sp)
    80002158:	0080                	addi	s0,sp,64
    8000215a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000215c:	00010497          	auipc	s1,0x10
    80002160:	72448493          	addi	s1,s1,1828 # 80012880 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002164:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002166:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002168:	00016917          	auipc	s2,0x16
    8000216c:	51890913          	addi	s2,s2,1304 # 80018680 <tickslock>
    80002170:	a801                	j	80002180 <wakeup+0x38>
      }
      release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	b19fe0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002178:	17848493          	addi	s1,s1,376
    8000217c:	03248263          	beq	s1,s2,800021a0 <wakeup+0x58>
    if (p != myproc())
    80002180:	f60ff0ef          	jal	800018e0 <myproc>
    80002184:	fea48ae3          	beq	s1,a0,80002178 <wakeup+0x30>
      acquire(&p->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	a6bfe0ef          	jal	80000bf4 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    8000218e:	4c9c                	lw	a5,24(s1)
    80002190:	ff3791e3          	bne	a5,s3,80002172 <wakeup+0x2a>
    80002194:	709c                	ld	a5,32(s1)
    80002196:	fd479ee3          	bne	a5,s4,80002172 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000219a:	0154ac23          	sw	s5,24(s1)
    8000219e:	bfd1                	j	80002172 <wakeup+0x2a>
    }
  }
}
    800021a0:	70e2                	ld	ra,56(sp)
    800021a2:	7442                	ld	s0,48(sp)
    800021a4:	74a2                	ld	s1,40(sp)
    800021a6:	7902                	ld	s2,32(sp)
    800021a8:	69e2                	ld	s3,24(sp)
    800021aa:	6a42                	ld	s4,16(sp)
    800021ac:	6aa2                	ld	s5,8(sp)
    800021ae:	6121                	addi	sp,sp,64
    800021b0:	8082                	ret

00000000800021b2 <reparent>:
{
    800021b2:	7179                	addi	sp,sp,-48
    800021b4:	f406                	sd	ra,40(sp)
    800021b6:	f022                	sd	s0,32(sp)
    800021b8:	ec26                	sd	s1,24(sp)
    800021ba:	e84a                	sd	s2,16(sp)
    800021bc:	e44e                	sd	s3,8(sp)
    800021be:	e052                	sd	s4,0(sp)
    800021c0:	1800                	addi	s0,sp,48
    800021c2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021c4:	00010497          	auipc	s1,0x10
    800021c8:	6bc48493          	addi	s1,s1,1724 # 80012880 <proc>
      pp->parent = initproc;
    800021cc:	00008a17          	auipc	s4,0x8
    800021d0:	14ca0a13          	addi	s4,s4,332 # 8000a318 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021d4:	00016997          	auipc	s3,0x16
    800021d8:	4ac98993          	addi	s3,s3,1196 # 80018680 <tickslock>
    800021dc:	a029                	j	800021e6 <reparent+0x34>
    800021de:	17848493          	addi	s1,s1,376
    800021e2:	01348b63          	beq	s1,s3,800021f8 <reparent+0x46>
    if (pp->parent == p)
    800021e6:	7c9c                	ld	a5,56(s1)
    800021e8:	ff279be3          	bne	a5,s2,800021de <reparent+0x2c>
      pp->parent = initproc;
    800021ec:	000a3503          	ld	a0,0(s4)
    800021f0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021f2:	f57ff0ef          	jal	80002148 <wakeup>
    800021f6:	b7e5                	j	800021de <reparent+0x2c>
}
    800021f8:	70a2                	ld	ra,40(sp)
    800021fa:	7402                	ld	s0,32(sp)
    800021fc:	64e2                	ld	s1,24(sp)
    800021fe:	6942                	ld	s2,16(sp)
    80002200:	69a2                	ld	s3,8(sp)
    80002202:	6a02                	ld	s4,0(sp)
    80002204:	6145                	addi	sp,sp,48
    80002206:	8082                	ret

0000000080002208 <exit>:
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	e052                	sd	s4,0(sp)
    80002216:	1800                	addi	s0,sp,48
    80002218:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000221a:	ec6ff0ef          	jal	800018e0 <myproc>
    8000221e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002220:	00008797          	auipc	a5,0x8
    80002224:	0f87b783          	ld	a5,248(a5) # 8000a318 <initproc>
    80002228:	0d050493          	addi	s1,a0,208
    8000222c:	15050913          	addi	s2,a0,336
    80002230:	00a79f63          	bne	a5,a0,8000224e <exit+0x46>
    panic("init exiting");
    80002234:	00005517          	auipc	a0,0x5
    80002238:	04c50513          	addi	a0,a0,76 # 80007280 <etext+0x280>
    8000223c:	d58fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002240:	67f010ef          	jal	800040be <fileclose>
      p->ofile[fd] = 0;
    80002244:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002248:	04a1                	addi	s1,s1,8
    8000224a:	01248563          	beq	s1,s2,80002254 <exit+0x4c>
    if (p->ofile[fd])
    8000224e:	6088                	ld	a0,0(s1)
    80002250:	f965                	bnez	a0,80002240 <exit+0x38>
    80002252:	bfdd                	j	80002248 <exit+0x40>
  begin_op();
    80002254:	251010ef          	jal	80003ca4 <begin_op>
  iput(p->cwd);
    80002258:	1509b503          	ld	a0,336(s3)
    8000225c:	334010ef          	jal	80003590 <iput>
  end_op();
    80002260:	2af010ef          	jal	80003d0e <end_op>
  p->cwd = 0;
    80002264:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002268:	00010497          	auipc	s1,0x10
    8000226c:	20048493          	addi	s1,s1,512 # 80012468 <wait_lock>
    80002270:	8526                	mv	a0,s1
    80002272:	983fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002276:	854e                	mv	a0,s3
    80002278:	f3bff0ef          	jal	800021b2 <reparent>
  wakeup(p->parent);
    8000227c:	0389b503          	ld	a0,56(s3)
    80002280:	ec9ff0ef          	jal	80002148 <wakeup>
  acquire(&p->lock);
    80002284:	854e                	mv	a0,s3
    80002286:	96ffe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000228a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000228e:	4795                	li	a5,5
    80002290:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002294:	8526                	mv	a0,s1
    80002296:	9f7fe0ef          	jal	80000c8c <release>
  sched();
    8000229a:	d7dff0ef          	jal	80002016 <sched>
  panic("zombie exit");
    8000229e:	00005517          	auipc	a0,0x5
    800022a2:	ff250513          	addi	a0,a0,-14 # 80007290 <etext+0x290>
    800022a6:	ceefe0ef          	jal	80000794 <panic>

00000000800022aa <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800022aa:	7179                	addi	sp,sp,-48
    800022ac:	f406                	sd	ra,40(sp)
    800022ae:	f022                	sd	s0,32(sp)
    800022b0:	ec26                	sd	s1,24(sp)
    800022b2:	e84a                	sd	s2,16(sp)
    800022b4:	e44e                	sd	s3,8(sp)
    800022b6:	1800                	addi	s0,sp,48
    800022b8:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022ba:	00010497          	auipc	s1,0x10
    800022be:	5c648493          	addi	s1,s1,1478 # 80012880 <proc>
    800022c2:	00016997          	auipc	s3,0x16
    800022c6:	3be98993          	addi	s3,s3,958 # 80018680 <tickslock>
  {
    acquire(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	929fe0ef          	jal	80000bf4 <acquire>
    if (p->pid == pid)
    800022d0:	589c                	lw	a5,48(s1)
    800022d2:	01278b63          	beq	a5,s2,800022e8 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	9b5fe0ef          	jal	80000c8c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022dc:	17848493          	addi	s1,s1,376
    800022e0:	ff3495e3          	bne	s1,s3,800022ca <kill+0x20>
  }
  return -1;
    800022e4:	557d                	li	a0,-1
    800022e6:	a819                	j	800022fc <kill+0x52>
      p->killed = 1;
    800022e8:	4785                	li	a5,1
    800022ea:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800022ec:	4c98                	lw	a4,24(s1)
    800022ee:	4789                	li	a5,2
    800022f0:	00f70d63          	beq	a4,a5,8000230a <kill+0x60>
      release(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	997fe0ef          	jal	80000c8c <release>
      return 0;
    800022fa:	4501                	li	a0,0
}
    800022fc:	70a2                	ld	ra,40(sp)
    800022fe:	7402                	ld	s0,32(sp)
    80002300:	64e2                	ld	s1,24(sp)
    80002302:	6942                	ld	s2,16(sp)
    80002304:	69a2                	ld	s3,8(sp)
    80002306:	6145                	addi	sp,sp,48
    80002308:	8082                	ret
        p->state = RUNNABLE;
    8000230a:	478d                	li	a5,3
    8000230c:	cc9c                	sw	a5,24(s1)
    8000230e:	b7dd                	j	800022f4 <kill+0x4a>

0000000080002310 <setkilled>:

void setkilled(struct proc *p)
{
    80002310:	1101                	addi	sp,sp,-32
    80002312:	ec06                	sd	ra,24(sp)
    80002314:	e822                	sd	s0,16(sp)
    80002316:	e426                	sd	s1,8(sp)
    80002318:	1000                	addi	s0,sp,32
    8000231a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000231c:	8d9fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002320:	4785                	li	a5,1
    80002322:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	967fe0ef          	jal	80000c8c <release>
}
    8000232a:	60e2                	ld	ra,24(sp)
    8000232c:	6442                	ld	s0,16(sp)
    8000232e:	64a2                	ld	s1,8(sp)
    80002330:	6105                	addi	sp,sp,32
    80002332:	8082                	ret

0000000080002334 <killed>:

int killed(struct proc *p)
{
    80002334:	1101                	addi	sp,sp,-32
    80002336:	ec06                	sd	ra,24(sp)
    80002338:	e822                	sd	s0,16(sp)
    8000233a:	e426                	sd	s1,8(sp)
    8000233c:	e04a                	sd	s2,0(sp)
    8000233e:	1000                	addi	s0,sp,32
    80002340:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002342:	8b3fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002346:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	941fe0ef          	jal	80000c8c <release>
  return k;
}
    80002350:	854a                	mv	a0,s2
    80002352:	60e2                	ld	ra,24(sp)
    80002354:	6442                	ld	s0,16(sp)
    80002356:	64a2                	ld	s1,8(sp)
    80002358:	6902                	ld	s2,0(sp)
    8000235a:	6105                	addi	sp,sp,32
    8000235c:	8082                	ret

000000008000235e <wait>:
{
    8000235e:	715d                	addi	sp,sp,-80
    80002360:	e486                	sd	ra,72(sp)
    80002362:	e0a2                	sd	s0,64(sp)
    80002364:	fc26                	sd	s1,56(sp)
    80002366:	f84a                	sd	s2,48(sp)
    80002368:	f44e                	sd	s3,40(sp)
    8000236a:	f052                	sd	s4,32(sp)
    8000236c:	ec56                	sd	s5,24(sp)
    8000236e:	e85a                	sd	s6,16(sp)
    80002370:	e45e                	sd	s7,8(sp)
    80002372:	e062                	sd	s8,0(sp)
    80002374:	0880                	addi	s0,sp,80
    80002376:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002378:	d68ff0ef          	jal	800018e0 <myproc>
    8000237c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000237e:	00010517          	auipc	a0,0x10
    80002382:	0ea50513          	addi	a0,a0,234 # 80012468 <wait_lock>
    80002386:	86ffe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000238a:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    8000238c:	4a15                	li	s4,5
        havekids = 1;
    8000238e:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002390:	00016997          	auipc	s3,0x16
    80002394:	2f098993          	addi	s3,s3,752 # 80018680 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002398:	00010c17          	auipc	s8,0x10
    8000239c:	0d0c0c13          	addi	s8,s8,208 # 80012468 <wait_lock>
    800023a0:	a871                	j	8000243c <wait+0xde>
          pid = pp->pid;
    800023a2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023a6:	000b0c63          	beqz	s6,800023be <wait+0x60>
    800023aa:	4691                	li	a3,4
    800023ac:	02c48613          	addi	a2,s1,44
    800023b0:	85da                	mv	a1,s6
    800023b2:	05093503          	ld	a0,80(s2)
    800023b6:	99cff0ef          	jal	80001552 <copyout>
    800023ba:	02054b63          	bltz	a0,800023f0 <wait+0x92>
          freeproc(pp);
    800023be:	8526                	mv	a0,s1
    800023c0:	847ff0ef          	jal	80001c06 <freeproc>
          release(&pp->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	8c7fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800023ca:	00010517          	auipc	a0,0x10
    800023ce:	09e50513          	addi	a0,a0,158 # 80012468 <wait_lock>
    800023d2:	8bbfe0ef          	jal	80000c8c <release>
}
    800023d6:	854e                	mv	a0,s3
    800023d8:	60a6                	ld	ra,72(sp)
    800023da:	6406                	ld	s0,64(sp)
    800023dc:	74e2                	ld	s1,56(sp)
    800023de:	7942                	ld	s2,48(sp)
    800023e0:	79a2                	ld	s3,40(sp)
    800023e2:	7a02                	ld	s4,32(sp)
    800023e4:	6ae2                	ld	s5,24(sp)
    800023e6:	6b42                	ld	s6,16(sp)
    800023e8:	6ba2                	ld	s7,8(sp)
    800023ea:	6c02                	ld	s8,0(sp)
    800023ec:	6161                	addi	sp,sp,80
    800023ee:	8082                	ret
            release(&pp->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	89bfe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800023f6:	00010517          	auipc	a0,0x10
    800023fa:	07250513          	addi	a0,a0,114 # 80012468 <wait_lock>
    800023fe:	88ffe0ef          	jal	80000c8c <release>
            return -1;
    80002402:	59fd                	li	s3,-1
    80002404:	bfc9                	j	800023d6 <wait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002406:	17848493          	addi	s1,s1,376
    8000240a:	03348063          	beq	s1,s3,8000242a <wait+0xcc>
      if (pp->parent == p)
    8000240e:	7c9c                	ld	a5,56(s1)
    80002410:	ff279be3          	bne	a5,s2,80002406 <wait+0xa8>
        acquire(&pp->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fdefe0ef          	jal	80000bf4 <acquire>
        if (pp->state == ZOMBIE)
    8000241a:	4c9c                	lw	a5,24(s1)
    8000241c:	f94783e3          	beq	a5,s4,800023a2 <wait+0x44>
        release(&pp->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	86bfe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002426:	8756                	mv	a4,s5
    80002428:	bff9                	j	80002406 <wait+0xa8>
    if (!havekids || killed(p))
    8000242a:	cf19                	beqz	a4,80002448 <wait+0xea>
    8000242c:	854a                	mv	a0,s2
    8000242e:	f07ff0ef          	jal	80002334 <killed>
    80002432:	e919                	bnez	a0,80002448 <wait+0xea>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002434:	85e2                	mv	a1,s8
    80002436:	854a                	mv	a0,s2
    80002438:	cc5ff0ef          	jal	800020fc <sleep>
    havekids = 0;
    8000243c:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000243e:	00010497          	auipc	s1,0x10
    80002442:	44248493          	addi	s1,s1,1090 # 80012880 <proc>
    80002446:	b7e1                	j	8000240e <wait+0xb0>
      release(&wait_lock);
    80002448:	00010517          	auipc	a0,0x10
    8000244c:	02050513          	addi	a0,a0,32 # 80012468 <wait_lock>
    80002450:	83dfe0ef          	jal	80000c8c <release>
      return -1;
    80002454:	59fd                	li	s3,-1
    80002456:	b741                	j	800023d6 <wait+0x78>

0000000080002458 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002458:	7179                	addi	sp,sp,-48
    8000245a:	f406                	sd	ra,40(sp)
    8000245c:	f022                	sd	s0,32(sp)
    8000245e:	ec26                	sd	s1,24(sp)
    80002460:	e84a                	sd	s2,16(sp)
    80002462:	e44e                	sd	s3,8(sp)
    80002464:	e052                	sd	s4,0(sp)
    80002466:	1800                	addi	s0,sp,48
    80002468:	84aa                	mv	s1,a0
    8000246a:	892e                	mv	s2,a1
    8000246c:	89b2                	mv	s3,a2
    8000246e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002470:	c70ff0ef          	jal	800018e0 <myproc>
  if (user_dst)
    80002474:	cc99                	beqz	s1,80002492 <either_copyout+0x3a>
  {
    return copyout(p->pagetable, dst, src, len);
    80002476:	86d2                	mv	a3,s4
    80002478:	864e                	mv	a2,s3
    8000247a:	85ca                	mv	a1,s2
    8000247c:	6928                	ld	a0,80(a0)
    8000247e:	8d4ff0ef          	jal	80001552 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002482:	70a2                	ld	ra,40(sp)
    80002484:	7402                	ld	s0,32(sp)
    80002486:	64e2                	ld	s1,24(sp)
    80002488:	6942                	ld	s2,16(sp)
    8000248a:	69a2                	ld	s3,8(sp)
    8000248c:	6a02                	ld	s4,0(sp)
    8000248e:	6145                	addi	sp,sp,48
    80002490:	8082                	ret
    memmove((char *)dst, src, len);
    80002492:	000a061b          	sext.w	a2,s4
    80002496:	85ce                	mv	a1,s3
    80002498:	854a                	mv	a0,s2
    8000249a:	88bfe0ef          	jal	80000d24 <memmove>
    return 0;
    8000249e:	8526                	mv	a0,s1
    800024a0:	b7cd                	j	80002482 <either_copyout+0x2a>

00000000800024a2 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024a2:	7179                	addi	sp,sp,-48
    800024a4:	f406                	sd	ra,40(sp)
    800024a6:	f022                	sd	s0,32(sp)
    800024a8:	ec26                	sd	s1,24(sp)
    800024aa:	e84a                	sd	s2,16(sp)
    800024ac:	e44e                	sd	s3,8(sp)
    800024ae:	e052                	sd	s4,0(sp)
    800024b0:	1800                	addi	s0,sp,48
    800024b2:	892a                	mv	s2,a0
    800024b4:	84ae                	mv	s1,a1
    800024b6:	89b2                	mv	s3,a2
    800024b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ba:	c26ff0ef          	jal	800018e0 <myproc>
  if (user_src)
    800024be:	cc99                	beqz	s1,800024dc <either_copyin+0x3a>
  {
    return copyin(p->pagetable, dst, src, len);
    800024c0:	86d2                	mv	a3,s4
    800024c2:	864e                	mv	a2,s3
    800024c4:	85ca                	mv	a1,s2
    800024c6:	6928                	ld	a0,80(a0)
    800024c8:	960ff0ef          	jal	80001628 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800024cc:	70a2                	ld	ra,40(sp)
    800024ce:	7402                	ld	s0,32(sp)
    800024d0:	64e2                	ld	s1,24(sp)
    800024d2:	6942                	ld	s2,16(sp)
    800024d4:	69a2                	ld	s3,8(sp)
    800024d6:	6a02                	ld	s4,0(sp)
    800024d8:	6145                	addi	sp,sp,48
    800024da:	8082                	ret
    memmove(dst, (char *)src, len);
    800024dc:	000a061b          	sext.w	a2,s4
    800024e0:	85ce                	mv	a1,s3
    800024e2:	854a                	mv	a0,s2
    800024e4:	841fe0ef          	jal	80000d24 <memmove>
    return 0;
    800024e8:	8526                	mv	a0,s1
    800024ea:	b7cd                	j	800024cc <either_copyin+0x2a>

00000000800024ec <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800024ec:	715d                	addi	sp,sp,-80
    800024ee:	e486                	sd	ra,72(sp)
    800024f0:	e0a2                	sd	s0,64(sp)
    800024f2:	fc26                	sd	s1,56(sp)
    800024f4:	f84a                	sd	s2,48(sp)
    800024f6:	f44e                	sd	s3,40(sp)
    800024f8:	f052                	sd	s4,32(sp)
    800024fa:	ec56                	sd	s5,24(sp)
    800024fc:	e85a                	sd	s6,16(sp)
    800024fe:	e45e                	sd	s7,8(sp)
    80002500:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002502:	00005517          	auipc	a0,0x5
    80002506:	b7650513          	addi	a0,a0,-1162 # 80007078 <etext+0x78>
    8000250a:	fb9fd0ef          	jal	800004c2 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000250e:	00010497          	auipc	s1,0x10
    80002512:	4ca48493          	addi	s1,s1,1226 # 800129d8 <proc+0x158>
    80002516:	00016917          	auipc	s2,0x16
    8000251a:	2c290913          	addi	s2,s2,706 # 800187d8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000251e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002520:	00005997          	auipc	s3,0x5
    80002524:	d8098993          	addi	s3,s3,-640 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002528:	00005a97          	auipc	s5,0x5
    8000252c:	d80a8a93          	addi	s5,s5,-640 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002530:	00005a17          	auipc	s4,0x5
    80002534:	b48a0a13          	addi	s4,s4,-1208 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002538:	00005b97          	auipc	s7,0x5
    8000253c:	250b8b93          	addi	s7,s7,592 # 80007788 <states.0>
    80002540:	a829                	j	8000255a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002542:	ed86a583          	lw	a1,-296(a3)
    80002546:	8556                	mv	a0,s5
    80002548:	f7bfd0ef          	jal	800004c2 <printf>
    printf("\n");
    8000254c:	8552                	mv	a0,s4
    8000254e:	f75fd0ef          	jal	800004c2 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002552:	17848493          	addi	s1,s1,376
    80002556:	03248263          	beq	s1,s2,8000257a <procdump+0x8e>
    if (p->state == UNUSED)
    8000255a:	86a6                	mv	a3,s1
    8000255c:	ec04a783          	lw	a5,-320(s1)
    80002560:	dbed                	beqz	a5,80002552 <procdump+0x66>
      state = "???";
    80002562:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002564:	fcfb6fe3          	bltu	s6,a5,80002542 <procdump+0x56>
    80002568:	02079713          	slli	a4,a5,0x20
    8000256c:	01d75793          	srli	a5,a4,0x1d
    80002570:	97de                	add	a5,a5,s7
    80002572:	6390                	ld	a2,0(a5)
    80002574:	f679                	bnez	a2,80002542 <procdump+0x56>
      state = "???";
    80002576:	864e                	mv	a2,s3
    80002578:	b7e9                	j	80002542 <procdump+0x56>
  }
}
    8000257a:	60a6                	ld	ra,72(sp)
    8000257c:	6406                	ld	s0,64(sp)
    8000257e:	74e2                	ld	s1,56(sp)
    80002580:	7942                	ld	s2,48(sp)
    80002582:	79a2                	ld	s3,40(sp)
    80002584:	7a02                	ld	s4,32(sp)
    80002586:	6ae2                	ld	s5,24(sp)
    80002588:	6b42                	ld	s6,16(sp)
    8000258a:	6ba2                	ld	s7,8(sp)
    8000258c:	6161                	addi	sp,sp,80
    8000258e:	8082                	ret

0000000080002590 <swtch>:
    80002590:	00153023          	sd	ra,0(a0)
    80002594:	00253423          	sd	sp,8(a0)
    80002598:	e900                	sd	s0,16(a0)
    8000259a:	ed04                	sd	s1,24(a0)
    8000259c:	03253023          	sd	s2,32(a0)
    800025a0:	03353423          	sd	s3,40(a0)
    800025a4:	03453823          	sd	s4,48(a0)
    800025a8:	03553c23          	sd	s5,56(a0)
    800025ac:	05653023          	sd	s6,64(a0)
    800025b0:	05753423          	sd	s7,72(a0)
    800025b4:	05853823          	sd	s8,80(a0)
    800025b8:	05953c23          	sd	s9,88(a0)
    800025bc:	07a53023          	sd	s10,96(a0)
    800025c0:	07b53423          	sd	s11,104(a0)
    800025c4:	0005b083          	ld	ra,0(a1)
    800025c8:	0085b103          	ld	sp,8(a1)
    800025cc:	6980                	ld	s0,16(a1)
    800025ce:	6d84                	ld	s1,24(a1)
    800025d0:	0205b903          	ld	s2,32(a1)
    800025d4:	0285b983          	ld	s3,40(a1)
    800025d8:	0305ba03          	ld	s4,48(a1)
    800025dc:	0385ba83          	ld	s5,56(a1)
    800025e0:	0405bb03          	ld	s6,64(a1)
    800025e4:	0485bb83          	ld	s7,72(a1)
    800025e8:	0505bc03          	ld	s8,80(a1)
    800025ec:	0585bc83          	ld	s9,88(a1)
    800025f0:	0605bd03          	ld	s10,96(a1)
    800025f4:	0685bd83          	ld	s11,104(a1)
    800025f8:	8082                	ret

00000000800025fa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025fa:	1141                	addi	sp,sp,-16
    800025fc:	e406                	sd	ra,8(sp)
    800025fe:	e022                	sd	s0,0(sp)
    80002600:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002602:	00005597          	auipc	a1,0x5
    80002606:	ce658593          	addi	a1,a1,-794 # 800072e8 <etext+0x2e8>
    8000260a:	00016517          	auipc	a0,0x16
    8000260e:	07650513          	addi	a0,a0,118 # 80018680 <tickslock>
    80002612:	d62fe0ef          	jal	80000b74 <initlock>
}
    80002616:	60a2                	ld	ra,8(sp)
    80002618:	6402                	ld	s0,0(sp)
    8000261a:	0141                	addi	sp,sp,16
    8000261c:	8082                	ret

000000008000261e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000261e:	1141                	addi	sp,sp,-16
    80002620:	e422                	sd	s0,8(sp)
    80002622:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002624:	00003797          	auipc	a5,0x3
    80002628:	e0c78793          	addi	a5,a5,-500 # 80005430 <kernelvec>
    8000262c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002630:	6422                	ld	s0,8(sp)
    80002632:	0141                	addi	sp,sp,16
    80002634:	8082                	ret

0000000080002636 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002636:	1141                	addi	sp,sp,-16
    80002638:	e406                	sd	ra,8(sp)
    8000263a:	e022                	sd	s0,0(sp)
    8000263c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000263e:	aa2ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002642:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002646:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002648:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000264c:	00004697          	auipc	a3,0x4
    80002650:	9b468693          	addi	a3,a3,-1612 # 80006000 <_trampoline>
    80002654:	00004717          	auipc	a4,0x4
    80002658:	9ac70713          	addi	a4,a4,-1620 # 80006000 <_trampoline>
    8000265c:	8f15                	sub	a4,a4,a3
    8000265e:	040007b7          	lui	a5,0x4000
    80002662:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002664:	07b2                	slli	a5,a5,0xc
    80002666:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002668:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000266c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000266e:	18002673          	csrr	a2,satp
    80002672:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002674:	6d30                	ld	a2,88(a0)
    80002676:	6138                	ld	a4,64(a0)
    80002678:	6585                	lui	a1,0x1
    8000267a:	972e                	add	a4,a4,a1
    8000267c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000267e:	6d38                	ld	a4,88(a0)
    80002680:	00000617          	auipc	a2,0x0
    80002684:	11060613          	addi	a2,a2,272 # 80002790 <usertrap>
    80002688:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000268a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000268c:	8612                	mv	a2,tp
    8000268e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002690:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002694:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002698:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026a2:	6f18                	ld	a4,24(a4)
    800026a4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026a8:	6928                	ld	a0,80(a0)
    800026aa:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026ac:	00004717          	auipc	a4,0x4
    800026b0:	9f070713          	addi	a4,a4,-1552 # 8000609c <userret>
    800026b4:	8f15                	sub	a4,a4,a3
    800026b6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026b8:	577d                	li	a4,-1
    800026ba:	177e                	slli	a4,a4,0x3f
    800026bc:	8d59                	or	a0,a0,a4
    800026be:	9782                	jalr	a5
}
    800026c0:	60a2                	ld	ra,8(sp)
    800026c2:	6402                	ld	s0,0(sp)
    800026c4:	0141                	addi	sp,sp,16
    800026c6:	8082                	ret

00000000800026c8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026c8:	1101                	addi	sp,sp,-32
    800026ca:	ec06                	sd	ra,24(sp)
    800026cc:	e822                	sd	s0,16(sp)
    800026ce:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800026d0:	9e4ff0ef          	jal	800018b4 <cpuid>
    800026d4:	cd11                	beqz	a0,800026f0 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026d6:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026da:	000f4737          	lui	a4,0xf4
    800026de:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026e2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026e4:	14d79073          	csrw	stimecmp,a5
}
    800026e8:	60e2                	ld	ra,24(sp)
    800026ea:	6442                	ld	s0,16(sp)
    800026ec:	6105                	addi	sp,sp,32
    800026ee:	8082                	ret
    800026f0:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800026f2:	00016497          	auipc	s1,0x16
    800026f6:	f8e48493          	addi	s1,s1,-114 # 80018680 <tickslock>
    800026fa:	8526                	mv	a0,s1
    800026fc:	cf8fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002700:	00008517          	auipc	a0,0x8
    80002704:	c2050513          	addi	a0,a0,-992 # 8000a320 <ticks>
    80002708:	411c                	lw	a5,0(a0)
    8000270a:	2785                	addiw	a5,a5,1
    8000270c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000270e:	a3bff0ef          	jal	80002148 <wakeup>
    release(&tickslock);
    80002712:	8526                	mv	a0,s1
    80002714:	d78fe0ef          	jal	80000c8c <release>
    80002718:	64a2                	ld	s1,8(sp)
    8000271a:	bf75                	j	800026d6 <clockintr+0xe>

000000008000271c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000271c:	1101                	addi	sp,sp,-32
    8000271e:	ec06                	sd	ra,24(sp)
    80002720:	e822                	sd	s0,16(sp)
    80002722:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002724:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002728:	57fd                	li	a5,-1
    8000272a:	17fe                	slli	a5,a5,0x3f
    8000272c:	07a5                	addi	a5,a5,9
    8000272e:	00f70c63          	beq	a4,a5,80002746 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002732:	57fd                	li	a5,-1
    80002734:	17fe                	slli	a5,a5,0x3f
    80002736:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002738:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000273a:	04f70763          	beq	a4,a5,80002788 <devintr+0x6c>
  }
}
    8000273e:	60e2                	ld	ra,24(sp)
    80002740:	6442                	ld	s0,16(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    80002746:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002748:	595020ef          	jal	800054dc <plic_claim>
    8000274c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000274e:	47a9                	li	a5,10
    80002750:	00f50963          	beq	a0,a5,80002762 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002754:	4785                	li	a5,1
    80002756:	00f50963          	beq	a0,a5,80002768 <devintr+0x4c>
    return 1;
    8000275a:	4505                	li	a0,1
    } else if(irq){
    8000275c:	e889                	bnez	s1,8000276e <devintr+0x52>
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	bff9                	j	8000273e <devintr+0x22>
      uartintr();
    80002762:	aa4fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002766:	a819                	j	8000277c <devintr+0x60>
      virtio_disk_intr();
    80002768:	23a030ef          	jal	800059a2 <virtio_disk_intr>
    if(irq)
    8000276c:	a801                	j	8000277c <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000276e:	85a6                	mv	a1,s1
    80002770:	00005517          	auipc	a0,0x5
    80002774:	b8050513          	addi	a0,a0,-1152 # 800072f0 <etext+0x2f0>
    80002778:	d4bfd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000277c:	8526                	mv	a0,s1
    8000277e:	57f020ef          	jal	800054fc <plic_complete>
    return 1;
    80002782:	4505                	li	a0,1
    80002784:	64a2                	ld	s1,8(sp)
    80002786:	bf65                	j	8000273e <devintr+0x22>
    clockintr();
    80002788:	f41ff0ef          	jal	800026c8 <clockintr>
    return 2;
    8000278c:	4509                	li	a0,2
    8000278e:	bf45                	j	8000273e <devintr+0x22>

0000000080002790 <usertrap>:
{
    80002790:	1101                	addi	sp,sp,-32
    80002792:	ec06                	sd	ra,24(sp)
    80002794:	e822                	sd	s0,16(sp)
    80002796:	e426                	sd	s1,8(sp)
    80002798:	e04a                	sd	s2,0(sp)
    8000279a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027a0:	1007f793          	andi	a5,a5,256
    800027a4:	ef85                	bnez	a5,800027dc <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a6:	00003797          	auipc	a5,0x3
    800027aa:	c8a78793          	addi	a5,a5,-886 # 80005430 <kernelvec>
    800027ae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027b2:	92eff0ef          	jal	800018e0 <myproc>
    800027b6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027b8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ba:	14102773          	csrr	a4,sepc
    800027be:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027c4:	47a1                	li	a5,8
    800027c6:	02f70163          	beq	a4,a5,800027e8 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800027ca:	f53ff0ef          	jal	8000271c <devintr>
    800027ce:	892a                	mv	s2,a0
    800027d0:	c135                	beqz	a0,80002834 <usertrap+0xa4>
  if(killed(p))
    800027d2:	8526                	mv	a0,s1
    800027d4:	b61ff0ef          	jal	80002334 <killed>
    800027d8:	cd1d                	beqz	a0,80002816 <usertrap+0x86>
    800027da:	a81d                	j	80002810 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800027dc:	00005517          	auipc	a0,0x5
    800027e0:	b3450513          	addi	a0,a0,-1228 # 80007310 <etext+0x310>
    800027e4:	fb1fd0ef          	jal	80000794 <panic>
    if(killed(p))
    800027e8:	b4dff0ef          	jal	80002334 <killed>
    800027ec:	e121                	bnez	a0,8000282c <usertrap+0x9c>
    p->trapframe->epc += 4;
    800027ee:	6cb8                	ld	a4,88(s1)
    800027f0:	6f1c                	ld	a5,24(a4)
    800027f2:	0791                	addi	a5,a5,4
    800027f4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027fe:	10079073          	csrw	sstatus,a5
    syscall();
    80002802:	248000ef          	jal	80002a4a <syscall>
  if(killed(p))
    80002806:	8526                	mv	a0,s1
    80002808:	b2dff0ef          	jal	80002334 <killed>
    8000280c:	c901                	beqz	a0,8000281c <usertrap+0x8c>
    8000280e:	4901                	li	s2,0
    exit(-1);
    80002810:	557d                	li	a0,-1
    80002812:	9f7ff0ef          	jal	80002208 <exit>
  if(which_dev == 2)
    80002816:	4789                	li	a5,2
    80002818:	04f90563          	beq	s2,a5,80002862 <usertrap+0xd2>
  usertrapret();
    8000281c:	e1bff0ef          	jal	80002636 <usertrapret>
}
    80002820:	60e2                	ld	ra,24(sp)
    80002822:	6442                	ld	s0,16(sp)
    80002824:	64a2                	ld	s1,8(sp)
    80002826:	6902                	ld	s2,0(sp)
    80002828:	6105                	addi	sp,sp,32
    8000282a:	8082                	ret
      exit(-1);
    8000282c:	557d                	li	a0,-1
    8000282e:	9dbff0ef          	jal	80002208 <exit>
    80002832:	bf75                	j	800027ee <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002834:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002838:	5890                	lw	a2,48(s1)
    8000283a:	00005517          	auipc	a0,0x5
    8000283e:	af650513          	addi	a0,a0,-1290 # 80007330 <etext+0x330>
    80002842:	c81fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002846:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000284a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000284e:	00005517          	auipc	a0,0x5
    80002852:	b1250513          	addi	a0,a0,-1262 # 80007360 <etext+0x360>
    80002856:	c6dfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ab5ff0ef          	jal	80002310 <setkilled>
    80002860:	b75d                	j	80002806 <usertrap+0x76>
    yield();
    80002862:	86fff0ef          	jal	800020d0 <yield>
    80002866:	bf5d                	j	8000281c <usertrap+0x8c>

0000000080002868 <kerneltrap>:
{
    80002868:	7179                	addi	sp,sp,-48
    8000286a:	f406                	sd	ra,40(sp)
    8000286c:	f022                	sd	s0,32(sp)
    8000286e:	ec26                	sd	s1,24(sp)
    80002870:	e84a                	sd	s2,16(sp)
    80002872:	e44e                	sd	s3,8(sp)
    80002874:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002876:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002882:	1004f793          	andi	a5,s1,256
    80002886:	c795                	beqz	a5,800028b2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002888:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000288c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000288e:	eb85                	bnez	a5,800028be <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002890:	e8dff0ef          	jal	8000271c <devintr>
    80002894:	c91d                	beqz	a0,800028ca <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002896:	4789                	li	a5,2
    80002898:	04f50a63          	beq	a0,a5,800028ec <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000289c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a0:	10049073          	csrw	sstatus,s1
}
    800028a4:	70a2                	ld	ra,40(sp)
    800028a6:	7402                	ld	s0,32(sp)
    800028a8:	64e2                	ld	s1,24(sp)
    800028aa:	6942                	ld	s2,16(sp)
    800028ac:	69a2                	ld	s3,8(sp)
    800028ae:	6145                	addi	sp,sp,48
    800028b0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028b2:	00005517          	auipc	a0,0x5
    800028b6:	ad650513          	addi	a0,a0,-1322 # 80007388 <etext+0x388>
    800028ba:	edbfd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    800028be:	00005517          	auipc	a0,0x5
    800028c2:	af250513          	addi	a0,a0,-1294 # 800073b0 <etext+0x3b0>
    800028c6:	ecffd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ca:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ce:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800028d2:	85ce                	mv	a1,s3
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	afc50513          	addi	a0,a0,-1284 # 800073d0 <etext+0x3d0>
    800028dc:	be7fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    800028e0:	00005517          	auipc	a0,0x5
    800028e4:	b1850513          	addi	a0,a0,-1256 # 800073f8 <etext+0x3f8>
    800028e8:	eadfd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    800028ec:	ff5fe0ef          	jal	800018e0 <myproc>
    800028f0:	d555                	beqz	a0,8000289c <kerneltrap+0x34>
    yield();
    800028f2:	fdeff0ef          	jal	800020d0 <yield>
    800028f6:	b75d                	j	8000289c <kerneltrap+0x34>

00000000800028f8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800028f8:	1101                	addi	sp,sp,-32
    800028fa:	ec06                	sd	ra,24(sp)
    800028fc:	e822                	sd	s0,16(sp)
    800028fe:	e426                	sd	s1,8(sp)
    80002900:	1000                	addi	s0,sp,32
    80002902:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002904:	fddfe0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002908:	4795                	li	a5,5
    8000290a:	0497e163          	bltu	a5,s1,8000294c <argraw+0x54>
    8000290e:	048a                	slli	s1,s1,0x2
    80002910:	00005717          	auipc	a4,0x5
    80002914:	ea870713          	addi	a4,a4,-344 # 800077b8 <states.0+0x30>
    80002918:	94ba                	add	s1,s1,a4
    8000291a:	409c                	lw	a5,0(s1)
    8000291c:	97ba                	add	a5,a5,a4
    8000291e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002920:	6d3c                	ld	a5,88(a0)
    80002922:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002924:	60e2                	ld	ra,24(sp)
    80002926:	6442                	ld	s0,16(sp)
    80002928:	64a2                	ld	s1,8(sp)
    8000292a:	6105                	addi	sp,sp,32
    8000292c:	8082                	ret
    return p->trapframe->a1;
    8000292e:	6d3c                	ld	a5,88(a0)
    80002930:	7fa8                	ld	a0,120(a5)
    80002932:	bfcd                	j	80002924 <argraw+0x2c>
    return p->trapframe->a2;
    80002934:	6d3c                	ld	a5,88(a0)
    80002936:	63c8                	ld	a0,128(a5)
    80002938:	b7f5                	j	80002924 <argraw+0x2c>
    return p->trapframe->a3;
    8000293a:	6d3c                	ld	a5,88(a0)
    8000293c:	67c8                	ld	a0,136(a5)
    8000293e:	b7dd                	j	80002924 <argraw+0x2c>
    return p->trapframe->a4;
    80002940:	6d3c                	ld	a5,88(a0)
    80002942:	6bc8                	ld	a0,144(a5)
    80002944:	b7c5                	j	80002924 <argraw+0x2c>
    return p->trapframe->a5;
    80002946:	6d3c                	ld	a5,88(a0)
    80002948:	6fc8                	ld	a0,152(a5)
    8000294a:	bfe9                	j	80002924 <argraw+0x2c>
  panic("argraw");
    8000294c:	00005517          	auipc	a0,0x5
    80002950:	abc50513          	addi	a0,a0,-1348 # 80007408 <etext+0x408>
    80002954:	e41fd0ef          	jal	80000794 <panic>

0000000080002958 <fetchaddr>:
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	e04a                	sd	s2,0(sp)
    80002962:	1000                	addi	s0,sp,32
    80002964:	84aa                	mv	s1,a0
    80002966:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002968:	f79fe0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000296c:	653c                	ld	a5,72(a0)
    8000296e:	02f4f663          	bgeu	s1,a5,8000299a <fetchaddr+0x42>
    80002972:	00848713          	addi	a4,s1,8
    80002976:	02e7e463          	bltu	a5,a4,8000299e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000297a:	46a1                	li	a3,8
    8000297c:	8626                	mv	a2,s1
    8000297e:	85ca                	mv	a1,s2
    80002980:	6928                	ld	a0,80(a0)
    80002982:	ca7fe0ef          	jal	80001628 <copyin>
    80002986:	00a03533          	snez	a0,a0
    8000298a:	40a00533          	neg	a0,a0
}
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6902                	ld	s2,0(sp)
    80002996:	6105                	addi	sp,sp,32
    80002998:	8082                	ret
    return -1;
    8000299a:	557d                	li	a0,-1
    8000299c:	bfcd                	j	8000298e <fetchaddr+0x36>
    8000299e:	557d                	li	a0,-1
    800029a0:	b7fd                	j	8000298e <fetchaddr+0x36>

00000000800029a2 <fetchstr>:
{
    800029a2:	7179                	addi	sp,sp,-48
    800029a4:	f406                	sd	ra,40(sp)
    800029a6:	f022                	sd	s0,32(sp)
    800029a8:	ec26                	sd	s1,24(sp)
    800029aa:	e84a                	sd	s2,16(sp)
    800029ac:	e44e                	sd	s3,8(sp)
    800029ae:	1800                	addi	s0,sp,48
    800029b0:	892a                	mv	s2,a0
    800029b2:	84ae                	mv	s1,a1
    800029b4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800029b6:	f2bfe0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029ba:	86ce                	mv	a3,s3
    800029bc:	864a                	mv	a2,s2
    800029be:	85a6                	mv	a1,s1
    800029c0:	6928                	ld	a0,80(a0)
    800029c2:	cedfe0ef          	jal	800016ae <copyinstr>
    800029c6:	00054c63          	bltz	a0,800029de <fetchstr+0x3c>
  return strlen(buf);
    800029ca:	8526                	mv	a0,s1
    800029cc:	c6cfe0ef          	jal	80000e38 <strlen>
}
    800029d0:	70a2                	ld	ra,40(sp)
    800029d2:	7402                	ld	s0,32(sp)
    800029d4:	64e2                	ld	s1,24(sp)
    800029d6:	6942                	ld	s2,16(sp)
    800029d8:	69a2                	ld	s3,8(sp)
    800029da:	6145                	addi	sp,sp,48
    800029dc:	8082                	ret
    return -1;
    800029de:	557d                	li	a0,-1
    800029e0:	bfc5                	j	800029d0 <fetchstr+0x2e>

00000000800029e2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029e2:	1101                	addi	sp,sp,-32
    800029e4:	ec06                	sd	ra,24(sp)
    800029e6:	e822                	sd	s0,16(sp)
    800029e8:	e426                	sd	s1,8(sp)
    800029ea:	1000                	addi	s0,sp,32
    800029ec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800029ee:	f0bff0ef          	jal	800028f8 <argraw>
    800029f2:	c088                	sw	a0,0(s1)
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret

00000000800029fe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	e426                	sd	s1,8(sp)
    80002a06:	1000                	addi	s0,sp,32
    80002a08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a0a:	eefff0ef          	jal	800028f8 <argraw>
    80002a0e:	e088                	sd	a0,0(s1)
}
    80002a10:	60e2                	ld	ra,24(sp)
    80002a12:	6442                	ld	s0,16(sp)
    80002a14:	64a2                	ld	s1,8(sp)
    80002a16:	6105                	addi	sp,sp,32
    80002a18:	8082                	ret

0000000080002a1a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a1a:	7179                	addi	sp,sp,-48
    80002a1c:	f406                	sd	ra,40(sp)
    80002a1e:	f022                	sd	s0,32(sp)
    80002a20:	ec26                	sd	s1,24(sp)
    80002a22:	e84a                	sd	s2,16(sp)
    80002a24:	1800                	addi	s0,sp,48
    80002a26:	84ae                	mv	s1,a1
    80002a28:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a2a:	fd840593          	addi	a1,s0,-40
    80002a2e:	fd1ff0ef          	jal	800029fe <argaddr>
  return fetchstr(addr, buf, max);
    80002a32:	864a                	mv	a2,s2
    80002a34:	85a6                	mv	a1,s1
    80002a36:	fd843503          	ld	a0,-40(s0)
    80002a3a:	f69ff0ef          	jal	800029a2 <fetchstr>
}
    80002a3e:	70a2                	ld	ra,40(sp)
    80002a40:	7402                	ld	s0,32(sp)
    80002a42:	64e2                	ld	s1,24(sp)
    80002a44:	6942                	ld	s2,16(sp)
    80002a46:	6145                	addi	sp,sp,48
    80002a48:	8082                	ret

0000000080002a4a <syscall>:
[SYS_getpinfo]   sys_getpinfo,
};

void
syscall(void)
{
    80002a4a:	1101                	addi	sp,sp,-32
    80002a4c:	ec06                	sd	ra,24(sp)
    80002a4e:	e822                	sd	s0,16(sp)
    80002a50:	e426                	sd	s1,8(sp)
    80002a52:	e04a                	sd	s2,0(sp)
    80002a54:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a56:	e8bfe0ef          	jal	800018e0 <myproc>
    80002a5a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a5c:	05853903          	ld	s2,88(a0)
    80002a60:	0a893783          	ld	a5,168(s2)
    80002a64:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a68:	37fd                	addiw	a5,a5,-1
    80002a6a:	4759                	li	a4,22
    80002a6c:	00f76f63          	bltu	a4,a5,80002a8a <syscall+0x40>
    80002a70:	00369713          	slli	a4,a3,0x3
    80002a74:	00005797          	auipc	a5,0x5
    80002a78:	d5c78793          	addi	a5,a5,-676 # 800077d0 <syscalls>
    80002a7c:	97ba                	add	a5,a5,a4
    80002a7e:	639c                	ld	a5,0(a5)
    80002a80:	c789                	beqz	a5,80002a8a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a82:	9782                	jalr	a5
    80002a84:	06a93823          	sd	a0,112(s2)
    80002a88:	a829                	j	80002aa2 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a8a:	15848613          	addi	a2,s1,344
    80002a8e:	588c                	lw	a1,48(s1)
    80002a90:	00005517          	auipc	a0,0x5
    80002a94:	98050513          	addi	a0,a0,-1664 # 80007410 <etext+0x410>
    80002a98:	a2bfd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a9c:	6cbc                	ld	a5,88(s1)
    80002a9e:	577d                	li	a4,-1
    80002aa0:	fbb8                	sd	a4,112(a5)
  }
}
    80002aa2:	60e2                	ld	ra,24(sp)
    80002aa4:	6442                	ld	s0,16(sp)
    80002aa6:	64a2                	ld	s1,8(sp)
    80002aa8:	6902                	ld	s2,0(sp)
    80002aaa:	6105                	addi	sp,sp,32
    80002aac:	8082                	ret

0000000080002aae <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002aae:	1101                	addi	sp,sp,-32
    80002ab0:	ec06                	sd	ra,24(sp)
    80002ab2:	e822                	sd	s0,16(sp)
    80002ab4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ab6:	fec40593          	addi	a1,s0,-20
    80002aba:	4501                	li	a0,0
    80002abc:	f27ff0ef          	jal	800029e2 <argint>
  exit(n);
    80002ac0:	fec42503          	lw	a0,-20(s0)
    80002ac4:	f44ff0ef          	jal	80002208 <exit>
  return 0;  // not reached
}
    80002ac8:	4501                	li	a0,0
    80002aca:	60e2                	ld	ra,24(sp)
    80002acc:	6442                	ld	s0,16(sp)
    80002ace:	6105                	addi	sp,sp,32
    80002ad0:	8082                	ret

0000000080002ad2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ad2:	1141                	addi	sp,sp,-16
    80002ad4:	e406                	sd	ra,8(sp)
    80002ad6:	e022                	sd	s0,0(sp)
    80002ad8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ada:	e07fe0ef          	jal	800018e0 <myproc>
}
    80002ade:	5908                	lw	a0,48(a0)
    80002ae0:	60a2                	ld	ra,8(sp)
    80002ae2:	6402                	ld	s0,0(sp)
    80002ae4:	0141                	addi	sp,sp,16
    80002ae6:	8082                	ret

0000000080002ae8 <sys_fork>:

uint64
sys_fork(void)
{
    80002ae8:	1141                	addi	sp,sp,-16
    80002aea:	e406                	sd	ra,8(sp)
    80002aec:	e022                	sd	s0,0(sp)
    80002aee:	0800                	addi	s0,sp,16
  return fork();
    80002af0:	ad6ff0ef          	jal	80001dc6 <fork>
}
    80002af4:	60a2                	ld	ra,8(sp)
    80002af6:	6402                	ld	s0,0(sp)
    80002af8:	0141                	addi	sp,sp,16
    80002afa:	8082                	ret

0000000080002afc <sys_wait>:

uint64
sys_wait(void)
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b04:	fe840593          	addi	a1,s0,-24
    80002b08:	4501                	li	a0,0
    80002b0a:	ef5ff0ef          	jal	800029fe <argaddr>
  return wait(p);
    80002b0e:	fe843503          	ld	a0,-24(s0)
    80002b12:	84dff0ef          	jal	8000235e <wait>
}
    80002b16:	60e2                	ld	ra,24(sp)
    80002b18:	6442                	ld	s0,16(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret

0000000080002b1e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b1e:	7179                	addi	sp,sp,-48
    80002b20:	f406                	sd	ra,40(sp)
    80002b22:	f022                	sd	s0,32(sp)
    80002b24:	ec26                	sd	s1,24(sp)
    80002b26:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b28:	fdc40593          	addi	a1,s0,-36
    80002b2c:	4501                	li	a0,0
    80002b2e:	eb5ff0ef          	jal	800029e2 <argint>
  addr = myproc()->sz;
    80002b32:	daffe0ef          	jal	800018e0 <myproc>
    80002b36:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002b38:	fdc42503          	lw	a0,-36(s0)
    80002b3c:	a3aff0ef          	jal	80001d76 <growproc>
    80002b40:	00054863          	bltz	a0,80002b50 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002b44:	8526                	mv	a0,s1
    80002b46:	70a2                	ld	ra,40(sp)
    80002b48:	7402                	ld	s0,32(sp)
    80002b4a:	64e2                	ld	s1,24(sp)
    80002b4c:	6145                	addi	sp,sp,48
    80002b4e:	8082                	ret
    return -1;
    80002b50:	54fd                	li	s1,-1
    80002b52:	bfcd                	j	80002b44 <sys_sbrk+0x26>

0000000080002b54 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002b54:	7139                	addi	sp,sp,-64
    80002b56:	fc06                	sd	ra,56(sp)
    80002b58:	f822                	sd	s0,48(sp)
    80002b5a:	f04a                	sd	s2,32(sp)
    80002b5c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b5e:	fcc40593          	addi	a1,s0,-52
    80002b62:	4501                	li	a0,0
    80002b64:	e7fff0ef          	jal	800029e2 <argint>
  if(n < 0)
    80002b68:	fcc42783          	lw	a5,-52(s0)
    80002b6c:	0607c763          	bltz	a5,80002bda <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002b70:	00016517          	auipc	a0,0x16
    80002b74:	b1050513          	addi	a0,a0,-1264 # 80018680 <tickslock>
    80002b78:	87cfe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002b7c:	00007917          	auipc	s2,0x7
    80002b80:	7a492903          	lw	s2,1956(s2) # 8000a320 <ticks>
  while(ticks - ticks0 < n){
    80002b84:	fcc42783          	lw	a5,-52(s0)
    80002b88:	cf8d                	beqz	a5,80002bc2 <sys_sleep+0x6e>
    80002b8a:	f426                	sd	s1,40(sp)
    80002b8c:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b8e:	00016997          	auipc	s3,0x16
    80002b92:	af298993          	addi	s3,s3,-1294 # 80018680 <tickslock>
    80002b96:	00007497          	auipc	s1,0x7
    80002b9a:	78a48493          	addi	s1,s1,1930 # 8000a320 <ticks>
    if(killed(myproc())){
    80002b9e:	d43fe0ef          	jal	800018e0 <myproc>
    80002ba2:	f92ff0ef          	jal	80002334 <killed>
    80002ba6:	ed0d                	bnez	a0,80002be0 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002ba8:	85ce                	mv	a1,s3
    80002baa:	8526                	mv	a0,s1
    80002bac:	d50ff0ef          	jal	800020fc <sleep>
  while(ticks - ticks0 < n){
    80002bb0:	409c                	lw	a5,0(s1)
    80002bb2:	412787bb          	subw	a5,a5,s2
    80002bb6:	fcc42703          	lw	a4,-52(s0)
    80002bba:	fee7e2e3          	bltu	a5,a4,80002b9e <sys_sleep+0x4a>
    80002bbe:	74a2                	ld	s1,40(sp)
    80002bc0:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002bc2:	00016517          	auipc	a0,0x16
    80002bc6:	abe50513          	addi	a0,a0,-1346 # 80018680 <tickslock>
    80002bca:	8c2fe0ef          	jal	80000c8c <release>
  return 0;
    80002bce:	4501                	li	a0,0
}
    80002bd0:	70e2                	ld	ra,56(sp)
    80002bd2:	7442                	ld	s0,48(sp)
    80002bd4:	7902                	ld	s2,32(sp)
    80002bd6:	6121                	addi	sp,sp,64
    80002bd8:	8082                	ret
    n = 0;
    80002bda:	fc042623          	sw	zero,-52(s0)
    80002bde:	bf49                	j	80002b70 <sys_sleep+0x1c>
      release(&tickslock);
    80002be0:	00016517          	auipc	a0,0x16
    80002be4:	aa050513          	addi	a0,a0,-1376 # 80018680 <tickslock>
    80002be8:	8a4fe0ef          	jal	80000c8c <release>
      return -1;
    80002bec:	557d                	li	a0,-1
    80002bee:	74a2                	ld	s1,40(sp)
    80002bf0:	69e2                	ld	s3,24(sp)
    80002bf2:	bff9                	j	80002bd0 <sys_sleep+0x7c>

0000000080002bf4 <sys_kill>:

uint64
sys_kill(void)
{
    80002bf4:	1101                	addi	sp,sp,-32
    80002bf6:	ec06                	sd	ra,24(sp)
    80002bf8:	e822                	sd	s0,16(sp)
    80002bfa:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bfc:	fec40593          	addi	a1,s0,-20
    80002c00:	4501                	li	a0,0
    80002c02:	de1ff0ef          	jal	800029e2 <argint>
  return kill(pid);
    80002c06:	fec42503          	lw	a0,-20(s0)
    80002c0a:	ea0ff0ef          	jal	800022aa <kill>
}
    80002c0e:	60e2                	ld	ra,24(sp)
    80002c10:	6442                	ld	s0,16(sp)
    80002c12:	6105                	addi	sp,sp,32
    80002c14:	8082                	ret

0000000080002c16 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c16:	1101                	addi	sp,sp,-32
    80002c18:	ec06                	sd	ra,24(sp)
    80002c1a:	e822                	sd	s0,16(sp)
    80002c1c:	e426                	sd	s1,8(sp)
    80002c1e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c20:	00016517          	auipc	a0,0x16
    80002c24:	a6050513          	addi	a0,a0,-1440 # 80018680 <tickslock>
    80002c28:	fcdfd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002c2c:	00007497          	auipc	s1,0x7
    80002c30:	6f44a483          	lw	s1,1780(s1) # 8000a320 <ticks>
  release(&tickslock);
    80002c34:	00016517          	auipc	a0,0x16
    80002c38:	a4c50513          	addi	a0,a0,-1460 # 80018680 <tickslock>
    80002c3c:	850fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002c40:	02049513          	slli	a0,s1,0x20
    80002c44:	9101                	srli	a0,a0,0x20
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	64a2                	ld	s1,8(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c50:	7179                	addi	sp,sp,-48
    80002c52:	f406                	sd	ra,40(sp)
    80002c54:	f022                	sd	s0,32(sp)
    80002c56:	ec26                	sd	s1,24(sp)
    80002c58:	e84a                	sd	s2,16(sp)
    80002c5a:	e44e                	sd	s3,8(sp)
    80002c5c:	e052                	sd	s4,0(sp)
    80002c5e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c60:	00004597          	auipc	a1,0x4
    80002c64:	7d058593          	addi	a1,a1,2000 # 80007430 <etext+0x430>
    80002c68:	00016517          	auipc	a0,0x16
    80002c6c:	a3050513          	addi	a0,a0,-1488 # 80018698 <bcache>
    80002c70:	f05fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c74:	0001e797          	auipc	a5,0x1e
    80002c78:	a2478793          	addi	a5,a5,-1500 # 80020698 <bcache+0x8000>
    80002c7c:	0001e717          	auipc	a4,0x1e
    80002c80:	c8470713          	addi	a4,a4,-892 # 80020900 <bcache+0x8268>
    80002c84:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c88:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c8c:	00016497          	auipc	s1,0x16
    80002c90:	a2448493          	addi	s1,s1,-1500 # 800186b0 <bcache+0x18>
    b->next = bcache.head.next;
    80002c94:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c96:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c98:	00004a17          	auipc	s4,0x4
    80002c9c:	7a0a0a13          	addi	s4,s4,1952 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002ca0:	2b893783          	ld	a5,696(s2)
    80002ca4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ca6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002caa:	85d2                	mv	a1,s4
    80002cac:	01048513          	addi	a0,s1,16
    80002cb0:	248010ef          	jal	80003ef8 <initsleeplock>
    bcache.head.next->prev = b;
    80002cb4:	2b893783          	ld	a5,696(s2)
    80002cb8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cba:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cbe:	45848493          	addi	s1,s1,1112
    80002cc2:	fd349fe3          	bne	s1,s3,80002ca0 <binit+0x50>
  }
}
    80002cc6:	70a2                	ld	ra,40(sp)
    80002cc8:	7402                	ld	s0,32(sp)
    80002cca:	64e2                	ld	s1,24(sp)
    80002ccc:	6942                	ld	s2,16(sp)
    80002cce:	69a2                	ld	s3,8(sp)
    80002cd0:	6a02                	ld	s4,0(sp)
    80002cd2:	6145                	addi	sp,sp,48
    80002cd4:	8082                	ret

0000000080002cd6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002cd6:	7179                	addi	sp,sp,-48
    80002cd8:	f406                	sd	ra,40(sp)
    80002cda:	f022                	sd	s0,32(sp)
    80002cdc:	ec26                	sd	s1,24(sp)
    80002cde:	e84a                	sd	s2,16(sp)
    80002ce0:	e44e                	sd	s3,8(sp)
    80002ce2:	1800                	addi	s0,sp,48
    80002ce4:	892a                	mv	s2,a0
    80002ce6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ce8:	00016517          	auipc	a0,0x16
    80002cec:	9b050513          	addi	a0,a0,-1616 # 80018698 <bcache>
    80002cf0:	f05fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cf4:	0001e497          	auipc	s1,0x1e
    80002cf8:	c5c4b483          	ld	s1,-932(s1) # 80020950 <bcache+0x82b8>
    80002cfc:	0001e797          	auipc	a5,0x1e
    80002d00:	c0478793          	addi	a5,a5,-1020 # 80020900 <bcache+0x8268>
    80002d04:	02f48b63          	beq	s1,a5,80002d3a <bread+0x64>
    80002d08:	873e                	mv	a4,a5
    80002d0a:	a021                	j	80002d12 <bread+0x3c>
    80002d0c:	68a4                	ld	s1,80(s1)
    80002d0e:	02e48663          	beq	s1,a4,80002d3a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d12:	449c                	lw	a5,8(s1)
    80002d14:	ff279ce3          	bne	a5,s2,80002d0c <bread+0x36>
    80002d18:	44dc                	lw	a5,12(s1)
    80002d1a:	ff3799e3          	bne	a5,s3,80002d0c <bread+0x36>
      b->refcnt++;
    80002d1e:	40bc                	lw	a5,64(s1)
    80002d20:	2785                	addiw	a5,a5,1
    80002d22:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d24:	00016517          	auipc	a0,0x16
    80002d28:	97450513          	addi	a0,a0,-1676 # 80018698 <bcache>
    80002d2c:	f61fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002d30:	01048513          	addi	a0,s1,16
    80002d34:	1fa010ef          	jal	80003f2e <acquiresleep>
      return b;
    80002d38:	a889                	j	80002d8a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d3a:	0001e497          	auipc	s1,0x1e
    80002d3e:	c0e4b483          	ld	s1,-1010(s1) # 80020948 <bcache+0x82b0>
    80002d42:	0001e797          	auipc	a5,0x1e
    80002d46:	bbe78793          	addi	a5,a5,-1090 # 80020900 <bcache+0x8268>
    80002d4a:	00f48863          	beq	s1,a5,80002d5a <bread+0x84>
    80002d4e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d50:	40bc                	lw	a5,64(s1)
    80002d52:	cb91                	beqz	a5,80002d66 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d54:	64a4                	ld	s1,72(s1)
    80002d56:	fee49de3          	bne	s1,a4,80002d50 <bread+0x7a>
  panic("bget: no buffers");
    80002d5a:	00004517          	auipc	a0,0x4
    80002d5e:	6e650513          	addi	a0,a0,1766 # 80007440 <etext+0x440>
    80002d62:	a33fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002d66:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d6a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d6e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d72:	4785                	li	a5,1
    80002d74:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d76:	00016517          	auipc	a0,0x16
    80002d7a:	92250513          	addi	a0,a0,-1758 # 80018698 <bcache>
    80002d7e:	f0ffd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002d82:	01048513          	addi	a0,s1,16
    80002d86:	1a8010ef          	jal	80003f2e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d8a:	409c                	lw	a5,0(s1)
    80002d8c:	cb89                	beqz	a5,80002d9e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d8e:	8526                	mv	a0,s1
    80002d90:	70a2                	ld	ra,40(sp)
    80002d92:	7402                	ld	s0,32(sp)
    80002d94:	64e2                	ld	s1,24(sp)
    80002d96:	6942                	ld	s2,16(sp)
    80002d98:	69a2                	ld	s3,8(sp)
    80002d9a:	6145                	addi	sp,sp,48
    80002d9c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d9e:	4581                	li	a1,0
    80002da0:	8526                	mv	a0,s1
    80002da2:	1ef020ef          	jal	80005790 <virtio_disk_rw>
    b->valid = 1;
    80002da6:	4785                	li	a5,1
    80002da8:	c09c                	sw	a5,0(s1)
  return b;
    80002daa:	b7d5                	j	80002d8e <bread+0xb8>

0000000080002dac <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002dac:	1101                	addi	sp,sp,-32
    80002dae:	ec06                	sd	ra,24(sp)
    80002db0:	e822                	sd	s0,16(sp)
    80002db2:	e426                	sd	s1,8(sp)
    80002db4:	1000                	addi	s0,sp,32
    80002db6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002db8:	0541                	addi	a0,a0,16
    80002dba:	1f2010ef          	jal	80003fac <holdingsleep>
    80002dbe:	c911                	beqz	a0,80002dd2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dc0:	4585                	li	a1,1
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	1cd020ef          	jal	80005790 <virtio_disk_rw>
}
    80002dc8:	60e2                	ld	ra,24(sp)
    80002dca:	6442                	ld	s0,16(sp)
    80002dcc:	64a2                	ld	s1,8(sp)
    80002dce:	6105                	addi	sp,sp,32
    80002dd0:	8082                	ret
    panic("bwrite");
    80002dd2:	00004517          	auipc	a0,0x4
    80002dd6:	68650513          	addi	a0,a0,1670 # 80007458 <etext+0x458>
    80002dda:	9bbfd0ef          	jal	80000794 <panic>

0000000080002dde <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	e04a                	sd	s2,0(sp)
    80002de8:	1000                	addi	s0,sp,32
    80002dea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dec:	01050913          	addi	s2,a0,16
    80002df0:	854a                	mv	a0,s2
    80002df2:	1ba010ef          	jal	80003fac <holdingsleep>
    80002df6:	c135                	beqz	a0,80002e5a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002df8:	854a                	mv	a0,s2
    80002dfa:	17a010ef          	jal	80003f74 <releasesleep>

  acquire(&bcache.lock);
    80002dfe:	00016517          	auipc	a0,0x16
    80002e02:	89a50513          	addi	a0,a0,-1894 # 80018698 <bcache>
    80002e06:	deffd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002e0a:	40bc                	lw	a5,64(s1)
    80002e0c:	37fd                	addiw	a5,a5,-1
    80002e0e:	0007871b          	sext.w	a4,a5
    80002e12:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e14:	e71d                	bnez	a4,80002e42 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e16:	68b8                	ld	a4,80(s1)
    80002e18:	64bc                	ld	a5,72(s1)
    80002e1a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e1c:	68b8                	ld	a4,80(s1)
    80002e1e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e20:	0001e797          	auipc	a5,0x1e
    80002e24:	87878793          	addi	a5,a5,-1928 # 80020698 <bcache+0x8000>
    80002e28:	2b87b703          	ld	a4,696(a5)
    80002e2c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e2e:	0001e717          	auipc	a4,0x1e
    80002e32:	ad270713          	addi	a4,a4,-1326 # 80020900 <bcache+0x8268>
    80002e36:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e38:	2b87b703          	ld	a4,696(a5)
    80002e3c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e3e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e42:	00016517          	auipc	a0,0x16
    80002e46:	85650513          	addi	a0,a0,-1962 # 80018698 <bcache>
    80002e4a:	e43fd0ef          	jal	80000c8c <release>
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6902                	ld	s2,0(sp)
    80002e56:	6105                	addi	sp,sp,32
    80002e58:	8082                	ret
    panic("brelse");
    80002e5a:	00004517          	auipc	a0,0x4
    80002e5e:	60650513          	addi	a0,a0,1542 # 80007460 <etext+0x460>
    80002e62:	933fd0ef          	jal	80000794 <panic>

0000000080002e66 <bpin>:

void
bpin(struct buf *b) {
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	e426                	sd	s1,8(sp)
    80002e6e:	1000                	addi	s0,sp,32
    80002e70:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e72:	00016517          	auipc	a0,0x16
    80002e76:	82650513          	addi	a0,a0,-2010 # 80018698 <bcache>
    80002e7a:	d7bfd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002e7e:	40bc                	lw	a5,64(s1)
    80002e80:	2785                	addiw	a5,a5,1
    80002e82:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e84:	00016517          	auipc	a0,0x16
    80002e88:	81450513          	addi	a0,a0,-2028 # 80018698 <bcache>
    80002e8c:	e01fd0ef          	jal	80000c8c <release>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret

0000000080002e9a <bunpin>:

void
bunpin(struct buf *b) {
    80002e9a:	1101                	addi	sp,sp,-32
    80002e9c:	ec06                	sd	ra,24(sp)
    80002e9e:	e822                	sd	s0,16(sp)
    80002ea0:	e426                	sd	s1,8(sp)
    80002ea2:	1000                	addi	s0,sp,32
    80002ea4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ea6:	00015517          	auipc	a0,0x15
    80002eaa:	7f250513          	addi	a0,a0,2034 # 80018698 <bcache>
    80002eae:	d47fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002eb2:	40bc                	lw	a5,64(s1)
    80002eb4:	37fd                	addiw	a5,a5,-1
    80002eb6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002eb8:	00015517          	auipc	a0,0x15
    80002ebc:	7e050513          	addi	a0,a0,2016 # 80018698 <bcache>
    80002ec0:	dcdfd0ef          	jal	80000c8c <release>
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	e04a                	sd	s2,0(sp)
    80002ed8:	1000                	addi	s0,sp,32
    80002eda:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002edc:	00d5d59b          	srliw	a1,a1,0xd
    80002ee0:	0001e797          	auipc	a5,0x1e
    80002ee4:	e947a783          	lw	a5,-364(a5) # 80020d74 <sb+0x1c>
    80002ee8:	9dbd                	addw	a1,a1,a5
    80002eea:	dedff0ef          	jal	80002cd6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002eee:	0074f713          	andi	a4,s1,7
    80002ef2:	4785                	li	a5,1
    80002ef4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002ef8:	14ce                	slli	s1,s1,0x33
    80002efa:	90d9                	srli	s1,s1,0x36
    80002efc:	00950733          	add	a4,a0,s1
    80002f00:	05874703          	lbu	a4,88(a4)
    80002f04:	00e7f6b3          	and	a3,a5,a4
    80002f08:	c29d                	beqz	a3,80002f2e <bfree+0x60>
    80002f0a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f0c:	94aa                	add	s1,s1,a0
    80002f0e:	fff7c793          	not	a5,a5
    80002f12:	8f7d                	and	a4,a4,a5
    80002f14:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f18:	711000ef          	jal	80003e28 <log_write>
  brelse(bp);
    80002f1c:	854a                	mv	a0,s2
    80002f1e:	ec1ff0ef          	jal	80002dde <brelse>
}
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	64a2                	ld	s1,8(sp)
    80002f28:	6902                	ld	s2,0(sp)
    80002f2a:	6105                	addi	sp,sp,32
    80002f2c:	8082                	ret
    panic("freeing free block");
    80002f2e:	00004517          	auipc	a0,0x4
    80002f32:	53a50513          	addi	a0,a0,1338 # 80007468 <etext+0x468>
    80002f36:	85ffd0ef          	jal	80000794 <panic>

0000000080002f3a <balloc>:
{
    80002f3a:	711d                	addi	sp,sp,-96
    80002f3c:	ec86                	sd	ra,88(sp)
    80002f3e:	e8a2                	sd	s0,80(sp)
    80002f40:	e4a6                	sd	s1,72(sp)
    80002f42:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f44:	0001e797          	auipc	a5,0x1e
    80002f48:	e187a783          	lw	a5,-488(a5) # 80020d5c <sb+0x4>
    80002f4c:	0e078f63          	beqz	a5,8000304a <balloc+0x110>
    80002f50:	e0ca                	sd	s2,64(sp)
    80002f52:	fc4e                	sd	s3,56(sp)
    80002f54:	f852                	sd	s4,48(sp)
    80002f56:	f456                	sd	s5,40(sp)
    80002f58:	f05a                	sd	s6,32(sp)
    80002f5a:	ec5e                	sd	s7,24(sp)
    80002f5c:	e862                	sd	s8,16(sp)
    80002f5e:	e466                	sd	s9,8(sp)
    80002f60:	8baa                	mv	s7,a0
    80002f62:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f64:	0001eb17          	auipc	s6,0x1e
    80002f68:	df4b0b13          	addi	s6,s6,-524 # 80020d58 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f6c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f6e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f70:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f72:	6c89                	lui	s9,0x2
    80002f74:	a0b5                	j	80002fe0 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f76:	97ca                	add	a5,a5,s2
    80002f78:	8e55                	or	a2,a2,a3
    80002f7a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f7e:	854a                	mv	a0,s2
    80002f80:	6a9000ef          	jal	80003e28 <log_write>
        brelse(bp);
    80002f84:	854a                	mv	a0,s2
    80002f86:	e59ff0ef          	jal	80002dde <brelse>
  bp = bread(dev, bno);
    80002f8a:	85a6                	mv	a1,s1
    80002f8c:	855e                	mv	a0,s7
    80002f8e:	d49ff0ef          	jal	80002cd6 <bread>
    80002f92:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f94:	40000613          	li	a2,1024
    80002f98:	4581                	li	a1,0
    80002f9a:	05850513          	addi	a0,a0,88
    80002f9e:	d2bfd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002fa2:	854a                	mv	a0,s2
    80002fa4:	685000ef          	jal	80003e28 <log_write>
  brelse(bp);
    80002fa8:	854a                	mv	a0,s2
    80002faa:	e35ff0ef          	jal	80002dde <brelse>
}
    80002fae:	6906                	ld	s2,64(sp)
    80002fb0:	79e2                	ld	s3,56(sp)
    80002fb2:	7a42                	ld	s4,48(sp)
    80002fb4:	7aa2                	ld	s5,40(sp)
    80002fb6:	7b02                	ld	s6,32(sp)
    80002fb8:	6be2                	ld	s7,24(sp)
    80002fba:	6c42                	ld	s8,16(sp)
    80002fbc:	6ca2                	ld	s9,8(sp)
}
    80002fbe:	8526                	mv	a0,s1
    80002fc0:	60e6                	ld	ra,88(sp)
    80002fc2:	6446                	ld	s0,80(sp)
    80002fc4:	64a6                	ld	s1,72(sp)
    80002fc6:	6125                	addi	sp,sp,96
    80002fc8:	8082                	ret
    brelse(bp);
    80002fca:	854a                	mv	a0,s2
    80002fcc:	e13ff0ef          	jal	80002dde <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002fd0:	015c87bb          	addw	a5,s9,s5
    80002fd4:	00078a9b          	sext.w	s5,a5
    80002fd8:	004b2703          	lw	a4,4(s6)
    80002fdc:	04eaff63          	bgeu	s5,a4,8000303a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002fe0:	41fad79b          	sraiw	a5,s5,0x1f
    80002fe4:	0137d79b          	srliw	a5,a5,0x13
    80002fe8:	015787bb          	addw	a5,a5,s5
    80002fec:	40d7d79b          	sraiw	a5,a5,0xd
    80002ff0:	01cb2583          	lw	a1,28(s6)
    80002ff4:	9dbd                	addw	a1,a1,a5
    80002ff6:	855e                	mv	a0,s7
    80002ff8:	cdfff0ef          	jal	80002cd6 <bread>
    80002ffc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ffe:	004b2503          	lw	a0,4(s6)
    80003002:	000a849b          	sext.w	s1,s5
    80003006:	8762                	mv	a4,s8
    80003008:	fca4f1e3          	bgeu	s1,a0,80002fca <balloc+0x90>
      m = 1 << (bi % 8);
    8000300c:	00777693          	andi	a3,a4,7
    80003010:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003014:	41f7579b          	sraiw	a5,a4,0x1f
    80003018:	01d7d79b          	srliw	a5,a5,0x1d
    8000301c:	9fb9                	addw	a5,a5,a4
    8000301e:	4037d79b          	sraiw	a5,a5,0x3
    80003022:	00f90633          	add	a2,s2,a5
    80003026:	05864603          	lbu	a2,88(a2)
    8000302a:	00c6f5b3          	and	a1,a3,a2
    8000302e:	d5a1                	beqz	a1,80002f76 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003030:	2705                	addiw	a4,a4,1
    80003032:	2485                	addiw	s1,s1,1
    80003034:	fd471ae3          	bne	a4,s4,80003008 <balloc+0xce>
    80003038:	bf49                	j	80002fca <balloc+0x90>
    8000303a:	6906                	ld	s2,64(sp)
    8000303c:	79e2                	ld	s3,56(sp)
    8000303e:	7a42                	ld	s4,48(sp)
    80003040:	7aa2                	ld	s5,40(sp)
    80003042:	7b02                	ld	s6,32(sp)
    80003044:	6be2                	ld	s7,24(sp)
    80003046:	6c42                	ld	s8,16(sp)
    80003048:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000304a:	00004517          	auipc	a0,0x4
    8000304e:	43650513          	addi	a0,a0,1078 # 80007480 <etext+0x480>
    80003052:	c70fd0ef          	jal	800004c2 <printf>
  return 0;
    80003056:	4481                	li	s1,0
    80003058:	b79d                	j	80002fbe <balloc+0x84>

000000008000305a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	e84a                	sd	s2,16(sp)
    80003064:	e44e                	sd	s3,8(sp)
    80003066:	1800                	addi	s0,sp,48
    80003068:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000306a:	47ad                	li	a5,11
    8000306c:	02b7e663          	bltu	a5,a1,80003098 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003070:	02059793          	slli	a5,a1,0x20
    80003074:	01e7d593          	srli	a1,a5,0x1e
    80003078:	00b504b3          	add	s1,a0,a1
    8000307c:	0504a903          	lw	s2,80(s1)
    80003080:	06091a63          	bnez	s2,800030f4 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003084:	4108                	lw	a0,0(a0)
    80003086:	eb5ff0ef          	jal	80002f3a <balloc>
    8000308a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000308e:	06090363          	beqz	s2,800030f4 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003092:	0524a823          	sw	s2,80(s1)
    80003096:	a8b9                	j	800030f4 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003098:	ff45849b          	addiw	s1,a1,-12
    8000309c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030a0:	0ff00793          	li	a5,255
    800030a4:	06e7ee63          	bltu	a5,a4,80003120 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800030a8:	08052903          	lw	s2,128(a0)
    800030ac:	00091d63          	bnez	s2,800030c6 <bmap+0x6c>
      addr = balloc(ip->dev);
    800030b0:	4108                	lw	a0,0(a0)
    800030b2:	e89ff0ef          	jal	80002f3a <balloc>
    800030b6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030ba:	02090d63          	beqz	s2,800030f4 <bmap+0x9a>
    800030be:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030c0:	0929a023          	sw	s2,128(s3)
    800030c4:	a011                	j	800030c8 <bmap+0x6e>
    800030c6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030c8:	85ca                	mv	a1,s2
    800030ca:	0009a503          	lw	a0,0(s3)
    800030ce:	c09ff0ef          	jal	80002cd6 <bread>
    800030d2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030d4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030d8:	02049713          	slli	a4,s1,0x20
    800030dc:	01e75593          	srli	a1,a4,0x1e
    800030e0:	00b784b3          	add	s1,a5,a1
    800030e4:	0004a903          	lw	s2,0(s1)
    800030e8:	00090e63          	beqz	s2,80003104 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030ec:	8552                	mv	a0,s4
    800030ee:	cf1ff0ef          	jal	80002dde <brelse>
    return addr;
    800030f2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030f4:	854a                	mv	a0,s2
    800030f6:	70a2                	ld	ra,40(sp)
    800030f8:	7402                	ld	s0,32(sp)
    800030fa:	64e2                	ld	s1,24(sp)
    800030fc:	6942                	ld	s2,16(sp)
    800030fe:	69a2                	ld	s3,8(sp)
    80003100:	6145                	addi	sp,sp,48
    80003102:	8082                	ret
      addr = balloc(ip->dev);
    80003104:	0009a503          	lw	a0,0(s3)
    80003108:	e33ff0ef          	jal	80002f3a <balloc>
    8000310c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003110:	fc090ee3          	beqz	s2,800030ec <bmap+0x92>
        a[bn] = addr;
    80003114:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003118:	8552                	mv	a0,s4
    8000311a:	50f000ef          	jal	80003e28 <log_write>
    8000311e:	b7f9                	j	800030ec <bmap+0x92>
    80003120:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003122:	00004517          	auipc	a0,0x4
    80003126:	37650513          	addi	a0,a0,886 # 80007498 <etext+0x498>
    8000312a:	e6afd0ef          	jal	80000794 <panic>

000000008000312e <iget>:
{
    8000312e:	7179                	addi	sp,sp,-48
    80003130:	f406                	sd	ra,40(sp)
    80003132:	f022                	sd	s0,32(sp)
    80003134:	ec26                	sd	s1,24(sp)
    80003136:	e84a                	sd	s2,16(sp)
    80003138:	e44e                	sd	s3,8(sp)
    8000313a:	e052                	sd	s4,0(sp)
    8000313c:	1800                	addi	s0,sp,48
    8000313e:	89aa                	mv	s3,a0
    80003140:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003142:	0001e517          	auipc	a0,0x1e
    80003146:	c3650513          	addi	a0,a0,-970 # 80020d78 <itable>
    8000314a:	aabfd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    8000314e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003150:	0001e497          	auipc	s1,0x1e
    80003154:	c4048493          	addi	s1,s1,-960 # 80020d90 <itable+0x18>
    80003158:	0001f697          	auipc	a3,0x1f
    8000315c:	6c868693          	addi	a3,a3,1736 # 80022820 <log>
    80003160:	a039                	j	8000316e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003162:	02090963          	beqz	s2,80003194 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003166:	08848493          	addi	s1,s1,136
    8000316a:	02d48863          	beq	s1,a3,8000319a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000316e:	449c                	lw	a5,8(s1)
    80003170:	fef059e3          	blez	a5,80003162 <iget+0x34>
    80003174:	4098                	lw	a4,0(s1)
    80003176:	ff3716e3          	bne	a4,s3,80003162 <iget+0x34>
    8000317a:	40d8                	lw	a4,4(s1)
    8000317c:	ff4713e3          	bne	a4,s4,80003162 <iget+0x34>
      ip->ref++;
    80003180:	2785                	addiw	a5,a5,1
    80003182:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003184:	0001e517          	auipc	a0,0x1e
    80003188:	bf450513          	addi	a0,a0,-1036 # 80020d78 <itable>
    8000318c:	b01fd0ef          	jal	80000c8c <release>
      return ip;
    80003190:	8926                	mv	s2,s1
    80003192:	a02d                	j	800031bc <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003194:	fbe9                	bnez	a5,80003166 <iget+0x38>
      empty = ip;
    80003196:	8926                	mv	s2,s1
    80003198:	b7f9                	j	80003166 <iget+0x38>
  if(empty == 0)
    8000319a:	02090a63          	beqz	s2,800031ce <iget+0xa0>
  ip->dev = dev;
    8000319e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031a2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031a6:	4785                	li	a5,1
    800031a8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031ac:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800031b0:	0001e517          	auipc	a0,0x1e
    800031b4:	bc850513          	addi	a0,a0,-1080 # 80020d78 <itable>
    800031b8:	ad5fd0ef          	jal	80000c8c <release>
}
    800031bc:	854a                	mv	a0,s2
    800031be:	70a2                	ld	ra,40(sp)
    800031c0:	7402                	ld	s0,32(sp)
    800031c2:	64e2                	ld	s1,24(sp)
    800031c4:	6942                	ld	s2,16(sp)
    800031c6:	69a2                	ld	s3,8(sp)
    800031c8:	6a02                	ld	s4,0(sp)
    800031ca:	6145                	addi	sp,sp,48
    800031cc:	8082                	ret
    panic("iget: no inodes");
    800031ce:	00004517          	auipc	a0,0x4
    800031d2:	2e250513          	addi	a0,a0,738 # 800074b0 <etext+0x4b0>
    800031d6:	dbefd0ef          	jal	80000794 <panic>

00000000800031da <fsinit>:
fsinit(int dev) {
    800031da:	7179                	addi	sp,sp,-48
    800031dc:	f406                	sd	ra,40(sp)
    800031de:	f022                	sd	s0,32(sp)
    800031e0:	ec26                	sd	s1,24(sp)
    800031e2:	e84a                	sd	s2,16(sp)
    800031e4:	e44e                	sd	s3,8(sp)
    800031e6:	1800                	addi	s0,sp,48
    800031e8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800031ea:	4585                	li	a1,1
    800031ec:	aebff0ef          	jal	80002cd6 <bread>
    800031f0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800031f2:	0001e997          	auipc	s3,0x1e
    800031f6:	b6698993          	addi	s3,s3,-1178 # 80020d58 <sb>
    800031fa:	02000613          	li	a2,32
    800031fe:	05850593          	addi	a1,a0,88
    80003202:	854e                	mv	a0,s3
    80003204:	b21fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003208:	8526                	mv	a0,s1
    8000320a:	bd5ff0ef          	jal	80002dde <brelse>
  if(sb.magic != FSMAGIC)
    8000320e:	0009a703          	lw	a4,0(s3)
    80003212:	102037b7          	lui	a5,0x10203
    80003216:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000321a:	02f71063          	bne	a4,a5,8000323a <fsinit+0x60>
  initlog(dev, &sb);
    8000321e:	0001e597          	auipc	a1,0x1e
    80003222:	b3a58593          	addi	a1,a1,-1222 # 80020d58 <sb>
    80003226:	854a                	mv	a0,s2
    80003228:	1f9000ef          	jal	80003c20 <initlog>
}
    8000322c:	70a2                	ld	ra,40(sp)
    8000322e:	7402                	ld	s0,32(sp)
    80003230:	64e2                	ld	s1,24(sp)
    80003232:	6942                	ld	s2,16(sp)
    80003234:	69a2                	ld	s3,8(sp)
    80003236:	6145                	addi	sp,sp,48
    80003238:	8082                	ret
    panic("invalid file system");
    8000323a:	00004517          	auipc	a0,0x4
    8000323e:	28650513          	addi	a0,a0,646 # 800074c0 <etext+0x4c0>
    80003242:	d52fd0ef          	jal	80000794 <panic>

0000000080003246 <iinit>:
{
    80003246:	7179                	addi	sp,sp,-48
    80003248:	f406                	sd	ra,40(sp)
    8000324a:	f022                	sd	s0,32(sp)
    8000324c:	ec26                	sd	s1,24(sp)
    8000324e:	e84a                	sd	s2,16(sp)
    80003250:	e44e                	sd	s3,8(sp)
    80003252:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003254:	00004597          	auipc	a1,0x4
    80003258:	28458593          	addi	a1,a1,644 # 800074d8 <etext+0x4d8>
    8000325c:	0001e517          	auipc	a0,0x1e
    80003260:	b1c50513          	addi	a0,a0,-1252 # 80020d78 <itable>
    80003264:	911fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003268:	0001e497          	auipc	s1,0x1e
    8000326c:	b3848493          	addi	s1,s1,-1224 # 80020da0 <itable+0x28>
    80003270:	0001f997          	auipc	s3,0x1f
    80003274:	5c098993          	addi	s3,s3,1472 # 80022830 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003278:	00004917          	auipc	s2,0x4
    8000327c:	26890913          	addi	s2,s2,616 # 800074e0 <etext+0x4e0>
    80003280:	85ca                	mv	a1,s2
    80003282:	8526                	mv	a0,s1
    80003284:	475000ef          	jal	80003ef8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003288:	08848493          	addi	s1,s1,136
    8000328c:	ff349ae3          	bne	s1,s3,80003280 <iinit+0x3a>
}
    80003290:	70a2                	ld	ra,40(sp)
    80003292:	7402                	ld	s0,32(sp)
    80003294:	64e2                	ld	s1,24(sp)
    80003296:	6942                	ld	s2,16(sp)
    80003298:	69a2                	ld	s3,8(sp)
    8000329a:	6145                	addi	sp,sp,48
    8000329c:	8082                	ret

000000008000329e <ialloc>:
{
    8000329e:	7139                	addi	sp,sp,-64
    800032a0:	fc06                	sd	ra,56(sp)
    800032a2:	f822                	sd	s0,48(sp)
    800032a4:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800032a6:	0001e717          	auipc	a4,0x1e
    800032aa:	abe72703          	lw	a4,-1346(a4) # 80020d64 <sb+0xc>
    800032ae:	4785                	li	a5,1
    800032b0:	06e7f063          	bgeu	a5,a4,80003310 <ialloc+0x72>
    800032b4:	f426                	sd	s1,40(sp)
    800032b6:	f04a                	sd	s2,32(sp)
    800032b8:	ec4e                	sd	s3,24(sp)
    800032ba:	e852                	sd	s4,16(sp)
    800032bc:	e456                	sd	s5,8(sp)
    800032be:	e05a                	sd	s6,0(sp)
    800032c0:	8aaa                	mv	s5,a0
    800032c2:	8b2e                	mv	s6,a1
    800032c4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800032c6:	0001ea17          	auipc	s4,0x1e
    800032ca:	a92a0a13          	addi	s4,s4,-1390 # 80020d58 <sb>
    800032ce:	00495593          	srli	a1,s2,0x4
    800032d2:	018a2783          	lw	a5,24(s4)
    800032d6:	9dbd                	addw	a1,a1,a5
    800032d8:	8556                	mv	a0,s5
    800032da:	9fdff0ef          	jal	80002cd6 <bread>
    800032de:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032e0:	05850993          	addi	s3,a0,88
    800032e4:	00f97793          	andi	a5,s2,15
    800032e8:	079a                	slli	a5,a5,0x6
    800032ea:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032ec:	00099783          	lh	a5,0(s3)
    800032f0:	cb9d                	beqz	a5,80003326 <ialloc+0x88>
    brelse(bp);
    800032f2:	aedff0ef          	jal	80002dde <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032f6:	0905                	addi	s2,s2,1
    800032f8:	00ca2703          	lw	a4,12(s4)
    800032fc:	0009079b          	sext.w	a5,s2
    80003300:	fce7e7e3          	bltu	a5,a4,800032ce <ialloc+0x30>
    80003304:	74a2                	ld	s1,40(sp)
    80003306:	7902                	ld	s2,32(sp)
    80003308:	69e2                	ld	s3,24(sp)
    8000330a:	6a42                	ld	s4,16(sp)
    8000330c:	6aa2                	ld	s5,8(sp)
    8000330e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003310:	00004517          	auipc	a0,0x4
    80003314:	1d850513          	addi	a0,a0,472 # 800074e8 <etext+0x4e8>
    80003318:	9aafd0ef          	jal	800004c2 <printf>
  return 0;
    8000331c:	4501                	li	a0,0
}
    8000331e:	70e2                	ld	ra,56(sp)
    80003320:	7442                	ld	s0,48(sp)
    80003322:	6121                	addi	sp,sp,64
    80003324:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003326:	04000613          	li	a2,64
    8000332a:	4581                	li	a1,0
    8000332c:	854e                	mv	a0,s3
    8000332e:	99bfd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003332:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003336:	8526                	mv	a0,s1
    80003338:	2f1000ef          	jal	80003e28 <log_write>
      brelse(bp);
    8000333c:	8526                	mv	a0,s1
    8000333e:	aa1ff0ef          	jal	80002dde <brelse>
      return iget(dev, inum);
    80003342:	0009059b          	sext.w	a1,s2
    80003346:	8556                	mv	a0,s5
    80003348:	de7ff0ef          	jal	8000312e <iget>
    8000334c:	74a2                	ld	s1,40(sp)
    8000334e:	7902                	ld	s2,32(sp)
    80003350:	69e2                	ld	s3,24(sp)
    80003352:	6a42                	ld	s4,16(sp)
    80003354:	6aa2                	ld	s5,8(sp)
    80003356:	6b02                	ld	s6,0(sp)
    80003358:	b7d9                	j	8000331e <ialloc+0x80>

000000008000335a <iupdate>:
{
    8000335a:	1101                	addi	sp,sp,-32
    8000335c:	ec06                	sd	ra,24(sp)
    8000335e:	e822                	sd	s0,16(sp)
    80003360:	e426                	sd	s1,8(sp)
    80003362:	e04a                	sd	s2,0(sp)
    80003364:	1000                	addi	s0,sp,32
    80003366:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003368:	415c                	lw	a5,4(a0)
    8000336a:	0047d79b          	srliw	a5,a5,0x4
    8000336e:	0001e597          	auipc	a1,0x1e
    80003372:	a025a583          	lw	a1,-1534(a1) # 80020d70 <sb+0x18>
    80003376:	9dbd                	addw	a1,a1,a5
    80003378:	4108                	lw	a0,0(a0)
    8000337a:	95dff0ef          	jal	80002cd6 <bread>
    8000337e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003380:	05850793          	addi	a5,a0,88
    80003384:	40d8                	lw	a4,4(s1)
    80003386:	8b3d                	andi	a4,a4,15
    80003388:	071a                	slli	a4,a4,0x6
    8000338a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000338c:	04449703          	lh	a4,68(s1)
    80003390:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003394:	04649703          	lh	a4,70(s1)
    80003398:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000339c:	04849703          	lh	a4,72(s1)
    800033a0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800033a4:	04a49703          	lh	a4,74(s1)
    800033a8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800033ac:	44f8                	lw	a4,76(s1)
    800033ae:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800033b0:	03400613          	li	a2,52
    800033b4:	05048593          	addi	a1,s1,80
    800033b8:	00c78513          	addi	a0,a5,12
    800033bc:	969fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	267000ef          	jal	80003e28 <log_write>
  brelse(bp);
    800033c6:	854a                	mv	a0,s2
    800033c8:	a17ff0ef          	jal	80002dde <brelse>
}
    800033cc:	60e2                	ld	ra,24(sp)
    800033ce:	6442                	ld	s0,16(sp)
    800033d0:	64a2                	ld	s1,8(sp)
    800033d2:	6902                	ld	s2,0(sp)
    800033d4:	6105                	addi	sp,sp,32
    800033d6:	8082                	ret

00000000800033d8 <idup>:
{
    800033d8:	1101                	addi	sp,sp,-32
    800033da:	ec06                	sd	ra,24(sp)
    800033dc:	e822                	sd	s0,16(sp)
    800033de:	e426                	sd	s1,8(sp)
    800033e0:	1000                	addi	s0,sp,32
    800033e2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033e4:	0001e517          	auipc	a0,0x1e
    800033e8:	99450513          	addi	a0,a0,-1644 # 80020d78 <itable>
    800033ec:	809fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800033f0:	449c                	lw	a5,8(s1)
    800033f2:	2785                	addiw	a5,a5,1
    800033f4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033f6:	0001e517          	auipc	a0,0x1e
    800033fa:	98250513          	addi	a0,a0,-1662 # 80020d78 <itable>
    800033fe:	88ffd0ef          	jal	80000c8c <release>
}
    80003402:	8526                	mv	a0,s1
    80003404:	60e2                	ld	ra,24(sp)
    80003406:	6442                	ld	s0,16(sp)
    80003408:	64a2                	ld	s1,8(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret

000000008000340e <ilock>:
{
    8000340e:	1101                	addi	sp,sp,-32
    80003410:	ec06                	sd	ra,24(sp)
    80003412:	e822                	sd	s0,16(sp)
    80003414:	e426                	sd	s1,8(sp)
    80003416:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003418:	cd19                	beqz	a0,80003436 <ilock+0x28>
    8000341a:	84aa                	mv	s1,a0
    8000341c:	451c                	lw	a5,8(a0)
    8000341e:	00f05c63          	blez	a5,80003436 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003422:	0541                	addi	a0,a0,16
    80003424:	30b000ef          	jal	80003f2e <acquiresleep>
  if(ip->valid == 0){
    80003428:	40bc                	lw	a5,64(s1)
    8000342a:	cf89                	beqz	a5,80003444 <ilock+0x36>
}
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret
    80003436:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003438:	00004517          	auipc	a0,0x4
    8000343c:	0c850513          	addi	a0,a0,200 # 80007500 <etext+0x500>
    80003440:	b54fd0ef          	jal	80000794 <panic>
    80003444:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003446:	40dc                	lw	a5,4(s1)
    80003448:	0047d79b          	srliw	a5,a5,0x4
    8000344c:	0001e597          	auipc	a1,0x1e
    80003450:	9245a583          	lw	a1,-1756(a1) # 80020d70 <sb+0x18>
    80003454:	9dbd                	addw	a1,a1,a5
    80003456:	4088                	lw	a0,0(s1)
    80003458:	87fff0ef          	jal	80002cd6 <bread>
    8000345c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000345e:	05850593          	addi	a1,a0,88
    80003462:	40dc                	lw	a5,4(s1)
    80003464:	8bbd                	andi	a5,a5,15
    80003466:	079a                	slli	a5,a5,0x6
    80003468:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000346a:	00059783          	lh	a5,0(a1)
    8000346e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003472:	00259783          	lh	a5,2(a1)
    80003476:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000347a:	00459783          	lh	a5,4(a1)
    8000347e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003482:	00659783          	lh	a5,6(a1)
    80003486:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000348a:	459c                	lw	a5,8(a1)
    8000348c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000348e:	03400613          	li	a2,52
    80003492:	05b1                	addi	a1,a1,12
    80003494:	05048513          	addi	a0,s1,80
    80003498:	88dfd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000349c:	854a                	mv	a0,s2
    8000349e:	941ff0ef          	jal	80002dde <brelse>
    ip->valid = 1;
    800034a2:	4785                	li	a5,1
    800034a4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800034a6:	04449783          	lh	a5,68(s1)
    800034aa:	c399                	beqz	a5,800034b0 <ilock+0xa2>
    800034ac:	6902                	ld	s2,0(sp)
    800034ae:	bfbd                	j	8000342c <ilock+0x1e>
      panic("ilock: no type");
    800034b0:	00004517          	auipc	a0,0x4
    800034b4:	05850513          	addi	a0,a0,88 # 80007508 <etext+0x508>
    800034b8:	adcfd0ef          	jal	80000794 <panic>

00000000800034bc <iunlock>:
{
    800034bc:	1101                	addi	sp,sp,-32
    800034be:	ec06                	sd	ra,24(sp)
    800034c0:	e822                	sd	s0,16(sp)
    800034c2:	e426                	sd	s1,8(sp)
    800034c4:	e04a                	sd	s2,0(sp)
    800034c6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034c8:	c505                	beqz	a0,800034f0 <iunlock+0x34>
    800034ca:	84aa                	mv	s1,a0
    800034cc:	01050913          	addi	s2,a0,16
    800034d0:	854a                	mv	a0,s2
    800034d2:	2db000ef          	jal	80003fac <holdingsleep>
    800034d6:	cd09                	beqz	a0,800034f0 <iunlock+0x34>
    800034d8:	449c                	lw	a5,8(s1)
    800034da:	00f05b63          	blez	a5,800034f0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800034de:	854a                	mv	a0,s2
    800034e0:	295000ef          	jal	80003f74 <releasesleep>
}
    800034e4:	60e2                	ld	ra,24(sp)
    800034e6:	6442                	ld	s0,16(sp)
    800034e8:	64a2                	ld	s1,8(sp)
    800034ea:	6902                	ld	s2,0(sp)
    800034ec:	6105                	addi	sp,sp,32
    800034ee:	8082                	ret
    panic("iunlock");
    800034f0:	00004517          	auipc	a0,0x4
    800034f4:	02850513          	addi	a0,a0,40 # 80007518 <etext+0x518>
    800034f8:	a9cfd0ef          	jal	80000794 <panic>

00000000800034fc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034fc:	7179                	addi	sp,sp,-48
    800034fe:	f406                	sd	ra,40(sp)
    80003500:	f022                	sd	s0,32(sp)
    80003502:	ec26                	sd	s1,24(sp)
    80003504:	e84a                	sd	s2,16(sp)
    80003506:	e44e                	sd	s3,8(sp)
    80003508:	1800                	addi	s0,sp,48
    8000350a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000350c:	05050493          	addi	s1,a0,80
    80003510:	08050913          	addi	s2,a0,128
    80003514:	a021                	j	8000351c <itrunc+0x20>
    80003516:	0491                	addi	s1,s1,4
    80003518:	01248b63          	beq	s1,s2,8000352e <itrunc+0x32>
    if(ip->addrs[i]){
    8000351c:	408c                	lw	a1,0(s1)
    8000351e:	dde5                	beqz	a1,80003516 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003520:	0009a503          	lw	a0,0(s3)
    80003524:	9abff0ef          	jal	80002ece <bfree>
      ip->addrs[i] = 0;
    80003528:	0004a023          	sw	zero,0(s1)
    8000352c:	b7ed                	j	80003516 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000352e:	0809a583          	lw	a1,128(s3)
    80003532:	ed89                	bnez	a1,8000354c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003534:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003538:	854e                	mv	a0,s3
    8000353a:	e21ff0ef          	jal	8000335a <iupdate>
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6942                	ld	s2,16(sp)
    80003546:	69a2                	ld	s3,8(sp)
    80003548:	6145                	addi	sp,sp,48
    8000354a:	8082                	ret
    8000354c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000354e:	0009a503          	lw	a0,0(s3)
    80003552:	f84ff0ef          	jal	80002cd6 <bread>
    80003556:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003558:	05850493          	addi	s1,a0,88
    8000355c:	45850913          	addi	s2,a0,1112
    80003560:	a021                	j	80003568 <itrunc+0x6c>
    80003562:	0491                	addi	s1,s1,4
    80003564:	01248963          	beq	s1,s2,80003576 <itrunc+0x7a>
      if(a[j])
    80003568:	408c                	lw	a1,0(s1)
    8000356a:	dde5                	beqz	a1,80003562 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000356c:	0009a503          	lw	a0,0(s3)
    80003570:	95fff0ef          	jal	80002ece <bfree>
    80003574:	b7fd                	j	80003562 <itrunc+0x66>
    brelse(bp);
    80003576:	8552                	mv	a0,s4
    80003578:	867ff0ef          	jal	80002dde <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000357c:	0809a583          	lw	a1,128(s3)
    80003580:	0009a503          	lw	a0,0(s3)
    80003584:	94bff0ef          	jal	80002ece <bfree>
    ip->addrs[NDIRECT] = 0;
    80003588:	0809a023          	sw	zero,128(s3)
    8000358c:	6a02                	ld	s4,0(sp)
    8000358e:	b75d                	j	80003534 <itrunc+0x38>

0000000080003590 <iput>:
{
    80003590:	1101                	addi	sp,sp,-32
    80003592:	ec06                	sd	ra,24(sp)
    80003594:	e822                	sd	s0,16(sp)
    80003596:	e426                	sd	s1,8(sp)
    80003598:	1000                	addi	s0,sp,32
    8000359a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000359c:	0001d517          	auipc	a0,0x1d
    800035a0:	7dc50513          	addi	a0,a0,2012 # 80020d78 <itable>
    800035a4:	e50fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035a8:	4498                	lw	a4,8(s1)
    800035aa:	4785                	li	a5,1
    800035ac:	02f70063          	beq	a4,a5,800035cc <iput+0x3c>
  ip->ref--;
    800035b0:	449c                	lw	a5,8(s1)
    800035b2:	37fd                	addiw	a5,a5,-1
    800035b4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800035b6:	0001d517          	auipc	a0,0x1d
    800035ba:	7c250513          	addi	a0,a0,1986 # 80020d78 <itable>
    800035be:	ecefd0ef          	jal	80000c8c <release>
}
    800035c2:	60e2                	ld	ra,24(sp)
    800035c4:	6442                	ld	s0,16(sp)
    800035c6:	64a2                	ld	s1,8(sp)
    800035c8:	6105                	addi	sp,sp,32
    800035ca:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035cc:	40bc                	lw	a5,64(s1)
    800035ce:	d3ed                	beqz	a5,800035b0 <iput+0x20>
    800035d0:	04a49783          	lh	a5,74(s1)
    800035d4:	fff1                	bnez	a5,800035b0 <iput+0x20>
    800035d6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800035d8:	01048913          	addi	s2,s1,16
    800035dc:	854a                	mv	a0,s2
    800035de:	151000ef          	jal	80003f2e <acquiresleep>
    release(&itable.lock);
    800035e2:	0001d517          	auipc	a0,0x1d
    800035e6:	79650513          	addi	a0,a0,1942 # 80020d78 <itable>
    800035ea:	ea2fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800035ee:	8526                	mv	a0,s1
    800035f0:	f0dff0ef          	jal	800034fc <itrunc>
    ip->type = 0;
    800035f4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035f8:	8526                	mv	a0,s1
    800035fa:	d61ff0ef          	jal	8000335a <iupdate>
    ip->valid = 0;
    800035fe:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003602:	854a                	mv	a0,s2
    80003604:	171000ef          	jal	80003f74 <releasesleep>
    acquire(&itable.lock);
    80003608:	0001d517          	auipc	a0,0x1d
    8000360c:	77050513          	addi	a0,a0,1904 # 80020d78 <itable>
    80003610:	de4fd0ef          	jal	80000bf4 <acquire>
    80003614:	6902                	ld	s2,0(sp)
    80003616:	bf69                	j	800035b0 <iput+0x20>

0000000080003618 <iunlockput>:
{
    80003618:	1101                	addi	sp,sp,-32
    8000361a:	ec06                	sd	ra,24(sp)
    8000361c:	e822                	sd	s0,16(sp)
    8000361e:	e426                	sd	s1,8(sp)
    80003620:	1000                	addi	s0,sp,32
    80003622:	84aa                	mv	s1,a0
  iunlock(ip);
    80003624:	e99ff0ef          	jal	800034bc <iunlock>
  iput(ip);
    80003628:	8526                	mv	a0,s1
    8000362a:	f67ff0ef          	jal	80003590 <iput>
}
    8000362e:	60e2                	ld	ra,24(sp)
    80003630:	6442                	ld	s0,16(sp)
    80003632:	64a2                	ld	s1,8(sp)
    80003634:	6105                	addi	sp,sp,32
    80003636:	8082                	ret

0000000080003638 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003638:	1141                	addi	sp,sp,-16
    8000363a:	e422                	sd	s0,8(sp)
    8000363c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000363e:	411c                	lw	a5,0(a0)
    80003640:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003642:	415c                	lw	a5,4(a0)
    80003644:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003646:	04451783          	lh	a5,68(a0)
    8000364a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000364e:	04a51783          	lh	a5,74(a0)
    80003652:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003656:	04c56783          	lwu	a5,76(a0)
    8000365a:	e99c                	sd	a5,16(a1)
}
    8000365c:	6422                	ld	s0,8(sp)
    8000365e:	0141                	addi	sp,sp,16
    80003660:	8082                	ret

0000000080003662 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003662:	457c                	lw	a5,76(a0)
    80003664:	0ed7eb63          	bltu	a5,a3,8000375a <readi+0xf8>
{
    80003668:	7159                	addi	sp,sp,-112
    8000366a:	f486                	sd	ra,104(sp)
    8000366c:	f0a2                	sd	s0,96(sp)
    8000366e:	eca6                	sd	s1,88(sp)
    80003670:	e0d2                	sd	s4,64(sp)
    80003672:	fc56                	sd	s5,56(sp)
    80003674:	f85a                	sd	s6,48(sp)
    80003676:	f45e                	sd	s7,40(sp)
    80003678:	1880                	addi	s0,sp,112
    8000367a:	8b2a                	mv	s6,a0
    8000367c:	8bae                	mv	s7,a1
    8000367e:	8a32                	mv	s4,a2
    80003680:	84b6                	mv	s1,a3
    80003682:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003684:	9f35                	addw	a4,a4,a3
    return 0;
    80003686:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003688:	0cd76063          	bltu	a4,a3,80003748 <readi+0xe6>
    8000368c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000368e:	00e7f463          	bgeu	a5,a4,80003696 <readi+0x34>
    n = ip->size - off;
    80003692:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003696:	080a8f63          	beqz	s5,80003734 <readi+0xd2>
    8000369a:	e8ca                	sd	s2,80(sp)
    8000369c:	f062                	sd	s8,32(sp)
    8000369e:	ec66                	sd	s9,24(sp)
    800036a0:	e86a                	sd	s10,16(sp)
    800036a2:	e46e                	sd	s11,8(sp)
    800036a4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036a6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036aa:	5c7d                	li	s8,-1
    800036ac:	a80d                	j	800036de <readi+0x7c>
    800036ae:	020d1d93          	slli	s11,s10,0x20
    800036b2:	020ddd93          	srli	s11,s11,0x20
    800036b6:	05890613          	addi	a2,s2,88
    800036ba:	86ee                	mv	a3,s11
    800036bc:	963a                	add	a2,a2,a4
    800036be:	85d2                	mv	a1,s4
    800036c0:	855e                	mv	a0,s7
    800036c2:	d97fe0ef          	jal	80002458 <either_copyout>
    800036c6:	05850763          	beq	a0,s8,80003714 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036ca:	854a                	mv	a0,s2
    800036cc:	f12ff0ef          	jal	80002dde <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036d0:	013d09bb          	addw	s3,s10,s3
    800036d4:	009d04bb          	addw	s1,s10,s1
    800036d8:	9a6e                	add	s4,s4,s11
    800036da:	0559f763          	bgeu	s3,s5,80003728 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800036de:	00a4d59b          	srliw	a1,s1,0xa
    800036e2:	855a                	mv	a0,s6
    800036e4:	977ff0ef          	jal	8000305a <bmap>
    800036e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036ec:	c5b1                	beqz	a1,80003738 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800036ee:	000b2503          	lw	a0,0(s6)
    800036f2:	de4ff0ef          	jal	80002cd6 <bread>
    800036f6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036f8:	3ff4f713          	andi	a4,s1,1023
    800036fc:	40ec87bb          	subw	a5,s9,a4
    80003700:	413a86bb          	subw	a3,s5,s3
    80003704:	8d3e                	mv	s10,a5
    80003706:	2781                	sext.w	a5,a5
    80003708:	0006861b          	sext.w	a2,a3
    8000370c:	faf671e3          	bgeu	a2,a5,800036ae <readi+0x4c>
    80003710:	8d36                	mv	s10,a3
    80003712:	bf71                	j	800036ae <readi+0x4c>
      brelse(bp);
    80003714:	854a                	mv	a0,s2
    80003716:	ec8ff0ef          	jal	80002dde <brelse>
      tot = -1;
    8000371a:	59fd                	li	s3,-1
      break;
    8000371c:	6946                	ld	s2,80(sp)
    8000371e:	7c02                	ld	s8,32(sp)
    80003720:	6ce2                	ld	s9,24(sp)
    80003722:	6d42                	ld	s10,16(sp)
    80003724:	6da2                	ld	s11,8(sp)
    80003726:	a831                	j	80003742 <readi+0xe0>
    80003728:	6946                	ld	s2,80(sp)
    8000372a:	7c02                	ld	s8,32(sp)
    8000372c:	6ce2                	ld	s9,24(sp)
    8000372e:	6d42                	ld	s10,16(sp)
    80003730:	6da2                	ld	s11,8(sp)
    80003732:	a801                	j	80003742 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003734:	89d6                	mv	s3,s5
    80003736:	a031                	j	80003742 <readi+0xe0>
    80003738:	6946                	ld	s2,80(sp)
    8000373a:	7c02                	ld	s8,32(sp)
    8000373c:	6ce2                	ld	s9,24(sp)
    8000373e:	6d42                	ld	s10,16(sp)
    80003740:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003742:	0009851b          	sext.w	a0,s3
    80003746:	69a6                	ld	s3,72(sp)
}
    80003748:	70a6                	ld	ra,104(sp)
    8000374a:	7406                	ld	s0,96(sp)
    8000374c:	64e6                	ld	s1,88(sp)
    8000374e:	6a06                	ld	s4,64(sp)
    80003750:	7ae2                	ld	s5,56(sp)
    80003752:	7b42                	ld	s6,48(sp)
    80003754:	7ba2                	ld	s7,40(sp)
    80003756:	6165                	addi	sp,sp,112
    80003758:	8082                	ret
    return 0;
    8000375a:	4501                	li	a0,0
}
    8000375c:	8082                	ret

000000008000375e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000375e:	457c                	lw	a5,76(a0)
    80003760:	10d7e063          	bltu	a5,a3,80003860 <writei+0x102>
{
    80003764:	7159                	addi	sp,sp,-112
    80003766:	f486                	sd	ra,104(sp)
    80003768:	f0a2                	sd	s0,96(sp)
    8000376a:	e8ca                	sd	s2,80(sp)
    8000376c:	e0d2                	sd	s4,64(sp)
    8000376e:	fc56                	sd	s5,56(sp)
    80003770:	f85a                	sd	s6,48(sp)
    80003772:	f45e                	sd	s7,40(sp)
    80003774:	1880                	addi	s0,sp,112
    80003776:	8aaa                	mv	s5,a0
    80003778:	8bae                	mv	s7,a1
    8000377a:	8a32                	mv	s4,a2
    8000377c:	8936                	mv	s2,a3
    8000377e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003780:	00e687bb          	addw	a5,a3,a4
    80003784:	0ed7e063          	bltu	a5,a3,80003864 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003788:	00043737          	lui	a4,0x43
    8000378c:	0cf76e63          	bltu	a4,a5,80003868 <writei+0x10a>
    80003790:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003792:	0a0b0f63          	beqz	s6,80003850 <writei+0xf2>
    80003796:	eca6                	sd	s1,88(sp)
    80003798:	f062                	sd	s8,32(sp)
    8000379a:	ec66                	sd	s9,24(sp)
    8000379c:	e86a                	sd	s10,16(sp)
    8000379e:	e46e                	sd	s11,8(sp)
    800037a0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037a2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037a6:	5c7d                	li	s8,-1
    800037a8:	a825                	j	800037e0 <writei+0x82>
    800037aa:	020d1d93          	slli	s11,s10,0x20
    800037ae:	020ddd93          	srli	s11,s11,0x20
    800037b2:	05848513          	addi	a0,s1,88
    800037b6:	86ee                	mv	a3,s11
    800037b8:	8652                	mv	a2,s4
    800037ba:	85de                	mv	a1,s7
    800037bc:	953a                	add	a0,a0,a4
    800037be:	ce5fe0ef          	jal	800024a2 <either_copyin>
    800037c2:	05850a63          	beq	a0,s8,80003816 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037c6:	8526                	mv	a0,s1
    800037c8:	660000ef          	jal	80003e28 <log_write>
    brelse(bp);
    800037cc:	8526                	mv	a0,s1
    800037ce:	e10ff0ef          	jal	80002dde <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037d2:	013d09bb          	addw	s3,s10,s3
    800037d6:	012d093b          	addw	s2,s10,s2
    800037da:	9a6e                	add	s4,s4,s11
    800037dc:	0569f063          	bgeu	s3,s6,8000381c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037e0:	00a9559b          	srliw	a1,s2,0xa
    800037e4:	8556                	mv	a0,s5
    800037e6:	875ff0ef          	jal	8000305a <bmap>
    800037ea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037ee:	c59d                	beqz	a1,8000381c <writei+0xbe>
    bp = bread(ip->dev, addr);
    800037f0:	000aa503          	lw	a0,0(s5)
    800037f4:	ce2ff0ef          	jal	80002cd6 <bread>
    800037f8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037fa:	3ff97713          	andi	a4,s2,1023
    800037fe:	40ec87bb          	subw	a5,s9,a4
    80003802:	413b06bb          	subw	a3,s6,s3
    80003806:	8d3e                	mv	s10,a5
    80003808:	2781                	sext.w	a5,a5
    8000380a:	0006861b          	sext.w	a2,a3
    8000380e:	f8f67ee3          	bgeu	a2,a5,800037aa <writei+0x4c>
    80003812:	8d36                	mv	s10,a3
    80003814:	bf59                	j	800037aa <writei+0x4c>
      brelse(bp);
    80003816:	8526                	mv	a0,s1
    80003818:	dc6ff0ef          	jal	80002dde <brelse>
  }

  if(off > ip->size)
    8000381c:	04caa783          	lw	a5,76(s5)
    80003820:	0327fa63          	bgeu	a5,s2,80003854 <writei+0xf6>
    ip->size = off;
    80003824:	052aa623          	sw	s2,76(s5)
    80003828:	64e6                	ld	s1,88(sp)
    8000382a:	7c02                	ld	s8,32(sp)
    8000382c:	6ce2                	ld	s9,24(sp)
    8000382e:	6d42                	ld	s10,16(sp)
    80003830:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003832:	8556                	mv	a0,s5
    80003834:	b27ff0ef          	jal	8000335a <iupdate>

  return tot;
    80003838:	0009851b          	sext.w	a0,s3
    8000383c:	69a6                	ld	s3,72(sp)
}
    8000383e:	70a6                	ld	ra,104(sp)
    80003840:	7406                	ld	s0,96(sp)
    80003842:	6946                	ld	s2,80(sp)
    80003844:	6a06                	ld	s4,64(sp)
    80003846:	7ae2                	ld	s5,56(sp)
    80003848:	7b42                	ld	s6,48(sp)
    8000384a:	7ba2                	ld	s7,40(sp)
    8000384c:	6165                	addi	sp,sp,112
    8000384e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003850:	89da                	mv	s3,s6
    80003852:	b7c5                	j	80003832 <writei+0xd4>
    80003854:	64e6                	ld	s1,88(sp)
    80003856:	7c02                	ld	s8,32(sp)
    80003858:	6ce2                	ld	s9,24(sp)
    8000385a:	6d42                	ld	s10,16(sp)
    8000385c:	6da2                	ld	s11,8(sp)
    8000385e:	bfd1                	j	80003832 <writei+0xd4>
    return -1;
    80003860:	557d                	li	a0,-1
}
    80003862:	8082                	ret
    return -1;
    80003864:	557d                	li	a0,-1
    80003866:	bfe1                	j	8000383e <writei+0xe0>
    return -1;
    80003868:	557d                	li	a0,-1
    8000386a:	bfd1                	j	8000383e <writei+0xe0>

000000008000386c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000386c:	1141                	addi	sp,sp,-16
    8000386e:	e406                	sd	ra,8(sp)
    80003870:	e022                	sd	s0,0(sp)
    80003872:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003874:	4639                	li	a2,14
    80003876:	d1efd0ef          	jal	80000d94 <strncmp>
}
    8000387a:	60a2                	ld	ra,8(sp)
    8000387c:	6402                	ld	s0,0(sp)
    8000387e:	0141                	addi	sp,sp,16
    80003880:	8082                	ret

0000000080003882 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003882:	7139                	addi	sp,sp,-64
    80003884:	fc06                	sd	ra,56(sp)
    80003886:	f822                	sd	s0,48(sp)
    80003888:	f426                	sd	s1,40(sp)
    8000388a:	f04a                	sd	s2,32(sp)
    8000388c:	ec4e                	sd	s3,24(sp)
    8000388e:	e852                	sd	s4,16(sp)
    80003890:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003892:	04451703          	lh	a4,68(a0)
    80003896:	4785                	li	a5,1
    80003898:	00f71a63          	bne	a4,a5,800038ac <dirlookup+0x2a>
    8000389c:	892a                	mv	s2,a0
    8000389e:	89ae                	mv	s3,a1
    800038a0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a2:	457c                	lw	a5,76(a0)
    800038a4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038a6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a8:	e39d                	bnez	a5,800038ce <dirlookup+0x4c>
    800038aa:	a095                	j	8000390e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800038ac:	00004517          	auipc	a0,0x4
    800038b0:	c7450513          	addi	a0,a0,-908 # 80007520 <etext+0x520>
    800038b4:	ee1fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800038b8:	00004517          	auipc	a0,0x4
    800038bc:	c8050513          	addi	a0,a0,-896 # 80007538 <etext+0x538>
    800038c0:	ed5fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c4:	24c1                	addiw	s1,s1,16
    800038c6:	04c92783          	lw	a5,76(s2)
    800038ca:	04f4f163          	bgeu	s1,a5,8000390c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ce:	4741                	li	a4,16
    800038d0:	86a6                	mv	a3,s1
    800038d2:	fc040613          	addi	a2,s0,-64
    800038d6:	4581                	li	a1,0
    800038d8:	854a                	mv	a0,s2
    800038da:	d89ff0ef          	jal	80003662 <readi>
    800038de:	47c1                	li	a5,16
    800038e0:	fcf51ce3          	bne	a0,a5,800038b8 <dirlookup+0x36>
    if(de.inum == 0)
    800038e4:	fc045783          	lhu	a5,-64(s0)
    800038e8:	dff1                	beqz	a5,800038c4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800038ea:	fc240593          	addi	a1,s0,-62
    800038ee:	854e                	mv	a0,s3
    800038f0:	f7dff0ef          	jal	8000386c <namecmp>
    800038f4:	f961                	bnez	a0,800038c4 <dirlookup+0x42>
      if(poff)
    800038f6:	000a0463          	beqz	s4,800038fe <dirlookup+0x7c>
        *poff = off;
    800038fa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800038fe:	fc045583          	lhu	a1,-64(s0)
    80003902:	00092503          	lw	a0,0(s2)
    80003906:	829ff0ef          	jal	8000312e <iget>
    8000390a:	a011                	j	8000390e <dirlookup+0x8c>
  return 0;
    8000390c:	4501                	li	a0,0
}
    8000390e:	70e2                	ld	ra,56(sp)
    80003910:	7442                	ld	s0,48(sp)
    80003912:	74a2                	ld	s1,40(sp)
    80003914:	7902                	ld	s2,32(sp)
    80003916:	69e2                	ld	s3,24(sp)
    80003918:	6a42                	ld	s4,16(sp)
    8000391a:	6121                	addi	sp,sp,64
    8000391c:	8082                	ret

000000008000391e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000391e:	711d                	addi	sp,sp,-96
    80003920:	ec86                	sd	ra,88(sp)
    80003922:	e8a2                	sd	s0,80(sp)
    80003924:	e4a6                	sd	s1,72(sp)
    80003926:	e0ca                	sd	s2,64(sp)
    80003928:	fc4e                	sd	s3,56(sp)
    8000392a:	f852                	sd	s4,48(sp)
    8000392c:	f456                	sd	s5,40(sp)
    8000392e:	f05a                	sd	s6,32(sp)
    80003930:	ec5e                	sd	s7,24(sp)
    80003932:	e862                	sd	s8,16(sp)
    80003934:	e466                	sd	s9,8(sp)
    80003936:	1080                	addi	s0,sp,96
    80003938:	84aa                	mv	s1,a0
    8000393a:	8b2e                	mv	s6,a1
    8000393c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000393e:	00054703          	lbu	a4,0(a0)
    80003942:	02f00793          	li	a5,47
    80003946:	00f70e63          	beq	a4,a5,80003962 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000394a:	f97fd0ef          	jal	800018e0 <myproc>
    8000394e:	15053503          	ld	a0,336(a0)
    80003952:	a87ff0ef          	jal	800033d8 <idup>
    80003956:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003958:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000395c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000395e:	4b85                	li	s7,1
    80003960:	a871                	j	800039fc <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003962:	4585                	li	a1,1
    80003964:	4505                	li	a0,1
    80003966:	fc8ff0ef          	jal	8000312e <iget>
    8000396a:	8a2a                	mv	s4,a0
    8000396c:	b7f5                	j	80003958 <namex+0x3a>
      iunlockput(ip);
    8000396e:	8552                	mv	a0,s4
    80003970:	ca9ff0ef          	jal	80003618 <iunlockput>
      return 0;
    80003974:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003976:	8552                	mv	a0,s4
    80003978:	60e6                	ld	ra,88(sp)
    8000397a:	6446                	ld	s0,80(sp)
    8000397c:	64a6                	ld	s1,72(sp)
    8000397e:	6906                	ld	s2,64(sp)
    80003980:	79e2                	ld	s3,56(sp)
    80003982:	7a42                	ld	s4,48(sp)
    80003984:	7aa2                	ld	s5,40(sp)
    80003986:	7b02                	ld	s6,32(sp)
    80003988:	6be2                	ld	s7,24(sp)
    8000398a:	6c42                	ld	s8,16(sp)
    8000398c:	6ca2                	ld	s9,8(sp)
    8000398e:	6125                	addi	sp,sp,96
    80003990:	8082                	ret
      iunlock(ip);
    80003992:	8552                	mv	a0,s4
    80003994:	b29ff0ef          	jal	800034bc <iunlock>
      return ip;
    80003998:	bff9                	j	80003976 <namex+0x58>
      iunlockput(ip);
    8000399a:	8552                	mv	a0,s4
    8000399c:	c7dff0ef          	jal	80003618 <iunlockput>
      return 0;
    800039a0:	8a4e                	mv	s4,s3
    800039a2:	bfd1                	j	80003976 <namex+0x58>
  len = path - s;
    800039a4:	40998633          	sub	a2,s3,s1
    800039a8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800039ac:	099c5063          	bge	s8,s9,80003a2c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800039b0:	4639                	li	a2,14
    800039b2:	85a6                	mv	a1,s1
    800039b4:	8556                	mv	a0,s5
    800039b6:	b6efd0ef          	jal	80000d24 <memmove>
    800039ba:	84ce                	mv	s1,s3
  while(*path == '/')
    800039bc:	0004c783          	lbu	a5,0(s1)
    800039c0:	01279763          	bne	a5,s2,800039ce <namex+0xb0>
    path++;
    800039c4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039c6:	0004c783          	lbu	a5,0(s1)
    800039ca:	ff278de3          	beq	a5,s2,800039c4 <namex+0xa6>
    ilock(ip);
    800039ce:	8552                	mv	a0,s4
    800039d0:	a3fff0ef          	jal	8000340e <ilock>
    if(ip->type != T_DIR){
    800039d4:	044a1783          	lh	a5,68(s4)
    800039d8:	f9779be3          	bne	a5,s7,8000396e <namex+0x50>
    if(nameiparent && *path == '\0'){
    800039dc:	000b0563          	beqz	s6,800039e6 <namex+0xc8>
    800039e0:	0004c783          	lbu	a5,0(s1)
    800039e4:	d7dd                	beqz	a5,80003992 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039e6:	4601                	li	a2,0
    800039e8:	85d6                	mv	a1,s5
    800039ea:	8552                	mv	a0,s4
    800039ec:	e97ff0ef          	jal	80003882 <dirlookup>
    800039f0:	89aa                	mv	s3,a0
    800039f2:	d545                	beqz	a0,8000399a <namex+0x7c>
    iunlockput(ip);
    800039f4:	8552                	mv	a0,s4
    800039f6:	c23ff0ef          	jal	80003618 <iunlockput>
    ip = next;
    800039fa:	8a4e                	mv	s4,s3
  while(*path == '/')
    800039fc:	0004c783          	lbu	a5,0(s1)
    80003a00:	01279763          	bne	a5,s2,80003a0e <namex+0xf0>
    path++;
    80003a04:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a06:	0004c783          	lbu	a5,0(s1)
    80003a0a:	ff278de3          	beq	a5,s2,80003a04 <namex+0xe6>
  if(*path == 0)
    80003a0e:	cb8d                	beqz	a5,80003a40 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003a10:	0004c783          	lbu	a5,0(s1)
    80003a14:	89a6                	mv	s3,s1
  len = path - s;
    80003a16:	4c81                	li	s9,0
    80003a18:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003a1a:	01278963          	beq	a5,s2,80003a2c <namex+0x10e>
    80003a1e:	d3d9                	beqz	a5,800039a4 <namex+0x86>
    path++;
    80003a20:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003a22:	0009c783          	lbu	a5,0(s3)
    80003a26:	ff279ce3          	bne	a5,s2,80003a1e <namex+0x100>
    80003a2a:	bfad                	j	800039a4 <namex+0x86>
    memmove(name, s, len);
    80003a2c:	2601                	sext.w	a2,a2
    80003a2e:	85a6                	mv	a1,s1
    80003a30:	8556                	mv	a0,s5
    80003a32:	af2fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003a36:	9cd6                	add	s9,s9,s5
    80003a38:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003a3c:	84ce                	mv	s1,s3
    80003a3e:	bfbd                	j	800039bc <namex+0x9e>
  if(nameiparent){
    80003a40:	f20b0be3          	beqz	s6,80003976 <namex+0x58>
    iput(ip);
    80003a44:	8552                	mv	a0,s4
    80003a46:	b4bff0ef          	jal	80003590 <iput>
    return 0;
    80003a4a:	4a01                	li	s4,0
    80003a4c:	b72d                	j	80003976 <namex+0x58>

0000000080003a4e <dirlink>:
{
    80003a4e:	7139                	addi	sp,sp,-64
    80003a50:	fc06                	sd	ra,56(sp)
    80003a52:	f822                	sd	s0,48(sp)
    80003a54:	f04a                	sd	s2,32(sp)
    80003a56:	ec4e                	sd	s3,24(sp)
    80003a58:	e852                	sd	s4,16(sp)
    80003a5a:	0080                	addi	s0,sp,64
    80003a5c:	892a                	mv	s2,a0
    80003a5e:	8a2e                	mv	s4,a1
    80003a60:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a62:	4601                	li	a2,0
    80003a64:	e1fff0ef          	jal	80003882 <dirlookup>
    80003a68:	e535                	bnez	a0,80003ad4 <dirlink+0x86>
    80003a6a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a6c:	04c92483          	lw	s1,76(s2)
    80003a70:	c48d                	beqz	s1,80003a9a <dirlink+0x4c>
    80003a72:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a74:	4741                	li	a4,16
    80003a76:	86a6                	mv	a3,s1
    80003a78:	fc040613          	addi	a2,s0,-64
    80003a7c:	4581                	li	a1,0
    80003a7e:	854a                	mv	a0,s2
    80003a80:	be3ff0ef          	jal	80003662 <readi>
    80003a84:	47c1                	li	a5,16
    80003a86:	04f51b63          	bne	a0,a5,80003adc <dirlink+0x8e>
    if(de.inum == 0)
    80003a8a:	fc045783          	lhu	a5,-64(s0)
    80003a8e:	c791                	beqz	a5,80003a9a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a90:	24c1                	addiw	s1,s1,16
    80003a92:	04c92783          	lw	a5,76(s2)
    80003a96:	fcf4efe3          	bltu	s1,a5,80003a74 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a9a:	4639                	li	a2,14
    80003a9c:	85d2                	mv	a1,s4
    80003a9e:	fc240513          	addi	a0,s0,-62
    80003aa2:	b28fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003aa6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aaa:	4741                	li	a4,16
    80003aac:	86a6                	mv	a3,s1
    80003aae:	fc040613          	addi	a2,s0,-64
    80003ab2:	4581                	li	a1,0
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	ca9ff0ef          	jal	8000375e <writei>
    80003aba:	1541                	addi	a0,a0,-16
    80003abc:	00a03533          	snez	a0,a0
    80003ac0:	40a00533          	neg	a0,a0
    80003ac4:	74a2                	ld	s1,40(sp)
}
    80003ac6:	70e2                	ld	ra,56(sp)
    80003ac8:	7442                	ld	s0,48(sp)
    80003aca:	7902                	ld	s2,32(sp)
    80003acc:	69e2                	ld	s3,24(sp)
    80003ace:	6a42                	ld	s4,16(sp)
    80003ad0:	6121                	addi	sp,sp,64
    80003ad2:	8082                	ret
    iput(ip);
    80003ad4:	abdff0ef          	jal	80003590 <iput>
    return -1;
    80003ad8:	557d                	li	a0,-1
    80003ada:	b7f5                	j	80003ac6 <dirlink+0x78>
      panic("dirlink read");
    80003adc:	00004517          	auipc	a0,0x4
    80003ae0:	a6c50513          	addi	a0,a0,-1428 # 80007548 <etext+0x548>
    80003ae4:	cb1fc0ef          	jal	80000794 <panic>

0000000080003ae8 <namei>:

struct inode*
namei(char *path)
{
    80003ae8:	1101                	addi	sp,sp,-32
    80003aea:	ec06                	sd	ra,24(sp)
    80003aec:	e822                	sd	s0,16(sp)
    80003aee:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003af0:	fe040613          	addi	a2,s0,-32
    80003af4:	4581                	li	a1,0
    80003af6:	e29ff0ef          	jal	8000391e <namex>
}
    80003afa:	60e2                	ld	ra,24(sp)
    80003afc:	6442                	ld	s0,16(sp)
    80003afe:	6105                	addi	sp,sp,32
    80003b00:	8082                	ret

0000000080003b02 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b02:	1141                	addi	sp,sp,-16
    80003b04:	e406                	sd	ra,8(sp)
    80003b06:	e022                	sd	s0,0(sp)
    80003b08:	0800                	addi	s0,sp,16
    80003b0a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b0c:	4585                	li	a1,1
    80003b0e:	e11ff0ef          	jal	8000391e <namex>
}
    80003b12:	60a2                	ld	ra,8(sp)
    80003b14:	6402                	ld	s0,0(sp)
    80003b16:	0141                	addi	sp,sp,16
    80003b18:	8082                	ret

0000000080003b1a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b1a:	1101                	addi	sp,sp,-32
    80003b1c:	ec06                	sd	ra,24(sp)
    80003b1e:	e822                	sd	s0,16(sp)
    80003b20:	e426                	sd	s1,8(sp)
    80003b22:	e04a                	sd	s2,0(sp)
    80003b24:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b26:	0001f917          	auipc	s2,0x1f
    80003b2a:	cfa90913          	addi	s2,s2,-774 # 80022820 <log>
    80003b2e:	01892583          	lw	a1,24(s2)
    80003b32:	02892503          	lw	a0,40(s2)
    80003b36:	9a0ff0ef          	jal	80002cd6 <bread>
    80003b3a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b3c:	02c92603          	lw	a2,44(s2)
    80003b40:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b42:	00c05f63          	blez	a2,80003b60 <write_head+0x46>
    80003b46:	0001f717          	auipc	a4,0x1f
    80003b4a:	d0a70713          	addi	a4,a4,-758 # 80022850 <log+0x30>
    80003b4e:	87aa                	mv	a5,a0
    80003b50:	060a                	slli	a2,a2,0x2
    80003b52:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b54:	4314                	lw	a3,0(a4)
    80003b56:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b58:	0711                	addi	a4,a4,4
    80003b5a:	0791                	addi	a5,a5,4
    80003b5c:	fec79ce3          	bne	a5,a2,80003b54 <write_head+0x3a>
  }
  bwrite(buf);
    80003b60:	8526                	mv	a0,s1
    80003b62:	a4aff0ef          	jal	80002dac <bwrite>
  brelse(buf);
    80003b66:	8526                	mv	a0,s1
    80003b68:	a76ff0ef          	jal	80002dde <brelse>
}
    80003b6c:	60e2                	ld	ra,24(sp)
    80003b6e:	6442                	ld	s0,16(sp)
    80003b70:	64a2                	ld	s1,8(sp)
    80003b72:	6902                	ld	s2,0(sp)
    80003b74:	6105                	addi	sp,sp,32
    80003b76:	8082                	ret

0000000080003b78 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b78:	0001f797          	auipc	a5,0x1f
    80003b7c:	cd47a783          	lw	a5,-812(a5) # 8002284c <log+0x2c>
    80003b80:	08f05f63          	blez	a5,80003c1e <install_trans+0xa6>
{
    80003b84:	7139                	addi	sp,sp,-64
    80003b86:	fc06                	sd	ra,56(sp)
    80003b88:	f822                	sd	s0,48(sp)
    80003b8a:	f426                	sd	s1,40(sp)
    80003b8c:	f04a                	sd	s2,32(sp)
    80003b8e:	ec4e                	sd	s3,24(sp)
    80003b90:	e852                	sd	s4,16(sp)
    80003b92:	e456                	sd	s5,8(sp)
    80003b94:	e05a                	sd	s6,0(sp)
    80003b96:	0080                	addi	s0,sp,64
    80003b98:	8b2a                	mv	s6,a0
    80003b9a:	0001fa97          	auipc	s5,0x1f
    80003b9e:	cb6a8a93          	addi	s5,s5,-842 # 80022850 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ba4:	0001f997          	auipc	s3,0x1f
    80003ba8:	c7c98993          	addi	s3,s3,-900 # 80022820 <log>
    80003bac:	a829                	j	80003bc6 <install_trans+0x4e>
    brelse(lbuf);
    80003bae:	854a                	mv	a0,s2
    80003bb0:	a2eff0ef          	jal	80002dde <brelse>
    brelse(dbuf);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	a28ff0ef          	jal	80002dde <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bba:	2a05                	addiw	s4,s4,1
    80003bbc:	0a91                	addi	s5,s5,4
    80003bbe:	02c9a783          	lw	a5,44(s3)
    80003bc2:	04fa5463          	bge	s4,a5,80003c0a <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bc6:	0189a583          	lw	a1,24(s3)
    80003bca:	014585bb          	addw	a1,a1,s4
    80003bce:	2585                	addiw	a1,a1,1
    80003bd0:	0289a503          	lw	a0,40(s3)
    80003bd4:	902ff0ef          	jal	80002cd6 <bread>
    80003bd8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bda:	000aa583          	lw	a1,0(s5)
    80003bde:	0289a503          	lw	a0,40(s3)
    80003be2:	8f4ff0ef          	jal	80002cd6 <bread>
    80003be6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003be8:	40000613          	li	a2,1024
    80003bec:	05890593          	addi	a1,s2,88
    80003bf0:	05850513          	addi	a0,a0,88
    80003bf4:	930fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	9b2ff0ef          	jal	80002dac <bwrite>
    if(recovering == 0)
    80003bfe:	fa0b18e3          	bnez	s6,80003bae <install_trans+0x36>
      bunpin(dbuf);
    80003c02:	8526                	mv	a0,s1
    80003c04:	a96ff0ef          	jal	80002e9a <bunpin>
    80003c08:	b75d                	j	80003bae <install_trans+0x36>
}
    80003c0a:	70e2                	ld	ra,56(sp)
    80003c0c:	7442                	ld	s0,48(sp)
    80003c0e:	74a2                	ld	s1,40(sp)
    80003c10:	7902                	ld	s2,32(sp)
    80003c12:	69e2                	ld	s3,24(sp)
    80003c14:	6a42                	ld	s4,16(sp)
    80003c16:	6aa2                	ld	s5,8(sp)
    80003c18:	6b02                	ld	s6,0(sp)
    80003c1a:	6121                	addi	sp,sp,64
    80003c1c:	8082                	ret
    80003c1e:	8082                	ret

0000000080003c20 <initlog>:
{
    80003c20:	7179                	addi	sp,sp,-48
    80003c22:	f406                	sd	ra,40(sp)
    80003c24:	f022                	sd	s0,32(sp)
    80003c26:	ec26                	sd	s1,24(sp)
    80003c28:	e84a                	sd	s2,16(sp)
    80003c2a:	e44e                	sd	s3,8(sp)
    80003c2c:	1800                	addi	s0,sp,48
    80003c2e:	892a                	mv	s2,a0
    80003c30:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c32:	0001f497          	auipc	s1,0x1f
    80003c36:	bee48493          	addi	s1,s1,-1042 # 80022820 <log>
    80003c3a:	00004597          	auipc	a1,0x4
    80003c3e:	91e58593          	addi	a1,a1,-1762 # 80007558 <etext+0x558>
    80003c42:	8526                	mv	a0,s1
    80003c44:	f31fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003c48:	0149a583          	lw	a1,20(s3)
    80003c4c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003c4e:	0109a783          	lw	a5,16(s3)
    80003c52:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003c54:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c58:	854a                	mv	a0,s2
    80003c5a:	87cff0ef          	jal	80002cd6 <bread>
  log.lh.n = lh->n;
    80003c5e:	4d30                	lw	a2,88(a0)
    80003c60:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c62:	00c05f63          	blez	a2,80003c80 <initlog+0x60>
    80003c66:	87aa                	mv	a5,a0
    80003c68:	0001f717          	auipc	a4,0x1f
    80003c6c:	be870713          	addi	a4,a4,-1048 # 80022850 <log+0x30>
    80003c70:	060a                	slli	a2,a2,0x2
    80003c72:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c74:	4ff4                	lw	a3,92(a5)
    80003c76:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c78:	0791                	addi	a5,a5,4
    80003c7a:	0711                	addi	a4,a4,4
    80003c7c:	fec79ce3          	bne	a5,a2,80003c74 <initlog+0x54>
  brelse(buf);
    80003c80:	95eff0ef          	jal	80002dde <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c84:	4505                	li	a0,1
    80003c86:	ef3ff0ef          	jal	80003b78 <install_trans>
  log.lh.n = 0;
    80003c8a:	0001f797          	auipc	a5,0x1f
    80003c8e:	bc07a123          	sw	zero,-1086(a5) # 8002284c <log+0x2c>
  write_head(); // clear the log
    80003c92:	e89ff0ef          	jal	80003b1a <write_head>
}
    80003c96:	70a2                	ld	ra,40(sp)
    80003c98:	7402                	ld	s0,32(sp)
    80003c9a:	64e2                	ld	s1,24(sp)
    80003c9c:	6942                	ld	s2,16(sp)
    80003c9e:	69a2                	ld	s3,8(sp)
    80003ca0:	6145                	addi	sp,sp,48
    80003ca2:	8082                	ret

0000000080003ca4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ca4:	1101                	addi	sp,sp,-32
    80003ca6:	ec06                	sd	ra,24(sp)
    80003ca8:	e822                	sd	s0,16(sp)
    80003caa:	e426                	sd	s1,8(sp)
    80003cac:	e04a                	sd	s2,0(sp)
    80003cae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cb0:	0001f517          	auipc	a0,0x1f
    80003cb4:	b7050513          	addi	a0,a0,-1168 # 80022820 <log>
    80003cb8:	f3dfc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003cbc:	0001f497          	auipc	s1,0x1f
    80003cc0:	b6448493          	addi	s1,s1,-1180 # 80022820 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003cc4:	4979                	li	s2,30
    80003cc6:	a029                	j	80003cd0 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cc8:	85a6                	mv	a1,s1
    80003cca:	8526                	mv	a0,s1
    80003ccc:	c30fe0ef          	jal	800020fc <sleep>
    if(log.committing){
    80003cd0:	50dc                	lw	a5,36(s1)
    80003cd2:	fbfd                	bnez	a5,80003cc8 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003cd4:	5098                	lw	a4,32(s1)
    80003cd6:	2705                	addiw	a4,a4,1
    80003cd8:	0027179b          	slliw	a5,a4,0x2
    80003cdc:	9fb9                	addw	a5,a5,a4
    80003cde:	0017979b          	slliw	a5,a5,0x1
    80003ce2:	54d4                	lw	a3,44(s1)
    80003ce4:	9fb5                	addw	a5,a5,a3
    80003ce6:	00f95763          	bge	s2,a5,80003cf4 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cea:	85a6                	mv	a1,s1
    80003cec:	8526                	mv	a0,s1
    80003cee:	c0efe0ef          	jal	800020fc <sleep>
    80003cf2:	bff9                	j	80003cd0 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003cf4:	0001f517          	auipc	a0,0x1f
    80003cf8:	b2c50513          	addi	a0,a0,-1236 # 80022820 <log>
    80003cfc:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003cfe:	f8ffc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003d02:	60e2                	ld	ra,24(sp)
    80003d04:	6442                	ld	s0,16(sp)
    80003d06:	64a2                	ld	s1,8(sp)
    80003d08:	6902                	ld	s2,0(sp)
    80003d0a:	6105                	addi	sp,sp,32
    80003d0c:	8082                	ret

0000000080003d0e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d0e:	7139                	addi	sp,sp,-64
    80003d10:	fc06                	sd	ra,56(sp)
    80003d12:	f822                	sd	s0,48(sp)
    80003d14:	f426                	sd	s1,40(sp)
    80003d16:	f04a                	sd	s2,32(sp)
    80003d18:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d1a:	0001f497          	auipc	s1,0x1f
    80003d1e:	b0648493          	addi	s1,s1,-1274 # 80022820 <log>
    80003d22:	8526                	mv	a0,s1
    80003d24:	ed1fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003d28:	509c                	lw	a5,32(s1)
    80003d2a:	37fd                	addiw	a5,a5,-1
    80003d2c:	0007891b          	sext.w	s2,a5
    80003d30:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003d32:	50dc                	lw	a5,36(s1)
    80003d34:	ef9d                	bnez	a5,80003d72 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d36:	04091763          	bnez	s2,80003d84 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d3a:	0001f497          	auipc	s1,0x1f
    80003d3e:	ae648493          	addi	s1,s1,-1306 # 80022820 <log>
    80003d42:	4785                	li	a5,1
    80003d44:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d46:	8526                	mv	a0,s1
    80003d48:	f45fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d4c:	54dc                	lw	a5,44(s1)
    80003d4e:	04f04b63          	bgtz	a5,80003da4 <end_op+0x96>
    acquire(&log.lock);
    80003d52:	0001f497          	auipc	s1,0x1f
    80003d56:	ace48493          	addi	s1,s1,-1330 # 80022820 <log>
    80003d5a:	8526                	mv	a0,s1
    80003d5c:	e99fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003d60:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003d64:	8526                	mv	a0,s1
    80003d66:	be2fe0ef          	jal	80002148 <wakeup>
    release(&log.lock);
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	f21fc0ef          	jal	80000c8c <release>
}
    80003d70:	a025                	j	80003d98 <end_op+0x8a>
    80003d72:	ec4e                	sd	s3,24(sp)
    80003d74:	e852                	sd	s4,16(sp)
    80003d76:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d78:	00003517          	auipc	a0,0x3
    80003d7c:	7e850513          	addi	a0,a0,2024 # 80007560 <etext+0x560>
    80003d80:	a15fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003d84:	0001f497          	auipc	s1,0x1f
    80003d88:	a9c48493          	addi	s1,s1,-1380 # 80022820 <log>
    80003d8c:	8526                	mv	a0,s1
    80003d8e:	bbafe0ef          	jal	80002148 <wakeup>
  release(&log.lock);
    80003d92:	8526                	mv	a0,s1
    80003d94:	ef9fc0ef          	jal	80000c8c <release>
}
    80003d98:	70e2                	ld	ra,56(sp)
    80003d9a:	7442                	ld	s0,48(sp)
    80003d9c:	74a2                	ld	s1,40(sp)
    80003d9e:	7902                	ld	s2,32(sp)
    80003da0:	6121                	addi	sp,sp,64
    80003da2:	8082                	ret
    80003da4:	ec4e                	sd	s3,24(sp)
    80003da6:	e852                	sd	s4,16(sp)
    80003da8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003daa:	0001fa97          	auipc	s5,0x1f
    80003dae:	aa6a8a93          	addi	s5,s5,-1370 # 80022850 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003db2:	0001fa17          	auipc	s4,0x1f
    80003db6:	a6ea0a13          	addi	s4,s4,-1426 # 80022820 <log>
    80003dba:	018a2583          	lw	a1,24(s4)
    80003dbe:	012585bb          	addw	a1,a1,s2
    80003dc2:	2585                	addiw	a1,a1,1
    80003dc4:	028a2503          	lw	a0,40(s4)
    80003dc8:	f0ffe0ef          	jal	80002cd6 <bread>
    80003dcc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003dce:	000aa583          	lw	a1,0(s5)
    80003dd2:	028a2503          	lw	a0,40(s4)
    80003dd6:	f01fe0ef          	jal	80002cd6 <bread>
    80003dda:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ddc:	40000613          	li	a2,1024
    80003de0:	05850593          	addi	a1,a0,88
    80003de4:	05848513          	addi	a0,s1,88
    80003de8:	f3dfc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003dec:	8526                	mv	a0,s1
    80003dee:	fbffe0ef          	jal	80002dac <bwrite>
    brelse(from);
    80003df2:	854e                	mv	a0,s3
    80003df4:	febfe0ef          	jal	80002dde <brelse>
    brelse(to);
    80003df8:	8526                	mv	a0,s1
    80003dfa:	fe5fe0ef          	jal	80002dde <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dfe:	2905                	addiw	s2,s2,1
    80003e00:	0a91                	addi	s5,s5,4
    80003e02:	02ca2783          	lw	a5,44(s4)
    80003e06:	faf94ae3          	blt	s2,a5,80003dba <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e0a:	d11ff0ef          	jal	80003b1a <write_head>
    install_trans(0); // Now install writes to home locations
    80003e0e:	4501                	li	a0,0
    80003e10:	d69ff0ef          	jal	80003b78 <install_trans>
    log.lh.n = 0;
    80003e14:	0001f797          	auipc	a5,0x1f
    80003e18:	a207ac23          	sw	zero,-1480(a5) # 8002284c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003e1c:	cffff0ef          	jal	80003b1a <write_head>
    80003e20:	69e2                	ld	s3,24(sp)
    80003e22:	6a42                	ld	s4,16(sp)
    80003e24:	6aa2                	ld	s5,8(sp)
    80003e26:	b735                	j	80003d52 <end_op+0x44>

0000000080003e28 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e28:	1101                	addi	sp,sp,-32
    80003e2a:	ec06                	sd	ra,24(sp)
    80003e2c:	e822                	sd	s0,16(sp)
    80003e2e:	e426                	sd	s1,8(sp)
    80003e30:	e04a                	sd	s2,0(sp)
    80003e32:	1000                	addi	s0,sp,32
    80003e34:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e36:	0001f917          	auipc	s2,0x1f
    80003e3a:	9ea90913          	addi	s2,s2,-1558 # 80022820 <log>
    80003e3e:	854a                	mv	a0,s2
    80003e40:	db5fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003e44:	02c92603          	lw	a2,44(s2)
    80003e48:	47f5                	li	a5,29
    80003e4a:	06c7c363          	blt	a5,a2,80003eb0 <log_write+0x88>
    80003e4e:	0001f797          	auipc	a5,0x1f
    80003e52:	9ee7a783          	lw	a5,-1554(a5) # 8002283c <log+0x1c>
    80003e56:	37fd                	addiw	a5,a5,-1
    80003e58:	04f65c63          	bge	a2,a5,80003eb0 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e5c:	0001f797          	auipc	a5,0x1f
    80003e60:	9e47a783          	lw	a5,-1564(a5) # 80022840 <log+0x20>
    80003e64:	04f05c63          	blez	a5,80003ebc <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e68:	4781                	li	a5,0
    80003e6a:	04c05f63          	blez	a2,80003ec8 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e6e:	44cc                	lw	a1,12(s1)
    80003e70:	0001f717          	auipc	a4,0x1f
    80003e74:	9e070713          	addi	a4,a4,-1568 # 80022850 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003e78:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e7a:	4314                	lw	a3,0(a4)
    80003e7c:	04b68663          	beq	a3,a1,80003ec8 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003e80:	2785                	addiw	a5,a5,1
    80003e82:	0711                	addi	a4,a4,4
    80003e84:	fef61be3          	bne	a2,a5,80003e7a <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e88:	0621                	addi	a2,a2,8
    80003e8a:	060a                	slli	a2,a2,0x2
    80003e8c:	0001f797          	auipc	a5,0x1f
    80003e90:	99478793          	addi	a5,a5,-1644 # 80022820 <log>
    80003e94:	97b2                	add	a5,a5,a2
    80003e96:	44d8                	lw	a4,12(s1)
    80003e98:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e9a:	8526                	mv	a0,s1
    80003e9c:	fcbfe0ef          	jal	80002e66 <bpin>
    log.lh.n++;
    80003ea0:	0001f717          	auipc	a4,0x1f
    80003ea4:	98070713          	addi	a4,a4,-1664 # 80022820 <log>
    80003ea8:	575c                	lw	a5,44(a4)
    80003eaa:	2785                	addiw	a5,a5,1
    80003eac:	d75c                	sw	a5,44(a4)
    80003eae:	a80d                	j	80003ee0 <log_write+0xb8>
    panic("too big a transaction");
    80003eb0:	00003517          	auipc	a0,0x3
    80003eb4:	6c050513          	addi	a0,a0,1728 # 80007570 <etext+0x570>
    80003eb8:	8ddfc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003ebc:	00003517          	auipc	a0,0x3
    80003ec0:	6cc50513          	addi	a0,a0,1740 # 80007588 <etext+0x588>
    80003ec4:	8d1fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003ec8:	00878693          	addi	a3,a5,8
    80003ecc:	068a                	slli	a3,a3,0x2
    80003ece:	0001f717          	auipc	a4,0x1f
    80003ed2:	95270713          	addi	a4,a4,-1710 # 80022820 <log>
    80003ed6:	9736                	add	a4,a4,a3
    80003ed8:	44d4                	lw	a3,12(s1)
    80003eda:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003edc:	faf60fe3          	beq	a2,a5,80003e9a <log_write+0x72>
  }
  release(&log.lock);
    80003ee0:	0001f517          	auipc	a0,0x1f
    80003ee4:	94050513          	addi	a0,a0,-1728 # 80022820 <log>
    80003ee8:	da5fc0ef          	jal	80000c8c <release>
}
    80003eec:	60e2                	ld	ra,24(sp)
    80003eee:	6442                	ld	s0,16(sp)
    80003ef0:	64a2                	ld	s1,8(sp)
    80003ef2:	6902                	ld	s2,0(sp)
    80003ef4:	6105                	addi	sp,sp,32
    80003ef6:	8082                	ret

0000000080003ef8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ef8:	1101                	addi	sp,sp,-32
    80003efa:	ec06                	sd	ra,24(sp)
    80003efc:	e822                	sd	s0,16(sp)
    80003efe:	e426                	sd	s1,8(sp)
    80003f00:	e04a                	sd	s2,0(sp)
    80003f02:	1000                	addi	s0,sp,32
    80003f04:	84aa                	mv	s1,a0
    80003f06:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f08:	00003597          	auipc	a1,0x3
    80003f0c:	6a058593          	addi	a1,a1,1696 # 800075a8 <etext+0x5a8>
    80003f10:	0521                	addi	a0,a0,8
    80003f12:	c63fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003f16:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f1a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f1e:	0204a423          	sw	zero,40(s1)
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6902                	ld	s2,0(sp)
    80003f2a:	6105                	addi	sp,sp,32
    80003f2c:	8082                	ret

0000000080003f2e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f2e:	1101                	addi	sp,sp,-32
    80003f30:	ec06                	sd	ra,24(sp)
    80003f32:	e822                	sd	s0,16(sp)
    80003f34:	e426                	sd	s1,8(sp)
    80003f36:	e04a                	sd	s2,0(sp)
    80003f38:	1000                	addi	s0,sp,32
    80003f3a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f3c:	00850913          	addi	s2,a0,8
    80003f40:	854a                	mv	a0,s2
    80003f42:	cb3fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003f46:	409c                	lw	a5,0(s1)
    80003f48:	c799                	beqz	a5,80003f56 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f4a:	85ca                	mv	a1,s2
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	9aefe0ef          	jal	800020fc <sleep>
  while (lk->locked) {
    80003f52:	409c                	lw	a5,0(s1)
    80003f54:	fbfd                	bnez	a5,80003f4a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f56:	4785                	li	a5,1
    80003f58:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f5a:	987fd0ef          	jal	800018e0 <myproc>
    80003f5e:	591c                	lw	a5,48(a0)
    80003f60:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f62:	854a                	mv	a0,s2
    80003f64:	d29fc0ef          	jal	80000c8c <release>
}
    80003f68:	60e2                	ld	ra,24(sp)
    80003f6a:	6442                	ld	s0,16(sp)
    80003f6c:	64a2                	ld	s1,8(sp)
    80003f6e:	6902                	ld	s2,0(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret

0000000080003f74 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f74:	1101                	addi	sp,sp,-32
    80003f76:	ec06                	sd	ra,24(sp)
    80003f78:	e822                	sd	s0,16(sp)
    80003f7a:	e426                	sd	s1,8(sp)
    80003f7c:	e04a                	sd	s2,0(sp)
    80003f7e:	1000                	addi	s0,sp,32
    80003f80:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f82:	00850913          	addi	s2,a0,8
    80003f86:	854a                	mv	a0,s2
    80003f88:	c6dfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003f8c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f90:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f94:	8526                	mv	a0,s1
    80003f96:	9b2fe0ef          	jal	80002148 <wakeup>
  release(&lk->lk);
    80003f9a:	854a                	mv	a0,s2
    80003f9c:	cf1fc0ef          	jal	80000c8c <release>
}
    80003fa0:	60e2                	ld	ra,24(sp)
    80003fa2:	6442                	ld	s0,16(sp)
    80003fa4:	64a2                	ld	s1,8(sp)
    80003fa6:	6902                	ld	s2,0(sp)
    80003fa8:	6105                	addi	sp,sp,32
    80003faa:	8082                	ret

0000000080003fac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fac:	7179                	addi	sp,sp,-48
    80003fae:	f406                	sd	ra,40(sp)
    80003fb0:	f022                	sd	s0,32(sp)
    80003fb2:	ec26                	sd	s1,24(sp)
    80003fb4:	e84a                	sd	s2,16(sp)
    80003fb6:	1800                	addi	s0,sp,48
    80003fb8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fba:	00850913          	addi	s2,a0,8
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	c35fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fc4:	409c                	lw	a5,0(s1)
    80003fc6:	ef81                	bnez	a5,80003fde <holdingsleep+0x32>
    80003fc8:	4481                	li	s1,0
  release(&lk->lk);
    80003fca:	854a                	mv	a0,s2
    80003fcc:	cc1fc0ef          	jal	80000c8c <release>
  return r;
}
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	70a2                	ld	ra,40(sp)
    80003fd4:	7402                	ld	s0,32(sp)
    80003fd6:	64e2                	ld	s1,24(sp)
    80003fd8:	6942                	ld	s2,16(sp)
    80003fda:	6145                	addi	sp,sp,48
    80003fdc:	8082                	ret
    80003fde:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fe0:	0284a983          	lw	s3,40(s1)
    80003fe4:	8fdfd0ef          	jal	800018e0 <myproc>
    80003fe8:	5904                	lw	s1,48(a0)
    80003fea:	413484b3          	sub	s1,s1,s3
    80003fee:	0014b493          	seqz	s1,s1
    80003ff2:	69a2                	ld	s3,8(sp)
    80003ff4:	bfd9                	j	80003fca <holdingsleep+0x1e>

0000000080003ff6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ff6:	1141                	addi	sp,sp,-16
    80003ff8:	e406                	sd	ra,8(sp)
    80003ffa:	e022                	sd	s0,0(sp)
    80003ffc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ffe:	00003597          	auipc	a1,0x3
    80004002:	5ba58593          	addi	a1,a1,1466 # 800075b8 <etext+0x5b8>
    80004006:	0001f517          	auipc	a0,0x1f
    8000400a:	96250513          	addi	a0,a0,-1694 # 80022968 <ftable>
    8000400e:	b67fc0ef          	jal	80000b74 <initlock>
}
    80004012:	60a2                	ld	ra,8(sp)
    80004014:	6402                	ld	s0,0(sp)
    80004016:	0141                	addi	sp,sp,16
    80004018:	8082                	ret

000000008000401a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000401a:	1101                	addi	sp,sp,-32
    8000401c:	ec06                	sd	ra,24(sp)
    8000401e:	e822                	sd	s0,16(sp)
    80004020:	e426                	sd	s1,8(sp)
    80004022:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004024:	0001f517          	auipc	a0,0x1f
    80004028:	94450513          	addi	a0,a0,-1724 # 80022968 <ftable>
    8000402c:	bc9fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004030:	0001f497          	auipc	s1,0x1f
    80004034:	95048493          	addi	s1,s1,-1712 # 80022980 <ftable+0x18>
    80004038:	00020717          	auipc	a4,0x20
    8000403c:	8e870713          	addi	a4,a4,-1816 # 80023920 <disk>
    if(f->ref == 0){
    80004040:	40dc                	lw	a5,4(s1)
    80004042:	cf89                	beqz	a5,8000405c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004044:	02848493          	addi	s1,s1,40
    80004048:	fee49ce3          	bne	s1,a4,80004040 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000404c:	0001f517          	auipc	a0,0x1f
    80004050:	91c50513          	addi	a0,a0,-1764 # 80022968 <ftable>
    80004054:	c39fc0ef          	jal	80000c8c <release>
  return 0;
    80004058:	4481                	li	s1,0
    8000405a:	a809                	j	8000406c <filealloc+0x52>
      f->ref = 1;
    8000405c:	4785                	li	a5,1
    8000405e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004060:	0001f517          	auipc	a0,0x1f
    80004064:	90850513          	addi	a0,a0,-1784 # 80022968 <ftable>
    80004068:	c25fc0ef          	jal	80000c8c <release>
}
    8000406c:	8526                	mv	a0,s1
    8000406e:	60e2                	ld	ra,24(sp)
    80004070:	6442                	ld	s0,16(sp)
    80004072:	64a2                	ld	s1,8(sp)
    80004074:	6105                	addi	sp,sp,32
    80004076:	8082                	ret

0000000080004078 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004078:	1101                	addi	sp,sp,-32
    8000407a:	ec06                	sd	ra,24(sp)
    8000407c:	e822                	sd	s0,16(sp)
    8000407e:	e426                	sd	s1,8(sp)
    80004080:	1000                	addi	s0,sp,32
    80004082:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004084:	0001f517          	auipc	a0,0x1f
    80004088:	8e450513          	addi	a0,a0,-1820 # 80022968 <ftable>
    8000408c:	b69fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004090:	40dc                	lw	a5,4(s1)
    80004092:	02f05063          	blez	a5,800040b2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004096:	2785                	addiw	a5,a5,1
    80004098:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000409a:	0001f517          	auipc	a0,0x1f
    8000409e:	8ce50513          	addi	a0,a0,-1842 # 80022968 <ftable>
    800040a2:	bebfc0ef          	jal	80000c8c <release>
  return f;
}
    800040a6:	8526                	mv	a0,s1
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret
    panic("filedup");
    800040b2:	00003517          	auipc	a0,0x3
    800040b6:	50e50513          	addi	a0,a0,1294 # 800075c0 <etext+0x5c0>
    800040ba:	edafc0ef          	jal	80000794 <panic>

00000000800040be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040be:	7139                	addi	sp,sp,-64
    800040c0:	fc06                	sd	ra,56(sp)
    800040c2:	f822                	sd	s0,48(sp)
    800040c4:	f426                	sd	s1,40(sp)
    800040c6:	0080                	addi	s0,sp,64
    800040c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040ca:	0001f517          	auipc	a0,0x1f
    800040ce:	89e50513          	addi	a0,a0,-1890 # 80022968 <ftable>
    800040d2:	b23fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800040d6:	40dc                	lw	a5,4(s1)
    800040d8:	04f05a63          	blez	a5,8000412c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040dc:	37fd                	addiw	a5,a5,-1
    800040de:	0007871b          	sext.w	a4,a5
    800040e2:	c0dc                	sw	a5,4(s1)
    800040e4:	04e04e63          	bgtz	a4,80004140 <fileclose+0x82>
    800040e8:	f04a                	sd	s2,32(sp)
    800040ea:	ec4e                	sd	s3,24(sp)
    800040ec:	e852                	sd	s4,16(sp)
    800040ee:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040f0:	0004a903          	lw	s2,0(s1)
    800040f4:	0094ca83          	lbu	s5,9(s1)
    800040f8:	0104ba03          	ld	s4,16(s1)
    800040fc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004100:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004104:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004108:	0001f517          	auipc	a0,0x1f
    8000410c:	86050513          	addi	a0,a0,-1952 # 80022968 <ftable>
    80004110:	b7dfc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004114:	4785                	li	a5,1
    80004116:	04f90063          	beq	s2,a5,80004156 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000411a:	3979                	addiw	s2,s2,-2
    8000411c:	4785                	li	a5,1
    8000411e:	0527f563          	bgeu	a5,s2,80004168 <fileclose+0xaa>
    80004122:	7902                	ld	s2,32(sp)
    80004124:	69e2                	ld	s3,24(sp)
    80004126:	6a42                	ld	s4,16(sp)
    80004128:	6aa2                	ld	s5,8(sp)
    8000412a:	a00d                	j	8000414c <fileclose+0x8e>
    8000412c:	f04a                	sd	s2,32(sp)
    8000412e:	ec4e                	sd	s3,24(sp)
    80004130:	e852                	sd	s4,16(sp)
    80004132:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004134:	00003517          	auipc	a0,0x3
    80004138:	49450513          	addi	a0,a0,1172 # 800075c8 <etext+0x5c8>
    8000413c:	e58fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004140:	0001f517          	auipc	a0,0x1f
    80004144:	82850513          	addi	a0,a0,-2008 # 80022968 <ftable>
    80004148:	b45fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000414c:	70e2                	ld	ra,56(sp)
    8000414e:	7442                	ld	s0,48(sp)
    80004150:	74a2                	ld	s1,40(sp)
    80004152:	6121                	addi	sp,sp,64
    80004154:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004156:	85d6                	mv	a1,s5
    80004158:	8552                	mv	a0,s4
    8000415a:	336000ef          	jal	80004490 <pipeclose>
    8000415e:	7902                	ld	s2,32(sp)
    80004160:	69e2                	ld	s3,24(sp)
    80004162:	6a42                	ld	s4,16(sp)
    80004164:	6aa2                	ld	s5,8(sp)
    80004166:	b7dd                	j	8000414c <fileclose+0x8e>
    begin_op();
    80004168:	b3dff0ef          	jal	80003ca4 <begin_op>
    iput(ff.ip);
    8000416c:	854e                	mv	a0,s3
    8000416e:	c22ff0ef          	jal	80003590 <iput>
    end_op();
    80004172:	b9dff0ef          	jal	80003d0e <end_op>
    80004176:	7902                	ld	s2,32(sp)
    80004178:	69e2                	ld	s3,24(sp)
    8000417a:	6a42                	ld	s4,16(sp)
    8000417c:	6aa2                	ld	s5,8(sp)
    8000417e:	b7f9                	j	8000414c <fileclose+0x8e>

0000000080004180 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004180:	715d                	addi	sp,sp,-80
    80004182:	e486                	sd	ra,72(sp)
    80004184:	e0a2                	sd	s0,64(sp)
    80004186:	fc26                	sd	s1,56(sp)
    80004188:	f44e                	sd	s3,40(sp)
    8000418a:	0880                	addi	s0,sp,80
    8000418c:	84aa                	mv	s1,a0
    8000418e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004190:	f50fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004194:	409c                	lw	a5,0(s1)
    80004196:	37f9                	addiw	a5,a5,-2
    80004198:	4705                	li	a4,1
    8000419a:	04f76063          	bltu	a4,a5,800041da <filestat+0x5a>
    8000419e:	f84a                	sd	s2,48(sp)
    800041a0:	892a                	mv	s2,a0
    ilock(f->ip);
    800041a2:	6c88                	ld	a0,24(s1)
    800041a4:	a6aff0ef          	jal	8000340e <ilock>
    stati(f->ip, &st);
    800041a8:	fb840593          	addi	a1,s0,-72
    800041ac:	6c88                	ld	a0,24(s1)
    800041ae:	c8aff0ef          	jal	80003638 <stati>
    iunlock(f->ip);
    800041b2:	6c88                	ld	a0,24(s1)
    800041b4:	b08ff0ef          	jal	800034bc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041b8:	46e1                	li	a3,24
    800041ba:	fb840613          	addi	a2,s0,-72
    800041be:	85ce                	mv	a1,s3
    800041c0:	05093503          	ld	a0,80(s2)
    800041c4:	b8efd0ef          	jal	80001552 <copyout>
    800041c8:	41f5551b          	sraiw	a0,a0,0x1f
    800041cc:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041ce:	60a6                	ld	ra,72(sp)
    800041d0:	6406                	ld	s0,64(sp)
    800041d2:	74e2                	ld	s1,56(sp)
    800041d4:	79a2                	ld	s3,40(sp)
    800041d6:	6161                	addi	sp,sp,80
    800041d8:	8082                	ret
  return -1;
    800041da:	557d                	li	a0,-1
    800041dc:	bfcd                	j	800041ce <filestat+0x4e>

00000000800041de <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041de:	7179                	addi	sp,sp,-48
    800041e0:	f406                	sd	ra,40(sp)
    800041e2:	f022                	sd	s0,32(sp)
    800041e4:	e84a                	sd	s2,16(sp)
    800041e6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041e8:	00854783          	lbu	a5,8(a0)
    800041ec:	cfd1                	beqz	a5,80004288 <fileread+0xaa>
    800041ee:	ec26                	sd	s1,24(sp)
    800041f0:	e44e                	sd	s3,8(sp)
    800041f2:	84aa                	mv	s1,a0
    800041f4:	89ae                	mv	s3,a1
    800041f6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800041f8:	411c                	lw	a5,0(a0)
    800041fa:	4705                	li	a4,1
    800041fc:	04e78363          	beq	a5,a4,80004242 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004200:	470d                	li	a4,3
    80004202:	04e78763          	beq	a5,a4,80004250 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004206:	4709                	li	a4,2
    80004208:	06e79a63          	bne	a5,a4,8000427c <fileread+0x9e>
    ilock(f->ip);
    8000420c:	6d08                	ld	a0,24(a0)
    8000420e:	a00ff0ef          	jal	8000340e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004212:	874a                	mv	a4,s2
    80004214:	5094                	lw	a3,32(s1)
    80004216:	864e                	mv	a2,s3
    80004218:	4585                	li	a1,1
    8000421a:	6c88                	ld	a0,24(s1)
    8000421c:	c46ff0ef          	jal	80003662 <readi>
    80004220:	892a                	mv	s2,a0
    80004222:	00a05563          	blez	a0,8000422c <fileread+0x4e>
      f->off += r;
    80004226:	509c                	lw	a5,32(s1)
    80004228:	9fa9                	addw	a5,a5,a0
    8000422a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000422c:	6c88                	ld	a0,24(s1)
    8000422e:	a8eff0ef          	jal	800034bc <iunlock>
    80004232:	64e2                	ld	s1,24(sp)
    80004234:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004236:	854a                	mv	a0,s2
    80004238:	70a2                	ld	ra,40(sp)
    8000423a:	7402                	ld	s0,32(sp)
    8000423c:	6942                	ld	s2,16(sp)
    8000423e:	6145                	addi	sp,sp,48
    80004240:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004242:	6908                	ld	a0,16(a0)
    80004244:	388000ef          	jal	800045cc <piperead>
    80004248:	892a                	mv	s2,a0
    8000424a:	64e2                	ld	s1,24(sp)
    8000424c:	69a2                	ld	s3,8(sp)
    8000424e:	b7e5                	j	80004236 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004250:	02451783          	lh	a5,36(a0)
    80004254:	03079693          	slli	a3,a5,0x30
    80004258:	92c1                	srli	a3,a3,0x30
    8000425a:	4725                	li	a4,9
    8000425c:	02d76863          	bltu	a4,a3,8000428c <fileread+0xae>
    80004260:	0792                	slli	a5,a5,0x4
    80004262:	0001e717          	auipc	a4,0x1e
    80004266:	66670713          	addi	a4,a4,1638 # 800228c8 <devsw>
    8000426a:	97ba                	add	a5,a5,a4
    8000426c:	639c                	ld	a5,0(a5)
    8000426e:	c39d                	beqz	a5,80004294 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004270:	4505                	li	a0,1
    80004272:	9782                	jalr	a5
    80004274:	892a                	mv	s2,a0
    80004276:	64e2                	ld	s1,24(sp)
    80004278:	69a2                	ld	s3,8(sp)
    8000427a:	bf75                	j	80004236 <fileread+0x58>
    panic("fileread");
    8000427c:	00003517          	auipc	a0,0x3
    80004280:	35c50513          	addi	a0,a0,860 # 800075d8 <etext+0x5d8>
    80004284:	d10fc0ef          	jal	80000794 <panic>
    return -1;
    80004288:	597d                	li	s2,-1
    8000428a:	b775                	j	80004236 <fileread+0x58>
      return -1;
    8000428c:	597d                	li	s2,-1
    8000428e:	64e2                	ld	s1,24(sp)
    80004290:	69a2                	ld	s3,8(sp)
    80004292:	b755                	j	80004236 <fileread+0x58>
    80004294:	597d                	li	s2,-1
    80004296:	64e2                	ld	s1,24(sp)
    80004298:	69a2                	ld	s3,8(sp)
    8000429a:	bf71                	j	80004236 <fileread+0x58>

000000008000429c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000429c:	00954783          	lbu	a5,9(a0)
    800042a0:	10078b63          	beqz	a5,800043b6 <filewrite+0x11a>
{
    800042a4:	715d                	addi	sp,sp,-80
    800042a6:	e486                	sd	ra,72(sp)
    800042a8:	e0a2                	sd	s0,64(sp)
    800042aa:	f84a                	sd	s2,48(sp)
    800042ac:	f052                	sd	s4,32(sp)
    800042ae:	e85a                	sd	s6,16(sp)
    800042b0:	0880                	addi	s0,sp,80
    800042b2:	892a                	mv	s2,a0
    800042b4:	8b2e                	mv	s6,a1
    800042b6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800042b8:	411c                	lw	a5,0(a0)
    800042ba:	4705                	li	a4,1
    800042bc:	02e78763          	beq	a5,a4,800042ea <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042c0:	470d                	li	a4,3
    800042c2:	02e78863          	beq	a5,a4,800042f2 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042c6:	4709                	li	a4,2
    800042c8:	0ce79c63          	bne	a5,a4,800043a0 <filewrite+0x104>
    800042cc:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042ce:	0ac05863          	blez	a2,8000437e <filewrite+0xe2>
    800042d2:	fc26                	sd	s1,56(sp)
    800042d4:	ec56                	sd	s5,24(sp)
    800042d6:	e45e                	sd	s7,8(sp)
    800042d8:	e062                	sd	s8,0(sp)
    int i = 0;
    800042da:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800042dc:	6b85                	lui	s7,0x1
    800042de:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042e2:	6c05                	lui	s8,0x1
    800042e4:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800042e8:	a8b5                	j	80004364 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800042ea:	6908                	ld	a0,16(a0)
    800042ec:	1fc000ef          	jal	800044e8 <pipewrite>
    800042f0:	a04d                	j	80004392 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042f2:	02451783          	lh	a5,36(a0)
    800042f6:	03079693          	slli	a3,a5,0x30
    800042fa:	92c1                	srli	a3,a3,0x30
    800042fc:	4725                	li	a4,9
    800042fe:	0ad76e63          	bltu	a4,a3,800043ba <filewrite+0x11e>
    80004302:	0792                	slli	a5,a5,0x4
    80004304:	0001e717          	auipc	a4,0x1e
    80004308:	5c470713          	addi	a4,a4,1476 # 800228c8 <devsw>
    8000430c:	97ba                	add	a5,a5,a4
    8000430e:	679c                	ld	a5,8(a5)
    80004310:	c7dd                	beqz	a5,800043be <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004312:	4505                	li	a0,1
    80004314:	9782                	jalr	a5
    80004316:	a8b5                	j	80004392 <filewrite+0xf6>
      if(n1 > max)
    80004318:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000431c:	989ff0ef          	jal	80003ca4 <begin_op>
      ilock(f->ip);
    80004320:	01893503          	ld	a0,24(s2)
    80004324:	8eaff0ef          	jal	8000340e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004328:	8756                	mv	a4,s5
    8000432a:	02092683          	lw	a3,32(s2)
    8000432e:	01698633          	add	a2,s3,s6
    80004332:	4585                	li	a1,1
    80004334:	01893503          	ld	a0,24(s2)
    80004338:	c26ff0ef          	jal	8000375e <writei>
    8000433c:	84aa                	mv	s1,a0
    8000433e:	00a05763          	blez	a0,8000434c <filewrite+0xb0>
        f->off += r;
    80004342:	02092783          	lw	a5,32(s2)
    80004346:	9fa9                	addw	a5,a5,a0
    80004348:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000434c:	01893503          	ld	a0,24(s2)
    80004350:	96cff0ef          	jal	800034bc <iunlock>
      end_op();
    80004354:	9bbff0ef          	jal	80003d0e <end_op>

      if(r != n1){
    80004358:	029a9563          	bne	s5,s1,80004382 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000435c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004360:	0149da63          	bge	s3,s4,80004374 <filewrite+0xd8>
      int n1 = n - i;
    80004364:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004368:	0004879b          	sext.w	a5,s1
    8000436c:	fafbd6e3          	bge	s7,a5,80004318 <filewrite+0x7c>
    80004370:	84e2                	mv	s1,s8
    80004372:	b75d                	j	80004318 <filewrite+0x7c>
    80004374:	74e2                	ld	s1,56(sp)
    80004376:	6ae2                	ld	s5,24(sp)
    80004378:	6ba2                	ld	s7,8(sp)
    8000437a:	6c02                	ld	s8,0(sp)
    8000437c:	a039                	j	8000438a <filewrite+0xee>
    int i = 0;
    8000437e:	4981                	li	s3,0
    80004380:	a029                	j	8000438a <filewrite+0xee>
    80004382:	74e2                	ld	s1,56(sp)
    80004384:	6ae2                	ld	s5,24(sp)
    80004386:	6ba2                	ld	s7,8(sp)
    80004388:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000438a:	033a1c63          	bne	s4,s3,800043c2 <filewrite+0x126>
    8000438e:	8552                	mv	a0,s4
    80004390:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004392:	60a6                	ld	ra,72(sp)
    80004394:	6406                	ld	s0,64(sp)
    80004396:	7942                	ld	s2,48(sp)
    80004398:	7a02                	ld	s4,32(sp)
    8000439a:	6b42                	ld	s6,16(sp)
    8000439c:	6161                	addi	sp,sp,80
    8000439e:	8082                	ret
    800043a0:	fc26                	sd	s1,56(sp)
    800043a2:	f44e                	sd	s3,40(sp)
    800043a4:	ec56                	sd	s5,24(sp)
    800043a6:	e45e                	sd	s7,8(sp)
    800043a8:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800043aa:	00003517          	auipc	a0,0x3
    800043ae:	23e50513          	addi	a0,a0,574 # 800075e8 <etext+0x5e8>
    800043b2:	be2fc0ef          	jal	80000794 <panic>
    return -1;
    800043b6:	557d                	li	a0,-1
}
    800043b8:	8082                	ret
      return -1;
    800043ba:	557d                	li	a0,-1
    800043bc:	bfd9                	j	80004392 <filewrite+0xf6>
    800043be:	557d                	li	a0,-1
    800043c0:	bfc9                	j	80004392 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800043c2:	557d                	li	a0,-1
    800043c4:	79a2                	ld	s3,40(sp)
    800043c6:	b7f1                	j	80004392 <filewrite+0xf6>

00000000800043c8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043c8:	7179                	addi	sp,sp,-48
    800043ca:	f406                	sd	ra,40(sp)
    800043cc:	f022                	sd	s0,32(sp)
    800043ce:	ec26                	sd	s1,24(sp)
    800043d0:	e052                	sd	s4,0(sp)
    800043d2:	1800                	addi	s0,sp,48
    800043d4:	84aa                	mv	s1,a0
    800043d6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043d8:	0005b023          	sd	zero,0(a1)
    800043dc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043e0:	c3bff0ef          	jal	8000401a <filealloc>
    800043e4:	e088                	sd	a0,0(s1)
    800043e6:	c549                	beqz	a0,80004470 <pipealloc+0xa8>
    800043e8:	c33ff0ef          	jal	8000401a <filealloc>
    800043ec:	00aa3023          	sd	a0,0(s4)
    800043f0:	cd25                	beqz	a0,80004468 <pipealloc+0xa0>
    800043f2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800043f4:	f30fc0ef          	jal	80000b24 <kalloc>
    800043f8:	892a                	mv	s2,a0
    800043fa:	c12d                	beqz	a0,8000445c <pipealloc+0x94>
    800043fc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800043fe:	4985                	li	s3,1
    80004400:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004404:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004408:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000440c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004410:	00003597          	auipc	a1,0x3
    80004414:	1e858593          	addi	a1,a1,488 # 800075f8 <etext+0x5f8>
    80004418:	f5cfc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    8000441c:	609c                	ld	a5,0(s1)
    8000441e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004422:	609c                	ld	a5,0(s1)
    80004424:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004428:	609c                	ld	a5,0(s1)
    8000442a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000442e:	609c                	ld	a5,0(s1)
    80004430:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004434:	000a3783          	ld	a5,0(s4)
    80004438:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000443c:	000a3783          	ld	a5,0(s4)
    80004440:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004444:	000a3783          	ld	a5,0(s4)
    80004448:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000444c:	000a3783          	ld	a5,0(s4)
    80004450:	0127b823          	sd	s2,16(a5)
  return 0;
    80004454:	4501                	li	a0,0
    80004456:	6942                	ld	s2,16(sp)
    80004458:	69a2                	ld	s3,8(sp)
    8000445a:	a01d                	j	80004480 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000445c:	6088                	ld	a0,0(s1)
    8000445e:	c119                	beqz	a0,80004464 <pipealloc+0x9c>
    80004460:	6942                	ld	s2,16(sp)
    80004462:	a029                	j	8000446c <pipealloc+0xa4>
    80004464:	6942                	ld	s2,16(sp)
    80004466:	a029                	j	80004470 <pipealloc+0xa8>
    80004468:	6088                	ld	a0,0(s1)
    8000446a:	c10d                	beqz	a0,8000448c <pipealloc+0xc4>
    fileclose(*f0);
    8000446c:	c53ff0ef          	jal	800040be <fileclose>
  if(*f1)
    80004470:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004474:	557d                	li	a0,-1
  if(*f1)
    80004476:	c789                	beqz	a5,80004480 <pipealloc+0xb8>
    fileclose(*f1);
    80004478:	853e                	mv	a0,a5
    8000447a:	c45ff0ef          	jal	800040be <fileclose>
  return -1;
    8000447e:	557d                	li	a0,-1
}
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6a02                	ld	s4,0(sp)
    80004488:	6145                	addi	sp,sp,48
    8000448a:	8082                	ret
  return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	bfcd                	j	80004480 <pipealloc+0xb8>

0000000080004490 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	e04a                	sd	s2,0(sp)
    8000449a:	1000                	addi	s0,sp,32
    8000449c:	84aa                	mv	s1,a0
    8000449e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044a0:	f54fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800044a4:	02090763          	beqz	s2,800044d2 <pipeclose+0x42>
    pi->writeopen = 0;
    800044a8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044ac:	21848513          	addi	a0,s1,536
    800044b0:	c99fd0ef          	jal	80002148 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044b4:	2204b783          	ld	a5,544(s1)
    800044b8:	e785                	bnez	a5,800044e0 <pipeclose+0x50>
    release(&pi->lock);
    800044ba:	8526                	mv	a0,s1
    800044bc:	fd0fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800044c0:	8526                	mv	a0,s1
    800044c2:	d80fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800044c6:	60e2                	ld	ra,24(sp)
    800044c8:	6442                	ld	s0,16(sp)
    800044ca:	64a2                	ld	s1,8(sp)
    800044cc:	6902                	ld	s2,0(sp)
    800044ce:	6105                	addi	sp,sp,32
    800044d0:	8082                	ret
    pi->readopen = 0;
    800044d2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044d6:	21c48513          	addi	a0,s1,540
    800044da:	c6ffd0ef          	jal	80002148 <wakeup>
    800044de:	bfd9                	j	800044b4 <pipeclose+0x24>
    release(&pi->lock);
    800044e0:	8526                	mv	a0,s1
    800044e2:	faafc0ef          	jal	80000c8c <release>
}
    800044e6:	b7c5                	j	800044c6 <pipeclose+0x36>

00000000800044e8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044e8:	711d                	addi	sp,sp,-96
    800044ea:	ec86                	sd	ra,88(sp)
    800044ec:	e8a2                	sd	s0,80(sp)
    800044ee:	e4a6                	sd	s1,72(sp)
    800044f0:	e0ca                	sd	s2,64(sp)
    800044f2:	fc4e                	sd	s3,56(sp)
    800044f4:	f852                	sd	s4,48(sp)
    800044f6:	f456                	sd	s5,40(sp)
    800044f8:	1080                	addi	s0,sp,96
    800044fa:	84aa                	mv	s1,a0
    800044fc:	8aae                	mv	s5,a1
    800044fe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004500:	be0fd0ef          	jal	800018e0 <myproc>
    80004504:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004506:	8526                	mv	a0,s1
    80004508:	eecfc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    8000450c:	0b405a63          	blez	s4,800045c0 <pipewrite+0xd8>
    80004510:	f05a                	sd	s6,32(sp)
    80004512:	ec5e                	sd	s7,24(sp)
    80004514:	e862                	sd	s8,16(sp)
  int i = 0;
    80004516:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004518:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000451a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000451e:	21c48b93          	addi	s7,s1,540
    80004522:	a81d                	j	80004558 <pipewrite+0x70>
      release(&pi->lock);
    80004524:	8526                	mv	a0,s1
    80004526:	f66fc0ef          	jal	80000c8c <release>
      return -1;
    8000452a:	597d                	li	s2,-1
    8000452c:	7b02                	ld	s6,32(sp)
    8000452e:	6be2                	ld	s7,24(sp)
    80004530:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004532:	854a                	mv	a0,s2
    80004534:	60e6                	ld	ra,88(sp)
    80004536:	6446                	ld	s0,80(sp)
    80004538:	64a6                	ld	s1,72(sp)
    8000453a:	6906                	ld	s2,64(sp)
    8000453c:	79e2                	ld	s3,56(sp)
    8000453e:	7a42                	ld	s4,48(sp)
    80004540:	7aa2                	ld	s5,40(sp)
    80004542:	6125                	addi	sp,sp,96
    80004544:	8082                	ret
      wakeup(&pi->nread);
    80004546:	8562                	mv	a0,s8
    80004548:	c01fd0ef          	jal	80002148 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000454c:	85a6                	mv	a1,s1
    8000454e:	855e                	mv	a0,s7
    80004550:	badfd0ef          	jal	800020fc <sleep>
  while(i < n){
    80004554:	05495b63          	bge	s2,s4,800045aa <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004558:	2204a783          	lw	a5,544(s1)
    8000455c:	d7e1                	beqz	a5,80004524 <pipewrite+0x3c>
    8000455e:	854e                	mv	a0,s3
    80004560:	dd5fd0ef          	jal	80002334 <killed>
    80004564:	f161                	bnez	a0,80004524 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004566:	2184a783          	lw	a5,536(s1)
    8000456a:	21c4a703          	lw	a4,540(s1)
    8000456e:	2007879b          	addiw	a5,a5,512
    80004572:	fcf70ae3          	beq	a4,a5,80004546 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004576:	4685                	li	a3,1
    80004578:	01590633          	add	a2,s2,s5
    8000457c:	faf40593          	addi	a1,s0,-81
    80004580:	0509b503          	ld	a0,80(s3)
    80004584:	8a4fd0ef          	jal	80001628 <copyin>
    80004588:	03650e63          	beq	a0,s6,800045c4 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000458c:	21c4a783          	lw	a5,540(s1)
    80004590:	0017871b          	addiw	a4,a5,1
    80004594:	20e4ae23          	sw	a4,540(s1)
    80004598:	1ff7f793          	andi	a5,a5,511
    8000459c:	97a6                	add	a5,a5,s1
    8000459e:	faf44703          	lbu	a4,-81(s0)
    800045a2:	00e78c23          	sb	a4,24(a5)
      i++;
    800045a6:	2905                	addiw	s2,s2,1
    800045a8:	b775                	j	80004554 <pipewrite+0x6c>
    800045aa:	7b02                	ld	s6,32(sp)
    800045ac:	6be2                	ld	s7,24(sp)
    800045ae:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800045b0:	21848513          	addi	a0,s1,536
    800045b4:	b95fd0ef          	jal	80002148 <wakeup>
  release(&pi->lock);
    800045b8:	8526                	mv	a0,s1
    800045ba:	ed2fc0ef          	jal	80000c8c <release>
  return i;
    800045be:	bf95                	j	80004532 <pipewrite+0x4a>
  int i = 0;
    800045c0:	4901                	li	s2,0
    800045c2:	b7fd                	j	800045b0 <pipewrite+0xc8>
    800045c4:	7b02                	ld	s6,32(sp)
    800045c6:	6be2                	ld	s7,24(sp)
    800045c8:	6c42                	ld	s8,16(sp)
    800045ca:	b7dd                	j	800045b0 <pipewrite+0xc8>

00000000800045cc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045cc:	715d                	addi	sp,sp,-80
    800045ce:	e486                	sd	ra,72(sp)
    800045d0:	e0a2                	sd	s0,64(sp)
    800045d2:	fc26                	sd	s1,56(sp)
    800045d4:	f84a                	sd	s2,48(sp)
    800045d6:	f44e                	sd	s3,40(sp)
    800045d8:	f052                	sd	s4,32(sp)
    800045da:	ec56                	sd	s5,24(sp)
    800045dc:	0880                	addi	s0,sp,80
    800045de:	84aa                	mv	s1,a0
    800045e0:	892e                	mv	s2,a1
    800045e2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045e4:	afcfd0ef          	jal	800018e0 <myproc>
    800045e8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800045ea:	8526                	mv	a0,s1
    800045ec:	e08fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045f0:	2184a703          	lw	a4,536(s1)
    800045f4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800045f8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800045fc:	02f71563          	bne	a4,a5,80004626 <piperead+0x5a>
    80004600:	2244a783          	lw	a5,548(s1)
    80004604:	cb85                	beqz	a5,80004634 <piperead+0x68>
    if(killed(pr)){
    80004606:	8552                	mv	a0,s4
    80004608:	d2dfd0ef          	jal	80002334 <killed>
    8000460c:	ed19                	bnez	a0,8000462a <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000460e:	85a6                	mv	a1,s1
    80004610:	854e                	mv	a0,s3
    80004612:	aebfd0ef          	jal	800020fc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004616:	2184a703          	lw	a4,536(s1)
    8000461a:	21c4a783          	lw	a5,540(s1)
    8000461e:	fef701e3          	beq	a4,a5,80004600 <piperead+0x34>
    80004622:	e85a                	sd	s6,16(sp)
    80004624:	a809                	j	80004636 <piperead+0x6a>
    80004626:	e85a                	sd	s6,16(sp)
    80004628:	a039                	j	80004636 <piperead+0x6a>
      release(&pi->lock);
    8000462a:	8526                	mv	a0,s1
    8000462c:	e60fc0ef          	jal	80000c8c <release>
      return -1;
    80004630:	59fd                	li	s3,-1
    80004632:	a8b1                	j	8000468e <piperead+0xc2>
    80004634:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004636:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004638:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000463a:	05505263          	blez	s5,8000467e <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000463e:	2184a783          	lw	a5,536(s1)
    80004642:	21c4a703          	lw	a4,540(s1)
    80004646:	02f70c63          	beq	a4,a5,8000467e <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000464a:	0017871b          	addiw	a4,a5,1
    8000464e:	20e4ac23          	sw	a4,536(s1)
    80004652:	1ff7f793          	andi	a5,a5,511
    80004656:	97a6                	add	a5,a5,s1
    80004658:	0187c783          	lbu	a5,24(a5)
    8000465c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004660:	4685                	li	a3,1
    80004662:	fbf40613          	addi	a2,s0,-65
    80004666:	85ca                	mv	a1,s2
    80004668:	050a3503          	ld	a0,80(s4)
    8000466c:	ee7fc0ef          	jal	80001552 <copyout>
    80004670:	01650763          	beq	a0,s6,8000467e <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004674:	2985                	addiw	s3,s3,1
    80004676:	0905                	addi	s2,s2,1
    80004678:	fd3a93e3          	bne	s5,s3,8000463e <piperead+0x72>
    8000467c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000467e:	21c48513          	addi	a0,s1,540
    80004682:	ac7fd0ef          	jal	80002148 <wakeup>
  release(&pi->lock);
    80004686:	8526                	mv	a0,s1
    80004688:	e04fc0ef          	jal	80000c8c <release>
    8000468c:	6b42                	ld	s6,16(sp)
  return i;
}
    8000468e:	854e                	mv	a0,s3
    80004690:	60a6                	ld	ra,72(sp)
    80004692:	6406                	ld	s0,64(sp)
    80004694:	74e2                	ld	s1,56(sp)
    80004696:	7942                	ld	s2,48(sp)
    80004698:	79a2                	ld	s3,40(sp)
    8000469a:	7a02                	ld	s4,32(sp)
    8000469c:	6ae2                	ld	s5,24(sp)
    8000469e:	6161                	addi	sp,sp,80
    800046a0:	8082                	ret

00000000800046a2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800046a2:	1141                	addi	sp,sp,-16
    800046a4:	e422                	sd	s0,8(sp)
    800046a6:	0800                	addi	s0,sp,16
    800046a8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046aa:	8905                	andi	a0,a0,1
    800046ac:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800046ae:	8b89                	andi	a5,a5,2
    800046b0:	c399                	beqz	a5,800046b6 <flags2perm+0x14>
      perm |= PTE_W;
    800046b2:	00456513          	ori	a0,a0,4
    return perm;
}
    800046b6:	6422                	ld	s0,8(sp)
    800046b8:	0141                	addi	sp,sp,16
    800046ba:	8082                	ret

00000000800046bc <exec>:

int
exec(char *path, char **argv)
{
    800046bc:	df010113          	addi	sp,sp,-528
    800046c0:	20113423          	sd	ra,520(sp)
    800046c4:	20813023          	sd	s0,512(sp)
    800046c8:	ffa6                	sd	s1,504(sp)
    800046ca:	fbca                	sd	s2,496(sp)
    800046cc:	0c00                	addi	s0,sp,528
    800046ce:	892a                	mv	s2,a0
    800046d0:	dea43c23          	sd	a0,-520(s0)
    800046d4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800046d8:	a08fd0ef          	jal	800018e0 <myproc>
    800046dc:	84aa                	mv	s1,a0

  begin_op();
    800046de:	dc6ff0ef          	jal	80003ca4 <begin_op>

  if((ip = namei(path)) == 0){
    800046e2:	854a                	mv	a0,s2
    800046e4:	c04ff0ef          	jal	80003ae8 <namei>
    800046e8:	c931                	beqz	a0,8000473c <exec+0x80>
    800046ea:	f3d2                	sd	s4,480(sp)
    800046ec:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800046ee:	d21fe0ef          	jal	8000340e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800046f2:	04000713          	li	a4,64
    800046f6:	4681                	li	a3,0
    800046f8:	e5040613          	addi	a2,s0,-432
    800046fc:	4581                	li	a1,0
    800046fe:	8552                	mv	a0,s4
    80004700:	f63fe0ef          	jal	80003662 <readi>
    80004704:	04000793          	li	a5,64
    80004708:	00f51a63          	bne	a0,a5,8000471c <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000470c:	e5042703          	lw	a4,-432(s0)
    80004710:	464c47b7          	lui	a5,0x464c4
    80004714:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004718:	02f70663          	beq	a4,a5,80004744 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000471c:	8552                	mv	a0,s4
    8000471e:	efbfe0ef          	jal	80003618 <iunlockput>
    end_op();
    80004722:	decff0ef          	jal	80003d0e <end_op>
  }
  return -1;
    80004726:	557d                	li	a0,-1
    80004728:	7a1e                	ld	s4,480(sp)
}
    8000472a:	20813083          	ld	ra,520(sp)
    8000472e:	20013403          	ld	s0,512(sp)
    80004732:	74fe                	ld	s1,504(sp)
    80004734:	795e                	ld	s2,496(sp)
    80004736:	21010113          	addi	sp,sp,528
    8000473a:	8082                	ret
    end_op();
    8000473c:	dd2ff0ef          	jal	80003d0e <end_op>
    return -1;
    80004740:	557d                	li	a0,-1
    80004742:	b7e5                	j	8000472a <exec+0x6e>
    80004744:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004746:	8526                	mv	a0,s1
    80004748:	bf4fd0ef          	jal	80001b3c <proc_pagetable>
    8000474c:	8b2a                	mv	s6,a0
    8000474e:	2c050b63          	beqz	a0,80004a24 <exec+0x368>
    80004752:	f7ce                	sd	s3,488(sp)
    80004754:	efd6                	sd	s5,472(sp)
    80004756:	e7de                	sd	s7,456(sp)
    80004758:	e3e2                	sd	s8,448(sp)
    8000475a:	ff66                	sd	s9,440(sp)
    8000475c:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000475e:	e7042d03          	lw	s10,-400(s0)
    80004762:	e8845783          	lhu	a5,-376(s0)
    80004766:	12078963          	beqz	a5,80004898 <exec+0x1dc>
    8000476a:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000476c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000476e:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004770:	6c85                	lui	s9,0x1
    80004772:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004776:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000477a:	6a85                	lui	s5,0x1
    8000477c:	a085                	j	800047dc <exec+0x120>
      panic("loadseg: address should exist");
    8000477e:	00003517          	auipc	a0,0x3
    80004782:	e8250513          	addi	a0,a0,-382 # 80007600 <etext+0x600>
    80004786:	80efc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000478a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000478c:	8726                	mv	a4,s1
    8000478e:	012c06bb          	addw	a3,s8,s2
    80004792:	4581                	li	a1,0
    80004794:	8552                	mv	a0,s4
    80004796:	ecdfe0ef          	jal	80003662 <readi>
    8000479a:	2501                	sext.w	a0,a0
    8000479c:	24a49a63          	bne	s1,a0,800049f0 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800047a0:	012a893b          	addw	s2,s5,s2
    800047a4:	03397363          	bgeu	s2,s3,800047ca <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800047a8:	02091593          	slli	a1,s2,0x20
    800047ac:	9181                	srli	a1,a1,0x20
    800047ae:	95de                	add	a1,a1,s7
    800047b0:	855a                	mv	a0,s6
    800047b2:	825fc0ef          	jal	80000fd6 <walkaddr>
    800047b6:	862a                	mv	a2,a0
    if(pa == 0)
    800047b8:	d179                	beqz	a0,8000477e <exec+0xc2>
    if(sz - i < PGSIZE)
    800047ba:	412984bb          	subw	s1,s3,s2
    800047be:	0004879b          	sext.w	a5,s1
    800047c2:	fcfcf4e3          	bgeu	s9,a5,8000478a <exec+0xce>
    800047c6:	84d6                	mv	s1,s5
    800047c8:	b7c9                	j	8000478a <exec+0xce>
    sz = sz1;
    800047ca:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047ce:	2d85                	addiw	s11,s11,1
    800047d0:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800047d4:	e8845783          	lhu	a5,-376(s0)
    800047d8:	08fdd063          	bge	s11,a5,80004858 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047dc:	2d01                	sext.w	s10,s10
    800047de:	03800713          	li	a4,56
    800047e2:	86ea                	mv	a3,s10
    800047e4:	e1840613          	addi	a2,s0,-488
    800047e8:	4581                	li	a1,0
    800047ea:	8552                	mv	a0,s4
    800047ec:	e77fe0ef          	jal	80003662 <readi>
    800047f0:	03800793          	li	a5,56
    800047f4:	1cf51663          	bne	a0,a5,800049c0 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800047f8:	e1842783          	lw	a5,-488(s0)
    800047fc:	4705                	li	a4,1
    800047fe:	fce798e3          	bne	a5,a4,800047ce <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004802:	e4043483          	ld	s1,-448(s0)
    80004806:	e3843783          	ld	a5,-456(s0)
    8000480a:	1af4ef63          	bltu	s1,a5,800049c8 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000480e:	e2843783          	ld	a5,-472(s0)
    80004812:	94be                	add	s1,s1,a5
    80004814:	1af4ee63          	bltu	s1,a5,800049d0 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004818:	df043703          	ld	a4,-528(s0)
    8000481c:	8ff9                	and	a5,a5,a4
    8000481e:	1a079d63          	bnez	a5,800049d8 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004822:	e1c42503          	lw	a0,-484(s0)
    80004826:	e7dff0ef          	jal	800046a2 <flags2perm>
    8000482a:	86aa                	mv	a3,a0
    8000482c:	8626                	mv	a2,s1
    8000482e:	85ca                	mv	a1,s2
    80004830:	855a                	mv	a0,s6
    80004832:	b0dfc0ef          	jal	8000133e <uvmalloc>
    80004836:	e0a43423          	sd	a0,-504(s0)
    8000483a:	1a050363          	beqz	a0,800049e0 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000483e:	e2843b83          	ld	s7,-472(s0)
    80004842:	e2042c03          	lw	s8,-480(s0)
    80004846:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000484a:	00098463          	beqz	s3,80004852 <exec+0x196>
    8000484e:	4901                	li	s2,0
    80004850:	bfa1                	j	800047a8 <exec+0xec>
    sz = sz1;
    80004852:	e0843903          	ld	s2,-504(s0)
    80004856:	bfa5                	j	800047ce <exec+0x112>
    80004858:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000485a:	8552                	mv	a0,s4
    8000485c:	dbdfe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004860:	caeff0ef          	jal	80003d0e <end_op>
  p = myproc();
    80004864:	87cfd0ef          	jal	800018e0 <myproc>
    80004868:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000486a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000486e:	6985                	lui	s3,0x1
    80004870:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004872:	99ca                	add	s3,s3,s2
    80004874:	77fd                	lui	a5,0xfffff
    80004876:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000487a:	4691                	li	a3,4
    8000487c:	6609                	lui	a2,0x2
    8000487e:	964e                	add	a2,a2,s3
    80004880:	85ce                	mv	a1,s3
    80004882:	855a                	mv	a0,s6
    80004884:	abbfc0ef          	jal	8000133e <uvmalloc>
    80004888:	892a                	mv	s2,a0
    8000488a:	e0a43423          	sd	a0,-504(s0)
    8000488e:	e519                	bnez	a0,8000489c <exec+0x1e0>
  if(pagetable)
    80004890:	e1343423          	sd	s3,-504(s0)
    80004894:	4a01                	li	s4,0
    80004896:	aab1                	j	800049f2 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004898:	4901                	li	s2,0
    8000489a:	b7c1                	j	8000485a <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000489c:	75f9                	lui	a1,0xffffe
    8000489e:	95aa                	add	a1,a1,a0
    800048a0:	855a                	mv	a0,s6
    800048a2:	c87fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048a6:	7bfd                	lui	s7,0xfffff
    800048a8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800048aa:	e0043783          	ld	a5,-512(s0)
    800048ae:	6388                	ld	a0,0(a5)
    800048b0:	cd39                	beqz	a0,8000490e <exec+0x252>
    800048b2:	e9040993          	addi	s3,s0,-368
    800048b6:	f9040c13          	addi	s8,s0,-112
    800048ba:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800048bc:	d7cfc0ef          	jal	80000e38 <strlen>
    800048c0:	0015079b          	addiw	a5,a0,1
    800048c4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800048c8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800048cc:	11796e63          	bltu	s2,s7,800049e8 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800048d0:	e0043d03          	ld	s10,-512(s0)
    800048d4:	000d3a03          	ld	s4,0(s10)
    800048d8:	8552                	mv	a0,s4
    800048da:	d5efc0ef          	jal	80000e38 <strlen>
    800048de:	0015069b          	addiw	a3,a0,1
    800048e2:	8652                	mv	a2,s4
    800048e4:	85ca                	mv	a1,s2
    800048e6:	855a                	mv	a0,s6
    800048e8:	c6bfc0ef          	jal	80001552 <copyout>
    800048ec:	10054063          	bltz	a0,800049ec <exec+0x330>
    ustack[argc] = sp;
    800048f0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800048f4:	0485                	addi	s1,s1,1
    800048f6:	008d0793          	addi	a5,s10,8
    800048fa:	e0f43023          	sd	a5,-512(s0)
    800048fe:	008d3503          	ld	a0,8(s10)
    80004902:	c909                	beqz	a0,80004914 <exec+0x258>
    if(argc >= MAXARG)
    80004904:	09a1                	addi	s3,s3,8
    80004906:	fb899be3          	bne	s3,s8,800048bc <exec+0x200>
  ip = 0;
    8000490a:	4a01                	li	s4,0
    8000490c:	a0dd                	j	800049f2 <exec+0x336>
  sp = sz;
    8000490e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004912:	4481                	li	s1,0
  ustack[argc] = 0;
    80004914:	00349793          	slli	a5,s1,0x3
    80004918:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb530>
    8000491c:	97a2                	add	a5,a5,s0
    8000491e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004922:	00148693          	addi	a3,s1,1
    80004926:	068e                	slli	a3,a3,0x3
    80004928:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000492c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004930:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004934:	f5796ee3          	bltu	s2,s7,80004890 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004938:	e9040613          	addi	a2,s0,-368
    8000493c:	85ca                	mv	a1,s2
    8000493e:	855a                	mv	a0,s6
    80004940:	c13fc0ef          	jal	80001552 <copyout>
    80004944:	0e054263          	bltz	a0,80004a28 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004948:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000494c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004950:	df843783          	ld	a5,-520(s0)
    80004954:	0007c703          	lbu	a4,0(a5)
    80004958:	cf11                	beqz	a4,80004974 <exec+0x2b8>
    8000495a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000495c:	02f00693          	li	a3,47
    80004960:	a039                	j	8000496e <exec+0x2b2>
      last = s+1;
    80004962:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004966:	0785                	addi	a5,a5,1
    80004968:	fff7c703          	lbu	a4,-1(a5)
    8000496c:	c701                	beqz	a4,80004974 <exec+0x2b8>
    if(*s == '/')
    8000496e:	fed71ce3          	bne	a4,a3,80004966 <exec+0x2aa>
    80004972:	bfc5                	j	80004962 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004974:	4641                	li	a2,16
    80004976:	df843583          	ld	a1,-520(s0)
    8000497a:	158a8513          	addi	a0,s5,344
    8000497e:	c88fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004982:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004986:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000498a:	e0843783          	ld	a5,-504(s0)
    8000498e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004992:	058ab783          	ld	a5,88(s5)
    80004996:	e6843703          	ld	a4,-408(s0)
    8000499a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000499c:	058ab783          	ld	a5,88(s5)
    800049a0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049a4:	85e6                	mv	a1,s9
    800049a6:	a1afd0ef          	jal	80001bc0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049aa:	0004851b          	sext.w	a0,s1
    800049ae:	79be                	ld	s3,488(sp)
    800049b0:	7a1e                	ld	s4,480(sp)
    800049b2:	6afe                	ld	s5,472(sp)
    800049b4:	6b5e                	ld	s6,464(sp)
    800049b6:	6bbe                	ld	s7,456(sp)
    800049b8:	6c1e                	ld	s8,448(sp)
    800049ba:	7cfa                	ld	s9,440(sp)
    800049bc:	7d5a                	ld	s10,432(sp)
    800049be:	b3b5                	j	8000472a <exec+0x6e>
    800049c0:	e1243423          	sd	s2,-504(s0)
    800049c4:	7dba                	ld	s11,424(sp)
    800049c6:	a035                	j	800049f2 <exec+0x336>
    800049c8:	e1243423          	sd	s2,-504(s0)
    800049cc:	7dba                	ld	s11,424(sp)
    800049ce:	a015                	j	800049f2 <exec+0x336>
    800049d0:	e1243423          	sd	s2,-504(s0)
    800049d4:	7dba                	ld	s11,424(sp)
    800049d6:	a831                	j	800049f2 <exec+0x336>
    800049d8:	e1243423          	sd	s2,-504(s0)
    800049dc:	7dba                	ld	s11,424(sp)
    800049de:	a811                	j	800049f2 <exec+0x336>
    800049e0:	e1243423          	sd	s2,-504(s0)
    800049e4:	7dba                	ld	s11,424(sp)
    800049e6:	a031                	j	800049f2 <exec+0x336>
  ip = 0;
    800049e8:	4a01                	li	s4,0
    800049ea:	a021                	j	800049f2 <exec+0x336>
    800049ec:	4a01                	li	s4,0
  if(pagetable)
    800049ee:	a011                	j	800049f2 <exec+0x336>
    800049f0:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800049f2:	e0843583          	ld	a1,-504(s0)
    800049f6:	855a                	mv	a0,s6
    800049f8:	9c8fd0ef          	jal	80001bc0 <proc_freepagetable>
  return -1;
    800049fc:	557d                	li	a0,-1
  if(ip){
    800049fe:	000a1b63          	bnez	s4,80004a14 <exec+0x358>
    80004a02:	79be                	ld	s3,488(sp)
    80004a04:	7a1e                	ld	s4,480(sp)
    80004a06:	6afe                	ld	s5,472(sp)
    80004a08:	6b5e                	ld	s6,464(sp)
    80004a0a:	6bbe                	ld	s7,456(sp)
    80004a0c:	6c1e                	ld	s8,448(sp)
    80004a0e:	7cfa                	ld	s9,440(sp)
    80004a10:	7d5a                	ld	s10,432(sp)
    80004a12:	bb21                	j	8000472a <exec+0x6e>
    80004a14:	79be                	ld	s3,488(sp)
    80004a16:	6afe                	ld	s5,472(sp)
    80004a18:	6b5e                	ld	s6,464(sp)
    80004a1a:	6bbe                	ld	s7,456(sp)
    80004a1c:	6c1e                	ld	s8,448(sp)
    80004a1e:	7cfa                	ld	s9,440(sp)
    80004a20:	7d5a                	ld	s10,432(sp)
    80004a22:	b9ed                	j	8000471c <exec+0x60>
    80004a24:	6b5e                	ld	s6,464(sp)
    80004a26:	b9dd                	j	8000471c <exec+0x60>
  sz = sz1;
    80004a28:	e0843983          	ld	s3,-504(s0)
    80004a2c:	b595                	j	80004890 <exec+0x1d4>

0000000080004a2e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a2e:	7179                	addi	sp,sp,-48
    80004a30:	f406                	sd	ra,40(sp)
    80004a32:	f022                	sd	s0,32(sp)
    80004a34:	ec26                	sd	s1,24(sp)
    80004a36:	e84a                	sd	s2,16(sp)
    80004a38:	1800                	addi	s0,sp,48
    80004a3a:	892e                	mv	s2,a1
    80004a3c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a3e:	fdc40593          	addi	a1,s0,-36
    80004a42:	fa1fd0ef          	jal	800029e2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a46:	fdc42703          	lw	a4,-36(s0)
    80004a4a:	47bd                	li	a5,15
    80004a4c:	02e7e963          	bltu	a5,a4,80004a7e <argfd+0x50>
    80004a50:	e91fc0ef          	jal	800018e0 <myproc>
    80004a54:	fdc42703          	lw	a4,-36(s0)
    80004a58:	01a70793          	addi	a5,a4,26
    80004a5c:	078e                	slli	a5,a5,0x3
    80004a5e:	953e                	add	a0,a0,a5
    80004a60:	611c                	ld	a5,0(a0)
    80004a62:	c385                	beqz	a5,80004a82 <argfd+0x54>
    return -1;
  if(pfd)
    80004a64:	00090463          	beqz	s2,80004a6c <argfd+0x3e>
    *pfd = fd;
    80004a68:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a6c:	4501                	li	a0,0
  if(pf)
    80004a6e:	c091                	beqz	s1,80004a72 <argfd+0x44>
    *pf = f;
    80004a70:	e09c                	sd	a5,0(s1)
}
    80004a72:	70a2                	ld	ra,40(sp)
    80004a74:	7402                	ld	s0,32(sp)
    80004a76:	64e2                	ld	s1,24(sp)
    80004a78:	6942                	ld	s2,16(sp)
    80004a7a:	6145                	addi	sp,sp,48
    80004a7c:	8082                	ret
    return -1;
    80004a7e:	557d                	li	a0,-1
    80004a80:	bfcd                	j	80004a72 <argfd+0x44>
    80004a82:	557d                	li	a0,-1
    80004a84:	b7fd                	j	80004a72 <argfd+0x44>

0000000080004a86 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004a86:	1101                	addi	sp,sp,-32
    80004a88:	ec06                	sd	ra,24(sp)
    80004a8a:	e822                	sd	s0,16(sp)
    80004a8c:	e426                	sd	s1,8(sp)
    80004a8e:	1000                	addi	s0,sp,32
    80004a90:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004a92:	e4ffc0ef          	jal	800018e0 <myproc>
    80004a96:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004a98:	0d050793          	addi	a5,a0,208
    80004a9c:	4501                	li	a0,0
    80004a9e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004aa0:	6398                	ld	a4,0(a5)
    80004aa2:	cb19                	beqz	a4,80004ab8 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004aa4:	2505                	addiw	a0,a0,1
    80004aa6:	07a1                	addi	a5,a5,8
    80004aa8:	fed51ce3          	bne	a0,a3,80004aa0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004aac:	557d                	li	a0,-1
}
    80004aae:	60e2                	ld	ra,24(sp)
    80004ab0:	6442                	ld	s0,16(sp)
    80004ab2:	64a2                	ld	s1,8(sp)
    80004ab4:	6105                	addi	sp,sp,32
    80004ab6:	8082                	ret
      p->ofile[fd] = f;
    80004ab8:	01a50793          	addi	a5,a0,26
    80004abc:	078e                	slli	a5,a5,0x3
    80004abe:	963e                	add	a2,a2,a5
    80004ac0:	e204                	sd	s1,0(a2)
      return fd;
    80004ac2:	b7f5                	j	80004aae <fdalloc+0x28>

0000000080004ac4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ac4:	715d                	addi	sp,sp,-80
    80004ac6:	e486                	sd	ra,72(sp)
    80004ac8:	e0a2                	sd	s0,64(sp)
    80004aca:	fc26                	sd	s1,56(sp)
    80004acc:	f84a                	sd	s2,48(sp)
    80004ace:	f44e                	sd	s3,40(sp)
    80004ad0:	ec56                	sd	s5,24(sp)
    80004ad2:	e85a                	sd	s6,16(sp)
    80004ad4:	0880                	addi	s0,sp,80
    80004ad6:	8b2e                	mv	s6,a1
    80004ad8:	89b2                	mv	s3,a2
    80004ada:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004adc:	fb040593          	addi	a1,s0,-80
    80004ae0:	822ff0ef          	jal	80003b02 <nameiparent>
    80004ae4:	84aa                	mv	s1,a0
    80004ae6:	10050a63          	beqz	a0,80004bfa <create+0x136>
    return 0;

  ilock(dp);
    80004aea:	925fe0ef          	jal	8000340e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004aee:	4601                	li	a2,0
    80004af0:	fb040593          	addi	a1,s0,-80
    80004af4:	8526                	mv	a0,s1
    80004af6:	d8dfe0ef          	jal	80003882 <dirlookup>
    80004afa:	8aaa                	mv	s5,a0
    80004afc:	c129                	beqz	a0,80004b3e <create+0x7a>
    iunlockput(dp);
    80004afe:	8526                	mv	a0,s1
    80004b00:	b19fe0ef          	jal	80003618 <iunlockput>
    ilock(ip);
    80004b04:	8556                	mv	a0,s5
    80004b06:	909fe0ef          	jal	8000340e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b0a:	4789                	li	a5,2
    80004b0c:	02fb1463          	bne	s6,a5,80004b34 <create+0x70>
    80004b10:	044ad783          	lhu	a5,68(s5)
    80004b14:	37f9                	addiw	a5,a5,-2
    80004b16:	17c2                	slli	a5,a5,0x30
    80004b18:	93c1                	srli	a5,a5,0x30
    80004b1a:	4705                	li	a4,1
    80004b1c:	00f76c63          	bltu	a4,a5,80004b34 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b20:	8556                	mv	a0,s5
    80004b22:	60a6                	ld	ra,72(sp)
    80004b24:	6406                	ld	s0,64(sp)
    80004b26:	74e2                	ld	s1,56(sp)
    80004b28:	7942                	ld	s2,48(sp)
    80004b2a:	79a2                	ld	s3,40(sp)
    80004b2c:	6ae2                	ld	s5,24(sp)
    80004b2e:	6b42                	ld	s6,16(sp)
    80004b30:	6161                	addi	sp,sp,80
    80004b32:	8082                	ret
    iunlockput(ip);
    80004b34:	8556                	mv	a0,s5
    80004b36:	ae3fe0ef          	jal	80003618 <iunlockput>
    return 0;
    80004b3a:	4a81                	li	s5,0
    80004b3c:	b7d5                	j	80004b20 <create+0x5c>
    80004b3e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b40:	85da                	mv	a1,s6
    80004b42:	4088                	lw	a0,0(s1)
    80004b44:	f5afe0ef          	jal	8000329e <ialloc>
    80004b48:	8a2a                	mv	s4,a0
    80004b4a:	cd15                	beqz	a0,80004b86 <create+0xc2>
  ilock(ip);
    80004b4c:	8c3fe0ef          	jal	8000340e <ilock>
  ip->major = major;
    80004b50:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b54:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b58:	4905                	li	s2,1
    80004b5a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b5e:	8552                	mv	a0,s4
    80004b60:	ffafe0ef          	jal	8000335a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b64:	032b0763          	beq	s6,s2,80004b92 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b68:	004a2603          	lw	a2,4(s4)
    80004b6c:	fb040593          	addi	a1,s0,-80
    80004b70:	8526                	mv	a0,s1
    80004b72:	eddfe0ef          	jal	80003a4e <dirlink>
    80004b76:	06054563          	bltz	a0,80004be0 <create+0x11c>
  iunlockput(dp);
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	a9dfe0ef          	jal	80003618 <iunlockput>
  return ip;
    80004b80:	8ad2                	mv	s5,s4
    80004b82:	7a02                	ld	s4,32(sp)
    80004b84:	bf71                	j	80004b20 <create+0x5c>
    iunlockput(dp);
    80004b86:	8526                	mv	a0,s1
    80004b88:	a91fe0ef          	jal	80003618 <iunlockput>
    return 0;
    80004b8c:	8ad2                	mv	s5,s4
    80004b8e:	7a02                	ld	s4,32(sp)
    80004b90:	bf41                	j	80004b20 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004b92:	004a2603          	lw	a2,4(s4)
    80004b96:	00003597          	auipc	a1,0x3
    80004b9a:	a8a58593          	addi	a1,a1,-1398 # 80007620 <etext+0x620>
    80004b9e:	8552                	mv	a0,s4
    80004ba0:	eaffe0ef          	jal	80003a4e <dirlink>
    80004ba4:	02054e63          	bltz	a0,80004be0 <create+0x11c>
    80004ba8:	40d0                	lw	a2,4(s1)
    80004baa:	00003597          	auipc	a1,0x3
    80004bae:	a7e58593          	addi	a1,a1,-1410 # 80007628 <etext+0x628>
    80004bb2:	8552                	mv	a0,s4
    80004bb4:	e9bfe0ef          	jal	80003a4e <dirlink>
    80004bb8:	02054463          	bltz	a0,80004be0 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bbc:	004a2603          	lw	a2,4(s4)
    80004bc0:	fb040593          	addi	a1,s0,-80
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	e89fe0ef          	jal	80003a4e <dirlink>
    80004bca:	00054b63          	bltz	a0,80004be0 <create+0x11c>
    dp->nlink++;  // for ".."
    80004bce:	04a4d783          	lhu	a5,74(s1)
    80004bd2:	2785                	addiw	a5,a5,1
    80004bd4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bd8:	8526                	mv	a0,s1
    80004bda:	f80fe0ef          	jal	8000335a <iupdate>
    80004bde:	bf71                	j	80004b7a <create+0xb6>
  ip->nlink = 0;
    80004be0:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004be4:	8552                	mv	a0,s4
    80004be6:	f74fe0ef          	jal	8000335a <iupdate>
  iunlockput(ip);
    80004bea:	8552                	mv	a0,s4
    80004bec:	a2dfe0ef          	jal	80003618 <iunlockput>
  iunlockput(dp);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	a27fe0ef          	jal	80003618 <iunlockput>
  return 0;
    80004bf6:	7a02                	ld	s4,32(sp)
    80004bf8:	b725                	j	80004b20 <create+0x5c>
    return 0;
    80004bfa:	8aaa                	mv	s5,a0
    80004bfc:	b715                	j	80004b20 <create+0x5c>

0000000080004bfe <sys_dup>:
{
    80004bfe:	7179                	addi	sp,sp,-48
    80004c00:	f406                	sd	ra,40(sp)
    80004c02:	f022                	sd	s0,32(sp)
    80004c04:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c06:	fd840613          	addi	a2,s0,-40
    80004c0a:	4581                	li	a1,0
    80004c0c:	4501                	li	a0,0
    80004c0e:	e21ff0ef          	jal	80004a2e <argfd>
    return -1;
    80004c12:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c14:	02054363          	bltz	a0,80004c3a <sys_dup+0x3c>
    80004c18:	ec26                	sd	s1,24(sp)
    80004c1a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c1c:	fd843903          	ld	s2,-40(s0)
    80004c20:	854a                	mv	a0,s2
    80004c22:	e65ff0ef          	jal	80004a86 <fdalloc>
    80004c26:	84aa                	mv	s1,a0
    return -1;
    80004c28:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c2a:	00054d63          	bltz	a0,80004c44 <sys_dup+0x46>
  filedup(f);
    80004c2e:	854a                	mv	a0,s2
    80004c30:	c48ff0ef          	jal	80004078 <filedup>
  return fd;
    80004c34:	87a6                	mv	a5,s1
    80004c36:	64e2                	ld	s1,24(sp)
    80004c38:	6942                	ld	s2,16(sp)
}
    80004c3a:	853e                	mv	a0,a5
    80004c3c:	70a2                	ld	ra,40(sp)
    80004c3e:	7402                	ld	s0,32(sp)
    80004c40:	6145                	addi	sp,sp,48
    80004c42:	8082                	ret
    80004c44:	64e2                	ld	s1,24(sp)
    80004c46:	6942                	ld	s2,16(sp)
    80004c48:	bfcd                	j	80004c3a <sys_dup+0x3c>

0000000080004c4a <sys_read>:
{
    80004c4a:	7179                	addi	sp,sp,-48
    80004c4c:	f406                	sd	ra,40(sp)
    80004c4e:	f022                	sd	s0,32(sp)
    80004c50:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c52:	fd840593          	addi	a1,s0,-40
    80004c56:	4505                	li	a0,1
    80004c58:	da7fd0ef          	jal	800029fe <argaddr>
  argint(2, &n);
    80004c5c:	fe440593          	addi	a1,s0,-28
    80004c60:	4509                	li	a0,2
    80004c62:	d81fd0ef          	jal	800029e2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c66:	fe840613          	addi	a2,s0,-24
    80004c6a:	4581                	li	a1,0
    80004c6c:	4501                	li	a0,0
    80004c6e:	dc1ff0ef          	jal	80004a2e <argfd>
    80004c72:	87aa                	mv	a5,a0
    return -1;
    80004c74:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c76:	0007ca63          	bltz	a5,80004c8a <sys_read+0x40>
  return fileread(f, p, n);
    80004c7a:	fe442603          	lw	a2,-28(s0)
    80004c7e:	fd843583          	ld	a1,-40(s0)
    80004c82:	fe843503          	ld	a0,-24(s0)
    80004c86:	d58ff0ef          	jal	800041de <fileread>
}
    80004c8a:	70a2                	ld	ra,40(sp)
    80004c8c:	7402                	ld	s0,32(sp)
    80004c8e:	6145                	addi	sp,sp,48
    80004c90:	8082                	ret

0000000080004c92 <sys_write>:
{
    80004c92:	7179                	addi	sp,sp,-48
    80004c94:	f406                	sd	ra,40(sp)
    80004c96:	f022                	sd	s0,32(sp)
    80004c98:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c9a:	fd840593          	addi	a1,s0,-40
    80004c9e:	4505                	li	a0,1
    80004ca0:	d5ffd0ef          	jal	800029fe <argaddr>
  argint(2, &n);
    80004ca4:	fe440593          	addi	a1,s0,-28
    80004ca8:	4509                	li	a0,2
    80004caa:	d39fd0ef          	jal	800029e2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004cae:	fe840613          	addi	a2,s0,-24
    80004cb2:	4581                	li	a1,0
    80004cb4:	4501                	li	a0,0
    80004cb6:	d79ff0ef          	jal	80004a2e <argfd>
    80004cba:	87aa                	mv	a5,a0
    return -1;
    80004cbc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cbe:	0007ca63          	bltz	a5,80004cd2 <sys_write+0x40>
  return filewrite(f, p, n);
    80004cc2:	fe442603          	lw	a2,-28(s0)
    80004cc6:	fd843583          	ld	a1,-40(s0)
    80004cca:	fe843503          	ld	a0,-24(s0)
    80004cce:	dceff0ef          	jal	8000429c <filewrite>
}
    80004cd2:	70a2                	ld	ra,40(sp)
    80004cd4:	7402                	ld	s0,32(sp)
    80004cd6:	6145                	addi	sp,sp,48
    80004cd8:	8082                	ret

0000000080004cda <sys_close>:
{
    80004cda:	1101                	addi	sp,sp,-32
    80004cdc:	ec06                	sd	ra,24(sp)
    80004cde:	e822                	sd	s0,16(sp)
    80004ce0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ce2:	fe040613          	addi	a2,s0,-32
    80004ce6:	fec40593          	addi	a1,s0,-20
    80004cea:	4501                	li	a0,0
    80004cec:	d43ff0ef          	jal	80004a2e <argfd>
    return -1;
    80004cf0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004cf2:	02054063          	bltz	a0,80004d12 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004cf6:	bebfc0ef          	jal	800018e0 <myproc>
    80004cfa:	fec42783          	lw	a5,-20(s0)
    80004cfe:	07e9                	addi	a5,a5,26
    80004d00:	078e                	slli	a5,a5,0x3
    80004d02:	953e                	add	a0,a0,a5
    80004d04:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d08:	fe043503          	ld	a0,-32(s0)
    80004d0c:	bb2ff0ef          	jal	800040be <fileclose>
  return 0;
    80004d10:	4781                	li	a5,0
}
    80004d12:	853e                	mv	a0,a5
    80004d14:	60e2                	ld	ra,24(sp)
    80004d16:	6442                	ld	s0,16(sp)
    80004d18:	6105                	addi	sp,sp,32
    80004d1a:	8082                	ret

0000000080004d1c <sys_fstat>:
{
    80004d1c:	1101                	addi	sp,sp,-32
    80004d1e:	ec06                	sd	ra,24(sp)
    80004d20:	e822                	sd	s0,16(sp)
    80004d22:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d24:	fe040593          	addi	a1,s0,-32
    80004d28:	4505                	li	a0,1
    80004d2a:	cd5fd0ef          	jal	800029fe <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d2e:	fe840613          	addi	a2,s0,-24
    80004d32:	4581                	li	a1,0
    80004d34:	4501                	li	a0,0
    80004d36:	cf9ff0ef          	jal	80004a2e <argfd>
    80004d3a:	87aa                	mv	a5,a0
    return -1;
    80004d3c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d3e:	0007c863          	bltz	a5,80004d4e <sys_fstat+0x32>
  return filestat(f, st);
    80004d42:	fe043583          	ld	a1,-32(s0)
    80004d46:	fe843503          	ld	a0,-24(s0)
    80004d4a:	c36ff0ef          	jal	80004180 <filestat>
}
    80004d4e:	60e2                	ld	ra,24(sp)
    80004d50:	6442                	ld	s0,16(sp)
    80004d52:	6105                	addi	sp,sp,32
    80004d54:	8082                	ret

0000000080004d56 <sys_link>:
{
    80004d56:	7169                	addi	sp,sp,-304
    80004d58:	f606                	sd	ra,296(sp)
    80004d5a:	f222                	sd	s0,288(sp)
    80004d5c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d5e:	08000613          	li	a2,128
    80004d62:	ed040593          	addi	a1,s0,-304
    80004d66:	4501                	li	a0,0
    80004d68:	cb3fd0ef          	jal	80002a1a <argstr>
    return -1;
    80004d6c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d6e:	0c054e63          	bltz	a0,80004e4a <sys_link+0xf4>
    80004d72:	08000613          	li	a2,128
    80004d76:	f5040593          	addi	a1,s0,-176
    80004d7a:	4505                	li	a0,1
    80004d7c:	c9ffd0ef          	jal	80002a1a <argstr>
    return -1;
    80004d80:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d82:	0c054463          	bltz	a0,80004e4a <sys_link+0xf4>
    80004d86:	ee26                	sd	s1,280(sp)
  begin_op();
    80004d88:	f1dfe0ef          	jal	80003ca4 <begin_op>
  if((ip = namei(old)) == 0){
    80004d8c:	ed040513          	addi	a0,s0,-304
    80004d90:	d59fe0ef          	jal	80003ae8 <namei>
    80004d94:	84aa                	mv	s1,a0
    80004d96:	c53d                	beqz	a0,80004e04 <sys_link+0xae>
  ilock(ip);
    80004d98:	e76fe0ef          	jal	8000340e <ilock>
  if(ip->type == T_DIR){
    80004d9c:	04449703          	lh	a4,68(s1)
    80004da0:	4785                	li	a5,1
    80004da2:	06f70663          	beq	a4,a5,80004e0e <sys_link+0xb8>
    80004da6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004da8:	04a4d783          	lhu	a5,74(s1)
    80004dac:	2785                	addiw	a5,a5,1
    80004dae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004db2:	8526                	mv	a0,s1
    80004db4:	da6fe0ef          	jal	8000335a <iupdate>
  iunlock(ip);
    80004db8:	8526                	mv	a0,s1
    80004dba:	f02fe0ef          	jal	800034bc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004dbe:	fd040593          	addi	a1,s0,-48
    80004dc2:	f5040513          	addi	a0,s0,-176
    80004dc6:	d3dfe0ef          	jal	80003b02 <nameiparent>
    80004dca:	892a                	mv	s2,a0
    80004dcc:	cd21                	beqz	a0,80004e24 <sys_link+0xce>
  ilock(dp);
    80004dce:	e40fe0ef          	jal	8000340e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004dd2:	00092703          	lw	a4,0(s2)
    80004dd6:	409c                	lw	a5,0(s1)
    80004dd8:	04f71363          	bne	a4,a5,80004e1e <sys_link+0xc8>
    80004ddc:	40d0                	lw	a2,4(s1)
    80004dde:	fd040593          	addi	a1,s0,-48
    80004de2:	854a                	mv	a0,s2
    80004de4:	c6bfe0ef          	jal	80003a4e <dirlink>
    80004de8:	02054b63          	bltz	a0,80004e1e <sys_link+0xc8>
  iunlockput(dp);
    80004dec:	854a                	mv	a0,s2
    80004dee:	82bfe0ef          	jal	80003618 <iunlockput>
  iput(ip);
    80004df2:	8526                	mv	a0,s1
    80004df4:	f9cfe0ef          	jal	80003590 <iput>
  end_op();
    80004df8:	f17fe0ef          	jal	80003d0e <end_op>
  return 0;
    80004dfc:	4781                	li	a5,0
    80004dfe:	64f2                	ld	s1,280(sp)
    80004e00:	6952                	ld	s2,272(sp)
    80004e02:	a0a1                	j	80004e4a <sys_link+0xf4>
    end_op();
    80004e04:	f0bfe0ef          	jal	80003d0e <end_op>
    return -1;
    80004e08:	57fd                	li	a5,-1
    80004e0a:	64f2                	ld	s1,280(sp)
    80004e0c:	a83d                	j	80004e4a <sys_link+0xf4>
    iunlockput(ip);
    80004e0e:	8526                	mv	a0,s1
    80004e10:	809fe0ef          	jal	80003618 <iunlockput>
    end_op();
    80004e14:	efbfe0ef          	jal	80003d0e <end_op>
    return -1;
    80004e18:	57fd                	li	a5,-1
    80004e1a:	64f2                	ld	s1,280(sp)
    80004e1c:	a03d                	j	80004e4a <sys_link+0xf4>
    iunlockput(dp);
    80004e1e:	854a                	mv	a0,s2
    80004e20:	ff8fe0ef          	jal	80003618 <iunlockput>
  ilock(ip);
    80004e24:	8526                	mv	a0,s1
    80004e26:	de8fe0ef          	jal	8000340e <ilock>
  ip->nlink--;
    80004e2a:	04a4d783          	lhu	a5,74(s1)
    80004e2e:	37fd                	addiw	a5,a5,-1
    80004e30:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e34:	8526                	mv	a0,s1
    80004e36:	d24fe0ef          	jal	8000335a <iupdate>
  iunlockput(ip);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	fdcfe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004e40:	ecffe0ef          	jal	80003d0e <end_op>
  return -1;
    80004e44:	57fd                	li	a5,-1
    80004e46:	64f2                	ld	s1,280(sp)
    80004e48:	6952                	ld	s2,272(sp)
}
    80004e4a:	853e                	mv	a0,a5
    80004e4c:	70b2                	ld	ra,296(sp)
    80004e4e:	7412                	ld	s0,288(sp)
    80004e50:	6155                	addi	sp,sp,304
    80004e52:	8082                	ret

0000000080004e54 <sys_unlink>:
{
    80004e54:	7151                	addi	sp,sp,-240
    80004e56:	f586                	sd	ra,232(sp)
    80004e58:	f1a2                	sd	s0,224(sp)
    80004e5a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e5c:	08000613          	li	a2,128
    80004e60:	f3040593          	addi	a1,s0,-208
    80004e64:	4501                	li	a0,0
    80004e66:	bb5fd0ef          	jal	80002a1a <argstr>
    80004e6a:	16054063          	bltz	a0,80004fca <sys_unlink+0x176>
    80004e6e:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e70:	e35fe0ef          	jal	80003ca4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e74:	fb040593          	addi	a1,s0,-80
    80004e78:	f3040513          	addi	a0,s0,-208
    80004e7c:	c87fe0ef          	jal	80003b02 <nameiparent>
    80004e80:	84aa                	mv	s1,a0
    80004e82:	c945                	beqz	a0,80004f32 <sys_unlink+0xde>
  ilock(dp);
    80004e84:	d8afe0ef          	jal	8000340e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004e88:	00002597          	auipc	a1,0x2
    80004e8c:	79858593          	addi	a1,a1,1944 # 80007620 <etext+0x620>
    80004e90:	fb040513          	addi	a0,s0,-80
    80004e94:	9d9fe0ef          	jal	8000386c <namecmp>
    80004e98:	10050e63          	beqz	a0,80004fb4 <sys_unlink+0x160>
    80004e9c:	00002597          	auipc	a1,0x2
    80004ea0:	78c58593          	addi	a1,a1,1932 # 80007628 <etext+0x628>
    80004ea4:	fb040513          	addi	a0,s0,-80
    80004ea8:	9c5fe0ef          	jal	8000386c <namecmp>
    80004eac:	10050463          	beqz	a0,80004fb4 <sys_unlink+0x160>
    80004eb0:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004eb2:	f2c40613          	addi	a2,s0,-212
    80004eb6:	fb040593          	addi	a1,s0,-80
    80004eba:	8526                	mv	a0,s1
    80004ebc:	9c7fe0ef          	jal	80003882 <dirlookup>
    80004ec0:	892a                	mv	s2,a0
    80004ec2:	0e050863          	beqz	a0,80004fb2 <sys_unlink+0x15e>
  ilock(ip);
    80004ec6:	d48fe0ef          	jal	8000340e <ilock>
  if(ip->nlink < 1)
    80004eca:	04a91783          	lh	a5,74(s2)
    80004ece:	06f05763          	blez	a5,80004f3c <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ed2:	04491703          	lh	a4,68(s2)
    80004ed6:	4785                	li	a5,1
    80004ed8:	06f70963          	beq	a4,a5,80004f4a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004edc:	4641                	li	a2,16
    80004ede:	4581                	li	a1,0
    80004ee0:	fc040513          	addi	a0,s0,-64
    80004ee4:	de5fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ee8:	4741                	li	a4,16
    80004eea:	f2c42683          	lw	a3,-212(s0)
    80004eee:	fc040613          	addi	a2,s0,-64
    80004ef2:	4581                	li	a1,0
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	869fe0ef          	jal	8000375e <writei>
    80004efa:	47c1                	li	a5,16
    80004efc:	08f51b63          	bne	a0,a5,80004f92 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004f00:	04491703          	lh	a4,68(s2)
    80004f04:	4785                	li	a5,1
    80004f06:	08f70d63          	beq	a4,a5,80004fa0 <sys_unlink+0x14c>
  iunlockput(dp);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	f0cfe0ef          	jal	80003618 <iunlockput>
  ip->nlink--;
    80004f10:	04a95783          	lhu	a5,74(s2)
    80004f14:	37fd                	addiw	a5,a5,-1
    80004f16:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f1a:	854a                	mv	a0,s2
    80004f1c:	c3efe0ef          	jal	8000335a <iupdate>
  iunlockput(ip);
    80004f20:	854a                	mv	a0,s2
    80004f22:	ef6fe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004f26:	de9fe0ef          	jal	80003d0e <end_op>
  return 0;
    80004f2a:	4501                	li	a0,0
    80004f2c:	64ee                	ld	s1,216(sp)
    80004f2e:	694e                	ld	s2,208(sp)
    80004f30:	a849                	j	80004fc2 <sys_unlink+0x16e>
    end_op();
    80004f32:	dddfe0ef          	jal	80003d0e <end_op>
    return -1;
    80004f36:	557d                	li	a0,-1
    80004f38:	64ee                	ld	s1,216(sp)
    80004f3a:	a061                	j	80004fc2 <sys_unlink+0x16e>
    80004f3c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004f3e:	00002517          	auipc	a0,0x2
    80004f42:	6f250513          	addi	a0,a0,1778 # 80007630 <etext+0x630>
    80004f46:	84ffb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f4a:	04c92703          	lw	a4,76(s2)
    80004f4e:	02000793          	li	a5,32
    80004f52:	f8e7f5e3          	bgeu	a5,a4,80004edc <sys_unlink+0x88>
    80004f56:	e5ce                	sd	s3,200(sp)
    80004f58:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f5c:	4741                	li	a4,16
    80004f5e:	86ce                	mv	a3,s3
    80004f60:	f1840613          	addi	a2,s0,-232
    80004f64:	4581                	li	a1,0
    80004f66:	854a                	mv	a0,s2
    80004f68:	efafe0ef          	jal	80003662 <readi>
    80004f6c:	47c1                	li	a5,16
    80004f6e:	00f51c63          	bne	a0,a5,80004f86 <sys_unlink+0x132>
    if(de.inum != 0)
    80004f72:	f1845783          	lhu	a5,-232(s0)
    80004f76:	efa1                	bnez	a5,80004fce <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f78:	29c1                	addiw	s3,s3,16
    80004f7a:	04c92783          	lw	a5,76(s2)
    80004f7e:	fcf9efe3          	bltu	s3,a5,80004f5c <sys_unlink+0x108>
    80004f82:	69ae                	ld	s3,200(sp)
    80004f84:	bfa1                	j	80004edc <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004f86:	00002517          	auipc	a0,0x2
    80004f8a:	6c250513          	addi	a0,a0,1730 # 80007648 <etext+0x648>
    80004f8e:	807fb0ef          	jal	80000794 <panic>
    80004f92:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004f94:	00002517          	auipc	a0,0x2
    80004f98:	6cc50513          	addi	a0,a0,1740 # 80007660 <etext+0x660>
    80004f9c:	ff8fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004fa0:	04a4d783          	lhu	a5,74(s1)
    80004fa4:	37fd                	addiw	a5,a5,-1
    80004fa6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004faa:	8526                	mv	a0,s1
    80004fac:	baefe0ef          	jal	8000335a <iupdate>
    80004fb0:	bfa9                	j	80004f0a <sys_unlink+0xb6>
    80004fb2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	e62fe0ef          	jal	80003618 <iunlockput>
  end_op();
    80004fba:	d55fe0ef          	jal	80003d0e <end_op>
  return -1;
    80004fbe:	557d                	li	a0,-1
    80004fc0:	64ee                	ld	s1,216(sp)
}
    80004fc2:	70ae                	ld	ra,232(sp)
    80004fc4:	740e                	ld	s0,224(sp)
    80004fc6:	616d                	addi	sp,sp,240
    80004fc8:	8082                	ret
    return -1;
    80004fca:	557d                	li	a0,-1
    80004fcc:	bfdd                	j	80004fc2 <sys_unlink+0x16e>
    iunlockput(ip);
    80004fce:	854a                	mv	a0,s2
    80004fd0:	e48fe0ef          	jal	80003618 <iunlockput>
    goto bad;
    80004fd4:	694e                	ld	s2,208(sp)
    80004fd6:	69ae                	ld	s3,200(sp)
    80004fd8:	bff1                	j	80004fb4 <sys_unlink+0x160>

0000000080004fda <sys_open>:

uint64
sys_open(void)
{
    80004fda:	7131                	addi	sp,sp,-192
    80004fdc:	fd06                	sd	ra,184(sp)
    80004fde:	f922                	sd	s0,176(sp)
    80004fe0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004fe2:	f4c40593          	addi	a1,s0,-180
    80004fe6:	4505                	li	a0,1
    80004fe8:	9fbfd0ef          	jal	800029e2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004fec:	08000613          	li	a2,128
    80004ff0:	f5040593          	addi	a1,s0,-176
    80004ff4:	4501                	li	a0,0
    80004ff6:	a25fd0ef          	jal	80002a1a <argstr>
    80004ffa:	87aa                	mv	a5,a0
    return -1;
    80004ffc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ffe:	0a07c263          	bltz	a5,800050a2 <sys_open+0xc8>
    80005002:	f526                	sd	s1,168(sp)

  begin_op();
    80005004:	ca1fe0ef          	jal	80003ca4 <begin_op>

  if(omode & O_CREATE){
    80005008:	f4c42783          	lw	a5,-180(s0)
    8000500c:	2007f793          	andi	a5,a5,512
    80005010:	c3d5                	beqz	a5,800050b4 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005012:	4681                	li	a3,0
    80005014:	4601                	li	a2,0
    80005016:	4589                	li	a1,2
    80005018:	f5040513          	addi	a0,s0,-176
    8000501c:	aa9ff0ef          	jal	80004ac4 <create>
    80005020:	84aa                	mv	s1,a0
    if(ip == 0){
    80005022:	c541                	beqz	a0,800050aa <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005024:	04449703          	lh	a4,68(s1)
    80005028:	478d                	li	a5,3
    8000502a:	00f71763          	bne	a4,a5,80005038 <sys_open+0x5e>
    8000502e:	0464d703          	lhu	a4,70(s1)
    80005032:	47a5                	li	a5,9
    80005034:	0ae7ed63          	bltu	a5,a4,800050ee <sys_open+0x114>
    80005038:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000503a:	fe1fe0ef          	jal	8000401a <filealloc>
    8000503e:	892a                	mv	s2,a0
    80005040:	c179                	beqz	a0,80005106 <sys_open+0x12c>
    80005042:	ed4e                	sd	s3,152(sp)
    80005044:	a43ff0ef          	jal	80004a86 <fdalloc>
    80005048:	89aa                	mv	s3,a0
    8000504a:	0a054a63          	bltz	a0,800050fe <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000504e:	04449703          	lh	a4,68(s1)
    80005052:	478d                	li	a5,3
    80005054:	0cf70263          	beq	a4,a5,80005118 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005058:	4789                	li	a5,2
    8000505a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000505e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005062:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005066:	f4c42783          	lw	a5,-180(s0)
    8000506a:	0017c713          	xori	a4,a5,1
    8000506e:	8b05                	andi	a4,a4,1
    80005070:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005074:	0037f713          	andi	a4,a5,3
    80005078:	00e03733          	snez	a4,a4
    8000507c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005080:	4007f793          	andi	a5,a5,1024
    80005084:	c791                	beqz	a5,80005090 <sys_open+0xb6>
    80005086:	04449703          	lh	a4,68(s1)
    8000508a:	4789                	li	a5,2
    8000508c:	08f70d63          	beq	a4,a5,80005126 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005090:	8526                	mv	a0,s1
    80005092:	c2afe0ef          	jal	800034bc <iunlock>
  end_op();
    80005096:	c79fe0ef          	jal	80003d0e <end_op>

  return fd;
    8000509a:	854e                	mv	a0,s3
    8000509c:	74aa                	ld	s1,168(sp)
    8000509e:	790a                	ld	s2,160(sp)
    800050a0:	69ea                	ld	s3,152(sp)
}
    800050a2:	70ea                	ld	ra,184(sp)
    800050a4:	744a                	ld	s0,176(sp)
    800050a6:	6129                	addi	sp,sp,192
    800050a8:	8082                	ret
      end_op();
    800050aa:	c65fe0ef          	jal	80003d0e <end_op>
      return -1;
    800050ae:	557d                	li	a0,-1
    800050b0:	74aa                	ld	s1,168(sp)
    800050b2:	bfc5                	j	800050a2 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800050b4:	f5040513          	addi	a0,s0,-176
    800050b8:	a31fe0ef          	jal	80003ae8 <namei>
    800050bc:	84aa                	mv	s1,a0
    800050be:	c11d                	beqz	a0,800050e4 <sys_open+0x10a>
    ilock(ip);
    800050c0:	b4efe0ef          	jal	8000340e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050c4:	04449703          	lh	a4,68(s1)
    800050c8:	4785                	li	a5,1
    800050ca:	f4f71de3          	bne	a4,a5,80005024 <sys_open+0x4a>
    800050ce:	f4c42783          	lw	a5,-180(s0)
    800050d2:	d3bd                	beqz	a5,80005038 <sys_open+0x5e>
      iunlockput(ip);
    800050d4:	8526                	mv	a0,s1
    800050d6:	d42fe0ef          	jal	80003618 <iunlockput>
      end_op();
    800050da:	c35fe0ef          	jal	80003d0e <end_op>
      return -1;
    800050de:	557d                	li	a0,-1
    800050e0:	74aa                	ld	s1,168(sp)
    800050e2:	b7c1                	j	800050a2 <sys_open+0xc8>
      end_op();
    800050e4:	c2bfe0ef          	jal	80003d0e <end_op>
      return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	74aa                	ld	s1,168(sp)
    800050ec:	bf5d                	j	800050a2 <sys_open+0xc8>
    iunlockput(ip);
    800050ee:	8526                	mv	a0,s1
    800050f0:	d28fe0ef          	jal	80003618 <iunlockput>
    end_op();
    800050f4:	c1bfe0ef          	jal	80003d0e <end_op>
    return -1;
    800050f8:	557d                	li	a0,-1
    800050fa:	74aa                	ld	s1,168(sp)
    800050fc:	b75d                	j	800050a2 <sys_open+0xc8>
      fileclose(f);
    800050fe:	854a                	mv	a0,s2
    80005100:	fbffe0ef          	jal	800040be <fileclose>
    80005104:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005106:	8526                	mv	a0,s1
    80005108:	d10fe0ef          	jal	80003618 <iunlockput>
    end_op();
    8000510c:	c03fe0ef          	jal	80003d0e <end_op>
    return -1;
    80005110:	557d                	li	a0,-1
    80005112:	74aa                	ld	s1,168(sp)
    80005114:	790a                	ld	s2,160(sp)
    80005116:	b771                	j	800050a2 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005118:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000511c:	04649783          	lh	a5,70(s1)
    80005120:	02f91223          	sh	a5,36(s2)
    80005124:	bf3d                	j	80005062 <sys_open+0x88>
    itrunc(ip);
    80005126:	8526                	mv	a0,s1
    80005128:	bd4fe0ef          	jal	800034fc <itrunc>
    8000512c:	b795                	j	80005090 <sys_open+0xb6>

000000008000512e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000512e:	7175                	addi	sp,sp,-144
    80005130:	e506                	sd	ra,136(sp)
    80005132:	e122                	sd	s0,128(sp)
    80005134:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005136:	b6ffe0ef          	jal	80003ca4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000513a:	08000613          	li	a2,128
    8000513e:	f7040593          	addi	a1,s0,-144
    80005142:	4501                	li	a0,0
    80005144:	8d7fd0ef          	jal	80002a1a <argstr>
    80005148:	02054363          	bltz	a0,8000516e <sys_mkdir+0x40>
    8000514c:	4681                	li	a3,0
    8000514e:	4601                	li	a2,0
    80005150:	4585                	li	a1,1
    80005152:	f7040513          	addi	a0,s0,-144
    80005156:	96fff0ef          	jal	80004ac4 <create>
    8000515a:	c911                	beqz	a0,8000516e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000515c:	cbcfe0ef          	jal	80003618 <iunlockput>
  end_op();
    80005160:	baffe0ef          	jal	80003d0e <end_op>
  return 0;
    80005164:	4501                	li	a0,0
}
    80005166:	60aa                	ld	ra,136(sp)
    80005168:	640a                	ld	s0,128(sp)
    8000516a:	6149                	addi	sp,sp,144
    8000516c:	8082                	ret
    end_op();
    8000516e:	ba1fe0ef          	jal	80003d0e <end_op>
    return -1;
    80005172:	557d                	li	a0,-1
    80005174:	bfcd                	j	80005166 <sys_mkdir+0x38>

0000000080005176 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005176:	7135                	addi	sp,sp,-160
    80005178:	ed06                	sd	ra,152(sp)
    8000517a:	e922                	sd	s0,144(sp)
    8000517c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000517e:	b27fe0ef          	jal	80003ca4 <begin_op>
  argint(1, &major);
    80005182:	f6c40593          	addi	a1,s0,-148
    80005186:	4505                	li	a0,1
    80005188:	85bfd0ef          	jal	800029e2 <argint>
  argint(2, &minor);
    8000518c:	f6840593          	addi	a1,s0,-152
    80005190:	4509                	li	a0,2
    80005192:	851fd0ef          	jal	800029e2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005196:	08000613          	li	a2,128
    8000519a:	f7040593          	addi	a1,s0,-144
    8000519e:	4501                	li	a0,0
    800051a0:	87bfd0ef          	jal	80002a1a <argstr>
    800051a4:	02054563          	bltz	a0,800051ce <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051a8:	f6841683          	lh	a3,-152(s0)
    800051ac:	f6c41603          	lh	a2,-148(s0)
    800051b0:	458d                	li	a1,3
    800051b2:	f7040513          	addi	a0,s0,-144
    800051b6:	90fff0ef          	jal	80004ac4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ba:	c911                	beqz	a0,800051ce <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051bc:	c5cfe0ef          	jal	80003618 <iunlockput>
  end_op();
    800051c0:	b4ffe0ef          	jal	80003d0e <end_op>
  return 0;
    800051c4:	4501                	li	a0,0
}
    800051c6:	60ea                	ld	ra,152(sp)
    800051c8:	644a                	ld	s0,144(sp)
    800051ca:	610d                	addi	sp,sp,160
    800051cc:	8082                	ret
    end_op();
    800051ce:	b41fe0ef          	jal	80003d0e <end_op>
    return -1;
    800051d2:	557d                	li	a0,-1
    800051d4:	bfcd                	j	800051c6 <sys_mknod+0x50>

00000000800051d6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800051d6:	7135                	addi	sp,sp,-160
    800051d8:	ed06                	sd	ra,152(sp)
    800051da:	e922                	sd	s0,144(sp)
    800051dc:	e14a                	sd	s2,128(sp)
    800051de:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800051e0:	f00fc0ef          	jal	800018e0 <myproc>
    800051e4:	892a                	mv	s2,a0
  
  begin_op();
    800051e6:	abffe0ef          	jal	80003ca4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800051ea:	08000613          	li	a2,128
    800051ee:	f6040593          	addi	a1,s0,-160
    800051f2:	4501                	li	a0,0
    800051f4:	827fd0ef          	jal	80002a1a <argstr>
    800051f8:	04054363          	bltz	a0,8000523e <sys_chdir+0x68>
    800051fc:	e526                	sd	s1,136(sp)
    800051fe:	f6040513          	addi	a0,s0,-160
    80005202:	8e7fe0ef          	jal	80003ae8 <namei>
    80005206:	84aa                	mv	s1,a0
    80005208:	c915                	beqz	a0,8000523c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000520a:	a04fe0ef          	jal	8000340e <ilock>
  if(ip->type != T_DIR){
    8000520e:	04449703          	lh	a4,68(s1)
    80005212:	4785                	li	a5,1
    80005214:	02f71963          	bne	a4,a5,80005246 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005218:	8526                	mv	a0,s1
    8000521a:	aa2fe0ef          	jal	800034bc <iunlock>
  iput(p->cwd);
    8000521e:	15093503          	ld	a0,336(s2)
    80005222:	b6efe0ef          	jal	80003590 <iput>
  end_op();
    80005226:	ae9fe0ef          	jal	80003d0e <end_op>
  p->cwd = ip;
    8000522a:	14993823          	sd	s1,336(s2)
  return 0;
    8000522e:	4501                	li	a0,0
    80005230:	64aa                	ld	s1,136(sp)
}
    80005232:	60ea                	ld	ra,152(sp)
    80005234:	644a                	ld	s0,144(sp)
    80005236:	690a                	ld	s2,128(sp)
    80005238:	610d                	addi	sp,sp,160
    8000523a:	8082                	ret
    8000523c:	64aa                	ld	s1,136(sp)
    end_op();
    8000523e:	ad1fe0ef          	jal	80003d0e <end_op>
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	b7fd                	j	80005232 <sys_chdir+0x5c>
    iunlockput(ip);
    80005246:	8526                	mv	a0,s1
    80005248:	bd0fe0ef          	jal	80003618 <iunlockput>
    end_op();
    8000524c:	ac3fe0ef          	jal	80003d0e <end_op>
    return -1;
    80005250:	557d                	li	a0,-1
    80005252:	64aa                	ld	s1,136(sp)
    80005254:	bff9                	j	80005232 <sys_chdir+0x5c>

0000000080005256 <sys_exec>:

uint64
sys_exec(void)
{
    80005256:	7121                	addi	sp,sp,-448
    80005258:	ff06                	sd	ra,440(sp)
    8000525a:	fb22                	sd	s0,432(sp)
    8000525c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000525e:	e4840593          	addi	a1,s0,-440
    80005262:	4505                	li	a0,1
    80005264:	f9afd0ef          	jal	800029fe <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005268:	08000613          	li	a2,128
    8000526c:	f5040593          	addi	a1,s0,-176
    80005270:	4501                	li	a0,0
    80005272:	fa8fd0ef          	jal	80002a1a <argstr>
    80005276:	87aa                	mv	a5,a0
    return -1;
    80005278:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000527a:	0c07c463          	bltz	a5,80005342 <sys_exec+0xec>
    8000527e:	f726                	sd	s1,424(sp)
    80005280:	f34a                	sd	s2,416(sp)
    80005282:	ef4e                	sd	s3,408(sp)
    80005284:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005286:	10000613          	li	a2,256
    8000528a:	4581                	li	a1,0
    8000528c:	e5040513          	addi	a0,s0,-432
    80005290:	a39fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005294:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005298:	89a6                	mv	s3,s1
    8000529a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000529c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052a0:	00391513          	slli	a0,s2,0x3
    800052a4:	e4040593          	addi	a1,s0,-448
    800052a8:	e4843783          	ld	a5,-440(s0)
    800052ac:	953e                	add	a0,a0,a5
    800052ae:	eaafd0ef          	jal	80002958 <fetchaddr>
    800052b2:	02054663          	bltz	a0,800052de <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800052b6:	e4043783          	ld	a5,-448(s0)
    800052ba:	c3a9                	beqz	a5,800052fc <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800052bc:	869fb0ef          	jal	80000b24 <kalloc>
    800052c0:	85aa                	mv	a1,a0
    800052c2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052c6:	cd01                	beqz	a0,800052de <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052c8:	6605                	lui	a2,0x1
    800052ca:	e4043503          	ld	a0,-448(s0)
    800052ce:	ed4fd0ef          	jal	800029a2 <fetchstr>
    800052d2:	00054663          	bltz	a0,800052de <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800052d6:	0905                	addi	s2,s2,1
    800052d8:	09a1                	addi	s3,s3,8
    800052da:	fd4913e3          	bne	s2,s4,800052a0 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052de:	f5040913          	addi	s2,s0,-176
    800052e2:	6088                	ld	a0,0(s1)
    800052e4:	c931                	beqz	a0,80005338 <sys_exec+0xe2>
    kfree(argv[i]);
    800052e6:	f5cfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800052ea:	04a1                	addi	s1,s1,8
    800052ec:	ff249be3          	bne	s1,s2,800052e2 <sys_exec+0x8c>
  return -1;
    800052f0:	557d                	li	a0,-1
    800052f2:	74ba                	ld	s1,424(sp)
    800052f4:	791a                	ld	s2,416(sp)
    800052f6:	69fa                	ld	s3,408(sp)
    800052f8:	6a5a                	ld	s4,400(sp)
    800052fa:	a0a1                	j	80005342 <sys_exec+0xec>
      argv[i] = 0;
    800052fc:	0009079b          	sext.w	a5,s2
    80005300:	078e                	slli	a5,a5,0x3
    80005302:	fd078793          	addi	a5,a5,-48
    80005306:	97a2                	add	a5,a5,s0
    80005308:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000530c:	e5040593          	addi	a1,s0,-432
    80005310:	f5040513          	addi	a0,s0,-176
    80005314:	ba8ff0ef          	jal	800046bc <exec>
    80005318:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000531a:	f5040993          	addi	s3,s0,-176
    8000531e:	6088                	ld	a0,0(s1)
    80005320:	c511                	beqz	a0,8000532c <sys_exec+0xd6>
    kfree(argv[i]);
    80005322:	f20fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005326:	04a1                	addi	s1,s1,8
    80005328:	ff349be3          	bne	s1,s3,8000531e <sys_exec+0xc8>
  return ret;
    8000532c:	854a                	mv	a0,s2
    8000532e:	74ba                	ld	s1,424(sp)
    80005330:	791a                	ld	s2,416(sp)
    80005332:	69fa                	ld	s3,408(sp)
    80005334:	6a5a                	ld	s4,400(sp)
    80005336:	a031                	j	80005342 <sys_exec+0xec>
  return -1;
    80005338:	557d                	li	a0,-1
    8000533a:	74ba                	ld	s1,424(sp)
    8000533c:	791a                	ld	s2,416(sp)
    8000533e:	69fa                	ld	s3,408(sp)
    80005340:	6a5a                	ld	s4,400(sp)
}
    80005342:	70fa                	ld	ra,440(sp)
    80005344:	745a                	ld	s0,432(sp)
    80005346:	6139                	addi	sp,sp,448
    80005348:	8082                	ret

000000008000534a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000534a:	7139                	addi	sp,sp,-64
    8000534c:	fc06                	sd	ra,56(sp)
    8000534e:	f822                	sd	s0,48(sp)
    80005350:	f426                	sd	s1,40(sp)
    80005352:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005354:	d8cfc0ef          	jal	800018e0 <myproc>
    80005358:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000535a:	fd840593          	addi	a1,s0,-40
    8000535e:	4501                	li	a0,0
    80005360:	e9efd0ef          	jal	800029fe <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005364:	fc840593          	addi	a1,s0,-56
    80005368:	fd040513          	addi	a0,s0,-48
    8000536c:	85cff0ef          	jal	800043c8 <pipealloc>
    return -1;
    80005370:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005372:	0a054463          	bltz	a0,8000541a <sys_pipe+0xd0>
  fd0 = -1;
    80005376:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000537a:	fd043503          	ld	a0,-48(s0)
    8000537e:	f08ff0ef          	jal	80004a86 <fdalloc>
    80005382:	fca42223          	sw	a0,-60(s0)
    80005386:	08054163          	bltz	a0,80005408 <sys_pipe+0xbe>
    8000538a:	fc843503          	ld	a0,-56(s0)
    8000538e:	ef8ff0ef          	jal	80004a86 <fdalloc>
    80005392:	fca42023          	sw	a0,-64(s0)
    80005396:	06054063          	bltz	a0,800053f6 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000539a:	4691                	li	a3,4
    8000539c:	fc440613          	addi	a2,s0,-60
    800053a0:	fd843583          	ld	a1,-40(s0)
    800053a4:	68a8                	ld	a0,80(s1)
    800053a6:	9acfc0ef          	jal	80001552 <copyout>
    800053aa:	00054e63          	bltz	a0,800053c6 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053ae:	4691                	li	a3,4
    800053b0:	fc040613          	addi	a2,s0,-64
    800053b4:	fd843583          	ld	a1,-40(s0)
    800053b8:	0591                	addi	a1,a1,4
    800053ba:	68a8                	ld	a0,80(s1)
    800053bc:	996fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053c0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053c2:	04055c63          	bgez	a0,8000541a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800053c6:	fc442783          	lw	a5,-60(s0)
    800053ca:	07e9                	addi	a5,a5,26
    800053cc:	078e                	slli	a5,a5,0x3
    800053ce:	97a6                	add	a5,a5,s1
    800053d0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800053d4:	fc042783          	lw	a5,-64(s0)
    800053d8:	07e9                	addi	a5,a5,26
    800053da:	078e                	slli	a5,a5,0x3
    800053dc:	94be                	add	s1,s1,a5
    800053de:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800053e2:	fd043503          	ld	a0,-48(s0)
    800053e6:	cd9fe0ef          	jal	800040be <fileclose>
    fileclose(wf);
    800053ea:	fc843503          	ld	a0,-56(s0)
    800053ee:	cd1fe0ef          	jal	800040be <fileclose>
    return -1;
    800053f2:	57fd                	li	a5,-1
    800053f4:	a01d                	j	8000541a <sys_pipe+0xd0>
    if(fd0 >= 0)
    800053f6:	fc442783          	lw	a5,-60(s0)
    800053fa:	0007c763          	bltz	a5,80005408 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800053fe:	07e9                	addi	a5,a5,26
    80005400:	078e                	slli	a5,a5,0x3
    80005402:	97a6                	add	a5,a5,s1
    80005404:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005408:	fd043503          	ld	a0,-48(s0)
    8000540c:	cb3fe0ef          	jal	800040be <fileclose>
    fileclose(wf);
    80005410:	fc843503          	ld	a0,-56(s0)
    80005414:	cabfe0ef          	jal	800040be <fileclose>
    return -1;
    80005418:	57fd                	li	a5,-1
}
    8000541a:	853e                	mv	a0,a5
    8000541c:	70e2                	ld	ra,56(sp)
    8000541e:	7442                	ld	s0,48(sp)
    80005420:	74a2                	ld	s1,40(sp)
    80005422:	6121                	addi	sp,sp,64
    80005424:	8082                	ret
	...

0000000080005430 <kernelvec>:
    80005430:	7111                	addi	sp,sp,-256
    80005432:	e006                	sd	ra,0(sp)
    80005434:	e40a                	sd	sp,8(sp)
    80005436:	e80e                	sd	gp,16(sp)
    80005438:	ec12                	sd	tp,24(sp)
    8000543a:	f016                	sd	t0,32(sp)
    8000543c:	f41a                	sd	t1,40(sp)
    8000543e:	f81e                	sd	t2,48(sp)
    80005440:	e4aa                	sd	a0,72(sp)
    80005442:	e8ae                	sd	a1,80(sp)
    80005444:	ecb2                	sd	a2,88(sp)
    80005446:	f0b6                	sd	a3,96(sp)
    80005448:	f4ba                	sd	a4,104(sp)
    8000544a:	f8be                	sd	a5,112(sp)
    8000544c:	fcc2                	sd	a6,120(sp)
    8000544e:	e146                	sd	a7,128(sp)
    80005450:	edf2                	sd	t3,216(sp)
    80005452:	f1f6                	sd	t4,224(sp)
    80005454:	f5fa                	sd	t5,232(sp)
    80005456:	f9fe                	sd	t6,240(sp)
    80005458:	c10fd0ef          	jal	80002868 <kerneltrap>
    8000545c:	6082                	ld	ra,0(sp)
    8000545e:	6122                	ld	sp,8(sp)
    80005460:	61c2                	ld	gp,16(sp)
    80005462:	7282                	ld	t0,32(sp)
    80005464:	7322                	ld	t1,40(sp)
    80005466:	73c2                	ld	t2,48(sp)
    80005468:	6526                	ld	a0,72(sp)
    8000546a:	65c6                	ld	a1,80(sp)
    8000546c:	6666                	ld	a2,88(sp)
    8000546e:	7686                	ld	a3,96(sp)
    80005470:	7726                	ld	a4,104(sp)
    80005472:	77c6                	ld	a5,112(sp)
    80005474:	7866                	ld	a6,120(sp)
    80005476:	688a                	ld	a7,128(sp)
    80005478:	6e6e                	ld	t3,216(sp)
    8000547a:	7e8e                	ld	t4,224(sp)
    8000547c:	7f2e                	ld	t5,232(sp)
    8000547e:	7fce                	ld	t6,240(sp)
    80005480:	6111                	addi	sp,sp,256
    80005482:	10200073          	sret
	...

000000008000548e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000548e:	1141                	addi	sp,sp,-16
    80005490:	e422                	sd	s0,8(sp)
    80005492:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005494:	0c0007b7          	lui	a5,0xc000
    80005498:	4705                	li	a4,1
    8000549a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000549c:	0c0007b7          	lui	a5,0xc000
    800054a0:	c3d8                	sw	a4,4(a5)
}
    800054a2:	6422                	ld	s0,8(sp)
    800054a4:	0141                	addi	sp,sp,16
    800054a6:	8082                	ret

00000000800054a8 <plicinithart>:

void
plicinithart(void)
{
    800054a8:	1141                	addi	sp,sp,-16
    800054aa:	e406                	sd	ra,8(sp)
    800054ac:	e022                	sd	s0,0(sp)
    800054ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054b0:	c04fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054b4:	0085171b          	slliw	a4,a0,0x8
    800054b8:	0c0027b7          	lui	a5,0xc002
    800054bc:	97ba                	add	a5,a5,a4
    800054be:	40200713          	li	a4,1026
    800054c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800054c6:	00d5151b          	slliw	a0,a0,0xd
    800054ca:	0c2017b7          	lui	a5,0xc201
    800054ce:	97aa                	add	a5,a5,a0
    800054d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800054d4:	60a2                	ld	ra,8(sp)
    800054d6:	6402                	ld	s0,0(sp)
    800054d8:	0141                	addi	sp,sp,16
    800054da:	8082                	ret

00000000800054dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800054dc:	1141                	addi	sp,sp,-16
    800054de:	e406                	sd	ra,8(sp)
    800054e0:	e022                	sd	s0,0(sp)
    800054e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054e4:	bd0fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800054e8:	00d5151b          	slliw	a0,a0,0xd
    800054ec:	0c2017b7          	lui	a5,0xc201
    800054f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800054f2:	43c8                	lw	a0,4(a5)
    800054f4:	60a2                	ld	ra,8(sp)
    800054f6:	6402                	ld	s0,0(sp)
    800054f8:	0141                	addi	sp,sp,16
    800054fa:	8082                	ret

00000000800054fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800054fc:	1101                	addi	sp,sp,-32
    800054fe:	ec06                	sd	ra,24(sp)
    80005500:	e822                	sd	s0,16(sp)
    80005502:	e426                	sd	s1,8(sp)
    80005504:	1000                	addi	s0,sp,32
    80005506:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005508:	bacfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000550c:	00d5151b          	slliw	a0,a0,0xd
    80005510:	0c2017b7          	lui	a5,0xc201
    80005514:	97aa                	add	a5,a5,a0
    80005516:	c3c4                	sw	s1,4(a5)
}
    80005518:	60e2                	ld	ra,24(sp)
    8000551a:	6442                	ld	s0,16(sp)
    8000551c:	64a2                	ld	s1,8(sp)
    8000551e:	6105                	addi	sp,sp,32
    80005520:	8082                	ret

0000000080005522 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005522:	1141                	addi	sp,sp,-16
    80005524:	e406                	sd	ra,8(sp)
    80005526:	e022                	sd	s0,0(sp)
    80005528:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000552a:	479d                	li	a5,7
    8000552c:	04a7ca63          	blt	a5,a0,80005580 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005530:	0001e797          	auipc	a5,0x1e
    80005534:	3f078793          	addi	a5,a5,1008 # 80023920 <disk>
    80005538:	97aa                	add	a5,a5,a0
    8000553a:	0187c783          	lbu	a5,24(a5)
    8000553e:	e7b9                	bnez	a5,8000558c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005540:	00451693          	slli	a3,a0,0x4
    80005544:	0001e797          	auipc	a5,0x1e
    80005548:	3dc78793          	addi	a5,a5,988 # 80023920 <disk>
    8000554c:	6398                	ld	a4,0(a5)
    8000554e:	9736                	add	a4,a4,a3
    80005550:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005554:	6398                	ld	a4,0(a5)
    80005556:	9736                	add	a4,a4,a3
    80005558:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000555c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005560:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005564:	97aa                	add	a5,a5,a0
    80005566:	4705                	li	a4,1
    80005568:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000556c:	0001e517          	auipc	a0,0x1e
    80005570:	3cc50513          	addi	a0,a0,972 # 80023938 <disk+0x18>
    80005574:	bd5fc0ef          	jal	80002148 <wakeup>
}
    80005578:	60a2                	ld	ra,8(sp)
    8000557a:	6402                	ld	s0,0(sp)
    8000557c:	0141                	addi	sp,sp,16
    8000557e:	8082                	ret
    panic("free_desc 1");
    80005580:	00002517          	auipc	a0,0x2
    80005584:	0f050513          	addi	a0,a0,240 # 80007670 <etext+0x670>
    80005588:	a0cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000558c:	00002517          	auipc	a0,0x2
    80005590:	0f450513          	addi	a0,a0,244 # 80007680 <etext+0x680>
    80005594:	a00fb0ef          	jal	80000794 <panic>

0000000080005598 <virtio_disk_init>:
{
    80005598:	1101                	addi	sp,sp,-32
    8000559a:	ec06                	sd	ra,24(sp)
    8000559c:	e822                	sd	s0,16(sp)
    8000559e:	e426                	sd	s1,8(sp)
    800055a0:	e04a                	sd	s2,0(sp)
    800055a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055a4:	00002597          	auipc	a1,0x2
    800055a8:	0ec58593          	addi	a1,a1,236 # 80007690 <etext+0x690>
    800055ac:	0001e517          	auipc	a0,0x1e
    800055b0:	49c50513          	addi	a0,a0,1180 # 80023a48 <disk+0x128>
    800055b4:	dc0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055b8:	100017b7          	lui	a5,0x10001
    800055bc:	4398                	lw	a4,0(a5)
    800055be:	2701                	sext.w	a4,a4
    800055c0:	747277b7          	lui	a5,0x74727
    800055c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800055c8:	18f71063          	bne	a4,a5,80005748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055cc:	100017b7          	lui	a5,0x10001
    800055d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800055d2:	439c                	lw	a5,0(a5)
    800055d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055d6:	4709                	li	a4,2
    800055d8:	16e79863          	bne	a5,a4,80005748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055dc:	100017b7          	lui	a5,0x10001
    800055e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800055e2:	439c                	lw	a5,0(a5)
    800055e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800055e6:	16e79163          	bne	a5,a4,80005748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800055ea:	100017b7          	lui	a5,0x10001
    800055ee:	47d8                	lw	a4,12(a5)
    800055f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800055f2:	554d47b7          	lui	a5,0x554d4
    800055f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800055fa:	14f71763          	bne	a4,a5,80005748 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800055fe:	100017b7          	lui	a5,0x10001
    80005602:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005606:	4705                	li	a4,1
    80005608:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000560a:	470d                	li	a4,3
    8000560c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000560e:	10001737          	lui	a4,0x10001
    80005612:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005614:	c7ffe737          	lui	a4,0xc7ffe
    80005618:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdacff>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000561c:	8ef9                	and	a3,a3,a4
    8000561e:	10001737          	lui	a4,0x10001
    80005622:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005624:	472d                	li	a4,11
    80005626:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005628:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000562c:	439c                	lw	a5,0(a5)
    8000562e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005632:	8ba1                	andi	a5,a5,8
    80005634:	12078063          	beqz	a5,80005754 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005638:	100017b7          	lui	a5,0x10001
    8000563c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005640:	100017b7          	lui	a5,0x10001
    80005644:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005648:	439c                	lw	a5,0(a5)
    8000564a:	2781                	sext.w	a5,a5
    8000564c:	10079a63          	bnez	a5,80005760 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005650:	100017b7          	lui	a5,0x10001
    80005654:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005658:	439c                	lw	a5,0(a5)
    8000565a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000565c:	10078863          	beqz	a5,8000576c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005660:	471d                	li	a4,7
    80005662:	10f77b63          	bgeu	a4,a5,80005778 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005666:	cbefb0ef          	jal	80000b24 <kalloc>
    8000566a:	0001e497          	auipc	s1,0x1e
    8000566e:	2b648493          	addi	s1,s1,694 # 80023920 <disk>
    80005672:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005674:	cb0fb0ef          	jal	80000b24 <kalloc>
    80005678:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000567a:	caafb0ef          	jal	80000b24 <kalloc>
    8000567e:	87aa                	mv	a5,a0
    80005680:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005682:	6088                	ld	a0,0(s1)
    80005684:	10050063          	beqz	a0,80005784 <virtio_disk_init+0x1ec>
    80005688:	0001e717          	auipc	a4,0x1e
    8000568c:	2a073703          	ld	a4,672(a4) # 80023928 <disk+0x8>
    80005690:	0e070a63          	beqz	a4,80005784 <virtio_disk_init+0x1ec>
    80005694:	0e078863          	beqz	a5,80005784 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005698:	6605                	lui	a2,0x1
    8000569a:	4581                	li	a1,0
    8000569c:	e2cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056a0:	0001e497          	auipc	s1,0x1e
    800056a4:	28048493          	addi	s1,s1,640 # 80023920 <disk>
    800056a8:	6605                	lui	a2,0x1
    800056aa:	4581                	li	a1,0
    800056ac:	6488                	ld	a0,8(s1)
    800056ae:	e1afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800056b2:	6605                	lui	a2,0x1
    800056b4:	4581                	li	a1,0
    800056b6:	6888                	ld	a0,16(s1)
    800056b8:	e10fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056bc:	100017b7          	lui	a5,0x10001
    800056c0:	4721                	li	a4,8
    800056c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056c4:	4098                	lw	a4,0(s1)
    800056c6:	100017b7          	lui	a5,0x10001
    800056ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056ce:	40d8                	lw	a4,4(s1)
    800056d0:	100017b7          	lui	a5,0x10001
    800056d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056d8:	649c                	ld	a5,8(s1)
    800056da:	0007869b          	sext.w	a3,a5
    800056de:	10001737          	lui	a4,0x10001
    800056e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800056e6:	9781                	srai	a5,a5,0x20
    800056e8:	10001737          	lui	a4,0x10001
    800056ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800056f0:	689c                	ld	a5,16(s1)
    800056f2:	0007869b          	sext.w	a3,a5
    800056f6:	10001737          	lui	a4,0x10001
    800056fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800056fe:	9781                	srai	a5,a5,0x20
    80005700:	10001737          	lui	a4,0x10001
    80005704:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005708:	10001737          	lui	a4,0x10001
    8000570c:	4785                	li	a5,1
    8000570e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005710:	00f48c23          	sb	a5,24(s1)
    80005714:	00f48ca3          	sb	a5,25(s1)
    80005718:	00f48d23          	sb	a5,26(s1)
    8000571c:	00f48da3          	sb	a5,27(s1)
    80005720:	00f48e23          	sb	a5,28(s1)
    80005724:	00f48ea3          	sb	a5,29(s1)
    80005728:	00f48f23          	sb	a5,30(s1)
    8000572c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005730:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005734:	100017b7          	lui	a5,0x10001
    80005738:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000573c:	60e2                	ld	ra,24(sp)
    8000573e:	6442                	ld	s0,16(sp)
    80005740:	64a2                	ld	s1,8(sp)
    80005742:	6902                	ld	s2,0(sp)
    80005744:	6105                	addi	sp,sp,32
    80005746:	8082                	ret
    panic("could not find virtio disk");
    80005748:	00002517          	auipc	a0,0x2
    8000574c:	f5850513          	addi	a0,a0,-168 # 800076a0 <etext+0x6a0>
    80005750:	844fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005754:	00002517          	auipc	a0,0x2
    80005758:	f6c50513          	addi	a0,a0,-148 # 800076c0 <etext+0x6c0>
    8000575c:	838fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005760:	00002517          	auipc	a0,0x2
    80005764:	f8050513          	addi	a0,a0,-128 # 800076e0 <etext+0x6e0>
    80005768:	82cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000576c:	00002517          	auipc	a0,0x2
    80005770:	f9450513          	addi	a0,a0,-108 # 80007700 <etext+0x700>
    80005774:	820fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005778:	00002517          	auipc	a0,0x2
    8000577c:	fa850513          	addi	a0,a0,-88 # 80007720 <etext+0x720>
    80005780:	814fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005784:	00002517          	auipc	a0,0x2
    80005788:	fbc50513          	addi	a0,a0,-68 # 80007740 <etext+0x740>
    8000578c:	808fb0ef          	jal	80000794 <panic>

0000000080005790 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005790:	7159                	addi	sp,sp,-112
    80005792:	f486                	sd	ra,104(sp)
    80005794:	f0a2                	sd	s0,96(sp)
    80005796:	eca6                	sd	s1,88(sp)
    80005798:	e8ca                	sd	s2,80(sp)
    8000579a:	e4ce                	sd	s3,72(sp)
    8000579c:	e0d2                	sd	s4,64(sp)
    8000579e:	fc56                	sd	s5,56(sp)
    800057a0:	f85a                	sd	s6,48(sp)
    800057a2:	f45e                	sd	s7,40(sp)
    800057a4:	f062                	sd	s8,32(sp)
    800057a6:	ec66                	sd	s9,24(sp)
    800057a8:	1880                	addi	s0,sp,112
    800057aa:	8a2a                	mv	s4,a0
    800057ac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057ae:	00c52c83          	lw	s9,12(a0)
    800057b2:	001c9c9b          	slliw	s9,s9,0x1
    800057b6:	1c82                	slli	s9,s9,0x20
    800057b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800057bc:	0001e517          	auipc	a0,0x1e
    800057c0:	28c50513          	addi	a0,a0,652 # 80023a48 <disk+0x128>
    800057c4:	c30fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    800057c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800057ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057cc:	0001eb17          	auipc	s6,0x1e
    800057d0:	154b0b13          	addi	s6,s6,340 # 80023920 <disk>
  for(int i = 0; i < 3; i++){
    800057d4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057d6:	0001ec17          	auipc	s8,0x1e
    800057da:	272c0c13          	addi	s8,s8,626 # 80023a48 <disk+0x128>
    800057de:	a8b9                	j	8000583c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800057e0:	00fb0733          	add	a4,s6,a5
    800057e4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800057e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057ea:	0207c563          	bltz	a5,80005814 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800057ee:	2905                	addiw	s2,s2,1
    800057f0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057f2:	05590963          	beq	s2,s5,80005844 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800057f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057f8:	0001e717          	auipc	a4,0x1e
    800057fc:	12870713          	addi	a4,a4,296 # 80023920 <disk>
    80005800:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005802:	01874683          	lbu	a3,24(a4)
    80005806:	fee9                	bnez	a3,800057e0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005808:	2785                	addiw	a5,a5,1
    8000580a:	0705                	addi	a4,a4,1
    8000580c:	fe979be3          	bne	a5,s1,80005802 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005810:	57fd                	li	a5,-1
    80005812:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005814:	01205d63          	blez	s2,8000582e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005818:	f9042503          	lw	a0,-112(s0)
    8000581c:	d07ff0ef          	jal	80005522 <free_desc>
      for(int j = 0; j < i; j++)
    80005820:	4785                	li	a5,1
    80005822:	0127d663          	bge	a5,s2,8000582e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005826:	f9442503          	lw	a0,-108(s0)
    8000582a:	cf9ff0ef          	jal	80005522 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000582e:	85e2                	mv	a1,s8
    80005830:	0001e517          	auipc	a0,0x1e
    80005834:	10850513          	addi	a0,a0,264 # 80023938 <disk+0x18>
    80005838:	8c5fc0ef          	jal	800020fc <sleep>
  for(int i = 0; i < 3; i++){
    8000583c:	f9040613          	addi	a2,s0,-112
    80005840:	894e                	mv	s2,s3
    80005842:	bf55                	j	800057f6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005844:	f9042503          	lw	a0,-112(s0)
    80005848:	00451693          	slli	a3,a0,0x4

  if(write)
    8000584c:	0001e797          	auipc	a5,0x1e
    80005850:	0d478793          	addi	a5,a5,212 # 80023920 <disk>
    80005854:	00a50713          	addi	a4,a0,10
    80005858:	0712                	slli	a4,a4,0x4
    8000585a:	973e                	add	a4,a4,a5
    8000585c:	01703633          	snez	a2,s7
    80005860:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005862:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005866:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000586a:	6398                	ld	a4,0(a5)
    8000586c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000586e:	0a868613          	addi	a2,a3,168
    80005872:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005874:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005876:	6390                	ld	a2,0(a5)
    80005878:	00d605b3          	add	a1,a2,a3
    8000587c:	4741                	li	a4,16
    8000587e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005880:	4805                	li	a6,1
    80005882:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005886:	f9442703          	lw	a4,-108(s0)
    8000588a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000588e:	0712                	slli	a4,a4,0x4
    80005890:	963a                	add	a2,a2,a4
    80005892:	058a0593          	addi	a1,s4,88
    80005896:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005898:	0007b883          	ld	a7,0(a5)
    8000589c:	9746                	add	a4,a4,a7
    8000589e:	40000613          	li	a2,1024
    800058a2:	c710                	sw	a2,8(a4)
  if(write)
    800058a4:	001bb613          	seqz	a2,s7
    800058a8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058ac:	00166613          	ori	a2,a2,1
    800058b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058b4:	f9842583          	lw	a1,-104(s0)
    800058b8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058bc:	00250613          	addi	a2,a0,2
    800058c0:	0612                	slli	a2,a2,0x4
    800058c2:	963e                	add	a2,a2,a5
    800058c4:	577d                	li	a4,-1
    800058c6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058ca:	0592                	slli	a1,a1,0x4
    800058cc:	98ae                	add	a7,a7,a1
    800058ce:	03068713          	addi	a4,a3,48
    800058d2:	973e                	add	a4,a4,a5
    800058d4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058d8:	6398                	ld	a4,0(a5)
    800058da:	972e                	add	a4,a4,a1
    800058dc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058e0:	4689                	li	a3,2
    800058e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058ea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800058ee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058f2:	6794                	ld	a3,8(a5)
    800058f4:	0026d703          	lhu	a4,2(a3)
    800058f8:	8b1d                	andi	a4,a4,7
    800058fa:	0706                	slli	a4,a4,0x1
    800058fc:	96ba                	add	a3,a3,a4
    800058fe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005902:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005906:	6798                	ld	a4,8(a5)
    80005908:	00275783          	lhu	a5,2(a4)
    8000590c:	2785                	addiw	a5,a5,1
    8000590e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005912:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005916:	100017b7          	lui	a5,0x10001
    8000591a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000591e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005922:	0001e917          	auipc	s2,0x1e
    80005926:	12690913          	addi	s2,s2,294 # 80023a48 <disk+0x128>
  while(b->disk == 1) {
    8000592a:	4485                	li	s1,1
    8000592c:	01079a63          	bne	a5,a6,80005940 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005930:	85ca                	mv	a1,s2
    80005932:	8552                	mv	a0,s4
    80005934:	fc8fc0ef          	jal	800020fc <sleep>
  while(b->disk == 1) {
    80005938:	004a2783          	lw	a5,4(s4)
    8000593c:	fe978ae3          	beq	a5,s1,80005930 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005940:	f9042903          	lw	s2,-112(s0)
    80005944:	00290713          	addi	a4,s2,2
    80005948:	0712                	slli	a4,a4,0x4
    8000594a:	0001e797          	auipc	a5,0x1e
    8000594e:	fd678793          	addi	a5,a5,-42 # 80023920 <disk>
    80005952:	97ba                	add	a5,a5,a4
    80005954:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005958:	0001e997          	auipc	s3,0x1e
    8000595c:	fc898993          	addi	s3,s3,-56 # 80023920 <disk>
    80005960:	00491713          	slli	a4,s2,0x4
    80005964:	0009b783          	ld	a5,0(s3)
    80005968:	97ba                	add	a5,a5,a4
    8000596a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000596e:	854a                	mv	a0,s2
    80005970:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005974:	bafff0ef          	jal	80005522 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005978:	8885                	andi	s1,s1,1
    8000597a:	f0fd                	bnez	s1,80005960 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000597c:	0001e517          	auipc	a0,0x1e
    80005980:	0cc50513          	addi	a0,a0,204 # 80023a48 <disk+0x128>
    80005984:	b08fb0ef          	jal	80000c8c <release>
}
    80005988:	70a6                	ld	ra,104(sp)
    8000598a:	7406                	ld	s0,96(sp)
    8000598c:	64e6                	ld	s1,88(sp)
    8000598e:	6946                	ld	s2,80(sp)
    80005990:	69a6                	ld	s3,72(sp)
    80005992:	6a06                	ld	s4,64(sp)
    80005994:	7ae2                	ld	s5,56(sp)
    80005996:	7b42                	ld	s6,48(sp)
    80005998:	7ba2                	ld	s7,40(sp)
    8000599a:	7c02                	ld	s8,32(sp)
    8000599c:	6ce2                	ld	s9,24(sp)
    8000599e:	6165                	addi	sp,sp,112
    800059a0:	8082                	ret

00000000800059a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059a2:	1101                	addi	sp,sp,-32
    800059a4:	ec06                	sd	ra,24(sp)
    800059a6:	e822                	sd	s0,16(sp)
    800059a8:	e426                	sd	s1,8(sp)
    800059aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059ac:	0001e497          	auipc	s1,0x1e
    800059b0:	f7448493          	addi	s1,s1,-140 # 80023920 <disk>
    800059b4:	0001e517          	auipc	a0,0x1e
    800059b8:	09450513          	addi	a0,a0,148 # 80023a48 <disk+0x128>
    800059bc:	a38fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059c0:	100017b7          	lui	a5,0x10001
    800059c4:	53b8                	lw	a4,96(a5)
    800059c6:	8b0d                	andi	a4,a4,3
    800059c8:	100017b7          	lui	a5,0x10001
    800059cc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800059ce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059d2:	689c                	ld	a5,16(s1)
    800059d4:	0204d703          	lhu	a4,32(s1)
    800059d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059dc:	04f70663          	beq	a4,a5,80005a28 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800059e0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059e4:	6898                	ld	a4,16(s1)
    800059e6:	0204d783          	lhu	a5,32(s1)
    800059ea:	8b9d                	andi	a5,a5,7
    800059ec:	078e                	slli	a5,a5,0x3
    800059ee:	97ba                	add	a5,a5,a4
    800059f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059f2:	00278713          	addi	a4,a5,2
    800059f6:	0712                	slli	a4,a4,0x4
    800059f8:	9726                	add	a4,a4,s1
    800059fa:	01074703          	lbu	a4,16(a4)
    800059fe:	e321                	bnez	a4,80005a3e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a00:	0789                	addi	a5,a5,2
    80005a02:	0792                	slli	a5,a5,0x4
    80005a04:	97a6                	add	a5,a5,s1
    80005a06:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a08:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a0c:	f3cfc0ef          	jal	80002148 <wakeup>

    disk.used_idx += 1;
    80005a10:	0204d783          	lhu	a5,32(s1)
    80005a14:	2785                	addiw	a5,a5,1
    80005a16:	17c2                	slli	a5,a5,0x30
    80005a18:	93c1                	srli	a5,a5,0x30
    80005a1a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a1e:	6898                	ld	a4,16(s1)
    80005a20:	00275703          	lhu	a4,2(a4)
    80005a24:	faf71ee3          	bne	a4,a5,800059e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a28:	0001e517          	auipc	a0,0x1e
    80005a2c:	02050513          	addi	a0,a0,32 # 80023a48 <disk+0x128>
    80005a30:	a5cfb0ef          	jal	80000c8c <release>
}
    80005a34:	60e2                	ld	ra,24(sp)
    80005a36:	6442                	ld	s0,16(sp)
    80005a38:	64a2                	ld	s1,8(sp)
    80005a3a:	6105                	addi	sp,sp,32
    80005a3c:	8082                	ret
      panic("virtio_disk_intr status");
    80005a3e:	00002517          	auipc	a0,0x2
    80005a42:	d1a50513          	addi	a0,a0,-742 # 80007758 <etext+0x758>
    80005a46:	d4ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
