//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPAdSource.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents an ad which can be scheduled in the play.
 */
NS_SWIFT_NAME(AdItem)
__TVOS_PROHIBITED
@interface BMPAdItem : NSObject
@property (nonatomic, copy, readonly) NSArray<BMPAdSource *> *sources;
@property (nonatomic, copy, readonly, nullable) NSString *position;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithAdSources:(NSArray<BMPAdSource *> *)sources atPosition:(nullable NSString *)position NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAdSources:(NSArray<BMPAdSource *> *)sources;
@end

NS_ASSUME_NONNULL_END
