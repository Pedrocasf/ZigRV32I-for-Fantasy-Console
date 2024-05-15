pub const IO = struct {
    const RV32I = @import("core.zig").RV32I;
    pub fn leds(v: u8) void {
        RV32I.LEDS.* = v;
    }
    pub fn putchar(ch: u8) void {
        leds(ch);
        while (RV32I.UART_CNTL.* != 0) {}
        RV32I.UART_DAT.* = ch;
    }
    pub fn print(s: []const u8) void {
        for (s) |c| {
            putchar(c);
        }
    }
    pub fn frame_done(done:u8)void{
        RV32I.FRAME_DONE.* = done;
    }
};
