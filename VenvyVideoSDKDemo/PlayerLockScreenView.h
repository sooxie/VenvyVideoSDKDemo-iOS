//
//  PlayerLockScreenView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerLockScreenView : UIView
@property (weak, nonatomic) IBOutlet UIView *leftLockView;
@property (weak, nonatomic) IBOutlet UIView *rightLockView;

+ (PlayerLockScreenView *)instancePlayerLockScreenView;

- (void) setScreenLock;
- (void) setScreenUnLock;

@end
