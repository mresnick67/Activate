import SwiftUI
import SwiftData

enum WorkoutSetInputField: Hashable {
    case weight(UUID)
    case reps(UUID)
    case rpe(UUID)
}

struct WorkoutSetRowView: View {
    let set: WorkoutSet
    let previousSet: WorkoutSet?
    let onToggleCompletion: (Bool) -> Void
    let onPersist: () -> Void

    @FocusState.Binding var focusedField: WorkoutSetInputField?

    @State private var weightText = ""
    @State private var repsText = ""
    @State private var rpeText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button {
                    onToggleCompletion(!set.isCompleted)
                } label: {
                    Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(set.isCompleted ? .green : .secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(set.isCompleted ? "Mark set incomplete" : "Mark set complete")

                Text("\(set.setOrder + 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 20, alignment: .leading)

                numericField(
                    title: "Wt",
                    text: $weightText,
                    focusedCase: .weight(set.id),
                    keyboard: .decimalPad,
                    isInvalid: weightIsInvalid
                )

                numericField(
                    title: "Reps",
                    text: $repsText,
                    focusedCase: .reps(set.id),
                    keyboard: .numberPad,
                    isInvalid: repsIsInvalid
                )

                numericField(
                    title: "RPE",
                    text: $rpeText,
                    focusedCase: .rpe(set.id),
                    keyboard: .decimalPad,
                    isInvalid: rpeIsInvalid
                )

                if previousSetSummary != nil {
                    Button("Repeat") {
                        repeatPreviousValues()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }

            if let previousSetSummary {
                Text("Last: \(previousSetSummary)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .onAppear {
            syncTextFromModel()
        }
        .onChange(of: set.weight) { _, _ in
            syncWeightTextFromModel()
        }
        .onChange(of: set.reps) { _, _ in
            syncRepsTextFromModel()
        }
        .onChange(of: set.rpe) { _, _ in
            syncRPETextFromModel()
        }
        .onChange(of: weightText) { _, newValue in
            updateWeight(from: newValue)
        }
        .onChange(of: repsText) { _, newValue in
            updateReps(from: newValue)
        }
        .onChange(of: rpeText) { _, newValue in
            updateRPE(from: newValue)
        }
    }

    private var weightIsInvalid: Bool {
        guard !weightText.isEmpty else { return false }
        guard weightText != ".", let value = Double(weightText) else { return true }
        return value < 0
    }

    private var repsIsInvalid: Bool {
        guard !repsText.isEmpty else { return false }
        guard let value = Int(repsText) else { return true }
        return value <= 0
    }

    private var rpeIsInvalid: Bool {
        guard !rpeText.isEmpty else { return false }
        guard rpeText != ".", let value = Double(rpeText) else { return true }
        return !(0...10).contains(value)
    }

    private var previousSetSummary: String? {
        guard let previousSet else { return nil }

        var parts: [String] = []

        if let weight = previousSet.weight {
            parts.append("\(formatDecimal(weight, maxFractionDigits: 2)) lb")
        }

        if let reps = previousSet.reps {
            parts.append("\(reps) reps")
        }

        if let rpe = previousSet.rpe {
            parts.append("RPE \(formatDecimal(rpe, maxFractionDigits: 1))")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }

    @ViewBuilder
    private func numericField(
        title: String,
        text: Binding<String>,
        focusedCase: WorkoutSetInputField,
        keyboard: UIKeyboardType,
        isInvalid: Bool
    ) -> some View {
        TextField(title, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .multilineTextAlignment(.center)
            .font(.subheadline.monospacedDigit())
            .padding(.vertical, 6)
            .frame(width: 62)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isInvalid ? .red : Color.secondary.opacity(0.25), lineWidth: isInvalid ? 1.2 : 1)
            )
            .focused($focusedField, equals: focusedCase)
    }

    private func repeatPreviousValues() {
        guard let previousSet else { return }

        set.weight = previousSet.weight
        set.reps = previousSet.reps
        set.rpe = previousSet.rpe

        syncTextFromModel()
        onPersist()
    }

    private func syncTextFromModel() {
        syncWeightTextFromModel()
        syncRepsTextFromModel()
        syncRPETextFromModel()
    }

    private func syncWeightTextFromModel() {
        weightText = set.weight.map { formatDecimal($0, maxFractionDigits: 2) } ?? ""
    }

    private func syncRepsTextFromModel() {
        repsText = set.reps.map(String.init) ?? ""
    }

    private func syncRPETextFromModel() {
        rpeText = set.rpe.map { formatDecimal($0, maxFractionDigits: 1) } ?? ""
    }

    private func updateWeight(from value: String) {
        let sanitized = sanitizeDecimal(value, maxFractionDigits: 2)
        guard sanitized == value else {
            weightText = sanitized
            return
        }

        guard !sanitized.isEmpty else {
            if set.weight != nil {
                set.weight = nil
                onPersist()
            }
            return
        }

        guard sanitized != ".", let parsed = Double(sanitized), parsed >= 0 else { return }

        if set.weight != parsed {
            set.weight = parsed
            onPersist()
        }
    }

    private func updateReps(from value: String) {
        let sanitized = sanitizeInteger(value, maxDigits: 3)
        guard sanitized == value else {
            repsText = sanitized
            return
        }

        guard !sanitized.isEmpty else {
            if set.reps != nil {
                set.reps = nil
                onPersist()
            }
            return
        }

        guard let parsed = Int(sanitized), parsed > 0 else { return }

        if set.reps != parsed {
            set.reps = parsed
            onPersist()
        }
    }

    private func updateRPE(from value: String) {
        let sanitized = sanitizeDecimal(value, maxFractionDigits: 1)
        guard sanitized == value else {
            rpeText = sanitized
            return
        }

        guard !sanitized.isEmpty else {
            if set.rpe != nil {
                set.rpe = nil
                onPersist()
            }
            return
        }

        guard sanitized != ".", let parsed = Double(sanitized), (0...10).contains(parsed) else { return }

        if set.rpe != parsed {
            set.rpe = parsed
            onPersist()
        }
    }

    private func sanitizeInteger(_ text: String, maxDigits: Int) -> String {
        String(text.filter(\.isNumber).prefix(maxDigits))
    }

    private func sanitizeDecimal(_ text: String, maxFractionDigits: Int) -> String {
        let filtered = text.filter { $0.isNumber || $0 == "." }

        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count > 1 else {
            return filtered
        }

        let integerPart = String(parts[0])
        let fractionPart = String(parts.dropFirst().joined())
        let limitedFraction = String(fractionPart.prefix(maxFractionDigits))

        if filtered.hasPrefix(".") {
            return limitedFraction.isEmpty ? "." : ".\(limitedFraction)"
        }

        return limitedFraction.isEmpty ? "\(integerPart)." : "\(integerPart).\(limitedFraction)"
    }

    private func formatDecimal(_ value: Double, maxFractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumFractionDigits = 0
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
