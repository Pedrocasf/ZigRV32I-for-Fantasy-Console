# ZigRV32I-for-Fantasy-Console
A board support package for an upcoming fantasy console based on a FemtoSOC emulator
Always remember that your main function should have the signature "pub export fn main() void".
This is a workaround for a bug in either zig or llvm. If nothing from the file where your main
function is located is exported the compiler will generate either an empty flat binary or an
ELF with zero sized sections.
