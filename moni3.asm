;/*
; ===========================================
; *	SC/MP-III Sample Program
; ===========================================
; */
;
; プリアンブル
; ------------
	  cpu 8070
	  org 0

wk1  = 0xff80
cnt1 = 0xff81
cnt2 = 0xff82
r4   = 0xff83
p4   = 0xff84
p5   = 0xff86

; ------------
; ワークエリア
q0 = 0xffa0
q1 = 0xffa1
q2 = 0xffa2
q3 = 0xffa3
q4 = 0xffa4
q5 = 0xffa5

r0 = 0xffa8
r1 = 0xffaa
r2 = 0xffac
r3 = 0xffae
cyr0 = 0xffb0
cyr1 = 0xffb1
cyr2 = 0xffb2

;// スタート
;	 nop;
	nop
;	 sp=0x8000;
	ld	sp, =0x8000
;	 jmp(main);
	jmp	main
;
;getc()
;{
getc:
;     db(2);
	db	2
;}
	ret
;putc()
;{
putc:
;     db(3);
	db	3
;}
	ret
;exit()
;{
exit:
;     db(4);
	db	4
;}
	ret
;
;// メイン
;main()
;{
main:
;	p2=#msg1;puts();	
	ld	p2, =msg1
	jsr	puts
;
;	div_test();
	jsr	div_test
;	
;//	benchmark();
;
;	while(1) {	
__wh000:
;		a='>';putc();
	ld	a, ='>'
	jsr	putc
;		p2=#inbuf;gets();
	ld	p2, =inbuf
	jsr	gets
;
;		// ECHO BACK.
;		p2=#inbuf;puts();
	ld	p2, =inbuf
	jsr	puts
;
;		//
;		p2=#inbuf;cmd();
	ld	p2, =inbuf
	jsr	cmd
;	}
	jmp	__wh000
__ew000:
;	exit();
	jsr	exit
;}
	ret
;
;benchmark()
;{
benchmark:
;	cnt1=0;
	ld	a, =0
	st	a,cnt1
;	do {
__do001:
;		cnt2=0;
	ld	a, =0
	st	a,cnt2
;		do {
__do002:
;			bench_subr();
	jsr	bench_subr
;		}while(--cnt2);
	dld	A,cnt2
	bnz	__do002
__od002:
;	}while(--cnt1);
	dld	A,cnt1
	bnz	__do001
__od001:
;	p2=#msg1;puts();	
	ld	p2, =msg1
	jsr	puts
;	exit();
	jsr	exit
;}
	ret
;
;bench_subr()
;{
bench_subr:
;	p4=0;
	ld	a, =0
	st	a,p4
;	do {
__do003:
;		bench_subr2();
	jsr	bench_subr2
;	}while(--p4);
	dld	A,p4
	bnz	__do003
__od003:
;}
	ret
;bench_subr2()
;{
bench_subr2:
;	push(ea);
	push	ea
;	push(ea);
	push	ea
;	pop(ea);
	pop	ea
;	pop(ea);
	pop	ea
;}
	ret
;
;// P2 ポインタの１行バッファをcmd解釈.
;// ワーク：
;//    p4 = readhex()の戻り値.
;//    p5 = 注目メモリーアドレスを覚えておく.
;cmd()
;{
cmd:
;	a=*p2++;lc();e=a;
	ld	a, @1,p2
	jsr	lc
	ld	e,a
;	if(e=='d') {
	ld	a,e
	sub	a, ='d'
	bnz	__el004
;		sp_skip();
	jsr	sp_skip
;		readhex();
	jsr	readhex
;		if(a!=0) {
	bz	__el005
;			ea=p4;
	ld	ea,p4
;			p5=ea;
	st	ea,p5
;		}
;		ea=p5;p2=ea;mdump(); //メモリーダンプの実行.
__el005:
	ld	ea,p5
	ld	p2,ea
	jsr	mdump
;
;		ea=p5;ea+=0x100;p5=ea;
	ld	ea,p5
	add	ea, =0x100
	st	ea,p5
;	}	
;	if(e=='q') {
__el004:
	ld	a,e
	sub	a, ='q'
	bnz	__el006
;		exit();
	jsr	exit
;	}	
;}
__el006:
	ret
