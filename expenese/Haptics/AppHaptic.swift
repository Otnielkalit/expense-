//
//  AppHaptic.swift
//  expenese
//

import SwiftUI
import UIKit

struct HapticPulse: Equatable {
    private(set) var generation = 0
    private(set) var feedback: SensoryFeedback = .selection

    mutating func play(_ feedback: SensoryFeedback) {
        self.feedback = feedback
        generation += 1
    }
}

extension View {
    func hapticPulse(_ pulse: HapticPulse) -> some View {
        sensoryFeedback(pulse.feedback, trigger: pulse.generation)
    }
}

enum AppHaptic {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
    }

    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.85)
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
