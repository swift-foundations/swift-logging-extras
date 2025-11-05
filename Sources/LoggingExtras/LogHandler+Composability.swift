//
//  LogHandler+Composability.swift
//  swift-logging-extras
//
//  Composability extensions for LogHandler
//

import Foundation
import Logging

/// Combine two log handlers into a multiplexed handler that sends logs to both
///
/// Example:
/// ```swift
/// let consoleHandler = StreamLogHandler.standardOutput(label: "app")
/// let fileHandler = try FileLogHandler(label: "app", logFileURL: logFile)
/// let combined = consoleHandler + fileHandler
///
/// let logger = Logger(label: "app") { _ in combined }
/// logger.info("Goes to both console and file")
/// ```
public func + (lhs: any LogHandler, rhs: any LogHandler) -> any LogHandler {
    MultiplexLogHandler([lhs, rhs])
}
