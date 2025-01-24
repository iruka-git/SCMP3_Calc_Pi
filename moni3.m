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

	pi_main();
	
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
			a=e;e=0;
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

//  メモリーダンプ8byte
mdump_b16()
{
	a=16;cnt2=a;
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

// =============  ここから、円周率計算 ===============
//
//
PI_MSG_1:
	db(0x0d);
	db(0x0a);
	db("> Calculating PI ... ");
	db(0x0d);
	db(0x0a);
	db(0);

PI_EQU_1:
	db("PI = ");
	db(0);

PI_EQU_2:
	db(" + ");
	db(0x0d);
	db(0x0a);
	db(0);

// 割り算=========
// q0/q4

div32_16()
{
	cyr0=0;
	cyr1=0;
	cyr2=0;

	divcnt=16;
	do {

// === q0:q3 の32bit を左シフト(2倍)
		// q0 <<=1
		ea=q0;ea+=q0;
		q0=ea;

		// sr = CY(bit7) CYをcyr1:cyr2に整数値(0 or 1)で保管.
		e=0;
		a=s;sl(ea);cyr0=ea;

		// q2 <<=1 : q2+= .CY
		ea=q2;ea+=q2;ea+=cyr1;
		q2=ea;
// === q2:q3 の16bit から q4:q5の16bit が減算できるなら減算する.
		ea-=q4;push(ea);

//		a=e;if(a>=0) {     // 減算結果の正負で引けたか見る. <== XXX

		a=s;if(a & 0x80) { // CYフラグで見る.
			pop(ea);
			q2=ea; //減算結果をq2に書き戻す.
			// q0++
			ild(a,q0);    //ea=q0;ea+=1;q0=ea;
		}else{
			pop(ea);//減算結果を破棄する.
		}
	}while(--divcnt);
}

div16_8()
{
//除算命令DIVはEAの内容をTの内容で割ります。EAには0から65536の値が、
//Tには1から32767までの範囲でEAより小さな値が入っていなくてはなりません。
//数値は符号なし、もしくは符号付きなら両方とも正の範囲でなくてはなりません。
//演算結果として商がEAに、剰余がTに入ります。ともに正の数です。

// === q0:q1 の16bit /  q4 (8bit) ==> q0 剰余は q1
	a=q4;e=0;t=ea; //除数をセット.

	ea=q0;         //被除数をセット.
	div(ea,t);
	q0=a;	//商.

	ea=t;
	q1=a;	//剰余.
}

#if 0
div16_8()
{
	divcnt=8;
	do {
// === q0:q1 の16bit を左シフト(2倍)
		ea=q0;ea+=q0;q0=ea;		// q0 <<=1

// === q1 から q4 が減算できるなら減算する.
		a=e;a-=q4;push(ea);

		// FIXME! CYフラグが常に1になるんだが・・・このCPU.

		a=s;if(a & 0x80) { // CYフラグで見る.
			pop(ea);
			q1=a; //減算結果をq1に書き戻す.

			ild(a,q0);	// q0++
		}else{
			pop(ea);//減算結果を破棄する.
		}
	}while(--divcnt);
}
#endif

// 割り算テスト
div_test16()
{
	ea=0    ;q2=ea;

	// q0 = 12345
	ea=41000  ;q0=ea;

	// q4 = 10
	ea=40000  ;q4=ea;

	// q0/q4
	div32_16();

	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
}

// 割り算テスト
div_test8()
{
	ea=0    ;q2=ea;

	// q0 = 12345
	ea=12345  ;q0=ea;

	// q4 = 16
	ea=100    ;q4=ea;

	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
	// q0/q4
	div16_8();

	p2=#q0;a='*';p2_dump(); //メモリーダンプの実行.
}

mp_set()
{
	e=a;
	*p2++ = 0;
	a=e;
	*p2++ = a;

	ea=#PRECISION;cnt1=ea;
	do {
		*p2++ = 0;
		dec_w(cnt1);
	}while(a!=0);
}

mp_zerochk()
{
	ea=#PRECISION; ea-=10; cnt1=ea;
	do {
		a = *p2++;
		if(a!=0) {
			return;
		}
		dec_w(cnt1);
	}while(a!=0);
	a=0; // Zero判定!
}

mp_copy()
{
	ea=#PRECISION;cnt1=ea;
	do {
		a = *p3++;
		    *p2++ = a;
		dec_w(cnt1);
	}while(a!=0);
}
/**********************************************************************
 *  p2 配列 の先頭ゼロをスキップする.
 **********************************************************************
 *  p2=ポインタ cnt1:cnt2=桁数(byte数)カウント
 */
mp_div_zeroskip16()
{
	do {
		a = p2[0];e=a;
		a = p2[1];
		a |= e;
		if(a!=0) return; // ea != 0

		//ポインタを2バイト進める
		ld(a,@2,p2);
		dec_w(cnt1);
	}while(a!=0);
	a=0;
}
/**********************************************************************
 *  p2 配列 の先頭ゼロをスキップする.
 **********************************************************************
 *  p2=ポインタ cnt1:cnt2=桁数(byte数)カウント
 */
mp_div_zeroskip8()
{
	do {
		a = p2[0];
		if(a!=0) return; // a != 0

		//ポインタを1バイト進める
		ld(a,@1,p2);
		dec_w(cnt1);
	}while(a!=0);
	a=0;
}
/**********************************************************************
 *  p2 配列 を 整数 reg_ea で除算する
 *	   一回の除算単位は 8bit (16bit/8bit)
 **********************************************************************
 *     q4 = 除数.
 *     p2 = 被除数配列.
 */
mp_div8()
{
	ea=#PRECISION;cnt1=ea;	// ループ回数.

	mp_div_zeroskip8();if(a==0) return; //全部ゼロ.

    a=0;q1=a;
	do {

/***
// :最適化前
		a = p2[0];
		q0=a; // q0:q1= 被除数.
		div16_8();
		// q0 = 商
		a=q0;
		p2[0]=a;	
		// q1 = 剰余(次のループで256倍して再利用)

		//ポインタを1バイト進める
		ld(a,@1,p2);
 ***/

// === q0:q1 の16bit /  q4 (8bit) ==> q0 剰余は q1
		a =p2[0];
		q0=a; // q0:q1= 被除数.

		e=0;a=q4;t=ea;
		ea=q0;
		div(ea,t);
		// q0 = 商
		*p2++=a;	

		// q1 = 剰余(次のループで256倍して再利用)
		ea=t;
		q1=a;	//剰余.
// ===

		dec_w(cnt1);
	}while(a!=0);
}
/**********************************************************************
 *  p2 配列 を 整数 reg_ea で除算する
 *	   一回の除算単位は16bit (32bit/16bit)
 **********************************************************************
 * mp_div(MP *p2,int ea)
 */
mp_div()
{
	q4=ea; 		// q4:q5 = 除数.
	ea=0;q2=ea;	// q2:q3 = 剰余ワーク（除算キャリー伝播としても使用）

	// 除数が 1～127の範囲内なら、DIV命令を使う8bit単位の多倍長演算に任せる.
	a=q5;if(a==0) {
		a=q4;if(a<0x80) {
			mp_div8();return;
		}
	}

	// 除数が 129～ の場合は、16bit 単位で処理する多倍長演算を実行する.
	ea=#PRECISION;ea>>=1;	// ループ回数.
	cnt1=ea;

	mp_div_zeroskip16();if(a==0) return; //全部ゼロ.

	do {
		a = p2[0];e=a;
		a = p2[1];
		q0=ea; // q0:q3= 被除数.
		div32_16();

		// q0:q1 = 商
		ea=q0;
		p2[1]=a; a=e;
		p2[0]=a;	
		// q2:q3 = 剰余(次のループで65536倍して再利用)

		//ポインタを2バイト進める
		ld(a,@2,p2);

		dec_w(cnt1);
	}while(a!=0);
}

p2_last()
{
	ea=p2;
	ea+=#PRECISION;
	ea-=1;
	p2=ea;
}
p3_last()
{
	ea=p3;
	ea+=#PRECISION;
	ea-=1;
	p3=ea;
}
/**********************************************************************
 *	多倍長減算： p2 = p2 - p3
 **********************************************************************
 *   mp_add(p2 += p3)
 */
mp_add()
{
	p2_last();
	p3_last();

	cyr1=0;	// CY
	cyr2=0;

	r0 = 0;
	r1 = 0;
	r2 = 0;
	r3 = 0;

	ea=#PRECISION;cnt1=ea;
	do {
		// p2[0] -= p3[0];
		a = *p2; r0 = a;
		a = *p3; r2 = a;

		ea = r0;
		ea +=r2;
		ea +=cyr1; // CY を含めて減算.
		*p2 = a;   // 減算結果8bit

		// CYをcyr1:cyr2に整数値(0 or 1)で保管.
		cyr1=0;
		a=e;if(a!=0) {cyr1=1;}

		// p2++ p3++;
		ld(a,@-1,p2);		
		ld(a,@-1,p3);		

		dec_w(cnt1);
	}while(a!=0);
}

/**********************************************************************
 *	多倍長減算： p2 = p2 - p3
 **********************************************************************
 *   mp_sub(p2 -= p3)
 */
mp_sub()
{
	p2_last();
	p3_last();

	cyr1=0;	// CY
	cyr2=0;

	r0 = 0;
	r1 = 0;
	r2 = 0;
	r3 = 0;

	ea=#PRECISION;cnt1=ea;
	do {
		// p2[0] -= p3[0];
		a = *p2; r0 = a;
		a = *p3; r2 = a;

		ea = r0;
		ea -=r2;
		ea -=cyr1; // CY を含めて減算.
		*p2 = a;   // 減算結果8bit

		// CYをcyr1:cyr2に整数値(0 or 1)で保管.
		cyr1=0;
		a=e;if(a!=0) {cyr1=1;}

		// p2-- p3--;
		ld(a,@-1,p2);		
		ld(a,@-1,p3);		

		dec_w(cnt1);
	}while(a!=0);
}
/**********************************************************************
 *  ea を 10倍する.
 **********************************************************************
 */
ea_mul10()
{
	// 乗算命令MPYはEAとTの内容を乗じて上位16 bitをEAに、下位16 bitをTに入れます。
	// 演算は符号付きで行われます。
	t=ea;
	ea=10;mpy(ea,t);
	ea=t;
}

/**********************************************************************
 *  ea を 二乗する.
 **********************************************************************
 */
ea_mul_ea()
{
	// 乗算命令MPYはEAとTの内容を乗じて上位16 bitをEAに、下位16 bitをTに入れます。
	// 演算は符号付きで行われます。
	t=ea;
		mpy(ea,t);
	ea=t;
}


/**********************************************************************
 *  m0 を 10倍する.
 **********************************************************************
 * mp_mul10(p2)
 */
mp_mul10()
{
	p2_last();

	cyr0=0;
	cyr1=0;	// CY
	cyr2=0;

	r2 = 0;
	r3 = 0;

	ea=#PRECISION;cnt1=ea;
	do {
		a = *p2; r0 = a;
		a = 0;   r1 = a;
		ea = r0; ea_mul10();ea+=r2;
		*p2 = a;   	// 乗算結果8bit
		
		a=e;r2=a;  	// 8bitを越える分をr2に保管.
		a=0;r3=a;

		// p2--;
		ld(a,@-1,p2);		

		dec_w(cnt1);
	}while(a!=0);
}

/**********************************************************************
 *	mp を小数以下 (PRECISION*2+1) まで印字.
 **********************************************************************
 * void print_pi(MP *p)
 */
print_pi()
{
	tab1=0;lf1=0;top1=0;
	
//	for(i=0;i< (PRECISION*2+1) ;i++) {

	ea=#PRECISION;ea<<=1;ea+=1;
	cnt3=ea;
	do {
		//a='+';pi_dump();
		ea=#Pi;p2=ea;
		a=p2[1];chr1=a;
		a=0;p2[0]=a;p2[1]=a;
		mp_mul10();
		a=top1;if(a==0) {
			top1=1;
//			printf("PI = %c. + \n",'0'+c);
			push(p2);
			p2=#PI_EQU_1; puts();
			a=chr1;a+='0';putc();
			p2=#PI_EQU_2; puts();
			pop(p2);
		}else{
			a=chr1;a+='0';putc();
			ild(a,tab1);  // tab1++;
			if(a>=10) {tab1=0;
				a=' ';putc();
				ild(a,lf1);  // tab1++;
				if(a>=5) {lf1=0;
					put_crlf();
				}
			}
		}
		dec_w(cnt3);
	}while(a!=0);

	put_crlf();
}

/**********************************************************************
 *  ひとつのArcTan項を計算する ma = m * atan(1/n)
 **********************************************************************
    void calc_M_atan_1_N(int m1,int n1)
 */
calc_M_atan_1_N()
{
// n_2 = n1*n1
	e=0;a=n1; ea_mul_ea(); n_2=ea;
	// p2=#n_2; a='*';p2_dump();

// ma = m * (1/n)
	p2=#ma ; e=0;a=m1  ; mp_set();
	p2=#ma ; e=0;a=n1  ; mp_div();

// mc = m * (1/n)
	p2=#mc ; p3=#ma    ; mp_copy();		//	mc = ma;

// arctan(x) = x - (1/3)x**3 + (1/5)x**5 - (1/7)x**7 ・・・
// LOOP: ma +-= mb

	sign1=0;

	ea=3;indx0=ea; // indx0 = 3,5,7,9,11, ...
	while(1) {
		// mc = mc*(1/n)*(1/n)
		a=n_2;if(a==25) {
			p2=#mc;	ea=n_2;   mp_div();			// mc = mc * (1/ (n*n) );
		}else{
			p2=#mc;	e=0;a=n1; mp_div();
			p2=#mc;	e=0;a=n1; mp_div();
		}
		// mb = mc*(1/i)
		p2=#mb ; p3=#mc ; mp_copy();		//	mb = mc;
		p2=#mb ; ea=indx0; mp_div();		//  mb /= indx0;

		p2=#mb ; mp_zerochk(); if(a==0) break;
		
		p2=#ma ; p3=#mb ;

		a=sign1;a ^= 1;sign1=a;
		if(a!=0) {
			mp_sub();	// ma += mb;
		}else{
			mp_add();	// ma -= mb;
		}

		// indx0 += 2;
		ea=indx0;ea+=2;
		indx0=ea;
	}

	a='A'; ma_dump();
}

/**********************************************************************
 *	デバッグルーチン
 **********************************************************************
 */
dump_pi()
{
	p2=#Pi; mdump(); //メモリーダンプの実行.
}
p2_dump()
{
	putc();
	a=':';putc();

	mdump_8();
	put_crlf();
}

q0_dump()
{
	push(p2);
	p2=#q0;p2_dump();
	pop(p2);
}

pi_dump()
{
	push(p2);
	p2=#Pi;p2_dump();
	pop(p2);
}

ma_dump()
{
	push(p2);
	p2=#ma;p2_dump();
	pop(p2);
}

mb_dump()
{
	push(p2);
	p2=#mb;p2_dump();
	pop(p2);
}

mc_dump()
{
	push(p2);
	p2=#mc;p2_dump();
	pop(p2);
}

/**********************************************************************
 *	マチンの公式でπを計算して、Pi に格納
 **********************************************************************
 */
calc_pi()
{
//	16 arctan(1/5)
	m1=16;n1=5;
	calc_M_atan_1_N();
	p2=#Pi ; p3=#ma ; mp_copy();		//	*Pi = *ma;

// -4 arctan(1/239)
	m1=4;n1=239;
	calc_M_atan_1_N();
	p2=#Pi ; p3=#ma ; mp_sub();			// *Pi -= *ma;

// ===> Pi
}

/**********************************************************************
 *	メインルーチン.
 **********************************************************************
 */
pi_main()
{
	//div_test8();return;

	p2=#PI_MSG_1;puts();	

	// 円周率計算.
	calc_pi();

	// 円周率Print.
	print_pi();
}
/**********************************************************************
 *
 **********************************************************************
 */

Pi: 
	ds(PRECISION+2);
ma: 
	ds(PRECISION+2);
mb: 
	ds(PRECISION+2);
mc: 
	ds(PRECISION+2);
_workend:
	ds(2);
//

