import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var viewModel = ExerciseLibraryViewModel()

    let onSelect: (Exercise) -> Void

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
                                Button {
                                    onSelect(exercise)
                                    dismiss()
                                } label: {
                                    ExerciseRowView(exercise: exercise)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pick Exercise")
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

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
    container.mainContext.insert(Exercise(name: "Pull-Up", category: .back, equipment: .bodyweight, isCustom: false))

    return ExercisePickerView { _ in }
        .modelContainer(container)
}
