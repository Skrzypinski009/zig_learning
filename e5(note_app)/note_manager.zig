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

    pub fn setPathNoteName(self: NoteManager, name: []u8) []u8 {
        var new_name: []u8 = try self.allocator.alloc(u8, name.len);
        for (name, 0..) |char, i| {
            if (std.ascii.isalphabetic(char) and std.ascii.isUpper(char)) {
                new_name[i] = std.ascii.lower(char);
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
            if (note.name == new_note.name) {
                return error.PathAlreadyExists;
            }
        }
        var dir = try std.fs.openDirAbsolute(self.notes_path, .{});
        defer dir.close();

        const path_name: []u8 = self.setPathNoteName(new_note.name);
        defer self.allocator.free(path_name);

        var file = dir.createFile(path_name, .{ .truncate = true });
        defer file.close();

        new_note.save(self.notes_path);
        self.addNote(new_note);
    }
};
