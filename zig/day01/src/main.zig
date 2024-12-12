const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const numbers = try readNumbers("./input.txt", allocator);
    defer {
        numbers[0].deinit();
        numbers[1].deinit();
    }

    const total_distance = calculateTotalDistance(numbers[0].items, numbers[1].items);
    const similarity_score = calculateSimilarityScore(numbers[0].items, numbers[1].items);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Total distance: {d}\n", .{total_distance});
    try stdout.print("Similarity score: {d}\n", .{similarity_score});
}

fn abs(x: i32) i32 {
    if (x < 0) {
        return -x;
    }
    return x;
}

fn binarySearch(buf: []const i32, target: i32) ?usize {
    var low: usize = 0;
    var high: usize = buf.len;
    while (low < high) {
        const mid = low + (high - low) / 2;
        if (buf[mid] == target) {
            return mid;
        } else if (buf[mid] < target) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return null;
}

fn countOf(buf: []const i32, target: i32) i32 {
    const middle = binarySearch(buf, target) orelse return 0;
    var count: i32 = 1;
    var index = middle;
    while (index > 0 and buf[index - 1] == target) {
        count += 1;
        index -= 1;
    }
    index = middle + 1;
    while (index < buf.len and buf[index] == target) {
        count += 1;
        index += 1;
    }
    return count;
}

fn readNumbers(file_path: []const u8, allocator: std.mem.Allocator) !struct { std.ArrayList(i32), std.ArrayList(i32) } {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size + 1);
    defer allocator.free(buffer);

    var list1 = std.ArrayList(i32).init(allocator);
    var list2 = std.ArrayList(i32).init(allocator);

    while (try file.reader().readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var it = std.mem.split(u8, line, "   ");
        const num1 = try std.fmt.parseInt(i32, it.next().?, 10);
        const num2 = try std.fmt.parseInt(i32, it.next().?, 10);
        try list1.append(num1);
        try list2.append(num2);
    }

    std.mem.sort(i32, list1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, comptime std.sort.asc(i32));
    return .{ list1, list2 };
}

fn calculateTotalDistance(list1: []const i32, list2: []const i32) i64 {
    var distance: i64 = 0;
    for (list1, list2) |x, y| {
        distance += abs(x - y);
    }
    return distance;
}

fn calculateSimilarityScore(list1: []const i32, list2: []const i32) i64 {
    var score: i64 = 0;
    for (list1, list2) |x, _| {
        const occurrences = countOf(list2, x);
        score += x * occurrences;
    }
    return score;
}
