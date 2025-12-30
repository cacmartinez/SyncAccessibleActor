//
//  SyncAccessibleExecutorSource+SynchronousExecutor.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

extension SyncAccessibleExecutorSource {
    final class SynchronousExecutor: SerialExecutor, TaskExecutor {
        private let queue: StrategyDispatchQueue
        
        init(queue: StrategyDispatchQueue) {
            self.queue = queue
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
//            print("jobpriority: \(job.priority)")
//            let threadPriorityToJobValue: JobPriority.RawValue
//            switch Thread.current.qualityOfService {
//            case .userInteractive:
//                threadPriorityToJobValue = JobPriority()
//
//            }
            
//            let jobPriority = job.priority.rawValue > Thread.threadPriority()
//            let queue = queueProvider(job.priority)
            let unownedJob = UnownedJob(job)
            if meetsDispatchCondition(condition: .onQueue(queue)) {
                print("Excutor queue sync will execute immediately")
                unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                            taskExecutor: self.asUnownedTaskExecutor())
//                unownedJob.runSynchronously(on: self.asUnownedTaskExecutor())
            } else {
                print("Excutor queue sync block will be scheduled on \(queue)")
                queue.asyncAndWait(qos: .userInteractive) {
                    print("Excutor queue sync block starting")
                    unownedJob.runSynchronously(isolatedTo: self.asUnownedSerialExecutor(),
                                                taskExecutor: self.asUnownedTaskExecutor())
//                    unownedJob.runSynchronously(on: self.asUnownedTaskExecutor())
                    print("Excutor queue sync block ending")
                }
            }
        }
        
//        private func isCurrentContextRunningOnQueue(_ queue: StrategyDispatchQueue) -> Bool {
////            guard let currentContextGCDExecutorQueueId = DispatchQueue.getSpecific(key: queueIdKey),
////                  let queueId = queue.getSpecific(key: queueIdKey) else {
////                return false
////            }
////            return currentContextGCDExecutorQueueId == queueId
//            return meetsDispatchCondition(condition: .onQueue(queue))
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
