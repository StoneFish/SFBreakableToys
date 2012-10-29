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
    CGPoint paddlePosition;
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
    
}

@end
