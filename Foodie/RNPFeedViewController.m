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
#import <OHAttributedLabel/OHASBasicMarkupParser.h>

@interface RNPFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"image_cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RNPBreakCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"break_cell"];
    [self.navigationBar setBarTintColor:[UIColor blackColor]];
    
    [FXBlurView setUpdatesEnabled];
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
    return 5;
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
        cell.imageView.image = [UIImage imageNamed:@"test.png"];
        
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
    return 375;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RNPFeedHeader *headerView = [[NSBundle mainBundle] loadNibNamed:@"RNPFeedHeader" owner:self options:Nil][0];
    UIView *view = [[UIView alloc] initWithFrame:[headerView frame]];
    
    headerView.blurView.tintColor = [UIColor blackColor];
    headerView.blurView.updateInterval = 0;
    headerView.blurView.underlyingView = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]].imageView;
    headerView.blurView.blurRadius = 40;
    
    headerView.profilePicture.image = [UIImage imageNamed:@"profile.jpg"];
    
    headerView.profilePicture.layer.cornerRadius = 19;
    headerView.profilePicture.layer.masksToBounds = YES;
    
    headerView.profilePicture.layer.shadowOffset = CGSizeMake(0, 1);
    headerView.profilePicture.layer.shadowRadius = 2;
    headerView.profilePicture.layer.shadowColor = ([UIColor blackColor]).CGColor;
    headerView.profilePicture.layer.shadowOpacity = .7;
    
    headerView.profilePicture.layer.borderColor = [UIColor blackColor].CGColor;
    headerView.profilePicture.layer.borderWidth = 1;
    
    NSMutableAttributedString* basicMarkupString = [OHASBasicMarkupParser attributedStringByProcessingMarkupInAttributedString:headerView.label.attributedText];
//    [basicMarkupString modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle)
//    {
//        paragraphStyle.firstLineHeadIndent = 20.f;
//    }];
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
@end
