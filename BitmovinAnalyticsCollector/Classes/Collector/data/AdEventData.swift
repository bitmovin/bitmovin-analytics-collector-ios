//
//  AdEventData.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
public class AdEventData: Codable {
    
    public func jsonString() -> String {
           let encoder = JSONEncoder()
           if #available(iOS 11.0, tvOS 11.0, *) {
               encoder.outputFormatting = [.sortedKeys]
           }

           encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "Negative Infinity", nan: "nan")
           do {
               let jsonData = try encoder.encode(self)
               guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                   return ""
               }

               return jsonString
           } catch {
               return ""
           }
       }
}
