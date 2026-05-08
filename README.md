This is a lightweight XOR-based encryption and decryption engine for an STM32 Cortex-M4 microcontroller using ARM Assembly. The project performs direct memory access to read an input message and encryption key, applies bitwise XOR masking to encrypt each byte, and stores the encrypted output in memory. Implemented reusable assembly macros allowing configurable source, destination, key addresses, and message length parameters for both encryption and decryption operations. Built an equivalent implementation in C to compare execution performance and generated code size against the direct ARM Assembly version.

Warning: This project uses a very basic XOR-based encryption method that is intentionally weak and easily breakable. The purpose of the project is educational and performance-oriented, focusing on comparing low-level ARM Assembly implementation behavior against an equivalent C implementation rather than providing real-world cryptographic security.

Note: Make sure that the input message, output message, and the key have the same size.


## Requirements

Install the ARM GNU toolchain and OpenOCD:

sudo apt update
sudo apt install gcc-arm-none-eabi gdb-multiarch openocd

Or, if your system provides it:

sudo apt install binutils-arm-none-eabi gcc-arm-none-eabi openocd

Check that the tools are installed:

arm-none-eabi-gcc --version
arm-none-eabi-as --version
arm-none-eabi-objdump --version
openocd --version

---

# 1. Building the ARM Assembly Version

## 1.1 Assemble the encryption assembly file

arm-none-eabi-as -mcpu=cortex-m4 -mthumb -g encryptionEngineARM.s -o encryptionEngineARM.o

## 1.2 Link the encryption object file using the linker script

arm-none-eabi-ld -T linkerFile.ld encryptionEngineARM.o -o encryptionEngineARM.elf

## 1.3 Generate a disassembly/listing file (Optional: Just to see the machine code)

arm-none-eabi-objdump -D encryptionEngineARM.elf > encryptionEngineARM.lst

---

## 1.4 Assemble the decryption assembly file

arm-none-eabi-as -mcpu=cortex-m4 -mthumb -g decryptionEngineARM.s -o decryptionEngineARM.o

## 1.5 Link the decryption object file

arm-none-eabi-ld -T linkerFile.ld decryptionEngineARM.o -o decryptionEngineARM.elf

## 1.6 Generate a disassembly/listing file

arm-none-eabi-objdump -D decryptionEngineARM.elf > decryptionEngineARM.lst

---

# 2. Building the C Version

For the C files, use arm-none-eabi-gcc, not arm-none-eabi-as.

## 2.1 Compile the C encryption file

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g -O0 -c encryptionEngineC.c -o encryptionEngineC.o

## 2.2 Link the C encryption object file

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -nostdlib -T linkerFile.ld -Wl,-e,main encryptionEngineC.o -o encryptionEngineC.elf

## 2.3 Generate a disassembly/listing file

arm-none-eabi-objdump -D encryptionEngineC.elf > encryptionEngineC.lst

---

## 2.4 Compile the C decryption file

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g -O0 -c decryptionEngineC.c -o decryptionEngineC.o

## 2.5 Link the C decryption object file

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -nostdlib -T linkerFile.ld -Wl,-e,main decryptionEngineC.o -o decryptionEngineC.elf

## 2.6 Generate a disassembly/listing file

arm-none-eabi-objdump -D decryptionEngineC.elf > decryptionEngineC.lst

---

# 3. Optimization Levels for Fair Comparison

To compare different compiler outputs, you can compile the C version with different optimization levels.

No optimization:

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g -O0 -c encryptionEngineC.c -o encryptionEngineC.o

Size optimization:

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g -Os -c encryptionEngineC.c -o encryptionEngineC.o

Speed optimization:

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g -O2 -c encryptionEngineC.c -o encryptionEngineC.o

The size and execution speed could significantly vary for each of the optimization levels.

---

# 4. Loading the Program onto the STM32

Start OpenOCD in one terminal:

openocd -f board/st_nucleo_f4.cfg (Make sure you put the STM32 model you are using)

In a second terminal, start GDB: (Make sure that the terminal is CDed to the directory that contains the .elf file)

