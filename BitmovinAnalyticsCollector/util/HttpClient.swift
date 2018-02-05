//
//  HttpUtil.swift
//  BitmovinAnalyticsCollector
//
//  Created by Cory Zachman on 1/17/18.
//  Copyright © 2018 Bitmovin. All rights reserved.
//

import Foundation

typealias HttpCompletionHandlerType = ((_ data: Data?, _ response: URLResponse?, _ error:Error?) -> ())

class HttpClient {
    var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func post(json: String, completionHandler: HttpCompletionHandlerType?) -> Void {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("http://\(Util.bundle())", forHTTPHeaderField: "Origin")
        request.httpMethod = "POST"
        let postString = json
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {// check for fundamental networking error
                print(String(describing: error))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {           // check for http errors
                print("HTTP Analytics response: \(httpStatus.statusCode)")
            }
            completionHandler?(data,response,error)
        }
        task.resume()
    }
    
}
