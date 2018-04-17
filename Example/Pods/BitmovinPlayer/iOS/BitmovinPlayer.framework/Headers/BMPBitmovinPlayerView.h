//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#ifndef BMPBitmovinPlayerView_h
#define BMPBitmovinPlayerView_h

#import <UIKit/UIKit.h>
#import <BitmovinPlayer/BMPBitmovinPlayer.h>
#import <BitmovinPlayer/BMPPlayerView.h>
#import <BitmovinPlayer/BMPFullscreenHandler.h>
#import <BitmovinPlayer/BMPUserInterfaceAPI.h>
#import <BitmovinPlayer/BMPUserInterfaceEventHandler.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A view containing a BMPBitmovinPlayer which can be added to the view hierarchy of your view controller. This view
 * needs a BMPBitmovinPlayer instance to work properly. This instance can be passed to the initializer, or using the
 * according property if the view is created using the interface builder.
 */
// NS_SWIFT_NAME(BitmovinPlayerView)
@interface BMPBitmovinPlayerView : BMPPlayerView <BMPUserInterfaceAPI, BMPUserInterfaceEventHandler>
@property (nonatomic, strong) id<BMPFullscreenHandler> fullscreenHandler;
- (void)willRotate;
- (void)didRotate;
@end

NS_ASSUME_NONNULL_END

#endif /* BMPBitmovinPlayerView_h */
