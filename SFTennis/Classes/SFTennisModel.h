//
//  SFTennisModel.h
//  SFTennis
//
//  Created by Plato on 11/2/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "SFTennisViewController.h"

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

@class SFTennisViewController;

@interface SFTennisModel : NSObject <GKPeerPickerControllerDelegate,GKSessionDelegate>
{
    NSInteger gameState;
    NSInteger peerStatus;
    
    gameInfo gameStatus;
    BOOL justCollided;
    
    GKSession * gameSession;
    int gameUniqueID;
    int gamePacketNumber;
    NSString * gamePeerId;
}

-(id)initWithController:(SFTennisViewController *) controller;

-(void) sendNetworkPacket:(GKSession *) session
                 packetID:(int) packetID
                 withData:(void *) data
                 ofLength:(int) length
                 reliable:(BOOL) howtosend;

-(void)moveToPaddlePoint:(CGPoint) paddlePoint;

-(void)willShowPicker;

-(void)peerPickerDidCancel;

-(void)didShowPicker:(GKPeerPickerController *)picker
      didConnectPeer:(NSString *)peerID
           toSession:(GKSession *)session;

@property(nonatomic) NSInteger gameState;
@property(nonatomic) NSInteger peerStatus;
@property(nonatomic,retain) GKSession * gameSession;
@property(nonatomic,copy) NSString * gamePeerId;
@property(nonatomic,assign) SFTennisViewController * controller;

@end
