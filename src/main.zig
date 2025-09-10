const std = @import("std");
const lightmix = @import("lightmix");
const filters = @import("lightmix_filters");

const Wave = lightmix.Wave;

const sample_rate: usize = 44100;
const channels: usize = 1;
const bits: usize = 16;

const frequency: f32 = 220.0;
const amplitude: f32 = 1.0;
const length: usize = 88200;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const wave: Wave = generate(allocator).filter(filters.volume.decay);
    defer wave.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try wave.write(file);

    try wave.debug_play();
}

fn generate(allocator: std.mem.Allocator) Wave {
    const data: []const f32 = generate_sinewave_data(allocator);
    defer allocator.free(data);

    const result: Wave = Wave.init(data, allocator, .{
        .sample_rate = sample_rate,
        .channels = channels,
        .bits = bits,
    });

    return result;
}

fn generate_sinewave_data(allocator: std.mem.Allocator) []const f32 {
    const sample_rate_f: f32 = @floatFromInt(sample_rate);
    const radians_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result = std.ArrayList(f32).init(allocator);
    defer result.deinit();

    for (0..length) |i| {
        const v: f32 = std.math.sin(@as(f32, @floatFromInt(i)) * radians_per_sec / sample_rate_f) * amplitude;
        result.append(v) catch @panic("Out of memory");
    }

    return result.toOwnedSlice() catch @panic("Out of memory");
}
