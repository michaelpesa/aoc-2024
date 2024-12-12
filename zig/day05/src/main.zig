const std = @import("std");

const use_dampener = true;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const result = try readPageOrderingRules("./input.txt", allocator, use_dampener);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Result: {d}\n", .{result});
}

fn readPageOrderingRules(file_path: []const u8, allocator: std.mem.Allocator) !u32 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buf = file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(buf);

    const lines = std.mem.count(u8, buf, "\n");
    var graph = Graph.init(&allocator, lines + 1);
    var queue = std.ArrayList(Node);

    for (std.mem.split(u8, buf, "\n")) |line| {
        const index = std.mem.indexOf(u8, line, "|") orelse continue;
        const from = try std.fmt.parseInt(u32, line[0..index], 10);
        const to = try std.fmt.parseInt(u32, line[index + 1 ..], 10);
        graph.addEdge(from, to);
    }

    for (0.., graph.edges) |index, edge_list| {
        if (edge_list.len == 0) {
            queue.append(index);
        }
    }

    while (queue.len != 0) {}

    return 0;
}

const Node = u32;

const Graph = struct {
    edges: []const []Node,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator, node_count: usize) !Graph {
        const edges = try allocator.alloc([]Node, node_count);
        for (edges) |edge_list| {
            edge_list.* = &[]Node;
        }
        return Graph{
            .edges = edges,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Graph) void {
        for (self.edges) |edge_list| {
            self.allocator.free(edge_list);
        }
        self.allocator.free(self.edges);
    }

    pub fn addEdge(self: *Graph, from: Node, to: Node) !void {
        const current_edges = self.edges[from];
        const new_length = current_edges.len + 1;
        const new_list = try self.allocator.realloc(current_edges, current_edges.len, new_length);
        self.edges[from] = new_list;
        self.edges[from][current_edges.len] = to;
    }
};
