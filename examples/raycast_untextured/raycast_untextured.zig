const RV32I = @import("rv32i").RV32I;
const IO = @import("rv32i").IO;
const FP = @import("rv32i").FP(i16, 8, i32, u16);
const MAP_WIDTH = 24;
const MAP_HEIGHT = 24;
const SCREEN_WIDTH:usize = 128;
const W = FP.initRaw(0x7F00);
const SCREEN_HEIGHT = 128;
const H = FP.initRaw(0x7F00);
const SCREEN = RV32I.VRAM;
const RGB_Red = 0x001F;
const RGB_Green = 0x07E0;
const RGB_Blue = 0xF800;
const RGB_White = 0xFFFF;
const RGB_Yellow = 0x07FF;
const COS_ROTSPEED = FP.initRaw(0x00E1);
const SIN_ROTSPEED = FP.initRaw(0x007B);
const MOV_SPEED = FP.initRaw(0x00D5);
const MAP: [MAP_WIDTH][MAP_HEIGHT]u8 = [MAP_WIDTH][MAP_HEIGHT]u8{ .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } };
pub export fn main() void {
    var posX = FP.init(22);
    var posY = FP.init(12);
    var dirX = FP.MINUS_ONE;
    var dirY = FP.ZERO;
    var planeX = FP.ZERO;
    var planeY = FP.initRaw(0x00A9);
    var counter:u8 = 0;
    while (true) {
        for(0..SCREEN_WIDTH) |x|{
            const cameraX = FP.initRaw(@as(i16, @intCast(x<<2)));
            const rayDirX = dirX.add((planeX.mul(cameraX)));
            const rayDirY = dirY.add((planeY.mul(cameraX)));
            var mapX = posX.int();
            var mapY = posY.int();
            var sideDistX = FP.initRaw(0);
            var sideDistY = FP.initRaw(0);

            const deltaDistX =
                if(rayDirX.eq(FP.initRaw(0)))
                    FP.initRaw(0x7FFF)
                else
                    FP.ONE.div(rayDirX).abs();

            const deltaDistY =
                if(rayDirY.eq(FP.initRaw(0)))
                    FP.initRaw(0x7FFF)
                else
                    FP.ONE.div(rayDirY).abs();

            var stepX:i16 = 0;
            var stepY:i16 = 0;
            var hit = false;
            var side = false;
            if(rayDirX.lt(FP.ZERO)){
                stepX = -1;
                sideDistX = posX.frac().mul(deltaDistX);
            }else{
                stepX = 1;
                sideDistX = FP.ONE.sub(posX.frac()).mul(deltaDistX);
            }
            if(rayDirY.lt(FP.ZERO)){
                stepY = -1;
                sideDistY = posY.frac().mul(deltaDistY);
            }else{
                stepY = 1;
                sideDistY = FP.ONE.sub(posY.frac()).mul(deltaDistY);
            }
            while(!hit){
                if(sideDistX.lt(sideDistY)){
                    sideDistX = sideDistX.add(deltaDistX);
                    mapX = mapX + stepX;
                    side = false;
                }else{
                    sideDistY = sideDistY.add(deltaDistY);
                    mapY = mapY + stepY;
                    side = true;
                }
                hit = MAP[@as(usize, @intCast(mapX))][@as(usize, @intCast(mapY))] > 0;
            }
            const perpWallDist =
                if(side)
                    sideDistY.sub(deltaDistY)
                else
                    sideDistX.sub(deltaDistX);

            const lineHeight = H.div(perpWallDist).clamp(FP.ZERO, H);
            const drawStart = lineHeight.neg().shr(1).add(H.shr(1));//.clamp(FP.ZERO, H.shr(1));
            const drawEnd = lineHeight.shr(1).add(H.shr(1));//.clamp(H.shr(1), H);
            var color:u16 = switch (MAP[@as(usize, @intCast(mapX))][@as(usize, @intCast(mapY))]) {
                0 => RGB_Red,
                1 => RGB_Green,
                2 => RGB_Blue,
                3 => RGB_White,
                else => RGB_Yellow
            };
            if (side){
                color = color >> 1;
            }
            for(@as(usize, @intCast(drawStart.int()))..@as(usize, @intCast(drawEnd.int()))) |p|{
                SCREEN[(p << 7) | x] = color;
            }
        }
        IO.swap_buffers(counter);
        counter = counter +% 1;
    }
}
