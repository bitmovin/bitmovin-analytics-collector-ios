//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>

/**
 * Type of the BMPAdSource
 */
NS_SWIFT_NAME(AdSourceType)
typedef NS_ENUM(NSInteger, BMPAdSourceType) {
    /** Missing advertising source type */
    BMPAdSourceTypeNone = 0,
    /** Interactive Media Ads. */
    BMPAdSourceTypeIMA
};
