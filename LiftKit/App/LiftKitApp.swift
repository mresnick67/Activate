import SwiftUI
import SwiftData

@main
struct LiftKitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self])
    }
}
