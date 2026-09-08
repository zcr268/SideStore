//
//  ZipAppOperation.swift
//  SideStore
//
//  Created by Magesh K on 9/9/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation
import SideSign

final class ZipAppOperation: BasePipelineOperation<InstallAppOperationContext, URL>, @unchecked Sendable {

    override func execute(parentProgress: Progress?) async throws -> URL {
        let startTime = CFAbsoluteTimeGetCurrent()
        debugLog("[ZipAppOperation] execute() started")
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            debugLog("[ZipAppOperation] execute() took: \(String(format: "%.3fs", elapsed))")
        }
        try await super.executePreconditionCheck(parentProgress: parentProgress)
        self.setProgress(10)

        guard let resignedAppBundle = self.context.resignedAppBundle else {
            throw OperationError.invalidParameters("ZipAppOperation: context.resignedAppBundle is nil")
        }

        let appURL = resignedAppBundle.fileURL
        debugLog("[ZipAppOperation] Zipping app bundle at \(appURL.path)...")
        self.setProgress(30)

        let ipaURL = try FileManager.default.zipAppBundle(at: appURL, compressionLevel: .none)
        self.context.ipaURL = ipaURL
        self.setProgress(100)
        debugLog("[ZipAppOperation] Zipped IPA created at \(ipaURL.path)")
        return ipaURL
    }
}
