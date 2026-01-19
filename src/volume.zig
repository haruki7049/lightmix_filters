const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;

pub fn decay(comptime T: type, original_wave: Wave(T)) !Wave(T) {
    var result_list: std.array_list.Aligned(T, null) = .empty;

    // Process each sample, applying a decay factor
    for (original_wave.samples, 0..) |sample, n| {
        // Calculate how far from the end we are
        const remaining_samples = original_wave.samples.len - n;

        // Decay factor: 1.0 at start, 0.0 at end
        const decay_factor = @as(T, @floatFromInt(remaining_samples)) /
            @as(T, @floatFromInt(original_wave.samples.len));

        // Apply the decay to the sample
        const decayed_sample = sample * decay_factor;
        try result_list.append(original_wave.allocator, decayed_sample);
    }

    // Return a new Wave with the filtered samples
    return Wave(T){
        .samples = try result_list.toOwnedSlice(original_wave.allocator),
        .allocator = original_wave.allocator,
        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
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

    const decayed_wave: Wave(f64) = wave.filter(decay);
    defer decayed_wave.deinit();

    try std.testing.expectEqualSlices(f64, test_data.decay, decayed_wave.samples);
}

pub fn amp(original_wave: Wave) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    for (original_wave.data, 0..) |data, i| {
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original_wave.data.len))) + 1.0;

        const new_data = data * volume;
        try result.append(new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
