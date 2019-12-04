//
//  AdAdapter.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import Foundation
protocol AdAdapter{
    func releaseAdapter()
    func getModuleInformation() -> AdModuleInformation
    func isAutoPlayEnabled() -> Bool
}
