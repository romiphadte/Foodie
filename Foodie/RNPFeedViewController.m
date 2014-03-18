//
//  RNPFeedViewController.m
//  Foodie
//
//  Created by Neeraj Baid on 3/2/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPFeedViewController.h"
#import "RNPFeedCell.h"
#import "RNPBreakCell.h"
#import "RNPFeedHeader.h"
#import "RNPFeedFooter.h"
#import "RNPFeedNavigationItemView.h"
#import "RNPRestaurantFeedViewController.h"
#import "UIImageView+WebCache.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <OHAttributedLabel/OHASBasicMarkupParser.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <CoreLocation/CoreLocation.h>
#import <FontAwesome+iOS/NSString+FontAwesome.h>


@interface RNPFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MBProgressHUD *HUD;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationUpdateIsForNearbyRefresh;

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) CGFloat effectiveSpeed;
@property (nonatomic) BOOL isScrollingDownwards;

@property (nonatomic, strong) NSMutableArray *cells;
@property (weak, nonatomic) IBOutlet FXBlurView *cameraButtonBlurView;

@property (strong, nonatomic) UIColor *color;

@end

@implementation RNPFeedViewController

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
    [FXBlurView setUpdatesEnabled];
    
    if (!_cells)
        _cells = [NSMutableArray array];
    _color = [UIColor colorWithRed:146/255.0 green:209/255.0 blue:105/255.0 alpha:1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"image_cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPBreakCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"break_cell"];
    [self.tableView addInfiniteScrollingWithActionHandler:^(void) {
        [self getNextPage];
    }];
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc] init];
    pullToRefresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [pullToRefresh addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
    pullToRefresh.tintColor = _color;
    pullToRefresh.attributedTitle = [NSAttributedString attributedStringWithString:@""];
    pullToRefresh.alpha = .8;
    [self.tableView addSubview:pullToRefresh];
    [self configureBlurView];
    [self addSwipeLeft];
    [self addSwipeRight];
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [self getLocation];
    [(RNPFeedNavigationItemView *)self.navigationItem.titleView setDelegate:self];
    RNPFeedNavigationItemView *itemView = (RNPFeedNavigationItemView *)self.navigationItem.titleView;
    [itemView setSelectedIndex:itemView.segmentedControl.selectedSegmentIndex];
    [(RNPFeedNavigationItemView *)self.navigationItem.titleView setDelegate:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)configureBlurView
{
    int num_iterations = 2;
    int blur_radius = 30;
    int update_interval = .1;
    _cameraButtonBlurView.layer.cornerRadius = 35;
    _cameraButtonBlurView.layer.masksToBounds = YES;
    _cameraButtonBlurView.iterations = num_iterations;
    [_cameraButtonBlurView setTintColor:[UIColor colorWithRed:243.0/255.0 green:97.0/255.0 blue:0 alpha:1]];
    [_cameraButtonBlurView setBlurRadius:blur_radius];
    [_cameraButtonBlurView setUpdateInterval:update_interval];
}

- (void)addSwipeLeft
{
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    swipeGR.delegate = self;
    swipeGR.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.tableView addGestureRecognizer:swipeGR];
}

- (void)swipeLeft
{
    UISegmentedControl *feedSelector = [(RNPFeedNavigationItemView *)self.navigationItem.titleView segmentedControl];
    if ([feedSelector selectedSegmentIndex] == 1)
        [(RNPFeedNavigationItemView *)self.navigationItem.titleView setSelectedIndex:0];
    else if ([feedSelector selectedSegmentIndex] == 2)
        [(RNPFeedNavigationItemView *)self.navigationItem.titleView setSelectedIndex:1];
}

- (void)addSwipeRight
{
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    swipeGR.delegate = self;
    swipeGR.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.tableView addGestureRecognizer:swipeGR];
}

