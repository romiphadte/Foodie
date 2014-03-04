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
#import "UIImageView+WebCache.h"
#import <OHAttributedLabel/OHASBasicMarkupParser.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface RNPFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) MBProgressHUD *HUD;

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSDictionary *profilePictures;

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"image_cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPBreakCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"break_cell"];
    [self.navigationBar setBarTintColor:[UIColor blackColor]];
    
    [self updateGlobalFeed];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%lu", (unsigned long)[_data count]);
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
        
        int num_iterations = 2;
        int blur_radius = 30;
        int update_interval = .1;
        
        [FXBlurView setUpdatesEnabled];
        [FXBlurView setBlurEnabled:YES];
        
        [cell.blurView setTintColor:[UIColor blackColor]];
        cell.blurView.iterations = num_iterations;
        cell.blurView.blurRadius = blur_radius;
        cell.blurView.updateInterval = update_interval;
        
        // configure image
        // configure label
        c = cell;
    }
    else
    {
        RNPBreakCell *cell = (RNPBreakCell *)[self.tableView dequeueReusableCellWithIdentifier:@"break_cell"];
        c = cell;
    }
    return c;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 367;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RNPFeedHeader *headerView = [[NSBundle mainBundle] loadNibNamed:@"RNPFeedHeader" owner:self options:Nil][0];
    UIView *view = [[UIView alloc] initWithFrame:[headerView frame]];
    
    NSDictionary *data = [_data objectAtIndex:section];
    
    headerView.username.text = [data objectForKey:@"username"];
    
    headerView.blurView.tintColor = [UIColor blackColor];
    headerView.blurView.updateInterval = 0;
    headerView.blurView.underlyingView = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].imageView;
    headerView.blurView.blurRadius = 40;
    
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
    
    headerView.label.text = [NSString stringWithFormat:@"*%@* at *%@*", [data objectForKey:@"dish"], [data objectForKey:@"restaurantname"]];
    
    headerView.likes.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[data objectForKey:@"likes"] count]];
    
    NSMutableAttributedString* basicMarkupString = [OHASBasicMarkupParser attributedStringByProcessingMarkupInAttributedString:headerView.label.attributedText];
    headerView.label.attributedText = basicMarkupString;
    
    [view addSubview:headerView];
    return view;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    RNPFeedFooter *footerView = [[NSBundle mainBundle] loadNibNamed:@"RNPFeedFooter" owner:self options:Nil][0];
//    UIView *view = [[UIView alloc] initWithFrame:[footerView frame]];
//    
//    footerView.blurView.tintColor = [UIColor blackColor];
//    footerView.blurView.updateInterval = 0;
//    footerView.blurView.underlyingView = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].imageView;
//    footerView.blurView.blurRadius = 175;
//    
//    [view addSubview:footerView];
//    return view;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 43;
//}

#pragma mark - Updating

- (void)updateGlobalFeed
{
    NSLog(@"update global feed");
    if (!_data)
        _data = [NSArray array];
    NSString *str = @"http://foodieapp.herokuapp.com/images/cHQdfW429KXwp8FQNK7u";
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (data)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"updated data");
             NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:Nil];
             NSLog(@"info %@", info);
             _data = info[0];
             _profilePictures = info[1];
             [self.tableView reloadData];
         }
     }];
}

@end
