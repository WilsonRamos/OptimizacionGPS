	.file	"geofencing_optimized.c"
	.text
	.p2align 4
	.globl	optimized_processGeofencing
	.type	optimized_processGeofencing, @function
optimized_processGeofencing:
.LFB57:
	.cfi_startproc
	endbr64
	movzbl	11(%rdi), %eax
	movss	12(%rdi), %xmm0
	cmpb	$7, %al
	jbe	.L2
	movss	.LC0(%rip), %xmm1
	comiss	%xmm0, %xmm1
	jnb	.L3
.L4:
	movss	.LC1(%rip), %xmm1
	comiss	%xmm0, %xmm1
	jnb	.L3
.L6:
	movss	.LC2(%rip), %xmm1
	movl	$-2, %r8d
	comiss	%xmm0, %xmm1
	jb	.L1
.L3:
	movss	.LC3(%rip), %xmm2
	movss	(%rdi), %xmm4
	movss	.LC4(%rip), %xmm3
	movss	4(%rdi), %xmm5
	mulss	%xmm2, %xmm4
	movzbl	10(%rdi), %ecx
	mulss	%xmm3, %xmm5
	testl	%edx, %edx
	jle	.L14
	xorl	%r8d, %r8d
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L18:
	addl	$1, %r8d
	addq	$42, %rsi
	cmpl	%r8d, %edx
	je	.L14
.L10:
	movss	(%rsi), %xmm0
	movss	4(%rsi), %xmm1
	movaps	%xmm4, %xmm6
	movaps	%xmm5, %xmm7
	movzwl	8(%rsi), %eax
	mulss	%xmm2, %xmm0
	mulss	%xmm3, %xmm1
	imull	%eax, %eax
	subss	%xmm0, %xmm6
	subss	%xmm1, %xmm7
	movaps	%xmm6, %xmm0
	mulss	%xmm6, %xmm0
	movaps	%xmm7, %xmm1
	mulss	%xmm7, %xmm1
	addss	%xmm1, %xmm0
	pxor	%xmm1, %xmm1
	cvtsi2ssl	%eax, %xmm1
	comiss	%xmm0, %xmm1
	jb	.L18
	leal	100(%r8), %eax
	cmpb	$5, %cl
	cmova	%eax, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2:
	cmpb	$5, %al
	ja	.L4
	movl	$-2, %r8d
	cmpb	$3, %al
	ja	.L6
.L1:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L14:
	movl	$-3, %r8d
	movl	%r8d, %eax
	ret
	.cfi_endproc
.LFE57:
	.size	optimized_processGeofencing, .-optimized_processGeofencing
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC5:
	.string	"\342\232\241 BENCHMARK OPTIMIZADO - Simulando CoSense"
	.align 8
.LC6:
	.string	"==========================================="
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC11:
	.string	"Tiempo total: %.4f segundos\n"
	.section	.rodata.str1.8
	.align 8
.LC13:
	.string	"Operaciones por segundo: %.0f\n"
	.align 8
.LC14:
	.string	"Tiempo por operaci\303\263n: %.2f \316\274s\n"
	.section	.rodata.str1.1
.LC15:
	.string	"Ultra-r\303\241pido: %.0f ops/seg\n"
	.section	.rodata.str1.8
	.align 8
.LC17:
	.string	"Geofencing optimizado: %.0f ops/seg\n"
	.text
	.p2align 4
	.globl	optimized_benchmark
	.type	optimized_benchmark, @function
optimized_benchmark:
.LFB58:
	.cfi_startproc
	endbr64
	pushq	%r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	leaq	.LC5(%rip), %rdi
	pushq	%r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	pushq	%r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	movl	$100000, %r12d
	pushq	%rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	subq	$96, %rsp
	.cfi_def_cfa_offset 144
	movq	%fs:40, %rax
	movq	%rax, 88(%rsp)
	xorl	%eax, %eax
	leaq	16(%rsp), %r13
	leaq	64(%rsp), %rbp
	call	puts@PLT
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	movabsq	$-4427302553767480922, %rax
	movq	%rax, 32(%rsp)
	movabsq	$-4427281096110842626, %rax
	movq	%rax, 48(%rsp)
	movabsq	$-4427286129812501955, %rax
	movq	%rax, 64(%rsp)
	call	clock@PLT
	movss	.LC7(%rip), %xmm5
	movss	.LC3(%rip), %xmm4
	movss	.LC8(%rip), %xmm3
	movq	%rax, %r14
	.p2align 4,,10
	.p2align 3
