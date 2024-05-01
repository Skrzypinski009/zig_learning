const std = @import("std");

fn ask_user() !i32 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [4]u8 = undefined;

    try stdout.print("A number please: ", .{});

    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return std.fmt.parseInt(i32, user_input, 10);
    }
    return @as(i32, 0);
}

pub fn main() !void {
    const timestamp: i64 = std.time.timestamp();
    const u_timestamp: u64 = @intCast(timestamp);
    var r = std.rand.DefaultPrng.init(u_timestamp);
    const number = @mod(r.random().int(i32), 100) + 1;

    var guess: i32 = 0;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Guess a number in a range from 1 to 100.\n", .{});

    while (guess != number) {
        try stdout.print("Give a number: ", .{});
        guess = try ask_user();
        if (guess < number) {
            try stdout.print("It's to small!\n", .{});
        } else if (guess > number) {
            try stdout.print("It's to big!\n", .{});
        }
    }
    try stdout.print("Congratulations! You guessed the number!\n", .{});
}
