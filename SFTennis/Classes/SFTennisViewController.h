//
//  SFTennisViewController.h
//  SFTennis
//
//  Created by Plato on 10/29/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

typedef struct {
    CGPoint ballPosition;
    CGPoint paddlePosition[2];
    CGPoint ballVelocity;
    int score[2];
} gameInfo;

typedef enum{
    kStateStartGame,
    kStatePicker,
    kStateMultiplayer,
    kStateMultiplayerCointoss,
    kStateMultiplayerReconnect,
    kStateGameOver
}gameStates;

typedef enum {
    NETWORK_COINTOSS,
    NETWORK_MOVE_EVENT,
    NETWORK_BALL_MOVE_EVENT,
    NETWORK_GAME_STATUS
} packetCodes;

typedef enum {
    kServer,
    kClient
} gameNetwork;

@interface SFTennisViewController : UIViewController <GKPeerPickerControllerDelegate,GKSessionDelegate>
{
    IBOutlet UIView * paddle1;
    IBOutlet UIView * paddle2;
    
    IBOutlet UIImageView * ball;
    IBOutlet UILabel * score1Label;
    IBOutlet UILabel * score2Label;
    IBOutlet UILabel * gameLabel;
    
    NSInteger gameState;
    NSInteger peerStatus;
    
    gameInfo gameStatus;
    BOOL justCollided;
    
    GKSession * gameSession;
    int gameUniqueID;
    int gamePacketNumber;
    NSString * gamePeerId;
}
@property(nonatomic,retain) IBOutlet UIView * paddle1;
@property(nonatomic,retain) IBOutlet UIView * paddle2;
@property(nonatomic,retain) IBOutlet UIImageView * ball;
@property(nonatomic,retain) IBOutlet UILabel * score1Label;
@property(nonatomic,retain) IBOutlet UILabel * score2Label;
@property(nonatomic,retain) IBOutlet UILabel * gameLabel;
@property(nonatomic) NSInteger gameState;
@property(nonatomic) NSInteger peerStatus;
@property(nonatomic,retain) GKSession * gameSession;
@property(nonatomic,copy) NSString * gamePeerId;

-(void) showPicker;

-(void) sendNetworkPacket:(GKSession *) session
                 packetID:(int) packetID
                 withData:(void *) data
                 ofLength:(int) length
                 reliable:(BOOL) howtosend;

-(void)resetBall;

@end
