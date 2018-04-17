//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

/**
 * Types of media which can be handled by the Bitmovin Player.
 */
NS_SWIFT_NAME(MediaSourceType)
typedef NS_ENUM(NSInteger, BMPMediaSourceType) {
    /** indicates a missing media source type. */
    BMPMediaSourceTypeNone = 0,
    /** Indicates media of type HLS. */
    BMPMediaSourceTypeHLS,
    /** Indicates media of type DASH. */
    BMPMediaSourceTypeDASH,
    /** Indicates media of type Progressive MP4. */
    BMPMediaSourceTypeProgressive
};