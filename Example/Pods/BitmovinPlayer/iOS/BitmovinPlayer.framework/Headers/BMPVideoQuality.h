//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPQuality.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(VideoQuality)
@interface BMPVideoQuality : BMPQuality
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;

- (instancetype)initWithIdentifier:(NSString *)identifier
                             label:(NSString *)label
                           bitrate:(NSUInteger)bitrate NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(NSString *)identifier
                             label:(NSString *)label
                           bitrate:(NSUInteger)bitrate
                             width:(NSUInteger)width
                            height:(NSUInteger)height NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
