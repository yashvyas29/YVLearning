//: A AV based Playground for text to speech

import AVFoundation
import AVKit
import PlaygroundSupport

var str = "Hello Yash!\nWelcome to text to speech playground."

let synthesizer = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: str)
utterance.rate = 0.4
utterance.voice = AVSpeechSynthesisVoice(language: "en-IN")

// For playground only
let playerViewController = AVPlayerViewController()
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = playerViewController.view
//

synthesizer.speak(utterance)

// Pause, Continue and Stop
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    synthesizer.pauseSpeaking(at: .word)
}
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    synthesizer.continueSpeaking()
}
DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
    synthesizer.stopSpeaking(at: .immediate)
}
