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
 * Base class for all event classes.
 */
NS_SWIFT_NAME(PlayerEvent)
@interface BMPPlayerEvent : NSObject
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@end

NS_ASSUME_NONNULL_END
