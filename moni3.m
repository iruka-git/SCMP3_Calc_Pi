/*
 ===========================================
 *	SC/MP-III Sample Program
 ===========================================
 */

#asm
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

#endasm
// スタート
	 nop;
	 sp=0x8000;
	 jmp(main);

getc()
{
     db(2);
}
putc()
{
     db(3);
}
exit()
{
     db(4);
}

// メイン
main()
{
	p2=#msg1;puts();	

	div_test();
	
//	benchmark();

	while(1) {	
		a='>';putc();
		p2=#inbuf;gets();

		// ECHO BACK.
		p2=#inbuf;puts();

		//
		p2=#inbuf;cmd();
	}
	exit();
}

benchmark()
{
	cnt1=0;
	do {
		cnt2=0;
		do {
			bench_subr();
		}while(--cnt2);
	}while(--cnt1);
	p2=#msg1;puts();	
	exit();
}

bench_subr()
{
	p4=0;
	do {
		bench_subr2();
	}while(--p4);
}
bench_subr2()
{
	push(ea);
	push(ea);
	pop(ea);
	pop(ea);
}

// P2 ポインタの１行バッファをcmd解釈.
// ワーク：
//    p4 = readhex()の戻り値.
//    p5 = 注目メモリーアドレスを覚えておく.
cmd()
{
	a=*p2++;lc();e=a;
	if(e=='d') {
		sp_skip();
		readhex();
		if(a!=0) {
			ea=p4;
			p5=ea;
		}
		ea=p5;p2=ea;mdump(); //メモリーダンプの実行.

		ea=p5;ea+=0x100;p5=ea;
	}	
	if(e=='q') {
		exit();
	}	
}

// ==========================================
// 入力関数

// P2 ポインタの空白文字飛ばし.
sp_skip()
{
	a=*p2;
	while(a==' ') {
		a=*p2++;  // p2++ だけしたい.
		a=*p2;
	}
}

p4mul16()
{
	push(ea);
	ea=p4;
	sl(ea);
	sl(ea);
	sl(ea);
	sl(ea);
	p4=ea;
	pop(ea);
}

// P2 ポインタから16進HEX読み. ==> p4に結果. 入力された桁数=Areg
readhex()
{
	ea=0;
	p4=ea;
	r4=a;
	while(1) {
		a=*p2++;e=a;
		readhex1();e=a;
		if(e!=0xff) {
			p4mul16();
			a=e;
			e<>a; a=0; e<>a; //e=0;
			ea+=p4;
			p4=ea;
			a=r4;a+=1;r4=a;
		}else{
			a=r4;
			return;
		}
	}
}

readhex1()
{
	lc();e=a;
	if(e>='0') {
		if(e<0x3a) { // <='9'
			a=e;
			a-=0x30;
			return;
		}
	}
	if(e>='a') {
		if(e<'g') {
			a=e;
			a-=0x57;  // 0x61 - 10
			return;
		}
	}
	a=0xff;
}


// ==========================================
// 出力関数

//  アスキーダンプ１行
ascdump_16()
{
	push(p2);
	p2=ea;
	ascdump_8();
	pr_spc();
	ascdump_8();
	pop(p2);
}

//  アスキーダンプ8byte
ascdump_8()
{
	a=8;cnt2=a;
	do {
		a=*p2++;
		ascdump1();
	} while(--cnt2);
}

//  アスキーダンプ1byte
ascdump1()
{
	e=a;
	if(e<0x20) {
		a=' ';e=a;
	}
	if(e>=0x7f) {
		a=' ';e=a;
	}
	a=e;putc();
}

//  大文字にする.
uc()
{
	e=a;
	if(e>='a') {
		if(e<0x7b) {  // <='z'
			a=e;
			a-=0x20;
			return;
		}
	}
	a=e;
}

//  小文字にする.
lc()
{
	e=a;
	if(e>='A') {
		if(e<0x5b) {  // <='Z'
			a=e;
			a+=0x20;
			return;
		}
	}
	a=e;
}


//  メモリーダンプ
mdump()
{
	a=16;cnt1=a;
	do {
		mdump_16();
	} while(--cnt1);
}

//  メモリーダンプ16byte
mdump_16()
{
	ea=p2;
	prhex4();
	pr_spc();

	mdump_8();
	pr_spc();
	mdump_8();

// ASCII DUMP
	ea=p2;ea-=16;
	ascdump_16();

	put_crlf();
}

//  メモリーダンプ8byte
mdump_8()
{
	a=8;cnt2=a;
	do {
		a=*p2++;
		prhex2();
		pr_spc();
	} while(--cnt2);
}

//  EAレジスタを16進4桁表示
prhex4()
{
	a<>e;
	prhex2();
	a<>e;
	prhex2();
}

//  Aレジスタを16進2桁表示
prhex2()
{
	push(ea);
	e=a;
	a>>=1;
	a>>=1;
	a>>=1;
	a>>=1;
	prhex1();

	a=e;
	prhex1();
	pop(ea);
}

//  Aレジスタ下位4bitのみを16進1桁表示
prhex1()
{
	push(ea);
	a&=0x0f;
	e=a;
	if( a >= 10) {
		a=e;a+=7;
	}else{
		a=e;
	}
	a += 0x30;
	putc();
	pop(ea);
}
//  空白文字を1つ出力
pr_spc()
{
	a=' ';putc();
}

//  改行コード出力
put_crlf()
{
	a=0x0d;putc();
	a=0x0a;putc();
}

//  文字列出力( P2 )ヌル終端.
puts()
{
	do {
		a=*p2++;
		if(a==0) break;
		putc();
	}while(1);	
}

//  文字列入力( P2 ) 0x0a + ヌル終端.
gets()
{
	do {
		getc();
		*p2++=a;
		e=a;
		if(e==0x0a) break;
		if(e==0x0d) break;
	}while(1);	

	a=0; *p2++=a;
}

//  文字列サンプル
msg1:
	db(" * SC/MP-III Monitor *");
	db(0x0d);
	db(0x0a);
	db(0);

inbuf:
	ds(128);

bufend:
	db(0);


// CALC PI //

// 割り算=========
// q0/q4

div32_16()
{
	cnt1=16;

	cyr0=0;
	cyr1=0;
	cyr2=0;

	do {

// === q0:q3 の32bit を左シフト(2倍)
		// q0 <<=1
		ea=q0;ea+=q0;
		q0=ea;
		// sr = CY(bit7)
		a=0;e=a;
		a=s;sl(ea);cyr0=ea;

		// q2 <<=1 : q2+= .CY
		ea=q2;ea+=q2;ea+=cyr1;
		q2=ea;
// === q2:q3 の16bit から q4:q5の16bit が減算できるなら減算する.
		ea-=q4;push(ea);
		a=e;if(a>=0) {
			pop(ea);
			q2=ea; //減算結果をq2に書き戻す.
			// q0++
			ea=q0;ea+=1;q0=ea;
		}else{
			pop(ea);//減算結果を破棄する.
		}
	}while(--cnt1);	
}

// 割り算テスト
div_test()
{
	// q0 = 12345
	ea=12345;q0=ea;
	ea=0    ;q2=ea;

	// q4 = 10
	ea=10   ;q4=ea;

	// q0/q4
	div32_16();

	ea=#q0;p2=ea;mdump(); //メモリーダンプの実行.
}

