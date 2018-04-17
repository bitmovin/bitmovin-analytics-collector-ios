//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPCue.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Enables external control over the associated BMPSubtitleTrack
 */
NS_SWIFT_NAME(SubtitleTrackController)
@protocol BMPSubtitleTrackController <NSObject>
/**
 * Triggers a CueEnterEvent.
 *
 * @param cue The BMPCue that should enter.
 */
- (void)cueEnter:(BMPCue *)cue;
/**
 * Triggers a CueExitEvent.
 *
 * @param cue The BMPCue that should exit.
 */
- (void)cueExit:(BMPCue *)cue;
@end

NS_ASSUME_NONNULL_END
