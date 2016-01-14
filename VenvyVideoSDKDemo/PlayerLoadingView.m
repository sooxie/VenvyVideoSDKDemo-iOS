//
//  PlayerLoadingView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "PlayerLoadingView.h"

@interface PlayerLoadingView()

@property (nonatomic) BOOL endLoading;
@property (nonatomic) CABasicAnimation *loadingAnim;

@end

@implementation PlayerLoadingView
@synthesize backButton;
@synthesize loadingImageView;
@synthesize hintLabel;
@synthesize endLoading;
@synthesize loadingAnim;

+ (PlayerLoadingView *)instancePlayerLoadingView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"PlayerLoadingView" owner:nil options:nil];
    PlayerLoadingView *playerLoadingView = [nibViews objectAtIndex:0];
    return playerLoadingView;
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
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setHidden:YES];
}

- (void)startAnimation {
    [self setHidden:NO];
    endLoading = NO;
    
    if(!loadingAnim) {
        loadingAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        loadingAnim.removedOnCompletion = NO;
        loadingAnim.delegate = self;
        loadingAnim.fillMode = kCAFillModeBoth;
        loadingAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    loadingAnim.speed = 1;
    loadingAnim.duration = 1.5f;
    loadingAnim.fromValue = [NSNumber numberWithDouble:0.0];
    loadingAnim.toValue = [NSNumber numberWithDouble:2 * M_PI];
    loadingAnim.repeatCount = HUGE_VALF;
    
    [loadingImageView.layer addAnimation:loadingAnim forKey:@"transform.rotation"];
    
}

- (void)stopAnimation {
    [self setHidden:YES];
    endLoading = YES;
    [loadingImageView.layer removeAllAnimations];
    loadingAnim = nil;
}

- (void)loadFailedStopAnimation {
    endLoading = YES;
    CFTimeInterval pausedTime = [loadingImageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    loadingImageView.layer.speed = 0.0;
    loadingImageView.layer.timeOffset = pausedTime;
}

- (void)loadFailed {
    [hintLabel setText:@"加载失败,请稍后再试"];
}

- (void)loadFailedByErrorUrl {
    [hintLabel setText:@"地址无效"];
}

- (void)loadFailedByErrorUrlFormat {
    [hintLabel setText:@"地址格式错误"];
}

- (void)loadFailedBySlowConnecting {
    [hintLabel setText:@"网络连接超时,请稍后再试"];
}

- (void)loadFailedByInvalidToken {
    [hintLabel setText:@"AppKey与bundleID不对应"];
}

- (void)loadFailedByInvalidAppKey {
    [hintLabel setText:@"AppKey无效"];
}

- (void)loadFailedByLive {
    [hintLabel setText:@"播放错误,这是直播视频"];
}

- (void)loadCompletedByAnalysis {
    [hintLabel setText:@"视频加载中..."];
}

- (void)loadNextPlayer {
    [hintLabel setText:@"加载失败,切换播放器中..."];
}

- (void)loadServerError {
    [hintLabel setText:@"连接服务器失败，请稍后再试"];
}

- (void)loadNoNet {
    [hintLabel setText:@"无网络连接，请检查网络"];
}

- (void)sendErrorMessage:(VVSDKPlayerErrorState)errorState {
    if(errorState < VVSDKPlayerHintForCeluar) {
        [self loadFailedStopAnimation];
    }
    switch (errorState) {
        case VVSDKPlayerErrorUrl:
            [self loadFailedByErrorUrl];
            break;
        case VVSDKPlayerErrorUrlFormat:
            [self loadFailedByErrorUrlFormat];
            break;
        case VVSDKPlayerErrorServer:
            [self loadServerError];
            break;
        case VVSDKPlayerErrorSlowConnecting:
            [self loadFailedBySlowConnecting];
            break;
        case VVSDKPlayerErrorInvalidAppKey:
            [self loadFailedByInvalidAppKey];
            break;
        case VVSDKPlayerErrorInvalidBundleID:
            [self loadFailedByInvalidToken];
            break;
        case VVSDKPlayerErrorForLiveVideo:
            [self loadFailedByLive];
            break;
        case VVSDKPlayerErrorForNoNet:
            [self loadNoNet];
            break;
        case VVSDKPlayerHintForServerLoadComplete:
            [self loadCompletedByAnalysis];
            break;
        default:
            break;
    }
}

- (void)backButtonTapped:(id)sender {
    //    [controller btnBackTapped:sender];
    if([self.delegate respondsToSelector:@selector(backButtonTapped:)]) {
        [self.delegate backButtonTapped:sender];
    }
}

- (void)hideBackButton:(BOOL)isHide {
    [backButton setHidden:isHide];
}

- (void)dealloc {
    [loadingImageView.layer removeAllAnimations];
}


@end
