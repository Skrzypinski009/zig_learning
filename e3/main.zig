const std = @import("std");

pub fn swap(a: *i32, b: *i32) void {
    const temp: i32 = a.*;
    a.* = b.*;
    b.* = temp;
}

pub fn randomize(array: []i32) void {
    const timestamp = std.time.timestamp();
    var prng = std.rand.DefaultPrng.init(@intCast(timestamp));
    var rand_num: i32 = undefined;
    for (0..array.len) |i| {
        rand_num = @mod(prng.random().int(i32), @as(i32, @intCast(array.len)));
        swap(&array[i], &array[@as(usize, @intCast(rand_num))]);
    }
}

pub fn bubble_sort(array: []i32) void {
    var sorted: bool = undefined;
    for (1..array.len) |i| {
        sorted = true;
        for (1..array.len - (i - 1)) |j| {
            if (array[j] < array[j - 1]) {
                sorted = false;
                swap(&array[j], &array[j - 1]);
            }
        }
        if (sorted) break;
    }
}

pub fn selection_sort(array: []i32) void {
    var min_idx: usize = undefined;
    for (0..array.len) |i| {
        min_idx = i;
        for (i..array.len) |j| {
            if (array[j] < array[min_idx]) {
                min_idx = j;
            }
        }
        if (min_idx != i) {
            swap(&array[i], &array[min_idx]);
        }
    }
}

pub fn main() !void {
    var arr = [_]i32{ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 };

    randomize(arr[0..]);
    std.debug.print("randomized: {any}\n", .{arr});

    bubble_sort(arr[0..]);
    std.debug.print("bubble sort: {any}\n", .{arr});

    randomize(arr[0..]);
    std.debug.print("randomized: {any}\n", .{arr});

    selection_sort(arr[0..]);
    std.debug.print("selection sort: {any}\n", .{arr});
}
