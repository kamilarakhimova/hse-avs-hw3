# Целочисленные параметры в функции передаются в регистрах rdi, rsi, rdx, rcx, r8, r9, 
# а возвращаемое целочисленное значение передаётся в регистре rax (и в регистре rdx, если оно занимает более 64 байт).
# Возвращаемое дробное значение передаётся в регистре xmm0.

	.file	"main.c"						# имя файла, который компилировался
	.intel_syntax noprefix						# использование синтаксиса в стиле Intel
	.text
	.globl	f							# объявление и экспортирование вовне символа f
	.type	f, @function						# отмечаем, что f -- это функция
f:									# непосредственно функция f
	movapd	xmm1, xmm0						# xmm1 = xmm0 = x, выполняется процессором x86
	mulsd	xmm0, xmm0						# xmm0 = xmm0 * xmm0 = x * x
	mulsd	xmm0, xmm1						# xmm0 = xmm0 * xmm1 = x * x * x
	ret								# выход из функции f, возвращаем значение в xmm0 = x * x * x
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
	movsd	xmm4, QWORD PTR 40[rsp]					# xmm4 = h
	mov	r12d, 20						# r12d = 20 = n
	mulsd	xmm4, xmm0						# xmm4 = xmm4 * xmm0 = h * I2n
	pxor	xmm0, xmm0						# xmm0 = 0
	subsd	xmm0, xmm4						# xmm0 = xmm0 - xmm4 = In - I2n
	andpd	xmm0, XMMWORD PTR .LC2[rip]				# fabs(In - I2n)
	movsd	QWORD PTR 48[rsp], xmm4					# In = xmm4 = I2n
	comisd	xmm0, QWORD PTR 56[rsp]					# сравниваем xmm0 и error <=> сравниваем fabs(In - I2n) и error
	jb	.L19							# если меньше, то переходим на .L19
.L9:
	add	r12d, r12d						# r12d = r12d + r12d = n * 2
	pxor	xmm0, xmm0						# xmm0 = 0
	movq	xmm4, r14						# xmm4 = r14 = b - a
	cvtsi2sd	xmm0, r12d					# xmm0 = n
	divsd	xmm4, xmm0						# xmm4 = (b - a) / n
	movsd	QWORD PTR 40[rsp], xmm4					# QWORD PTR 40[rsp] = h = xmm4 = (b - a) / n
	test	r12d, r12d						# сраваниваем r12d = n и 0
	jle	.L11							# если меньше/равно, то переходим на .L11
	lea	ebp, -1[r12]						# ebp = n
	mov	r13d, -1						# r13d = -1
	pxor	xmm1, xmm1						# xmm1 = 0
.L8:
	pxor	xmm0, xmm0						# xmm0 = 0
	movsd	QWORD PTR 8[rsp], xmm1					# I2n = QWORD PTR 8[rsp] = xmm1 = 0
	cvtsi2sd	xmm0, r13d					# xmm0 = i - 1
	mulsd	xmm0, QWORD PTR 40[rsp]					# xmm0 = xmm0 * h = (i - 1) * h
	add	r13d, 1							# r13d += 1
	addsd	xmm0, QWORD PTR 16[rsp]					# xmm0 = xmm0 + a = a + (i - 1) * h
	call	rbx							# вызываем rbx = f
	mulsd	xmm0, QWORD PTR 32[rsp]					# xmm0 = n2 * xmm0 = n2 * f(a + (i - 1) * h)
	movsd	xmm1, QWORD PTR 8[rsp]					# xmm1 = I2n
	addsd	xmm0, QWORD PTR 24[rsp]					# xmm0 = n1 + xmm0 = n1 + n2 * f(a + (i - 1) * h)
	addsd	xmm1, xmm0						# xmm1 = xmm1 + xmm0 = I2n + n1 + n2 * f(a + (i - 1) * h)
	cmp	ebp, r13d						# сравниваем ebp и r13d <=> n и i
	jne	.L8							# если не равны, то переходим на .L8
