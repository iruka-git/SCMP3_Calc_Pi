/*
 ===========================================
 *	SC/MP-III Sample Program
 ===========================================
 */
#asm
   cpu 8070
   org 0
wk1 = 0xff80

   nop;
#endasm

test_main()
{
	ea=100;
	wk1 = ea;
	p2=0x1000;
	push(p2);
	a=*p2;
	a=*p2++;
	*p3 = a;
	*p3++ = a;
	
	ea=#wk1;
	
	if( a == 0x10 ) {
		a='1';//		e=a;
	}
	if( a >= 0x10 ) {
		a=e;//		e=a;
	}
	if( a < 0x10 ) {
		ea=p2;//		e=a;
	}
	if( a > 0x10 ) {
		ea=p3;//		e=a;
	}
	if( a <= 0x10 ) {
		e=a;//		e=a;
	}
	if( ea == 0x10 ) {
		e=a;//		e=a;
	}
	pop(p2);
	//	p2[0]=a;

	while( a < 1 ) {
		a += 1;
	}
	while( ea == 100 ) {
		ea += 1;
	}
}

#asm

#include "../nibl3.asm"

#endasm
