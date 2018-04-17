//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPConfiguration.h>
#import <BitmovinPlayer/BMPSourceConfiguration.h>
#import <BitmovinPlayer/BMPSourceItem.h>
#import <BitmovinPlayer/BMPStyleConfiguration.h>
#import <BitmovinPlayer/BMPPlaybackConfiguration.h>
#import <BitmovinPlayer/BMPAdvertisingConfiguration.h>
#import <BitmovinPlayer/BMPCastConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains configuration values regarding the playback behaviour of the player.
 */
NS_SWIFT_NAME(PlayerConfiguration)
@interface BMPPlayerConfiguration : BMPConfiguration
@property (nonatomic, nonnull, strong) BMPSourceConfiguration *sourceConfiguration;
@property (nonatomic, nonnull, strong) BMPStyleConfiguration *styleConfiguration;
@property (nonatomic, nonnull, strong) BMPPlaybackConfiguration *playbackConfiguration;
@property (nonatomic, nonnull, strong) BMPAdvertisingConfiguration *advertisingConfiguration __TVOS_PROHIBITED;
@property (nonatomic, nonnull, strong) BMPCastConfiguration *castConfiguration __TVOS_PROHIBITED;

/**
 * Get/Set a source item for this PlayerConfiguration. When a source item is set, also a new new SourceConfiguration
 * containing this single source item is created for this PlayerConfiguration.
 */
@property (nonatomic, nullable, strong) BMPSourceItem *sourceItem;

/**
 * Sets a new source item based on the provided url for this PlayerConfiguration.
 *
 * @param urlString The url to a DASH, HLS or Progressive MP4 source which is used to create a new SourceConfiguration
 * and SourceItem for this PlayerConfiguration.
 */
- (BOOL)setSourceItemWithString:(NSString *)urlString error:(NSError **)error NS_SWIFT_NAME(setSourceItem(urlString:));

/**
 * Sets a new source item based on the provided url for this PlayerConfiguration.
 *
 * @param url The url to a DASH, HLS or Progressive MP4 source which is used to create a new SourceConfiguration
 * and SourceItem for this PlayerConfiguration.
 */
- (BOOL)setSourceItemWithUrl:(NSURL *)url error:(NSError **)error NS_SWIFT_NAME(setSourceItem(url:));
@end

NS_ASSUME_NONNULL_END