.L7:
	mulsd	xmm1, QWORD PTR 40[rsp]					# xmm1 *= QWORD PTR 40[rsp] <=> I2n *= h
	movsd	xmm0, QWORD PTR 48[rsp]					# xmm0 = In
	subsd	xmm0, xmm1						# xmm0 -= xmm1 <=> In - I2n
	andpd	xmm0, XMMWORD PTR .LC2[rip]				# fabs(xmm0)
	comisd	xmm0, QWORD PTR 56[rsp]					# сравниваем xmm0 и error <=> сравниваем fabs(In - I2n) и error
	jb	.L3							# если меньше, то переходим на .L3
	movsd	QWORD PTR 48[rsp], xmm1					# QWORD PTR 48[rsp] = In
	jmp	.L9							# переходим (прыгаем) на метку .L9
.L19:
	movapd	xmm1, xmm4						# xmm1 = xmm4 = (b - a) / n
.L3:
	add	rsp, 64							# возвращаем стеку его 64 байта
	movapd	xmm0, xmm1						# xmm0 = xmm1 = I2n
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	ret								# выходим из функции integral, возвращаем значение в xmm0 = I2n
.L11:
	pxor	xmm1, xmm1						# xmm1 = 0
	jmp	.L7							# переходим (прыгаем) на метку .L7
.LC3:
	.string	"rw+"							# метка с "rw+" для вызова fopen для входного файла потом
.LC4:
	.string	"generator"						# метка с "generator" для получения входных данных через генерацию тестов потом
.LC5:
	.string	"Error! Try again, please."				# метка с "Еrror! Try again, please." для вывода сообщения об ошибке потом
.LC8:
	.string	"%lf %lf %lf %lf"					# метка с "%lf %lf %lf %lf" для вызова fprintf с результатами генерации данных потом
.LC9:
	.string	"%lf"							# метка с "%lf" для вызова fscanf, fprintf с сообщением о результате потом
.LC11:
	.string	"Elapsed: %ld ns"					# метка с "Elapsed: %ld ns" для вызова printf c сообщением о замере времени потом
.LC12:
	.string	"w+"							# метка с "w+" для вызова fopen для выходного файла потом
	.globl	main							# объявление и экспортирование вовне символа main
	.type	main, @function						# отмечаем, что main -- это функция
main:									# непосредственно функция main
	push	r13
	push	r12
	push	rbp
	sub	rsp, 112						# одалживаем у стека пространство в 112 байт
	cmp	edi, 4							# сравниваем edi и 4 <=> argc и 4
	jne	.L21							# если не равны, то переходим на .L21
	xor	edi, edi						# edi = 0
	mov	rbp, QWORD PTR 8[rsi]					# rbp = arg1
	mov	r13, QWORD PTR 24[rsi]					# r13 = arg3
	mov	r12, QWORD PTR 16[rsi]					# r12 = arg2
	call	time@PLT						# вызываем time(NULL)
	mov	rdi, rax						# получаемое от time(NULL) значение кладём в rdi
	call	srand@PLT						# вызываем srand() c аргументом time(NULL)
	mov	rdi, rbp						# в rdi кладём значение rbp = arg1
	lea	rsi, .LC3[rip]						# в rsi кладём значение .LC3[rip] = "rw+"
	call	fopen@PLT						# вызываем fopen(arg1, "rw+")
	lea	rsi, .LC4[rip]						# в rsi кладём значение .LC4[rip] = "generator"
	mov	rdi, r13						# rdi = r13 = arg3
	mov	rbp, rax						# получаемое от fopen(arg1, "rw+") значение кладём в rbp = input
	call	strcmp@PLT						# вызываем strcmp(arg3, "generator")
	test	eax, eax						# сравниваем eax = strcmp(arg3, "generator") и 0
	je	.L32							# если равны, то переходим на метку .L32
	test	rbp, rbp						# сравниваем rbp = input и 0
	je	.L21							# если равны, то переходим на метку .L21
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
