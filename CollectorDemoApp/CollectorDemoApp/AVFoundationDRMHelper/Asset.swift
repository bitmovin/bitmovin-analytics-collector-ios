/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A simple class that holds information about an Asset.
 */
import AVFoundation

class Asset {

    static let assetResourceLoaderDelegateQueue = DispatchQueue(label: "com.example.apple-samplecode.HLSCatalog.AssetResourceLoaderDelegateQueue")

    /// The AVURLAsset corresponding to this Asset.
    var urlAsset: AVURLAsset
    
    var delegate: AssetResourceLoaderDelegate?
    var fairPlayConfig: FairPlayConfiguration?

    init(urlAsset: AVURLAsset, fpsConfig: FairPlayConfiguration) {
        self.urlAsset = urlAsset

        self.fairPlayConfig = fpsConfig
        self.delegate = AssetResourceLoaderDelegate(asset: self)
        self.urlAsset.resourceLoader.setDelegate(self.delegate!, queue: Asset.assetResourceLoaderDelegateQueue)
    }
}

/// Extends `Asset` to conform to the `Equatable` protocol.
extension Asset: Equatable {
    static func ==(lhs: Asset, rhs: Asset) -> Bool {
        return lhs.urlAsset == rhs.urlAsset
    }
}

/**
 Extends `Asset` to add a simple download state enumeration used by the sample
 to track the download states of Assets.
 */
extension Asset {
    enum DownloadState: String {
        
        /// The asset is not downloaded at all.
        case notDownloaded
        
        /// The asset has a download in progress.
        case downloading
        
        /// The asset is downloaded and saved on disk.
        case downloaded
    }
}

/**
 Extends `Asset` to define a number of values to use as keys in dictionary lookups.
 */
extension Asset {
    struct Keys {
        /**
         Key for the Asset name, used for `AssetDownloadProgressNotification` and
         `AssetDownloadStateChangedNotification` Notifications as well as
         AssetListManager.
         */
        static let name = "AssetNameKey"
        
        /**
         Key for the Asset download percentage, used for
         `AssetDownloadProgressNotification` Notification.
         */
        static let percentDownloaded = "AssetPercentDownloadedKey"
        
        /**
         Key for the Asset download state, used for
         `AssetDownloadStateChangedNotification` Notification.
         */
        static let downloadState = "AssetDownloadStateKey"
        
        /**
         Key for the Asset download AVMediaSelection display Name, used for
         `AssetDownloadStateChangedNotification` Notification.
         */
        static let downloadSelectionDisplayName = "AssetDownloadSelectionDisplayNameKey"
    }
}
