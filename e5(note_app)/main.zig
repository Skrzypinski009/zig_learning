const std = @import("std");
const time = std.time;
const Note = @import("note.zig").Note;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // const n = Note.init("ExampleNote"[0..], time.timestamp(), "tag1, tag2"[0..], "Content of the ExampleNote! :)\n Have fun reading it\n"[0..]);
    // try n.printRaw(stdout);
    // try n.save("/home/marek/Dokumenty/zig/my_examples/zad5 - note_app/example_note");
    var n = try Note.load(allocator, "/home/marek/Dokumenty/zig/my_examples/zad5 - note_app/example_note");
    try n.print(stdout);
    n.free(allocator);
}
