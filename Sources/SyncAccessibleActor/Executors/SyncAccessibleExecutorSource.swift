//
//  SyncAccessibleExecutorSource.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

public final class SyncAccessibleExecutorSource: Sendable {
    let synchronousExecutor: SynchronousExecutor
    let asynchronousExecutor: AsynchronousExecutor
//    private let taskExecutor: ImmediateExecutor
//    let queueProvider: @Sendable (_ jobPriority: JobPriority?) -> QueueProtocol
    
//    enum EnqueueStyle {
//        case firstInFirstOut(qos: DispatchQoS? = nil)
//        case highestQOSFirstThenFIFO // jumps elements with higher priority ahead of elements with lower priority.
//    }
    
    init(queueStrategy: QueueingStrategy = .prioritizingByQOS) {
        let queue = StrategyDispatchQueue(queueingStrategy: queueStrategy,
                                          minimumQOS: .background)
        self.synchronousExecutor = SynchronousExecutor(queue: queue)
        self.asynchronousExecutor = AsynchronousExecutor(queue: queue)
//        let queueProvider: @Sendable (_ jobPriority: JobPriority?) -> QueueProtocol
//        let gcdExecutorQueueIdKey = DispatchSpecificKey<UUID>()
//        let queueId = UUID()
//        let immediateExecutor = ImmediateExecutor()
        
//        switch enqueStyle {
//        case .firstInFirstOut(let qos):
//            let orderJobsQueue: DispatchQueue
//            switch (qos, targetQueue) {
//            case (.some(let qos), .some(let targetQueue)):
//                orderJobsQueue = DispatchQueue(label: queueLabel, qos: qos, target: targetQueue)
//            case (.some(let qos), .none):
//                orderJobsQueue = DispatchQueue(label: queueLabel, qos: qos)
//            case (.none, .some(let target)):
//                orderJobsQueue = DispatchQueue(label: queueLabel, target: target)
//            default:
//                orderJobsQueue = DispatchQueue(label: queueLabel)
//            }
//            
//            orderJobsQueue.setSpecific(key: gcdExecutorQueueIdKey, value: queueId)
//            queueProvider = { _ in orderJobsQueue }
//        case .highestQOSFirstThenFIFO:
//            let workloop = DispatchWorkloop(label: queueLabel)
//            guard let targetQueue else {
//                queueProvider = { _ in workloop }
//                break
//            }
//            
//            let objcQueue = TEObjcQueue(label: "objc.queue", target: targetQueue)
//            
//            queueProvider = { _ in objcQueue }
//            let userInteractiveQueue = DispatchQueue(label: "\(queueLabel)-user-interactive", target: targetQueue)
////            userInteractiveQueue.setSpecific(key: gcdExecutorQueueIdKey, value: UUID())
//            let userInitiatedQueue = DispatchQueue(label: "\(queueLabel)-user-inititated", target: userInteractiveQueue)
////            userInitiatedQueue.setSpecific(key: gcdExecutorQueueIdKey, value: UUID())
//            let defaultQueue = DispatchQueue(label: "\(queueLabel)-default", target: userInitiatedQueue)
////            defaultQueue.setSpecific(key: gcdExecutorQueueIdKey, value: UUID())
//            let utilityQueue = DispatchQueue(label: "\(queueLabel)-utility", target: defaultQueue)
////            utilityQueue.setSpecific(key: gcdExecutorQueueIdKey, value: UUID())
//            let backgroundQueue = DispatchQueue(label: "\(queueLabel)-background", target: utilityQueue)
////            backgroundQueue.setSpecific(key: gcdExecutorQueueIdKey, value: UUID())
//
//            queueProvider = { jobPriority in
//                guard let jobPriority else {
//                    switch Thread.current.qualityOfService {
//                    case .userInteractive:
//                        return userInteractiveQueue
//                    case .userInitiated:
//                        return userInitiatedQueue
//                    case .default:
//                        return defaultQueue
//                    case .utility:
//                        return utilityQueue
//                    case .background:
//                        return backgroundQueue
//                    default:
//                        return defaultQueue
//                    }
//                }
//
//                switch jobPriority.rawValue {
//                case (TaskPriority.userInitiated.rawValue+1)...:
//                    return userInteractiveQueue
//                case (TaskPriority.medium.rawValue+1)...TaskPriority.userInitiated.rawValue:
//                    return userInitiatedQueue
//                case (TaskPriority.utility.rawValue+1)...TaskPriority.medium.rawValue:
//                    return defaultQueue
//                case (TaskPriority.background.rawValue+1)...TaskPriority.utility.rawValue:
//                    return utilityQueue
//                case ...TaskPriority.background.rawValue:
//                    return backgroundQueue
//                default:
//                    return defaultQueue
//                }
//            }
//        }
        
//        self.queueProvider = queueProvider
//        self.taskExecutor = immediateExecutor
//        self.synchronousExecutor = SynchronousExecutor(queueProvider: queueProvider, queueIdKey: gcdExecutorQueueIdKey, taskExecutor: immediateExecutor.asUnownedTaskExecutor())
//        self.asynchronousExecutor = AsynchronousExecutor(queueProvider: queueProvider,
//                                                         queueIdKey: gcdExecutorQueueIdKey,
//                                                         taskExecutor: immediateExecutor.asUnownedTaskExecutor())
    }
}
