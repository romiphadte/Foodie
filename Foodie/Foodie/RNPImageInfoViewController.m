//
//  RNPImageInfoViewController.m
//  Foodie
//
//  Created by Romi Phadte on 3/25/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPImageInfoViewController.h"
#import <AmazonS3Client.h>
#import <S3/S3TransferManager.h>

@interface RNPImageInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage* savedImage;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) S3TransferManager *tm;

@end



@implementation RNPImageInfoViewController

BOOL isUp=false;

@synthesize savedImage;
@synthesize name;
@synthesize tm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.imageView setImage:savedImage];
    // Do any additional setup after loading the view from its nib.
}


-(void)saveImage: (UIImage *) image{
    savedImage=image;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textViewDidBeginEditing:(UITextView*) textView{
    [self animateTextField: textView up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}

- (void)textViewDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}
- (IBAction)tapped:(id)sender {
    [self.view endEditing:YES];
}
- (IBAction)swiped:(id)sender {
    [self.view endEditing:YES];
}

- (void) animateTextField: (UIView*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up&&!isUp ? -movementDistance : movementDistance);
    isUp=up;
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
- (IBAction)done:(id)sender {
    
    [self upload];

    [self dismissViewControllerAnimated:NO completion:^{
    }];
    
    
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    UIColor *colour = [UIColor lightGrayColor];
    
    if ([name.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)]) {
    
    // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: name.font};
        CGRect boundingRect = [name.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [name.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes];
    }
else {
    [colour setFill];
    [name.placeholder drawInRect:rect withFont:name.font lineBreakMode:NSLineBreakByTruncatingTail alignment:name.textAlignment];
    }
}

-(void)upload{
    
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJSZ7S32Z6MXOG4RA"
        withSecretKey:@"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"];
    
    self.tm = [S3TransferManager new];
    self.tm.s3 = s3;
    [self.tm uploadData:(UIImagePNGRepresentation(self.savedImage)) bucket:@"rnpfoodie" key:@"yo"];
    
    
}


@end
