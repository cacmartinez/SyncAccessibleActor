import Testing
@testable import SyncAccessibleActor

actor TestActor: SyncAccessibleActor {
    nonisolated let executorSource = SyncAccessibleExecutorSource()
    
    var value = 8
}

final class SyncAccessibleActorTests {
    @Test func testAccessingIsolatedValueSynchronously() {
        let actor = TestActor()
        
        let actorValue = actor.performSynchronously {
            return await actor.value
        }
        #expect(actorValue == 8)
    }
    
    @Test func testAccessingIsolatedValueAsynchronously() async {
        let actor = TestActor()
        #expect(await actor.value == 8)
    }
}

