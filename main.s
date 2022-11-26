# Целочисленные параметры в функции передаются в регистрах rdi, rsi, rdx, rcx, r8, r9, 
# а возвращаемое целочисленное значение передаётся в регистре rax (и в регистре rdx, если оно занимает более 64 байт)

	.file	"main.c"						# имя файла, который компилировался
	.intel_syntax noprefix						# использование синтаксиса в стиле Intel
	.text
	.globl	f							# объявление и экспортирование вовне символа f
	.type	f, @function						# отмечаем, что f -- это функция
f:									# непосредственно функция f
	movapd	xmm1, xmm0						# xmm1 = xmm0 = x, выполняется процессором x86
	mulsd	xmm0, xmm0						# xmm0 = xmm0 * xmm0 = x * x
	mulsd	xmm0, xmm1						# xmm0 = xmm0 * xmm1 = x * x * x
	ret								# выход из функции, возвращаем значение в xmm0 = x * x * x
	.globl	integral						# объявление и экспортирование вовне символа integral
	.type	integral, @function					# отмечаем, что integral -- это функция
integral:								# непосредственно функция integral
	push	r14
	subsd	xmm1, xmm0						# xmm1 = xmm1 - xmm0 = b - a
	push	r13
	push	r12
	push	rbp
	movq	r14, xmm1						# r14 = xmm1 = b - a
	mov	ebp, -1							# ebp = -1 = i
	push	rbx
	mov	rbx, rdi						# rbx = rdi = f
	sub	rsp, 64							# rsp -= 64
	divsd	xmm1, QWORD PTR .LC1[rip]				# xmm1 = xmm1 / n = (b - a) / n = h
	mov	QWORD PTR 8[rsp], 0x000000000				# QWORD PTR 8[rsp] = I2n
	movsd	QWORD PTR 16[rsp], xmm0					# QWORD PTR 16[rsp] = a
	movsd	QWORD PTR 56[rsp], xmm2					# QWORD PTR 56[rsp] = error
	movsd	QWORD PTR 24[rsp], xmm3					# QWORD PTR 24[rsp] = n1
	movsd	QWORD PTR 32[rsp], xmm4					# QWORD PTR 32[rsp] = n2
	movsd	QWORD PTR 40[rsp], xmm1					# QWORD PTR 40[rsp] = h
.L4:
	pxor	xmm0, xmm0						# xmm0 = 0
	cvtsi2sd	xmm0, ebp					# xmm0 = i - 1
	mulsd	xmm0, QWORD PTR 40[rsp]					# xmm0 = xmm0 * h = (i - 1) * h
	add	ebp, 1							# ebp = ebp + 1 = i + 1
	addsd	xmm0, QWORD PTR 16[rsp]					# xmm0 = xmm0 + a = a + (i - 1) * h
	call	rbx							# вызываем rbx = f
	mulsd	xmm0, QWORD PTR 32[rsp]					# xmm0 = n2 * xmm0 = n2 * f(a + (i - 1) * h)
	addsd	xmm0, QWORD PTR 24[rsp]					# xmm0 = n1 + xmm0 = n1 + n2 * f(a + (i - 1) * h)
	addsd	xmm0, QWORD PTR 8[rsp]					# xmm0 = xmm0 + I2n = I2n + n1 + n2 * f(a + (i - 1) * h)
	movsd	QWORD PTR 8[rsp], xmm0					# I2n = xmm0 = I2n + n1 + n2 * f(a + (i - 1) * h)
	cmp	ebp, 19							# сравниваем ebp и 19 <=> сравниваем i и 19
	jne	.L4							# если не равны, то переходим на .L4
	movsd	xmm4, QWORD PTR 40[rsp]
	mov	r12d, 20
	mulsd	xmm4, xmm0
	pxor	xmm0, xmm0
	subsd	xmm0, xmm4
	andpd	xmm0, XMMWORD PTR .LC2[rip]
	movsd	QWORD PTR 48[rsp], xmm4
	comisd	xmm0, QWORD PTR 56[rsp]
	jb	.L19
