.syntax unified
.cpu cortex-m4
.thumb

.word 0x20000400
.word start + 1
.space 0xe4

.text

.macro encrypt messageAddr, keyAddr, outputAddr, length
    ldr r0, =\messageAddr
    ldr r1, =\keyAddr
    ldrb r3, [r1]

    ldr r7, =\outputAddr

    mov r4, #\length

loop\@:
    cmp r4, #0
    beq stop\@

    ldrb r5, [r0], #1
    eor r9, r5, r3
    strb r9, [r7], #1

    sub r4, r4, #1
    b loop\@

stop\@:
.endm

start:
    encrypt message, key, encryptedMessage, 4

stop:
    b stop

.data

message: .ascii "AMER" @ Each ASCII character occupies 1 byte
encryptedMessage: .space 4 @ Reserve 4 bytes for the encrypted output, it should match the size of the input message
key: .word 34534234 @ 32-bit key (4 bytes), matching the message size
