	.file	"geofencing_generic.c"
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC2:
	.string	"Error: Latitud fuera del rango v\303\241lido: %.6f\n"
	.align 8
.LC5:
	.string	"Error: Longitud fuera del rango v\303\241lido: %.6f\n"
	.text
	.p2align 4
	.globl	validateGPSCoordinates
	.type	validateGPSCoordinates, @function
validateGPSCoordinates:
.LFB50:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movsd	.LC0(%rip), %xmm2
	comisd	%xmm0, %xmm2
	ja	.L2
	comisd	.LC1(%rip), %xmm0
	ja	.L2
	movsd	.LC3(%rip), %xmm0
	comisd	%xmm1, %xmm0
	ja	.L6
	comisd	.LC4(%rip), %xmm1
	movl	$1, %eax
	ja	.L6
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L6:
	.cfi_restore_state
	movapd	%xmm1, %xmm0
	movl	$1, %edi
	movl	$1, %eax
	leaq	.LC5(%rip), %rsi
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L2:
	.cfi_restore_state
	leaq	.LC2(%rip), %rsi
	movl	$1, %edi
	movl	$1, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE50:
	.size	validateGPSCoordinates, .-validateGPSCoordinates
	.section	.rodata.str1.8
	.align 8
.LC6:
	.string	"Warning: N\303\272mero de sat\303\251lites sospechoso: %d\n"
	.align 8
.LC9:
	.string	"Warning: HDOP fuera del rango t\303\255pico: %.2f\n"
	.text
	.p2align 4
	.globl	validateGPSQuality
	.type	validateGPSQuality, @function
