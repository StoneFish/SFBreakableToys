//
//  SFTennisViewController.m
//  SFTennis
//
//  Created by Plato on 10/29/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFTennisViewController.h"

@interface SFTennisViewController ()

@end

@implementation SFTennisViewController
@synthesize paddle2 = paddle2;
@synthesize paddle1 = paddle1;
@synthesize ball = ball;
@synthesize score1Label = score1Label;
@synthesize score2Label = score2Label;
@synthesize gameLabel = gameLabel;

- (void)dealloc
{
    [_model release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)modelDidChange
{
    
}

-(void)showPicker
{
    [_model willShowPicker];
    self.gameLabel.hidden = YES;
    GKPeerPickerController * picker = [[GKPeerPickerController alloc]init];
    picker.delegate = self;
    [picker show];
}

#pragma -mark GKPeerPickerControllerDelegate
-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    [_model peerPickerDidCancel];
    picker.delegate = nil;
    [picker autorelease];
    [self hideGameLabel];
}

-(void)hideGameLabel
{
    self.gameLabel.hidden = YES;
}

-(void)showGameLabelWithText:(NSString *)text
{
    self.gameLabel.text = text;
    self.gameLabel.hidden = NO;
}

-(GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    GKSession * session = [[GKSession alloc]initWithSessionID:@"GKTennis" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    [_model didShowPicker:picker didConnectPeer:peerID toSession:session];
    [picker dismiss];
    picker.delegate = nil;
    [picker autorelease];
}

#pragma -mark touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * t = [[event allTouches] anyObject];
    CGPoint paddlePoint = [t locationInView:self.view];
    [_model moveToPaddlePoint:paddlePoint];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [[SFTennisModel alloc]init];
}

-(void)didChangeServerScore:(NSString *) serverScore clientScore:(NSString *) clientScore
{
    self.score1Label.text = serverScore;
    self.score2Label.text = clientScore;
}

-(void)movePaddle1ToPointX:(CGFloat) paddlePointX
{
    self.paddle1.center = CGPointMake(paddlePointX, self.paddle1.center.y);
}

-(void)movePaddle2ToPointX:(CGFloat) paddlePointX
{
    self.paddle2.center = CGPointMake(paddlePointX, self.paddle2.center.y);
}

-(BOOL)shouldChangeVelocityX
{
    CGRect ballFrame = self.ball.frame;
    CGPoint bottomRight = CGPointMake(ballFrame.origin.x, ballFrame.origin.y +ballFrame.size.height);
    return (ballFrame.origin.x <= 0 || bottomRight.x >= 320);
}

-(BOOL)shouldChangeVelocityY
{
    CGRect ballFrame = self.ball.frame;
   return (CGRectIntersectsRect(ballFrame, self.paddle1.frame) ||
     CGRectIntersectsRect(ballFrame, self.paddle2.frame));
}
@end
