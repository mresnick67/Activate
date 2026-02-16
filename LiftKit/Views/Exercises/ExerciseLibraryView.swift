import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    var body: some View {
        NavigationStack {
            Text("Exercises")
                .navigationTitle("Exercises")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self,
        configurations: config
    )

    // Seed a single exercise to prove model insert works in previews.
    let sampleExercise = Exercise(
        name: "Bench Press",
        category: .chest,
        equipment: .barbell,
        isCustom: false
    )
    container.mainContext.insert(sampleExercise)

    return ExerciseLibraryView()
        .modelContainer(container)
}
