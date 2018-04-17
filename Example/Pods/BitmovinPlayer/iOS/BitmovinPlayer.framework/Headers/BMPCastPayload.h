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
 * A class holding information for the BMPCastWaitingForDeviceEvent.
 */
NS_SWIFT_NAME(CastPayload)
__TVOS_PROHIBITED
@interface BMPCastPayload : NSObject
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly, strong) NSString *deviceName;
@property (nonatomic, readonly, strong) NSString *type;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithDeviceName:(NSString *)deviceName
                       currentTime:(NSTimeInterval)currentTime
                         timestamp:(NSTimeInterval)timestamp NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
