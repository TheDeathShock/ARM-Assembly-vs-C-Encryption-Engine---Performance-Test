.syntax unified
.cpu cortex-m4
.thumb

.word 0x20000400
.word start + 1
.space 0xe4

.text

.macro decrypt encryptedAddr, keyAddr, outputAddr, length
    ldr r0, =\encryptedAddr
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
    decrypt encryptedMessage, key, decryptedMessage, 4

stop:
    b stop

.data

encryptedMessage: .space 4 @Replace ".space 4" with the actual encrypted message that you want to decrypt
decryptedMessage: .space 4 @You should reserve the same size as the size of the encryptedMessage
key: .word 34534234 @The size of the encryption key should be the one as the message