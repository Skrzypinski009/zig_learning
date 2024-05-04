const std = @import("std");

pub const Options = struct {
    array: [][]u8,
    allocator: std.mem.Allocator,

    pub fn init(options_str: []const u8, allocator: std.mem.Allocator) Options {
        var options = Options{ .array = &.{}, .allocator = allocator };
        options.arrayFromString(options_str) catch std.debug.print("aa", .{});
        return options;
    }

    pub fn deinit(self: *Options) void {
        for (self.array) |option| {
            self.allocator.free(option);
        }
        self.allocator.free(self.array);
    }

    pub fn addOption(self: *Options, string: []const u8) !void {
        const old_len: usize = self.array.len;
        self.array = try self.allocator.realloc(self.array, old_len + 1);
        self.array[old_len] = try self.allocator.alloc(u8, string.len);
        std.mem.copyForwards(u8, self.array[old_len], string);
    }

    pub fn arrayFromString(self: *Options, options_str: []const u8) !void {
        var seq = std.mem.splitSequence(u8, options_str, ";"[0..]);
        while (seq.next()) |option| {
            try self.addOption(option[0..]);
        }
    }

    pub fn print(self: Options, writer: anytype) !void {
        for (self.array, 0..) |option, i| {
            try writer.print("{d} - {s}\n", .{ i + 1, option });
        }
    }
};
