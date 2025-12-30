//
//  SyncAccessibleExecutorSource+AsynchronousExecutor.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

extension SyncAccessibleExecutorSource {
    final class AsynchronousExecutor: SerialExecutor, TaskExecutor {
        private let queue: StrategyDispatchQueue
//        private let queueProvider: @Sendable (_ jobPriority: JobPriority?) -> DispatchQueue
//        private let queueIdKey: DispatchSpecificKey<UUID>
//        private let taskExecutor: UnownedTaskExecutor
        
        init(queue: StrategyDispatchQueue) {
            self.queue = queue
//            self.queueIdKey = queueIdKey
//            self.taskExecutor = taskExecutor
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
//            print("jobpriority: \(job.priority)")
//            let queue = queueProvider(job.priority)
            let unownedJob = UnownedJob(job)
            if meetsDispatchCondition(condition: .onQueue(queue)) {
                unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                            taskExecutor: self.asUnownedTaskExecutor())
//                unownedJob.runSynchronously(on: self.asUnownedTaskExecutor())
            } else {
                queue.async(qos: .userInitiated) {
                    print("on async queue: \(self.queue)")
                    unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                                taskExecutor: self.asUnownedTaskExecutor())
//                    unownedJob.runSynchronously(on: self.asUnownedTaskExecutor())
                }
            }
        }
        
//        func isCurrentContextRunningOnQueue(_ queue: DispatchQueue) -> Bool {
//            guard let currentContextGCDExecutorQueueId = DispatchQueue.getSpecific(key: queueIdKey),
//                  let queueId = queue.getSpecific(key: queueIdKey) else {
//                return false
//            }
//            return currentContextGCDExecutorQueueId == queueId
//        }
        
        func asUnownedSerialExecutor() -> UnownedSerialExecutor {
            UnownedSerialExecutor(complexEquality: self)
        }
        
        func asUnownedTaskExecutor() -> UnownedTaskExecutor {
            UnownedTaskExecutor(ordinary: self)
        }
        
        func checkIsolated() {
            dispatchPrecondition(condition: .onQueue(queue))
//            dispatchPrecondition(condition: .onQueue(queueProvider(nil)))
        }
    }
}
