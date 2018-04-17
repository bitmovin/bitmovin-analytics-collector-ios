//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(FullscreenHandler)
@protocol BMPFullscreenHandler <NSObject>
@property (nonatomic, readonly, getter=isFullscreen) BOOL fullscreen;

- (void)onFullscreenRequested;
- (void)onFullscreenExitRequested;
@end

NS_ASSUME_NONNULL_END
