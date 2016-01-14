//
//  BrightnessProgressView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "BrightnessProgressView.h"


@implementation BrightnessProgressView
@synthesize progressView;

+ (BrightnessProgressView *)instanceBrightnessProgressView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"BrightnessProgressView" owner:nil options:nil];
    BrightnessProgressView *brightnessProgressView = [nibViews objectAtIndex:0];
    return brightnessProgressView;
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
    [self.layer setCornerRadius:10.0f];
    
    [progressView setTrackImage:[UIImage imageNamed:@"slider_brightness_min"]];
    [progressView setProgressImage:[UIImage imageNamed:@"slider_brightness_max"]];
    [progressView setProgress:[UIScreen mainScreen].brightness];
    
}

- (void)setProgress:(CGFloat)progress {
    if(progress >= 0 && progress <= 1) {
        [progressView setProgress:progress];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size.height = 154;
    frame.size.width = 154;
    [super setFrame:frame];
}


@end
