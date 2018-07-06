//
//  ViewController.swift
//  BitmovinAnalyticsCollector_tvOSExample
//
//  Created by Cory Zachman on 7/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinAnalyticsCollector

class ViewController: UIViewController {
    private var player: BitmovinPlayer?
    private var analyticsCollector: BitmovinAnalytics
    private var config: BitmovinAnalyticsConfig

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: "9ae0b480-f2ee-4c10-bc3c-cb88e982e0ac")
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "iOSHLSStatic"
        config.path = "/vod/breadcrumb/"

        analyticsCollector = BitmovinAnalytics(config: config)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        self.view.backgroundColor = .black

        // Define needed resources
        guard let streamUrl = URL(string: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8") else {
            return
        }

        // Create player configuration
        let config = PlayerConfiguration()
        let playbackConfig = PlaybackConfiguration()
        playbackConfig.isAutoplayEnabled = true
        do {
            try config.setSourceItem(url: streamUrl)
            config.playbackConfiguration = playbackConfig
            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)
            analyticsCollector.attachBitmovinPlayer(player: player)

            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            // Listen to player events
            player.add(listener: self)

            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds

            view.addSubview(playerView)
            view.bringSubview(toFront: playerView)

            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }
}

extension ViewController: PlayerListener {
    func onError(_ event: ErrorEvent) {
        print("onError \(event.message)")
    }
}
