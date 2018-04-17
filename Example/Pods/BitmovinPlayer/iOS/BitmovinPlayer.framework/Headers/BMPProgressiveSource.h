//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPMediaSource.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a progressive media source.
 */
NS_SWIFT_NAME(ProgressiveSource)
@interface BMPProgressiveSource : BMPMediaSource
- (instancetype)initWithType:(BMPMediaSourceType)mediaSourceType url:(NSURL *)url NS_UNAVAILABLE;
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
