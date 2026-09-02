//
//  SyncAccessibleExecutorSource.swift
//  SyncAccessibleActor_private
//
//  Created by Compean on 30/12/25.
//

import StrategyDispatchQueue

public final class SyncAccessibleExecutorSource: Sendable {
    let executor: Executor
    let backingQueue: StrategyDispatchSerialQueue<Void>
    
    public init(queueStrategy: sending any QueueingStrategy<StrategyDispatchQueue.WorkItem> = .prioritizingByQOS,
                nonIsolatedCheckAction: NonIsolatedAction = .crash) {
        let queue = StrategyDispatchSerialQueue(queueingStrategy: queueStrategy,
                                                minimumQOS: .background)
        self.executor = Executor(queue: queue, nonIsolatedCheckAction: nonIsolatedCheckAction)
        self.backingQueue = queue
    }
}
