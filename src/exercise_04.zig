const std = @import("std");

const helper = @import("helper.zig");
const utils = @import("utils.zig");
const configuration = @import("configuration.zig");

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 4.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const lines = try helper.parseInputLines(alloc, "src/source/source_04_01.txt");
    defer alloc.free(lines);

    try executeOneLoop(alloc, lines);
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 4.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const lines = try helper.parseInputLines(alloc, "src/source/source_04_01.txt");
    defer alloc.free(lines);

    try executeAllLoops(alloc, lines);
}

fn executeOneLoop(alloc: std.mem.Allocator, matrix: [][]u8) !void {
    var matrix_map = try utils.cloneMatrix(alloc, matrix);
    defer alloc.free(matrix_map);

    helper.printExp("\nInitial state:\n", .{});
    print_matrix(matrix);

    const start_ms = std.time.milliTimestamp();
    const total = execute_loop(matrix, &matrix_map, 1);
    const end_ms = std.time.milliTimestamp();

    helper.printExp("\n\nFinal state:\n", .{});
    print_matrix(matrix_map);

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn executeAllLoops(alloc: std.mem.Allocator, matrix: [][]u8) !void {
    var matrix_map = try utils.cloneMatrix(alloc, matrix);
    defer alloc.free(matrix_map);

    helper.printExp("\nInitial state:\n", .{});
    print_matrix(matrix);

    var matrix_cursor = matrix;

    var total: usize = 0;
    var total_loop: usize = 1;

    var count_ms: i64 = 0;

    var loops: usize = 0;
    while (total_loop != 0) {
        loops += 1;

        helper.printExp("\n Loop: {d}\n", .{loops});

        const start_ms = std.time.milliTimestamp();
        total_loop = execute_loop(matrix_cursor, &matrix_map, 1);
        const end_ms = std.time.milliTimestamp();

        count_ms += end_ms - start_ms;

        total += total_loop;
        matrix_cursor = matrix_map;

        helper.printExp("\n Loop {d} state:\n", .{loops});
        print_matrix(matrix_map);

        helper.printExp(" Loop total: {d}\n\n", .{total_loop});
    }

    const time = try utils.millisecondsToTime(alloc, count_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn execute_loop(matrix: [][]u8, matrix_map: *[][]u8, area: usize) usize {
    var total: usize = 0;
    for (matrix, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            helper.printExp("\n ---- Cell (x: {d}, y: {d}) '{c}' ----\n", .{ y, x, cell });

            if (cell != '@') {
                helper.printExp("\n  Skipping (not '@').\n", .{});
                continue;
            }

            const min_y = y -| area;
            const max_y = @min(matrix.len - 1, y + area);

            const min_x = x -| area;
            const max_x = @min(row.len - 1, x + area);

            helper.printExp("\n  Selection Limits: \n", .{});
            helper.printExp("   y: {d}..{d}\n", .{ min_y, max_y });
            helper.printExp("   x: {d}..{d}\n", .{ min_x, max_x });

            helper.printExp("\n  Selection Limits: \n\n", .{});

            var count: usize = 0;
            for (min_y..max_y + 1) |r| {
                helper.printExp("   {s}\n", .{matrix[r][min_x .. max_x + 1]});
                count += std.mem.count(u8, matrix[r][min_x .. max_x + 1], "@");
                if (count > 4) {
                    helper.printExp("\n  More than 4 neighbours found.\n", .{});
                    break;
                }
            }

            count -= 1;

            helper.printExp("\n  Neighbour count: {d}\n", .{count});

            if (count < 4) {
                matrix_map.*[y][x] = 'x';
                total += 1;
            }
        }
    }

    return total;
}

fn print_matrix(matrix: [][]u8) void {
    if (!configuration.explain) {
        return;
    }

    helper.printExp("\n", .{});
    for (matrix) |row| {
        helper.printExp(" {s}\n", .{row});
    }
    helper.printExp("\n", .{});
}
