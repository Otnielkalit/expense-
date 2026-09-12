//
//  TryVoiceView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI

struct TryVoiceView: View {
    @StateObject private var audioManager = AudioLevelManager()
    @State private var isRecording = false
    @State private var showManual = false
    
    var body: some View {
        VStack(spacing: 60) {
            
            Spacer()
            VStack(spacing: 8) {
                Text("Tell Me **Your**")
                Text("**Expense** or **Income !**")
            }
            .font(.system(size: 32))
            .multilineTextAlignment(.center)
            .foregroundColor(.black)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isRecording.toggle()
                    if isRecording {
                        audioManager.startMonitoring()
                    } else {
                        audioManager.stopMonitoring()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 320, height: 320)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 250, height: 250)
                        .scaleEffect(isRecording ? 1.05 : 1.0)
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 180, height: 180)
                    if isRecording {
                        AudioWaveformView(level: audioManager.level)
                            .frame(width: 80, height: 60)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action: {
                showManual = true 
            }) {
                Text("+ Add Manual")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color(red: 0, green: 0.5, blue: 1.0))
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .fullScreenCover(isPresented: $showManual) {
            AddExpenseManualView()
        }

        .onDisappear {
            audioManager.stopMonitoring()
            isRecording = false
        }
    }
}

struct AudioWaveformView: View {
    let level: CGFloat
    
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
        let center = 5.0
        let distance = abs(CGFloat(index) - center)
        let baseMinHeight: CGFloat = 8 + (5 - distance) * 2
        let multiplier = 1.0 - (distance * 0.15)
        let dynamicHeight = level * 100 * multiplier
        return baseMinHeight + dynamicHeight
    }
}
