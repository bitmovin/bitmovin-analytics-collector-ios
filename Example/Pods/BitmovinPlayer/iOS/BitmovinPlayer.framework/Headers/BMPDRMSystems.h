//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Provides access to DRM scheme UUIDs.
 */
NS_SWIFT_NAME(DRMSystems)
@interface BMPDRMSystems : NSObject
@property (class, nonatomic, readonly, strong) NSUUID *fairplayUUID;
@property (class, nonatomic, readonly, strong) NSUUID *widevineUUID;
@end

NS_ASSUME_NONNULL_END
