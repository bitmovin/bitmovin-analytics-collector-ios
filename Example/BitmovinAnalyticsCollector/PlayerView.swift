//
//  PlayerView.swift
//  BitmovinAnalyticsSampleApp
//
//  Created by Cory Zachman on 1/15/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }

        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
