//
//  AdSample.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class AdSample{
    var adStartupTime: Double?
    var clicked: Double = 0
    var clickPosition: Double?
    var closed: Double = 0
    var closePosition: Double?
    var completed: Double = 0
    var midpoint: Double?
    var percentageInViewport: Int?
    var quartile1: Double = 0
    var quartile3: Double = 0
    var skipped: Double = 0
    var skipPosition: Double?
    var started: Double = 0
    var timeHovered: Double?
    var timeInViewport: Double?
    var timePlayed: Double?
    var timeUntilHover: Double?
    var adPodPosition: Int?
    var exitPosition: Double?
    var playPercentage: Int?
    var skipPercentage: Int?
    var clickPercentage: Int?
    var closePercentage: Int?
    var errorPosition: Double?
    var errorPercentage: Int?
    var timeToContent: Double?
    var timeFromContent: Double?
    var manifestDownloadTime: Double?
    var errorCode: Int?
    var errorData: String?
    var errorMessage: String?
    var ad: Ad = Ad()
}
