//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPPlayerEvent.h>
#import <UIKit/UIKit.h>
#import <BitmovinPlayer/BMPCue.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for cue events like BMPCueEnterEvent and BMPCueExitEvent.
 */
NS_SWIFT_NAME(CueEvent)
@interface BMPCueEvent : BMPPlayerEvent
@property (nonatomic, readonly) NSTimeInterval startTime;
@property (nonatomic, readonly) NSTimeInterval endTime;
@property (nonatomic, readonly, nullable, copy) NSString *text;
@property (nonatomic, readonly, nullable, copy) NSString *html;
@property (nonatomic, readonly, nullable) UIImage *image;
@property (nonatomic, readonly, nullable, copy) NSString *position;
@property (nonatomic, readonly, nullable, copy) NSString *region;
@property (nonatomic, readonly, nullable, copy) NSString *regionStyle;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCue:(BMPCue *)cue NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
