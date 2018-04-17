//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPOfflineState.h>
#import <BitmovinPlayer/BMPSourceItem.h>
#import <BitmovinPlayer/BMPOfflineManagerListener.h>
#import <BitmovinPlayer/BMPOfflineSourceItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * IMPORTANT: Methods from BMPOfflineManager need to be called from the main thread.
 *
 * This class offers functionality to handle the whole lifecycle of protected and unprotected offline content. Do not
 * create own instances of it, instead use [OfflineManager sharedInstance] to obtain a reference to the singleton.
 *
 * Depending on the current state of the SourceItem, which can be obtained by calling offlineStateForSourceItem:,
 * different methods are allowed to be called on the BMPOfflineManager. The table below shows all possible and allowed
 * transitions between the different states. Each line describes one transition which happens immediately and synchronous.
 * When there is a method call noted in column "Method call triggering transition", the "Following State" is entered
 * immediately after the method call returns.
 *
 * When there is no method call noted, the "Following State" is entered when the event described in column
 * "BMPOfflineManagerListener event" was received.
 *
 * The "Following State" is always noted under the assumption that no error occurred when calling the transition method,
 * or during processing of the current task. Errors are always reported to offlineManager:didFailWithError:. See the
 * documentation of BMPOfflineManagerListener.h for more information.
 *
 *  Current State   | Method call triggering transition | BMPOfflineManagerListener event               | Following State
 *  --------------- | ----------------------------------|-----------------------------------------------|----------------
 *  NotDownloaded   | downloadSourceItem:               | -                                             | Downloading
 *  Downloading     | cancelDownloadForSourceItem:      | -                                             | Canceling
 *  Downloading     | suspendDownloadForSourceItem:     | offlineManagerDidSuspendDownload:             | Suspended
 *  Downloading     | -                                 | offlineManagerDidFinishDownload:              | Downloaded
 *  Downloading     | -                                 | offlineManager:didProgressTo:                 | Downloading
 *  Downloaded      | deleteOfflineDataForSourceItem:   | -                                             | NotDownloaded
 *  Suspended       | resumeDownloadForSourceItem:      | offlineManager:didResumeDownloadWithProgress: | Downloading
 *  Suspended       | cancelDownloadForSourceItem:      | -                                             | Canceling
 *  Canceling       | -                                 | offlineManagerDidCancelDownload:              | NotDownloaded
 *
 */
NS_SWIFT_NAME(OfflineManager)
@interface BMPOfflineManager : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/**
 * @return The singleton instance of the BMPOfflineManager.
 */
+ (instancetype)sharedInstance __TVOS_PROHIBITED;
/**
 * Has to be called in your AppDelegate's application(application:didFinishLaunchingWithOptions:) method to initialize
 * handling of offline content.
 */
+ (void)initializeOfflineManager __TVOS_PROHIBITED;
/**
 * Returns the offline state for the given BMPSourceItem.
 *
 * @param sourceItem A BMPSourceItem instance for which the offline state should be determined.
 * @return The offline state for the given BMPSourceItem.
 */
- (BMPOfflineState)offlineStateForSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(offlineState(for:));
/**
 * Deletes the offline stored media data associated with the given BMPSourceItem. Calling this method is only valid when
 * offlineStateForSourceItem: for the same BMPSourceItem instance returns BMPOfflineStateDownloaded.
 *
 * @param sourceItem A BMPSourceItem instance for which the offline data should be deleted.
 */
- (void)deleteOfflineDataForSourceItem:(BMPSourceItem *)sourceItem;
/**
 * Downloads the media data associated with the given BMPSourceItem. The highest media bitrate will be selected for
 * download by default. If you want to specify which bitrate should be selected for download, use
 * downloadSourceItem:minimumBitrate:.
 *
 * Calling this method is only valid when offlineStateForSourceItem: for the same BMPSourceItem instance returns
 * BMPOfflineStateNotDownloaded.
 *
 * @param sourceItem A BMPSourceItem instance for which the media data should be downloaded.
 */
