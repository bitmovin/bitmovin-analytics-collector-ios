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
    private var player: Player?
    private var analyticsCollector: BitmovinAnalytics
    private var config: BitmovinAnalyticsConfig

    required init?(coder aDecoder: NSCoder) {
        config = BitmovinAnalyticsConfig(key: "e73a3577-d91c-4214-9e6d-938fb936818a")
        config.cdnProvider = CdnProvider.bitmovin
        config.customData1 = "customData1"
        config.customData2 = "customData2"
        config.customData3 = "customData3"
        config.customData4 = "customData4"
        config.customData5 = "customData5"
        config.customerUserId = "customUserId"
        config.experimentName = "experiment-1"
        config.videoId = "tvOSHLSStatic"
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
        let config = PlayerConfig()
        let playbackConfig = PlaybackConfig()
        playbackConfig.isAutoplayEnabled = true
        
        config.playbackConfig = playbackConfig
        // Create player based on player configuration
        let player = PlayerFactory.create(playerConfig: config)
        player.add(listener: self)
        analyticsCollector.attachBitmovinPlayer(player: player)

        // Create player view and pass the player instance to it
        let playerBoundaries = BitmovinPlayer.PlayerView(player: player, frame: .zero)

        // Listen to player events
        
        playerBoundaries.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundaries.frame = view.bounds

        view.addSubview(playerBoundaries)
        view.bringSubviewToFront(playerBoundaries)
        
        let sourceConfig = SourceConfig(url: streamUrl)
        let source = SourceFactory.create(from: sourceConfig!)
        player.load(source: source)
        self.player = player
    }
}

extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        print(event.name)
    }
}
