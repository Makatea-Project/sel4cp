/*
 * Copyright 2023, Neutrality.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

.section .text.start
.code32

/*
 * Loader entry point.
 */
	.globl	start
start:
	/* Load a stack. */
	leal	stack_top, %esp

	/* Reset the EFLAGS register. */
	pushl	$0
	popf

	/* Save the %eax and %ebx registers. */
	pushl	%ebx	/* multiboot_info_ptr */
	pushl	%eax	/* multiboot_magic    */

	/* Call the loader C function to tweak the multiboot info structure.
	 * The multiboot args are already on the stack. */
	call	loader
	testl	%eax, %eax
	js	halt

	/* Jump into the seL4 kernel. */
	popl	%eax
	popl	%ebx
	leal	kernel_entry, %ecx
	jmp	*(%ecx)

	/* Here be dragons. */
halt:
	cli
1:
	hlt
	jmp	1b

/*
 * Allocate a small stack for the few things we need to push there.
 */
	.align	16
stack:
	.fill	0x100
stack_top:
