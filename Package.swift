// swift-tools-version: 6.3.1

import Foundation
import PackageDescription

extension String {
    static let loggingExtras: Self = "LoggingExtras"
}

extension Target.Dependency {
    static var loggingExtras: Self { .target(name: .loggingExtras) }
}

extension Target.Dependency {
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "Dependencies Test Support", package: "swift-dependencies") }
    static var logging: Self { .product(name: "Logging", package: "swift-log") }
}

let package = Package(
    name: "swift-logging-extras",
    platforms: [
      .iOS(.v26),
      .macOS(.v26),
      .tvOS(.v26),
      .watchOS(.v26)
    ],
    products: [
        .library(name: .loggingExtras, targets: [.loggingExtras])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4")
    ],
    targets: [
        .target(
            name: .loggingExtras,
            dependencies: [
                .dependencies,
                .logging
            ]
        ),
        .testTarget(
            name: .loggingExtras.tests,
            dependencies: [
                .loggingExtras,
                .dependenciesTestSupport
            ]
        )
    ]
)

extension String { var tests: Self { self + " Tests" } }
