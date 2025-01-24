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

;; 除算ワーク. q0:q3 = 被除数 q4:q5 = 除数.
q0 = 0xffa0
q1 = 0xffa1
q2 = 0xffa2
q3 = 0xffa3
q4 = 0xffa4
q5 = 0xffa5

;; 除算カウンタ16回.
divcnt = 0xffa6

r0 = 0xffa8
r1 = 0xffaa
r2 = 0xffac
r3 = 0xffae

;; CYフラグ代用
cyr0 = 0xffb0
cyr1 = 0xffb1
cyr2 = 0xffb2

;; 収束ループカウンタ
cnt3 = 0xffb3
cnt4 = 0xffb4

;; arctan()計算引数
m1    = 0xffb6
n1    = 0xffb8

;; arctan()内部変数
sign1 = 0xffb9
tab1  = 0xffba
lf1   = 0xffbb
chr1  = 0xffbc
top1  = 0xffbd

indx0 = 0xffc0
indx1 = 0xffc1

;; n_2 = n1 * n1
n_2    = 0xffc2


;; 計算する桁数（２進数の配列バイト数）
PRECISION = 5000

;; 16bit値 デクリメントしてゼロチェック ==>Areg .
dec_w macro work
	ld ea,work
	sub ea, =1
	st ea,work
	
	or a,e

	endm


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
;	pi_main();
	jsr	pi_main
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
;			a=e;e=0;
	ld	a,e
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
;//  メモリーダンプ8byte
;mdump_b16()
;{
mdump_b16:
;	a=16;cnt2=a;
	ld	a, =16
	st	a,cnt2
;	do {
__do023:
;		a=*p2++;
	ld	a, @1,p2
;		prhex2();
	jsr	prhex2
;		pr_spc();
	jsr	pr_spc
;	} while(--cnt2);
	dld	A,cnt2
	bnz	__do023
__od023:
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
	bra	__el024
;		a=e;a+=7;
	ld	a,e
	add	a, =7
;	}else{
	jmp	__fi024
__el024:
;		a=e;
	ld	a,e
;	}
__fi024:
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
__do025:
;		a=*p2++;
	ld	a, @1,p2
;		if(a==0) break;
	bz	__od025
;		putc();
	jsr	putc
;	}while(1);	
	bra	__do025
__od025:
;}
	ret
