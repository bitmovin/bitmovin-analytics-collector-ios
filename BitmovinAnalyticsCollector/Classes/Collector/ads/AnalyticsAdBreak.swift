//
//  AdBreak.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class AnalyticsAdBreak {
    var id: String
    var ads: Array<Ad>
    var position: AdPosition?
    var offset: String?
    var scheduleTime: Int64?
    var replaceContentDuration: Int64?
    var preloadOffset: Int64?
    var tagType: AdTagType?
    var tagUrl: String?
    var persistent: Bool?
    var fallbackIndex: Int = 0
    
    init(id: String, ads: Array<Ad>) {
        self.id = id
        self.ads = ads
    }
}