- (void)swipeRight
{
    UISegmentedControl *feedSelector = [(RNPFeedNavigationItemView *)self.navigationItem.titleView segmentedControl];
    if ([feedSelector selectedSegmentIndex] == 0)
        [(RNPFeedNavigationItemView *)self.navigationItem.titleView setSelectedIndex:1];
    else if ([feedSelector selectedSegmentIndex] == 1)
        [(RNPFeedNavigationItemView *)self.navigationItem.titleView setSelectedIndex:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c;
    if (indexPath.row == 0)
    {
        RNPFeedCell *cell = (RNPFeedCell *)[self.tableView dequeueReusableCellWithIdentifier:@"image_cell"];
        
        NSDictionary *data = [_data objectAtIndex:indexPath.section];
        NSString *urlString = [data objectForKey:@"url"];
        NSURL *imageURL = [NSURL URLWithString:urlString];
        
        [cell.imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             [cell.imageView setBackgroundColor:[UIColor colorWithRed:130 green:130 blue:130 alpha:1]];
             cell.imageView.alpha = 0.0;
             [UIView animateWithDuration:.35
                              animations:^{
                                  cell.imageView.alpha = 1.0;
                              }];
         }];
        
        cell.caption.text = [data objectForKey:@"caption"];
        
        int num_iterations = 1;
        int blur_radius = 30;
        int update_interval = .2;
        
        [FXBlurView setUpdatesEnabled];
        [FXBlurView setBlurEnabled:YES];
        
        [cell.blurView setTintColor:[UIColor blackColor]];
        cell.blurView.iterations = num_iterations;
        cell.blurView.blurRadius = blur_radius;
        cell.blurView.updateInterval = update_interval;

        c = cell;
        
        [_cells setObject:cell atIndexedSubscript:indexPath.section];
    }
    else
    {
        RNPBreakCell *cell = (RNPBreakCell *)[self.tableView dequeueReusableCellWithIdentifier:@"break_cell"];
        c = cell;
    }

//    if (indexPath.section != 0 && indexPath.section != 1 && _effectiveSpeed < 0 && _effectiveSpeed > -30)
//    {
//        NSLog(@"reload section: %ld", (long)indexPath.section);
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section-1] withRowAnimation:UITableViewRowAnimationNone];
//    }
    
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 367;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *subviews = [self.tableView subviews];
//    NSLog(@"subviews: %@", [subviews description]);
//    NSLog(@"offset: %f", self.tableView.contentOffset.y);
    for (UIView *view in subviews)
    {
        if ([view isKindOfClass:[UIView class]] && ![view isKindOfClass:[UIImageView class]] && ![view isKindOfClass:[SVInfiniteScrollingView class]] && ![view isKindOfClass:[UIRefreshControl class]]  && section > 1)
        {
            if (view.frame.origin.y - self.tableView.contentOffset.y > 70)
            {
                RNPFeedHeader *headerView = [view subviews][0];
                headerView.blurView.underlyingView = [_cells[section-1] imageView];
                break;
            }
        }
    }
    
    RNPFeedHeader *headerView = [[NSBundle mainBundle] loadNibNamed:@"RNPFeedHeader" owner:self options:Nil][0];
    UIView *view = [[UIView alloc] initWithFrame:[headerView frame]];
    
    NSDictionary *data = [_data objectAtIndex:section];
    
    headerView.username.text = [data objectForKey:@"dish"];
    headerView.restaurantID = [data objectForKey:@"restaurantid"];
    headerView.restaurantName = [data objectForKey:@"restaurantname"];
    
    headerView.blurView.tintColor = [UIColor blackColor];
    headerView.blurView.updateInterval = 0;
    headerView.blurView.underlyingView = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].imageView;
    headerView.blurView.blurRadius = 40;
    
    headerView.delegate = self;
    
    NSString *str = [_profilePictures objectForKey:[data objectForKey:@"username"]];
    NSURL *url = [NSURL URLWithString:str];
    
    [headerView.profilePicture setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         [headerView.profilePicture setBackgroundColor:[UIColor colorWithRed:130 green:130 blue:130 alpha:1]];
         headerView.profilePicture.alpha = 0.0;
         [UIView animateWithDuration:.35
                          animations:^{
                              headerView.profilePicture.alpha = 1.0;
                          }];
     }];
    
    headerView.profilePicture.layer.cornerRadius = 19;
    headerView.profilePicture.layer.masksToBounds = YES;
    headerView.profilePicture.layer.borderColor = [UIColor blackColor].CGColor;
    headerView.profilePicture.layer.borderWidth = 1;
    
    NSString *locationString = [NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForEnum:FAIconMapMarker], [data objectForKey:@"restaurantname"]];
    headerView.label.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
    headerView.label.text = locationString;
    [headerView.label sizeToFit];
    headerView.label.layer.cornerRadius = 10;
    headerView.label.backgroundColor = [UIColor colorWithRed:34/255.0 green:113/255.0 blue:210/255.0 alpha:1];
    headerView.label.frame = CGRectMake(headerView.label.frame.origin.x, headerView.label.frame.origin.y+1, headerView.label.frame.size.width+14, headerView.label.frame.size.height+8);
    
    NSString *userString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAIconUser], [data objectForKey:@"username"]];
    headerView.usernameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:11];
    headerView.usernameLabel.text = userString;
    [headerView.usernameLabel sizeToFit];
    headerView.usernameLabel.layer.cornerRadius = 10;
    headerView.usernameLabel.backgroundColor = [UIColor colorWithRed:223/255.0 green:65/255.0 blue:44/255.0 alpha:1];
    headerView.usernameLabel.frame = CGRectMake(headerView.label.frame.origin.x + headerView.label.frame.size.width + 5, headerView.label.frame.origin.y, headerView.usernameLabel.frame.size.width+14, headerView.label.frame.size.height);
    
    headerView.likes.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[data objectForKey:@"likes"] count]];
    
