//
//  BrightnessProgressView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrightnessControlProgressView.h"

@interface BrightnessProgressView : UIView

@property (weak, nonatomic) IBOutlet BrightnessControlProgressView *progressView;

+ (BrightnessProgressView *)instanceBrightnessProgressView;

- (void)setProgress:(CGFloat)progress;

@end
