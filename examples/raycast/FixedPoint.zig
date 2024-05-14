const std = @import("std");
const assert = std.debug.assert;

fn FixedPoint(comptime T: type, comptime BinaryScaling: comptime_int, comptime InitFloat: type) type {
    return struct {
        const FP = @This();
        raw: T,
        const A = BinaryScaling;
        const r = BinaryScaling - 1;
        const n = BinaryScaling + 1;
        const p = ((n * 2) - r);
        const s = n + p + 1 - A;
        pub fn init(v: T) FP {
            return .{ .raw = v << BinaryScaling };
        }
        pub fn initFromFloat(v: InitFloat) FP {
            return .{ .raw = @floatCast(v * (1 << BinaryScaling)) };
        }
        pub fn initRaw(v: T) FP {
            return .{ .raw = v };
        }
        pub fn unscale(fp: FP) T {
            return fp.raw >> BinaryScaling;
        }
        pub fn add(a: FP, b: FP) FP {
            return .{ .raw = a.raw + b.raw };
        }
        pub fn sub(a: FP, b: FP) FP {
            return .{ .raw = a.raw - b.raw };
        }
        pub fn mul(a: FP, b: FP) FP {
            return .{ .raw = (a.raw * b.raw) >> BinaryScaling };
        }
        pub fn div(a: FP, b: FP) FP {
            return .{ .raw = (a.raw << BinaryScaling) / b.raw };
        }
        pub fn neg(a: FP) FP {
            return .{ .raw = -a.raw };
        }
        pub fn eq(a: FP, b: FP) bool {
            return a.raw == b.raw;
        }
        pub fn lt(a: FP, b: FP) bool {
            return a.raw < b.raw;
        }
        pub fn gt(a: FP, b: FP) bool {
            return a.raw > b.raw;
        }
        pub fn clamp(val: FP, lower: FP, upper: FP) FP {
            assert(lower.raw <= upper.raw);
            return max(lower, min(val, upper));
        }
        pub fn min(a: FP, b: FP) FP {
            return if (a.raw < b.raw) a else b;
        }
        pub fn max(a: FP, b: FP) FP {
            return if (a.raw > b.raw) a else b;
        }
        pub fn shr(a:FP, b:T) FP {
            return .{ .raw = a.raw >> @as(u5, @intCast(b)) };
        }
        pub fn int(a:FP) T {
            return a.raw >> BinaryScaling;
        }
        pub fn abs(a:FP) FP {
            return .{ .raw = @as(i32, @intCast(@abs(a.raw))) };
        }
        pub fn frac(a:FP) FP {
            return .{ .raw = a.raw & (std.math.maxInt(T) >> (BinaryScaling - @bitSizeOf(T))) };
        }
        pub fn sin(x: FP) FP {
            var xr = x.raw;
            xr = xr << (@bitSizeOf(T) - 2 - n);
            if ((xr ^ (xr << 1)) < 0) {
                xr = (1 << (@bitSizeOf(T) - 1)) - xr;
            }
            xr = xr >> (@bitSizeOf(T) - 2 - n);
            return .{ .raw = x * ((3 << p) - ((x * x) >> r)) >> s };
        }
        pub fn cos(x: FP) FP {
            const half = initFromFloat(0.5);
            return sin(x.add(half));
        }
    };
}
