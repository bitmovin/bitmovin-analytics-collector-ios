//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains configuration values which can be used to alter the playback behaviour of the player.
 */
NS_SWIFT_NAME(PlaybackConfiguration)
@interface BMPPlaybackConfiguration : BMPConfiguration
@property (nonatomic, getter=isAutoplayEnabled) BOOL autoplayEnabled;
@property (nonatomic, getter=isMuted) BOOL muted;
@property (nonatomic, getter=isTimeShiftEnabled) BOOL timeShiftEnabled;
@end

NS_ASSUME_NONNULL_END
