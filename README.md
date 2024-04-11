# ZigRV32IFCBSP
A board support package for a upcoming fantasy console based on a FemtoSOC emulator
Always remember that your main function should have the siignature "pub export fn main() void".
This is a workaround for a bug in either zig or llvm. If nothing from the file where your main
function is located is exported the compiler will generate either an empty flat binary or an
ELF with zero sized sections.
