const std = @import("std");
const lightmix = @import("lightmix");
const filters = @import("lightmix_filters");

const Wave = lightmix.Wave;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = undefined;
    defer wave.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try wave.write(file);

    try wave.debug_play();
}
