import Foundation
import OSLog

/// Small rotating local diagnostic log; contains status and screen geometry only.
enum RelocationLog {
    private static let lock = NSLock()
    private static let logger = Logger(subsystem: "bwyatt.DockAnchor", category: "Relocation")
    static func write(_ message: String) {
        logger.notice("\(message, privacy: .public)")
        lock.lock()
        defer { lock.unlock() }
        do {
            let directory = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Logs/DockAnchor", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let file = directory.appendingPathComponent("relocation.log")
            if let size = (try? FileManager.default.attributesOfItem(atPath: file.path)[.size]) as? NSNumber,
               size.intValue > 1_000_000 {
                let previous = directory.appendingPathComponent("relocation.previous.log")
                if FileManager.default.fileExists(atPath: previous.path) { try FileManager.default.removeItem(at: previous) }
                try FileManager.default.moveItem(at: file, to: previous)
            }
            if !FileManager.default.fileExists(atPath: file.path) {
                FileManager.default.createFile(atPath: file.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: file)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: Data("\(ISO8601DateFormatter().string(from: Date())) \(message)\n".utf8))
        } catch {
            logger.error("Unable to write relocation log: \(error.localizedDescription, privacy: .public)")
        }
    }
}
