//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPPlayerEvent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * See BMPPlayerListener.h for more information on this event.
 */
NS_SWIFT_NAME(TimeShiftEvent)
@interface BMPTimeShiftEvent : BMPPlayerEvent
@property (nonatomic, readonly) NSTimeInterval position;
@property (nonatomic, readonly) NSTimeInterval target;
@property (nonatomic, readonly) NSTimeInterval timeShift;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithPosition:(NSTimeInterval)position
                          target:(NSTimeInterval)target
                       timeShift:(NSTimeInterval)timeShift NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
