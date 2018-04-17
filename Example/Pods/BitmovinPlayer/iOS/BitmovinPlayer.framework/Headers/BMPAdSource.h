//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPAdSourceType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents an ad source which can be assigned to an AdItem.
 * An AdItem can have multiple AdSources as waterfalling option.
 */
NS_SWIFT_NAME(AdSource)
__TVOS_PROHIBITED
@interface BMPAdSource : NSObject
@property (nonatomic, readonly) BMPAdSourceType type;
@property (nonatomic, readonly, copy) NSURL *tag;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithTag:(NSURL *)tag ofType:(BMPAdSourceType)type NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(tag:ofType:));
@end

NS_ASSUME_NONNULL_END
