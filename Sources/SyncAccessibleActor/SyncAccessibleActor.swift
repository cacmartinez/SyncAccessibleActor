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
    nonisolated func performSynchronously<T, E: Error>(_ action: @Sendable () async throws(E) -> T) throws(E) -> T where T: Sendable {
        try withoutActuallyEscaping(action) { (escapingAction: @escaping @Sendable () async throws(E) -> T) throws(E) -> T in
            var result: Result<T, E>?
            Task(executorPreference: executorSource.synchronousExecutor) {
                print("Main - sync task started")
                do throws(E) {
                    result = .success(try await escapingAction())
                } catch {
                    result = .failure(error)
                }
                print("Main - sync task ended")
            }
            return try result!.get()
        }
    }
}
