import Dependencies_Test_Support
import Foundation
import Testing

@testable import LoggingExtras

@Suite
struct `Logging Extras Tests` {
    @Test
    func `Logger Dependency`() async throws {
        try await withDependencies { _ in
            // Logger should be automatically set to test value
        } operation: {
            @Dependency(\.logger) var logger

            // Test that we can access the logger
            logger.info("Test message")
            logger.debug("Debug message")
            logger.warning("Warning message")
            logger.error("Error message")

            // Test that the logger label includes the process name
            #expect(logger.label == ProcessInfo.processInfo.processName)
        }
    }

    @Test
    func `Custom Logger`() async throws {
        try await withDependencies {
            $0.logger = Logger(label: "com.test.custom")
        } operation: {
            @Dependency(\.logger) var logger

            #expect(logger.label == "com.test.custom")
            logger.info("Custom logger test")
        }
    }

    @Test
    func `Enhanced Logging`() async throws {
        try await withDependencies { _ in
            // Logger should be automatically set to test value
        } operation: {
            @Dependency(\.logger) var logger

            // Test the enhanced logging method with metadata
            logger.log(
                .info,
                "Test message with metadata",
                metadata: ["testKey": "testValue"]
            )

            // Test without additional metadata
            logger.log(.debug, "Debug message without extra metadata")
        }
    }

    @Test
    func `Logger Levels`() async throws {
        try await withDependencies { _ in
            // Logger should be automatically set to test value
        } operation: {
            @Dependency(\.logger) var logger

            // Test all log levels
            logger.trace("Trace level message")
            logger.debug("Debug level message")
            logger.info("Info level message")
            logger.notice("Notice level message")
            logger.warning("Warning level message")
            logger.error("Error level message")
            logger.critical("Critical level message")
        }
    }

    @Test
    func `Logger Metadata`() async throws {
        try await withDependencies { _ in
            // Logger should be automatically set to test value
        } operation: {
            @Dependency(\.logger) var logger

            // Test logging with various metadata types
            logger.log(
                .info,
                "Message with complex metadata",
                metadata: [
                    "string": "value",
                    "number": "42",
                    "boolean": "true",
                    "array": "[1, 2, 3]",
                ]
            )
        }
    }
}
