//
//  SyncAccessibleExecutorSource+NonIsolatedAction.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 03/01/26.
//

public extension SyncAccessibleExecutorSource {
    enum NonIsolatedAction: Sendable {
        case crash
        case assert
        case custom(@Sendable () -> Void)
    }
}
