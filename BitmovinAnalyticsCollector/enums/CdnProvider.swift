//
//  CdnProvider.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/8/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

public enum CdnProver : String{
    case bitmovin = "bitmovin"
    case akamai = "akamai"
    case fastly = "fastly"
    case maxcdn = "maxcdn"
    case cloudfront = "cloudfront"
    case chinacache = "chinacache"
    case bitgravity = "bitgravity"
}
