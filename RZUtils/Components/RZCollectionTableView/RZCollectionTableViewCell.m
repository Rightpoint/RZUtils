//
//  RZCollectionTableViewCellm
//
//  Created by Nick Donaldson on 9/13/13.

//  Copyright (c) 2013 RaizLabs. 
//

#import <QuartzCore/QuartzCore.h>
#import "RZCollectionTableViewCell.h"
#import "RZCollectionTableView.h"
#import "RZCollectionTableView_Private.h"

#define kRZCTEditingButtonWidth       80.f
#define kRZCTEditStateAnimDuration    0.3

@interface RZCollectionTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *rzEditingItems;

@property (nonatomic, readwrite, weak) UIView *swipeableContentHostView;
@property (nonatomic, weak) UIView            *editingButtonsHostView;
@property (nonatomic, strong) NSArray         *editingButtons;

@property (nonatomic, weak) UIPanGestureRecognizer *panGesture;

@end

@interface RZCollectionTableViewCellEditingItem ()

@property (nonatomic, copy) NSString  *title;
@property (nonatomic, strong) UIFont  *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleHighlightColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *highlightedIcon;

@end

// ------------------------------------------------

@implementation RZCollectionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self createHostViews];
        [self configureGestures];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self createHostViews];
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

- (void)createHostViews
{
    UIView *editingButtonView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    editingButtonView.backgroundColor  = self.backgroundColor;
    editingButtonView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:editingButtonView];
    self.editingButtonsHostView = editingButtonView;

    UIView *swipeView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    swipeView.backgroundColor  = self.backgroundColor;
    swipeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:swipeView];
    self.swipeableContentHostView = swipeView;
}

