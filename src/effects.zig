pub fn distortion(original_wave: Wave, args: DistortionArgs) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    for (original_wave.data, 0..) |sample, i| {
        const amped_sample: f32 = sample * args.amplitude;

        // Check whether amped_sample is under zero or not
        if (amped_sample < 0) {
            // Check whether amped_sample is under -1.0 or not
            if (amped_sample < -1.0) {
                try result.append(-1.0);
            } else {
                try result.append(amped_sample);
            }
        } else {
            // Check whether amped_sample is over 1.0 or not
            if (amped_sample > 1.0) {
                try result.append(1.0);
            } else {
                try result.append(amped_sample);
            }
        }
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}

pub const DistortionArgs = struct {
    amplitude: f32,
};
