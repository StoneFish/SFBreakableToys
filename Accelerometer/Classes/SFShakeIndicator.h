//
//  SFShakeIndicator.h
//  Three20Lab
//
//  Created by Plato on 10/26/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFShakeIndicator : NSObject

@property(nonatomic,readonly) BOOL isShake;

//需要摇的次数
@property(nonatomic) NSInteger shouldShakeCount;

-(void)addAcceleration:(UIAcceleration*)accel;

@end
