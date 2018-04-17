//
// Bitmovin Player iOS SDK
// Copyright (C) 2017, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

#import <Foundation/Foundation.h>
#import <BitmovinPlayer/BMPUserInterfaceListener.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Handles adding and removing of event listeners.
 */
NS_SWIFT_NAME(UserInterfaceEventHandler)
@protocol BMPUserInterfaceEventHandler <NSObject>
/**
 * Adds an event listener.
 *
 * @param listener The event listener to be added.
 */
- (void)addUserInterfaceListener:(id<BMPUserInterfaceListener>)listener NS_SWIFT_NAME(add(listener:));

/**
 * Removes an event listener.
 *
 * @param listener The event listener to be removed.
 */
- (void)removeUserInterfaceListener:(id<BMPUserInterfaceListener>)listener NS_SWIFT_NAME(remove(listener:));
@end

NS_ASSUME_NONNULL_END
