//
//  AdBreak.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class AdBreak {
    var id: String
    var ads: Array<Ad>
    var position: AdPosition?
    var offset: String?
    var scheduleTime: Double?
    var replaceContentDuration: Double?
    var preloadOffset: Double?
    var tagType: AdTagType?
    var tagUrl: String?
    var persistent: Bool?
    var fallbackIndex: Double = 0
    
    init(id: String, ads: Array<Ad>) {
        self.id = id
        self.ads = ads
    }
}
