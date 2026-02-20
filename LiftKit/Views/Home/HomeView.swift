import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var isShowingActiveWorkout = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button {
                    isShowingActiveWorkout = true
                } label: {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("LiftKit")
        }
        .fullScreenCover(isPresented: $isShowingActiveWorkout) {
            ActiveWorkoutView()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self], inMemory: true)
}
