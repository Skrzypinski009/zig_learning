const std = @import("std");

pub const Note = struct {
    name: []u8,
    timestamp: i64,
    tags: []u8,
    content: []u8,

    pub fn init(name: []u8, timestamp: i64, tags: []u8, content: []u8) Note {
        return Note{ .name = name, .timestamp = timestamp, .tags = tags, .content = content };
    }

    pub fn print(self: Note, writer: anytype) !void {
        try writer.print("Name: {s},\nTimestamp: {d},\nTags: {s},\nContent: {s}\n", .{ self.name, self.timestamp, self.tags, self.content });
    }

    pub fn printRaw(self: Note, writer: anytype) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        const new_len = self.content.len + std.mem.count(u8, self.content, "\n");
        const new_content: []u8 = try allocator.alloc(u8, new_len);
        defer allocator.free(new_content);

        _ = std.mem.replace(u8, self.content, "\n", "\\n", new_content);
        const fmt = "name: {s}\ntimestamp: {d}\ntags: {s}\ncontent: {s}\n";

        try writer.print(fmt, .{ self.name, self.timestamp, self.tags, new_content });
    }

    pub fn save(self: Note, path: []const u8) !void {
        // var file: std.fs.File = undefined;
        // file = std.fs.openFileAbsolute(path, .{ .mode = std.fs.File.OpenMode.write_only }) catch |err| switch (err) {
        //     error.FileNotFound => try std.fs.createFileAbsolute(path, .{}),
        //     else => return err,
        // };
        var file: std.fs.File = try std.fs.createFileAbsolute(path, .{ .truncate = true });
        defer file.close();
        const writer = file.writer();
        try self.printRaw(writer);
    }

    pub fn nextValueFromLines(line_seq: ?[]const u8) []const u8 {
        if (line_seq) |line| {
            var seq = std.mem.splitSequence(u8, line, ":"[0..]);
            _ = seq.next();
            const value = seq.next();
            if (value) |real_value| {
                return real_value[1..];
            }
        }
        unreachable;
    }

    pub fn load(allocator: std.mem.Allocator, path: []const u8) !Note {
        var file: std.fs.File = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        const reader = file.reader();

        const file_content: []u8 = try reader.readAllAlloc(allocator, std.math.maxInt(usize));
        defer allocator.free(file_content);
        _ = try reader.readUntilDelimiterOrEof(file_content, 0);
        // std.debug.print("{s}\n", .{file_content});

        var name: []const u8 = undefined;
        var timestamp: i64 = 0;
        var tags: []const u8 = undefined;
        var content: []const u8 = undefined;

        var lines = std.mem.splitSequence(u8, file_content, "\n"[0..]);
        name = nextValueFromLines(lines.next());
        const timestamp_str = nextValueFromLines(lines.next());
        timestamp = try std.fmt.parseInt(i64, timestamp_str, 10);
        tags = nextValueFromLines(lines.next());
        content = nextValueFromLines(lines.next());
        // std.debug.print("name: {s}, tags: {s}\n", .{ name, tags });

        const unical_name: []u8 = try allocator.alloc(u8, name.len);
        const unical_tags: []u8 = try allocator.alloc(u8, tags.len);
        const unical_content: []u8 = try allocator.alloc(u8, content.len);

        std.mem.copyForwards(u8, unical_name, name);
        std.mem.copyForwards(u8, unical_tags, tags);
        std.mem.copyForwards(u8, unical_content, content);
        return Note.init(unical_name, timestamp, unical_tags, unical_content);
    }

    pub fn free(self: Note, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.tags);
        allocator.free(self.content);
    }
};
