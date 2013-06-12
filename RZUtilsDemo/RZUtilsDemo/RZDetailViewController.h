//
//  RZDetailViewController.h
//  RZUtilsDemo
//
//  Created by Nicholas Bonatsakis on 6/12/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RZDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
