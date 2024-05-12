MEMORY {
    flash : ORIGIN = 0x00000000, LENGTH = 16M
    psram : ORIGIN = 0x01000000, LENGTH = 8M
    isram : ORIGIN = 0x01800000, LENGTH = 140K

}

ENTRY(_start)

_start = ORIGIN(flash);
__stack_top = ORIGIN(psram) + LENGTH(psram);
__global_pointer = ORIGIN(isram);
SECTIONS
{
    . = _start;

    .text : ALIGN(4) {
        KEEP(*(.rv32imain))
        *(.text)
        . = ALIGN(4);
    } > flash

    __text_end = .;

    .rodata : ALIGN(4) {
        *(.rodata*)
        . = ALIGN(4);
    } > flash = 0x00

    __data_lma = .;
    .data : AT(__data_lma)  {
        __data_start__ = ABSOLUTE(.);
        *(.data)
        . = ALIGN(4);
        __data_end__ = ABSOLUTE(.);
    } > psram = 0xFF

    __bss_lma = .;
    .bss  ALIGN(4) (NOLOAD) : {
        __bss_start__ = ABSOLUTE(.);
        *(.dynbss)
        *(.gnu.linkonce.b*)
        *(.bss)
        *(COMMON)
        . = ALIGN(16);
        __bss_end__ = ABSOLUTE(.);
    } > psram
}