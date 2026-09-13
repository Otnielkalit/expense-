//
//  TryVoiceView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct TryVoiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var customCategories: [Category]
    
    @StateObject private var audioManager = AudioLevelManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var showManual = false
    @State private var draftPayload: DraftPayload?
    @State private var voiceHaptic = HapticPulse()
    @State private var voiceAccessAlert: VoiceAccessAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Your **Expenses**")
                .font(.system(size: 32))
                .foregroundColor(.black)
                .padding(.top, 80)
            
            Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 60, height: 60)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            if isRecording {
                Text("\"\(speechRecognizer.transcript.isEmpty ? "Listening..." : speechRecognizer.transcript)\"")
                    .font(.system(size: 22, weight: .regular).italic())
                    .foregroundColor(Color(hex: "3A3A3C"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(height: 80)
            } else {
                Text("\"Tap the mic to add expense\"")
                    .font(.system(size: 22, weight: .regular).italic())
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .frame(height: 80)
            }
            
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
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .fullScreenCover(isPresented: $showManual) {
            AddExpenseManualView()
        }
        .sheet(item: $draftPayload) { payload in
            EditExpenseView(drafts: payload.items)
        }
        .hapticPulse(voiceHaptic)
        .alert(
            voiceAccessAlert?.title ?? "Voice Recognition Is Off",
            isPresented: Binding(
                get: { voiceAccessAlert != nil },
                set: { if !$0 { voiceAccessAlert = nil } }
            )
        ) {
            Button("Open Settings") {
                VoiceAccessAlert.openSettings()
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text(voiceAccessAlert?.message ?? "")
        }
        .onChange(of: speechRecognizer.isRecording) { _, recording in
            if recording {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isRecording = true
                }
                voiceHaptic.play(.start)
            }
        }
        .onChange(of: speechRecognizer.accessAlert) { _, alert in
            guard let alert else { return }
            resetIdleState()
            showAccessAlert(alert)
            speechRecognizer.accessAlert = nil
        }
        .onChange(of: speechRecognizer.startFailed) { _, failed in
            guard failed else { return }
            resetIdleState()
            voiceHaptic.play(.error)
            speechRecognizer.startFailed = false
        }
        .onDisappear {
            audioManager.stopMonitoring()
            speechRecognizer.stopTranscribing()
            isRecording = false
        }
    }

    private func startRecording() {
        if let alert = SpeechRecognizer.accessAlertIfBlocked() {
            showAccessAlert(alert)
            return
        }

        audioManager.startMonitoring()
        speechRecognizer.startTranscribing()
    }

    private func showAccessAlert(_ alert: VoiceAccessAlert) {
        voiceAccessAlert = alert
        voiceHaptic.play(.warning)
    }

    private func resetIdleState() {
        isRecording = false
        audioManager.stopMonitoring()
        speechRecognizer.stopTranscribing()
    }

    private func stopRecording() {
        audioManager.stopMonitoring()
        speechRecognizer.stopTranscribing()
        isRecording = false

        let text = speechRecognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            voiceHaptic.play(.warning)
            return
        }

        voiceHaptic.play(.stop)
        processSpeech(text)
    }
    
    private func processSpeech(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let categoryNames = customCategories.map { $0.name }
        let parsedList = NLPParser.parse(text, customCategories: categoryNames)
        let drafts = parsedList.map { parsed in
            Draft(
                amount: parsed.amount,
                category: parsed.category,
                paymentMethod: parsed.paymentMethod,
                paymentType: parsed.paymentType,
                desc: parsed.description,
                date: parsed.date,
                isExpense: parsed.isExpense
            )
        }
        draftPayload = DraftPayload(items: drafts)
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
