//
//  SFViewController.m
//  Three20Lab
//
//  Created by Plato on 10/26/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFViewController.h"
#import "AccelerometerFilter.h"
#import "SFShakeIndicator.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

static const float kFilteringFactor = 0.1;

@interface SFViewController ()
{
    float _gravX;
    float _gravY;
    
    AccelerometerFilter * _lowpassFilter;
    SFShakeIndicator * _shakeIndicator;
    AVAudioPlayer * _player;
    //    AccelerometerFilter * _highpassFilter;
}

@end

@implementation SFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _gravX = 0;
        _gravY = 0;
        //        _highpassFilter = [[HighpassFilter alloc]initWithSampleRate:60.0 cutoffFrequency:5.0];
        _lowpassFilter = [[LowpassFilter alloc] initWithSampleRate:60.0 cutoffFrequency:5.0];
        _shakeIndicator = [[SFShakeIndicator alloc]init];
        _shakeIndicator.shouldShakeCount = 3;
        
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"m4a"]];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    return self;
}

-(void)viewDidUnload
{
    TT_RELEASE_SAFELY(_lowpassFilter);
    TT_RELEASE_SAFELY(_shakeIndicator);
    TT_RELEASE_SAFELY(_player);
    //    TT_RELEASE_SAFELY(_highpassFilter);
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:53/255.0f alpha:1];
    UIAccelerometer * accel = [UIAccelerometer sharedAccelerometer];
    accel.updateInterval = .1;
    accel.delegate = self;
    
    NSString * imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"moon.png"];
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
    //    (@"bundle://moon.png")];
    imageView.frame = CGRectMake(100, 200, 50, 50);
    imageView.tag = 9;
    [self.view addSubview:imageView];
	// Do any additional setup after loading the view.
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [_lowpassFilter addAcceleration:acceleration];
    //    [_highpassFilter addAcceleration:acceleration];
    
    //shake
    [_shakeIndicator addAcceleration:acceleration];
    if ([_shakeIndicator isShake]) {
        self.view.backgroundColor = [self nextColor];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_player play];
    }
    
    
    //moon move
    UIView * view = [self.view viewWithTag:9];
    CGPoint curCenter = [view center];
    
    float newX = 45 * _lowpassFilter.x + curCenter.x;
    float newY = -45 * _lowpassFilter.y + curCenter.y;
    
    if (newX<25) {
        newX = 25;
    }
    if (newY < 25) {
        newY = 25;
    }
    if (newX >295) {
        newX = 295;
    }
    if (newY >455) {
        newY = 455;
    }
    
    [UIView beginAnimations:nil context:nil];
    
    view.center = CGPointMake(newX, newY);
    [UIView commitAnimations];
}

-(UIColor *)nextColor
{
    return [UIColor colorWithRed:(random()%255)/255.0f
                           green:(random()%255)/255.0f
                            blue:(random()%255)/255.0f
                           alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
