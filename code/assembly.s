.section .text
.globl _start

_start:
    # R-Type Instructions
    add x1, x2, x3
    sub x2, x3, x4
    xor x3, x4, x5
    or x4, x5, x6
    and x5, x6, x7
    sll x6, x7, x8
    srl x7, x8, x9
    sra x8, x9, x10
    slt x9, x10, x11
    sltu x10, x11, x12

    # # float
    # flw f4, 0(x1)
    # fsw f1, 16(x2)

    # fmadd.s f3, f0, f1, f2  
    # fmsub.s f4, f1, f2, f3  
    # fnmadd.s f5, f4, f5, f6 
    # fnmsub.s f6, f7, f8, f9 

    # fadd.s f7, f10, f11  
    # fsub.s f8, f12, f13  
    # fmul.s f9, f14, f15  
    # fdiv.s f10, f16, f17 
    # fsqrt.s f11, f18   

    # fsgnj.s f12, f19, f20
    # fsgnjn.s f13, f0, f1 
    # fsgnjx.s f14, f1, f2    
    # fmin.s f15, f2, f3 
    # fmax.s f16, f4, f5 

    # fcvt.s.w f17, x1  
    # fcvt.s.wu f18, x1
    # fcvt.w.s x2, f0   
    # fcvt.wu.s x3, f0  

    # fmv.x.w x4, f0  
    # fmv.w.x f19, x5 

    # feq.s x6, f4, f5 
    # flt.s x7, f5, f6 
    # fle.s x8, f6, f7 

    # fclass.s x9, f9        

    # # mul
    # mul x1, x2, x3
    # mulh x5, x6, x7
    # # mulsu x3, x4, x5
    # # mulu x4, x6, x9
    # div x8, x9, x11
    # divu x5, x6, x7
    # rem x1, x2, x3
    # remu x5, x6, x7

    # I-Type Instructions
    addi x1, x2, 3
    xori x2, x3, 4
    ori x3, x4, 5
    andi x4, x5, 6
    slli x5, x6, 7
    srli x6, x7, 8
    srai x7, x8, 9
    slti x8, x9, 10
    sltiu x9, x10, 11

    # Load Instructions
    lb x1, 0(x0)
    lh x2, 4(x0)
    lw x3, 8(x0)
    lbu x4, 12(x0)
    lhu x5, 16(x0)

    # Additional Instructions
    addi x1, x0, 0x123
    slli x2, x1, 12
    add x3, x2, x1
    slli x4, x3, 8
    addi x5, x4, 0x45

    # Store Instructions
    sb x5, 0(x0)
    lb x6, 0(x0)
    sh x5, 4(x0)
    lh x7, 4(x0)
    sw x5, 8(x0)
    lw x8, 8(x0)

    # atomic
    # lr.w x1, (x2)
    # sc.w x3, x4, (x2)
    # amoswap.w x1, x3, (x2)
    # amoadd.w x3, x4, (x3)
    # amoand.w x4, x5, (x4)
    # amoor.w x5, x6, (x5)
    # amoxor.w x6, x7, (x6)
    # amomax.w x7, x8, (x7)
    # amomin.w x8, x9, (x8)

    # Branch Instructions
    beq x1, x2, 12
    bne x1, x2, 16
    blt x1, x2, 20
    bge x1, x2, 24
    bltu x1, x2, 28
    bgeu x1, x2, 32

    # Jump Instructions
    jal x3, 12
    jalr x4, x2, 16

    # U-Type Instructions
    lui x5, 1234
    auipc x5, 1234


