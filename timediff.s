	.file	"timediff.c"
	.intel_syntax noprefix
	.text
	.globl	timespecDiff
	.type	timespecDiff, @function
timespecDiff:
	imul	rdi, rdi, 1000000000
	imul	rdx, rdx, 1000000000
	sub	rdi, rcx
	lea	rax, [rdi+rsi]
	sub	rax, rdx
	ret
