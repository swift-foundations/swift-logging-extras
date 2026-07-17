// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-logger-handlers open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-logger-handlers
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Foundation
import Logger_Handlers
import Logging
import Testing

@testable import Logger_Handlers_Foundation_Integration

@Suite
struct `Logger.Handler.File Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Logger.Handler.File Tests`.Unit {
    @Test
    func `initialization supplies handler defaults`() {
        let directory = FileManager.default.temporaryDirectory.appending(
            path: UUID().uuidString
        )
        let url = directory.appending(path: "unit.log")
        defer { try? FileManager.default.removeItem(at: directory) }

        guard let handler = try? Logger.Handler.File(label: "tests", url: url) else {
            Issue.record("expected file handler initialization to succeed")
            return
        }

        #expect(handler.logLevel == .info)
        #expect(handler.metadataProvider == nil)
        #expect(handler.metadata.isEmpty)
    }
}

extension `Logger.Handler.File Tests`.`Edge Case` {
    @Test
    func `invalid parent path throws a Cocoa error`() {
        #expect(throws: CocoaError.self) {
            try Logger.Handler.File(
                label: "tests",
                url: URL(fileURLWithPath: "/dev/null/log-handler-tests.log")
            )
        }
    }
}

extension `Logger.Handler.File Tests`.Integration {
    @Test
    func `record is appended with merged metadata`() {
        let directory = FileManager.default.temporaryDirectory.appending(
            path: UUID().uuidString
        )
        let url = directory.appending(path: "integration.log")
        defer { try? FileManager.default.removeItem(at: directory) }

        guard
            var handler = try? Logger.Handler.File(
                label: "tests",
                url: url,
                metadataProvider: Logger.MetadataProvider { ["provider": "yes"] }
            )
        else {
            Issue.record("expected file handler initialization to succeed")
            return
        }

        handler.metadata = ["stored": "yes"]
        handler.log(
            event: LogEvent(
                level: .info,
                message: "persisted",
                metadata: ["explicit": "yes"],
                source: "tests",
                file: "Tests.swift",
                function: "test",
                line: 42
            )
        )

        guard let output = try? String(contentsOf: url, encoding: .utf8) else {
            Issue.record("expected file handler output to be readable")
            return
        }

        #expect(output.contains("[INFO ] persisted"))
        #expect(output.contains("explicit=yes, provider=yes, stored=yes"))
    }
}
