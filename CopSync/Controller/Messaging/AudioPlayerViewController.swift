import UIKit

class AudioPlayerViewController: UIViewController {
    
    var audioPlayerView: UIView?
    var playAudioButton: UIButton?
    var audioController: MediaController?
    var seekBarView: UIView?
    var seekBarAnimDuration: NSTimeInterval?
    var seekBarWidth: CGFloat?
    var seekBarYPos: CGFloat?
    var isAudioPlaying = false
    var tappableView: UIView?
    var seekBarStartWidth: CGFloat?
    var seekBarLayerView: UIView?
    var isTapped = false
    var chatBubbleData: ChatBubbleData?
    var chatBubble: ChatBubble?
    
    func addAudioPlayerView(messageMaxYPos: CGFloat, sourceType: DataSourceType, parentView: UIScrollView, audioController: MediaController) -> CGFloat{
        self.audioController = audioController
        self.audioPlayerView = UIView(frame: ChatBubble.framePrimary(sourceType, startY: messageMaxYPos + 15))
        self.audioPlayerView?.center.x = (self.audioPlayerView?.center.x)! + 10
        self.audioPlayerView?.frame.size.width = (self.audioPlayerView?.frame.width)! - 20
        self.chatBubbleData = ChatBubbleData(text: "", image: nil, sourceType: .Sender, audioMessageView: self.audioPlayerView)
        self.chatBubble = ChatBubble(data: chatBubbleData!, startY: messageMaxYPos + 10)
        
        addPlayButton()
        addSeekBarView()
        self.chatBubble?.addSubview(self.audioPlayerView!)
        parentView.addSubview(self.chatBubble!)
        parentView.addSubview(audioPlayerView!)
        return CGRectGetMaxY((self.audioPlayerView?.frame)!)
    }
    
    func addPlayButton() {
        self.playAudioButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.audioPlayerView!.frame.height, height: self.audioPlayerView!.frame.height))
        self.playAudioButton?.setImage(UIImage(named: "playButton"), forState: .Normal)
        self.playAudioButton!.addTarget(self, action: #selector(AudioPlayerViewController.playAudio), forControlEvents: .TouchUpInside)
        self.playAudioButton?.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.audioPlayerView!.addSubview(self.playAudioButton!)
    }
    
    func addSeekBarView() {
        self.seekBarWidth = (self.audioPlayerView?.frame.width)! - (self.playAudioButton?.frame.width)!
        self.seekBarYPos = (self.audioPlayerView?.center.y)! - (audioPlayerView?.frame.origin.y)!
        self.seekBarView = UIView(frame: CGRect(x: CGRectGetMaxX(self.playAudioButton!.frame) + 6, y: 0, width: self.seekBarWidth! - 6, height: self.audioPlayerView!.frame.height / 2))
        self.seekBarView?.center.y = self.seekBarYPos!
        self.seekBarView?.layer.cornerRadius = 3
        self.seekBarView!.backgroundColor = UIColor.purpleColor()
        self.audioPlayerView!.addSubview(self.seekBarView!)
    }
    
    func addSeekBarLayerView() {
       self.seekBarLayerView = UIView(frame: CGRect(x: CGRectGetMaxX(self.playAudioButton!.frame) + 6, y: 0, width: 0, height: self.audioPlayerView!.frame.height / 2))
        self.seekBarLayerView!.center.y = self.seekBarYPos!
        self.seekBarLayerView!.layer.cornerRadius = 5
        self.seekBarLayerView!.backgroundColor = UIColor.orangeColor()
        self.audioPlayerView!.addSubview(self.seekBarLayerView!)
    }
    
    func animateSeekBarLayerView() {
        UIView.animateWithDuration(self.seekBarAnimDuration!, animations: {
            self.seekBarLayerView!.frame.size.width = (self.audioPlayerView?.frame.width)! - (self.playAudioButton?.frame.width)! - 6
            }) { finished in
                self.stopPlayingAudio()
            }
    }
    
    func playAudio() {
        if !isAudioPlaying {
            self.isAudioPlaying = true
            self.playAudioButton?.setImage(UIImage(named: "stopButton"), forState: .Normal)
            self.seekBarAnimDuration =  self.audioController!.playAudio()
            addSeekBarLayerView()
            animateSeekBarLayerView()
        } else {
            stopPlayingAudio()
        }
    }
    
    func stopPlayingAudio() {
        self.isAudioPlaying = false
        self.playAudioButton?.setImage(UIImage(named: "playButton"), forState: .Normal)
        self.audioController?.stopPlayingAudio()
        self.seekBarLayerView?.frame.size.width = 0
        self.seekBarLayerView?.layer.removeAllAnimations()
    }
    
}
