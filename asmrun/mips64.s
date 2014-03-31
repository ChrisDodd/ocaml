/***********************************************************************/
/*                                                                     */
/*                                OCaml                                */
/*                                                                     */
/*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         */
/*                                                                     */
/*  Copyright 1996 Institut National de Recherche en Informatique et   */
/*  en Automatique.  All rights reserved.  This file is distributed    */
/*  under the terms of the GNU Library General Public License, with    */
/*  the special exception on linking described in file ../LICENSE.     */
/*                                                                     */
/***********************************************************************/

/* $Id$ */

/* Asm part of the runtime system, Mips processor, IRIX n32 conventions */

/* Allocation */

        .text

        .globl  caml_call_gc
        .ent    caml_call_gc

caml_call_gc:
    /* Reserve stack space for registers and saved $gp */
    /* 32 * 8 = 0x100 for float regs
       22 * 8 = 0xb0  for integer regs
            8 = 0x8   for saved $gp ====> 0x1b8 total */
        dsubu   $sp, $sp, 0x1b8
    /* Reinit $gp */
        .cpsetup $25, 0x1b0, caml_call_gc
    /* Record return address */
        sd      $31, caml_last_return_address
    /* Record lowest stack address */
        daddu   $24, $sp, 0x1b8
        sd      $24, caml_bottom_of_stack
    /* Save pointer to register array */
        daddu   $24, $sp, 0x100
        sd      $24, caml_gc_regs
    /* Save current allocation pointer for debugging purposes */
        sd      $22, caml_young_ptr
    /* Save the exception handler (if e.g. a sighandler raises) */
        sd      $30, caml_exception_pointer
    /* Save all regs used by the code generator on the stack */
        sd      $2, 2 * 8($24)
        sd      $3, 3 * 8($24)
        sd      $4, 4 * 8($24)
        sd      $5, 5 * 8($24)
        sd      $6, 6 * 8($24)
        sd      $7, 7 * 8($24)
        sd      $8, 8 * 8($24)
        sd      $9, 9 * 8($24)
        sd      $10, 10 * 8($24)
        sd      $11, 11 * 8($24)
        sd      $12, 12 * 8($24)
        sd      $13, 13 * 8($24)
        sd      $14, 14 * 8($24)
        sd      $15, 15 * 8($24)
        sd      $16, 16 * 8($24)
        sd      $17, 17 * 8($24)
        sd      $18, 18 * 8($24)
        sd      $19, 19 * 8($24)
        sd      $20, 20 * 8($24)
        sd      $21, 21 * 8($24)
        s.d     $f0, 0 * 8($sp)
        s.d     $f1, 1 * 8($sp)
        s.d     $f2, 2 * 8($sp)
        s.d     $f3, 3 * 8($sp)
        s.d     $f4, 4 * 8($sp)
        s.d     $f5, 5 * 8($sp)
        s.d     $f6, 6 * 8($sp)
        s.d     $f7, 7 * 8($sp)
        s.d     $f8, 8 * 8($sp)
        s.d     $f9, 9 * 8($sp)
        s.d     $f10, 10 * 8($sp)
        s.d     $f11, 11 * 8($sp)
        s.d     $f12, 12 * 8($sp)
        s.d     $f13, 13 * 8($sp)
        s.d     $f14, 14 * 8($sp)
        s.d     $f15, 15 * 8($sp)
        s.d     $f16, 16 * 8($sp)
        s.d     $f17, 17 * 8($sp)
        s.d     $f18, 18 * 8($sp)
        s.d     $f19, 19 * 8($sp)
        s.d     $f20, 20 * 8($sp)
        s.d     $f21, 21 * 8($sp)
        s.d     $f22, 22 * 8($sp)
        s.d     $f23, 23 * 8($sp)
        s.d     $f24, 24 * 8($sp)
        s.d     $f25, 25 * 8($sp)
        s.d     $f26, 26 * 8($sp)
        s.d     $f27, 27 * 8($sp)
        s.d     $f28, 28 * 8($sp)
        s.d     $f29, 29 * 8($sp)
        s.d     $f30, 30 * 8($sp)
        s.d     $f31, 31 * 8($sp)
    /* Call the garbage collector */
        jal     caml_garbage_collection
    /* Restore all regs used by the code generator */
        daddu   $24, $sp, 0x100
        ld      $2, 2 * 8($24)
        ld      $3, 3 * 8($24)
        ld      $4, 4 * 8($24)
        ld      $5, 5 * 8($24)
        ld      $6, 6 * 8($24)
        ld      $7, 7 * 8($24)
        ld      $8, 8 * 8($24)
        ld      $9, 9 * 8($24)
        ld      $10, 10 * 8($24)
        ld      $11, 11 * 8($24)
        ld      $12, 12 * 8($24)
        ld      $13, 13 * 8($24)
        ld      $14, 14 * 8($24)
        ld      $15, 15 * 8($24)
        ld      $16, 16 * 8($24)
        ld      $17, 17 * 8($24)
        ld      $18, 18 * 8($24)
        ld      $19, 19 * 8($24)
        ld      $20, 20 * 8($24)
        ld      $21, 21 * 8($24)
        l.d     $f0, 0 * 8($sp)
        l.d     $f1, 1 * 8($sp)
        l.d     $f2, 2 * 8($sp)
        l.d     $f3, 3 * 8($sp)
        l.d     $f4, 4 * 8($sp)
        l.d     $f5, 5 * 8($sp)
        l.d     $f6, 6 * 8($sp)
        l.d     $f7, 7 * 8($sp)
        l.d     $f8, 8 * 8($sp)
        l.d     $f9, 9 * 8($sp)
        l.d     $f10, 10 * 8($sp)
        l.d     $f11, 11 * 8($sp)
        l.d     $f12, 12 * 8($sp)
        l.d     $f13, 13 * 8($sp)
        l.d     $f14, 14 * 8($sp)
        l.d     $f15, 15 * 8($sp)
        l.d     $f16, 16 * 8($sp)
        l.d     $f17, 17 * 8($sp)
        l.d     $f18, 18 * 8($sp)
        l.d     $f19, 19 * 8($sp)
        l.d     $f20, 20 * 8($sp)
        l.d     $f21, 21 * 8($sp)
        l.d     $f22, 22 * 8($sp)
        l.d     $f23, 23 * 8($sp)
        l.d     $f24, 24 * 8($sp)
        l.d     $f25, 25 * 8($sp)
        l.d     $f26, 26 * 8($sp)
        l.d     $f27, 27 * 8($sp)
        l.d     $f28, 28 * 8($sp)
        l.d     $f29, 29 * 8($sp)
        l.d     $f30, 30 * 8($sp)
        l.d     $f31, 31 * 8($sp)
    /* Reload new allocation pointer and allocation limit */
        ld      $22, caml_young_ptr
        ld      $23, caml_young_limit
    /* Reload return address */
        ld      $31, caml_last_return_address
    /* Say that we are back into Caml code */
        sd      $0, caml_last_return_address
    /* Adjust return address to restart the allocation sequence */
    /* DANGER -- needs to match up with mips64/emit.mlp code */
        dsubu   $31, $31, 24
    /* Return */
        .cpreturn
        daddu   $sp, $sp, 0x1b8
        j       $31

        .end    caml_call_gc

