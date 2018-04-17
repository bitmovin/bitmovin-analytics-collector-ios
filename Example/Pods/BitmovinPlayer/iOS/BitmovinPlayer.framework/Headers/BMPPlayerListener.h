//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPPlayerEvents.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Defines listener methods for all events available for the BitmovinPlayer. See the documentation of the single listener
 * methods for further information.
 */
NS_SWIFT_NAME(PlayerListener)
@protocol BMPPlayerListener <NSObject>
@optional
/**
 * Is called when the player is ready for immediate playback, because initial audio/video has been downloaded.
 *
 * @param event An object holding specific event data.
 */
- (void)onReady:(BMPReadyEvent *)event;

/**
 * Is called when the player enters the play state.
 *
 * @param event An object holding specific event data.
 */
- (void)onPlay:(BMPPlayEvent *)event;

/**
 * Is called when the player enters the pause state.
 * 
 * @param event An object holding specific event data.
 */
- (void)onPaused:(BMPPausedEvent *)event;

/**
 * Is called when the current playback time has changed.
 *
 * @param event An object holding specific event data.
 */
- (void)onTimeChanged:(BMPTimeChangedEvent *)event;

/**
 * Is called when the duration of the current played media has changed.
 *
 * @param event An object holding specific event data.
 */
- (void)onDurationChanged:(BMPDurationChangedEvent *)event;

/**
 * Is called periodically during seeking.
 *
 * Only applies to VoD streams.
 *
 * @param event An object holding specific event data.
 */
- (void)onSeek:(BMPSeekEvent *)event;

/**
 * Is called when seeking has been finished and data is available to continue playback.
 *
 * Only applies to VoD streams.
 *
 * @param event An object holding specific event data.
 */
- (void)onSeeked:(BMPSeekedEvent *)event;

/**
 * Is called periodically during time shifting. Only applies to live streams, please refer to onSeek for VoD streams.
 *
 * @param event An object holding specific event data.
 */
- (void)onTimeShift:(BMPTimeShiftEvent *)event;

/**
 * Is called when time shifting has been finished and data is available to continue playback. Only applies to live streams, please refer to onSeeked for VoD streams.
 *
 * @param event An object holding specific event data.
 */
- (void)onTimeShifted:(BMPTimeShiftedEvent *)event;

/**
 * Is called when the player is paused or in buffering state and the timeShift offset has exceeded the available timeShift window.
 *
 * @param event An object holding specific event data.
 */
- (void)onDvrWindowExceeded:(BMPDvrWindowExceededEvent *)event;

/**
 * Is called when the player begins to stall and to buffer due to an empty buffer.
 *
 * @param event An object holding specific event data.
 */
- (void)onStallStarted:(BMPStallStartedEvent *)event;

/**
 * Is called when the player ends stalling, due to enough data in the buffer.
 *
 * @param event An object holding specific event data.
 */
- (void)onStallEnded:(BMPStallEndedEvent *)event;

/**
 * Is called when the current size of the video content has been changed.
 *
 * @param event An object holding specific event data.
 */
- (void)onVideoSizeChanged:(BMPVideoSizeChangedEvent *)event;

/**
 * Is called when the playback of the current media has finished.
 *
 * @param event An object holding specific event data.
 */
- (void)onPlaybackFinished:(BMPPlaybackFinishedEvent *)event;

/**
 * Is called when the first frame of the current video is rendered onto the video surface.
 *
 * @param event An object holding specific event data.
 */
- (void)onRenderFirstFrame:(BMPRenderFirstFrameEvent *)event;

/**
 * Is called when an error is encountered.
 *
 * @param event An object holding specific event data.
 */
- (void)onError:(BMPErrorEvent *)event;

/**
 * Is called when a new source is loaded. This does not mean that loading of the new manifest has been finished.
 *
 * @param event An object holding specific event data.
 */
- (void)onSourceLoaded:(BMPSourceLoadedEvent *)event;

/**
 * Is called when the current source will be unloaded.
 *
 * @param event An object holding specific event data.
 */
- (void)onSourceWillUnload:(BMPSourceWillUnloadEvent *)event;

/**
 * Is called when the current source has been unloaded.
 *
 * @param event An object holding specific event data.
 */
- (void)onSourceUnloaded:(BMPSourceUnloadedEvent *)event;

/**
 * Is called when the player was destroyed.
 *
 * @param event An object holding specific event data.
 */
- (void)onDestroy:(BMPDestroyEvent *)event;

/**
 * Is called when metadata (i.e. ID3 tags in HLS and EMSG in DASH) are encountered.
 * 
 * @param event An object holding specific event data.
 */
