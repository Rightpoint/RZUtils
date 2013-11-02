//
//  RZCollectionTableViewCellm
//
//  Created by Nick Donaldson on 9/13/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZCollectionTableViewCell.h"
#import "RZCollectionTableView.h"
#import "RZCollectionTableView_Private.h"

#define kRZCTDefaultDeleteButtonWidth 80.f

NSString * const RZCollectionTableViewCellEditingStateChanged = @"RZCollectionTableViewCellEditingStateChanged";
NSString * const RZCollectionTableViewCellEditingCommitted = @"RZCollectionTableViewCellEditingCommitted";

@interface RZCollectionTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, weak) UIView *pannableContentView;

@property (nonatomic, weak) UIPanGestureRecognizer *panGesture;

- (void)createBackgroundView;

// NOTE: see comments in implementation of this method
- (void)convertConstraintsToContentView;

- (void)configureGestures;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;

@end

@implementation RZCollectionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createBackgroundView];
        [self configureGestures];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self createBackgroundView];
        [self convertConstraintsToContentView];
        [self configureGestures];
    }
    return self;
}

#pragma mark - UICollectionViewCell subclass

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setRzEditing:NO animated:NO];
}

#pragma mark - Config

- (void)createBackgroundView
{
    self.contentView.backgroundColor = self.backgroundColor;
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor redColor];
}

- (void)convertConstraintsToContentView
{
    //
    // Nick Donaldson, 11/01/13
    //
    // When using autolayout, for some reason, IB-Instantiated subviews have constraints with cell itself
    // instead of contentView. Since the subviews created in the XIB are, indeed, subviews of contentView,
    // they should be constrained to it rather than to the cell.
    //
    // Normally this is not a problem since the contentView will always fill the cell, but in this case,
    // we are transforming the contentView to achieve the "swipe to delete" behavior, so we need to swap
    // the targets of the constraints to be correct.
    //
    // If this anomaly is ever fixed in UIKit, this method *should* still be safe - the search will simply
    // not find any constraints that match the criteria to be modified.
    //
#warning TODO: File Radar on this
    
    NSArray *initialConstraints = [[self constraints] copy];
    [initialConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        
        if (constraint.firstItem == self && constraint.secondItem != nil)
        {
            if ([self.contentView.subviews containsObject:constraint.secondItem])
            {
                // copy constraint, change first view to content view
                [self removeConstraint:constraint];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:constraint.secondItem
                                                                 attribute:constraint.secondAttribute
                                                                multiplier:constraint.multiplier
                                                                  constant:constraint.constant]];
            }
        }
        else if (constraint.secondItem == self && constraint.firstItem != nil)
        {
            if ([self.contentView.subviews containsObject:constraint.firstItem])
            {
                // copy constraint, change second view to content view
                [self removeConstraint:constraint];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:constraint.firstItem
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:self.contentView
                                                                 attribute:constraint.secondAttribute
                                                                multiplier:constraint.multiplier
                                                                  constant:constraint.constant]];
            }
        }
        
    }];
    
    [self setNeedsUpdateConstraints];
}

- (void)configureGestures
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.contentView addGestureRecognizer:panGesture];
    panGesture.delegate = self;
    panGesture.enabled = NO;
    self.panGesture = panGesture;
}

#pragma mark - Editing

- (void)setRzEditingStyle:(RZCollectionTableViewCellEditingStyle)editingStyle
{
    _rzEditingStyle = editingStyle;
    self.panGesture.enabled = (editingStyle == RZCollectionTableViewCellEditingStyleDelete);
}

- (void)setRzEditing:(BOOL)editing
{
    [self setRzEditing:editing animated:NO];
}

- (void)setRzEditing:(BOOL)editing animated:(BOOL)animated
{
    _rzEditing = editing;

    self.panGesture.enabled = (editing && self.rzEditingStyle == RZCollectionTableViewCellEditingStyleDelete);
    
    [self._rz_parentCollectionTableView _rz_editingStateChangedForCell:self];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[RZCollectionTableViewCellAttributes class]])
    {
        RZCollectionTableViewCellAttributes *rzLayoutAttributes = (RZCollectionTableViewCellAttributes*)layoutAttributes;
        self.rzEditingStyle = rzLayoutAttributes.editingStyle;
        self._rz_parentCollectionTableView = rzLayoutAttributes._rz_parentCollectionTableView;
    }
    else
    {
        self.rzEditingStyle = RZCollectionTableViewCellEditingStyleNone;
        self._rz_parentCollectionTableView = nil;
    }
}

//- (void)commitTvcEdits
//{
//    [self._rz_parentCollectionTableView _rz_editingCommittedForCell:self];
//}

#pragma mark - Pan Gesture handlers

- (void)handlePan:(UIPanGestureRecognizer *)panGesture
{
//    [self setTvcEditing:YES animated:YES];'
    
    static CGFloat initialTranslationX = 0;
    
    CGPoint translation = [panGesture translationInView:self];
    CGAffineTransform currentTransform = self.contentView.transform;

    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            initialTranslationX = currentTransform.tx;
            
        case UIGestureRecognizerStateChanged:
        {
            
            
            CGFloat targetTranslationX = initialTranslationX + translation.x;
            targetTranslationX = MIN(0, targetTranslationX); // must be negative (left)
            
            // if we're beyond the threshold, mitigate the amount we continue to translate
            if (targetTranslationX < -kRZCTDefaultDeleteButtonWidth)
            {
                // effect of translation gets mitigated the farther the target is
            }
            self.contentView.transform = CGAffineTransformMakeTranslation(targetTranslationX, 0);
        }
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.contentView.transform = CGAffineTransformIdentity;
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
            break;

        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = NO;
    if ([gestureRecognizer isKindOfClass:[UIGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint vel = [pan velocityInView:self];
        // if it's more X than y
        if (fabsf(vel.x) > fabsf(vel.y))
        {
            // if it's more left than right
            shouldBegin = (vel.x < 0);
        }
    }
    return shouldBegin;
}

@end
