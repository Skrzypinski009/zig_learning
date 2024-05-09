const std = @import("std");
const Note = @import("note.zig").Note;

pub const NoteManager = struct {
    notes_path: []const u8,
    notes: []Note,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, notes_path: []const u8) NoteManager {
        return NoteManager{ .notes_path = notes_path, .notes = &.{}, .allocator = allocator };
    }

    pub fn deinit(self: NoteManager) void {
        for (self.notes) |*note| {
            note.free(self.allocator);
        }
        self.allocator.free(self.notes);
    }

    pub fn addNote(self: *NoteManager, new_note: Note) !void {
        self.notes = try self.allocator.realloc(self.notes, self.notes.len + 1);
        self.notes[self.notes.len - 1] = new_note;

        // var new_notes: []Note = try self.allocator.alloc(Note, self.notes.len + 1);
        // new_notes = self.notes;
        // for (self.notes, 0..) |note, i| {
        //     new_notes[i] = note;
        // }
        // new_notes[self.notes.len] = new_note;
        // self.allocator.free(self.notes);
        // self.notes = new_notes;
    }

    pub fn loadNotes(self: *NoteManager) !void {
        var dir = try std.fs.openDirAbsolute(self.notes_path, .{
            .iterate = true,
        });
        defer dir.close();
        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            // std.debug.print("- {any}:{s}\n", .{ entry.kind, entry.name });
            const file = try dir.openFile(entry.name, .{});
            defer file.close();
            const note = try Note.loadFromFile(self.allocator, file);
            try self.addNote(note);
        }
    }

    pub fn getNoteFileName(self: NoteManager, name: []u8) ![]u8 {
        var new_name: []u8 = try self.allocator.alloc(u8, name.len);
        for (name, 0..) |char, i| {
            if (std.ascii.isAlphabetic(char) and std.ascii.isUpper(char)) {
                new_name[i] = std.ascii.toLower(char);
            } else if (char == ' ') {
                new_name[i] = '_';
            } else {
                new_name[i] = char;
            }
        }
        return new_name;
    }

    pub fn createNote(self: *NoteManager, new_note: Note) !void {
        for (self.notes) |note| {
            if (std.mem.eql(u8, note.name, new_note.name)) {
                return error.PathAlreadyExists;
            }
        }
        var dir = try std.fs.openDirAbsolute(self.notes_path, .{});
        defer dir.close();

        const file_name: []u8 = try self.getNoteFileName(new_note.name);
        defer self.allocator.free(file_name);

        // var file = try dir.createFile(path_name, .{ .truncate = true });
        // defer file.close();

        try new_note.save(self.notes_path, file_name);
        try self.addNote(new_note);
    }
};