.L9:
	add	r12d, r12d
	pxor	xmm0, xmm0
	movq	xmm4, r14
	cvtsi2sd	xmm0, r12d
	divsd	xmm4, xmm0
	movsd	QWORD PTR 40[rsp], xmm4
	test	r12d, r12d
	jle	.L11
	lea	ebp, -1[r12]
	mov	r13d, -1
	pxor	xmm1, xmm1
.L8:
	pxor	xmm0, xmm0
	movsd	QWORD PTR 8[rsp], xmm1
	cvtsi2sd	xmm0, r13d
	mulsd	xmm0, QWORD PTR 40[rsp]
	add	r13d, 1
	addsd	xmm0, QWORD PTR 16[rsp]
	call	rbx
	mulsd	xmm0, QWORD PTR 32[rsp]
	movsd	xmm1, QWORD PTR 8[rsp]
	addsd	xmm0, QWORD PTR 24[rsp]
	addsd	xmm1, xmm0
	cmp	ebp, r13d
	jne	.L8
.L7:
	mulsd	xmm1, QWORD PTR 40[rsp]
	movsd	xmm0, QWORD PTR 48[rsp]
	subsd	xmm0, xmm1
	andpd	xmm0, XMMWORD PTR .LC2[rip]
	comisd	xmm0, QWORD PTR 56[rsp]
	jb	.L3
	movsd	QWORD PTR 48[rsp], xmm1
	jmp	.L9
.L19:
	movapd	xmm1, xmm4
.L3:
	add	rsp, 64
	movapd	xmm0, xmm1
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret
.L11:
	pxor	xmm1, xmm1
	jmp	.L7
.LC3:
	.string	"rw+"
.LC4:
	.string	"generator"
.LC5:
	.string	"Error! Try again, please."
.LC8:
	.string	"%lf %lf %lf %lf"
.LC9:
	.string	"%lf"
.LC11:
	.string	"Elapsed: %ld ns"
.LC12:
	.string	"w+"
	.globl	main							# объявление и экспортирование вовне символа main
	.type	main, @function						# отмечаем, что main -- это функция
main:									# непосредственно функция main
	push	r13
	push	r12
	push	rbp
	sub	rsp, 112
	cmp	edi, 4
	jne	.L21
	xor	edi, edi
	mov	rbp, QWORD PTR 8[rsi]
	mov	r13, QWORD PTR 24[rsi]
	mov	r12, QWORD PTR 16[rsi]
	call	time@PLT
	mov	rdi, rax
	call	srand@PLT
	mov	rdi, rbp
	lea	rsi, .LC3[rip]
	call	fopen@PLT
	lea	rsi, .LC4[rip]
	mov	rdi, r13
	mov	rbp, rax
	call	strcmp@PLT
	test	eax, eax
	je	.L32
	test	rbp, rbp
	je	.L21
.L26:
	lea	rdx, 48[rsp]
	lea	rsi, .LC9[rip]
	mov	rdi, rbp
	xor	eax, eax
	call	__isoc99_fscanf@PLT
	lea	rdx, 56[rsp]
	mov	rdi, rbp
	xor	eax, eax
	lea	rsi, .LC9[rip]
	call	__isoc99_fscanf@PLT
	lea	rdx, 64[rsp]
	mov	rdi, rbp
	xor	eax, eax
	lea	rsi, .LC9[rip]
	call	__isoc99_fscanf@PLT
	mov	rdi, rbp
	lea	rdx, 72[rsp]
	xor	eax, eax
	lea	rsi, .LC9[rip]
	call	__isoc99_fscanf@PLT
	mov	rdi, rbp
	call	fclose@PLT
