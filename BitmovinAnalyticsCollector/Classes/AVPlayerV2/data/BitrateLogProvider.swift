//
//  AccessLogProvider.swift
//  Pods
//
//  Created by Thomas Sabe on 05.05.22.
//

import Foundation

protocol BitrateLogProvider {
    func getEvents() -> [BitrateLogDto]?
}
