//
//  NBCardView.m
//  WWDC2014
//
//  Created by Neeraj Baid on 4/8/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import "NBCardView.h"

@implementation NBCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

# pragma mark - Setup

- (void)setup
{
    self.backgroundImageView.layer.cornerRadius = 10;
    self.titleLabel.textColor = [UIColor whiteColor];
}

#pragma mark - Touches/Dragging

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    if (self.previousTouch.y == 0)
        _previousTouch = location;
    CGFloat translation = location.y - self.previousTouch.y;
    [self setCenter:CGPointMake(self.center.x, self.center.y + translation/3.0)];
    _previousTouch = location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _previousTouch = CGPointMake(0, 0);
    if (self.frame.origin.y > self.superview.frame.size.height - 300)
        [self animateOut];
    else
        [self animateRestore];
}

- (void)animateOut
{
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
         [self.delegate animatedOutCardView];
     } completion:^(BOOL completed){
         if (completed)
         {
             [self removeFromSuperview];
             self.alpha = 0;
         }
     }];
}

- (IBAction)dismiss:(id)sender
{
    [self animateOut];
}

- (void)animateRestore
{
    [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - 300, self.frame.size.width, self.frame.size.height);
     } completion:^(BOOL completed){
         
     }];
}

@end