.L25:
	lea	rsi, 80[rsp]
	mov	edi, 1
	call	clock_gettime@PLT
	movsd	xmm4, QWORD PTR 56[rsp]
	movsd	xmm3, QWORD PTR 48[rsp]
	movsd	xmm2, QWORD PTR .LC10[rip]
	movsd	xmm1, QWORD PTR 72[rsp]
	mov	rdi, QWORD PTR f@GOTPCREL[rip]
	movsd	xmm0, QWORD PTR 64[rsp]
	call	integral@PLT
	lea	rsi, 96[rsp]
	mov	edi, 1
	movsd	QWORD PTR 8[rsp], xmm0
	call	clock_gettime@PLT
	mov	rcx, QWORD PTR 88[rsp]
	mov	rdx, QWORD PTR 80[rsp]
	mov	rdi, QWORD PTR 96[rsp]
	mov	rsi, QWORD PTR 104[rsp]
	call	timespecDiff@PLT
	lea	rsi, .LC11[rip]
	mov	edi, 1
	mov	rdx, rax
	xor	eax, eax
	call	__printf_chk@PLT
	lea	rsi, .LC12[rip]
	mov	rdi, r12
	call	fopen@PLT
	movsd	xmm0, QWORD PTR 8[rsp]
	mov	esi, 1
	lea	rdx, .LC9[rip]
	mov	rdi, rax
	mov	rbp, rax
	mov	eax, 1
	call	__fprintf_chk@PLT
	mov	rdi, rbp
	call	fclose@PLT
	xor	eax, eax
	jmp	.L20
.L21:
	lea	rsi, .LC5[rip]
	mov	edi, 1
	xor	eax, eax
	call	__printf_chk@PLT
	mov	eax, 1
.L20:
	add	rsp, 112
	pop	rbp
	pop	r12
	pop	r13
	ret
.L32:
	xor	edi, edi
	call	time@PLT
	mov	rdi, rax
	call	srand@PLT
	call	rand@PLT
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, eax
	divsd	xmm0, QWORD PTR .LC6[rip]
	mulsd	xmm0, QWORD PTR .LC1[rip]
	subsd	xmm0, QWORD PTR .LC7[rip]
	movsd	QWORD PTR 8[rsp], xmm0
	call	rand@PLT
	pxor	xmm1, xmm1
	cvtsi2sd	xmm1, eax
	divsd	xmm1, QWORD PTR .LC6[rip]
	mulsd	xmm1, QWORD PTR .LC1[rip]
	subsd	xmm1, QWORD PTR .LC7[rip]
	movsd	QWORD PTR 40[rsp], xmm1
	call	rand@PLT
	pxor	xmm2, xmm2
	cvtsi2sd	xmm2, eax
	divsd	xmm2, QWORD PTR .LC6[rip]
	mulsd	xmm2, QWORD PTR .LC1[rip]
	subsd	xmm2, QWORD PTR .LC7[rip]
	movsd	QWORD PTR 16[rsp], xmm2
	call	rand@PLT
	movsd	xmm2, QWORD PTR 16[rsp]
	pxor	xmm3, xmm3
	movsd	xmm5, QWORD PTR .LC7[rip]
	cvtsi2sd	xmm3, eax
	divsd	xmm3, QWORD PTR .LC6[rip]
	movsd	xmm1, QWORD PTR 40[rsp]
	mov	rdi, rbp
	subsd	xmm5, xmm2
	movsd	xmm0, QWORD PTR 8[rsp]
	mov	esi, 1
	lea	rdx, .LC8[rip]
	mov	eax, 4
	movsd	QWORD PTR 24[rsp], xmm2
	movsd	QWORD PTR 16[rsp], xmm1
	mulsd	xmm3, xmm5
	addsd	xmm3, xmm2
	movsd	QWORD PTR 32[rsp], xmm3
	call	__fprintf_chk@PLT
	movsd	xmm6, QWORD PTR 8[rsp]
	mov	rdi, r13
	movsd	xmm1, QWORD PTR 16[rsp]
	movsd	xmm2, QWORD PTR 24[rsp]
	movsd	xmm3, QWORD PTR 32[rsp]
	lea	rsi, .LC4[rip]
	movsd	QWORD PTR 48[rsp], xmm6
	movsd	QWORD PTR 56[rsp], xmm1
	movsd	QWORD PTR 64[rsp], xmm2
	movsd	QWORD PTR 72[rsp], xmm3
	call	strcmp@PLT
	test	eax, eax
	je	.L25
	jmp	.L26
.LC1:
	.long	0							# n for function integral
	.long	1077149696
.LC2:
	.long	-1
	.long	2147483647
	.long	0
	.long	0
.LC6:
	.long	-4194304
	.long	1105199103
.LC7:
	.long	0
	.long	1076101120
.LC10:
	.long	-350469331
	.long	1058682594
