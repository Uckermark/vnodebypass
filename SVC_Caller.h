#include <stdio.h>
#include <stdint.h>

int SVC_Access(const char* detectionPath) {
	int64_t flag = 0;
	__asm __volatile("mov x0, %0" :: "r" (detectionPath));    //path
	__asm __volatile("mov x1, #0");   //mode
	__asm __volatile("mov x16, #0x21");       //access
	__asm __volatile("svc #0x80");    //supervisor call
	__asm __volatile("mov %0, x0" : "=r" (flag));
	return flag;
}
