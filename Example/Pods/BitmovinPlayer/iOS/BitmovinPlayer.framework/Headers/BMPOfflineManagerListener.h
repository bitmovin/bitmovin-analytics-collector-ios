//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

@class BMPOfflineManager;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for listeners for the BMPOfflineManager.
 */
NS_SWIFT_NAME(OfflineManagerListener)
@protocol BMPOfflineManagerListener <NSObject>
/**
 * Is called when the download of the media content failed for some reason. Downloaded content may have been stored to
 * disk. It is possible to retry by first checking the state of the sourceItem (BMPOfflineManager#offlineStateForSourceItem:)
 * and taking the appropriate actions which are allowed in the current state as documented in BMPOfflineManager.h
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 * @param error An optional error object describing the cause of the failure.
 */
- (void)offlineManager:(BMPOfflineManager *)offlineManager didFailWithError:(nullable NSError *)error;
/**
 * Is called when the download of the media content was successful, and everything is written to disk.
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 */
- (void)offlineManagerDidFinishDownload:(BMPOfflineManager *)offlineManager;
/**
 * Is called then the download of the media content progressed to a new percentage value. The method is only called when
 * the according SourceItem is in state BMPOfflineStateDownloading.
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 * @param progress The percentage of completion for the current download task.
 */
- (void)offlineManager:(BMPOfflineManager *)offlineManager didProgressTo:(double)progress;
/**
 * Is called when the download of the media content was suspended. This could be the result of a call to
 * BMPOfflineManager#suspendDownloadForSourceItem: or if the app was terminated by the user while downloads were running.
 * In the latter case, this listener method is called upon first application startup after termination.
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 */
- (void)offlineManagerDidSuspendDownload:(BMPOfflineManager *)offlineManager;
/**
 * Is called when the download of the media content was resumed after it was suspended.
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 * @param progress The percentage of completion for the current download task.
 */
- (void)offlineManager:(BMPOfflineManager *)offlineManager didResumeDownloadWithProgress:(double)progress;
/**
 * Is called when the download of the media content was cancelled by the user and all partially downloaded content has been
 * deleted from disk.
 *
 * @param offlineManager The BMPOfflineManager calling the listener.
 */
- (void)offlineManagerDidCancelDownload:(BMPOfflineManager *)offlineManager;
@end

NS_ASSUME_NONNULL_END
