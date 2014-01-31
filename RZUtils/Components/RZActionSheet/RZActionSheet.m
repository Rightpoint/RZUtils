//
//  RZActionSheet.m
//  OvulinePregnancy
//
//  Created by Nicholas Bonatsakis on 8/26/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import "RZActionSheet.h"

@interface RZActionSheet () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *buttonInfoList;

@end

@implementation RZActionSheet

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self)
    {
        self.buttonInfoList = [NSMutableArray array];
    }
    return self;
}

- (void)setCancelButtonTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)completion
{
    [self addButtonWithTitle:title];
    [self.buttonInfoList addObject:[self buttonInfoWithTitle:title completion:completion]];
    self.cancelButtonIndex = self.buttonInfoList.count - 1;
}

- (void)setDestructiveButtonTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)completion
{
    [self addButtonWithTitle:title];
    [self.buttonInfoList addObject:[self buttonInfoWithTitle:title completion:completion]];
    self.destructiveButtonIndex = self.buttonInfoList.count - 1;
}

- (void)addButtonWithTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)completion
{
    [self addButtonWithTitle:title];
    [self.buttonInfoList addObject:[self buttonInfoWithTitle:title completion:completion]];
}

- (NSArray *)buttonInfoWithTitle:(NSString *)title completion:(RZActionSheetCompletion)completion
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:title, nil];
    if (completion)
    {
        [arr addObject:[completion copy]];
    }
    
    return arr;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSArray *buttonInfo = self.buttonInfoList[buttonIndex];
    if (buttonInfo.count > 1)
    {
        RZActionSheetCompletion completion = buttonInfo[1];
        completion();
    }
    
}
@end
