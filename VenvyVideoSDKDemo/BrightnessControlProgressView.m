//
//  BrightnessControlProgressView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "BrightnessControlProgressView.h"

@interface BrightnessControlProgressView()

@property (nonatomic) UIImageView *trackImageView;
@property (nonatomic) UIImageView *progressImageView;
@property (nonatomic,assign) CGFloat segmentWidth;
@property (nonatomic,assign) NSInteger segmentNumber;

@end


@implementation BrightnessControlProgressView
@synthesize progress;
@synthesize progressImage;
@synthesize progressImageView;
@synthesize trackImage;
@synthesize trackImageView;
@synthesize segmentWidth;
@synthesize segmentNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initProgressView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initProgressView];
    }
    return self;
}

- (void) initProgressView
{
    if(progress < 0) {
        progress = 0;
    }
    if(progress > 1) {
        progress = 1;
    }
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setScrollEnabled:NO];
    [self addSubview:scrollView];
    
    if(progressImageView == nil) {
        progressImageView = [[UIImageView alloc] initWithFrame:frame];
        [progressImageView setContentMode:UIViewContentModeScaleToFill];
    }
    if(trackImageView == nil) {
        trackImageView = [[UIImageView alloc] initWithFrame:frame];
        [trackImageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    [scrollView addSubview:progressImageView];
    [scrollView addSubview:trackImageView];
    
    if(progressImage != nil) {
        progressImageView.image = progressImage;
    }
    if(trackImageView != nil) {
        trackImageView.image = trackImage;
    }
}

- (void) setProgressImage:(UIImage *)_progressImage
{
    progressImage = _progressImage;
    progressImageView.image = progressImage;
}

- (void) setTrackImage:(UIImage *)_trackImage
{
    trackImage = _trackImage;
    trackImageView.image = trackImage;
}

- (void) setProgress:(CGFloat)_progress
{
    [self setProgress:_progress animate:NO];
}

- (void) setProgress:(CGFloat)_progress animate:(BOOL)isAnimate
{
    progress = _progress;
    if(segmentWidth == 0) {
        segmentWidth = self.frame.size.width * (7 + 1) / 129.0f;
    }
    segmentNumber = roundf(self.frame.size.width * progress / segmentWidth);
    segmentNumber = segmentNumber <= 0 ? 1 : segmentNumber;
    
    if(isAnimate) {
        [UIView animateWithDuration:0.5f animations:^{
            trackImageView.transform = CGAffineTransformMakeTranslation(segmentWidth * segmentNumber, 0);
        }];
    }
    else {
        trackImageView.transform = CGAffineTransformMakeTranslation(segmentWidth * segmentNumber, 0);
    }
    
}



@end
