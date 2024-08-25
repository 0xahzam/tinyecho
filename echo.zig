const std = @import("std");
const net = std.net;

pub fn main() !void {
    const address = "127.0.0.1";
    const port = 3000;

    const ip = try net.Address.resolveIp(address, port);

    var listener = try ip.listen(.{ .reuse_address = true });

    std.debug.print("Listening on {s}:{d}\n", .{ address, port });

    while (true) {
        const conn = listener.accept() catch |err| {
            std.debug.print("Error accepting connection: {}\n", .{err});
            continue;
        };

        const incoming = conn.address;
        std.debug.print("Connection from {}\n", .{incoming});

        var buffer: [1024]u8 = undefined;
        while (true) {
            const bytes_read = try conn.stream.read(&buffer);
            if (bytes_read == 0) break;

            std.debug.print("Received: {s}\n", .{buffer[0..bytes_read]});

            _ = conn.stream.write(buffer[0..bytes_read]) catch |err| {
                std.debug.print("Error writing to connection: {}\n", .{err});
                break;
            };
        }
    }
}
