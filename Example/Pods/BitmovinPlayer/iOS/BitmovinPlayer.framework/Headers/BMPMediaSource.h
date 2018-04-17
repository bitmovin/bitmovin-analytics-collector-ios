//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPMediaSourceType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for all media sources.
 */
NS_SWIFT_NAME(MediaSource)
@interface BMPMediaSource : NSObject <NSCopying>
@property (nonatomic) BMPMediaSourceType type;
@property (nonatomic, nonnull, strong) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithType:(BMPMediaSourceType)mediaSourceType url:(NSURL *)url NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
