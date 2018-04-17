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
 * API methods related to the user interface.
 */
NS_SWIFT_NAME(UserInterfaceAPI)
@protocol BMPUserInterfaceAPI <NSObject>
/**
 * Returns true if the player is currently in fullscreen mode.
 *
 * @return True if the player is currently in fullscreen mode.
 */
@property (nonatomic, readonly, getter=isFullscreen) BOOL fullscreen;

/**
 * Returns true if the players playback controls are currently shown, false if they are hidden.
 *
 * @return True if the players playback controls are currently shown, false if they are hidden.
 */
@property (nonatomic, readonly, getter=areControlsShown) BOOL controlsShown;

/**
 * The player enters fullscreen mode. Has no effect if already in fullscreen.
 */
- (void)enterFullscreen;

/**
 * The player exits fullscreen mode. Has no effect if not in fullscreen.
 */
- (void)exitFullscreen;

/**
 * Sets a poster image which will be displayed before playback starts.
 *
 * @param url The URL to the poster image
 * @param keepPersistent Flag to set the poster image persistent so it is also displayed during playback.
 */
- (void)setPosterImage:(NSURL *)url keepPersistent:(BOOL)keepPersistent NS_SWIFT_NAME(setPosterImage(url:keepPersistent:));
@end

NS_ASSUME_NONNULL_END
