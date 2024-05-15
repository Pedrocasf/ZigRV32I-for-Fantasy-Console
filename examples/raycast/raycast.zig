const RV32I = @import("rv32i").RV32I;
const IO = @import("rv32i").IO;
const FP = @import("FixedPoint.zig").FixedPoint(i32, 23, f32);
const MAP_WIDTH = 24;
const MAP_HEIGHT = 24;
const SCREEN_WIDTH:usize = 256;
const W = FP.init(SCREEN_WIDTH-1);
const SCREEN_HEIGHT = 256;
const H = FP.init(SCREEN_HEIGHT-1);
const SCREEN_POINTER = RV32I.VRAM;
const RGB_Red = 0xF800;
const RGB_Green = 0x07E0;
const RGB_Blue = 0x001F;
const RGB_White = 0xFFFF;
const RGB_Yellow = 0xFF70;
const MAP: [MAP_WIDTH][MAP_HEIGHT]u8 = [MAP_WIDTH][MAP_HEIGHT]u8{ .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } };
pub export fn main() void {
    const posX = FP.init(22);
    const posY = FP.init(12);
    const dirX = FP.init(-1);
    const dirY = FP.init(0);
    const planeX = FP.init(0);
    const planeY = FP.initRaw(0x00547ae1);
    var counter:u8 = 0;
    while (true) {
        for(0..SCREEN_WIDTH) |x|{
            const cameraX = FP.init(@as(i32, @intCast(x))).shr(7);
            const rayDirX = dirX.add((planeX.mul(cameraX)));
            const rayDirY = dirY.add((planeY.mul(cameraX)));
            var mapX = posX.int();
            var mapY = posY.int();
            var sideDistX = FP.initRaw(0);
            var sideDistY = FP.initRaw(0);
            const deltaDistX = if(rayDirX.eq(FP.initRaw(0)))
            FP.initRaw(0x7FFFFFFF)
            else
            FP.init(1).div(rayDirX).abs();
            const deltaDistY = if(rayDirY.eq(FP.initRaw(0)))
            FP.initRaw(0x7FFFFFFF)
            else
            FP.init(1).div(rayDirY).abs();
            var stepX:i32 = 0;
            var stepY:i32 = 0;
            var hit = false;
            var side = false;
            if(rayDirX.lt(FP.initRaw(0))){
                stepX = -1;
                sideDistX = posX.sub(FP.init(mapX)).mul(deltaDistX);
            }else{
                stepX = 1;
                sideDistX = FP.init(mapX+1).sub(posX).mul(deltaDistX);
            }
            if(rayDirY.lt(FP.initRaw(0))){
                stepY = -1;
                sideDistY = posY.sub(FP.init(mapY)).mul(deltaDistY);
            }else{
                stepY = 1;
                sideDistY = FP.init(mapY+1).sub(posY).mul(deltaDistY);
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
            var perpWallDist = FP.initRaw(0);
            if(side){
                perpWallDist = sideDistY.sub(deltaDistY);
            }else{
                perpWallDist = sideDistX.sub(deltaDistX);
            }
            const lineHeight = H.div(perpWallDist);
            var drawStart = lineHeight.neg().shr(1).add(H.shr(1));
            if(drawStart.lt(FP.initRaw(0))){
                drawStart = (FP.initRaw(0));
            }
            var drawEnd = lineHeight.shr(1).add(H.shr(1));
            if(drawEnd.gt(H)){
                drawEnd = H.sub(FP.init(1));
            }
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
                SCREEN_POINTER[x<<8|p] = color;
            }
        }
        IO.frame_done(counter);
        counter = counter +% 1;
    }
}
