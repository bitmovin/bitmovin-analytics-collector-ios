//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPPlaybackType.h>
#import <BitmovinPlayer/BMPSourceItem.h>
#import <BitmovinPlayer/BMPConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Contains configuration values regarding the media which should be played back by the player.
 */
NS_SWIFT_NAME(SourceConfiguration)
@interface BMPSourceConfiguration : BMPConfiguration
@property (nonatomic) BMPPlaybackType playbackType;
@property (nonatomic) BOOL repeatAll;
@property (nonatomic, strong, nullable, readonly) BMPSourceItem *firstSourceItem;

/**
 * @brief Adds a new source item based on the provided url string.
 *
 * @param urlString The url to a DASH, HLS or Progressive MP4 source which is used to create a new SourceItem to be added.
 */
- (BOOL)addSourceItemWithString:(NSString *)urlString error:(NSError **)error NS_SWIFT_NAME(addSourceItem(urlString:));

/**
 * @brief Adds a new source item based on the provided url.
 *
 * @param url The url to a DASH, HLS or Progressive MP4 source which is used to create a new SourceItem to be added.
 */
- (BOOL)addSourceItemWithUrl:(NSURL *)url error:(NSError **)error NS_SWIFT_NAME(addSourceItem(url:));

/**
 * @brief Adds a new source item.
 *
 * @param sourceItem The new SourceItem to be added.
 */
- (void)addSourceItem:(BMPSourceItem *)sourceItem NS_SWIFT_NAME(addSourceItem(item:));
@end

NS_ASSUME_NONNULL_END
