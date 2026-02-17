import Foundation
import SwiftData

@MainActor
enum ExerciseSeedService {
    private static let seedFlagKey = "hasSeededDefaultExercises_v1"

    struct SeedExercise: Decodable {
        let name: String
        let category: ExerciseCategory
        let equipment: Equipment
    }

    static func seedIfNeeded(modelContext: ModelContext) {
        let defaults = UserDefaults.standard

        if defaults.bool(forKey: seedFlagKey) {
            return
        }

        // If any exercises already exist (seeded or custom), treat as seeded.
        // This keeps seeding idempotent and avoids duplicates.
        let existingCount = (try? modelContext.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        if existingCount > 0 {
            defaults.set(true, forKey: seedFlagKey)
            return
        }

        guard let url = Bundle.main.url(forResource: "DefaultExercises", withExtension: "json") else {
            assertionFailure("DefaultExercises.json not found in app bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let seedExercises = try decoder.decode([SeedExercise].self, from: data)

            for seed in seedExercises {
                let exercise = Exercise(
                    name: seed.name,
                    category: seed.category,
                    equipment: seed.equipment,
                    isCustom: false,
                    notes: nil,
                    createdAt: .now
                )
                modelContext.insert(exercise)
            }

            try modelContext.save()
            defaults.set(true, forKey: seedFlagKey)
        } catch {
            assertionFailure("Failed seeding exercises: \(error)")
        }
    }
}
