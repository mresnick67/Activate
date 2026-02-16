import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            Text("Settings")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsPlaceholderView()
}
