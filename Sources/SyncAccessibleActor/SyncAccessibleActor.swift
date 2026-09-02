// The Swift Programming Language
// https://docs.swift.org/swift-book

import StrategyDispatchQueue

public protocol SyncAccessibleActor: Actor {
    nonisolated var executorSource: SyncAccessibleExecutorSource { get }
}

public extension SyncAccessibleActor {
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executorSource.executor.asUnownedSerialExecutor()
    }
    
    @available(*, noasync)
    nonisolated func performSynchronously<T, E: Error>(_ action: (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> T {
        try executorSource.backingQueue.asyncAndWait { _ throws(E) in
            nonisolated(unsafe) let unsafeAction = action
            return try assumeIsolated { actor -> SendableWrapper<Result<T, E>> in
                do throws(E) {
                    return SendableWrapper(wrapped: .success(try unsafeAction(actor)))
                } catch {
                    return SendableWrapper(wrapped: .failure(error))
                }
            }.wrapped.get()
        }
    }
}

private struct SendableWrapper<Value>: @unchecked Sendable {
    let wrapped: Value
}


