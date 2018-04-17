//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPConfiguration.h>
#import <BitmovinPlayer/BMPAudioTrack.h>
#import <BitmovinPlayer/BMPSubtitleTrack.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Provides the possibility to overwrite the labels which are automatically assigned for different
 * types of tracks.
 */
NS_SWIFT_NAME(LabelingConfiguration)
@interface BMPLabelingConfiguration : BMPConfiguration
/**
 * An optional block which gets a BMPSubtitleTrack as parameter and returns the desired label
 * which should be used for that track.
 */
@property (nonatomic, copy, nullable) NSString *(^subtitleLabel)(BMPSubtitleTrack *track);

/**
 * An optional block which gets a BMPAudioTrack as parameter and returns the desired label
 * which should be used for that track.
 */
@property (nonatomic, copy, nullable) NSString *(^audioLabel)(BMPAudioTrack *track);
@end

NS_ASSUME_NONNULL_END
