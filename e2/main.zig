const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn capitalize(input_text: []const u8, allocator: Allocator) ![]u8 {
    var new_text: []u8 = try allocator.alloc(u8, input_text.len);

    for (input_text, 0..) |char, i| {
        if (std.ascii.isAlphanumeric(char)) {
            if (i > 0 and input_text[i - 1] == ' ' or i == 0) {
                new_text[i] = std.ascii.toUpper(char);
            } else new_text[i] = std.ascii.toLower(char);
        } else {
            new_text[i] = char;
        }
    }
    return new_text;
}

pub fn get_user_input() ![]u8 {
    const stdin = std.io.getStdIn().reader();
    var buffer: [8]u8 = undefined;
    if (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        return input;
    }
    return "";
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const stdout = std.io.getStdOut().writer();
    // const stdin = std.io.getStdIn().reader();

    const user_input: []u8 = try get_user_input();
    const text = try capitalize(user_input, arena.allocator());
    // try stdout.print("{any} => {any}\n", .{ @TypeOf(string_text), string_text });

    try stdout.print("{!s}\n", .{text});
}
