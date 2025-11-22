const std = @import("std");

const Date = struct {
    year: u16,
    month: u8,
    day: u8,
};

pub fn get_actual_date(buffer: []u8) void {
    const now_sec = std.time.timestamp();
    const d = timestamp_to_date(now_sec);

    _ = std.fmt.bufPrint(buffer, "{d:0>4}-{d:0>2}-{d:0>2}", .{ d.year, d.month, d.day }) catch {
        //
    };
}

fn timestamp_to_date(ts: i64) Date {
    const days: i64 = @divFloor(ts, 86400);

    const z = days + 719468;
    const era: i64 = @divFloor(z, 146097);
    const doe = z - era * 146097;
    const yoe: i64 = @divFloor(doe - @divFloor(doe, 1460) + @divFloor(doe, 36524) - @divFloor(doe, 146096), 365);
    const y = yoe + era * 400;
    const doy: i64 = doe - (365 * yoe + @divFloor(yoe, 4) - @divFloor(yoe, 100));
    const mp: i64 = @divFloor(5 * doy + 2, 153);
    const d: i64 = doy - @divFloor(153 * mp + 2, 5) + 1;
    const m: u8 = @intCast(mp + (if (mp < 10) @as(i64, 3) else @as(i64, -9)));

    return Date{
        .year = @intCast(y + (if (m <= 2) @as(i64, 1) else @as(i64, 0))),
        .month = m,
        .day = @intCast(d),
    };
}
