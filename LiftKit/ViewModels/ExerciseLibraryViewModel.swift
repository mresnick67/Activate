import Foundation
import Observation

@Observable
final class ExerciseLibraryViewModel {
    var searchText: String = ""
    /// nil = all categories
    var selectedCategory: ExerciseCategory? = nil

    func filteredExercises(from exercises: [Exercise]) -> [Exercise] {
        exercises.filter { exercise in
            matchesCategory(exercise) && matchesSearch(exercise)
        }
    }

    func groupedByCategory(exercises: [Exercise]) -> [(category: ExerciseCategory, exercises: [Exercise])] {
        let dict = Dictionary(grouping: exercises, by: { $0.category })

        return ExerciseCategory.allCases
            .compactMap { category in
                guard let items = dict[category], !items.isEmpty else { return nil }
                return (category, items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
            }
    }

    private func matchesCategory(_ exercise: Exercise) -> Bool {
        guard let selectedCategory else { return true }
        return exercise.category == selectedCategory
    }

    private func matchesSearch(_ exercise: Exercise) -> Bool {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return exercise.name.localizedCaseInsensitiveContains(trimmed)
    }
}
