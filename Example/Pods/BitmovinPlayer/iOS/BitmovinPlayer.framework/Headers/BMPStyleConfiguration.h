//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPConfiguration.h>
#import <BitmovinPlayer/BMPUserInterfaceType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains configuration values which can be used to alter the visual presentation and behaviour of the player UI.
 */
NS_SWIFT_NAME(StyleConfiguration)
@interface BMPStyleConfiguration : BMPConfiguration
@property (nonatomic, getter=isUiEnabled) BOOL uiEnabled;
@property (nonatomic) BMPUserInterfaceType userInterfaceType;
@property (nonatomic, copy) NSURL *playerUiCss;
@property (nonatomic, copy) NSURL *playerUiJs;
@end

NS_ASSUME_NONNULL_END
