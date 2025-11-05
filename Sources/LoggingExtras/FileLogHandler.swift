//
//  FileLogHandler.swift
//  swift-logging-extras
//
//  A simple LogHandler that writes log messages to a file
//

import Foundation
import Logging

/// A simple LogHandler that writes log messages to a file
///
/// Useful for test logging where you want to persist output even if the process crashes.
///
/// Example usage with MultiplexLogHandler for dual output:
/// ```swift
/// let fileHandler = try FileLogHandler(label: "test", logFileURL: logFile)
/// let logger = Logger(label: "test") { _ in
///     existingHandler + fileHandler
/// }
/// logger.info("Logged to both console and file")
/// ```
public struct FileLogHandler: LogHandler {
    private let fileHandle: FileHandle
    private let logFileURL: URL
    private let label: String

    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .info

    /// Create a FileLogHandler that writes to the specified file
    ///
    /// - Parameters:
    ///   - label: The logger label
    ///   - logFileURL: The file URL to write logs to. Parent directories will be created if needed.
    /// - Throws: If file cannot be created or opened for writing
    public init(label: String, logFileURL: URL) throws {
        self.label = label
        self.logFileURL = logFileURL

        // Create parent directory if needed
        try FileManager.default.createDirectory(
            at: logFileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // Create or append to file
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }

        self.fileHandle = try FileHandle(forWritingTo: logFileURL)
        self.fileHandle.seekToEndOfFile()
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        // Format timestamp as readable time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())

        let levelStr = level.rawValue.uppercased().padding(toLength: 5, withPad: " ", startingAt: 0)

        var logLine = "\(timestamp) [\(levelStr)] \(message)"

        // Add metadata if present - format as key=value pairs
        if let metadata = metadata, !metadata.isEmpty {
            let sortedMetadata = metadata.sorted { $0.key < $1.key }
            let metadataStr = sortedMetadata.map { key, value in
                // Format the value nicely
                let valueStr = "\(value)".replacingOccurrences(of: "\"", with: "")
                return "\(key)=\(valueStr)"
            }.joined(separator: ", ")
            logLine += " → \(metadataStr)"
        }

        logLine += "\n"

        if let data = logLine.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
}
