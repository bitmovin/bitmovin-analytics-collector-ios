//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IVSPlayerLayer;

/// Extends `AVPictureInPictureController` with `IVSPlayerLayer` support.
API_AVAILABLE(ios(15.0))
@interface AVPictureInPictureController (IVSPlayer)

/// Create an instance of `AVPictureInPictureController` with an `IVSPlayerLayer` instance.
/// @param playerLayer The `IVSPlayerLayer` instance used for playback.
- (nullable instancetype)initWithIVSPlayerLayer:(IVSPlayerLayer *)playerLayer;

/// The `IVSPlayerLayer` instance associated with this Picture in Picture controller; nil otherwise.
@property (nonatomic, readonly, nullable) IVSPlayerLayer *ivsPlayerLayer;

@end

NS_ASSUME_NONNULL_END
