const std = @import("std");
const lightmix = @import("lightmix");
const seventh_chords = @import("seventh-chords");

const Wave = lightmix.Wave;
const Scale = seventh_chords.Scale;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = undefined;
    defer wave.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try wave.write(file);

    try wave.debug_play();
}
