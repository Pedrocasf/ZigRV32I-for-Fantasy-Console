const std = @import("std");
const assert = std.debug.assert;

pub fn FixedPoint(comptime T: type, comptime BinaryScaling: comptime_int, comptime TD: type, comptime TU: type) type {
    return struct {
        const FP = @This();
        raw: T,
        const A = BinaryScaling;
        const r = BinaryScaling - 1;
        const n = BinaryScaling + 1;
        const p = ((n * 2) - r);
        const s = n + p + 1 - A;
        pub fn init(v: T) FP {
            return .{ .raw = v <<| BinaryScaling };
        }
        pub const ONE = FP.init(1);
        pub const MINUS_ONE = FP.ONE.neg();
        pub const ZERO = FP.initRaw(0);
        pub fn initRaw(v: T) FP {
            return .{ .raw = v };
        }
        pub fn unscale(fp: FP) T {
            return fp.raw >> BinaryScaling;
        }
        pub fn add(a: FP, b: FP) FP {
            return .{ .raw = a.raw +| b.raw };
        }
        pub fn sub(a: FP, b: FP) FP {
            return .{ .raw = a.raw -| b.raw };
        }
        pub fn mul(a: FP, b: FP) FP {
            return .{ .raw = @as(T,@truncate((@as(TD,@intCast(a.raw)) * @as(TD,@intCast(b.raw))) >> BinaryScaling)) };
        }
        pub fn div(a: FP, b: FP) FP {
            if(b.raw == 0){
                return .{ .raw = std.math.maxInt(T)};
            }
            return .{ .raw = @as(T,@truncate(@divFloor(@as(TD,@intCast(a.raw)) << BinaryScaling ,@as(TD,@intCast(b.raw))))) };
        }
        pub fn neg(a: FP) FP {
            return .{ .raw = -%a.raw };
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
        pub fn gte(a: FP, b: FP) bool {
            return a.raw >= b.raw;
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
            return .{ .raw = a.raw >> @as(std.math.Log2Int(T), @intCast(b)) };
        }
        pub fn int(a:FP) T {
            return a.raw >> BinaryScaling;
        }
        pub fn uint(a:FP) TU {
            return @as(TU,@bitCast(a.raw)) >> BinaryScaling;
        }
        pub fn abs(a:FP) FP {
            return .{ .raw = @as(T, @bitCast(@abs(a.raw))) };
        }
        pub fn frac(a:FP) FP {
            return .{ .raw = a.raw & 0x00FF};
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
            const half = FP.ONE.shr(1);
            return sin(x.add(half));
        }
    };
}
