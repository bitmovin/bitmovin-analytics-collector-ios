//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPDRMConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a Widevine DRM configuration.
 */
NS_SWIFT_NAME(WidevineConfiguration)
@interface BMPWidevineConfiguration : BMPDRMConfiguration
/** An array of objects which specify custom HTTP headers for the license request. */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *licenseRequestHeaders;
/** Specifies how long in milliseconds should be waited before a license request should be retried. */
@property (nonatomic) NSUInteger licenseRequestRetryDelay;
/**
 * Specifies how often a license request should be retried if was not successful (e.g. the license server was not
 * reachable). Default is 1. 0 disables retries.
 */
@property (nonatomic) NSUInteger maxLicenseRequestRetries;
/**
 * An JS object as JSON String which allows to specify configuration options of the DRM key system, such as
 * distinctiveIdentifier or persistentState.
 */
@property (nonatomic, strong, nullable) NSString *mediaKeySystemConfig;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithLicenseUrl:(nullable NSURL *)licenseUrl uuid:(NSUUID *)uuid NS_UNAVAILABLE;
- (instancetype)initWithLicenseUrl:(nullable NSURL *)licenseUrl NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