For ARM version:
arm-none-eabi-gdb encryptionEngineARM.elf

Inside GDB:

target extended-remote localhost:3333
monitor reset halt
load
break start
continue

For the C version:

arm-none-eabi-gdb encryptionEngineC.elf

Inside GDB:

target extended-remote localhost:3333
monitor reset halt
load
break main
continue

---

# 5. Measuring Code Size

Use:

arm-none-eabi-size encryptionEngineARM.elf
arm-none-eabi-size encryptionEngineC.elf

Example output:

   text    data     bss     dec     hex filename
    120       8       4     132      84 encryptionEngineARM.elf

Meaning:

text = code size
data = initialized global/static data
bss  = uninitialized global/static data
dec  = total size in decimal
hex  = total size in hexadecimal

You can also compare instruction output using:

arm-none-eabi-objdump -D encryptionEngineARM.elf > encryptionEngineARM.lst
arm-none-eabi-objdump -D encryptionEngineC.elf > encryptionEngineC.lst

Then compare the generated instructions in the .lst files.

---

# 6. Measuring Execution Time

The most accurate way to compare execution time on Cortex-M4 is by using the CPU cycle counter: DWT_CYCCNT.

Execution time should be compared using CPU cycles.

execution time = cycles / CPU clock frequency

Example:

If the code takes 80 cycles and the CPU clock is 8 MHz:

execution time = 80 / 8,000,000
execution time = 0.000010 seconds
execution time = 10 microseconds

If you only want to compare Assembly vs C, comparing cycle count is enough. You do not need to convert to seconds unless you want to also know the difference in the elapsed time.


---

## 6.1 Enable the DWT cycle counter in GDB

Inside GDB, run:

set *(unsigned int*)0xE000EDFC = *(unsigned int*)0xE000EDFC | 0x01000000
set *(unsigned int*)0xE0001004 = 0
set *(unsigned int*)0xE0001000 = *(unsigned int*)0xE0001000 | 1

Register meanings:

0xE000EDFC = DEMCR register
0xE0001000 = DWT_CTRL register
0xE0001004 = DWT_CYCCNT register

This enables and resets the Cortex-M4 cycle counter.

---

## 6.2 Measuring the ARM Assembly version

For the ARM Assembly version, break at the beginning and end of the encryption/decryption code.

Example:

break start
continue

Reset the cycle counter:

set *(unsigned int*)0xE0001004 = 0

Run until the final infinite loop or stop label:

break stop
continue

Read the cycle count:

print *(unsigned int*)0xE0001004

The printed number is the number of CPU cycles used between the reset point and the breakpoint.

---

## 6.3 Measuring the C version

For the C version, break at main:

break main
continue

Reset the cycle counter before calling the encryption/decryption function:

set *(unsigned int*)0xE0001004 = 0

Step over the function call or set a breakpoint after it.

Example:

next

Then read the cycle count:

print *(unsigned int*)0xE0001004

The printed value is the number of CPU cycles used by the C function call and related instructions.

For better accuracy, place the measurement around only the function itself, not the infinite while(1) loop.

---

# 7. Alternative: Comparing Instruction Count

You can also compare the number of instructions generated.

Generate listing files:

arm-none-eabi-objdump -D encryptionEngineARM.elf > encryptionEngineARM.lst
arm-none-eabi-objdump -D encryptionEngineC.elf > encryptionEngineC.lst

Then inspect the relevant function/label.

For Assembly:

start:
loop:
stop:

For C:

main
encrypt
decrypt

This does not perfectly equal execution time, because different instructions may take different numbers of cycles, but it is still useful for comparing generated code structure.
However, make sure to multiply the instructions that contain memory access by 12, as instructions that contain memory access are atleast 10x slower.

---


# 8. Important Notes

- The ARM Assembly version directly controls the instructions used.
- The C version depends on compiler optimization.
- -O0 usually creates slower and larger code.
- -O2 usually creates faster code.
- The comparison should focus on execution cycles and generated code size, not compile time.
- Compile time depends on the computer/compiler, not the STM32 microcontroller.
- This project is for low-level programming and performance comparison, not real cryptographic protection.
