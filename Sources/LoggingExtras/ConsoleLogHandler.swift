//
//  ConsoleLogHandler.swift
//  swift-logging-extras
//
//  A DispatchQueue-serialised, DateFormatter-formatted console (stderr)
//  LogHandler. Moved from swift-server-foundation (decomposition W3, C4)
//  and renamed to the package's handler idiom (File/Multiplex/Console).
//

import Foundation
import Logging

public struct ConsoleLogHandler: Logging.LogHandler {
    private let label: String
    private let queue: DispatchQueue
    private let dateFormatter: DateFormatter

    public var logLevel: Logger.Level
    public var metadataProvider: Logger.MetadataProvider?

    private var _metadata: Logger.Metadata
    public var metadata: Logger.Metadata {
        get { queue.sync { _metadata } }
        set { queue.sync { _metadata = newValue } }
    }

    public init(
        label: String,
        logLevel: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.label = label
        self.logLevel = logLevel
        self.metadataProvider = metadataProvider
        self._metadata = [:]
        self.queue = DispatchQueue(label: label)
        self.dateFormatter = .log
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { queue.sync { _metadata[metadataKey] } }
        set { queue.sync { _metadata[metadataKey] = newValue } }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata explicitMetadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        queue.sync {
            let timestamp = dateFormatter.string(from: Date())
            let mergedMetadata = self.mergedMetadata(explicitMetadata)
            let components = [
                timestamp,
                level.formatted,
                "[\(source):\(line)]",
                message.description,
                mergedMetadata,
            ].compactMap { $0 }

            let fullMessage = components.joined(separator: " | ")
            FileHandle.standardError.write(Data((fullMessage + "\n").utf8))
        }
    }

    private func mergedMetadata(_ explicitMetadata: Logger.Metadata?) -> String? {
        var metadata = _metadata

        if let provided = metadataProvider?.get(), !provided.isEmpty {
            metadata.merge(provided) { _, new in new }
        }

        if let explicit = explicitMetadata, !explicit.isEmpty {
            metadata.merge(explicit) { _, new in new }
        }

        guard !metadata.isEmpty else { return nil }

        return
            metadata
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ", ")
    }
}

extension Logger.Level {
    public var formatted: String {
        switch self {
        case .trace: return "TRACE"
        case .debug: return "DEBUG"
        case .info: return "INFO "
        case .notice: return "NOTCE"
        case .warning: return "WARN "
        case .error: return "ERROR"
        case .critical: return "CRIT "
        }
    }
}

extension DateFormatter {
    static let log: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
