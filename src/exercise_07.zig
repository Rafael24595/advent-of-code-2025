const std = @import("std");

const helper = @import("helper.zig");
const utils = @import("utils.zig");
const configuration = @import("configuration.zig");

const FilePath = "src/source/source_07_00.txt";

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 4.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const matrix = try helper.parseInputLines(alloc, FilePath);
    defer alloc.free(matrix);

    const start_ms = std.time.milliTimestamp();

    const result = try move(alloc, matrix);

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{result.@"0"});
    std.debug.print("Time : {s}\n\n", .{time});
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 4.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const matrix = try helper.parseInputLines(alloc, FilePath);
    defer alloc.free(matrix);

    const start_ms = std.time.milliTimestamp();

    const result = try move(alloc, matrix);

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{result.@"1"});
    std.debug.print("Time : {s}\n\n", .{time});
}

fn move(alloc: std.mem.Allocator, matrix: [][]u8) !struct { usize, i64 } {
    var timelines = try utils.defineMatrix(alloc, matrix.len, matrix[0].len);
    var total: usize = 0;

    for (0..matrix.len - 1) |y| {
        const next_y = y + 1;

        const row = matrix[y];
        for (row, 0..) |cell, x| {
            if (cell != 'S' and cell != '|') {
                continue;
            }

            var mult = timelines[y][x];
            if (mult == 0) {
                mult = 1;
            }

            if (matrix[next_y][x] == '^') {
                if (x >= 1) {
                    matrix[next_y][x - 1] = '|';
                    timelines[next_y][x - 1] += mult;
                }

                if (x + 1 < row.len) {
                    matrix[next_y][x + 1] = '|';
                    timelines[next_y][x + 1] += mult;
                }

                total += 1;
                continue;
            }

            if (matrix[next_y][x] == '.') {
                matrix[next_y][x] = '|';
            }

            timelines[next_y][x] += mult;
        }
    }

    helper.printMatrix(matrix);

    var time: i64 = 0;
    for (timelines[timelines.len - 1]) |v| {
        time += v;
    }

    return .{ total, time };
}
