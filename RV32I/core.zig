const root = @import("root");
pub const RV32I = struct {
    fn bit_to_io(bit: usize) *volatile u8 {
        const offset = 1 << (bit + 2);
        return @ptrFromInt(IO_BASE + offset);
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
    const IO_BASE = 0x01823000;
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
    pub fn memcpy32(noalias destination: anytype, noalias source: anytype, count: usize) void {
        if (count < 4) {
            genericMemcpy(@as([*]volatile u8, @ptrCast(destination)), @as([*]const u8, @ptrCast(source)), count);
        } else {
            if ((@intFromPtr(@as(*volatile u8, @ptrCast(destination))) % 4) == 0 and (@intFromPtr(@as(*const u8, @ptrCast(source))) % 4) == 0) {
                alignedMemcpy(u32, @as([*]align(4) volatile u8, @ptrCast(@alignCast(destination))), @as([*]align(4) const u8, @ptrCast(@alignCast(source))), count);
            } else if ((@intFromPtr(@as(*volatile u8, @ptrCast(destination))) % 2) == 0 and (@intFromPtr(@as(*const u8, @ptrCast(source))) % 2) == 0) {
                alignedMemcpy(u16, @as([*]align(2) volatile u8, @ptrCast(@alignCast(destination))), @as([*]align(2) const u8, @ptrCast(@alignCast(source))), count);
            } else {
                genericMemcpy(@as([*]volatile u8, @ptrCast(destination)), @as([*]const u8, @ptrCast(source)), count);
            }
        }
    }

    pub fn memcpy16(noalias destination: anytype, noalias source: anytype, count: usize) void {
        if (count < 2) {
            genericMemcpy(@as([*]u8, @ptrCast(destination)), @as([*]const u8, @ptrCast(source)), count);
        } else {
            if ((@intFromPtr(@as(*u8, @ptrCast(destination))) % 2) == 0 and (@intFromPtr(@as(*const u8, @ptrCast(source))) % 2) == 0) {
                alignedMemcpy(u16, @as([*]align(2) volatile u8, @ptrCast(@alignCast(destination))), @as([*]align(2) const u8, @ptrCast(@alignCast(source))), count);
            } else {
                genericMemcpy(@as([*]volatile u8, @ptrCast(destination)), @as([*]const u8, @ptrCast(source)), count);
            }
        }
    }

    pub fn alignedMemcpy(comptime T: type, noalias destination: [*]align(@alignOf(T)) volatile u8, noalias source: [*]align(@alignOf(T)) const u8, count: usize) void {
        @setRuntimeSafety(false);
        const alignSize = count / @sizeOf(T);
        const remainderSize = count % @sizeOf(T);

        const alignDestination = @as([*]volatile T, @ptrCast(destination));
        const alignSource = @as([*]const T, @ptrCast(source));

        var index: usize = 0;
        while (index != alignSize) : (index += 1) {
            alignDestination[index] = alignSource[index];
        }

        index = count - remainderSize;
        while (index != count) : (index += 1) {
            destination[index] = source[index];
        }
    }

    pub fn genericMemcpy(noalias destination: [*]volatile u8, noalias source: [*]const u8, count: usize) void {
        @setRuntimeSafety(false);
        var index: usize = 0;
        while (index != count) : (index += 1) {
            destination[index] = source[index];
        }
    }

    pub fn memset32(destination: anytype, value: u32, count: usize) void {
        if ((@intFromPtr(@as(*volatile u8, @ptrCast(destination))) % 4) == 0) {
            alignedMemset(u32, @as([*]align(4) volatile u8, @ptrCast(@alignCast(destination))), value, count);
        } else {
            genericMemset(u32, @as([*]volatile u8, @ptrCast(destination)), value, count);
        }
    }

    pub fn memset16(destination: anytype, value: u16, count: usize) void {
        if ((@intFromPtr(@as(*u8, @ptrCast(destination))) % 4) == 0) {
            alignedMemset(u16, @as([*]align(2) volatile u8, @ptrCast(@alignCast(destination))), value, count);
        } else {
            genericMemset(u16, @as([*]volatile u8, @ptrCast(destination)), value, count);
        }
    }

    pub fn alignedMemset(comptime T: type, destination: [*]align(@alignOf(T)) volatile u8, value: T, count: usize) void {
        @setRuntimeSafety(false);
        const alignedDestination = @as([*]volatile T, @ptrCast(destination));
        var index: usize = 0;
        while (index != count) : (index += 1) {
            alignedDestination[index] = value;
        }
    }

    pub fn genericMemset(comptime T: type, destination: [*]volatile u8, value: T, count: usize) void {
        @setRuntimeSafety(false);
        const valueBytes = @as([*]const u8, @ptrCast(&value));
        var index: usize = 0;
        while (index != count) : (index += 1) {
            comptime var expandIndex = 0;
            inline while (expandIndex < @sizeOf(T)) : (expandIndex += 1) {
                destination[(index * @sizeOf(T)) + expandIndex] = valueBytes[expandIndex];
            }
        }
    }
};
export fn RV32IMain() linksection(".rv32imain") noreturn {
    asm volatile (
        \\la sp, __stack_top
        \\la gp, __global_pointer
    );
    RV32IZigStartup();
}

extern var __bss_lma: u8;
extern var __bss_start__: u8;
extern var __bss_end__: u8;
extern var __data_lma: u8;
extern var __data_start__: u8;
extern var __data_end__: u8;

fn RV32IZigStartup() noreturn {
    // Clear .bss
    RV32I.memset32(@as([*]volatile u8, @ptrCast(&__bss_start__)), 0, @intFromPtr(&__bss_end__) - @intFromPtr(&__bss_start__));

    // Copy .data section to PSRAM
    RV32I.memcpy32(@as([*]volatile u8, @ptrCast(&__data_start__)), @as([*]const u8, @ptrCast(&__data_lma)), @intFromPtr(&__data_end__) - @intFromPtr(&__data_start__));

    // call user's main
    if (@hasDecl(root, "main")) {
        root.main();
    }
    unreachable;
}
