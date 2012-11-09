//
//  SFTennisViewController.h
//  SFTennis
//
//  Created by Plato on 10/29/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SFTennisModel.h"

@class SFTennisModel;

@interface SFTennisViewController : UIViewController <GKPeerPickerControllerDelegate,GKSessionDelegate>
{
    IBOutlet UIView * paddle1;
    IBOutlet UIView * paddle2;
    
    IBOutlet UIImageView * ball;
    IBOutlet UILabel * score1Label;
    IBOutlet UILabel * score2Label;
    IBOutlet UILabel * gameLabel;
        
    SFTennisModel * _model;
}
@property(nonatomic,retain) IBOutlet UIView * paddle1;
@property(nonatomic,retain) IBOutlet UIView * paddle2;
@property(nonatomic,retain) IBOutlet UIImageView * ball;
@property(nonatomic,retain) IBOutlet UILabel * score1Label;
@property(nonatomic,retain) IBOutlet UILabel * score2Label;
@property(nonatomic,retain) IBOutlet UILabel * gameLabel;

-(void)showPicker;

-(void)didChangeServerScore:(NSString *) serverScore clientScore:(NSString *) clientScore;

-(void)hideGameLabel;

-(void)showGameLabelWithText:(NSString *) text;
-(void)movePaddle1ToPointX:(CGFloat) paddlePointX;
-(void)movePaddle2ToPointX:(CGFloat) paddlePointX;

-(BOOL)shouldChangeVelocityX;

-(BOOL)shouldChangeVelocityY;

-(void)modelDidChange;

@end
