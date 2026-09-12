//
//  SpeechRecognizer.swift
//  expenese
//

import Foundation
import AVFoundation
import Speech
import SwiftUI
import Combine

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    
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
                    print("Speech recognition authorization denied")
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
