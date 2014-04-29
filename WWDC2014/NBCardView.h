//
//  NBCardView.h
//  WWDC2014
//
//  Created by Neeraj Baid on 4/8/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBViewController.h"
#import "TTTAttributedLabel.h"

@interface NBCardView : UIView <UIAlertViewDelegate>

@property (nonatomic) CGPoint previousTouch;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) id<MapViewDelegate> delegate;

- (void)setup;
- (void)animateOut;

@end
