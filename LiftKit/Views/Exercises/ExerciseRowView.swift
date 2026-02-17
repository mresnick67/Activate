import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.equipmentSymbolName)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(exercise.category.displayName) • \(exercise.equipment.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }
}

private extension Exercise {
    var equipmentSymbolName: String {
        switch equipment {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell"
        case .machine: return "gearshape.2"
        case .cable: return "link"
        case .bodyweight: return "figure.walk"
        case .kettlebell: return "dumbbell.fill" // close enough for now
        case .band: return "wave.3.right"
        case .other: return "questionmark"
        }
    }
}

#Preview {
    ExerciseRowView(exercise: Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false))
        .padding()
}
