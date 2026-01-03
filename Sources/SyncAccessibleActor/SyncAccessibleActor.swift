// The Swift Programming Language
// https://docs.swift.org/swift-book

import StrategyDispatchQueue

public protocol SyncAccessibleActor: Actor {
    nonisolated var executorSource: SyncAccessibleExecutorSource { get }
}

public extension SyncAccessibleActor {
    
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executorSource.asynchronousExecutor.asUnownedSerialExecutor()
    }
    
    @available(*, noasync)
    nonisolated func performSynchronously<T, E: Error>(_ action: @Sendable (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> sending T {
        try withoutActuallyEscaping(action) { (escapingAction: @Sendable @escaping (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> sending T in
            
            nonisolated(unsafe) var result: Result<T, E>? = nil
            let taskAction = escapingAction
            Task(executorPreference: executorSource.synchronousExecutor) { @Sendable in
                print("Main - sync task started")
                do throws(E) {
                    result = .success(try await taskAction(self))
                } catch {
                    result = .failure(error)
                }
                print("Main - sync task ended")
            }
            guard let result else {
                fatalError("Block reached a suspension point before completing. This should be impossible because it is an actor isolated synchronous block.")
            }
            return try result.get()
        }
    }
}
