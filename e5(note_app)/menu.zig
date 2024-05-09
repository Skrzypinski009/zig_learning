const std = @import("std");
const Note = @import("note.zig").Note;
const Options = @import("options.zig").Options;
const NoteManager = @import("note_manager.zig").NoteManager;

pub const Menu = struct {
    allocator: std.mem.Allocator,
    note_manager: NoteManager,

    create_note_options: Options,
    view_notes_options: Options,

    selected_note: usize = 0,

    const Views = enum {
        exit,
        main,
        create_note,
        view_notes,
        selected_note,
    };

    pub fn init(
        allocator: std.mem.Allocator,
    ) !Menu {
        const main_options = Options.init("New note;View notes"[0..], allocator);
        const create_note_options = Options.init("Set Name;Set time;Set tags;Set content;Submit;Go back"[0..], allocator);
        const view_notes_options = Options.init("New note;Select note;Change page;Exit"[0..], allocator);
        var note_manager: NoteManager = NoteManager.init(allocator, "/home/marek/Dokumenty/zig/my_examples/e5(note_app)/notes/");
        try note_manager.loadNotes();
        return Menu{
            .allocator = allocator,
            .note_manager = note_manager,
            .main_options = main_options,
            .create_note_options = create_note_options,
            .view_notes_options = view_notes_options,
        };
    }

    pub fn deinit(self: *Menu) void {
        self.main_options.deinit();
        self.create_note_options.deinit();
        self.note_manager.deinit();
    }

    pub fn start(self: *Menu) !void {
        const stdout = std.io.getStdOut().writer();
        const stdin = std.io.getStdIn().reader();

        var view: Views = Views.view_notes;
        while (view != Views.exit) {
            view = try self.startView(view, stdout, stdin);
        }
    }

    pub fn startView(self: *Menu, view: Views, writer: anytype, reader: anytype) !Views {
        return switch (view) {
            Views.create_note => try self.createNoteView(writer, reader),
            Views.view_notes => try self.viewNotesView(writer, reader),
            else => Views.exit,
        };
    }

    pub fn anyMenuView(self: Menu, writer: anytype, reader: anytype, options: Options) !u8 {
        var choice: u8 = 0;
        try options.print(writer);
        choice = try self.getCharInput(reader);
        return choice;
    }

    pub fn createNoteView(self: *Menu, writer: anytype, reader: anytype) !Views {
        var note: Note = Note{};
        var choice: u8 = 0;
        while (true) {
            try clearConsole(writer);
            try note.print(writer);
            choice = try self.anyMenuView(writer, reader, self.create_note_options);
            switch (choice) {
                1...4 => {
                    const input = try self.getInput(reader);
                    switch (choice) {
                        1 => note.name = input,
                        2 => note.timestamp = time: {
                            const timestamp_int = try std.fmt.parseInt(i64, input, 10);
                            self.allocator.free(input);
                            break :time timestamp_int;
                        },
                        3 => note.tags = input,
                        4 => note.content = input,
                        else => {},
                    }
                },
                5 => {
                    if (note.isGood()) {
                        if (self.note_manager.createNote(note)) {
                            return Views.view_notes;
                        } else |err| {
                            try writer.print("Can't create note\n", .{});
                            try writer.print("Error: {}\n", .{err});
                            std.posix.nanosleep(2, 0);
                        }
                    } else {
                        std.debug.print("Fill all fields to create a note!", .{});
                        std.posix.nanosleep(2, 0);
                    }
                },
                6 => return Views.view_notes,
                else => {},
            }
        }
        unreachable;
    }

    pub fn viewNotesView(self: *Menu, writer: anytype, reader: anytype) !Views {
        var page: usize = 0;
        var max_page: usize = self.note_manager.notes.len / 3;
        if (self.note_manager.notes.len % 3 > 0) max_page += 1;

        var note_idx: usize = 0;
        const line = "------------------\n";
        var choice: u8 = 0;
        var end_idx: usize = 0;

        while (true) {
            // printing notes
            note_idx = page * 3;
            try clearConsole(writer);
            const next_notes_len: usize = self.note_manager.notes.len;
            end_idx = minUsize(next_notes_len - note_idx, 3);
            for (0..end_idx) |i| {
                try writer.print(line, .{});
                try self.note_manager.notes[note_idx + i].print(writer);
            }
            try writer.print(line, .{});
            try writer.print("   1..<{d}>..{d}\n", .{ page + 1, max_page });

            // printing menu and getting choice
            choice = try self.anyMenuView(writer, reader, self.view_notes_options);
            switch (choice) {
                1 => {
                    return Views.create_note;
                },
                // selecting note
                2 => {
                    try writer.print("Enter the name of note: ", .{});
                    const input = try self.getInput(reader);
                    defer self.allocator.free(input);
                    for (self.note_manager.notes, 0..) |note, i| {
                        if (std.mem.eql(u8, note.name, input)) {
                            self.selected_note = i;
                            return Views.selected_note;
                        }
                    }
                    try writer.print("There is no note with that name!\n", .{});
                    std.posix.nanosleep(1, 0);
                },
                // changeing page
                3 => {
                    try writer.print("Enter the page number: ", .{});
                    const page_choice = try self.getCharInput(reader);
                    if (page_choice - 1 <= max_page) {
                        page = page_choice - 1;
                    } else {
                        try writer.print("There is no page {d}!\n", .{page_choice});
                        std.posix.nanosleep(1, 0);
                    }
                },
                // exit
                4 => return Views.exit,
                else => {},
            }
        }
    }

    pub fn getInput(self: Menu, reader: anytype) ![]u8 {
        const buff: []u8 = try self.allocator.alloc(u8, 64);
        defer self.allocator.free(buff);
        if (try reader.readUntilDelimiterOrEof(buff, '\n')) |input| {
            const input_len = if (input.len == 0) 1 else input.len;
            const inp: []u8 = try self.allocator.alloc(u8, input_len);

            std.mem.copyForwards(u8, inp, if (input.len == 0) " " else input);
            return inp;
        }
        unreachable;
    }

    pub fn getCharInput(self: Menu, reader: anytype) !u8 {
        const input: []u8 = try self.getInput(reader);
        defer self.allocator.free(input);
        if (std.fmt.parseInt(u8, input[0..1], 10)) |choice| {
            return choice;
        } else |_| {
            return 0;
        }
        unreachable;
    }

    pub fn clearConsole(writer: anytype) !void {
        try writer.print("\x1B[2J\x1B[H", .{});
    }

    pub fn minUsize(a: usize, b: usize) usize {
        return if (a < b) a else b;
    }
};
