const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const result = try scanForEnabledLines("./input.txt", allocator);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Result: {d}\n", .{result});
}

fn scanForEnabledLines(file_path: []const u8, allocator: std.mem.Allocator) !i64 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buf = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(buf);

    var str = buf;
    var result: i64 = 0;
    while (std.mem.indexOf(u8, str, "don't()")) |pos| {
        result += scanForMulOperations(str[0..pos]);
        const end = std.mem.indexOf(u8, str[pos..], "do()") orelse str.len;
        str = str[pos + end ..];
    }
    result += scanForMulOperations(str);
    return result;
}

fn scanForMulOperations(buf: []const u8) i64 {
    var str = buf;
    var result: i64 = 0;

    while (std.mem.indexOf(u8, str, "mul(")) |start| {
        str = str[start + 4 ..];
        var pos = std.mem.indexOf(u8, str, ",") orelse continue;
        if (pos == str.len) break;
        const num1 = std.fmt.parseInt(i32, str[0..pos], 10) catch continue;

        str = str[pos + 1 ..];
        pos = std.mem.indexOf(u8, str, ")") orelse continue;
        if (pos == str.len) break;
        const num2 = std.fmt.parseInt(i32, str[0..pos], 10) catch continue;

        result += num1 * num2;
    }
    return result;
}
