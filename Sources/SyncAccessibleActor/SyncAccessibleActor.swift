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
    
//    @available(*, noasync)
//    nonisolated func performSynchronously<T, E: Error>(_ action: (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> T {
//        try withoutActuallyEscaping(action) { (escapingAction: consuming @escaping (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> T in
//            
//            var result: SendableWrapper<T, E>?
////            let taskAction = SendableWrapper(wrapped: consume escapingAction)
//            Task(executorPreference: executorSource.synchronousExecutor) { //@Sendable in
//                print("Main - sync task started")
//                do throws(E) {
//                    result = SendableWrapper(wrapped: .success(try await escapingAction(self)))
//                } catch {
//                    result = SendableWrapper(wrapped: .failure(error))
//                }
//                print("Main - sync task ended")
//            }
////            _ = consume taskAction
//            guard let result else {
//                fatalError("Block reached a suspension point before completing. This should be impossible because it is an actor isolated synchronous block.")
//            }
//            return try result.wrapped.get()
//        }
//    }
    
    @available(*, noasync)
    nonisolated func performSynchronously<T, E: Error>(_ action: (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> T {
        try executorSource.backingQueue.asyncAndWait { () throws(E) -> T in
            nonisolated(unsafe) let theAction = action
            return try assumeIsolated { actor -> SendableWrapper<T, E> in
                do throws(E) {
                    return SendableWrapper(wrapped: .success(try theAction(actor)))
                } catch {
                    return SendableWrapper(wrapped: .failure(error))
                }
            }.wrapped.get()
        }
    }
}

private final class SendableWrapper<Value, Failure: Error>: @unchecked Sendable {
    let wrapped: Result<Value, Failure>
    
    init(wrapped: consuming sending Result<Value, Failure>) {
        self.wrapped = wrapped
    }
}


