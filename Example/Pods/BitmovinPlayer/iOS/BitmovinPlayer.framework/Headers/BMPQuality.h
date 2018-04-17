//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPJsonable.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Quality)
@interface BMPQuality : NSObject <BMPJsonable>
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, readonly) NSUInteger bitrate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(NSString *)identifier
                             label:(NSString *)label
                           bitrate:(NSUInteger)bitrate NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
