//
//  TryVoiceView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct TryVoiceView: View {
    @StateObject private var audioManager = AudioLevelManager()
    @State private var isListening = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text(isListening ? "I'm Listening" : "Tap to Speak")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            ZStack {
                // Outer circle (static)
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 300)
                
                // Middle circle (static)
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 230, height: 230)
                
                // Inner circle (static)
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 170, height: 170)
                
                // Center button (Animated Waveform)
                Button(action: {
                    toggleListening()
                }) {
                    AudioWaveformView(level: isListening ? audioManager.level : 0)
                        .frame(width: 150, height: 120)
                        .contentShape(Rectangle()) // Make the whole frame tappable
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(height: 350)
            
            Spacer()
            
            Text("\"Today My Expense Meat ball, Cash 35K\nin Greenland Batam\"")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .onDisappear {
            audioManager.stopMonitoring()
        }
    }
    
    private func toggleListening() {
        if isListening {
            audioManager.stopMonitoring()
            isListening = false
        } else {
            audioManager.startMonitoring()
            isListening = true
        }
    }
}

struct AudioWaveformView: View {
    let level: CGFloat
    
    // We'll use 11 bars to match the new design
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<11) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary)
                    .frame(width: 5, height: barHeight(for: index))
                    .animation(.spring(response: 0.15, dampingFraction: 0.7), value: level)
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        // Base minimum height based on distance from center
        let center = 5.0
        let distance = abs(CGFloat(index) - center)
        
        // Base height is smaller at edges, larger in middle
        let baseMinHeight: CGFloat = 8 + (5 - distance) * 2
        
        // Multiplier based on distance from center
        // Middle bar (index 5) moves the most, outer bars move less
        let multiplier = 1.0 - (distance * 0.15)
        
        // Dynamic height can go up to 100 for the center bar
        let dynamicHeight = level * 100 * multiplier
        return baseMinHeight + dynamicHeight
    }
}
