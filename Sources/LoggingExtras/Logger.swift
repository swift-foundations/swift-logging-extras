import Dependencies
import Foundation
import Logging

extension Dependency.Values {
    public var logger: Logger {
        get { self[Logger.self] }
        set { self[Logger.self] = newValue }
    }
}

extension Logger: @retroactive Dependency.Key {
    /// W-E2 (di-composition-root-design.md §4.2/§4.3): this key had NO live half — it
    /// conformed only to `Dependency.Key.Test`. Every `@Dependency(\.logger)` read in a
    /// LIVE context without an explicit override therefore resolved `testValue`, and
    /// because that test default was a *real, working* logger (default handler,
    /// process-name label) the substitution logged normally and stayed invisible for as
    /// long as the key has existed. The §4.2 tripwire caught it on its first live boot.
    ///
    /// The liveValue below preserves that observable behavior verbatim — it *is* the old
    /// testValue — so live consumers see no change in what gets logged. What changes is
    /// that they now resolve a value declared FOR the live context instead of borrowing
    /// one from the test surface.
    public static var liveValue: Logger {
        Logger(label: ProcessInfo.processInfo.processName)
    }

    /// Quiet in tests, matching the shape swift-server's own `LoggerKey` already uses
    /// (`swift-server/Sources/Server Dependencies Integration/LoggerKey.swift`): scripted
    /// tests stay silent unless they override `\.logger` explicitly.
    public static var testValue: Logger {
        Logger(label: ProcessInfo.processInfo.processName, factory: { _ in
            SwiftLogNoOpLogHandler()
        })
    }
}

extension Logger {
    public func log(
        _ level: Logger.Level,
        _ message: @autoclosure () -> Logger.Message,
        metadata: Logger.Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        self.log(
            level: level,
            message(),
            metadata: (metadata ?? [:]).merging(
                [
                    "file": "\(file)",
                    "line": "\(line)",
                ],
                uniquingKeysWith: { $1 }
            ),
            file: file,
            function: function,
            line: line
        )
    }
}
