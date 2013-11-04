//
//  RZCollectionTableViewCellm
//
//  Created by Nick Donaldson on 9/13/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RZCollectionTableViewCell.h"
#import "RZCollectionTableView.h"
#import "RZCollectionTableView_Private.h"

#define kRZCTDefaultDeleteButtonWidth 80.f
#define kRZCTEditStateAnimDuration    0.6

NSString * const RZCollectionTableViewCellEditingStateChanged = @"RZCollectionTableViewCellEditingStateChanged";
NSString * const RZCollectionTableViewCellEditingCommitted = @"RZCollectionTableViewCellEditingCommitted";

@interface RZCollectionTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, weak) UIView *swipeableContentHostView;

@property (nonatomic, weak) UIPanGestureRecognizer *panGesture;

- (void)createSwipeableView;

// NOTE: see comments in implementation of this method
- (void)moveSubviewsToSwipeableContainer;

- (void)configureGestures;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;

@end

@implementation RZCollectionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createSwipeableView];
        [self configureGestures];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self createSwipeableView];
        [self configureGestures];
        [self moveSubviewsToSwipeableContainer];
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

- (void)createSwipeableView
{
    UIView *swipeView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    swipeView.backgroundColor = self.backgroundColor;
    swipeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:swipeView];
    self.swipeableContentHostView = swipeView;
}

- (void)moveSubviewsToSwipeableContainer
{
    // move all of content view's subviews to the pannable container
    NSArray *subviews = [[self.contentView subviews] copy];
    [subviews enumerateObjectsUsingBlock:^(UIView *sv, NSUInteger idx, BOOL *stop) {
        if (sv != self.swipeableContentHostView)
        {
            [self.swipeableContentHostView addSubview:sv];
        }
    }];
    
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
        
        if (constraint.firstItem == self.swipeableContentHostView || constraint.secondItem == self.swipeableContentHostView) return;
        
        if ((constraint.firstItem == self || constraint.firstItem == self.contentView) && constraint.secondItem != nil)
        {
            if ([self.swipeableContentHostView.subviews containsObject:constraint.secondItem])
            {
                // copy constraint, change first view to content view
                [self removeConstraint:constraint];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.swipeableContentHostView
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:constraint.secondItem
                                                                 attribute:constraint.secondAttribute
                                                                multiplier:constraint.multiplier
                                                                  constant:constraint.constant]];
            }
        }
        else if ((constraint.secondItem == self || constraint.secondItem == self.contentView) && constraint.firstItem != nil)
        {
            if ([self.swipeableContentHostView.subviews containsObject:constraint.firstItem])
            {
                // copy constraint, change second view to content view
                [self removeConstraint:constraint];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:constraint.firstItem
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:self.swipeableContentHostView
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
    [self.swipeableContentHostView addGestureRecognizer:panGesture];
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
    static CGFloat initialTranslationX = 0;
    
    CGPoint translation = [panGesture translationInView:self];
    CGAffineTransform currentTransform = self.swipeableContentHostView.transform;

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
                CGFloat overshoot = -kRZCTDefaultDeleteButtonWidth - targetTranslationX;
                targetTranslationX = -kRZCTDefaultDeleteButtonWidth - overshoot*0.25;
            }
            
            self.swipeableContentHostView.transform = CGAffineTransformMakeTranslation(targetTranslationX, 0);
        }
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            
            [UIView animateWithDuration:kRZCTEditStateAnimDuration * 0.33
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.swipeableContentHostView.transform = CGAffineTransformMakeTranslation(currentTransform.tx * 0.2, 0);
                             } completion:^(BOOL finished) {
                                
                                 [UIView animateWithDuration:kRZCTEditStateAnimDuration * 0.66
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      self.swipeableContentHostView.transform = CGAffineTransformIdentity;
                                                  } completion:^(BOOL finished) {
                                                      
                                                  }];
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
    if (gestureRecognizer == self.panGesture)
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
    else if ([super respondsToSelector:@selector(gestureRecognizerShouldBegin:)])
    {
        shouldBegin = [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return shouldBegin;
}

@end
