const std = @import("std");

const use_dampener = true;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const safe_levels = try readNumberOfSafeLevels("./input.txt", allocator, use_dampener);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Safe levels: {d}\n", .{safe_levels});
}

fn readNumberOfSafeLevels(file_path: []const u8, allocator: std.mem.Allocator, dampen: bool) !u32 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size + 1);
    defer allocator.free(buffer);

    var safe_levels: u32 = 0;
    while (try file.reader().readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var levels = std.ArrayList(i32).init(allocator);
        defer levels.deinit();

        var it = std.mem.split(u8, line, " ");
        while (it.next()) |level| {
            try levels.append(try std.fmt.parseInt(i32, level, 10));
        }

        if (areLevelsSafe(levels.items)) {
            safe_levels += 1;
        } else if (dampen) {
            for (0..levels.items.len) |index| {
                var tmp = try levels.clone();
                defer tmp.deinit();
                _ = tmp.orderedRemove(index);
                if (areLevelsSafe(tmp.items)) {
                    std.debug.print("recovered with dampen on line {s}\n", .{line});
                    safe_levels += 1;
                    break;
                }
            }
        }
    }
    return safe_levels;
}

fn areLevelsSafe(levels: []const i32) bool {
    const Direction = enum {
        unknown,
        up,
        down,
    };
    var direction = Direction.unknown;
    var last = levels[0];

    for (levels[1..]) |level| {
        switch (direction) {
            Direction.unknown => {
                if (level > last) {
                    direction = Direction.up;
                } else {
                    direction = Direction.down;
                }
            },
            Direction.up => {
                if (level < last) {
                    return false;
                }
            },
            Direction.down => {
                if (level > last) {
                    return false;
                }
            },
        }

        const distance = abs(level - last);
        if (distance == 0 or distance > 3) {
            return false;
        }
        last = level;
    }
    return true;
}

fn abs(x: i32) i32 {
    if (x < 0) {
        return -x;
    }
    return x;
}
