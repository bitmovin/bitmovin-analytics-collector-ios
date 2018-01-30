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
    
    static func version() -> String? {
        return Bundle(identifier: "com.bitmovin.BitmovinAnalyticsCollector")?.infoDictionary?["CFBundleShortVersionString"]  as? String;
    }
    
    static func toJson<T: Codable>(object: T?) -> String  {
        let encoder = JSONEncoder();
        if #available(iOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }
        
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
        do {
            let jsonData = try encoder.encode(object)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
            }
            
            return jsonString
        }
        catch {
            return ""
        }
    }
}

extension Date {
    var timeIntervalSince1970Millis: Int {
        return Int(round(Date().timeIntervalSince1970 * 1000))
    }
}