- (void)onMetadata:(BMPMetadataEvent *)event;

/**
 * Is called when casting to another device, such as a ChromeCast, is available.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastAvailable:(BMPCastAvailableEvent *)event;

/**
 * Is called when the playback on an cast device has been paused.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastPaused:(BMPCastPausedEvent *)event;

/**
 * Is called when the playback on an cast device has been finished.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastPlaybackFinished:(BMPCastPlaybackFinishedEvent *)event;

/**
 * Is called when playback on an cast device has been started.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastPlaying:(BMPCastPlayingEvent *)event;

/**
 * Is called when the cast app is launched successfully.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastStarted:(BMPCastStartedEvent *)event;

/**
 * Is called when casting is initiated, but the user still needs to choose which device should be used.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastStart:(BMPCastStartEvent *)event;

/**
 * Is called when casting to a device is stopped.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastStopped:(BMPCastStoppedEvent *)event;

/**
 * Is called when the time update from the currently used cast device is received.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastTimeUpdated:(BMPCastTimeUpdatedEvent *)event;

/**
 * Is called when a cast device has been chosen and player is waiting for the device to get ready for playback.
 *
 * @param event An object holding specific event data.
 */
- (void)onCastWaitingForDevice:(BMPCastWaitingForDeviceEvent *)event __TVOS_PROHIBITED;

/**
 * Is called when the player configuration has been updated by either calling load or setup on the player.
 *
 * @param event An object holding specific event data.
 */
- (void)onConfigurationUpdated:(BMPConfigurationUpdatedEvent *)event;

/**
 * Is called when a subtitle entry transitions into the active status.
 */
- (void)onCueEnter:(BMPCueEnterEvent *)event;

/**
 * Is called when an active subtitle entry transitions into the inactive status.
 */
- (void)onCueExit:(BMPCueExitEvent *)event;

/**
 * Is called when a new BMPSubtitleTrack is added, for example using the BMPPlayerAPI#addSubtitle: call.
 */
- (void)onSubtitleAdded:(BMPSubtitleAddedEvent *)event;

/**
 * Is called when an external BMPSubtitleTrack has been removed so it is possible to update the controls accordingly.
 */
- (void)onSubtitleRemoved:(BMPSubtitleRemovedEvent *)event;

/**
 * Is called when the active BMPSubtitleTrack is changed.
 */
- (void)onSubtitleChanged:(BMPSubtitleChangedEvent *)event;

/**
 * Is called when the player is muted.
 */
- (void)onMuted:(BMPMutedEvent *)event;

/**
 * Is called when the player is unmuted.
 */
- (void)onUnmuted:(BMPUnmutedEvent *)event;

/**
 * Is fired when the audio track is changed.
 */
- (void)onAudioChanged:(BMPAudioChangedEvent *)event;

/**
 * Is fired when the playback of an ad has been started.
 */
- (void)onAdStarted:(BMPAdStartedEvent *)event;

/**
 * Is fired when the playback of an ad has been finished.
 */
- (void)onAdFinished:(BMPAdFinishedEvent *)event;

/**
 * Is fired when the playback of an ad break has been started
 */
- (void)onAdBreakStarted:(BMPAdBreakStartedEvent *)event;

/**
 * Is fired when the playback of an ad break has been finished.
 */
- (void)onAdBreakFinished:(BMPAdBreakFinishedEvent *)event;

/**
 * Is fired when an ad manifest was successfully downloaded and parsed and the ad has been added onto the queue.
 */
- (void)onAdScheduled:(BMPAdScheduledEvent *)event;

/**
 * Is fired when an ad has been skipped.
 */
- (void)onAdSkipped:(BMPAdSkippedEvent *)event;

/**
 * Is fired when the user clicks on the ad.
 */
- (void)onAdClicked:(BMPAdClickedEvent *)event;

/**
 * Is fired when ad playback fails.
 */
- (void)onAdError:(BMPAdErrorEvent *)event __TVOS_PROHIBITED;

/**
 * Is fired when the ad manifest has been successfully loaded.
 */
- (void)onAdManifestLoaded:(BMPAdManifestLoadedEvent *)event;

/**
 * Is fired when the current video download quality has changed.
 */
- (void)onVideoDownloadQualityChanged:(BMPVideoDownloadQualityChangedEvent *)event;

/**
 * Is called for each occurring player event.
 *
 * @param event The player event. Use event.name or [event isKindOfClass:] to check the specific event type.
 */
- (void)onEvent:(BMPPlayerEvent *)event NS_SWIFT_NAME(onEvent(_:));

@end

NS_ASSUME_NONNULL_END