;
;// ==========================================
;// 入力関数
;
;// P2 ポインタの空白文字飛ばし.
;sp_skip()
;{
sp_skip:
;	a=*p2;
	ld	a, 0,p2
;	while(a==' ') {
__wh007:
	sub	a, =' '
	bnz	__ew007
;		a=*p2++;  // p2++ だけしたい.
	ld	a, @1,p2
;		a=*p2;
	ld	a, 0,p2
;	}
	jmp	__wh007
__ew007:
;}
	ret
;
;p4mul16()
;{
p4mul16:
;	push(ea);
	push	ea
;	ea=p4;
	ld	ea,p4
;	sl(ea);
	sl	ea
;	sl(ea);
	sl	ea
;	sl(ea);
	sl	ea
;	sl(ea);
	sl	ea
;	p4=ea;
	st	ea,p4
;	pop(ea);
	pop	ea
;}
	ret
;
;// P2 ポインタから16進HEX読み. ==> p4に結果. 入力された桁数=Areg
;readhex()
;{
readhex:
;	ea=0;
	ld	ea, =0
;	p4=ea;
	st	ea,p4
;	r4=a;
	st	a,r4
;	while(1) {
__wh008:
;		a=*p2++;e=a;
	ld	a, @1,p2
	ld	e,a
;		readhex1();e=a;
	jsr	readhex1
	ld	e,a
;		if(e!=0xff) {
	ld	a,e
	sub	a, =0xff
	bz	__el009
;			p4mul16();
	jsr	p4mul16
;			a=e;
	ld	a,e
;			e<>a; a=0; e<>a; //e=0;
	xch	e,a
	ld	a, =0
	xch	e,a
;			ea+=p4;
	add	ea,p4
;			p4=ea;
	st	ea,p4
;			a=r4;a+=1;r4=a;
	ld	a,r4
	add	a, =1
	st	a,r4
;		}else{
	jmp	__fi009
__el009:
;			a=r4;
	ld	a,r4
;			return;
	ret
;		}
__fi009:
;	}
	jmp	__wh008
__ew008:
;}
	ret
;
;readhex1()
;{
readhex1:
;	lc();e=a;
	jsr	lc
	ld	e,a
;	if(e>='0') {
	ld	a,e
	sub	a, ='0'
	bp	$+4
	bra	__el010
;		if(e<0x3a) { // <='9'
	ld	a,e
	sub	a, =0x3a
	bp	__el011
;			a=e;
	ld	a,e
;			a-=0x30;
	sub	a, =0x30
;			return;
	ret
;		}
;	}
__el011:
;	if(e>='a') {
__el010:
	ld	a,e
	sub	a, ='a'
	bp	$+4
	bra	__el012
;		if(e<'g') {
	ld	a,e
	sub	a, ='g'
	bp	__el013
;			a=e;
	ld	a,e
;			a-=0x57;  // 0x61 - 10
	sub	a, =0x57
;			return;
	ret
;		}
;	}
__el013:
;	a=0xff;
__el012:
	ld	a, =0xff
;}
	ret
;
;
;// ==========================================
;// 出力関数
;
;//  アスキーダンプ１行
;ascdump_16()
;{
ascdump_16:
;	push(p2);
	push	p2
;	p2=ea;
	ld	p2,ea
;	ascdump_8();
	jsr	ascdump_8
;	pr_spc();
	jsr	pr_spc
;	ascdump_8();
	jsr	ascdump_8
;	pop(p2);
	pop	p2
;}
	ret
;
;//  アスキーダンプ8byte
;ascdump_8()
;{
ascdump_8:
;	a=8;cnt2=a;
	ld	a, =8
	st	a,cnt2
;	do {
__do014:
;		a=*p2++;
	ld	a, @1,p2
;		ascdump1();
	jsr	ascdump1
;	} while(--cnt2);
	dld	A,cnt2
	bnz	__do014
__od014:
;}
	ret
;
;//  アスキーダンプ1byte
;ascdump1()
;{
ascdump1:
;	e=a;
	ld	e,a
;	if(e<0x20) {
	ld	a,e
	sub	a, =0x20
	bp	__el015
;		a=' ';e=a;
	ld	a, =' '
	ld	e,a
;	}
;	if(e>=0x7f) {
__el015:
	ld	a,e
	sub	a, =0x7f
	bp	$+4
	bra	__el016
;		a=' ';e=a;
	ld	a, =' '
	ld	e,a
;	}
;	a=e;putc();
__el016:
	ld	a,e
	jsr	putc
;}
	ret
