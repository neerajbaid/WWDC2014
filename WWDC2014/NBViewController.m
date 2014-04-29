//
//  NBViewController.m
//  WWDC2014
//
//  Created by Neeraj Baid on 4/8/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import "NBViewController.h"
#import "NBSearchTableViewCell.h"
#import "NBMapViewAnnotation.h"
#import "NBDetailViewController.h"
#import "NBCardView.h"
#import "TTTAttributedLabel.h"
#import <MapKit/MapKit.h>

@interface NBViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, MapViewDelegate, TTTAttributedLabelDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *searchResults;
@property (nonatomic) BOOL cardIsVisible;

@property (weak, nonatomic) IBOutlet UIView *introView;
@property (weak, nonatomic) IBOutlet UIImageView *introImage;

@end

@implementation NBViewController 

# pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NBSearchTableViewCell *cell = [self.searchTableView dequeueReusableCellWithIdentifier:@"search_cell" forIndexPath:indexPath];
    
    NSDictionary *info;
    if (self.searchResults.count == 0)
        info = self.data[indexPath.row];
    else
        info = self.searchResults[indexPath.row];
    
    cell.categoryLabel.text = info[@"category"];
    cell.nameLabel.text = info[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchResults.count == 0)
        return self.data.count;
    else
        return self.searchResults.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *info;
    if (self.searchResults.count == 0)
        info = self.data[indexPath.row];
    else
        info = self.searchResults[indexPath.row];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
    [self animateOutTableView];
    [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.13, 0.13))];
    NSArray *allAnnotations = self.mapView.annotations;
    for (NBMapViewAnnotation *annotation in allAnnotations)
    {
        if([annotation.info isEqual:info])
        {
            [self.mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
    [self cancelSearch];
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

# pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self animateInTableView];
    [self addRightBarButtonItem];
}

- (void)search
{
    if (self.introView.alpha > 0)
        [self animateOutIntro];
    [self animateInSearchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqual:@""])
        self.searchResults = [NSArray array];
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category CONTAINS[cd] %@ OR name CONTAINS[cd] %@", searchText, searchText];
        NSArray *results = [self.data filteredArrayUsingPredicate:predicate];
        [self setSearchResults:results];
    }
    [self.searchTableView reloadData];
}

# pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NBMapViewAnnotation class]])
    {
        MKPinAnnotationView *pinView = nil;
        
        static NSString *defaultPinID = @"identifier";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            pinView.pinColor = MKPinAnnotationColorRed;  //or Green or Purple
            
            pinView.enabled = YES;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSDictionary *info = ((NBMapViewAnnotation *)view.annotation).info;
    [self.mapView deselectAnnotation:view.annotation animated:YES];
    [self animateUpAddCardView:[self setupCardViewWithInfo:info]];
}

# pragma mark - View

- (void)animateInTableView
{
    [UIView animateWithDuration:0.2 animations:^(void)
     {
         self.searchTableView.alpha = 1;
     }];
}

- (void)animateOutTableView
{
    [UIView animateWithDuration:0.2 animations:^(void)
     {
         self.searchTableView.alpha = 0;
         [self.searchBar resignFirstResponder];
     }];
}

- (void)animatedOutCardView
{
    [UIView animateWithDuration:0.5 animations:^(void)
     {
         self.mapView.alpha = 1;
     }];
    self.mapView.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)animateInSearchBar
{
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         self.searchBar.alpha = 1;
         [self.searchBar becomeFirstResponder];
     } completion:^(BOOL completion)
     {
     }];
}

- (void)animateOutSearchBar
{
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         self.searchBar.alpha = 0;
         [self.searchBar resignFirstResponder];
     } completion:^(BOOL completion)
     {
     }];
}

- (void)cancelSearch
{
    [self animateOutTableView];
    [self animateOutSearchBar];
    self.searchResults = [NSArray array];
    self.searchBar.text = @"";
    self.navigationItem.rightBarButtonItem = nil;
    [self.searchTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage new];
    for (UIView *view in [self.searchBar.subviews[0] subviews])
    {
        if ([view isKindOfClass:[UITextField class]])
        {
            view.layer.borderColor = [[UIColor grayColor] CGColor];
            view.layer.borderWidth = 1;
            view.layer.cornerRadius = 4;
        }
    }
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.alpha = 0;
    self.searchBar.alpha = 0;
    [self setupNavigationBar];
    self.mapView.delegate = self;
    
    [self readInfo];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"NBSearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"search_cell"];
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.7, -122.153127), MKCoordinateSpanMake(0.85, 0.85))];
    [self setupMapView];
    [self setupIntroView];
}

- (void)tappedNavTitle
{
    if (self.introView.alpha == 0)
        [self animateInIntro];
    else
        [self animateOutIntro];
}

- (void)setupIntroView
{
    self.introView.layer.cornerRadius = 5;
    self.introView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.9];
    self.introView.layer.borderColor = [[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1] CGColor];
    self.introView.layer.borderWidth = 1;
    [self.introView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateOutIntro)]];
    
    self.introImage.layer.cornerRadius = 30;
    self.introImage.layer.borderColor = [[UIColor blackColor] CGColor];
    self.introImage.layer.borderWidth = 1;
    self.introImage.layer.masksToBounds = YES;
    
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    
    [self.mapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateOutIntro)]];
}

