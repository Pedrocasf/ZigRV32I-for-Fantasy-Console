const std = @import("std");
const RV32IBuilder = @import("RV32I/builder.zig");

pub fn build(b: *std.Build) void {
    _ = RV32IBuilder.addRV32IExecutable(b, "hello_rv_world", "examples/hello_rv_world/hello_rv_world.zig");
    _ = RV32IBuilder.addRV32IExecutable(b, "raycast_untextured", "examples/raycast_untextured/raycast_untextured.zig");
    _ = RV32IBuilder.addRV32IExecutable(b, "raycast_textured", "examples/raycast_textured/raycast_textured.zig");
}
