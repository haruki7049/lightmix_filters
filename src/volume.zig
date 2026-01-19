const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub const DecayArgs = struct {
    start_point: usize = 0,
};

pub fn decay(comptime T: type, original: Wave(T), args: DecayArgs) !Wave(T) {
    var result_list: std.array_list.Aligned(T, null) = .empty;

    // Process each sample, applying a decay factor
    for (original.samples, args.start_point..) |sample, n| {
        // Calculate how far from the end we are
        const remaining_samples = original.samples.len - n;

        // Decay factor: 1.0 at start, 0.0 at end
        const decay_factor = @as(T, @floatFromInt(remaining_samples)) /
            @as(T, @floatFromInt(original.samples.len));

        // Apply the decay to the sample
        const decayed_sample = sample * decay_factor;
        try result_list.append(original.allocator, decayed_sample);
    }

    // Return a new Wave with the filtered samples
    return Wave(T){
        .samples = try result_list.toOwnedSlice(original.allocator),
        .allocator = original.allocator,
        .sample_rate = original.sample_rate,
        .channels = original.channels,
    };
}

test "decay" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const frequency = 440.0;
    const sample_rate = 44100.0;
    const radians_per_sec: f64 = frequency * 2.0 * std.math.pi;

    // Sine wave generation
    var samples: [44100]f64 = undefined;
    for (0..samples.len) |i| {
        const t = @as(f64, @floatFromInt(i)) / sample_rate;
        samples[i] = 0.5 * @sin(radians_per_sec * t);
    }

    const wave: Wave(f64) = Wave(f64).init(samples[0..], allocator, .{
        .sample_rate = 44100,
        .channels = 1,
    });

    const decayed_wave: Wave(f64) = wave.filter_with(DecayArgs, decay, .{ .start_point = 0 });
    defer decayed_wave.deinit();

    try std.testing.expectEqualSlices(f64, test_data.decay, decayed_wave.samples);
}

pub const CutAttackArgs = struct {
    start_point: usize = 1,
    length: usize = 100,
};

pub fn cutAttack(comptime T: type, original: Wave(T), options: CutAttackArgs) !Wave(T) {
    const allocator = original.allocator;
    var result: std.array_list.Aligned(T, null) = .empty;

    for (original.samples, options.start_point..) |sample, n| {
        if (n < options.length) {
            const percent: T = @floatFromInt(n / options.length);
            try result.append(allocator, percent * sample);

            continue;
        }

        try result.append(allocator, sample);
    }

    return Wave(T){
        .samples = try result.toOwnedSlice(allocator),
        .allocator = allocator,

        .sample_rate = original.sample_rate,
        .channels = original.channels,
    };
}

test "cutAttack" {
    const test_data = @import("./test_data.zig");
    const allocator = std.testing.allocator;

    const frequency = 440.0;
    const sample_rate = 44100.0;
    const radians_per_sec: f64 = frequency * 2.0 * std.math.pi;

    // Sine wave generation
    var samples: [44100]f64 = undefined;
    for (0..samples.len) |i| {
        const t = @as(f64, @floatFromInt(i)) / sample_rate;
        samples[i] = 0.5 * @sin(radians_per_sec * t);
    }

    const wave: Wave(f64) = Wave(f64).init(samples[0..], allocator, .{
        .sample_rate = 44100,
        .channels = 1,
    });

    const filtered_wave: Wave(f64) = wave.filter_with(CutAttackArgs, cutAttack, .{ .start_point = 0 });
    defer filtered_wave.deinit();

    try std.testing.expectEqualSlices(f64, test_data.cutAttack, filtered_wave.samples);
}
