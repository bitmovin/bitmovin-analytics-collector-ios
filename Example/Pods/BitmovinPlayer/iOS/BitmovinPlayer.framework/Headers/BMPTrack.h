//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPTrackType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for all available tracks.
 */
NS_SWIFT_NAME(Track)
@interface BMPTrack : NSObject
@property (nonatomic, nullable, copy, readonly) NSURL *url;
@property (nonatomic, getter=isDefaultTrack, readonly) BOOL defaultTrack;
@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, readonly) BMPTrackType type;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithUrl:(nullable NSURL *)url
                  trackType:(BMPTrackType)trackType
                      label:(NSString *)label
                 identifier:(NSString *)identifier
             isDefaultTrack:(BOOL)isDefaultTrack NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
