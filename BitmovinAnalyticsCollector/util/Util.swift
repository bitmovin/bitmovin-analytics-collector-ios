//
//  Util.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/10/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation
import CoreTelephony

class Util {
    static func bundle() -> String {
        guard let bundle = Bundle.main.bundleIdentifier else {
            return "Unknow"
        }
        return bundle;
    }
    
    static func language() -> String {
        return Locale.current.identifier
    }
    
    static func userAgent() -> String {
        let model = UIDevice.current.model
        let product = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown Product"
        let scale = UIScreen.main.scale
        let height = UIScreen.main.bounds.size.height * scale
        let version = UIDevice.current.systemVersion
        let carrier = CTTelephonyNetworkInfo.init().subscriberCellularProvider?.carrierName ?? "Unknown Carrier"
        

        let userAgent = String(format: "%@ / Apple; %@ %.f / iOS %@ / %@",product,model,height,version,carrier)
        
        return userAgent
    }
}

extension Date {
    var timeIntervalSince1970Millis: Int {
        return Int(round(Date().timeIntervalSince1970 * 1000))
    }
}
