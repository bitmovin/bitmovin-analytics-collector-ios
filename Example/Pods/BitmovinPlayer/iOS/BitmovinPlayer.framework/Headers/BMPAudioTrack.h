//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPTrack.h>
#import <BitmovinPlayer/BMPJsonable.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes an audio track.
 */
NS_SWIFT_NAME(AudioTrack)
@interface BMPAudioTrack : BMPTrack <BMPJsonable>
/** The IETF BCP 47 language tag associated with the audio track. */
@property (nonatomic, nullable, copy, readonly) NSString *language;
- (instancetype)initWithLabel:(NSString *)label
                   identifier:(NSString *)identifier
               isDefaultTrack:(BOOL)isDefaultTrack
                     language:(nullable NSString *)language NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithUrl:(nullable NSURL *)url
                  trackType:(BMPTrackType)trackType
                      label:(NSString *)label
                 identifier:(NSString *)identifier
             isDefaultTrack:(BOOL)isDefaultTrack NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
