//
//  OperationLogging.swift
//  SideStore
//
//  Created by Magesh K on 8/7/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

internal protocol OperationLogging {
    func debugLog(_ text: @autoclosure () -> String)
    func verboseLog(_ text: @autoclosure () -> String)
}

internal extension OperationLogging {

    func debugLog(_ text: @autoclosure () -> String) {
        let message = text()
        if !message.isEmpty && message.allSatisfy({ $0 == "\n" || $0 == "\r" }) {
            print(message, terminator: "")
        } else {
            print("\(getOperationsLogTag(level: "[D]"))\(message)")
        }
    }

    func verboseLog(_ text: @autoclosure () -> String) {
        guard OperationsLoggingControl.isLoggingEnabled(for: type(of: self)) else { return }
        let message = text()
        if !message.isEmpty && message.allSatisfy({ $0 == "\n" || $0 == "\r" }) {
            print(message, terminator: "")
        } else {
            print("\(getOperationsLogTag(level: "[V]"))\(message)")
        }
    }
}

func logOperationSummary(
    operation: String,
    target: String,
    status: String,
    elapsed: Double,
    error: Error? = nil
) {
    let width = 49
    
    func centerRow(_ text: String) -> String {
        let padding = max(0, width - text.count)
        let left = String(repeating: " ", count: padding / 2)
        let right = String(repeating: " ", count: padding - left.count)
        return "|\(left)\(text)\(right)|"
    }
    
    func bulletRow(_ label: String, _ value: String) -> [String] {
        let prefix = " • \(label): "
        let availableWidth = max(1, width - prefix.count)
        
        if value.count <= availableWidth {
            let rightPadding = String(repeating: " ", count: availableWidth - value.count)
            return ["|\(prefix)\(value)\(rightPadding)|"]
        } else {
            var rows: [String] = []
            var remaining = Substring(value)
            
            let firstChunk = String(remaining.prefix(availableWidth))
            remaining = remaining.dropFirst(availableWidth)
            let firstPad = String(repeating: " ", count: availableWidth - firstChunk.count)
            rows.append("|\(prefix)\(firstChunk)\(firstPad)|")
            
            let indent = String(repeating: " ", count: prefix.count)
            while !remaining.isEmpty {
                let chunk = String(remaining.prefix(availableWidth))
                remaining = remaining.dropFirst(availableWidth)
                let pad = String(repeating: " ", count: availableWidth - chunk.count)
                rows.append("|\(indent)\(chunk)\(pad)|")
            }
            return rows
        }
    }
    
    debugLog("===================================================")
    debugLog(centerRow("OPERATION \(status.uppercased())"))
    debugLog("===================================================")
    for row in bulletRow("Operation", operation) {
        debugLog(row)
    }
    for row in bulletRow("App ID", target) {
        debugLog(row)
    }
    for row in bulletRow("Status", status.uppercased()) {
        debugLog(row)
    }
    for row in bulletRow("Elapsed", String(format: "%.3fs", elapsed)) {
        debugLog(row)
    }
    if let error = error {
        for row in bulletRow("Error", error.localizedDescription) {
            debugLog(row)
        }
    }
    debugLog("===================================================")
}