- (void)animateInIntro
{
    [UIView animateWithDuration:.3 animations:^(void)
     {
         self.introView.alpha = 1;
         self.mapView.scrollEnabled = NO;
         self.mapView.zoomEnabled = NO;
     } completion:^(BOOL finished)
     {
         
     }];
}

- (void)animateOutIntro
{
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    [UIView animateWithDuration:.3 animations:^(void)
     {
         self.introView.alpha = 0;
     } completion:^(BOOL finished)
     {
     }];
}

- (void)setupNavigationBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[UIImage imageNamed:@"Search.png"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    button.alpha = 0.5;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Neeraj.png"]];
    imageView.frame = CGRectMake(44, 7, 123, 30);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view addSubview:imageView];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedNavTitle)]];
    self.navigationController.navigationBar.topItem.titleView = view;
    
//    [self addRightBarButtonItem];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)addRightBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    [button addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    button.alpha = 0.5;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)addCardView:(NBCardView *)cardView
{
    CGRect r = cardView.frame;
    r.origin.y = self.view.bounds.size.height;
    cardView.frame = r;
    cardView.delegate = self;
    [self.view addSubview:cardView];
}

- (void)setupMapView
{
    for (NSDictionary *item in self.data)
    {
        NBMapViewAnnotation *annotation = [[NBMapViewAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue]) title:item[@"name"] subtitle:item[@"category"]];
        annotation.info = item;
        [self.mapView addAnnotation:annotation];
    }
}

- (NBCardView *)setupCardViewWithInfo:(NSDictionary *)info
{
    NBCardView *cardView = [[NSBundle mainBundle] loadNibNamed:@"NBCardView" owner:self options:Nil][0];
    
    cardView.backgroundImageView.backgroundColor = [[UIColor alloc] initWithRed:[info[@"red"] doubleValue]/255.0 green:[info[@"green"] doubleValue]/255.0 blue:[info[@"blue"] doubleValue]/255.0 alpha:1];
    const CGFloat *components = CGColorGetComponents([cardView.backgroundImageView.backgroundColor CGColor]);
    double perceptiveLuminance = 1 - (0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]);
    
    if (perceptiveLuminance < 0.5)
    {
        cardView.titleLabel.textColor = [UIColor blackColor];
        cardView.descriptionLabel.textColor = [UIColor blackColor];
    }
    else
    {
        cardView.titleLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        cardView.descriptionLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    [self setupButtonsInView:cardView];
    
    cardView.titleLabel.textAlignment = NSTextAlignmentCenter;
    cardView.titleLabel.text = info[@"name"];
    cardView.descriptionLabel.text = info[@"description"];
    [cardView.descriptionLabel sizeToFit];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:cardView.descriptionLabel.textColor, [NSNumber numberWithInt:kCTUnderlineStyleSingle], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName, kCTUnderlineStyleAttributeName, nil];
    objects = [[NSArray alloc] initWithObjects:[UIColor blueColor], [NSNumber numberWithInt:kCTUnderlineStyleSingle], nil];
    NSDictionary *activeLinkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    cardView.descriptionLabel.linkAttributes = linkAttributes;
    cardView.descriptionLabel.activeLinkAttributes = activeLinkAttributes;
    cardView.descriptionLabel.delegate = self;
    
    NSMutableDictionary *titleLinkAttributes = [linkAttributes mutableCopy];
    NSMutableDictionary *titleActiveLinkAttributes = [activeLinkAttributes mutableCopy];
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [titleLinkAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [titleActiveLinkAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    cardView.titleLabel.linkAttributes = titleLinkAttributes;
    cardView.titleLabel.activeLinkAttributes = titleActiveLinkAttributes;
    cardView.titleLabel.delegate = self;
    
    for (int l = 0; l < [info[@"body_links"] count]; l++)
    {
        [cardView.descriptionLabel addLinkToURL:[NSURL URLWithString:info[@"body_links"][l]] withRange:[cardView.descriptionLabel.text rangeOfString:info[@"text_for_body_links"][l]]];
    }
    for (int l = 0; l < [info[@"title_links"] count]; l++)
    {
        [cardView.titleLabel addLinkToURL:[NSURL URLWithString:info[@"title_links"][l]] withRange:[cardView.titleLabel.text rangeOfString:info[@"text_for_title_links"][l]]];
    }
    
    return cardView;
}

- (void)setupButtonsInView:(NBCardView *)cardView
{
    [cardView.dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cardView.dismissButton.backgroundColor = [UIColor colorWithRed:76/255.0 green:218/255.0 blue:101/255.0 alpha:1];
    cardView.dismissButton.layer.cornerRadius = 5;
}

- (void)animateUpAddCardView:(NBCardView *)cardView
{
    [self addCardView:cardView];
    cardView.alpha = 1;
    [cardView setup];
    self.mapView.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         cardView.alpha = 1;
         CGRect r = cardView.frame;
         r.origin.y = self.view.bounds.size.height-300;
         cardView.frame = r;
         self.mapView.alpha = 0.5;
     } completion:^(BOOL completed){
         self.cardIsVisible = YES;
     }];
}

# pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

# pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}

# pragma mark - Misc

- (void)readInfo
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"json"];
    NSError *error;
    self.data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingAllowFragments error:&error];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                 initWithKey:@"name"
                                 ascending:YES
                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
    self.data = [self.data sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
