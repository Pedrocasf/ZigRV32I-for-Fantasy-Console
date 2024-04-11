const std = @import("std");
const RV32IBuilder = @import("RV32I/builder.zig");

pub fn build(b: *std.Build) void {
    _ = RV32IBuilder.addRV32IExecutable(b, "hello_rv_world", "examples/hello_rv_world/hello_rv_world.zig");
}