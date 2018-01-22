//
//  HttpUtil.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/17/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

class HttpClient {
    var config: BitmovinAnalyticsConfig
    
    init(config: BitmovinAnalyticsConfig) {
        self.config = config
    }
    
    func post(json: String){
        let url = URL(string: BitmovinAnalyticsConfig.analyticsUrl)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("http://\(Util.bundle())", forHTTPHeaderField: "Origin")
        request.httpMethod = "POST"
        let postString = json
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {                                                 // check for fundamental networking error
                print("Http Error: \(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {           // check for http errors
                print("StatusCode: \(httpStatus.statusCode)")
            }
        }
        task.resume()
    }
    
}
