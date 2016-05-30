import Foundation
import AVFoundation

public class MediaController: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioURL: NSURL?
    var audioDuration =  NSTimeInterval()
    
    func startRecording() {
        let audioFileName = getDocumentDirectory().stringByAppendingString("/recording.m4a")
        self.audioURL = NSURL(fileURLWithPath: audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(URL: self.audioURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        if success {
            print("successfully recorded")
        } else {
            print("Something went wrong")
        }
        
    }
    
    func getDocumentDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return path[0]
        
    }

    
    func stopPlayingAudio() {
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
        }
    }
    
    func playAudio() -> NSTimeInterval {
        // set URL of the sound
        let soundURL = self.audioURL
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: soundURL!)
            self.audioPlayer!.delegate = self
            // check if audioPlayer is prepared to play audio
            if (self.audioPlayer!.prepareToPlay()) {
                self.audioDuration = (self.audioPlayer?.duration)!
                self.audioPlayer?.play()
            }
        }
        catch {
            return 0
        }
        return audioDuration
    }
    
    func updateCurrentAudioTime(currentPositionRatio: CGFloat) -> NSTimeInterval {
        let updatedTime = NSTimeInterval(currentPositionRatio) * audioDuration
        self.audioPlayer?.currentTime = updatedTime
        print(self.audioDuration)
        return updatedTime
    }
    
}