//
//  RZMasterViewController.h
//  RZUtilsDemo
//
//  Created by Nicholas Bonatsakis on 6/12/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RZDetailViewController;

@interface RZMasterViewController : UITableViewController

@property (strong, nonatomic) RZDetailViewController *detailViewController;

@end
