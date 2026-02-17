import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var viewModel = ExerciseLibraryViewModel()

    var body: some View {
        NavigationStack {
            List {
                let filtered = viewModel.filteredExercises(from: exercises)
                let grouped = viewModel.groupedByCategory(exercises: filtered)

                if grouped.isEmpty {
                    ContentUnavailableView(
                        "No exercises",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters.")
                    )
                } else {
                    ForEach(grouped, id: \.category) { group in
                        Section(group.category.displayName) {
                            ForEach(group.exercises) { exercise in
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    ExerciseRowView(exercise: exercise)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $viewModel.searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            Text("All").tag(ExerciseCategory?.none)
                            Divider()
                            ForEach(ExerciseCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(ExerciseCategory?.some(category))
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Placeholder for BQ-016 (Add Custom Exercise)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Exercise")
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self,
        configurations: config
    )

    container.mainContext.insert(Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false))
    container.mainContext.insert(Exercise(name: "Incline Dumbbell Press", category: .chest, equipment: .dumbbell, isCustom: false))
    container.mainContext.insert(Exercise(name: "Pull-Up", category: .back, equipment: .bodyweight, isCustom: false))

    return ExerciseLibraryView()
        .modelContainer(container)
}
