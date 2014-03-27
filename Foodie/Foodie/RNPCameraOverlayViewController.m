//
//  RNPCameraOverlayViewController.m
//  Foodie
//
//  Created by Romi Phadte on 3/10/14.
//  Copyright (c) 2014 Romi Phadte. All rights reserved.
//

#import "RNPCameraOverlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RNPFilterViewController.h"
#import <FXBlurView/FXBlurView.h>


@interface RNPCameraOverlayViewController ()

@property AVCaptureSession *session;
@property AVCaptureVideoPreviewLayer *preview;
@property (weak, nonatomic) IBOutlet UIView *topBlur;
@property (weak, nonatomic) IBOutlet UIView *bottomBlur;


@property bool deviceAuthorized;

@end

@implementation RNPCameraOverlayViewController

@synthesize session;
@synthesize preview;
@synthesize topBlur;
@synthesize bottomBlur;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
  //  [self setupOverlay];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpCamera];
    [FXBlurView setBlurEnabled:YES];
    [FXBlurView setUpdatesEnabled];
    [self blurTints];

    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpCamera{
    
    [self loadView];
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
    preview.videoGravity=AVLayerVideoGravityResize;
  	CGRect layerRect = [[[self view] layer] bounds];//find out why doesn't work with preview layer
    
	[preview setBounds:layerRect];
	[preview setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                    CGRectGetMidY(layerRect))];
    [self.view.layer insertSublayer:preview atIndex:0];
    [self checkDeviceAuthorizationStatus];
    [self.session startRunning];
    
 
    
}
-(void) addInput{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            if ([self.session canAddInput:videoIn]){
                NSLog(@"added video Input");
                [self.session addInput:videoIn];
            }
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
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
}
- (IBAction)exit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismiss self");
    }];
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


-(void)setupOverlay{
    NSLog(@"overlay");
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_overlay.png"]];
    [overlayImageView setFrame:CGRectMake(30, 100, 260, 300)];
    [[self view] addSubview:overlayImageView];
//    overlay.image=[UIImage imageNamed:@"camera_overlay.png"];
 //   self.view addSub[[self overlay] layer]
}

-(void)blurTints{

    topBlur.backgroundColor = [UIColor clearColor];
    UIToolbar* tpToolbar = [[UIToolbar alloc] initWithFrame:topBlur.frame];
    tpToolbar.barStyle = UIBarStyleBlackTranslucent;
    [topBlur.superview insertSubview:tpToolbar belowSubview:topBlur];
    
    
    bottomBlur.backgroundColor = [UIColor clearColor];
    UIToolbar* bmToolbar = [[UIToolbar alloc] initWithFrame:bottomBlur.frame];
    bmToolbar.barStyle = UIBarStyleBlackTranslucent;
    [topBlur.superview insertSubview:bmToolbar belowSubview:topBlur];
    
}

- (IBAction)takePicture:(id)sender {
    
    AVCaptureConnection *videoConnection = nil;
    AVCaptureStillImageOutput *stillImageOutput;
    if([session.outputs count]>0){
        stillImageOutput=session.outputs[0];
    }
    
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    
    
    }];
}
     
     
- (void)processImage:(UIImage *)image {
    
    RNPFilterViewController *controller= [[RNPFilterViewController alloc]init];

    [controller saveImage:image];
    [self presentViewController:controller animated:YES completion:^{
        NSLog(@"filters");
    }];
    
}

@end
