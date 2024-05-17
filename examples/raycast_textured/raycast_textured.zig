const RV32I = @import("rv32i").RV32I;
const IO = @import("rv32i").IO;
const FP = @import("rv32i").FP(i16, 7, i32, u16);
const MAP_WIDTH = 24;
const MAP_HEIGHT = 24;
const SCREEN_WIDTH: usize = 256;
const W = FP.initRaw(0x7FFF);
const SCREEN_HEIGHT = 256;
const H = FP.initRaw(0x7FFF);
const SCREEN = RV32I.VRAM;
const Red = 0x001F;
const Green = 0x07E0;
const Blue = 0xF800;
const White = 0xFFFF;
const Yellow = 0x07FF;
const COLORS: [5]u16 = [5]u16{ Red, Green, Blue, White, Yellow };
const TEX_SZ = 64;
const COS_ROTSPEED = FP.initRaw(0x0072);
const SIN_ROTSPEED = FP.initRaw(0x003B);
const MOV_SPEED = FP.initRaw(0x0066);
const MAP: [MAP_WIDTH][MAP_HEIGHT]u8 = [MAP_WIDTH][MAP_HEIGHT]u8{ .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } };
const TEXTURES: [11]*const [TEX_SZ * TEX_SZ:0]u16 = [11]*const [TEX_SZ * TEX_SZ:0]u16{ @alignCast(@ptrCast(@embedFile("textures/eagle.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/redbrick.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/purplestone.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/greystone.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/bluestone.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/mossy.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/wood.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/colorstone.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/barrel.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/greenlight.png.raw"))), @alignCast(@ptrCast(@embedFile("textures/pillar.png.raw"))) };
pub export fn main() void {
    var posX = FP.init(22);
    var posY = FP.init(12);
    var dirX = FP.MINUS_ONE;
    var dirY = FP.ZERO;
    var planeX = FP.ZERO;
    var planeY = FP.initRaw(0x0055);
    while (true) {
        for (0..SCREEN_WIDTH - 1) |x| {
            const cameraX = FP.initRaw(@as(i16, @intCast(x)));
            const rayDirX = dirX.add((planeX.mul(cameraX)));
            const rayDirY = dirY.add((planeY.mul(cameraX)));
            var mapX = posX.int();
            var mapY = posY.int();
            var sideDistX = FP.initRaw(0);
            var sideDistY = FP.initRaw(0);

            const deltaDistX =
                if (rayDirX.eq(FP.initRaw(0)))
                FP.initRaw(0x7FFF)
            else
                FP.ONE.div(rayDirX).abs();

            const deltaDistY =
                if (rayDirY.eq(FP.initRaw(0)))
                FP.initRaw(0x7FFF)
            else
                FP.ONE.div(rayDirY).abs();

            var stepX: i16 = 0;
            var stepY: i16 = 0;
            var hit = false;
            var side = false;
            if (rayDirX.lt(FP.ZERO)) {
                stepX = -1;
                sideDistX = posX.frac().mul(deltaDistX);
            } else {
                stepX = 1;
                sideDistX = FP.ONE.sub(posX.frac()).mul(deltaDistX);
            }
            if (rayDirY.lt(FP.ZERO)) {
                stepY = -1;
                sideDistY = posY.frac().mul(deltaDistY);
            } else {
                stepY = 1;
                sideDistY = FP.ONE.sub(posY.frac()).mul(deltaDistY);
            }
            while (!hit) {
                if (sideDistX.lt(sideDistY)) {
                    sideDistX = sideDistX.add(deltaDistX);
                    mapX = mapX + stepX;
                    side = false;
                } else {
                    sideDistY = sideDistY.add(deltaDistY);
                    mapY = mapY + stepY;
                    side = true;
                }
                hit = MAP[@as(usize, @intCast(mapX))][@as(usize, @intCast(mapY))] > 0;
            }
            const perpWallDist =
                if (side)
                sideDistY.sub(deltaDistY)
            else
                sideDistX.sub(deltaDistX);

            const lineHeight = H.div(perpWallDist).int();
            var drawStart = (-lineHeight >> 1) + (SCREEN_HEIGHT >> 1);
            if (drawStart < 0) {
                drawStart = 0;
            }
            var drawEnd = (-lineHeight >> 1) + (SCREEN_HEIGHT >> 1);
            if (drawEnd > SCREEN_HEIGHT) {
                drawEnd = SCREEN_HEIGHT - 1;
            }
            const texNum = MAP[@as(usize, @intCast(mapX))][@as(usize, @intCast(mapY))] -% 1;
            const wallX =
                if (side)
                posX.add(perpWallDist.mul(rayDirX)).frac()
            else
                posY.add(perpWallDist.mul(rayDirY)).frac();
            var texX = @as(usize, @as(u16, @bitCast(wallX.shl(6).int())));
            if ((side and rayDirY.lt(FP.ZERO)) or ((!side) and rayDirX.gt(FP.ZERO))) {
                texX = TEX_SZ -| texX -| 1;
            }
            const step = FP.init(@divFloor(TEX_SZ, lineHeight));
            var texPos = FP.init(drawStart).sub(H.shr(1)).add(FP.init(lineHeight >> 1)).mul(step);
            for (@as(usize, @intCast(drawStart))..@as(usize, @intCast(drawEnd))) |y| {
                const texY = @as(usize, @as(u16, @bitCast(texPos.int() & (TEX_SZ - 1))));
                texPos = texPos.add(step);
                var color: u16 = TEXTURES[texNum][(texY << 8) + texX];
                if (side) {
                    color = color >> 1;
                }
                SCREEN[(x << 8) | y] = color;
            }
        }
        IO.swap_buffers();
    }
}