;
;//  大文字にする.
;uc()
;{
uc:
;	e=a;
	ld	e,a
;	if(e>='a') {
	ld	a,e
	sub	a, ='a'
	bp	$+4
	bra	__el017
;		if(e<0x7b) {  // <='z'
	ld	a,e
	sub	a, =0x7b
	bp	__el018
;			a=e;
	ld	a,e
;			a-=0x20;
	sub	a, =0x20
;			return;
	ret
;		}
;	}
__el018:
;	a=e;
__el017:
	ld	a,e
;}
	ret
;
;//  小文字にする.
;lc()
;{
lc:
;	e=a;
	ld	e,a
;	if(e>='A') {
	ld	a,e
	sub	a, ='A'
	bp	$+4
	bra	__el019
;		if(e<0x5b) {  // <='Z'
	ld	a,e
	sub	a, =0x5b
	bp	__el020
;			a=e;
	ld	a,e
;			a+=0x20;
	add	a, =0x20
;			return;
	ret
;		}
;	}
__el020:
;	a=e;
__el019:
	ld	a,e
;}
	ret
;
;
;//  メモリーダンプ
;mdump()
;{
mdump:
;	a=16;cnt1=a;
	ld	a, =16
	st	a,cnt1
;	do {
__do021:
;		mdump_16();
	jsr	mdump_16
;	} while(--cnt1);
	dld	A,cnt1
	bnz	__do021
__od021:
;}
	ret
;
;//  メモリーダンプ16byte
;mdump_16()
;{
mdump_16:
;	ea=p2;
	ld	ea,p2
;	prhex4();
	jsr	prhex4
;	pr_spc();
	jsr	pr_spc
;
;	mdump_8();
	jsr	mdump_8
;	pr_spc();
	jsr	pr_spc
;	mdump_8();
	jsr	mdump_8
;
;// ASCII DUMP
;	ea=p2;ea-=16;
	ld	ea,p2
	sub	ea, =16
;	ascdump_16();
	jsr	ascdump_16
;
;	put_crlf();
	jsr	put_crlf
;}
	ret
;
;//  メモリーダンプ8byte
;mdump_8()
;{
mdump_8:
;	a=8;cnt2=a;
	ld	a, =8
	st	a,cnt2
;	do {
__do022:
;		a=*p2++;
	ld	a, @1,p2
;		prhex2();
	jsr	prhex2
;		pr_spc();
	jsr	pr_spc
;	} while(--cnt2);
	dld	A,cnt2
	bnz	__do022
__od022:
;}
	ret
;
;//  EAレジスタを16進4桁表示
;prhex4()
;{
prhex4:
;	a<>e;
	xch	a,e
;	prhex2();
	jsr	prhex2
;	a<>e;
	xch	a,e
;	prhex2();
	jsr	prhex2
;}
	ret
;
;//  Aレジスタを16進2桁表示
;prhex2()
;{
prhex2:
;	push(ea);
	push	ea
;	e=a;
	ld	e,a
;	a>>=1;
	sr	a
;	a>>=1;
	sr	a
;	a>>=1;
	sr	a
;	a>>=1;
	sr	a
;	prhex1();
	jsr	prhex1
;
;	a=e;
	ld	a,e
;	prhex1();
	jsr	prhex1
;	pop(ea);
	pop	ea
;}
	ret
;
;//  Aレジスタ下位4bitのみを16進1桁表示
;prhex1()
;{
prhex1:
;	push(ea);
	push	ea
;	a&=0x0f;
	and	a, =0x0f
;	e=a;
	ld	e,a
;	if( a >= 10) {
	sub	a, =10
	bp	$+4
	bra	__el023
;		a=e;a+=7;
	ld	a,e
	add	a, =7
;	}else{
	jmp	__fi023
__el023:
;		a=e;
	ld	a,e
;	}
__fi023:
;	a += 0x30;
	add	a, =0x30
;	putc();
	jsr	putc
;	pop(ea);
	pop	ea
;}
	ret
;//  空白文字を1つ出力
;pr_spc()
;{
pr_spc:
;	a=' ';putc();
	ld	a, =' '
	jsr	putc
;}
	ret
