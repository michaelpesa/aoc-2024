const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const result = try wordSearch("./input.txt", allocator, checkForMAS);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Count: {d}\n", .{result});
}

fn checkForXMAS(lines: []const []const u8) u32 {
    var found: u32 = 0;
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != 'X') continue;
            // Search for XMAS in this line, forward and backwards.
            if ((j + 4) <= line.len and std.mem.eql(u8, line[j .. j + 4], "XMAS")) {
                found += 1;
            }
            if (j >= 3 and std.mem.eql(u8, line[j - 3 .. j + 1], "SAMX")) {
                found += 1;
            }

            // Check down vertically and horizontally.
            if ((i + 4) <= lines.len) {
                const line1 = lines[i + 1];
                const line2 = lines[i + 2];
                const line3 = lines[i + 3];
                if (isXMAS(c, line1[j], line2[j], line3[j])) {
                    found += 1;
                }
                if ((j + 4) <= line.len) {
                    if (isXMAS(c, line1[j + 1], line2[j + 2], line3[j + 3])) {
                        found += 1;
                    }
                }
                if (j >= 3) {
                    if (isXMAS(c, line1[j - 1], line2[j - 2], line3[j - 3])) {
                        found += 1;
                    }
                }
            }
            if (i >= 3) {
                const line1 = lines[i - 1];
                const line2 = lines[i - 2];
                const line3 = lines[i - 3];
                if (isXMAS(c, line1[j], line2[j], line3[j])) {
                    found += 1;
                }
                if ((j + 4) <= line.len) {
                    if (isXMAS(c, line1[j + 1], line2[j + 2], line3[j + 3])) {
                        found += 1;
                    }
                }
                if (j >= 3) {
                    if (isXMAS(c, line1[j - 1], line2[j - 2], line3[j - 3])) {
                        found += 1;
                    }
                }
            }
        }
    }
    return found;
}

fn checkForMAS(lines: []const []const u8) u32 {
    var found: u32 = 0;
    for (lines, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != 'A') continue;
            if (i == 0 or (i + 1) >= lines.len) continue;
            if (j == 0 or (j + 1) >= line.len) continue;

            const p1 = lines[i - 1][j - 1];
            const p2 = lines[i - 1][j + 1];
            const n1 = lines[i + 1][j - 1];
            const n2 = lines[i + 1][j + 1];

            if ((p1 == 'M' and n2 == 'S' and p2 == 'M' and n1 == 'S') or
                (p1 == 'M' and n2 == 'S' and p2 == 'S' and n1 == 'M') or
                (p1 == 'S' and n2 == 'M' and p2 == 'M' and n1 == 'S') or
                (p1 == 'S' and n2 == 'M' and p2 == 'S' and n1 == 'M'))
            {
                found += 1;
            }
        }
    }
    return found;
}

fn wordSearch(file_path: []const u8, allocator: std.mem.Allocator, check: fn ([]const []const u8) u32) !u32 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buf = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(buf);

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var str = buf;
    while (std.mem.indexOf(u8, str, "\n")) |pos| {
        try lines.append(str[0..pos]);
        str = str[pos + 1 ..];
    }
    return check(lines.items);
}

fn isXMAS(c1: u8, c2: u8, c3: u8, c4: u8) bool {
    return c1 == 'X' and c2 == 'M' and c3 == 'A' and c4 == 'S';
}
