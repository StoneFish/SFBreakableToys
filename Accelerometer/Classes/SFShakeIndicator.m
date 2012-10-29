//
//  SFShakeIndicator.m
//  Three20Lab
//
//  Created by Plato on 10/26/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFShakeIndicator.h"
#import "AccelerometerFilter.h"

static const int kSFShouldShakeCount = 3;

@interface SFShakeIndicator ()
{
    AccelerometerFilter * _filter;
    NSTimeInterval _lastTime;
    double _lastX;
    double _lastY;
    
    double _bigestShake;
    double _shakeCount;
}

@end

@implementation SFShakeIndicator

@synthesize isShake = _isShake;
@synthesize shouldShakeCount = _shouldShakeCount;

- (void)dealloc
{
    TT_RELEASE_SAFELY(_filter);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _filter = [[HighpassFilter alloc]initWithSampleRate:60.0 cutoffFrequency:5.0];
        _shouldShakeCount = kSFShouldShakeCount;
    }
    return self;
}

-(void)addAcceleration:(UIAcceleration *)accel
{
    [_filter addAcceleration:accel];
    if (_lastTime && accel.timestamp > _lastTime + .25) {
        if (_shakeCount >= kSFShouldShakeCount && _bigestShake >= 1.25) {
            _isShake = YES;
        } else {
            _isShake = NO;
        }
        _lastTime = 0;
        _shakeCount = 0;
        _bigestShake = 0;
    } else {
        if (fabs(_filter.x) >= fabs(_filter.y)) {
            if ((fabs(_filter.x) > .75) && (_filter.x * _lastX <= 0)) {
                _lastTime = accel.timestamp;
                _shakeCount++;
                _lastX = _filter.x;
                if (fabs(_filter.x) > _bigestShake) _bigestShake = fabs(_filter.x);
            }
        }else{
            if ((fabs(_filter.x) > .75) && (_filter.x * _lastX <= 0)) {
                _lastTime = accel.timestamp;
                _shakeCount++;
                _lastX = _filter.x;
                
                if ((fabs(_filter.y) > .75) && (_filter.y * _lastY <= 0)) {
                    _lastTime = accel.timestamp;
                    _shakeCount++;
                    _lastY = _filter.y;
                    if (fabs(_filter.y) > _bigestShake) _bigestShake = fabs(_filter.y); }
            }
        }
        _isShake = NO;
    }
}

@end
