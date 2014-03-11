//
//  RNPCameraOverlayViewController.m
//  Foodie
//
//  Created by Romi Phadte on 3/10/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPCameraOverlayViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface RNPCameraOverlayViewController ()

@property AVCaptureSession *session;
@property AVCaptureVideoPreviewLayer *preview;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property bool deviceAuthorized;

@end

@implementation RNPCameraOverlayViewController

@synthesize session;
@synthesize preview;
@synthesize previewView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    [self setUpCamera];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpCamera{
    
    
    [self setSession:[[AVCaptureSession alloc]init]];
    [self addInput];
    [self addOutput];

    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    else {
        session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    [self setPreview:[AVCaptureVideoPreviewLayer layerWithSession:session]];
    
    preview.frame = previewView.bounds; // Assume you want the preview layer to fill the view.
    preview.videoGravity=AVLayerVideoGravityResize;
    
    [previewView.layer addSublayer:preview];
    
    [self checkDeviceAuthorizationStatus];
        [self.session startRunning];
    
}
-(void) addInput{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            if ([self.session canAddInput:videoIn])
                [self.session addInput:videoIn];
            else
                NSLog(@"Couldn't add video input");
        }
        else
            NSLog(@"Couldn't create video input");
    }
    else{
        NSLog(@"Couldn't create video capture device");
    }
}

-(void) addOutput{
    
    
}


- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Foodie!"
											message:@"Foodie doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

@end
