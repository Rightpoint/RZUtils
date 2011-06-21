//
//  RZDeviceInfo.h
//  RZUtils
//
//  Created by Nathan Spector on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RZDeviceInfo : NSObject {

}

// Returns YES if the current device is an iPad.
+(BOOL) isPad;

// Returns YES if the device can background third-party applications.
+(BOOL) supportsBackgrounding;

// Returns YES if the device can do local notifications
+(BOOL) supportsLocalNotifications;

@end