;
;//  文字列入力( P2 ) 0x0a + ヌル終端.
;gets()
;{
gets:
;	do {
__do026:
;		getc();
	jsr	getc
;		*p2++=a;
	st	a, @1,p2
;		e=a;
	ld	e,a
;		if(e==0x0a) break;
	ld	a,e
	sub	a, =0x0a
	bz	__od026
;		if(e==0x0d) break;
	ld	a,e
	sub	a, =0x0d
	bz	__od026
;	}while(1);	
	bra	__do026
__od026:
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
;// =============  ここから、円周率計算 ===============
;//
;//
;PI_MSG_1:
PI_MSG_1:
;	db(0x0d);
	db	0x0d
;	db(0x0a);
	db	0x0a
;	db("> Calculating PI ... ");
	db	"> Calculating PI ... "
;	db(0x0d);
	db	0x0d
;	db(0x0a);
	db	0x0a
;	db(0);
	db	0
;
;PI_EQU_1:
PI_EQU_1:
;	db("PI = ");
	db	"PI = "
;	db(0);
	db	0
;
;PI_EQU_2:
PI_EQU_2:
;	db(" + ");
	db	" + "
;	db(0x0d);
	db	0x0d
;	db(0x0a);
	db	0x0a
;	db(0);
	db	0
;
;// 割り算=========
;// q0/q4
;
;div32_16()
;{
div32_16:
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
;	divcnt=16;
	ld	a, =16
	st	a,divcnt
;	do {
__do027:
;
;// === q0:q3 の32bit を左シフト(2倍)
;		// q0 <<=1
;		ea=q0;ea+=q0;
	ld	ea,q0
	add	ea,q0
;		q0=ea;
	st	ea,q0
;
;		// sr = CY(bit7) CYをcyr1:cyr2に整数値(0 or 1)で保管.
;		e=0;
	xch	e,a
	ld	a, =0
	xch	e,a
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
;
;//		a=e;if(a>=0) {     // 減算結果の正負で引けたか見る. <== XXX
;
;		a=s;if(a & 0x80) { // CYフラグで見る.
	ld	a,s
	and	a, =0x80
	bz	__el028
;			pop(ea);
	pop	ea
;			q2=ea; //減算結果をq2に書き戻す.
	st	ea,q2
;			// q0++
;			ild(a,q0);    //ea=q0;ea+=1;q0=ea;
	ild	a,q0
;		}else{
	jmp	__fi028
__el028:
;			pop(ea);//減算結果を破棄する.
	pop	ea
;		}
__fi028:
;	}while(--divcnt);
	dld	A,divcnt
	bnz	__do027
__od027:
;}
	ret
;
;div16_8()
;{
div16_8:
;//除算命令DIVはEAの内容をTの内容で割ります。EAには0から65536の値が、
;//Tには1から32767までの範囲でEAより小さな値が入っていなくてはなりません。
;//数値は符号なし、もしくは符号付きなら両方とも正の範囲でなくてはなりません。
;//演算結果として商がEAに、剰余がTに入ります。ともに正の数です。
;
;// === q0:q1 の16bit /  q4 (8bit) ==> q0 剰余は q1
;	a=q4;e=0;t=ea; //除数をセット.
	ld	a,q4
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	t,ea
;
;	ea=q0;         //被除数をセット.
	ld	ea,q0
;	div(ea,t);
	div	ea,t
;	q0=a;	//商.
	st	a,q0
;
;	ea=t;
	ld	ea,t
;	q1=a;	//剰余.
	st	a,q1
;}
	ret
;
;
;// 割り算テスト
;div_test16()
;{
div_test16:
;	ea=0    ;q2=ea;
	ld	ea, =0
	st	ea,q2
;
;	// q0 = 12345
;	ea=41000  ;q0=ea;
	ld	ea, =41000
	st	ea,q0
;
;	// q4 = 10
;	ea=40000  ;q4=ea;
	ld	ea, =40000
	st	ea,q4
;
;	// q0/q4
;	div32_16();
	jsr	div32_16
;
;	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
	ld	p2, =q0
	ld	a, ='*'
	jsr	p2_dump
;}
	ret
;
;// 割り算テスト
;div_test8()
;{
div_test8:
;	ea=0    ;q2=ea;
	ld	ea, =0
	st	ea,q2
;
;	// q0 = 12345
;	ea=12345  ;q0=ea;
	ld	ea, =12345
	st	ea,q0
;
;	// q4 = 16
;	ea=100    ;q4=ea;
	ld	ea, =100
	st	ea,q4
;
;	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
	ld	p2, =q0
	ld	a, ='*'
	jsr	p2_dump
;	// q0/q4
;	div16_8();
	jsr	div16_8
;
;	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
	ld	p2, =q0
	ld	a, ='*'
	jsr	p2_dump
;}
	ret
;
;mp_set()
;{
mp_set:
;	e=a;
	ld	e,a
;	*p2++ = 0;
	ld	a, =0
	st	a, @1,p2
;	a=e;
	ld	a,e
;	*p2++ = a;
	st	a, @1,p2
;
;	ea=#PRECISION;cnt1=ea;
	ld	ea, =PRECISION
	st	ea,cnt1
;	do {
__do029:
;		*p2++ = 0;
	ld	a, =0
	st	a, @1,p2
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do029
__od029:
;}
	ret
;
;mp_zerochk()
;{
mp_zerochk:
;	ea=#PRECISION; ea-=10; cnt1=ea;
	ld	ea, =PRECISION
	sub	ea, =10
	st	ea,cnt1
;	do {
__do030:
;		a = *p2++;
	ld	a, @1,p2
;		if(a!=0) {
	bz	__el031
;			return;
	ret
;		}
;		dec_w(cnt1);
__el031:
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do030
__od030:
;	a=0; // Zero判定!
	ld	a, =0
;}
	ret
;
;mp_copy()
;{
mp_copy:
;	ea=#PRECISION;cnt1=ea;
	ld	ea, =PRECISION
	st	ea,cnt1
;	do {
__do032:
;		a = *p3++;
	ld	a, @1,p3
;		    *p2++ = a;
	st	a, @1,p2
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do032
__od032:
;}
	ret
;/**********************************************************************
; *  p2 配列 の先頭ゼロをスキップする.
; **********************************************************************
; *  p2=ポインタ cnt1:cnt2=桁数(byte数)カウント
; */
;mp_div_zeroskip16()
;{
mp_div_zeroskip16:
;	do {
__do033:
;		a = p2[0];e=a;
	ld	a,0,p2
	ld	e,a
;		a = p2[1];
	ld	a,1,p2
;		a |= e;
	or	a,e
;		if(a!=0) return; // ea != 0
	bz	__el034
	ret
;
;		//ポインタを2バイト進める
;		ld(a,@2,p2);
__el034:
	ld	a,@2,p2
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do033
__od033:
;	a=0;
	ld	a, =0
;}
	ret
;/**********************************************************************
; *  p2 配列 の先頭ゼロをスキップする.
; **********************************************************************
; *  p2=ポインタ cnt1:cnt2=桁数(byte数)カウント
; */
;mp_div_zeroskip8()
;{
mp_div_zeroskip8:
;	do {
__do035:
;		a = p2[0];
	ld	a,0,p2
;		if(a!=0) return; // a != 0
	bz	__el036
	ret
;
;		//ポインタを1バイト進める
;		ld(a,@1,p2);
__el036:
	ld	a,@1,p2
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do035
__od035:
;	a=0;
	ld	a, =0
;}
	ret
;/**********************************************************************
; *  p2 配列 を 整数 reg_ea で除算する
; *	   一回の除算単位は 8bit (16bit/8bit)
; **********************************************************************
; *     q4 = 除数.
; *     p2 = 被除数配列.
; */
;mp_div8()
;{
mp_div8:
;	ea=#PRECISION;cnt1=ea;	// ループ回数.
	ld	ea, =PRECISION
	st	ea,cnt1
;
;	mp_div_zeroskip8();if(a==0) return; //全部ゼロ.
	jsr	mp_div_zeroskip8
	bnz	__el037
	ret
;
;    a=0;q1=a;
__el037:
	ld	a, =0
	st	a,q1
;	do {
__do038:
;
;/***
;// :最適化前
;		a = p2[0];
;		q0=a; // q0:q1= 被除数.
;		div16_8();
;		// q0 = 商
;		a=q0;
;		p2[0]=a;	
;		// q1 = 剰余(次のループで256倍して再利用)
;
;		//ポインタを1バイト進める
;		ld(a,@1,p2);
; ***/
;
;// === q0:q1 の16bit /  q4 (8bit) ==> q0 剰余は q1
;		a =p2[0];
	ld	a,0,p2
;		q0=a; // q0:q1= 被除数.
	st	a,q0
;
;		e=0;a=q4;t=ea;
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,q4
	ld	t,ea
;		ea=q0;
	ld	ea,q0
;		div(ea,t);
	div	ea,t
;		// q0 = 商
;		*p2++=a;	
	st	a, @1,p2
;
;		// q1 = 剰余(次のループで256倍して再利用)
;		ea=t;
	ld	ea,t
;		q1=a;	//剰余.
	st	a,q1
;// ===
;
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do038
__od038:
;}
	ret
;/**********************************************************************
; *  p2 配列 を 整数 reg_ea で除算する
; *	   一回の除算単位は16bit (32bit/16bit)
; **********************************************************************
; * mp_div(MP *p2,int ea)
; */
;mp_div()
;{
mp_div:
;	q4=ea; 		// q4:q5 = 除数.
	st	ea,q4
;	ea=0;q2=ea;	// q2:q3 = 剰余ワーク（除算キャリー伝播としても使用）
	ld	ea, =0
	st	ea,q2
;
;	// 除数が 1～127の範囲内なら、DIV命令を使う8bit単位の多倍長演算に任せる.
;	a=q5;if(a==0) {
	ld	a,q5
	bnz	__el039
;		a=q4;if(a<0x80) {
	ld	a,q4
	sub	a, =0x80
	bp	__el040
;			mp_div8();return;
	jsr	mp_div8
	ret
;		}
;	}
__el040:
;
;	// 除数が 129～ の場合は、16bit 単位で処理する多倍長演算を実行する.
;	ea=#PRECISION;ea>>=1;	// ループ回数.
__el039:
	ld	ea, =PRECISION
	sr	ea
;	cnt1=ea;
	st	ea,cnt1
;
;	mp_div_zeroskip16();if(a==0) return; //全部ゼロ.
	jsr	mp_div_zeroskip16
	bnz	__el041
	ret
;
;	do {
__el041:
__do042:
;		a = p2[0];e=a;
	ld	a,0,p2
	ld	e,a
;		a = p2[1];
	ld	a,1,p2
;		q0=ea; // q0:q3= 被除数.
	st	ea,q0
;		div32_16();
	jsr	div32_16
;
;		// q0:q1 = 商
;		ea=q0;
	ld	ea,q0
;		p2[1]=a; a=e;
	st	a,1,p2
	ld	a,e
;		p2[0]=a;	
	st	a,0,p2
;		// q2:q3 = 剰余(次のループで65536倍して再利用)
;
;		//ポインタを2バイト進める
;		ld(a,@2,p2);
	ld	a,@2,p2
;
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do042
__od042:
;}
	ret
;
;p2_last()
;{
p2_last:
;	ea=p2;
	ld	ea,p2
;	ea+=#PRECISION;
	add	ea, =PRECISION
;	ea-=1;
	sub	ea, =1
;	p2=ea;
	ld	p2,ea
;}
	ret
;p3_last()
;{
p3_last:
;	ea=p3;
	ld	ea,p3
;	ea+=#PRECISION;
	add	ea, =PRECISION
;	ea-=1;
	sub	ea, =1
;	p3=ea;
	ld	p3,ea
;}
	ret
;/**********************************************************************
; *	多倍長減算： p2 = p2 - p3
; **********************************************************************
; *   mp_add(p2 += p3)
; */
;mp_add()
;{
mp_add:
;	p2_last();
	jsr	p2_last
;	p3_last();
	jsr	p3_last
;
;	cyr1=0;	// CY
	ld	a, =0
	st	a,cyr1
;	cyr2=0;
	ld	a, =0
	st	a,cyr2
;
;	r0 = 0;
	ld	a, =0
	st	a,r0
;	r1 = 0;
	ld	a, =0
	st	a,r1
;	r2 = 0;
	ld	a, =0
	st	a,r2
;	r3 = 0;
	ld	a, =0
	st	a,r3
;
;	ea=#PRECISION;cnt1=ea;
	ld	ea, =PRECISION
	st	ea,cnt1
;	do {
__do043:
;		// p2[0] -= p3[0];
;		a = *p2; r0 = a;
	ld	a, 0,p2
	st	a,r0
;		a = *p3; r2 = a;
	ld	a, 0,p3
	st	a,r2
;
;		ea = r0;
	ld	ea,r0
;		ea +=r2;
	add	ea,r2
;		ea +=cyr1; // CY を含めて減算.
	add	ea,cyr1
;		*p2 = a;   // 減算結果8bit
	st	a, 0,p2
;
;		// CYをcyr1:cyr2に整数値(0 or 1)で保管.
;		cyr1=0;
	ld	a, =0
	st	a,cyr1
;		a=e;if(a!=0) {cyr1=1;}
	ld	a,e
	bz	__el044
	ld	a, =1
	st	a,cyr1
;
;		// p2++ p3++;
;		ld(a,@-1,p2);		
__el044:
	ld	a,@-1,p2
;		ld(a,@-1,p3);		
	ld	a,@-1,p3
;
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do043
__od043:
;}
	ret
;
;/**********************************************************************
; *	多倍長減算： p2 = p2 - p3
; **********************************************************************
; *   mp_sub(p2 -= p3)
; */
;mp_sub()
;{
mp_sub:
;	p2_last();
	jsr	p2_last
;	p3_last();
	jsr	p3_last
;
;	cyr1=0;	// CY
	ld	a, =0
	st	a,cyr1
;	cyr2=0;
	ld	a, =0
	st	a,cyr2
;
;	r0 = 0;
	ld	a, =0
	st	a,r0
;	r1 = 0;
	ld	a, =0
	st	a,r1
;	r2 = 0;
	ld	a, =0
	st	a,r2
;	r3 = 0;
	ld	a, =0
	st	a,r3
;
;	ea=#PRECISION;cnt1=ea;
	ld	ea, =PRECISION
	st	ea,cnt1
;	do {
__do045:
;		// p2[0] -= p3[0];
;		a = *p2; r0 = a;
	ld	a, 0,p2
	st	a,r0
;		a = *p3; r2 = a;
	ld	a, 0,p3
	st	a,r2
;
;		ea = r0;
	ld	ea,r0
;		ea -=r2;
	sub	ea,r2
;		ea -=cyr1; // CY を含めて減算.
	sub	ea,cyr1
;		*p2 = a;   // 減算結果8bit
	st	a, 0,p2
;
;		// CYをcyr1:cyr2に整数値(0 or 1)で保管.
;		cyr1=0;
	ld	a, =0
	st	a,cyr1
;		a=e;if(a!=0) {cyr1=1;}
	ld	a,e
	bz	__el046
	ld	a, =1
	st	a,cyr1
;
;		// p2-- p3--;
;		ld(a,@-1,p2);		
__el046:
	ld	a,@-1,p2
;		ld(a,@-1,p3);		
	ld	a,@-1,p3
;
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do045
__od045:
;}
	ret
;/**********************************************************************
; *  ea を 10倍する.
; **********************************************************************
; */
;ea_mul10()
;{
ea_mul10:
;	// 乗算命令MPYはEAとTの内容を乗じて上位16 bitをEAに、下位16 bitをTに入れます。
;	// 演算は符号付きで行われます。
;	t=ea;
	ld	t,ea
;	ea=10;mpy(ea,t);
	ld	ea, =10
	mpy	ea,t
;	ea=t;
	ld	ea,t
;}
	ret
;
;/**********************************************************************
; *  ea を 二乗する.
; **********************************************************************
; */
;ea_mul_ea()
;{
ea_mul_ea:
;	// 乗算命令MPYはEAとTの内容を乗じて上位16 bitをEAに、下位16 bitをTに入れます。
;	// 演算は符号付きで行われます。
;	t=ea;
	ld	t,ea
;		mpy(ea,t);
	mpy	ea,t
;	ea=t;
	ld	ea,t
;}
	ret
;
;
;/**********************************************************************
; *  m0 を 10倍する.
; **********************************************************************
; * mp_mul10(p2)
; */
;mp_mul10()
;{
mp_mul10:
;	p2_last();
	jsr	p2_last
;
;	cyr0=0;
	ld	a, =0
	st	a,cyr0
;	cyr1=0;	// CY
	ld	a, =0
	st	a,cyr1
;	cyr2=0;
	ld	a, =0
	st	a,cyr2
;
;	r2 = 0;
	ld	a, =0
	st	a,r2
;	r3 = 0;
	ld	a, =0
	st	a,r3
;
;	ea=#PRECISION;cnt1=ea;
	ld	ea, =PRECISION
	st	ea,cnt1
;	do {
__do047:
;		a = *p2; r0 = a;
	ld	a, 0,p2
	st	a,r0
;		a = 0;   r1 = a;
	ld	a, =0
	st	a,r1
;		ea = r0; ea_mul10();ea+=r2;
	ld	ea,r0
	jsr	ea_mul10
	add	ea,r2
;		*p2 = a;   	// 乗算結果8bit
	st	a, 0,p2
;		
;		a=e;r2=a;  	// 8bitを越える分をr2に保管.
	ld	a,e
	st	a,r2
;		a=0;r3=a;
	ld	a, =0
	st	a,r3
;
;		// p2--;
;		ld(a,@-1,p2);		
	ld	a,@-1,p2
;
;		dec_w(cnt1);
	dec_w	cnt1
;	}while(a!=0);
	bnz	__do047
__od047:
;}
	ret
;
;/**********************************************************************
; *	mp を小数以下 (PRECISION*2+1) まで印字.
; **********************************************************************
; * void print_pi(MP *p)
; */
;print_pi()
;{
print_pi:
;	tab1=0;lf1=0;top1=0;
	ld	a, =0
	st	a,tab1
	ld	a, =0
	st	a,lf1
	ld	a, =0
	st	a,top1
;	
;//	for(i=0;i< (PRECISION*2+1) ;i++) {
;
;	ea=#PRECISION;ea<<=1;ea+=1;
	ld	ea, =PRECISION
	sl	ea
	add	ea, =1
;	cnt3=ea;
	st	ea,cnt3
;	do {
__do048:
;		//a='+';pi_dump();
;		ea=#Pi;p2=ea;
	ld	ea, =Pi
	ld	p2,ea
;		a=p2[1];chr1=a;
	ld	a,1,p2
	st	a,chr1
;		a=0;p2[0]=a;p2[1]=a;
	ld	a, =0
	st	a,0,p2
	st	a,1,p2
;		mp_mul10();
	jsr	mp_mul10
;		a=top1;if(a==0) {
	ld	a,top1
	bnz	__el049
;			top1=1;
	ld	a, =1
	st	a,top1
;//			printf("PI = %c. + \n",'0'+c);
;			push(p2);
	push	p2
;			p2=#PI_EQU_1; puts();
	ld	p2, =PI_EQU_1
	jsr	puts
;			a=chr1;a+='0';putc();
	ld	a,chr1
	add	a, ='0'
	jsr	putc
;			p2=#PI_EQU_2; puts();
	ld	p2, =PI_EQU_2
	jsr	puts
;			pop(p2);
	pop	p2
;		}else{
	jmp	__fi049
__el049:
;			a=chr1;a+='0';putc();
	ld	a,chr1
	add	a, ='0'
	jsr	putc
;			ild(a,tab1);  // tab1++;
	ild	a,tab1
;			if(a>=10) {tab1=0;
	sub	a, =10
	bp	$+4
	bra	__el050
	ld	a, =0
	st	a,tab1
;				a=' ';putc();
	ld	a, =' '
	jsr	putc
;				ild(a,lf1);  // tab1++;
	ild	a,lf1
;				if(a>=5) {lf1=0;
	sub	a, =5
	bp	$+4
	bra	__el051
	ld	a, =0
	st	a,lf1
;					put_crlf();
	jsr	put_crlf
;				}
;			}
__el051:
;		}
__el050:
__fi049:
;		dec_w(cnt3);
	dec_w	cnt3
;	}while(a!=0);
	bnz	__do048
__od048:
;
;	put_crlf();
	jsr	put_crlf
;}
	ret
;
;/**********************************************************************
; *  ひとつのArcTan項を計算する ma = m * atan(1/n)
; **********************************************************************
;    void calc_M_atan_1_N(int m1,int n1)
; */
;calc_M_atan_1_N()
;{
calc_M_atan_1_N:
;// n_2 = n1*n1
;	e=0;a=n1; ea_mul_ea(); n_2=ea;
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,n1
	jsr	ea_mul_ea
	st	ea,n_2
;	// p2=#n_2; a='*';p2_dump();
;
;// ma = m * (1/n)
;	p2=#ma ; e=0;a=m1  ; mp_set();
	ld	p2, =ma
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,m1
	jsr	mp_set
;	p2=#ma ; e=0;a=n1  ; mp_div();
	ld	p2, =ma
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,n1
	jsr	mp_div
;
;// mc = m * (1/n)
;	p2=#mc ; p3=#ma    ; mp_copy();		//	mc = ma;
	ld	p2, =mc
	ld	p3, =ma
	jsr	mp_copy
;
;// arctan(x) = x - (1/3)x**3 + (1/5)x**5 - (1/7)x**7 ・・・
;// LOOP: ma +-= mb
;
;	sign1=0;
	ld	a, =0
	st	a,sign1
;
;	ea=3;indx0=ea; // indx0 = 3,5,7,9,11, ...
	ld	ea, =3
	st	ea,indx0
;	while(1) {
__wh052:
;		// mc = mc*(1/n)*(1/n)
;		a=n_2;if(a==25) {
	ld	a,n_2
	sub	a, =25
	bnz	__el053
;			p2=#mc;	ea=n_2;   mp_div();			// mc = mc * (1/ (n*n) );
	ld	p2, =mc
	ld	ea,n_2
	jsr	mp_div
;		}else{
	jmp	__fi053
__el053:
;			p2=#mc;	e=0;a=n1; mp_div();
	ld	p2, =mc
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,n1
	jsr	mp_div
;			p2=#mc;	e=0;a=n1; mp_div();
	ld	p2, =mc
	xch	e,a
	ld	a, =0
	xch	e,a
	ld	a,n1
	jsr	mp_div
;		}
__fi053:
;		// mb = mc*(1/i)
;		p2=#mb ; p3=#mc ; mp_copy();		//	mb = mc;
	ld	p2, =mb
	ld	p3, =mc
	jsr	mp_copy
;		p2=#mb ; ea=indx0; mp_div();		//  mb /= indx0;
	ld	p2, =mb
	ld	ea,indx0
	jsr	mp_div
;
;		p2=#mb ; mp_zerochk(); if(a==0) break;
	ld	p2, =mb
	jsr	mp_zerochk
	bz	__ew052
;		
;		p2=#ma ; p3=#mb ;
	ld	p2, =ma
	ld	p3, =mb
;
;		a=sign1;a ^= 1;sign1=a;
	ld	a,sign1
	xor	a, =1
	st	a,sign1
;		if(a!=0) {
	bz	__el054
;			mp_sub();	// ma += mb;
	jsr	mp_sub
;		}else{
	jmp	__fi054
__el054:
;			mp_add();	// ma -= mb;
	jsr	mp_add
;		}
__fi054:
;
;		// indx0 += 2;
;		ea=indx0;ea+=2;
	ld	ea,indx0
	add	ea, =2
;		indx0=ea;
	st	ea,indx0
;	}
	jmp	__wh052
__ew052:
;
;	a='A'; ma_dump();
	ld	a, ='A'
	jsr	ma_dump
;}
	ret
;
;/**********************************************************************
; *	デバッグルーチン
; **********************************************************************
; */
;dump_pi()
;{
dump_pi:
;	p2=#Pi; mdump(); //メモリーダンプの実行.
	ld	p2, =Pi
	jsr	mdump
;}
	ret
;p2_dump()
;{
p2_dump:
;	putc();
	jsr	putc
;	a=':';putc();
	ld	a, =':'
	jsr	putc
;
;	mdump_8();
	jsr	mdump_8
;	put_crlf();
	jsr	put_crlf
;}
	ret
;
;q0_dump()
;{
q0_dump:
;	push(p2);
	push	p2
;	p2=#q0;p2_dump();
	ld	p2, =q0
	jsr	p2_dump
;	pop(p2);
	pop	p2
;}
	ret
;
;pi_dump()
;{
pi_dump:
;	push(p2);
	push	p2
;	p2=#Pi;p2_dump();
	ld	p2, =Pi
	jsr	p2_dump
;	pop(p2);
	pop	p2
;}
	ret
;
;ma_dump()
;{
ma_dump:
;	push(p2);
	push	p2
;	p2=#ma;p2_dump();
	ld	p2, =ma
	jsr	p2_dump
;	pop(p2);
	pop	p2
;}
	ret
;
;mb_dump()
;{
mb_dump:
;	push(p2);
	push	p2
;	p2=#mb;p2_dump();
	ld	p2, =mb
	jsr	p2_dump
;	pop(p2);
	pop	p2
;}
	ret
;
;mc_dump()
;{
mc_dump:
;	push(p2);
	push	p2
;	p2=#mc;p2_dump();
	ld	p2, =mc
	jsr	p2_dump
;	pop(p2);
	pop	p2
;}
	ret
;
;/**********************************************************************
; *	マチンの公式でπを計算して、Pi に格納
; **********************************************************************
; */
;calc_pi()
;{
calc_pi:
;//	16 arctan(1/5)
;	m1=16;n1=5;
	ld	a, =16
	st	a,m1
	ld	a, =5
	st	a,n1
;	calc_M_atan_1_N();
	jsr	calc_M_atan_1_N
;	p2=#Pi ; p3=#ma ; mp_copy();		//	*Pi = *ma;
	ld	p2, =Pi
	ld	p3, =ma
	jsr	mp_copy
;
;// -4 arctan(1/239)
;	m1=4;n1=239;
	ld	a, =4
	st	a,m1
	ld	a, =239
	st	a,n1
;	calc_M_atan_1_N();
	jsr	calc_M_atan_1_N
;	p2=#Pi ; p3=#ma ; mp_sub();			// *Pi -= *ma;
	ld	p2, =Pi
	ld	p3, =ma
	jsr	mp_sub
;
;// ===> Pi
;}
	ret
;
;/**********************************************************************
; *	メインルーチン.
; **********************************************************************
; */
;pi_main()
;{
pi_main:
;	//div_test8();return;
;
;	p2=#PI_MSG_1;puts();	
	ld	p2, =PI_MSG_1
	jsr	puts
;
;	// 円周率計算.
;	calc_pi();
	jsr	calc_pi
;
;	// 円周率Print.
;	print_pi();
	jsr	print_pi
;}
	ret
;/**********************************************************************
; *
; **********************************************************************
; */
;
;Pi: 
Pi:
;	ds(PRECISION+2);
	ds	PRECISION+2
;ma: 
ma:
;	ds(PRECISION+2);
	ds	PRECISION+2
;mb: 
mb:
;	ds(PRECISION+2);
	ds	PRECISION+2
;mc: 
mc:
;	ds(PRECISION+2);
	ds	PRECISION+2
;_workend:
_workend:
;	ds(2);
	ds	2
;//