.L20:
	movq	%r13, %rbx
	movss	.LC4(%rip), %xmm2
	cmpq	%rbp, %rbx
	je	.L28
.L22:
	movaps	%xmm5, %xmm0
	movaps	%xmm3, %xmm1
	subss	16(%rbx), %xmm0
	subss	20(%rbx), %xmm1
	mulss	%xmm4, %xmm0
	mulss	%xmm2, %xmm1
	mulss	%xmm0, %xmm0
	mulss	%xmm1, %xmm1
	addss	%xmm1, %xmm0
	pxor	%xmm1, %xmm1
	ucomiss	%xmm0, %xmm1
	ja	.L29
.L21:
	addq	$16, %rbx
	cmpq	%rbp, %rbx
	jne	.L22
.L28:
	subl	$1, %r12d
	jne	.L20
	call	clock@PLT
	pxor	%xmm1, %xmm1
	movl	$1, %edi
	leaq	.LC11(%rip), %rsi
	subq	%r14, %rax
	cvtsi2sdq	%rax, %xmm1
	movl	$1, %eax
	divsd	.LC10(%rip), %xmm1
	movapd	%xmm1, %xmm0
	movsd	%xmm1, 8(%rsp)
	call	__printf_chk@PLT
	movsd	8(%rsp), %xmm1
	movl	$1, %edi
	movsd	.LC12(%rip), %xmm0
	leaq	.LC13(%rip), %rsi
	movl	$1, %eax
	divsd	%xmm1, %xmm0
	call	__printf_chk@PLT
	movsd	8(%rsp), %xmm1
	movl	$1, %edi
	movsd	.LC10(%rip), %xmm0
	leaq	.LC14(%rip), %rsi
	movl	$1, %eax
	mulsd	%xmm1, %xmm0
	divsd	.LC12(%rip), %xmm0
	call	__printf_chk@PLT
	call	clock@PLT
	movq	%rax, %rbx
	call	clock@PLT
	pxor	%xmm0, %xmm0
	movl	$1, %edi
	movsd	.LC12(%rip), %xmm6
	subq	%rbx, %rax
	leaq	.LC15(%rip), %rsi
	cvtsi2sdq	%rax, %xmm0
	divsd	.LC10(%rip), %xmm0
	divsd	%xmm0, %xmm6
	movl	$1, %eax
	movapd	%xmm6, %xmm0
	call	__printf_chk@PLT
	call	clock@PLT
	movq	%rax, %rbx
	call	clock@PLT
	movq	88(%rsp), %rdx
	xorq	%fs:40, %rdx
	jne	.L30
	movsd	.LC16(%rip), %xmm1
	subq	%rbx, %rax
	pxor	%xmm0, %xmm0
	leaq	.LC17(%rip), %rsi
	cvtsi2sdq	%rax, %xmm0
	movl	$1, %edi
	movl	$1, %eax
	divsd	.LC10(%rip), %xmm0
	divsd	%xmm0, %xmm1
	addq	$96, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%rbp
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	movapd	%xmm1, %xmm0
	jmp	__printf_chk@PLT
.L29:
	.cfi_restore_state
	call	sqrtf@PLT
	movss	.LC4(%rip), %xmm2
	movss	.LC8(%rip), %xmm3
	movss	.LC3(%rip), %xmm4
	movss	.LC7(%rip), %xmm5
	jmp	.L21
.L30:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE58:
	.size	optimized_benchmark, .-optimized_benchmark
	.section	.rodata.str1.8
	.align 8
.LC18:
	.string	"\n\360\237\232\200 USO DE MEMORIA OPTIMIZADO"
	.section	.rodata.str1.1
.LC19:
	.string	"============================"
	.section	.rodata.str1.8
	.align 8
.LC20:
	.string	"Tama\303\261o OptimizedGPSPoint: %zu bytes\n"
	.align 8
