//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPSourceItem.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a BMPSourceItem which references already downloaded or currently downloading offline content. It can be
 * passed to a BMPBitmovinPlayer instance for playback. Do not create instances of this class on your own, instead
 * use BMPOfflineManager#createOfflineSourceItemForSourceItem:restrictedToAssetCache:.
 */
NS_SWIFT_NAME(OfflineSourceItem)
@interface BMPOfflineSourceItem : BMPSourceItem
- (instancetype)initWithUrl:(NSURL *)url NS_UNAVAILABLE;
- (instancetype)initWithAdaptiveSource:(BMPAdaptiveSource *)adaptiveSource NS_UNAVAILABLE;
- (instancetype)initWithProgressiveSource:(BMPProgressiveSource *)progressiveSource NS_UNAVAILABLE;
- (instancetype)initWithProgressiveSources:(NSArray<BMPProgressiveSource *> *)progressiveSources NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
