import Testing
import SyncAccessibleActor
import Foundation

@globalActor
actor OrderActor {
    static let shared = OrderActor()
}

final class TestNonSendable {
    var a: Int = 3
}

actor TestActor: SyncAccessibleActor {
    nonisolated let executorSource = SyncAccessibleExecutorSource()
    
    var value = 8
    var nonSendable = TestNonSendable()
    
    func generatedNonSendable() -> sending TestNonSendable {
        let nonsendable = TestNonSendable()
        nonsendable.a = value + 2
        return nonsendable
    }
    
    func getValueAfterSomeSleep(taskNumber: Int) -> Int? {
//        for _ in 0..<100000 {
//            value += 1
//        }
        print("started getValueAfterSomeSleep \(taskNumber)")
        sleepThread()
        
        if Task.isCancelled {
            return nil
        }
        return value
    }
    
    private func sleepThread() {
        Thread.sleep(forTimeInterval: 0.02)
    }
}

final class SyncAccessibleActorTests {
    @Test func testAccessingIsolatedValueSynchronously() {
        let actor = TestActor()
        
        let newNonSendable = TestNonSendable()
        newNonSendable.a = 6
        let result = actor.performSynchronously { actor in
            actor.assertIsolated()
            actor.nonSendable = newNonSendable
            return (actorValue: actor.value, nonSendable: actor.generatedNonSendable(), actorNonSendableValue: actor.nonSendable.a)
        }
        #expect(result.actorValue == 8)
        #expect(result.nonSendable.a == 10)
        #expect(result.actorNonSendableValue == 6)
    }
    
    @Test func testAccessingIsolatedValueAsynchronously() async {
        let actor = TestActor()
        #expect(await actor.value == 8)
    }
    
    @available(iOS 26.0, *)
    @Test func testOrderOfExecution_qosPriorityExecutor() async throws {
        let actor = TestActor()
        
        let task1 = Task(priority: .medium) { @OrderActor in
            print("started task 1")
            let value = await actor.getValueAfterSomeSleep(taskNumber: 1)
            print("task 1 value: \(value)")
            print("finished task 1")
        }
        
        let task2 = Task(priority: .medium) { @OrderActor in
            print("started task 2")
            let value = await actor.getValueAfterSomeSleep(taskNumber: 2)
            print("task 2 value: \(value)")
            print("finished task 2")
        }
        
        let task3 = Task(priority: .medium) { @OrderActor in
            print("started task 3")
            let value = await withTaskPriorityEscalationHandler {
                 await actor.getValueAfterSomeSleep(taskNumber: 3)
            } onPriorityEscalated: { oldPriority, newPriority in
                print("escalated priority of task 3 from \(oldPriority) to \(newPriority)")
            }
            print("task 3 value: \(value)")
            print("finished task 3")
        }
        
        Task(priority: .userInitiated) {
            try await Task.sleep(for: .seconds(0.01))
            print("bumping priority of task 3")
            await task3.value
        }
        
        for _ in 0..<50000000 {
            
        }
    }
    
//    @Test func testCancellation() async throws {
//        let actor = TestActor()
//        
//        let task1StartTime = Date()
//        let task1 = Task.detached(priority: .medium) {
//            print("started task 1")
//            print("task 1 priority: \(Task.currentPriority)")
//            let value = await actor.getValueAfterSomeSleep()
//            print("task 1 value: \(value)")
//            print("task 1 priority: \(Task.currentPriority)")
//            let date = Date()
//            print("finished task 1")
//            return (duration: date.timeIntervalSince(task1StartTime), date: date)
//        }
//        
//        let task2StartTime = Date()
//        let task2 = Task.detached(priority: .medium) {
//            try await Task.sleep(for: .seconds(0.01))
//            print("started task 2")
//            print("task 2 priority: \(Task.currentPriority)")
//            let value = await actor.getValueAfterSomeSleep()
//            print("task 2 value: \(value)")
//            print("task 2 priority: \(Task.currentPriority)")
//            let date = Date()
//            print("finished task 2")
//            return (duration: date.timeIntervalSince(task2StartTime), date: date)
//        }
//        
//        let task3StartTime = Date()
//        let task3 = Task.detached(priority: .medium) {
//            try await Task.sleep(for: .seconds(0.02))
//            print("started task 3")
//            print("task 3 priority: \(Task.currentPriority)")
//            let value = await actor.getValueAfterSomeSleep()
//            print("task 3 value: \(value)")
//            print("task 3 priority: \(Task.currentPriority)")
//            let date = Date()
//            print("finished task 3")
//            return (duration: date.timeIntervalSince(task3StartTime), date: date)
//        }
//        
//        let task4StartTime = Date()
//        let task4 = Task.detached(priority: .medium) {
//            try await Task.sleep(for: .seconds(0.03))
//            print("started task 4")
//            print("task 4 priority: \(Task.currentPriority)")
//            let value = await actor.getValueAfterSomeSleep()
//            print("task 4 value: \(value)")
//            print("task 4 priority: \(Task.currentPriority)")
//            let date = Date()
//            print("finished task 4")
//            return (duration: date.timeIntervalSince(task3StartTime), date: date)
//        }
//        
//        Task {
//            try await task4.value
//        }
//        Task {
//            try await Task.sleep(for: .seconds(0.03))
//            try await task3.value
//        }
////        try await Task.sleep(for: .seconds(0.02))
//        
////        task1.cancel()
////        task2.cancel()
//        
////        print("task1 duration: \(try await task1.value.duration) date: \(try await task1.value.date.timeIntervalSinceReferenceDate)")
////        try await (task4.value, task3.value)
////        print("task3 duration: \(try await task3.value.duration) date: \(try await task3.value.date.timeIntervalSinceReferenceDate)")
////        print("task4 duration: \(try await task4.value.duration) date: \(try await task4.value.date.timeIntervalSinceReferenceDate)")
////        Task {
////            try await task1.value
////            try await task2.value
////        }
//        for _ in 0..<50000000 {
//            
//        }
////        #expect(try await task1.value == nil)
////        #expect(try await task2.value == 8)
//    }
}

