import AmazonIVSPlayer
import Foundation

// Handles logic to use UI components to control player
class IVSPlayerController: NSObject {
    private weak var player: IVSPlayer?

    // UI Components
    private let playButton: UIButton
    private let seekSlider: UISlider
    private let bufferIndicator: UIActivityIndicatorView

    init(
        playButton: UIButton,
        seekSlider: UISlider,
        bufferIndicator: UIActivityIndicatorView
    ) {
        self.playButton = playButton
        self.seekSlider = seekSlider
        self.bufferIndicator = bufferIndicator
        super.init()

        registerUIListener()
        setUpDisplayLink()
    }

    func attachPlayer(player: IVSPlayer) {
        self.player = player
        registerPlayerListener()
        seekSlider.setValue(0.0, animated: false)
    }

    func detachPlayer() {
        seekSlider.isHidden = true
        self.player = nil
    }

    func release() {
        tearDownDisplayLink()
    }

    private func registerUIListener() {
        playButton.addTarget(self, action: #selector(mainButtonPressed), for: .touchUpInside)
        seekSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    // MARK: - Play / Pause handling
    @objc
    func mainButtonPressed() {
        guard let player = player else {
            return
        }
        if isPlaying() {
            player.pause()
        } else {
            player.play()
        }
    }

    // https://github.com/aws-samples/amazon-ivs-player-ios-sample/blob/master/BasicPlayback/BasicPlayback/ViewController.swift
    // MARK: - Seek handling
    private var playbackPositionDisplayLink: CADisplayLink?

    private enum SeekStatus: Equatable {
        case choosing(Float)
        case requested(CMTime)
    }

    private var seekStatus: SeekStatus? {
        didSet {
            updatePositionDisplay()
        }
    }

    private func setUpDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(updatePositionDisplay))
        displayLink.preferredFramesPerSecond = 5
        displayLink.isPaused = player?.state != .playing
        displayLink.add(to: .main, forMode: .common)
        playbackPositionDisplayLink = displayLink
        seekSlider.isHidden = true
    }

    private func tearDownDisplayLink() {
        playbackPositionDisplayLink?.invalidate()
        playbackPositionDisplayLink = nil
    }

    @objc
    func updatePositionDisplay() {
        guard let player = player else {
            return
        }

        if seekStatus == nil {
            updateSeekSlider(position: player.position, duration: player.duration)
        }
    }

    @objc
    func sliderValueChanged(sender: UISlider, event: UIEvent) {
        guard let touchEvent = event.allTouches?.first else {
            seek(toFractionOfDuration: sender.value)
            return
        }

        switch touchEvent.phase {
        case .began, .moved:
            seekStatus = .choosing(sender.value)

        case .ended:
            seek(toFractionOfDuration: sender.value)

        case .cancelled:
            seekStatus = nil

        default: ()
        }
    }

    private func updateSeekSlider(position: CMTime, duration: CMTime) {
        if duration.isNumeric && position.isNumeric {
            let scaledPosition = position.convertScale(duration.timescale, method: .default)
            let progress = Double(scaledPosition.value) / Double(duration.value)
            seekSlider.setValue(Float(progress), animated: false)
        }
    }

    private func seek(toFractionOfDuration fraction: Float) {
        guard let player = player else {
            seekStatus = nil
            return
        }
        let position = CMTimeMultiplyByFloat64(player.duration, multiplier: Float64(fraction))
        seek(to: position)
    }

    private func seek(to position: CMTime) {
        guard let player = player else {
            seekStatus = nil
            return
        }
        seekStatus = .requested(position)
        player.seek(to: position) { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.seekStatus == .requested(position) {
                self.seekStatus = nil
            }
        }
    }

    private func updateForDuration(duration: CMTime) {
        if duration.isIndefinite {
            seekSlider.isHidden = true
        } else if duration.isNumeric {
            seekSlider.isHidden = false
        } else {
            seekSlider.isHidden = true
        }
    }

    // MARK: - Player
    private func isPlaying() -> Bool {
        guard let player = player else {
            return false
        }
        return player.state == .playing || player.state == .buffering
    }

    private func registerPlayerListener() {
        player?.delegate = self
    }

    // MARK: - State Handling
    private func updateForState(_ state: IVSPlayer.State) {
        // seeking
        playbackPositionDisplayLink?.isPaused = state != .playing

        // play / pause
        let showPause = state == .playing || state == .buffering
        let buttonImageName = showPause ? "PauseButton" : "PlayButton"
        let buttonImage = UIImage(named: buttonImageName)

        playButton.setImage(buttonImage, for: UIControl.State())

        // buffering
        if state == .buffering {
            bufferIndicator.startAnimating()
        } else {
            bufferIndicator.stopAnimating()
        }
    }
}

extension IVSPlayerController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        updateForState(state)
    }

    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        updateForDuration(duration: duration)
    }
}
