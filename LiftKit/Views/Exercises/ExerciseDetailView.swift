import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Category", value: exercise.category.displayName)
                LabeledContent("Equipment", value: exercise.equipment.displayName)
                if let notes = exercise.notes, !notes.isEmpty {
                    LabeledContent("Notes", value: notes)
                }
            }

            Section {
                Text("Exercise history + PR tracking coming next (BQ-010).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
