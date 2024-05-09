const std = @import("std");
const time = std.time;
const Note = @import("note.zig").Note;
const NoteManager = @import("note_manager.zig").NoteManager;
const Menu = @import("menu.zig").Menu;

pub fn main() !void {
    // const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // const n = Note.init("ExampleNote"[0..], time.timestamp(), "tag1, tag2"[0..], "Content of the ExampleNote! :)\n Have fun reading it\n"[0..]);
    // try n.printRaw(stdout);
    // try n.save("/home/marek/Dokumenty/zig/my_examples/zad5 - note_app/example_note");

    // var n = try Note.load(allocator, "/home/marek/Dokumenty/zig/my_examples/zad5 - note_app/example_note");
    // try n.print(stdout);
    // n.free(allocator);

    // var nm = NoteManager.init(allocator, "/home/marek/Dokumenty/zig/my_examples/e5(note_app)/notes/");
    // defer nm.deinit();
    // try nm.loadNotes();
    // for (nm.notes) |note| {
    //     try note.print(stdout);
    // }
    //
    // const T = enum { one, two, three };
    // const a: type = T.one;
    // _ = a;
    //
    // std.debug.print("{any}\n", .{@TypeOf(T)});
    // std.debug.print("notes: {any} \n", .{nm.notes});
    var menu = try Menu.init(allocator);
    defer menu.deinit();
    // try menu.createMainOptions();
    try menu.start();
}
