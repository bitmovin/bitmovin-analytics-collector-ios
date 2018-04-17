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
 * The type of a track object.
 */
NS_SWIFT_NAME(TrackType)
typedef NS_ENUM(NSInteger, BMPTrackType) {
    /** Indicates a missing type */
    BMPTrackTypeNone = 0,
    /** Indicates a track containing textual data like the BMPSubtitleTrack. */
    BMPTrackTypeText,
    /** Indicates a track containing thumbnail data like the BMPThumbnailTrack. */
    BMPTrackTypeThumbnail,
    /** Indicates a track containing audio data like the BMPAudioTrack. */
    BMPTrackTypeAudio
};

NS_ASSUME_NONNULL_END