/* Call a C function from Caml */

        .globl  caml_c_call
        .ent    caml_c_call

caml_c_call:
    /* Function to call is in $24 */
    /* Set up $gp, saving caller's $gp in callee-save register $19 */
        .cpsetup $25, $19, caml_c_call
    /* Preload addresses of interesting global variables
       in callee-save registers */
        dla     $16, caml_last_return_address
        dla     $17, caml_young_ptr
    /* Save return address, bottom of stack, alloc ptr, exn ptr */
        sd      $31, 0($16)     /* caml_last_return_address */
        sd      $sp, caml_bottom_of_stack
        sd      $22, 0($17)     /* caml_young_ptr */
        sd      $30, caml_exception_pointer
    /* Call C function */
        move    $25, $24
        jal     $24
    /* Reload return address, alloc ptr, alloc limit */
        ld      $31, 0($16)     /* caml_last_return_address */
        ld      $22, 0($17)     /* caml_young_ptr */
        ld      $23, caml_young_limit /* caml_young_limit */
    /* Zero caml_last_return_address, indicating we're back in Caml code */
        sd      $0, 0($16)      /* caml_last_return_address */
    /* Restore $gp and return */
        move    $gp, $19
        j       $31
        .end    caml_c_call

/* Start the Caml program */

        .globl  caml_start_program
        .globl  stray_exn_handler
        .ent    caml_start_program
caml_start_program:
    /* Reserve space for callee-save registers */
        dsubu   $sp, $sp, 0x90
    /* Setup $gp */
        .cpsetup $25, 0x80, caml_start_program
    /* Load in $24 the code address to call */
        dla     $24, caml_program
    /* Code shared with caml_callback* */
$103:
    /* Save return address */
        sd      $31, 0x88($sp)
    /* Save all callee-save registers */
        sd      $16, 0x0($sp)
        sd      $17, 0x8($sp)
        sd      $18, 0x10($sp)
        sd      $19, 0x18($sp)
        sd      $20, 0x20($sp)
        sd      $21, 0x28($sp)
        sd      $22, 0x30($sp)
        sd      $23, 0x38($sp)
        sd      $30, 0x40($sp)
        s.d     $f20, 0x48($sp)
        s.d     $f22, 0x50($sp)
        s.d     $f24, 0x58($sp)
        s.d     $f26, 0x60($sp)
        s.d     $f28, 0x68($sp)
        s.d     $f30, 0x70($sp)
    /* Set up a callback link on the stack. */
        dsubu   $sp, $sp, 32
        ld      $2, caml_bottom_of_stack
        sd      $2, 0($sp)
        ld      $3, caml_last_return_address
        sd      $3, 8($sp)
        ld      $4, caml_gc_regs
        sd      $4, 16($sp)
    /* Set up a trap frame to catch exceptions escaping the Caml code */
        dsubu   $sp, $sp, 32
        ld      $30, caml_exception_pointer
        sd      $30, 0($sp)
        dla     $2, $105
        sd      $2, 8($sp)
        sd      $gp, 16($sp)
        move    $30, $sp
    /* Reload allocation pointers */
        ld      $22, caml_young_ptr
        ld      $23, caml_young_limit
    /* Say that we are back into Caml code */
        sd      $0, caml_last_return_address
    /* Call the Caml code */
        move    $25, $24
        jal     $24