;
;//  改行コード出力
;put_crlf()
;{
put_crlf:
;	a=0x0d;putc();
	ld	a, =0x0d
	jsr	putc
;	a=0x0a;putc();
	ld	a, =0x0a
	jsr	putc
;}
	ret
;
;//  文字列出力( P2 )ヌル終端.
;puts()
;{
puts:
;	do {
__do024:
;		a=*p2++;
	ld	a, @1,p2
;		if(a==0) break;
	bz	__od024
;		putc();
	jsr	putc
;	}while(1);	
	bra	__do024
__od024:
;}
	ret
;
;//  文字列入力( P2 ) 0x0a + ヌル終端.
;gets()
;{
gets:
;	do {
__do025:
;		getc();
	jsr	getc
;		*p2++=a;
	st	a, @1,p2
;		e=a;
	ld	e,a
;		if(e==0x0a) break;
	ld	a,e
	sub	a, =0x0a
	bz	__od025
;		if(e==0x0d) break;
	ld	a,e
	sub	a, =0x0d
	bz	__od025
;	}while(1);	
	bra	__do025
__od025:
;
;	a=0; *p2++=a;
	ld	a, =0
	st	a, @1,p2
;}
	ret
;
;//  文字列サンプル
;msg1:
msg1:
;	db(" * SC/MP-III Monitor *");
	db	" * SC/MP-III Monitor *"
;	db(0x0d);
	db	0x0d
;	db(0x0a);
	db	0x0a
;	db(0);
	db	0
;
;inbuf:
inbuf:
;	ds(128);
	ds	128
;
;bufend:
bufend:
;	db(0);
	db	0
;
;
;// CALC PI //
;
;// 割り算=========
;// q0/q4
;
;div32_16()
;{
div32_16:
;	cnt1=16;
	ld	a, =16
	st	a,cnt1
;
;	cyr0=0;
	ld	a, =0
	st	a,cyr0
;	cyr1=0;
	ld	a, =0
	st	a,cyr1
;	cyr2=0;
	ld	a, =0
	st	a,cyr2
;
;	do {
__do026:
;
;// === q0:q3 の32bit を左シフト(2倍)
;		// q0 <<=1
;		ea=q0;ea+=q0;
	ld	ea,q0
	add	ea,q0
;		q0=ea;
	st	ea,q0
;		// sr = CY(bit7)
;		a=0;e=a;
	ld	a, =0
	ld	e,a
;		a=s;sl(ea);cyr0=ea;
	ld	a,s
	sl	ea
	st	ea,cyr0
;
;		// q2 <<=1 : q2+= .CY
;		ea=q2;ea+=q2;ea+=cyr1;
	ld	ea,q2
	add	ea,q2
	add	ea,cyr1
;		q2=ea;
	st	ea,q2
;// === q2:q3 の16bit から q4:q5の16bit が減算できるなら減算する.
;		ea-=q4;push(ea);
	sub	ea,q4
	push	ea
;		a=e;if(a>=0) {
	ld	a,e
	sub	a, =0
	bp	$+4
	bra	__el027
;			pop(ea);
	pop	ea
;			q2=ea; //減算結果をq2に書き戻す.
	st	ea,q2
;			// q0++
;			ea=q0;ea+=1;q0=ea;
	ld	ea,q0
	add	ea, =1
	st	ea,q0
;		}else{
	jmp	__fi027
__el027:
;			pop(ea);//減算結果を破棄する.
	pop	ea
;		}
__fi027:
;	}while(--cnt1);	
	dld	A,cnt1
	bnz	__do026
__od026:
;}
	ret
;
;// 割り算テスト
;div_test()
;{
div_test:
;	// q0 = 12345
;	ea=12345;q0=ea;
	ld	ea, =12345
	st	ea,q0
;	ea=0    ;q2=ea;
	ld	ea, =0
	st	ea,q2
;
;	// q4 = 10
;	ea=10   ;q4=ea;
	ld	ea, =10
	st	ea,q4
;
;	// q0/q4
;	div32_16();
	jsr	div32_16
;
;	ea=#q0;p2=ea;mdump(); //メモリーダンプの実行.
	ld	ea, =q0
	ld	p2,ea
	jsr	mdump
;}
	ret
