//
//  NBDetailViewController.m
//  WWDC2014
//
//  Created by Neeraj Baid on 4/8/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import "NBDetailViewController.h"

@interface NBDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@end

@implementation NBDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = self.info[@"name"];
    self.backgroundImageView.image = [UIImage imageNamed:self.info[@"background_image"]];
    self.infoView.layer.shadowRadius = 6;
    self.infoView.layer.shadowOpacity = 0.7;
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
