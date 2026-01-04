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
//    nonisolated func performSynchronously<T, E: Error>(_ action: sending (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> sending T {
//        try withoutActuallyEscaping(action) { (escapingAction: @escaping (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> sending T in
//            
//            nonisolated(unsafe) var result: Result<T, E>?
//            let taskAction = SendableWrapper(wrapped: escapingAction)
//            Task(executorPreference: executorSource.synchronousExecutor) { @Sendable in
//                print("Main - sync task started")
//                do throws(E) {
//                    result = .success(try await taskAction.wrapped(self))
//                } catch {
//                    result = .failure(error)
//                }
//                print("Main - sync task ended")
//            }
//            guard let result else {
//                fatalError("Block reached a suspension point before completing. This should be impossible because it is an actor isolated synchronous block.")
//            }
//            return try result.get()
//        }
//    }
    @available(*, noasync)
    nonisolated func performSynchronously<T, E: Error>(_ action: (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> T {
        try executorSource.backingQueue.asyncAndWait { () throws(E) -> T in
            nonisolated(unsafe) let theAction = action
            let wrappedValue = assumeIsolated { actor -> SendableWrapper<T, E> in
                do throws(E) {
                    let value = try theAction(actor)
                    return SendableWrapper(wrapped: .success(value))
                } catch {
                    return SendableWrapper(wrapped: .failure(error))
                }
            }
            
            let value = wrappedValue.wrapped
            
            return try value.get()
//            let valueToReturn: T = try wrappedValue.wrapped.get()
//            _ = consume wrappedValue
//            return valueToReturn
//            nonisolated(unsafe) var result: Result<T, E>?
//            assumeIsolated { actor in
//                do throws(E) {
//                    result = .success(try action(actor))
//                } catch {
//                    result = .failure(error)
//                }
//            }
//            return try result!.get()
        }
//        try withoutActuallyEscaping(action) { (escapingAction: @escaping (_ actor: isolated Self) throws(E) -> sending T) throws(E) -> sending T in
//            
//            nonisolated(unsafe) var result: Result<T, E>?
//            let taskAction = SendableWrapper(wrapped: escapingAction)
//            Task(executorPreference: executorSource.synchronousExecutor) { @Sendable in
//                print("Main - sync task started")
//                do throws(E) {
//                    result = .success(try await taskAction.wrapped(self))
//                } catch {
//                    result = .failure(error)
//                }
//                print("Main - sync task ended")
//            }
//            guard let result else {
//                fatalError("Block reached a suspension point before completing. This should be impossible because it is an actor isolated synchronous block.")
//            }
//            return try result.get()
//        }
    }
}

final class SendableWrapper<Value, Failure: Error>: @unchecked Sendable {
    let wrapped: Result<Value, Failure>
    
    init(wrapped: consuming sending Result<Value, Failure>) {
        self.wrapped = wrapped
    }
}


