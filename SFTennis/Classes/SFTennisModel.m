//
//  SFTennisModel.m
//  SFTennis
//
//  Created by Plato on 11/2/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFTennisModel.h"

@implementation SFTennisModel
@synthesize gamePeerId = gamePeerId;
@synthesize gameState = gameState;
@synthesize gameSession = gameSession;
@synthesize peerStatus = peerStatus;
@synthesize controller = _controller;

- (id)initWithController:(SFTennisViewController *) controller
{
    self = [self init];
    if (self) {
        self.controller = controller;
        
        self.gameState = kStateStartGame;
        NSUUID * uid = [[UIDevice currentDevice] identifierForVendor];
        gameUniqueID = [uid hash];
        
        gameStatus.paddlePosition[0].x = gameStatus.paddlePosition[1].x = 320/2;
        
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)peerPickerDidCancel
{
    self.gameState = kStateStartGame;
}

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
            [_controller hideGameLabel];
        }
            break;
        case NETWORK_GAME_STATUS:
        {
            gameInfo * gs = (gameInfo *)&incommingPacket[8];
            memcpy(&gameStatus, gs, sizeof(gameInfo));
            [_controller
             didChangeServerScore:[NSString stringWithFormat:@"%d",gameStatus.score[kServer]]
             clientScore:[NSString stringWithFormat:@"%d",gameStatus.score[kClient]]];
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
    
    [_controller
     didChangeServerScore:[NSString stringWithFormat:@"%d",gameStatus.score[kServer]]
     clientScore:[NSString stringWithFormat:@"%d",gameStatus.score[kClient]]];
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
                if ([_controller shouldChangeVelocityX]) {
                    gameStatus.ballVelocity.x *= -1;
                    collision = YES;
                }
                if (collision) {
                    [self sendNetworkPacket:self.gameSession packetID:NETWORK_BALL_MOVE_EVENT withData:&gameStatus ofLength:sizeof(gameInfo) reliable:NO];
                }
                if ([_controller shouldChangeVelocityY] && !justCollided) {
                    gameStatus.ballVelocity.y *= -1;
                    collision = YES;
                    justCollided = YES;
                    [self performSelector:@selector(resetCollision) withObject:nil afterDelay:1.0];
                }

                [_controller movePaddle2ToPointX:gameStatus.paddlePosition[1 - self.peerStatus].x];
            }else{
                [_controller movePaddle1ToPointX:gameStatus.paddlePosition[1 - self.peerStatus].x];
            }
            
            gameStatus.ballPosition.x = gameStatus.ballPosition.x + gameStatus.ballVelocity.x;
            gameStatus.ballPosition.y = gameStatus.ballPosition.y + gameStatus.ballVelocity.y;
            
            _controller.ball.center = CGPointMake(gameStatus.ballPosition.x, gameStatus.ballPosition.y);
            if (gameStatus.score[kServer] >= 5) {
                [_controller showGameLabelWithText:@"Play 1 wins!"];
                self.gameState = kStateGameOver;
                [self sendNetworkPacket:self.gameSession packetID:NETWORK_GAME_STATUS withData:&gameStatus ofLength:sizeof(gameInfo) reliable:YES];
                return;
            }
            if (gameStatus.score[kClient] >= 5) {
                [_controller showGameLabelWithText: @"Play 2 wins!"];
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

-(void)moveToPaddlePoint:(CGPoint) paddlePoint
{
    switch (self.gameState) {
        case kStateStartGame:
        {
            [_controller showPicker];
        }
            break;
        case kStateMultiplayer:
        {            
            if (self.peerStatus == kServer) {
                [_controller movePaddle1ToPointX:paddlePoint.x];
               gameStatus.paddlePosition[self.peerStatus].x = paddlePoint.x;

            }else{
                [_controller movePaddle2ToPointX:paddlePoint.x];
                gameStatus.paddlePosition[self.peerStatus].x = paddlePoint.x;
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

-(void)willShowPicker
{
    self.gameState = kStatePicker;
}

-(void)didShowPicker:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.gamePeerId = peerID;
    self.gameSession = session;
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:NULL];
    self.gameState = kStateMultiplayerCointoss;
}
@end
