const std = @import("std");
const Note = @import("note.zig").Note;
const Options = @import("options.zig").Options;

pub const Menu = struct {
    const Views = enum {
        exit,
        main,
        create_note,
        view_notes,
    };

    allocator: std.mem.Allocator,
    main_options: Options,
    create_note_options: Options,

    pub fn init(
        allocator: std.mem.Allocator,
    ) Menu {
        const main_options = Options.init("New note;View notes"[0..], allocator);
        const create_note_options = Options.init("Set Name;Set time"[0..], allocator);
        const m = Menu{
            .allocator = allocator,
            .main_options = main_options,
            .create_note_options = create_note_options,
        };
        return m;
    }

    pub fn deinit(self: *Menu) void {
        self.main_options.deinit();
        self.create_note_options.deinit();
    }

    pub fn start(self: Menu) !void {
        const stdout = std.io.getStdOut().writer();
        const stdin = std.io.getStdIn().reader();

        // printOptions(stdout, self.test_options.*);

        var view: Views = Views.main;
        while (view != Views.exit) {
            view = self.startView(view, stdout, stdin);
        }
    }

    // pub fn getOptionsByView(self: Menu, view: Views) ?[][]u8 {
    //     return switch (view) {
    //         Views.main => self.main_options,
    //         else => null,
    //     };
    // }

    pub fn anyMenuView(self: Menu, writer: anytype, reader: anytype, options: Options) !u8 {
        var choice: u8 = 0;
        try options.print(writer);
        choice = try self.getCharInput(reader);
        return choice;
    }

    pub fn mainMenuView(self: Menu, writer: anytype, reader: anytype) !Views {
        try clearConsole(writer);
        const choice: u8 = try self.anyMenuView(writer, reader, self.main_options);
        return switch (choice) {
            1 => Views.create_note,
            2 => Views.view_notes,
            else => Views.main,
        };
    }

    // pub fn createNoteView(self: Menu, writer: anytype, reader: anytype) !Views {
    //     clearConsole(writer);
    //     var note: Note = Note{};
    //     note.print(writer);

    //     const choice: u8 = try self.anyMenuView(writer, reader, self.create_note_options);
    // }

    pub fn startView(self: Menu, view: Views, writer: anytype, reader: anytype) Views {
        return switch (view) {
            Views.main => self.mainMenuView(writer, reader) catch Views.exit,
            else => Views.exit,
        };
    }

    pub fn getInput(self: Menu, reader: anytype) ![]u8 {
        const buff: []u8 = try self.allocator.alloc(u8, 64);
        defer self.allocator.free(buff);
        if (try reader.readUntilDelimiterOrEof(buff, '\n')) |input| {
            const inp: []u8 = try self.allocator.alloc(u8, input.len);
            std.mem.copyForwards(u8, inp, input);
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

    // MAIN  OPTIONS
    // pub fn createMainOptions(self: *Menu) !void {
    //     const op1_arr = "Create new note";
    //     const op2_arr = "View notes";

    //     const op1 = try self.allocator.alloc(u8, op1_arr.len);
    //     const op2 = try self.allocator.alloc(u8, op2_arr.len);

    //     self.main_options = try self.allocator.alloc([]u8, 2);
    //     std.mem.copyForwards(u8, op1, op1_arr);
    //     std.mem.copyForwards(u8, op2, op2_arr);
    //     self.main_options[0] = op1;
    //     self.main_options[1] = op2;
    // }

    // pub fn createCreateNoteOptions(self: *Menu) !void {
    //     const op1_arr = "Set name";
    //     const op2_arr = "Set date";
    //     const op3_arr = "Set tags";
    //     const op4_arr = "Set content";

    //     const op1 = try self.allocator.alloc(u8, op1_arr.len);
    //     const op2 = try self.allocator.alloc(u8, op2_arr.len);
    //     const op3 = try self.allocator.alloc(u8, op3_arr.len);
    //     const op4 = try self.allocator.alloc(u8, op4_arr.len);

    //     self.create_note_options = try self.allocator.alloc([]u8, 2);
    //     std.mem.copyForwards(u8, op1, op1_arr);
    //     std.mem.copyForwards(u8, op2, op2_arr);
    //     std.mem.copyForwards(u8, op3, op3_arr);
    //     std.mem.copyForwards(u8, op4, op4_arr);
    //     self.main_options[0] = op1;
    //     self.main_options[1] = op2;
    //     self.main_options[2] = op3;
    //     self.main_options[3] = op4;
    // }

    // pub fn destroyMainOptions(self: *Menu) void {
    //     for (self.main_options) |option| {
    //         self.allocator.free(option);
    //     }
    //     self.allocator.free(self.main_options);
    // }

    pub fn clearConsole(writer: anytype) !void {
        try writer.print("\x1B[2J\x1B[H", .{});
    }
};
