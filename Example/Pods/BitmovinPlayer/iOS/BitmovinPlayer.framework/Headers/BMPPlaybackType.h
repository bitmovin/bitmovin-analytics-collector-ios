//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Indicates in which order source items in a playlist should be played back.
 */
NS_SWIFT_NAME(PlaybackType)
typedef NS_ENUM(NSInteger, BMPPlaybackType) {
    /** Indicates sequential playback. */
    BMPPlaybackTypeSequential,
    /** Indicates shuffled playback. */
    BMPPlaybackTypeShuffle
};

NS_ASSUME_NONNULL_END
