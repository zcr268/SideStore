import ArgumentParser
import SwiftLintFramework

extension Cargo {
    struct Version: ParsableCommand {
        @Flag(help: "Display full version info")
        var verbose = false

        static let configuration = CommandConfiguration(abstract: "Display the current version of Cargo")

        static var value: String { "TODO" }

        func run() throws {
            if verbose, let buildID = ExecutableInfo.buildID {
                print("Version:", Self.value)
                print("Build ID:", buildID)
            } else {
                print(Self.value)
            }
            ExitHelper.successfullyExit()
        }
    }
}
