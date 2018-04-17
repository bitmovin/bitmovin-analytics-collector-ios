//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPErrorEvent.h>
#import <BitmovinPlayer/BMPAdItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * See BMPPlayerListener.h for more information on this event.
 */
NS_SWIFT_NAME(AdErrorEvent)
__TVOS_PROHIBITED
@interface BMPAdErrorEvent : BMPErrorEvent
@property (nonatomic, strong, readonly, nullable) BMPAdItem *adItem;

- (instancetype)initWithCode:(NSUInteger)code message:(NSString *)message NS_UNAVAILABLE;
- (instancetype)initWithAdItem:(nullable BMPAdItem *)adItem code:(NSUInteger)code message:(NSString *)message NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
