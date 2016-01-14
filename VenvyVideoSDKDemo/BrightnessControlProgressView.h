//
//  BrightnessControlProgressView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrightnessControlProgressView : UIView

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic) UIImage *trackImage;
@property (nonatomic) UIImage *progressImage;

- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress animate:(BOOL)animate;

@end
