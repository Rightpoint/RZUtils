//
//  coreTextExAppDelegate.h
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class coreTextExViewController;

@interface coreTextExAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    coreTextExViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet coreTextExViewController *viewController;

@end

