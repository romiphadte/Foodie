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


@interface RNPRestaurantFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MBProgressHUD *HUD;

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
    // Do any additional setup after loading the view from its nib.
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
             [MBProgressHUD hideHUDForView:self.view animated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
