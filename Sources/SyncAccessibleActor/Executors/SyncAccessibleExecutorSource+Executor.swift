//
//  SyncAccessibleExecutorSource+Executor.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import Dispatch
import StrategyDispatchQueue

extension SyncAccessibleExecutorSource {
    final class Executor: SerialExecutor, TaskExecutor {
        private let queue: StrategyDispatchQueue
        private let queueDispatchAction: @Sendable (_ queue: StrategyDispatchQueue, _ qos: DispatchQoS, _ execute: sending @escaping () -> Void) -> Void
        
        init(queue: StrategyDispatchQueue, queueDispatchAction: @escaping @Sendable (_ queue: StrategyDispatchQueue, _ qos: DispatchQoS, _ execute: sending @escaping () -> Void) -> Void) {
            self.queue = queue
            self.queueDispatchAction = queueDispatchAction
        }
        
        private func qos(from priority: JobPriority) -> DispatchQoS {
            var qos: DispatchQoS
            switch priority.rawValue {
                case (TaskPriority.userInitiated.rawValue+1)...:
                    qos = .userInteractive
                case (TaskPriority.medium.rawValue+1)...TaskPriority.userInitiated.rawValue:
                    qos = .userInitiated
                case (TaskPriority.utility.rawValue+1)...TaskPriority.medium.rawValue:
                    qos = .default
                case (TaskPriority.background.rawValue+1)...TaskPriority.utility.rawValue:
                    qos = .utility
                case ...TaskPriority.background.rawValue:
                    qos = .background
                default:
                    qos = .default
            }
            return qos
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
            let jobPriority = job.priority
            
            let unownedJob = UnownedJob(job)
            if meetsDispatchCondition(condition: .onQueue(queue)) {
                unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                            taskExecutor: self.asUnownedTaskExecutor())
            } else {
                let qos = qos(from: jobPriority)
                queueDispatchAction(queue, qos) {
                    unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                                taskExecutor: self.asUnownedTaskExecutor())
                }
            }
        }
        
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(complexEquality: self)
        }
        
        func asUnownedTaskExecutor() -> UnownedTaskExecutor {
            UnownedTaskExecutor(ordinary: self)
        }
        
        func isIsolatingCurrentContext() -> Bool? {
            meetsDispatchCondition(condition: .onQueue(queue))
        }
        
        func checkIsolated() {
            dispatchPrecondition(condition: .onQueue(queue))
        }
    }
}
