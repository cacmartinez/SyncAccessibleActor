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
    nonisolated func performSynchronously<T, E: Error>(_ action: @Sendable (_ actor: isolated Self) throws(E) -> T) throws(E) -> T where T: Sendable {
        try withoutActuallyEscaping(action) { (escapingAction: @escaping @Sendable (_ actor: isolated Self) throws(E) -> T) throws(E) -> T in
            var result: Result<T, E>?
            Task(executorPreference: executorSource.synchronousExecutor) {
                print("Main - sync task started")
                do throws(E) {
                    result = .success(try await escapingAction(self))
                } catch {
                    result = .failure(error)
                }
                print("Main - sync task ended")
            }
            guard let result else {
                fatalError("Block reached a suspension point before completing. This should be impossible because it is an isolated synchronous block.")
            }
            return try result.get()
        }
    }
}
