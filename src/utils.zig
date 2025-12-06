const std = @import("std");

pub const TimeUnit = struct {
    label: []const u8,
    time: i64,
};

pub const Millisecond: TimeUnit = .{ .label = "ms", .time = 1 };
pub const Second: TimeUnit = .{ .label = "s", .time = 1000 };
pub const Minute: TimeUnit = .{ .label = "m", .time = Second.time * 60 };
pub const Hour: TimeUnit = .{ .label = "h", .time = Minute.time * 60 };
pub const Day: TimeUnit = .{ .label = "d", .time = Hour.time * 24 };
pub const Year: TimeUnit = .{ .label = "y", .time = Day.time * 365 };

const TimeUnits: [6]TimeUnit = .{ Year, Day, Hour, Minute, Second, Millisecond };

pub fn millisecondsToTime(alloc: std.mem.Allocator, ms: i64, limit: ?TimeUnit) ![]const u8 {
    var buffer = try std.ArrayList(u8).initCapacity(alloc, 0);

    var fix_ms = ms;
    for (TimeUnits) |unit| {
        if (limit != null and std.mem.eql(u8, unit.label, limit.?.label)) {
            break;
        }

        const amount = @divFloor(fix_ms, unit.time);
        if (amount > 0 or buffer.capacity > 0 or std.mem.eql(u8, unit.label, "ms")) {
            const time = try std.fmt.allocPrint(alloc, "{d}{s} ", .{ amount, unit.label });
            try buffer.appendSlice(alloc, time);
        }

        fix_ms = @mod(fix_ms, unit.time);
    }

    return std.mem.trim(u8, buffer.items, " \n\t\r");
}

pub fn cloneMatrix(allocator: std.mem.Allocator, matrix: [][] u8) ![][]u8 {
    var clone = try allocator.alloc([]u8, matrix.len);

    for (matrix, 0..) |row, i| {
        clone[i] = try allocator.dupe(u8, row);
    }

    return clone;
}

pub fn transposeMatrix(allocator: std.mem.Allocator, matrix: [][]i64) ![][]i64 {
    const m_len = matrix.len;
    const r_len = matrix[0].len;

    var flat = try allocator.alloc(i64, m_len * r_len);

    var transposed = try allocator.alloc([]i64, r_len);
    for (0..r_len) |i| {
        transposed[i] = flat[i * m_len .. i * m_len + m_len];
    }

    for (0..m_len) |i| {
        for (0..r_len) |j| {
            transposed[j][i] = matrix[i][j];
        }
    }

    return transposed;
}