$104:
    /* Pop the trap frame, restoring caml_exception_pointer */
        ld      $24, 0($sp)
        sd      $24, caml_exception_pointer
        daddu   $sp, $sp, 32
$106:
    /* Pop the callback link, restoring the global variables */
        ld      $24, 0($sp)
        sd      $24, caml_bottom_of_stack
        ld      $25, 8($sp)
        sd      $25, caml_last_return_address
        ld      $24, 16($sp)
        sd      $24, caml_gc_regs
        daddu   $sp, $sp, 32
    /* Update allocation pointer */
        sd      $22, caml_young_ptr
    /* Reload callee-save registers and return */
        ld      $31, 0x88($sp)
        ld      $16, 0x0($sp)
        ld      $17, 0x8($sp)
        ld      $18, 0x10($sp)
        ld      $19, 0x18($sp)
        ld      $20, 0x20($sp)
        ld      $21, 0x28($sp)
        ld      $22, 0x30($sp)
        ld      $23, 0x38($sp)
        ld      $30, 0x40($sp)
        l.d     $f20, 0x48($sp)
        l.d     $f22, 0x50($sp)
        l.d     $f24, 0x58($sp)
        l.d     $f26, 0x60($sp)
        l.d     $f28, 0x68($sp)
        l.d     $f30, 0x70($sp)
        .cpreturn
        daddu   $sp, $sp, 0x90
        j       $31

    /* The trap handler: encode exception bucket as an exception result
       and return it */
$105:
        sd      $30, caml_exception_pointer
        or      $2, $2, 2
        b       $106

        .end    caml_start_program

/* Raise an exception from C */

        .globl  caml_raise_exception
        .ent    caml_raise_exception
caml_raise_exception:
    /* Setup $gp, discarding caller's $gp (we won't return) */
        .cpsetup $25, $24, caml_raise_exception
    /* Branch to exn handler */
        move    $2, $4
        ld      $22, caml_young_ptr
        ld      $23, caml_young_limit
        ld      $sp, caml_exception_pointer
        ld      $30, 0($sp)
        ld      $24, 8($sp)
        ld      $gp, 16($sp)
        daddu   $sp, $sp, 32
        j       $24

        .end    caml_raise_exception

/* Callback from C to Caml */

        .globl  caml_callback_exn
        .ent    caml_callback_exn
caml_callback_exn:
        dsubu   $sp, $sp, 0x90
        .cpsetup $25, 0x80, caml_callback_exn
    /* Initial shuffling of arguments */
        move    $9, $4          /* closure */
        move    $8, $5          /* argument */
        ld      $24, 0($4)      /* code pointer */
        b       $103
        .end    caml_callback_exn

        .globl  caml_callback2_exn
        .ent    caml_callback2_exn
caml_callback2_exn:
        dsubu   $sp, $sp, 0x90
        .cpsetup $25, 0x80, caml_callback2_exn
    /* Initial shuffling of arguments */
        move    $10, $4                 /* closure */
        move    $8, $5                  /* first argument */
        move    $9, $6                  /* second argument */
        dla     $24, caml_apply2        /* code pointer */
        b       $103

        .end    caml_callback2_exn

        .globl  caml_callback3_exn
        .ent    caml_callback3_exn
caml_callback3_exn:
        dsubu   $sp, $sp, 0x90
        .cpsetup $25, 0x80, caml_callback3_exn
    /* Initial shuffling of arguments */
        move    $11, $4                 /* closure */
        move    $8, $5                  /* first argument */
        move    $9, $6                  /* second argument */
        move    $10, $7                 /* third argument */
        dla     $24, caml_apply3        /* code pointer */
        b       $103

        .end    caml_callback3_exn

/* Glue code to call [caml_array_bound_error] */

        .globl  caml_ml_array_bound_error
        .ent    caml_ml_array_bound_error

caml_ml_array_bound_error:
    /* Setup $gp, discarding caller's $gp (we won't return) */
        .cpsetup $25, $24, caml_ml_array_bound_error
        dla     $24, caml_array_bound_error
        jal     caml_c_call             /* never returns */

        .end    caml_ml_array_bound_error

        .rdata
        .globl  caml_system__frametable
caml_system__frametable:
        .quad   1               /* one descriptor */
        .quad   $104            /* return address into callback */
        .half   -1              /* negative frame size => use callback link */
        .half   0               /* no roots here */
