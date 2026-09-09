import Foundation
import AVFoundation
import CoreGraphics
import Combine

class AudioLevelManager: ObservableObject {
    @Published var level: CGFloat = 0.0
    @Published var isRecording: Bool = false
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    func startMonitoring() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)
            try session.setActive(true)
            
            session.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.setupRecorder()
                    } else {
                        print("Microphone permission denied.")
                    }
                }
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupRecorder() {
        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            
            // Update level very frequently (60fps ~ 0.016s) for smooth animation
            timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
                self?.updateLevel()
            }
        } catch {
            print("Failed to start audio recorder: \(error.localizedDescription)")
        }
    }
    
    private func updateLevel() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.updateMeters()
        // Audio power ranges from -160 dB (quiet) to 0 dB (loud).
        // For a more sensitive animation, we cap the minimum at -50 dB.
        let power = recorder.averagePower(forChannel: 0)
        
        let minDb: Float = -50.0
        let normalizedLevel: Float
        
        if power < minDb {
            normalizedLevel = 0.0
        } else if power >= 0.0 {
            normalizedLevel = 1.0
        } else {
            // Linear mapping
            normalizedLevel = (power - minDb) / (0.0 - minDb)
        }
        
        // Smooth out the animation by interpolating
        let targetLevel = CGFloat(normalizedLevel)
        let currentLevel = self.level
        
        // Simple low-pass filter
        self.level = currentLevel + (targetLevel - currentLevel) * 0.2
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        level = 0.0
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
