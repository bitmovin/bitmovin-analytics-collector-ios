//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPPlayerEvent.h>
#import <BitmovinPlayer/BMPAdSourceType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * See BMPPlayerListener.h for more information on this event.
 */
NS_SWIFT_NAME(AdStartedEvent)
@interface BMPAdStartedEvent : BMPPlayerEvent
@property (nonatomic, readonly, copy) NSURL *clickThroughUrl;
@property (nonatomic, readonly) BMPAdSourceType clientType;
@property (nonatomic, readonly) NSUInteger indexInQueue;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval timeOffset;
@property (nonatomic, readonly) NSTimeInterval skipOffset;
@property (nonatomic, readonly, copy, nullable) NSString *position;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithClickThroughUrl:(NSURL *)clickThroughUrl
                             clientType:(BMPAdSourceType)clientType
                           indexInQueue:(NSUInteger)indexInQueue
                               duration:(NSTimeInterval)duration
                             timeOffset:(NSTimeInterval)timeOffset
                             skipOffset:(NSTimeInterval)skipOffset
                               position:(nullable NSString *)position NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