//    NSMutableAttributedString* basicMarkupString = [OHASBasicMarkupParser attributedStringByProcessingMarkupInAttributedString:headerView.label.attributedText];
//    headerView.label.attributedText = basicMarkupString;
    
    [view addSubview:headerView];
    return view;
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
//    NSLog(@"offset: %f", self.lastContentOffset - self.tableView.contentOffset.y);
    
//    if (self.lastContentOffset > self.tableView.contentOffset.y)
//        _effectiveSpeed = self.lastContentOffset - self.tableView.contentOffset.y;
//    else if (self.lastContentOffset < self.tableView.contentOffset.y)
//        _isScrollingDownwards = YES;
    
    _effectiveSpeed = self.lastContentOffset - self.tableView.contentOffset.y;
    self.lastContentOffset = self.tableView.contentOffset.y;
}
 */

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    RNPFeedFooter *footerView = [[NSBundle mainBundle] loadNibNamed:@"RNPFeedFooter" owner:self options:Nil][0];
    UIView *view = [[UIView alloc] initWithFrame:[footerView frame]];
    
    footerView.blurView.tintColor = [UIColor blackColor];
    footerView.blurView.updateInterval = 0;
    footerView.blurView.underlyingView = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].imageView;
    footerView.blurView.blurRadius = 175;
    
    [view addSubview:footerView];
    return view;
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 43;
}
 */

#pragma mark - Updating

- (void)update:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
    RNPFeedNavigationItemView *itemView = (RNPFeedNavigationItemView *)self.navigationItem.titleView;
    [itemView setSelectedIndex:itemView.segmentedControl.selectedSegmentIndex];
}

- (void)getNextPage
{
    UISegmentedControl *feedSelector = [(RNPFeedNavigationItemView *)self.navigationItem.titleView segmentedControl];
    int selectedIndex = (int)[feedSelector selectedSegmentIndex];
    if (selectedIndex == 0)
        [self nextPageFollowingFeed];
    else if (selectedIndex == 1)
        [self nextPageNearbyFeed];
    else if (selectedIndex == 2)
        [self nextPageGlobalFeed];
}

- (void)updateFollowingFeed
{
    NSLog(@"update following feed");
    NSString *str = @"http://foodieapp.herokuapp.com/images_following/cHQdfW429KXwp8FQNK7u/2neeraj"; //need to add user info
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             if ([info count] > 1)
             {
                 _data = info[0];
                 _profilePictures = info[1];
                 [self.tableView reloadData];
                 [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
             }
             else
             {
                 // false
             }
         }
     }];
}

- (void)nextPageFollowingFeed
{
    NSLog(@"update following feed");
    NSMutableString *str = [NSMutableString stringWithFormat:@"http://foodieapp.herokuapp.com/images_following_pagination/cHQdfW429KXwp8FQNK7u/%@/%@", @"2neeraj", [[_data lastObject] objectForKey:@"dateadded"]];
    [str replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    NSLog(@"%@", str);
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             if ([info[0] count] < 1)
                 _tableView.showsInfiniteScrolling = NO;
             else
             {
                 _data = [_data arrayByAddingObjectsFromArray:info[0]];
                 NSMutableDictionary *profilePictures = [_profilePictures mutableCopy];
                 [profilePictures addEntriesFromDictionary:info[1]];
                 _profilePictures = [profilePictures copy];
                 [_tableView.infiniteScrollingView stopAnimating];
                 [self.tableView reloadData];
             }
         }
     }];
}

