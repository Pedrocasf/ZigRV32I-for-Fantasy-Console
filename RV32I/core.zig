const root = @import("root");
pub const RV32I = struct {
    fn bit_to_io(bit: usize) *volatile u8 {
        const offset = 1 << (bit + 2);
        return @ptrFromInt(IO_BASE + offset - 1);
    }
    const IO_LEDS_bit = 0;
    const IO_UART_DAT_bit = 1;
    const IO_UART_CNTL_bit = 2;
    const IO_SSD1351_CNTL_bit = 3;
    const IO_SSD1351_CMD_bit = 4;
    const IO_SSD1351_DAT_bit = 5;
    const IO_SSD1351_DAT16_bit = 6;
    const IO_MAX7219_DAT_bit = 7;
    const IO_SDCARD_bit = 8;
    const IO_BUTTONS_bit = 9;
    const IO_SWAP_BUFFERS_bit = 10;
    const IO_BASE = 0x01823000;
    const VRAM_SIZE = 0x000023000;
    pub const LEDS = bit_to_io(IO_LEDS_bit);
    pub const UART_DAT = bit_to_io(IO_UART_DAT_bit);
    pub const UART_CNTL = bit_to_io(IO_UART_CNTL_bit);
    pub const SSD1351_CNTL = bit_to_io(IO_SSD1351_CNTL_bit);
    pub const SSD1351_CMD = bit_to_io(IO_SSD1351_CMD_bit);
    pub const SSD1351_DAT = bit_to_io(IO_SSD1351_DAT_bit);
    pub const SSD1351_DAT16 = bit_to_io(IO_SSD1351_DAT16_bit);
    pub const MAX7219_DAT = bit_to_io(IO_MAX7219_DAT_bit);
    pub const SDCARD = bit_to_io(IO_SDCARD_bit);
    pub const BUTTONS = bit_to_io(IO_BUTTONS_bit);
    pub const SWAP_BUFFERS = bit_to_io(IO_SWAP_BUFFERS_bit);
    pub const VRAM = @as([*]align(2) volatile u16, @ptrFromInt(0x01800000));
};
export fn RV32IMain() linksection(".rv32imain") callconv(.Naked)  noreturn {
    asm volatile (
        \\la sp, __stack_top
        \\la gp, __global_pointer
        \\j _RV32IZigStartup
    );
}

extern var __bss_start__: u8;
extern var __bss_end__: u8;
extern var __data_lma: u8;
extern var __data_start__: u8;
extern var __data_end__: u8;

export fn _RV32IZigStartup() noreturn {
    const bss_size:isize = @bitCast(@intFromPtr(&__bss_start__) - @intFromPtr(&__bss_end__));
    // Clear .bss
    if(bss_size > 0){
        @memset(@as([*]volatile u8, @ptrCast(&__bss_start__))[0..@bitCast(bss_size-1)], 0);
    }
    
    const data_size:isize = @bitCast(@intFromPtr(&__data_start__) - @intFromPtr(&__data_end__));
    // Copy .data section to PSRAM
    if(data_size > 0){
        @memcpy(@as([*]volatile u8, @ptrCast(&__data_start__))[0..@bitCast(data_size-1)], @as([*]const u8, @ptrCast(&__data_lma))[0..@bitCast(data_size-1)]);
    }
    // call user's main
    if (@hasDecl(root, "main")) {
        root.main();
    }
    asm volatile (
        \\fence.tso
    );
    unreachable;
}
