//
//  RNPFilterViewController.m
//  Foodie
//
//  Created by Romi Phadte on 3/11/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPFilterViewController.h"
#import <FXBlurView/FXBlurView.h>
#import "RNPImageInfoViewController.h"

@interface RNPFilterViewController ()

@property UIImage *savedImage;
@property (weak, nonatomic) IBOutlet FXBlurView *topBlurBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBlurBar;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RNPFilterViewController

@synthesize savedImage;
@synthesize topBlurBar;
@synthesize bottomBlurBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)saveImage:(UIImage *)image{
    self.savedImage=image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [FXBlurView setUpdatesEnabled];
    [FXBlurView setBlurEnabled:YES];
    [self.imageView setImage:savedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exit:(id)sender {
#ifdef UPLOADER
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismiss self");
    }];
#else
   [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismiss self");
    }];
#endif
    
}
- (IBAction)editView:(id)sender {
    RNPImageInfoViewController *vc=[[RNPImageInfoViewController alloc] init];
    [vc saveImage:self.imageView.image];
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"info");
    }];

}

@end
