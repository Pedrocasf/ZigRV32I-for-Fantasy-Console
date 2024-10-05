const std = @import("std");

const RV32ILinkerScript = libRoot() ++ "/rv32i.ld";
const RV32ILibFile = libRoot() ++ "/rv32i.zig";
var ElfOrBinOption: ?bool = null;
var IsDebugOption: ?bool = null;
const rv32i_target_query = blk: {
    const target = std.Target.Query{
        .cpu_arch = std.Target.Cpu.Arch.riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .os_tag = .freestanding,
    };
    break :blk target;
};
fn libRoot() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub fn addRV32IStaticLibrary(b: *std.Build, libraryName: []const u8, sourceFile: []const u8, opt: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{ .name = libraryName, .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = sourceFile }}, .target = b.resolveTargetQuery(rv32i_target_query), .optimize = opt, .single_threaded = true });
    lib.setLinkerScriptPath(.{ .src_path = .{ .owner = b, .sub_path = RV32ILinkerScript }});
    return lib;
}

pub fn createRV32ILib(b: *std.Build, opt: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    return addRV32IStaticLibrary(b, "ZigRV32I", RV32ILibFile, opt);
}
pub fn addRV32IExecutable(b: *std.Build, rv32iName: []const u8, sourceFile: []const u8) *std.Build.Step.Compile {
    const ElfOrBin = blk: {
        if (ElfOrBinOption) |value| {
            break :blk value;
            } else {
            const newElfOrBin = b.option(bool, "ElfOrBin", "select true for generating an ELF file or false for a flat binary") orelse false;
            ElfOrBinOption = newElfOrBin;
            break :blk newElfOrBin;
            }
        };
    const IsDebug = blk: {
        if (IsDebugOption) |value| {
            break :blk value;
        } else {
            const newIsDebug = b.option(bool, "IsDebug", "select if is a debug build") orelse false;
            IsDebugOption = newIsDebug;
            break :blk newIsDebug;
        }
    };
    const exe = b.addExecutable(.{ .name = rv32iName, .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = sourceFile }}, .target = b.resolveTargetQuery(rv32i_target_query), .optimize = if(IsDebug) .Debug else .ReleaseFast, .single_threaded = true });

    exe.setLinkerScriptPath(.{ .src_path = .{ .owner = b, .sub_path = RV32ILinkerScript }});
    if (ElfOrBin) {
        b.installArtifact(exe);
    } else {
        const objcopy_step = exe.addObjCopy(.{
            .format = .bin,
            });

        const install_bin_step = b.addInstallBinFile(objcopy_step.getOutput(), b.fmt("{s}.bin", .{rv32iName}));
        install_bin_step.step.dependOn(&objcopy_step.step);

        b.default_step.dependOn(&install_bin_step.step);

    }

    const rv32iLib = createRV32ILib(b, if(IsDebug) .Debug else .ReleaseFast);
    exe.root_module.addAnonymousImport("rv32i", .{ .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = RV32ILibFile }}});
    exe.linkLibrary(rv32iLib);
    b.default_step.dependOn(&exe.step);
    return exe;
}
