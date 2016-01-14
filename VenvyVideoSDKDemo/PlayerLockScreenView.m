//
//  PlayerLockScreenView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "PlayerLockScreenView.h"

@interface PlayerLockScreenView() {
    BOOL isShowing;
    BOOL isShowed;
}

@end

@implementation PlayerLockScreenView
@synthesize leftLockView,rightLockView;

+ (PlayerLockScreenView *)instancePlayerLockScreenView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"PlayerLockScreenView" owner:nil options:nil];
    PlayerLockScreenView *playerLockScreenView = [nibViews objectAtIndex:0];
    return playerLockScreenView;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    self.layer.masksToBounds = YES;
    [leftLockView.layer setCornerRadius:leftLockView.frame.size.width / 2];
    leftLockView.layer.masksToBounds = YES;
    [rightLockView.layer setCornerRadius:rightLockView.frame.size.width / 2];
    rightLockView.layer.masksToBounds = YES;
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if([view isEqual:leftLockView] || [view isEqual:rightLockView]) {
        [self setScreenUnLock];
        return;
    }
    
    if(isShowing) {
        return;
    }
    isShowing = YES;
    if(!isShowed) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideView) object:nil];
        [self showView];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideView) object:nil];
        [self hideView];
    }
    
    
}

- (void) setScreenLock {
    [self setHidden:NO];
}

- (void) setScreenUnLock {
    [self setHidden:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideView) object:nil];
    [self hideView];
}

- (void) showView {
    [UIView animateWithDuration:0.3f animations:^{
        leftLockView.transform = CGAffineTransformMakeTranslation(leftLockView.frame.size.width + 10, 0);
        rightLockView.transform = CGAffineTransformMakeTranslation(-(rightLockView.frame.size.width + 10), 0);
        
    } completion:^(BOOL finished) {
        isShowed = YES;
        isShowing = NO;
        [self performSelector:@selector(hideView) withObject:nil afterDelay:3.0f];
        
    }];
}

- (void) hideView {
    [UIView animateWithDuration:0.3f animations:^{
        leftLockView.transform = CGAffineTransformIdentity;
        rightLockView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        isShowed = NO;
        isShowing = NO;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
