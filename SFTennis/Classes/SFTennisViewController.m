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
@synthesize gameSession = gameSession;
@synthesize paddle2 = paddle2;
@synthesize paddle1 = paddle1;
@synthesize peerStatus = peerStatus;
@synthesize ball = ball;
@synthesize score1Label = score1Label;
@synthesize score2Label = score2Label;
@synthesize gameLabel = gameLabel;
@synthesize gamePeerId = gamePeerId;
@synthesize gameState = gameState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showPicker
{
    self.gameState = kStatePicker;
    GKPeerPickerController * picker = [[GKPeerPickerController alloc]init];
    picker.delegate = self;
    [picker show];
}

#pragma -mark GKPeerPickerControllerDelegate
-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    [picker autorelease];
    
    self.gameState = kStateStartGame;
    self.gameLabel.hidden = NO;
}

-(GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    GKSession * session = [[GKSession alloc]initWithSessionID:@"GKTennis" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

-(void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.gamePeerId = peerID;
    self.gameSession = session;
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:NULL];
    [picker dismiss];
    picker.delegate = nil;
    [picker autorelease];
    self.gameState = kStateMultiplayerCointoss;
}

#pragma -mark send & recive
-(void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend
{
    static unsigned char networkPacket[1024];
    const unsigned int packetHeaderSize = 2 * sizeof(int);
    
    if (length < (1024 - packetHeaderSize)) {
        int * pIntData = (int *)&networkPacket[0];
        pIntData[0] = gamePacketNumber ++;
        pIntData[1] = packetID;
        
        memcpy(&networkPacket[packetHeaderSize], data, length);
        
        NSData * packet = [NSData dataWithBytes:networkPacket length:(length+8)];
        if (howtosend) {
            [session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
        }else{
            [session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
        }
    }
}

-(void)receiveData:(NSData *)data fromPeer:(NSString *) peer inSeesion:(GKSession *)session context:(void *) context{
    static int lastPacketTime = -1;
    unsigned char *incommingPacket = (unsigned char *)[data bytes];
    int * pIntData = (int *)&incommingPacket[0];
    
    int packetTime = pIntData[0];
    int packetID = pIntData[1];
    if (packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
        return;
    }
    
    lastPacketTime = packetTime;
    switch (packetID) {
        case NETWORK_COINTOSS:
        {
            int coinToss = pIntData[2];
            if (coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            }
            self.gameLabel.hidden = YES;
        }
            break;
        case NETWORK_GAME_STATUS:
        {
            gameInfo * gs = (gameInfo *)&incommingPacket[8];
            memcpy(&gameStatus, gs, sizeof(gameInfo));
            score1Label.text = [NSString stringWithFormat:@"%d",gameStatus.score[kServer]];
            score2Label.text = [NSString stringWithFormat:@"%d",gameStatus.score[kClient]];
        }
            break;
        case NETWORK_MOVE_EVENT:
        {
            gameInfo * gi = (gameInfo *)&incommingPacket[8];
            gameStatus.paddlePosition[1-self.peerStatus].x = gi ->paddlePosition[1-self.peerStatus].x;
        }
            break;
        case NETWORK_BALL_MOVE_EVENT:
        {
            gameInfo * gi =(gameInfo *)&incommingPacket[8];
            gameStatus.ballPosition.x = gi -> ballPosition.x;
            gameStatus.ballPosition.y = gi -> ballPosition.y;
            gameStatus.ballVelocity.x = gi -> ballVelocity.x;
            gameStatus.ballVelocity.y = gi -> ballVelocity.y;
            break;
        }
        default:
            break;
    }
}

-(void)resetBall
{
    gameStatus.ballPosition.x = 320/2;
    gameStatus.ballPosition.y = 480/2;
    
    float isNegative = random() %2;
    int direction = (isNegative < 1) ? -1 : 1;
    gameStatus.ballVelocity.x = 4 * direction;
    gameStatus.ballVelocity.y = 4 * direction;
    score1Label.text = [NSString stringWithFormat:@"%d",gameStatus.score[kServer]];
    score2Label.text = [NSString stringWithFormat:@"%d",gameStatus.score[kClient]];
    if (gameSession) {
        [self sendNetworkPacket:gameSession packetID:NETWORK_GAME_STATUS withData:&gameStatus ofLength:sizeof(gameInfo) reliable:YES];
    }
}

-(void)gameLoop
{
    switch (self.gameState) {
        case kStatePicker:
        case kStateStartGame:
            break;
        case kStateMultiplayerCointoss:
        {
            [self sendNetworkPacket:self.gameSession packetID:NETWORK_COINTOSS withData:&gameUniqueID ofLength:sizeof(int) reliable:YES];
            self.gameState = kStateMultiplayer;
        }
            break;
        case kStateMultiplayer:
        {
            BOOL collision = NO;
            if (self.peerStatus == kServer) {
                CGPoint bottomRight = CGPointMake(ball.frame.origin.x, ball.frame.origin.y + ball.frame.size.height);
                if (gameStatus.ballPosition.y <= 0) {
                    gameStatus.score[kClient] ++;
                    [self resetBall];
                    return;
                }
                if (gameStatus.ballPosition.y >= 480) {
                    gameStatus.score[kServer]++;
                    [self resetBall];
                    return;
                }
                if (ball.frame.origin.x <= 0 || bottomRight.x >= 320) {
                    gameStatus.ballVelocity.x *= -1;
                    collision = YES;
                }
                if (collision) {
                    [self sendNetworkPacket:self.gameSession packetID:NETWORK_BALL_MOVE_EVENT withData:&gameStatus ofLength:sizeof(gameInfo) reliable:NO];
                }
                if ((CGRectIntersectsRect(ball.frame, paddle1.frame) ||
                     CGRectIntersectsRect(ball.frame, paddle2.frame)) &&
                    !justCollided) {
                    gameStatus.ballVelocity.y *= -1;
                    collision = YES;
                    justCollided = YES;
                    [self performSelector:@selector(resetCollision) withObject:nil afterDelay:1.0];
                }
                paddle2.center = CGPointMake(gameStatus.paddlePosition[1 - self.peerStatus].x, paddle2.center.y);
            }else{
                paddle1.center = CGPointMake(gameStatus.paddlePosition[1 - self.peerStatus].x, paddle1.center.y);
            }
            gameStatus.ballPosition.y = gameStatus.ballPosition.y + gameStatus.ballVelocity.y;
            gameStatus.ballPosition.x = gameStatus.ballPosition.x + gameStatus.ballVelocity.x;
            
            ball.center = CGPointMake(gameStatus.ballPosition.x, gameStatus.ballPosition.y);
            if (gameStatus.score[kServer] >= 5) {
                self.gameLabel.text = @"Play 1 wins!";
                self.gameLabel.hidden = NO;
                self.gameState = kStateGameOver;
                [self sendNetworkPacket:self.gameSession packetID:NETWORK_GAME_STATUS withData:&gameStatus ofLength:sizeof(gameInfo) reliable:YES];
                return;
            }
            if (gameStatus.score[kClient] >=5) {
                self.gameLabel.text = @"Play 2 wins!";
                self.gameLabel.hidden = NO;
                self.gameState = kStateGameOver;
                [self sendNetworkPacket:self.gameSession packetID:NETWORK_GAME_STATUS withData:&gameStatus ofLength:sizeof(gameInfo) reliable:YES];
                return;
            }
            
        }
            break;
        default:
            break;
    }
}

#pragma -mark touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (self.gameState) {
        case kStateStartGame:
        {
            self.gameLabel.hidden = YES;
            [self showPicker];
        }
            break;
        case kStateMultiplayer:
        {
            UITouch * t = [[event allTouches] anyObject];
            CGPoint paddlePoint = [t locationInView:self.view];
            if (self.peerStatus == kServer) {
                paddle1.center = CGPointMake(paddlePoint.x, paddle1.center.y);
                gameStatus.paddlePosition[self.peerStatus].x = paddle1.center.x;
            }else{
                paddle2.center = CGPointMake(paddlePoint.x, paddle2.center.y);
                gameStatus.paddlePosition[self.peerStatus].x = paddle2.center.x;
            }
            [self sendNetworkPacket:gameSession packetID:NETWORK_MOVE_EVENT withData:&gameStatus ofLength:sizeof(gameStatus) reliable:NO];
        }
            break;
        case kStateGameOver:
            exit(0);
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameState = kStateStartGame;
    NSUUID * uid = [[UIDevice currentDevice] identifierForVendor];
    gameUniqueID = [uid hash];
    
    [self resetBall];
    
    gameStatus.paddlePosition[0].x = gameStatus.paddlePosition[1].x = 320/2;
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
