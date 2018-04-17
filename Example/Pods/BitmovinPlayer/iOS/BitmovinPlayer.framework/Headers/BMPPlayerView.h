//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BitmovinPlayer/BMPBitmovinPlayer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for player user interfaces which should work together with the BMPBitmovinPlayer. If ypu want to build your
 * own UI on top of our player, extend this class.
 */
NS_SWIFT_NAME(PlayerView)
@interface BMPPlayerView : UIView
@property (nullable, nonatomic, strong) BMPBitmovinPlayer *player;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithPlayer:(BMPBitmovinPlayer *)player frame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
