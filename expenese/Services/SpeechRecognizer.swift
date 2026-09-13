//
//  SpeechRecognizer.swift
//  expenese
//

import Foundation
import AVFoundation
import Speech
import SwiftUI
import Combine
import UIKit

enum VoiceAccessAlert: String, Identifiable {
    case speechRecognition
    case microphone
    case both

    var id: String { rawValue }

    var title: String {
        switch self {
        case .speechRecognition: "Voice Recognition Is Off"
        case .microphone: "Microphone Is Off"
        case .both: "Voice Access Is Off"
        }
    }

    var message: String {
        switch self {
        case .speechRecognition:
            "Turn on Speech Recognition in Settings to add expenses with your voice."
        case .microphone:
            "Turn on Microphone in Settings so Expense can hear what you say."
        case .both:
            "Turn on Microphone and Speech Recognition in Settings to add expenses with your voice."
        }
    }

    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var startFailed = false
    @Published var accessAlert: VoiceAccessAlert?

    static func accessAlertIfBlocked() -> VoiceAccessAlert? {
        let speech = SFSpeechRecognizer.authorizationStatus()
        let speechOff = speech == .denied || speech == .restricted
        let micOff = AVAudioApplication.shared.recordPermission == .denied

        switch (speechOff, micOff) {
        case (true, true): return .both
        case (true, false): return .speechRecognition
        case (false, true): return .microphone
        case (false, false): return nil
        }
    }
    
    private var audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        // We use Indonesian for our NLP parser
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))
    }
    
    func startTranscribing() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self?.beginRecording()
                } else {
                    self?.accessAlert = Self.accessAlertIfBlocked() ?? .speechRecognition
                }
            }
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        isRecording = false
    }
    
    private func beginRecording() {
        if AVAudioApplication.shared.recordPermission == .denied {
            accessAlert = Self.accessAlertIfBlocked() ?? .microphone
            return
        }

        // Cancel previous task if running
        if let task = task {
            task.cancel()
            self.task = nil
        }
        
        transcript = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
            startFailed = true
            return
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        request.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = false
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine failed to start: \(error)")
            startFailed = true
            return
        }
        
        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcript = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.request = nil
                self?.task = nil
                DispatchQueue.main.async {
                    self?.isRecording = false
                }
            }
        }
    }
}
