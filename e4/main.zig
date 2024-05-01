const std = @import("std");
const NAME_LEN: usize = 15;

const User = struct {
    first_name: [15]u8,
    last_name: [20]u8,
    age: u8,
};

pub fn setUpFirstName(slice: []const u8) [15]u8 {
    var string: [15]u8 = [_]u8{0} ** 15;
    const n = @min(15, slice.len);
    for (slice, 0..n) |char, i| {
        string[i] = char;
    }
    return string;
}

pub fn setUpLastName(slice: []const u8) [20]u8 {
    var string: [20]u8 = [_]u8{0} ** 20;
    const n = @min(20, slice.len);
    for (slice, 0..n) |char, i| {
        string[i] = char;
    }
    return string;
}

pub fn createUser(first_name: []const u8, last_name: []const u8, age: u8) User {
    const user = User{ .first_name = setUpFirstName(first_name), .last_name = setUpLastName(last_name), .age = age };
    return user;
}

pub fn printUser(user: User) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("First Name: {s}\nLast Name: {s}\nAge: {d}\n", .{ user.first_name, user.last_name, user.age });
}

pub fn saveUsers(users: []const User) !void {
    const dir = std.fs.cwd();
    var file: std.fs.File = undefined;
    if (dir.openFile("users.txt", .{})) |opened_file| {
        file = opened_file;
    } else |_| { //error handling
        file = try dir.createFile("users.txt", .{});
    }
    defer file.close();
    for (users) |user| {
        try file.writer().print("{s}\n{s}\n{d}\n", .{ user.first_name, user.last_name, user.age });
    }
}

pub fn main() !void {
    const users_arr = [_]User{
        createUser("Jan"[0..], "Kowalski"[0..], 42),
        createUser("Skipper"[0..], "Kawazaki"[0..], 19),
        createUser("Marcin"[0..], "Marciński"[0..], 22),
        createUser("Stefan"[0..], "Mucha"[0..], 35),
    };
    const users: []const User = &users_arr;
    for (users) |user| {
        try printUser(user);
        std.debug.print("---------------\n", .{});
    }
    try saveUsers(users);
}
