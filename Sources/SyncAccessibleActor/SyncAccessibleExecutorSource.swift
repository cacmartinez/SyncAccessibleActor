//
//  SyncAccessibleExecutorSource.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

public final class SyncAccessibleExecutorSource: Sendable {
    let asynchronousExecutor: Executor
    let backingQueue: StrategyDispatchSerialQueue
    
    public init(queueStrategy: any QueueingStrategy<StrategyDispatchQueue.WorkItem> = .prioritizingByQOS,
                nonIsolatedCheckAction: NonIsolatedAction = .crash) {
        let queue = StrategyDispatchSerialQueue(queueingStrategy: queueStrategy,
                                                minimumQOS: .background)
        self.asynchronousExecutor = Executor(queue: queue, nonIsolatedCheckAction: nonIsolatedCheckAction)
        self.backingQueue = queue
    }
}
