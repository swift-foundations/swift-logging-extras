import Dependencies
import Dependencies_Test_Support
import Foundation
import Logging
import Testing

@testable import LoggingExtras

@Suite
struct Test {

    @Test
    func `Quick Start Example (README lines 47-60)`() {
        struct MyFeature {
            @Dependency(\.logger) var logger

            func doSomething() {
                logger.info("Starting operation")
                // ... your code ...
                logger.debug("Operation completed")
            }
        }

        let feature = MyFeature()
        feature.doSomething()
    }

    @Test
    func `Basic Usage with Dependencies (README lines 68-81)`() {
        struct MyService {
            @Dependency(\.logger) var logger

            func performTask() {
                logger.info("Task started")
                logger.debug("Processing...")
                logger.notice("Task completed")
            }
        }

        let service = MyService()
        service.performTask()
    }

    @Test
    func `Test Usage Example (README lines 88-101)`() async throws {
        try await withDependencies { _ in
            // Logger is automatically set to test value
        } operation: {
            @Dependency(\.logger) var logger
            logger.info("Test message")  // Will include process name
        }
    }

    @Test
    func `Custom Logger Configuration (README lines 108-121)`() async throws {
        try await withDependencies {
            $0.logger = Logger(label: "com.example.myapp.feature")
        } operation: {
            @Dependency(\.logger) var logger
            logger.info("Using custom logger")

            // Verify the custom logger label is used
            #expect(logger.label == "com.example.myapp.feature")
        }
    }

    @Test
    func `Enhanced Logging with Metadata (README lines 128-144)`() {
        struct MyFeature {
            @Dependency(\.logger) var logger

            func processUser(id: String) {
                // Automatically includes file and line information in metadata
                logger.log(
                    .info,
                    "Processing user",
                    metadata: ["userId": "\(id)"]
                )
            }
        }

        let feature = MyFeature()
        feature.processUser(id: "12345")
    }

    @Test
    func `Dependency Values Extension (README lines 150-154)`() {
        // Verify the dependency key exists
        @Dependency(\.logger) var logger

        // Should be able to access logger
        logger.info("Testing dependency values extension")
    }

    @Test
    func `Logger Test Dependency Key (README lines 160-164)`() {
        // Verify the test value is configured correctly
        let testLogger = Logger.testValue

        #expect(testLogger.label == ProcessInfo.processInfo.processName)
    }

    @Test
    func `Enhanced Logging Method Signature (README lines 170-180)`() {
        @Dependency(\.logger) var logger

        // Test that the enhanced logging method exists and works
        logger.log(
            .info,
            "Test message",
            metadata: ["key": "value"]
        )

        // Test without metadata
        logger.log(.debug, "Debug message")
    }
}