.LC21:
	.string	"Tama\303\261o OptimizedGeofence: %zu bytes\n"
	.align 8
.LC22:
	.string	"Total por punto + geocerca: %zu bytes\n"
	.section	.rodata.str1.1
.LC23:
	.string	"\nArray de %d elementos:\n"
.LC25:
	.string	"OptimizedGPSPoint[]: %.1f KB\n"
.LC27:
	.string	"OptimizedGeofence[]: %.1f KB\n"
	.text
	.p2align 4
	.globl	optimized_memory_usage
	.type	optimized_memory_usage, @function
optimized_memory_usage:
.LFB59:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC18(%rip), %rdi
	call	puts@PLT
	leaq	.LC19(%rip), %rdi
	call	puts@PLT
	movl	$16, %edx
	leaq	.LC20(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$42, %edx
	leaq	.LC21(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$58, %edx
	leaq	.LC22(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$1000, %edx
	leaq	.LC23(%rip), %rsi
	xorl	%eax, %eax
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$1, %edi
	movl	$1, %eax
	movsd	.LC24(%rip), %xmm0
	leaq	.LC25(%rip), %rsi
	call	__printf_chk@PLT
	movl	$1, %edi
	movl	$1, %eax
	movsd	.LC26(%rip), %xmm0
	leaq	.LC27(%rip), %rsi
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	jmp	__printf_chk@PLT
	.cfi_endproc
.LFE59:
	.size	optimized_memory_usage, .-optimized_memory_usage
	.section	.rodata.str1.1
.LC28:
	.string	"Extremos Arequipa"
	.section	.rodata.str1.8
	.align 8
.LC30:
	.string	"\n\360\237\216\257 PRUEBA DE PRECISI\303\223N OPTIMIZADA"
	.align 8
.LC31:
	.string	"================================="
	.section	.rodata.str1.1
.LC34:
	.string	"Centro a punto cercano"
.LC35:
	.string	"Diagonal completa"
.LC37:
	.string	"Distancia media"
	.section	.rodata.str1.8
	.align 8
.LC40:
	.string	"%s: %.1f m (esperado: %.1f m, error: %.2f%%)\n"
	.text
	.p2align 4
	.globl	optimized_accuracy_test
	.type	optimized_accuracy_test, @function
optimized_accuracy_test:
.LFB60:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	leaq	.LC30(%rip), %rdi
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$168, %rsp
	.cfi_def_cfa_offset 192
	movq	%fs:40, %rax
	movq	%rax, 152(%rsp)
	xorl	%eax, %eax
	leaq	16(%rsp), %rbx
	leaq	112(%rsp), %rbp
	call	puts@PLT
	leaq	.LC31(%rip), %rdi
	call	puts@PLT
	movss	.LC32(%rip), %xmm0
	movabsq	$-4427281096110842626, %rax
	movl	$0x43900000, 64(%rsp)
	movq	%rax, 48(%rsp)
	movss	.LC29(%rip), %xmm3
	movabsq	$-4427280499110387384, %rax
	leaq	.LC28(%rip), %rdx
	movq	%rax, 56(%rsp)
	leaq	.LC34(%rip), %rax
	movq	%rax, 72(%rsp)
	movabsq	$-4427259642749171625, %rax
	movq	%rax, 80(%rsp)
	movabsq	$-4427302553767480922, %rax
	movq	%rax, 88(%rsp)
	leaq	.LC35(%rip), %rax
	movq	%rax, 104(%rsp)
	movabsq	$-4427286129812501955, %rax
	movq	%rax, 112(%rsp)
	movabsq	$-4427280499110382141, %rax
	movq	%rax, 120(%rsp)
	leaq	.LC37(%rip), %rax
	movl	$0x44be0000, 128(%rsp)
	movq	%rax, 136(%rsp)
	movss	%xmm0, 32(%rsp)
	movss	%xmm0, 96(%rsp)
.L34:
	movss	16(%rbx), %xmm1
	movaps	%xmm3, %xmm2
	pxor	%xmm0, %xmm0
	leaq	.LC40(%rip), %rsi
	movl	$1, %edi
	movl	$3, %eax
	cvtss2sd	%xmm3, %xmm0
	subss	%xmm1, %xmm2
	andps	.LC38(%rip), %xmm2
	divss	%xmm1, %xmm2
	cvtss2sd	%xmm1, %xmm1
	mulss	.LC39(%rip), %xmm2
	cvtss2sd	%xmm2, %xmm2
	call	__printf_chk@PLT
	cmpq	%rbp, %rbx
	je	.L39
	movss	40(%rbx), %xmm0
	movss	44(%rbx), %xmm1
	pxor	%xmm4, %xmm4
	subss	32(%rbx), %xmm0
	subss	36(%rbx), %xmm1
	mulss	.LC3(%rip), %xmm0
	mulss	.LC4(%rip), %xmm1
	mulss	%xmm0, %xmm0
	mulss	%xmm1, %xmm1
	addss	%xmm1, %xmm0
	ucomiss	%xmm0, %xmm4
	movaps	%xmm0, %xmm3
	sqrtss	%xmm3, %xmm3
	ja	.L40
.L35:
	movq	56(%rbx), %rdx
	addq	$32, %rbx
	jmp	.L34
	.p2align 4,,10
	.p2align 3
.L39:
	movq	152(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L41
	addq	$168, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L40:
	.cfi_restore_state
	movss	%xmm3, 12(%rsp)
	call	sqrtf@PLT
	movss	12(%rsp), %xmm3
	jmp	.L35
.L41:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE60:
	.size	optimized_accuracy_test, .-optimized_accuracy_test
	.section	.rodata.str1.8
	.align 8
.LC41:
	.string	"\n\342\232\231\357\270\217  OPTIMIZACIONES APLICADAS (simulando CoSense)"
	.align 8
.LC42:
	.string	"==============================================="
	.align 8
.LC43:
	.string	"1. \342\234\205 Eliminaci\303\263n de verificaciones de rango GPS"
	.align 8
.LC44:
	.string	"   - Sin validaci\303\263n lat \342\210\210 [-90,90] (conocido: [-16.41,-16.31])"
	.align 8
.LC45:
	.string	"   - Sin validaci\303\263n lon \342\210\210 [-180,180] (conocido: [-71.61,-71.53])"
	.align 8
.LC46:
	.string	"\n2. \342\234\205 Compresi\303\263n de tipos de datos"
	.align 8
.LC47:
	.string	"   - float en lugar de double (precisi\303\263n suficiente)"
	.align 8
.LC48:
	.string	"   - unsigned short para altitud (rango [2330,5357])"
	.align 8
.LC49:
	.string	"   - unsigned char para velocidad (rango [0,210])"
	.align 8
.LC50:
	.string	"\n3. \342\234\205 Aproximaci\303\263n matem\303\241tica para distancias cortas"
	.align 8
.LC51:
	.string	"   - Euclidiana en lugar de Haversine (error <0.05%% en 11km)\n"
	.align 8
.LC52:
	.string	"   - Constantes precomputadas para latitud de Arequipa"
	.align 8
.LC53:
	.string	"\n4. \342\234\205 Eliminaci\303\263n de verificaciones NULL y errores"
	.align 8
.LC54:
	.string	"   - Sin chequeos de punteros (conocidos como v\303\241lidos)"
	.align 8
.LC55:
	.string	"   - Sin manejo de casos extremos (rango controlado)"
	.align 8
.LC56:
	.string	"\n5. \342\234\205 Estructuras empaquetadas y optimizadas"
	.align 8
.LC57:
	.string	"   - __attribute__((packed)) para reducir padding"
	.align 8
.LC58:
	.string	"   - Campos m\303\241s cortos donde sea posible"
	.text
	.p2align 4
	.globl	show_optimizations
	.type	show_optimizations, @function
show_optimizations:
.LFB61:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC41(%rip), %rdi
	call	puts@PLT
	leaq	.LC42(%rip), %rdi
	call	puts@PLT
	leaq	.LC43(%rip), %rdi
	call	puts@PLT
	leaq	.LC44(%rip), %rdi
	call	puts@PLT
	leaq	.LC45(%rip), %rdi
	call	puts@PLT
	leaq	.LC46(%rip), %rdi
	call	puts@PLT
	leaq	.LC47(%rip), %rdi
	call	puts@PLT
	leaq	.LC48(%rip), %rdi
	call	puts@PLT
	leaq	.LC49(%rip), %rdi
	call	puts@PLT
	leaq	.LC50(%rip), %rdi
	call	puts@PLT
	leaq	.LC51(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	leaq	.LC52(%rip), %rdi
	call	puts@PLT
	leaq	.LC53(%rip), %rdi
	call	puts@PLT
	leaq	.LC54(%rip), %rdi
	call	puts@PLT
	leaq	.LC55(%rip), %rdi
	call	puts@PLT
	leaq	.LC56(%rip), %rdi
	call	puts@PLT
	leaq	.LC57(%rip), %rdi
	call	puts@PLT
	leaq	.LC58(%rip), %rdi
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	jmp	puts@PLT
	.cfi_endproc
.LFE61:
	.size	show_optimizations, .-show_optimizations
	.section	.rodata.str1.8
	.align 8
.LC59:
	.string	"\342\232\241 GEOFENCING OPTIMIZADO - SIMULANDO COSENSE"
	.align 8
.LC60:
	.string	"\360\237\223\212 Versi\303\263n optimizada usando especificaciones Newton DSL"
	.align 8
.LC61:
	.string	"\360\237\216\257 Rangos espec\303\255ficos: Per\303\272 (Arequipa) - 11km x 7km"
	.align 8
.LC62:
	.string	"\360\237\232\200 Simulando optimizaciones autom\303\241ticas de CoSense\n"
	.align 8
.LC63:
	.string	"\n\360\237\223\210 RESULTADOS ESPERADOS vs Versi\303\263n Gen\303\251rica:"
	.align 8
.LC64:
	.string	"- Velocidad: 3-10x m\303\241s r\303\241pido"
	.section	.rodata.str1.1
.LC65:
	.string	"- Memoria: 50-75%% menos uso\n"
	.section	.rodata.str1.8
	.align 8
.LC66:
	.string	"- Precisi\303\263n: Mantenida para aplicaci\303\263n local"
	.align 8
.LC67:
	.string	"- C\303\263digo: M\303\241s simple y directo"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB62:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	.LC59(%rip), %rdi
	call	puts@PLT
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	leaq	.LC60(%rip), %rdi
	call	puts@PLT
	leaq	.LC61(%rip), %rdi
	call	puts@PLT
	leaq	.LC62(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	call	optimized_benchmark
	xorl	%eax, %eax
	call	optimized_memory_usage
	xorl	%eax, %eax
	call	optimized_accuracy_test
	xorl	%eax, %eax
	call	show_optimizations
	leaq	.LC63(%rip), %rdi
	call	puts@PLT
	leaq	.LC64(%rip), %rdi
	call	puts@PLT
	leaq	.LC65(%rip), %rsi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk@PLT
	leaq	.LC66(%rip), %rdi
	call	puts@PLT
	leaq	.LC67(%rip), %rdi
	call	puts@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE62:
	.size	main, .-main
	.section	.rodata.cst4,"aM",@progbits,4
	.align 4
.LC0:
	.long	1065353216
	.align 4
.LC1:
	.long	1069547520
	.align 4
.LC2:
	.long	1073741824
	.align 4
.LC3:
	.long	1205431296
	.align 4
.LC4:
	.long	1204832474
	.align 4
.LC7:
	.long	3246578942
	.align 4
.LC8:
	.long	3264160588
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC10:
	.long	0
	.long	1093567616
	.align 8
.LC12:
	.long	0
	.long	1092119040
	.align 8
.LC16:
	.long	0
	.long	1088653312
	.align 8
.LC24:
	.long	0
	.long	1076838400
	.align 8
.LC26:
	.long	0
	.long	1078231552
	.section	.rodata.cst4
	.align 4
.LC29:
	.long	1180579581
	.align 4
.LC32:
	.long	1178406912
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC38:
	.long	2147483647
	.long	0
	.long	0
	.long	0
	.section	.rodata.cst4
	.align 4
.LC39:
	.long	1120403456
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
