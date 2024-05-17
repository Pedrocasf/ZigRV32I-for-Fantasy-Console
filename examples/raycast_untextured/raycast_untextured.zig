const RV32I = @import("rv32i").RV32I;
const IO = @import("rv32i").IO;
const FP = @import("rv32i").FP(i16, 8, i32, u16);
const MAP_SZ = 24;
const SCREEN_SZ = 256;
const SZ = FP.initRaw(0x7FFF);
const SCREEN = RV32I.VRAM;
const Red = 0x001F;
const Green = 0x07E0;
const Blue = 0xF800;
const White = 0xFFFF;
const Yellow = 0x07FF;
const COLORS:[5]u16 = [5]u16{Red, Green, Blue, White, Yellow};
const COS_ROTSPEED = FP.initRaw(0x0072);
const SIN_ROTSPEED = FP.initRaw(0x003B);
const MOV_SPEED = FP.initRaw(0x0066);
const MAP: [MAP_SZ][MAP_SZ]u8 = [MAP_SZ][MAP_SZ]u8{ .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 }, .{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } };
pub export fn main() void {
    var posX = FP.init(22);
    var posY = FP.init(12);
    var dirX = FP.MINUS_ONE;
    var dirY = FP.ZERO;
    var planeX = FP.ZERO;
    var planeY = FP.initRaw(0x0055);
    while (true) {
        for(0..SCREEN_SZ-1) |x|{
            const cameraX = FP.initRaw(@as(i16, @intCast(x)));
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

            const lineHeight = @divFloor(SCREEN_SZ, perpWallDist.int());
            var drawStart = (-lineHeight >> 1) + (SCREEN_SZ >> 1);
            if (drawStart < 0) {
                drawStart = 0;
            }
            var drawEnd = (lineHeight >> 1) + (SCREEN_SZ >> 1);
            if (drawEnd > SCREEN_SZ) {
                drawEnd = SCREEN_SZ - 1;
            }
            var color:u16 = COLORS[MAP[@as(usize, @intCast(mapX))][@as(usize, @intCast(mapY))]];
            if (side){
                color = color >> 1;
            }
            for(@as(usize, @intCast(drawStart))..@as(usize, @intCast(drawEnd))) |p|{
                SCREEN[(x << 8) | p] = color;
            }
        }
        IO.swap_buffers();
    }
}