- (void)updateNearbyFeed
{
    NSLog(@"update nearby feed");
    _locationUpdateIsForNearbyRefresh = NO;
    NSString *str = [NSString stringWithFormat:@"http://foodieapp.herokuapp.com/images_nearby/cHQdfW429KXwp8FQNK7u/%f/%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
    NSLog(@"string: %@", str);
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
//             NSLog(@"info %@", info);
             if ([info count] > 1)
             {
                 _data = info[0];
                 _profilePictures = info[1];
                 [self.tableView reloadData];
                 [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
             }
             else
             {
                 // false
             }
         }
     }];
}

- (void)nextPageNearbyFeed
{
    NSLog(@"next page nearby feed");
    _locationUpdateIsForNearbyRefresh = NO;
    NSMutableString *str = [NSMutableString stringWithFormat:@"http://foodieapp.herokuapp.com/images_nearby_pagination/cHQdfW429KXwp8FQNK7u/%f/%f/%@", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude, [[_data lastObject] objectForKey:@"dateadded"]];
    [str replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    NSLog(@"string: %@", str);
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             NSLog(@"next page nearby feed updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             if ([info[0] count] < 1)
                 _tableView.showsInfiniteScrolling = NO;
             else
             {
                 _data = [_data arrayByAddingObjectsFromArray:info[0]];
                 NSMutableDictionary *profilePictures = [_profilePictures mutableCopy];
                 [profilePictures addEntriesFromDictionary:info[1]];
                 _profilePictures = [profilePictures copy];
                 [_tableView.infiniteScrollingView stopAnimating];
                 [self.tableView reloadData];
             }
         }
     }];
}

- (void)updateGlobalFeed
{
    NSLog(@"update global feed");
    NSString *str = @"http://foodieapp.herokuapp.com/images_global/cHQdfW429KXwp8FQNK7u";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
//             NSLog(@"info %@", info);
             _data = info[0];
             _profilePictures = info[1];
             [_tableView.pullToRefreshView stopAnimating];
             [self.tableView reloadData];
             [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
         }
     }];
}

- (void)nextPageGlobalFeed
{
    NSLog(@"next page global feed");
    NSMutableString *str = [NSMutableString stringWithFormat:@"http://foodieapp.herokuapp.com/images_global_pagination/cHQdfW429KXwp8FQNK7u/%@", [[_data lastObject] objectForKey:@"dateadded"]];
    [str replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"url: %@", [url description]);
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
//         NSLog(@"data: %lu", (unsigned long)[data length]);
//         NSLog(@"response: %@", [response description]);
//         NSLog(@"connection error: %@", [connectionError description]);
         if (data)
         {
             NSLog(@"next page global feed updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             if ([info[0] count] < 1)
                 _tableView.showsInfiniteScrolling = NO;
             else
             {
                 _data = [_data arrayByAddingObjectsFromArray:info[0]];
                 NSMutableDictionary *profilePictures = [_profilePictures mutableCopy];
                 [profilePictures addEntriesFromDictionary:info[1]];
                 _profilePictures = [profilePictures copy];
                 [_tableView.infiniteScrollingView stopAnimating];
                 [self.tableView reloadData];
             }
         }
     }];
}

- (void)setFeedSelection:(NSInteger)selectedIndex
{
    [_tableView.infiniteScrollingView stopAnimating];
    _tableView.showsInfiniteScrolling = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (selectedIndex == 0)
        [self updateFollowingFeed];
    else if (selectedIndex == 1)
    {
        if ([_currentLocation.timestamp timeIntervalSinceDate:[NSDate date]] > 3600)
        {
            _locationUpdateIsForNearbyRefresh = YES;
            [self getLocation];
        }
        else
            [self updateNearbyFeed];
    }
    else if (selectedIndex == 2)
        [self updateGlobalFeed];
}