- (void)moveSubviewsToSwipeableContainer
{
    // move all of content view's subviews to the pannable container
    NSArray *subviews = [[self.contentView subviews] copy];
    [subviews enumerateObjectsUsingBlock:^(UIView *sv, NSUInteger idx, BOOL *stop) {
        if ( sv != self.swipeableContentHostView && sv != self.editingButtonsHostView ) {
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
    // we are moving the subviews to a new container to achieve the "swipe to delete" behavior, so we need to swap
    // the targets of the constraints to be correct.
    //
    // If this anomaly is ever fixed in UIKit, this method *should* still be safe - the search will simply
    // not find any constraints that match the criteria to be modified.
    //

    NSArray *initialConstraints = [[self constraints] copy];
    [initialConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {

        if ( constraint.firstItem == self.swipeableContentHostView || constraint.secondItem == self.swipeableContentHostView ) {return;}

        if ( ( constraint.firstItem == self || constraint.firstItem == self.contentView ) && constraint.secondItem != nil ) {
            if ( [self.swipeableContentHostView.subviews containsObject:constraint.secondItem] ) {
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
        else if ( ( constraint.secondItem == self || constraint.secondItem == self.contentView ) && constraint.firstItem != nil ) {
            if ( [self.swipeableContentHostView.subviews containsObject:constraint.firstItem] ) {
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
    panGesture.enabled  = NO;
    self.panGesture     = panGesture;
}

- (void)refreshEditingButtons
{
    [self.editingButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *newButtons = [NSMutableArray array];

    [self.rzEditingItems enumerateObjectsUsingBlock:^(RZCollectionTableViewCellEditingItem *item, NSUInteger idx, BOOL *stop) {

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        button.backgroundColor = item.bgColor ? item.bgColor : [UIColor redColor];

        [button addTarget:self action:@selector(editingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        if ( item.icon ) {
            [button setImage:item.icon forState:UIControlStateNormal];
            [button setImage:item.highlightedIcon forState:UIControlStateHighlighted];
        }
        else {
            [button setTitle:item.title forState:UIControlStateNormal];
            [button.titleLabel setFont:item.titleFont];
            [button setTitleColor:item.titleColor forState:UIControlStateNormal];
            [button setTitleColor:item.titleHighlightColor forState:UIControlStateHighlighted];
        }

        [self.editingButtonsHostView addSubview:button];
        [self.editingButtonsHostView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:nil views:@{ @"button" : button }]];
        [self.editingButtonsHostView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                                attribute:NSLayoutAttributeWidth
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0
                                                                                 constant:kRZCTEditingButtonWidth]];

        if ( idx > 0 ) {
            // right-align to previous button
            UIButton *prevButton = [newButtons objectAtIndex:idx - 1];
            [self.editingButtonsHostView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                                    attribute:NSLayoutAttributeRight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:prevButton
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1.0
                                                                                     constant:0]];
        }
        else {
            // right-align to container
            [self.editingButtonsHostView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                                    attribute:NSLayoutAttributeRight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.editingButtonsHostView
                                                                                    attribute:NSLayoutAttributeRight
                                                                                   multiplier:1.0
                                                                                     constant:0]];
        }

        [newButtons addObject:button];

        // update background color of container to match last button
        if ( idx == self.editingButtons.count ) {
            self.editingButtonsHostView.backgroundColor = item.bgColor;
        }
    }];

    self.editingButtons = [NSArray arrayWithArray:newButtons];
}

- (void)editingButtonPressed:(UIButton *)button
{
    NSInteger idx = [self.editingButtons indexOfObject:button];
    if ( idx != NSNotFound ) {
        [self._rz_parentCollectionTableView _rz_editingButtonPressed:idx forCell:self];
    }
}

#pragma mark - Editing

- (void)setRzEditingItems:(NSArray *)editingItems
{
    _rzEditingItems = editingItems;
    [self refreshEditingButtons];
}

- (void)setRzEditingEnabled:(BOOL)rzEditingEnabled
{
    if ( rzEditingEnabled && self.rzEditingItems.count == 0 ) {
        _rzEditingEnabled = NO;
        NSLog(@"ERROR: Cannot enable editing on RZCollectionTableViewCell with no editing items set");
    }
    else {
        _rzEditingEnabled = rzEditingEnabled;
        self.panGesture.enabled = rzEditingEnabled;
    }
}

- (void)setRzEditing:(BOOL)editing
{
    [self setRzEditing:editing animated:NO];
}

- (void)setRzEditing:(BOOL)editing animated:(BOOL)animated
{
    _rzEditing = editing;

    self.swipeableContentHostView.userInteractionEnabled = !editing;

    CGFloat stopTarget = editing ? ( -kRZCTEditingButtonWidth * self.rzEditingItems.count ) : 0;
    if ( animated ) {
        [UIView animateWithDuration:kRZCTEditStateAnimDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.swipeableContentHostView.transform = CGAffineTransformMakeTranslation(stopTarget, 0);
        } completion:nil];
    }
    else {
        self.swipeableContentHostView.transform = CGAffineTransformMakeTranslation(stopTarget, 0);
    }

    [self._rz_parentCollectionTableView _rz_editingStateChangedForCell:self];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ( [layoutAttributes isKindOfClass:[RZCollectionTableViewCellAttributes class]] ) {
        RZCollectionTableViewCellAttributes *rzLayoutAttributes = (RZCollectionTableViewCellAttributes *)layoutAttributes;
        self.rzEditingEnabled              = rzLayoutAttributes.rzEditingEnabled;
        self._rz_parentCollectionTableView = rzLayoutAttributes._rz_parentCollectionTableView;
    }
    else {
        self.rzEditingEnabled              = NO;
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

    CGPoint           translation      = [panGesture translationInView:self];
    CGAffineTransform currentTransform = self.swipeableContentHostView.transform;
    CGFloat           maxTransX        = -kRZCTEditingButtonWidth * self.rzEditingItems.count;

    switch ( panGesture.state ) {
        case UIGestureRecognizerStateBegan:

            initialTranslationX = currentTransform.tx;

        case UIGestureRecognizerStateChanged: {
            CGFloat targetTranslationX = initialTranslationX + translation.x;
            targetTranslationX = MIN(0, targetTranslationX); // must be negative (left)

            // if we're beyond the threshold, mitigate the amount we continue to translate
            if ( targetTranslationX < maxTransX ) {
                // effect of translation gets mitigated the farther the target is
                CGFloat overshoot = maxTransX - targetTranslationX;
                targetTranslationX = maxTransX - overshoot * 0.3333;
            }

            self.swipeableContentHostView.transform = CGAffineTransformMakeTranslation(targetTranslationX, 0);
        }
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if ( currentTransform.tx < maxTransX ) {
                [self setRzEditing:YES animated:YES];
            }
            else {
                [self setRzEditing:NO animated:YES];
            }
        }
            break;

        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = NO;
    if ( gestureRecognizer == self.panGesture ) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint                vel  = [pan velocityInView:self];
        // if it's more X than y
        if ( fabsf(vel.x) > fabsf(vel.y) ) {
            // if it's more left than right
            shouldBegin = ( vel.x < 0 );
        }
    }
    else if ( [super respondsToSelector:@selector(gestureRecognizerShouldBegin:)] ) {
        shouldBegin = [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return shouldBegin;
}

@end

@implementation RZCollectionTableViewCellEditingItem

+ (RZCollectionTableViewCellEditingItem *)itemWithTitle:(NSString *)title
                                                   font:(UIFont *)font
                                             titleColor:(UIColor *)titleColor
                                  highlightedTitlecolor:(UIColor *)highlightedTitleColor
                                        backgroundColor:(UIColor *)backgroundColor
{
    RZCollectionTableViewCellEditingItem *item = [RZCollectionTableViewCellEditingItem new];
    item.title               = title;
    item.titleFont           = font;
    item.titleColor          = titleColor;
    item.titleHighlightColor = highlightedTitleColor ? highlightedTitleColor : titleColor;
    item.bgColor             = backgroundColor;
    return item;
}

+ (RZCollectionTableViewCellEditingItem *)itemWithIcon:(UIImage *)icon
                                       highlightedIcon:(UIImage *)highlightedIcon
                                       backgroundColor:(UIColor *)backgroundColor
{
    RZCollectionTableViewCellEditingItem *item = [RZCollectionTableViewCellEditingItem new];
    item.icon            = icon;
    item.highlightedIcon = highlightedIcon ? highlightedIcon : icon;
    item.bgColor         = backgroundColor;
    return item;
}


@end
