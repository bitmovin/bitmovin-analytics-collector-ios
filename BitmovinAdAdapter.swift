//
//  BitmovinAdAdapter.swift
//  Pods
//
//  Created by Thomas Sabe on 03.12.19.
//

import BitmovinPlayer
import Foundation
public class BitmovinAdAdapter: AdAdapter{
    
    private var bitmovinPlayer: BitmovinPlayer
    private var adAnalytics: BitmovinAdAnalytics
    
    internal init(bitmovinPlayer: BitmovinPlayer, adAnalytics: BitmovinAdAnalytics){
        self.adAnalytics = adAnalytics;
        self.bitmovinPlayer = bitmovinPlayer;
    }
    
    func release() {
    
    }
}