validateGPSQuality:
.LFB51:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	cmpl	$50, %edi
	ja	.L21
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L16
	comisd	.LC8(%rip), %xmm0
	movl	$1, %eax
	ja	.L16
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L16:
	.cfi_restore_state
	leaq	.LC9(%rip), %rsi
	movl	$1, %edi
	movl	$1, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L21:
	.cfi_restore_state
	movl	%edi, %edx
	leaq	.LC6(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE51:
	.size	validateGPSQuality, .-validateGPSQuality
	.section	.rodata.str1.8
	.align 8
.LC16:
	.string	"Warning: Distancia calculada sospechosa: %.2f metros\n"
	.text
	.p2align 4
	.globl	generic_calculateDistance
	.type	generic_calculateDistance, @function
generic_calculateDistance:
.LFB52:
	.cfi_startproc
	endbr64
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movsd	%xmm0, 24(%rsp)
	movsd	%xmm1, 32(%rsp)
	movsd	%xmm2, 8(%rsp)
	movsd	%xmm3, 16(%rsp)
	call	validateGPSCoordinates
	testb	%al, %al
	jne	.L23
.L34:
	movsd	.LC10(%rip), %xmm0
.L22:
	addq	$56, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L23:
	.cfi_restore_state
	movsd	16(%rsp), %xmm1
	movsd	8(%rsp), %xmm0
	call	validateGPSCoordinates
	testb	%al, %al
	je	.L34
	movsd	8(%rsp), %xmm0
	subsd	24(%rsp), %xmm0
	mulsd	.LC11(%rip), %xmm0
	divsd	.LC4(%rip), %xmm0
	mulsd	.LC12(%rip), %xmm0
	call	sin@PLT
	movsd	.LC11(%rip), %xmm7
	mulsd	24(%rsp), %xmm7
	movsd	%xmm0, 40(%rsp)
	movapd	%xmm7, %xmm0
	divsd	.LC4(%rip), %xmm0
	call	cos@PLT
	movsd	.LC11(%rip), %xmm7
	mulsd	8(%rsp), %xmm7
	movsd	%xmm0, 24(%rsp)
	movapd	%xmm7, %xmm0
	divsd	.LC4(%rip), %xmm0
	call	cos@PLT
	movsd	16(%rsp), %xmm5
	subsd	32(%rsp), %xmm5
	movsd	%xmm0, 8(%rsp)
	movsd	.LC11(%rip), %xmm0
	mulsd	%xmm5, %xmm0
	divsd	.LC4(%rip), %xmm0
	mulsd	.LC12(%rip), %xmm0
	call	sin@PLT
	movsd	24(%rsp), %xmm4
	mulsd	8(%rsp), %xmm4
	movapd	%xmm0, %xmm1
	movsd	40(%rsp), %xmm2
	mulsd	%xmm2, %xmm2
	movapd	%xmm4, %xmm0
	pxor	%xmm4, %xmm4
	mulsd	%xmm1, %xmm0
	mulsd	%xmm1, %xmm0
	addsd	%xmm0, %xmm2
	movsd	.LC13(%rip), %xmm0
	subsd	%xmm2, %xmm0
	ucomisd	%xmm0, %xmm4
	movapd	%xmm0, %xmm1
	sqrtsd	%xmm1, %xmm1
	ja	.L35
.L26:
	pxor	%xmm5, %xmm5
	movapd	%xmm2, %xmm3
	ucomisd	%xmm2, %xmm5
	sqrtsd	%xmm3, %xmm3
	ja	.L36
.L27:
	movapd	%xmm3, %xmm0
	call	atan2@PLT
	pxor	%xmm6, %xmm6
	addsd	%xmm0, %xmm0
	mulsd	.LC14(%rip), %xmm0
	comisd	%xmm0, %xmm6
	ja	.L28
	comisd	.LC15(%rip), %xmm0
	jbe	.L22
.L28:
	leaq	.LC16(%rip), %rsi
	movl	$1, %edi
	movl	$1, %eax
	call	__printf_chk@PLT
	jmp	.L34
.L36:
	movapd	%xmm2, %xmm0
	movsd	%xmm3, 16(%rsp)
	movsd	%xmm1, 8(%rsp)
	call	sqrt@PLT
	movsd	16(%rsp), %xmm3
	movsd	8(%rsp), %xmm1
	jmp	.L27
.L35:
	movsd	%xmm1, 16(%rsp)
	movsd	%xmm2, 8(%rsp)
	call	sqrt@PLT
	movsd	16(%rsp), %xmm1
	movsd	8(%rsp), %xmm2
	jmp	.L26
	.cfi_endproc
.LFE52:
	.size	generic_calculateDistance, .-generic_calculateDistance
	.section	.rodata.str1.8
	.align 8
.LC17:
	.string	"Error: Puntero NULL en isInsideGeofence"
	.align 8
.LC18:
	.string	"Error: Radio de geocerca inv\303\241lido: %.2f metros\n"
	.align 8
.LC19:
	.string	"Warning: Se\303\261al GPS de baja calidad"
	.align 8
.LC20:
	.string	"Error: No se pudo calcular la distancia"
	.text
	.p2align 4
	.globl	generic_isInsideGeofence
	.type	generic_isInsideGeofence, @function
generic_isInsideGeofence:
.LFB53:
	.cfi_startproc
	endbr64
	testq	%rdi, %rdi
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	sete	%al
	testq	%rsi, %rsi
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	sete	%r12b
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	orb	%al, %r12b
	jne	.L55
	movsd	8(%rdi), %xmm1
	movsd	(%rdi), %xmm0
	movq	%rdi, %rbx
	movq	%rsi, %rbp
	call	validateGPSCoordinates
	testb	%al, %al
	jne	.L56
.L37:
	movl	%r12d, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L56:
	.cfi_restore_state
	movsd	8(%rbp), %xmm1
	movsd	0(%rbp), %xmm0
	call	validateGPSCoordinates
	testb	%al, %al
	je	.L37
	movsd	16(%rbp), %xmm0
	pxor	%xmm4, %xmm4
	comisd	%xmm0, %xmm4
	jnb	.L42
	comisd	.LC15(%rip), %xmm0
	ja	.L42
	movsd	40(%rbx), %xmm0
	movl	32(%rbx), %edi
	call	validateGPSQuality
	testb	%al, %al
	je	.L57
.L45:
	movsd	8(%rbp), %xmm3
	movsd	0(%rbp), %xmm2
	movsd	8(%rbx), %xmm1
	movsd	(%rbx), %xmm0
	call	generic_calculateDistance
	pxor	%xmm5, %xmm5
	comisd	%xmm0, %xmm5
	ja	.L58
	movsd	16(%rbp), %xmm1
	comisd	%xmm0, %xmm1
	setnb	%r12b
	jmp	.L37
	.p2align 4,,10
	.p2align 3
.L55:
	xorl	%r12d, %r12d
	leaq	.LC17(%rip), %rdi
	call	puts@PLT
	movl	%r12d, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L42:
	.cfi_restore_state
	leaq	.LC18(%rip), %rsi
	movl	$1, %edi
	movl	$1, %eax
	call	__printf_chk@PLT
	movl	%r12d, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L57:
	.cfi_restore_state
	leaq	.LC19(%rip), %rdi
	call	puts@PLT
	jmp	.L45
	.p2align 4,,10
	.p2align 3
.L58:
	leaq	.LC20(%rip), %rdi
	call	puts@PLT
	jmp	.L37
	.cfi_endproc
.LFE53:
	.size	generic_isInsideGeofence, .-generic_isInsideGeofence
	.p2align 4
	.globl	generic_evaluateGPSQuality
	.type	generic_evaluateGPSQuality, @function
generic_evaluateGPSQuality:
.LFB54:
	.cfi_startproc
	endbr64
	testl	%edi, %edi
	js	.L68
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L68
	cmpl	$7, %edi
	jle	.L61
	movsd	.LC13(%rip), %xmm1
	comisd	%xmm0, %xmm1
	jnb	.L73
.L62:
	movsd	.LC21(%rip), %xmm1
	movl	$3, %eax
	comisd	%xmm0, %xmm1
	jnb	.L74
.L64:
	movsd	.LC22(%rip), %xmm1
	movl	$2, %eax
	comisd	%xmm0, %xmm1
	jnb	.L75
.L66:
	movsd	.LC23(%rip), %xmm1
	xorl	%eax, %eax
	comisd	%xmm0, %xmm1
	setnb	%al
	ret
	.p2align 4,,10
	.p2align 3
.L61:
	cmpl	$5, %edi
	jg	.L62
	cmpl	$3, %edi
	jg	.L64
	movl	$0, %eax
	je	.L66
	ret
	.p2align 4,,10
	.p2align 3
.L74:
	ret
	.p2align 4,,10
	.p2align 3
.L75:
	ret
	.p2align 4,,10
	.p2align 3
.L73:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L68:
	movl	$-1, %eax
	ret
	.cfi_endproc
.LFE54:
	.size	generic_evaluateGPSQuality, .-generic_evaluateGPSQuality
	.section	.rodata.str1.8
	.align 8
.LC24:
	.string	"Error: Velocidad negativa: %.2f km/h\n"
	.align 8
.LC26:
	.string	"Warning: Velocidad muy alta: %.2f km/h\n"
	.text
	.p2align 4
	.globl	generic_isVehicleMoving
	.type	generic_isVehicleMoving, @function
generic_isVehicleMoving:
.LFB55:
	.cfi_startproc
	endbr64
	pxor	%xmm1, %xmm1
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	comisd	%xmm0, %xmm1
	ja	.L86
	comisd	.LC25(%rip), %xmm0
	ja	.L87
.L80:
	comisd	.LC22(%rip), %xmm0
	seta	%al
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L87:
	.cfi_restore_state
	movl	$1, %edi
	leaq	.LC26(%rip), %rsi
	movl	$1, %eax
	movsd	%xmm0, 8(%rsp)
	call	__printf_chk@PLT
	movsd	8(%rsp), %xmm0
	jmp	.L80
	.p2align 4,,10
	.p2align 3
.L86:
	leaq	.LC24(%rip), %rsi
	movl	$1, %edi
	movl	$1, %eax
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE55:
	.size	generic_isVehicleMoving, .-generic_isVehicleMoving
	.section	.rodata.str1.8
	.align 8
.LC27:
	.string	"Error: Punteros NULL en processGeofencing"
	.align 8
.LC28:
	.string	"Error: N\303\272mero de geocercas inv\303\241lido: %d\n"
	.align 8
.LC29:
	.string	"Warning: Calidad GPS insuficiente (calidad: %d)\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC30:
	.string	"Punto dentro de geocerca: %s\n"
	.text
	.p2align 4
	.globl	generic_processGeofencing
	.type	generic_processGeofencing, @function
generic_processGeofencing:
.LFB56:
	.cfi_startproc
	endbr64
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	testq	%rdi, %rdi
	je	.L96
	movq	%rsi, %rbx
	testq	%rsi, %rsi
	je	.L96
	movl	%edx, %r13d
	testl	%edx, %edx
	jle	.L101
	movsd	40(%rdi), %xmm0
	movq	%rdi, %r14
	movl	32(%rdi), %edi
	call	generic_evaluateGPSQuality
	cmpl	$1, %eax
	jle	.L102
	movsd	24(%r14), %xmm0
	xorl	%r12d, %r12d
	call	generic_isVehicleMoving
	movl	%eax, %ebp
	.p2align 4,,10
	.p2align 3
.L95:
	movq	%rbx, %rsi
	movq	%r14, %rdi
	call	generic_isInsideGeofence
	testb	%al, %al
	jne	.L103
	addl	$1, %r12d
	addq	$88, %rbx
	cmpl	%r12d, %r13d
	jne	.L95
	movl	$-3, %r12d
.L88:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	movl	%r12d, %eax
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L103:
	.cfi_restore_state
	leaq	24(%rbx), %rdx
	xorl	%eax, %eax
	movl	$1, %edi
	leaq	.LC30(%rip), %rsi
	call	__printf_chk@PLT
	leal	100(%r12), %eax
	testb	%bpl, %bpl
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	cmovne	%eax, %r12d
	popq	%rbp
	.cfi_def_cfa_offset 32
	movl	%r12d, %eax
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	ret
.L102:
	.cfi_restore_state
	movl	%eax, %edx
	leaq	.LC29(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$-2, %r12d
	jmp	.L88
.L96:
	leaq	.LC27(%rip), %rdi
	movl	$-1, %r12d
	call	puts@PLT
	jmp	.L88
.L101:
	leaq	.LC28(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	movl	$-1, %r12d
	call	__printf_chk@PLT
	jmp	.L88
	.cfi_endproc
.LFE56:
	.size	generic_processGeofencing, .-generic_processGeofencing
	.section	.rodata.str1.8
	.align 8
.LC31:
	.string	"\360\237\224\204 BENCHMARK GEN\303\211RICO - Sin optimizaciones"
	.align 8
.LC32:
	.string	"=========================================="
	.section	.rodata.str1.1
.LC48:
	.string	"Tiempo total: %.4f segundos\n"
	.section	.rodata.str1.8
	.align 8
.LC50:
	.string	"Operaciones por segundo: %.0f\n"
	.align 8
.LC51:
	.string	"Tiempo por operaci\303\263n: %.2f \316\274s\n"
	.align 8
.LC53:
	.string	"Geofencing completo: %.0f ops/seg\n"
	.text
	.p2align 4
	.globl	generic_benchmark
	.type	generic_benchmark, @function
generic_benchmark:
.LFB57:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	leaq	.LC31(%rip), %rdi
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movl	$100000, %r13d
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$328, %rsp
	.cfi_def_cfa_offset 384
	movq	%fs:40, %rax
	movq	%rax, 312(%rsp)
	xorl	%eax, %eax
	leaq	112(%rsp), %r12
	leaq	304(%rsp), %rbp
	call	puts@PLT
	leaq	.LC32(%rip), %rdi
	call	puts@PLT
	movq	.LC33(%rip), %rax
	movl	$7, 144(%rsp)
	movl	$8, 192(%rsp)
	movq	%rax, 112(%rsp)
	movq	.LC34(%rip), %rax
	movq	$0x000000000, 208(%rsp)
	movq	%rax, 120(%rsp)
	movq	.LC35(%rip), %rax
	movq	$0x000000000, 216(%rsp)
	movq	%rax, 128(%rsp)
	movq	.LC36(%rip), %rax
	movq	$0x000000000, 224(%rsp)
	movq	%rax, 136(%rsp)
	movq	.LC37(%rip), %rax
	movq	$0x000000000, 232(%rsp)
	movq	%rax, 152(%rsp)
	movq	.LC38(%rip), %rax
	movl	$4, 240(%rsp)
	movq	%rax, 160(%rsp)
	movq	.LC39(%rip), %rax
	movq	%rax, 168(%rsp)
	movq	.LC40(%rip), %rax
	movq	%rax, 176(%rsp)
	movq	.LC8(%rip), %rax
	movq	%rax, 184(%rsp)
	movq	.LC13(%rip), %rax
	movq	%rax, 200(%rsp)
	movq	.LC41(%rip), %rax
	movq	%rax, 248(%rsp)
	movq	.LC42(%rip), %rax
	movq	%rax, 256(%rsp)
	movq	.LC43(%rip), %rax
	movq	%rax, 264(%rsp)
	movq	.LC44(%rip), %rax
	movdqa	.LC54(%rip), %xmm0
	movl	$6, 288(%rsp)
	movq	%rax, 272(%rsp)
	movq	.LC22(%rip), %rax
	movups	%xmm0, 40(%rsp)
	pxor	%xmm0, %xmm0
	movq	%rax, 280(%rsp)
	movq	.LC21(%rip), %rax
	movups	%xmm0, 56(%rsp)
	movq	%rax, 296(%rsp)
	movq	.LC45(%rip), %rax
	movups	%xmm0, 72(%rsp)
	movq	%rax, 16(%rsp)
	movq	.LC46(%rip), %rax
	movups	%xmm0, 88(%rsp)
	movq	%rax, 24(%rsp)
	movq	.LC25(%rip), %rax
	movq	%rax, 32(%rsp)
	call	clock@PLT
	movq	%rax, %r14
	.p2align 4,,10
	.p2align 3
.L105:
	movq	%r12, %rbx
.L106:
	movsd	8(%rbx), %xmm1
	movsd	(%rbx), %xmm0
	addq	$48, %rbx
	movsd	24(%rsp), %xmm3
	movsd	16(%rsp), %xmm2
	call	generic_calculateDistance
	cmpq	%rbx, %rbp
	jne	.L106
	subl	$1, %r13d
	jne	.L105
	call	clock@PLT
	pxor	%xmm1, %xmm1
	leaq	.LC48(%rip), %rsi
	movl	$1, %edi
	subq	%r14, %rax
	movl	$10000, %ebp
	leaq	16(%rsp), %rbx
	cvtsi2sdq	%rax, %xmm1
	movl	$1, %eax
	divsd	.LC47(%rip), %xmm1
	movapd	%xmm1, %xmm0
	movsd	%xmm1, 8(%rsp)
	leaq	160(%rsp), %r15
	leaq	208(%rsp), %r14
	call	__printf_chk@PLT
	movsd	8(%rsp), %xmm1
	movl	$1, %edi
	movsd	.LC49(%rip), %xmm0
	leaq	.LC50(%rip), %rsi
	movl	$1, %eax
	leaq	256(%rsp), %r13
	divsd	%xmm1, %xmm0
	call	__printf_chk@PLT
	movsd	8(%rsp), %xmm1
	movl	$1, %edi
	movsd	.LC47(%rip), %xmm0
	leaq	.LC51(%rip), %rsi
	movl	$1, %eax
	mulsd	%xmm1, %xmm0
	divsd	.LC49(%rip), %xmm0
	call	__printf_chk@PLT
	call	clock@PLT
	movq	%rax, 8(%rsp)
	.p2align 4,,10
	.p2align 3
.L108:
	movl	$1, %edx
	movq	%rbx, %rsi
	movq	%r12, %rdi
	call	generic_processGeofencing
	movl	$1, %edx
	movq	%rbx, %rsi
	movq	%r15, %rdi
	call	generic_processGeofencing
	movl	$1, %edx
	movq	%rbx, %rsi
	movq	%r14, %rdi
	call	generic_processGeofencing
	movl	$1, %edx
	movq	%rbx, %rsi
	movq	%r13, %rdi
	call	generic_processGeofencing
	subl	$1, %ebp
	jne	.L108
	call	clock@PLT
	pxor	%xmm0, %xmm0
	movsd	.LC52(%rip), %xmm1
	subq	8(%rsp), %rax
	cvtsi2sdq	%rax, %xmm0
	movl	$1, %edi
	movl	$1, %eax
	divsd	.LC47(%rip), %xmm0
	divsd	%xmm0, %xmm1
	leaq	.LC53(%rip), %rsi
	movapd	%xmm1, %xmm0
	call	__printf_chk@PLT
	movq	312(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L113
	addq	$328, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L113:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE57:
	.size	generic_benchmark, .-generic_benchmark
	.section	.rodata.str1.8
	.align 8
.LC55:
	.string	"\n\360\237\222\276 USO DE MEMORIA GEN\303\211RICO"
	.section	.rodata.str1.1
.LC56:
	.string	"========================="
	.section	.rodata.str1.8
	.align 8
.LC57:
	.string	"Tama\303\261o GenericGPSPoint: %zu bytes\n"
	.align 8
.LC58:
	.string	"Tama\303\261o GenericGeofence: %zu bytes\n"
	.align 8
.LC59:
	.string	"Total por punto + geocerca: %zu bytes\n"
	.text
	.p2align 4
	.globl	generic_memory_usage
	.type	generic_memory_usage, @function
generic_memory_usage:
.LFB58:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC55(%rip), %rdi
	call	puts@PLT
	leaq	.LC56(%rip), %rdi
	call	puts@PLT
	movl	$48, %edx
	leaq	.LC57(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$88, %edx
	leaq	.LC58(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$136, %edx
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	leaq	.LC59(%rip), %rsi
	movl	$1, %edi
	jmp	__printf_chk@PLT
	.cfi_endproc
.LFE58:
	.size	generic_memory_usage, .-generic_memory_usage
	.section	.rodata.str1.8
	.align 8
.LC60:
	.string	"\n\360\237\216\257 PRUEBA DE PRECISI\303\223N GEN\303\211RICA"
	.align 8
.LC61:
	.string	"==============================="
	.section	.rodata.str1.1
.LC65:
	.string	"Arequipa local"
.LC67:
	.string	"Madrid-Arequipa"
.LC69:
	.string	"1 grado longitud en ecuador"
.LC71:
	.string	"Polo a polo"
	.section	.rodata.str1.8
	.align 8
.LC73:
	.string	"%s: %.2f km (esperado: %.2f km, error: %.2f%%)\n"
	.text
	.p2align 4
	.globl	generic_accuracy_test
	.type	generic_accuracy_test, @function
generic_accuracy_test:
.LFB59:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	leaq	.LC60(%rip), %rdi
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	leaq	.LC73(%rip), %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	subq	$208, %rsp
	.cfi_def_cfa_offset 240
	movq	%fs:40, %rax
	movq	%rax, 200(%rsp)
	xorl	%eax, %eax
	movq	%rsp, %rbx
	leaq	192(%rsp), %r12
	call	puts@PLT
	leaq	.LC61(%rip), %rdi
	call	puts@PLT
	movq	.LC33(%rip), %rax
	movsd	.LC62(%rip), %xmm1
	movq	$0x000000000, 96(%rsp)
	movsd	.LC63(%rip), %xmm0
	movq	$0x000000000, 104(%rsp)
	movq	%rax, (%rsp)
	movq	.LC34(%rip), %rax
	movq	$0x000000000, 112(%rsp)
	movq	%rax, 8(%rsp)
	movq	.LC64(%rip), %rax
	movq	$0x000000000, 152(%rsp)
	movq	%rax, 32(%rsp)
	leaq	.LC65(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	.LC38(%rip), %rax
	movsd	%xmm1, 16(%rsp)
	movq	%rax, 48(%rsp)
	movq	.LC39(%rip), %rax
	movsd	%xmm0, 24(%rsp)
	movq	%rax, 56(%rsp)
	movq	.LC66(%rip), %rax
	movsd	%xmm1, 64(%rsp)
	movq	%rax, 80(%rsp)
	leaq	.LC67(%rip), %rax
	movq	%rax, 88(%rsp)
	movq	.LC13(%rip), %rax
	movsd	%xmm0, 72(%rsp)
	movq	%rax, 120(%rsp)
	movq	.LC68(%rip), %rax
	movq	%rax, 128(%rsp)
	leaq	.LC69(%rip), %rax
	movq	%rax, 136(%rsp)
	movq	.LC1(%rip), %rax
	movq	%rax, 144(%rsp)
	movq	.LC0(%rip), %rax
	movq	%rax, 160(%rsp)
	movq	.LC70(%rip), %rax
	movq	$0x000000000, 168(%rsp)
	movq	%rax, 176(%rsp)
	leaq	.LC71(%rip), %rax
	movq	%rax, 184(%rsp)
.L117:
	movsd	24(%rbx), %xmm3
	movsd	16(%rbx), %xmm2
	addq	$48, %rbx
	movsd	-40(%rbx), %xmm1
	movsd	-48(%rbx), %xmm0
	call	generic_calculateDistance
	movsd	-16(%rbx), %xmm1
	movq	-8(%rbx), %rdx
	movq	%rbp, %rsi
	divsd	.LC25(%rip), %xmm0
	movapd	%xmm0, %xmm2
	movl	$1, %edi
	movl	$3, %eax
	subsd	%xmm1, %xmm2
	andpd	.LC72(%rip), %xmm2
	divsd	%xmm1, %xmm2
	mulsd	.LC44(%rip), %xmm2
	call	__printf_chk@PLT
	cmpq	%r12, %rbx
	jne	.L117
	movq	200(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L121
	addq	$208, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L121:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE59:
	.size	generic_accuracy_test, .-generic_accuracy_test
	.section	.rodata.str1.8
	.align 8
.LC74:
	.string	"\360\237\214\215 GEOFENCING GEN\303\211RICO - SIN OPTIMIZACIONES"
	.align 8
.LC75:
	.string	"==========================================="
	.align 8
.LC76:
	.string	"\360\237\223\212 Versi\303\263n que funciona para cualquier ubicaci\303\263n mundial"
	.align 8
.LC77:
	.string	"\360\237\224\247 Con todas las verificaciones y validaciones de seguridad\n"
	.section	.rodata.str1.1
.LC78:
	.string	"\n\360\237\223\213 CARACTER\303\215STICAS:"
	.section	.rodata.str1.8
	.align 8
.LC79:
	.string	"- Verificaciones completas de rangos GPS"
	.section	.rodata.str1.1
.LC80:
	.string	"- Manejo robusto de errores"
	.section	.rodata.str1.8
	.align 8
.LC81:
	.string	"- F\303\263rmula Haversine precisa para cualquier distancia"
	.align 8
.LC82:
	.string	"- Tipos de datos gen\303\251ricos (double para todo)"
	.align 8
.LC83:
	.string	"- Funciona desde el Polo Norte hasta el Polo Sur"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB60:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC74(%rip), %rdi
	call	puts@PLT
	leaq	.LC75(%rip), %rdi
	call	puts@PLT
	leaq	.LC76(%rip), %rdi
	call	puts@PLT
	leaq	.LC77(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	call	generic_benchmark
	xorl	%eax, %eax
	call	generic_memory_usage
	xorl	%eax, %eax
	call	generic_accuracy_test
	leaq	.LC78(%rip), %rdi
	call	puts@PLT
	leaq	.LC79(%rip), %rdi
	call	puts@PLT
	leaq	.LC80(%rip), %rdi
	call	puts@PLT
	leaq	.LC81(%rip), %rdi
	call	puts@PLT
	leaq	.LC82(%rip), %rdi
	call	puts@PLT
	leaq	.LC83(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE60:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC0:
	.long	0
	.long	-1068072960
	.align 8
.LC1:
	.long	0
	.long	1079410688
	.align 8
.LC3:
	.long	0
	.long	-1067024384
	.align 8
.LC4:
	.long	0
	.long	1080459264
	.align 8
.LC8:
	.long	0
	.long	1078525952
	.align 8
.LC10:
	.long	0
	.long	-1074790400
	.align 8
.LC11:
	.long	1413754136
	.long	1074340347
	.align 8
.LC12:
	.long	0
	.long	1071644672
	.align 8
.LC13:
	.long	0
	.long	1072693248
	.align 8
.LC14:
	.long	0
	.long	1096306094
	.align 8
.LC15:
	.long	1165009879
	.long	1098062840
	.align 8
.LC21:
	.long	0
	.long	1073741824
	.align 8
.LC22:
	.long	0
	.long	1075052544
	.align 8
.LC23:
	.long	0
	.long	1076101120
	.align 8
.LC25:
	.long	0
	.long	1083129856
	.align 8
.LC33:
	.long	3592214439
	.long	-1070569206
	.align 8
.LC34:
	.long	3776767466
	.long	-1068374311
	.align 8
.LC35:
	.long	0
	.long	1084380160
	.align 8
.LC36:
	.long	0
	.long	1076756480
	.align 8
.LC37:
	.long	0
	.long	1073217536
	.align 8
.LC38:
	.long	3016785029
	.long	1078211929
	.align 8
.LC39:
	.long	3841418750
	.long	-1072848543
	.align 8
.LC40:
	.long	0
	.long	1082413056
	.align 8
.LC41:
	.long	0
	.long	1074266112
	.align 8
.LC42:
	.long	0
	.long	-1068089344
	.align 8
.LC43:
	.long	0
	.long	1080451072
	.align 8
.LC44:
	.long	0
	.long	1079574528
	.align 8
.LC45:
	.long	3406561901
	.long	-1070572641
	.align 8
.LC46:
	.long	1992040192
	.long	-1068374935
	.align 8
.LC47:
	.long	0
	.long	1093567616
	.align 8
.LC49:
	.long	0
	.long	1092119040
	.align 8
.LC52:
	.long	0
	.long	1088653312
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC54:
	.quad	4710606272623174979
	.quad	27426670985176434
	.section	.rodata.cst8
	.align 8
.LC62:
	.long	3474236841
	.long	-1070576076
	.align 8
.LC63:
	.long	158054796
	.long	-1068375559
	.align 8
.LC64:
	.long	858993459
	.long	1076376371
	.align 8
.LC66:
	.long	0
	.long	1086409792
	.align 8
.LC68:
	.long	3779571220
	.long	1079759994
	.align 8
.LC70:
	.long	3264175145
	.long	1087605701
	.section	.rodata.cst16
	.align 16
.LC72:
	.long	4294967295
	.long	2147483647
	.long	0
	.long	0
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
