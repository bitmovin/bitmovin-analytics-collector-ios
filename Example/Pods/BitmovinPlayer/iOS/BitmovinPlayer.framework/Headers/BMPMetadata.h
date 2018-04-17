//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPMetadataEntry.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Metadata)
@interface BMPMetadata : NSObject
@property (nonatomic, readonly, copy) NSArray<id<BMPMetadataEntry>> *entries;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithEntries:(NSArray<id<BMPMetadataEntry>> *)entries NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
