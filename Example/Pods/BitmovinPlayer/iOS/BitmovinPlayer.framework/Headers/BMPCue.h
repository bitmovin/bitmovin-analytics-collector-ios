//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes a subtitle cue.
 */
NS_SWIFT_NAME(Cue)
@interface BMPCue : NSObject <NSCopying>
/** The start time of the cue in seconds */
@property (nonatomic) NSTimeInterval startTime;
/** The end time of the cue in seconds */
@property (nonatomic) NSTimeInterval endTime;
/** The cue text as HTML. May be nil. */
@property (nonatomic, nullable, copy) NSString *html;
/** The cue text. May be nil. */
@property (nonatomic, nullable, copy) NSString *text;
/** The cue image. May be nil. */
@property (nonatomic, nullable) UIImage *image;
/** The position of the cue. May be nil. */
@property (nonatomic, nullable, copy) NSString *position;
/** The region of the cue. May be nil. */
@property (nonatomic, nullable, copy) NSString *region;
/** The region style of the cue. May be nil. */
@property (nonatomic, nullable, copy) NSString *regionStyle;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithStartTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                             html:(nullable NSString *)html
                             text:(nullable NSString *)text
                            image:(nullable UIImage *)image
                         position:(nullable NSString *)position
                           region:(nullable NSString *)region
                      regionStyle:(nullable NSString *)regionStyle NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithStartTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                             text:(NSString *)text;

- (instancetype)initWithStartTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                             html:(NSString *)html;

- (instancetype)initWithStartTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                            image:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
