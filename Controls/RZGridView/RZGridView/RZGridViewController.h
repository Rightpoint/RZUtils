//
//  RZGridViewViewController.h
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZGridView.h"

@interface RZGridViewController : UIViewController <RZGridViewDataSource> {
    
}

@property (nonatomic, retain) RZGridView *gridView;

@end
