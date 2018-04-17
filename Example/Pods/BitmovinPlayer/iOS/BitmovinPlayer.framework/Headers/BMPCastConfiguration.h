//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains configuration values which can be used to customize the cast receiver app.
 */
NS_SWIFT_NAME(CastConfiguration)
@interface BMPCastConfiguration : BMPConfiguration
@property (nonatomic, copy, nullable) NSURL *receiverStylesheetUrl;
@end

NS_ASSUME_NONNULL_END
