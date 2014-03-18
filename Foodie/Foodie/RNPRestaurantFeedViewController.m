//
//  RNPRestaurantFeedViewController.m
//  
//
//  Created by Neeraj Baid on 3/16/14.
//
//

#import "RNPRestaurantFeedViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <FontAwesome+iOS/NSString+FontAwesome.h>


@interface RNPRestaurantFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet FXBlurView *infoBlurView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *menuLabel;

@property (strong, nonatomic) NSDictionary *restaurantData;

@end

@implementation RNPRestaurantFeedViewController

- (id)initWithRestaurant:(NSString *)restaurantName withID:(NSString *)restaurantID
{
    self = [super init];
    if (self)
    {
        _restaurantName = restaurantName;
        _restaurantID = restaurantID;
        
    }
    return self;
}

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
    [self updateFeed];
    _infoBlurView.tintColor = [UIColor blackColor];
    _infoBlurView.updateInterval = 0;
    _infoBlurView.blurRadius = 40;
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touches began restaurant");
    CGPoint touch = [[touches anyObject] locationInView:self.infoBlurView];
//    NSLog(@"touch: (%f, %f)", touch.x, touch.y);
//    NSLog(@"distance label: %f, %f, %f, %f", _distanceLabel.frame.origin.x, _distanceLabel.frame.origin.y, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height);
    if (CGRectContainsPoint(_distanceLabel.frame, touch))
        NSLog(@"touched distance");
    else if (CGRectContainsPoint(_menuLabel.frame, touch))
        NSLog(@"touched menu");
}

# pragma mark - Refreshing

- (void)update:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
    [_tableView.infiniteScrollingView stopAnimating];
    _tableView.showsInfiniteScrolling = YES;
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self updateFeed];
}

- (void)updateFeed
{
    NSLog(@"update following feed");
    NSString *str = [NSString stringWithFormat:@"http://foodieapp.herokuapp.com/restaurant_feed/cHQdfW429KXwp8FQNK7u/%@", _restaurantID];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             if ([info count] > 1)
             {
                 self.data = info[0];
                 self.profilePictures = info[1];
                 [self.tableView reloadData];
                 [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
             }
             else
             {
                 // false
             }
             [self updateRestaurantInfo];
         }
     }];
}

- (void)getNextPage
{
    NSLog(@"update following feed");
    NSMutableString *str = [NSMutableString stringWithFormat:@"http://foodieapp.herokuapp.com/restaurant_feed_pagination/cHQdfW429KXwp8FQNK7u/%@/%@", _restaurantID, [[self.data lastObject] objectForKey:@"dateadded"]];
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
                 self.data = [self.data arrayByAddingObjectsFromArray:info[0]];
                 NSMutableDictionary *profilePictures = [self.profilePictures mutableCopy];
                 [profilePictures addEntriesFromDictionary:info[1]];
                 self.profilePictures = [profilePictures copy];
                 [_tableView.infiniteScrollingView stopAnimating];
                 [self.tableView reloadData];
             }
         }
     }];
}

- (void)updateRestaurantInfo
{
    NSString *str = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@?client_id=YTZ50PEQ125QT5Q1QE0J20EQVQTASSQT4IGZWLQUPR120D1W&v=20140124&client_secret=PAFV4UYU3OWSMQEC25H1KWAC3JZ3F1WJ4A4RGH4IXWYDRAMB", _restaurantID];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             _restaurantData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
             _restaurantData = [[_restaurantData objectForKey:@"response"] objectForKey:@"venue"];
             
             double rating = [[_restaurantData objectForKey:@"rating"] doubleValue];
             NSString *userString = [NSString stringWithFormat:@"%@ %.1f", [NSString fontAwesomeIconStringForEnum:FAIconStar], rating];
             _ratingLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15];
             _ratingLabel.text = userString;
             [_ratingLabel sizeToFit];
             _ratingLabel.layer.cornerRadius = 12;
             if (rating == 0)
             {
                 _ratingLabel.frame = CGRectMake(0, _ratingLabel.frame.origin.y, 0, _ratingLabel.frame.size.height);
                 _ratingLabel.text = @"";
             }
             else if (rating < 7)
                 _ratingLabel.backgroundColor = [UIColor colorWithRed:185/255.0 green:185/255.0 blue:185/255.0 alpha:1];
             else
                 _ratingLabel.backgroundColor = [UIColor colorWithRed:105/255.0 green:191/255.0 blue:19/255.0 alpha:1];
             _ratingLabel.frame = CGRectMake(_ratingLabel.frame.origin.x, _ratingLabel.frame.origin.y, _ratingLabel.frame.size.width+14, _ratingLabel.frame.size.height+8);
             
             CLLocationDegrees latitude = [_restaurantData[@"location"][@"lat"] doubleValue];
             CLLocationDegrees longitude = [_restaurantData[@"location"][@"lng"] doubleValue];
             double distance = [self.currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]] * 0.000621371;
             NSString *distanceString = [NSString stringWithFormat:@"%@ %.1f mi", [NSString fontAwesomeIconStringForEnum:FAIconLocationArrow], distance];
             _distanceLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15];
             _distanceLabel.text = distanceString;
             [_distanceLabel sizeToFit];
             _distanceLabel.layer.cornerRadius = 12;
             _distanceLabel.frame = CGRectMake(_ratingLabel.frame.origin.x + _ratingLabel.frame.size.width + 6, _ratingLabel.frame.origin.y, _distanceLabel.frame.size.width+14, _ratingLabel.frame.size.height);
             _distanceLabel.backgroundColor = [UIColor colorWithRed:225/255.0 green:193/255.0 blue:0/255.0 alpha:1];
             
             if ([_restaurantData objectForKey:@"menu"] != NULL)
             {
                 NSString *menuString = [NSString stringWithFormat:@"%@ Menu", [NSString fontAwesomeIconStringForEnum:FAIconFood]];
                 _menuLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15];
                 _menuLabel.text = menuString;
                 [_menuLabel sizeToFit];
                 _menuLabel.layer.cornerRadius = 12;
                 _menuLabel.frame = CGRectMake(_distanceLabel.frame.origin.x + _distanceLabel.frame.size.width + 6, _ratingLabel.frame.origin.y, _menuLabel.frame.size.width+14, _ratingLabel.frame.size.height);
                 _menuLabel.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
             }
             else
                 CGRectMake(_distanceLabel.frame.origin.x + _distanceLabel.frame.size.width + 6, _ratingLabel.frame.origin.y, 0, _ratingLabel.frame.size.height);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             [self animateLabels];
         }
     }];
}

- (void)animateLabels
{
    float duration = .4;
    _ratingLabel.alpha = 0;
    _distanceLabel.alpha = 0;
    _menuLabel.alpha = 0;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^(void)
     { _ratingLabel.alpha = 1; } completion:nil];
    [UIView animateWithDuration:duration delay:.15 options:UIViewAnimationOptionCurveLinear animations:^(void)
     { _distanceLabel.alpha = 1; } completion:nil];
    [UIView animateWithDuration:duration delay:.3 options:UIViewAnimationOptionCurveLinear animations:^(void)
     { _menuLabel.alpha = 1; } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
