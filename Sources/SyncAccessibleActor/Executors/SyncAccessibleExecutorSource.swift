//
//  SyncAccessibleExecutorSource.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

public final class SyncAccessibleExecutorSource: Sendable {
    let synchronousExecutor: Executor
    let asynchronousExecutor: Executor
    
    public init(queueStrategy: any QueueingStrategy<StrategyDispatchQueue.WorkItem> = .prioritizingByQOS) {
        let queue = StrategyDispatchQueue(queueingStrategy: queueStrategy,
                                          minimumQOS: .background)
        self.synchronousExecutor = Executor(queue: queue) { queue, qos, execute in
            queue.asyncAndWait(qos: qos, execute: execute)
        }
        self.asynchronousExecutor = Executor(queue: queue) { queue, qos, execute in
            queue.async(qos: qos, execute: execute)
        }
    }
}
