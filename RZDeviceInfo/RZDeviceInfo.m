//
//  RZDeviceInfo.m
//  RZUtils
//
//  Created by Nathan Spector on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RZDeviceInfo.h"
#import <UIKit/UIKit.h>

@implementation RZDeviceInfo

// Based on code from user |progrmr| on StackOverFlow.
// URL: stackoverflow.com/questions/2759229 (accessed 06/16/10)
+(BOOL) isPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

// Based on code from the official iPhone Application Programming Guide
// URL: developer.apple.com/iphone/library/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide
+(BOOL) supportsBackgrounding {
	UIDevice* device = [UIDevice currentDevice];
	BOOL backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	return backgroundSupported;
}

//Based on code from above and some blog
// URL: blog.onstreamtv.de/?p=489
+(BOOL) supportsLocalNotifications {
	BOOL localNotesSupported = NO;
	Class myClass = NSClassFromString(@"UILocalNotification");	
	if(myClass)
		localNotesSupported = YES;
	
	return localNotesSupported;
}

@end





