//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

/**
 * States a source item can have regarding to offline playback and offline DRM.
 */
NS_SWIFT_NAME(OfflineState)
typedef NS_ENUM(NSInteger, BMPOfflineState) {
    /** Indicates that the content is completely downloaded and stored on disk. */
    BMPOfflineStateDownloaded,
    /**
     * Indicates that the content is currently downloading. In this state there may be already some offline data
     * stored on disk.
     */
    BMPOfflineStateDownloading,
    /** Indicates that the downloading of the content was suspended and the locally stored data is incomplete. */
    BMPOfflineStateSuspended,
    /** Indicates that the content is not downloaded. There is no data stored on disk. */
    BMPOfflineStateNotDownloaded,
    /**
     * Indicates that the download is cancelling. When cancellation succeeded and all partially downloaded data
     * was deleted, the BMPOfflineManager sends offlineManagerDidCancelDownload:. At this point the according
     * BMPSourceItem is in state BMPOfflineStateNotDownloaded again.
     */
    BMPOfflineStateCanceling
};
