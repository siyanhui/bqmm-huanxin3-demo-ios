//
//  EMBubbleView+MMText.m
//  ChatDemo-UI3.0
//
//  Created by LiChao Jun on 16/2/4.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import "EMBubbleView+MMText.h"
#import <objc/runtime.h>

#import "MMTextView.h"

static const void *textViewKey = &textViewKey;

@implementation EaseBubbleView (MMText)

#pragma mark - private

- (void)_setupMMTextBubbleMarginConstraints
{
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
    
    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupMMTextBubbleConstraints
{
    [self _setupMMTextBubbleMarginConstraints];
}

- (NSString *)textView {
    return objc_getAssociatedObject(self, textViewKey);
}

- (void)setTextView:(UITextView *)textView {
    objc_setAssociatedObject(self, textViewKey, textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public

- (void)setupMMTextBubbleViewWithModel:(id<IMessageModel>)model
{
    self.textView = [[MMTextView alloc] init];
    self.textView.mmFont = [UIFont systemFontOfSize:15];
    self.textView.mmTextColor = [UIColor blackColor];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.backgroundImageView addSubview:self.textView];
    
    [self _setupMMTextBubbleConstraints];
}

- (void)updateMMTextMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupMMTextBubbleMarginConstraints];
}

@end
