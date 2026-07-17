//
//  ConsoleLogHandler Tests.swift
//  swift-logging-extras
//
//  Created by Coen ten Thije Boonkkamp on 23/07/2025.
//

import Foundation
import Logging
import Testing

@testable import LoggingExtras

@Suite
struct Test {

    @Test
    func `Console Log Handler formats levels correctly`() {
        let handler = ConsoleLogHandler(label: "test")

        let levels: [Logger.Level] = [.trace, .debug, .info, .notice, .warning, .error, .critical]
        let expectedFormats = ["TRACE", "DEBUG", "INFO ", "NOTCE", "WARN ", "ERROR", "CRIT "]

        for (level, expected) in zip(levels, expectedFormats) {
            #expect(level.formatted == expected)
        }
    }

    @Test
    func `Console Log Handler initializes with correct defaults`() {
        let handler = ConsoleLogHandler(label: "test-label")

        #expect(handler.logLevel == .info)
        #expect(handler.metadataProvider == nil)
        #expect(handler.metadata.isEmpty)
    }

    @Test
    func `Console Log Handler initializes with custom values`() {
        let metadataProvider = Logger.MetadataProvider { ["custom": "value"] }
        let handler = ConsoleLogHandler(
            label: "custom-label",
            logLevel: .debug,
            metadataProvider: metadataProvider
        )

        #expect(handler.logLevel == .debug)
        #expect(handler.metadataProvider != nil)
    }

    @Test
    func `Console Log Handler manages metadata correctly`() {
        var handler = ConsoleLogHandler(label: "test")

        #expect(handler.metadata.isEmpty)

        handler.metadata = ["key1": "value1"]
        #expect(handler.metadata["key1"] == "value1")

        handler[metadataKey: "key2"] = "value2"
        #expect(handler[metadataKey: "key2"] == "value2")

        handler[metadataKey: "key1"] = nil
        #expect(handler[metadataKey: "key1"] == nil)
        #expect(handler.metadata.count == 1)
    }

    @Test
    func `Date Formatter log produces ISO8601 format`() {
        let formatter = DateFormatter.log
        let date = Date(timeIntervalSince1970: 1234567890.123)

        let formatted = formatter.string(from: date)
        #expect(formatted == "2009-02-13T23:31:30.123Z")
    }

    @Test
    func `Date Formatter log uses UTC timezone`() {
        let formatter = DateFormatter.log
        #expect(formatter.timeZone == TimeZone(secondsFromGMT: 0))
    }

    @Test
    func `Date Formatter log uses POSIX locale`() {
        let formatter = DateFormatter.log
        #expect(formatter.locale == Locale(identifier: "en_US_POSIX"))
    }
}