# pragma mark - Liking

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleFavoriteForCellAtIndexPath:indexPath];
    NSLog(@"%@", [[_data objectAtIndex:indexPath.section] description]);
}

- (void)handleFavoriteForCellAtIndexPath:(NSIndexPath *)indexPath
{
    RNPFeedCell *cell = (RNPFeedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([self imageHasBeenFavoritedAtIndex:indexPath])
    {
        [self unlikeImageAtIndexPath:indexPath];
        [cell unlike];
    }
    else
    {
        [self likeImageAtIndexPath:indexPath];
        [cell like];
    }
}

- (BOOL)imageHasBeenFavoritedAtIndex:(NSIndexPath *)indexPath
{
    NSString *username = @"2neeraj"; // *dummy data
    
    NSArray *usernamesThatHaveFavorited = [[_data objectAtIndex:indexPath.section] objectForKey:@"likes"];
    return [usernamesThatHaveFavorited containsObject:username];
}

- (void)unlikeImageAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *username = @"2neeraj"; // *dummy data
    
    NSString *imageID = [[_data objectAtIndex:indexPath.section] objectForKey:@"id"];
    NSMutableArray *usernamesThatHaveFavorited = [[[_data objectAtIndex:indexPath.section] objectForKey:@"likes"] mutableCopy];
    [usernamesThatHaveFavorited removeObject:username];
    NSMutableArray *localData = [_data mutableCopy];
    NSMutableDictionary *localImageData = [[localData objectAtIndex:indexPath.section] mutableCopy];
    [localImageData setObject:[usernamesThatHaveFavorited copy] forKey:@"likes"];
    [localData setObject:[localImageData copy] atIndexedSubscript:indexPath.section];
    _data = [localData copy];
    
    NSString *str = [NSString stringWithFormat:@"http://foodieapp.herokuapp.com/unlike/cHQdfW429KXwp8FQNK7u/%@/%@", imageID, username];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:Nil];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//    [[self tableView:self.tableView viewForHeaderInSection:indexPath.section] setNeedsDisplay];
}

- (void)likeImageAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *username = @"2neeraj"; // *dummy data
    
    NSString *imageID = [[_data objectAtIndex:indexPath.section] objectForKey:@"id"];
    NSMutableArray *usernamesThatHaveFavorited = [[[_data objectAtIndex:indexPath.section] objectForKey:@"likes"] mutableCopy];
    [usernamesThatHaveFavorited addObject:username];
    NSMutableArray *localData = [_data mutableCopy];
    NSMutableDictionary *localImageData = [[localData objectAtIndex:indexPath.section] mutableCopy];
    [localImageData setObject:[usernamesThatHaveFavorited copy] forKey:@"likes"];
    [localData setObject:[localImageData copy] atIndexedSubscript:indexPath.section];
    _data = [localData copy];
    
    NSString *str = [NSString stringWithFormat:@"http://foodieapp.herokuapp.com/like/cHQdfW429KXwp8FQNK7u/%@/%@", imageID, username];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:Nil];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
//    RNPFeedHeader *headerView = [[[self tableView:self.tableView viewForHeaderInSection:indexPath.section] subviews] objectAtIndex:0];
//    int newLikes = [[[headerView likes] text] integerValue] + 1;
//    NSString *inStr = [NSString stringWithFormat: @"%d", newLikes];
//    [[headerView likes] setText:inStr];
//    [headerView setNeedsDisplay];
}

# pragma mark - Location

- (void)getLocation
{
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"has location");
    _currentLocation = [locations lastObject];
    [_locationManager stopUpdatingLocation];
    if (_locationUpdateIsForNearbyRefresh)
        [self updateNearbyFeed];
}

# pragma mark - Header tapping

- (void)touchedRestaurant:(NSString *)restaurantName withID:(NSString *)restaurantID
{
    RNPRestaurantFeedViewController *restaurantFeedVC = [[RNPRestaurantFeedViewController alloc] initWithRestaurant:restaurantName withID:restaurantID];
    restaurantFeedVC.title = restaurantName;
    [self.navigationController pushViewController:restaurantFeedVC animated:YES];
    NSLog(@"touched restaurant: %@ with ID: %@", restaurantName, restaurantID);
}

- (void)touchedUser:(NSString *)username
{
    NSLog(@"touched user: %@", username);
}

@end