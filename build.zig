const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const lightmix = b.dependency("lightmix", .{});

    // Modules
    const mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
        },
    });

    // Install
    const lib = b.addLibrary(.{
        .name = "lightmix_filters",
        .root_module = mod,
    });
    b.installArtifact(lib);

    // Unit tests
    const unit_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