- (void)downloadSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(download(sourceItem:));
/**
 * Downloads the media data associated with the given BMPSourceItem. Calling this method is only valid when
 * offlineStateForSourceItem: for the same BMPSourceItem instance returns BMPOfflineStateNotDownloaded.
 *
 * @param sourceItem A BMPSourceItem instance for which the media data should be downloaded.
 * @param minimumBitrate The lowest media bitrate greater than or equal to this value in bps will be selected for
 *      download. If no suitable media bitrate is found, the highest media bitrate will be selected.
 */
- (void)downloadSourceItem:(BMPSourceItem *)sourceItem minimumBitrate:(nullable NSNumber *)minimumBitrate NS_SWIFT_NAME(download(sourceItem:minimumBitrate:));
/**
 * Cancels all running download tasks associated with the given BMPSourceItem and deletes the partially downloaded
 * content from disk. Calling this method is only valid when offlineStateForSourceItem: for the same BMPSourceItem
 * instance returns BMPOfflineStateDownloading or BMPOfflineStateSuspended.
 *
 * @param sourceItem A BMPSourceItem instance for which all associated running download tasks should be cancelled.
 */
- (void)cancelDownloadForSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(cancelDownload(for:));
/**
 * Suspends all running download tasks associated with the given BMPSourceItem. Calling this method is only valid when
 * offlineStateForSourceItem: for the same BMPSourceItem instance returns BMPOfflineStateDownloading. The download can
 * be resumed by calling resumeDownloadForSourceItem:. Not data is deleted when calling this method.
 *
 * @param sourceItem A BMPSourceItem instance for which all associated running download tasks should be suspended.
 */
- (void)suspendDownloadForSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(suspendDownload(for:));
/**
 * Resumes all suspended download tasks associated with the given BMPSourceItem. Calling this method is only valid when
 * offlineStateForSourceItem: for the same BMPSourceItem instance returns BMPOfflineStateSuspended.
 *
 * @param sourceItem A BMPSourceItem instance for which all associated suspended download tasks should be resumed.
 */
- (void)resumeDownloadForSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(resumeDownload(for:));
/**
 * Creates and returns a BMPOfflineSourceItem which should be used with a BMPBitmovinPlayer instance when playback of
 * offline content is desired.
 *
 * @param sourceItem A BMPSourceItem instance for which a new BMPOfflineSourceItem instance should be created
 * @param restrictedToAssetCache Whether or not the player should restrict playback only to audio, video and subtitle tracks
 *      which are stored offline on the device. This has to be set to YES if the device has no network access.
 * @return A BMPOfflineSourceItem which can be used with a BMPBitmovinPlayer instance for offline playback.
 */
- (nullable BMPOfflineSourceItem *)createOfflineSourceItemForSourceItem:(BMPSourceItem *)sourceItem restrictedToAssetCache:(BOOL)restrictedToAssetCache NS_SWIFT_NAME(createOfflineSourceItem(for:restrictedToAssetCache:));
/**
 * Adds a listener to the BMPOfflineManager.
 *
 * @param listener The listener to add.
 * @param sourceItem The BMPSourceItem instance for which the listener should be added.
 */
- (void)addListener:(id<BMPOfflineManagerListener>)listener forSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(add(listener:for:));
/**
 * Removes a listener from the BMPOfflineManager.
 *
 * @param listener The listener to remove.
 * @param sourceItem The BMPSourceItem instance for which the listener should be removed.
 */
- (void)removeListener:(id<BMPOfflineManagerListener>)listener forSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(remove(listener:for:));
/**
 * Should be called from your AppDelegate when application(application:handleEventsForBackgroundURLSession:completionHandler:)
 * is called by the system.
 *
 * @param completionHandler The completion handler which is provided by the system.
 * @param identifier The identifier which is provided by the system.
 */
- (void)addCompletionHandler:(void (^)(void))completionHandler forIdentifier:(NSString *)identifier NS_SWIFT_NAME(add(completionHandler:for:));
/**
 * Can be used to determine if the BMPSourceItem is playable without a network connection.
 * @param sourceItem A BMPSourceItem instance for which the state should be determined.
 * @return YES, if the BMPSourceItem instance is playable without a network connection, NO otherwise.
 */
- (BOOL)isSourceItemPlayableOffline:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(isPlayableOffline(sourceItem:));
@end

NS_ASSUME_NONNULL_END
