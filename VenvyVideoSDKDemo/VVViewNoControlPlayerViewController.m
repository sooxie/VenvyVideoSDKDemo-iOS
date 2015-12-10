//
//  VVViewNoControlPlayerViewController.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/9/16.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import "VVViewNoControlPlayerViewController.h"
#import <VenvyVideoSDK/VVSDKPlayerView.h>
#import "VVPlayerMediaControl.h"

#ifndef IS_IPAD
#define IS_IPAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
#endif

#ifndef IS_IOS8_1
#define IS_IOS8_1 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.3)
#endif

#ifndef IS_IOS8
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#endif

@interface VVViewNoControlPlayerViewController()

@property (nonatomic) VVSDKPlayerView *playerView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic) UIButton *fullScreenButton;
@property (nonatomic,assign) BOOL isRotating;
@property (nonatomic,assign) BOOL isNeedCorrect;
@property (nonatomic,assign) BOOL isLockDevice;
@property (nonatomic) NSMutableArray *registerNotifications;
@property (nonatomic) VVPlayerMediaControl *mediaControl;

@end

@implementation VVViewNoControlPlayerViewController
@synthesize playerView;
@synthesize backButton;
@synthesize isFullScreen;
@synthesize fullScreenButton;
@synthesize isRotating;
@synthesize isNeedCorrect;
@synthesize isLockDevice;
@synthesize registerNotifications;
@synthesize mediaControl;

- (id) initWithUrl:(NSString *)url VideoType:(NSInteger)videoType LocalVideoTitle:(NSString *)localVideoTitle IsLive:(BOOL)isLive {
    self = [super init];
    if(self) {
        isFullScreen = NO;
        if(IS_IPAD) {
            playerView = [[VVSDKPlayerView alloc] initWithFrame:CGRectMake(20, 80, 600, 400) CanSwitchFullScreen:YES IsFullScreen:NO];
            [playerView setUrl:url];
            [playerView setVideoType:videoType];
            [playerView setLocalVideoTitle:localVideoTitle];
            [playerView setIsLive:isLive];
            //            [playerView setPlaybackControlStyle:VVSDKPlayerControlStyleNone];
        }
        else {
            playerView = [[VVSDKPlayerView alloc] initWithFrame:CGRectMake(10, 80, 300, 200) CanSwitchFullScreen:YES IsFullScreen:NO Url:url VideoType:videoType LocalVideoTitle:localVideoTitle];
            [playerView setIsLive:isLive];
        }
        //如果有对controller的view使用或修改一定要放在最后,不然会提前调用viewDidLoad(当然手动调用startLoadingVideo可以无视)
        [playerView setPlaybackControlStyle:VVSDKPlayerControlStyleNone];
        [self.view setBackgroundColor:[UIColor darkGrayColor]];
        [self.view addSubview:playerView];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mediaControl = [VVPlayerMediaControl instanceMediaControl];
    //启用云泡
    mediaControl.isEnableBubble = YES;
    [mediaControl updateWithEnableBubble];
    [playerView setEnableBubble:YES];
    
    [mediaControl setFrame:playerView.bounds];
    mediaControl.playerView = playerView;
//    [self.view addSubview:mediaControl];
    //设置customUIView不能含有手势(UIScrollView的除外),不然会被云链层覆盖
    [playerView setCustomUIView:mediaControl];
    //手势请置于这层
    [playerView setCustomGestureView:mediaControl.gestureView];
    
    __weak __block VVSDKPlayerView *weakPlayerView = playerView;
    __weak __block VVViewNoControlPlayerViewController *weakSelf = self;
    __weak __block VVPlayerMediaControl *weakMediaControl = mediaControl;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [mediaControl setSwitchToFullScreen:^{
        weakSelf.isFullScreen = YES;
        CGFloat maxSide = MAX(weakSelf.view.frame.size.width , weakSelf.view.frame.size.height);
        CGFloat minSide = MIN(weakSelf.view.frame.size.width , weakSelf.view.frame.size.height);
        
        if(!IS_IPAD) {
            //动画可选(最佳在0.3s内完成)
            //纠正
            if(weakSelf.isNeedCorrect) {
                if(!IS_IOS8_1) {
                    weakSelf.isRotating = YES;
                }
                [UIView animateWithDuration:0.3f animations:^{
                    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
                        [[UIApplication sharedApplication] setStatusBarOrientation:[UIApplication sharedApplication].statusBarOrientation];
                    }
                    else {
                        if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
                            if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
                                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                            }
                            else {
                                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                            }
                        }
                        else {
                            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                        }
                    }
                    if(IS_IOS8_1) {
                        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
                            [weakSelf forceLandscape:[UIApplication sharedApplication].statusBarOrientation];
                        }
                        else {
                            [weakSelf forceLandscape:UIInterfaceOrientationLandscapeRight];
                        }
                    }
                    else {
                        if(IS_IOS8) {
                            [weakSelf.view setTransform:CGAffineTransformIdentity];
                            weakSelf.view.frame = CGRectMake(0, 0, maxSide, minSide);
                        }
                    }
                    isNeedCorrect = NO;
                    
                    [weakPlayerView updateFrame:CGRectMake(0, 0, maxSide, minSide)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                }completion:^(BOOL finished) {
                    weakSelf.isRotating = NO;
                }];
                return;
            }
            //不是自动旋转使用这种方式触发的需要纠正
            if(!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
                //先关闭自动旋转,8.1,8.2直接调用旋转设备,不能关闭
                if(!IS_IOS8_1) {
                    weakSelf.isRotating = YES;
                }
                NSLog(@"%@",NSStringFromCGAffineTransform(weakSelf.view.transform));
                [UIView animateWithDuration:0.3f animations:^{
                    //强行旋转
                    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                    
                    if(IS_IOS8_1) {
                        [weakSelf forceLandscape:UIInterfaceOrientationLandscapeRight];
                    }
                    else {
                        [weakSelf.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                        weakSelf.view.frame = CGRectMake(0, 0, minSide, maxSide);
                    }
                    isNeedCorrect = YES;
                    [weakPlayerView updateFrame:CGRectMake(0,0, maxSide, minSide)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                }completion:^(BOOL finished) {
                    weakSelf.isRotating = NO;
                }];
            }
            else {
                [UIView animateWithDuration:0.3f animations:^{
                    if(!IS_IOS8) {
                        if(CGAffineTransformIsIdentity(weakSelf.view.transform)) {
                            if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                                [weakSelf.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                            }
                            else {
                                [weakSelf.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
                            }
                            weakSelf.view.frame = CGRectMake(0, 0, minSide, maxSide);
                            isNeedCorrect = YES;
                        }
                    }
                    [weakPlayerView updateFrame:CGRectMake(0, 0, maxSide, minSide)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                }];
            }
        }
        else {
            [UIView animateWithDuration:0.3f animations:^{
                [weakPlayerView updateFrame:CGRectMake(0, 0, maxSide, minSide)];
                [weakMediaControl setFrame:weakPlayerView.bounds];
            }];
        }
    }];
    
    [weakMediaControl setTurnOffFullScreen:^{
        weakSelf.isFullScreen = NO;
        
        CGFloat maxSide = MAX(weakSelf.view.frame.size.width , weakSelf.view.frame.size.height);
        CGFloat minSide = MIN(weakSelf.view.frame.size.width , weakSelf.view.frame.size.height);
        if(!IS_IPAD) {
            //动画可选(最佳在0.3s内完成)
            //不是自动旋转纠正切回
            if(weakSelf.isNeedCorrect) {
                //先关闭自动旋转
                if(!IS_IOS8_1) {
                    weakSelf.isRotating = YES;
                }
                [UIView animateWithDuration:0.3f animations:^{
                    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                    if(IS_IOS8_1) {
                        [weakSelf forceLandscape:UIInterfaceOrientationPortrait];
                    }
                    else {
                        [weakSelf.view setTransform:CGAffineTransformIdentity];
                        weakSelf.view.frame = CGRectMake(0, 0, minSide, maxSide);
                    }
                    [weakPlayerView updateFrame:CGRectMake(10, 80, 300, 200)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                    isNeedCorrect = NO;
                }completion:^(BOOL finished) {
                    weakSelf.isRotating = NO;
                }];
                return;
            }
            if(!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
                if(!IS_IOS8_1) {
                    weakSelf.isRotating = YES;
                }
                //强行旋转
                [UIView animateWithDuration:0.3f animations:^{
                    if(IS_IOS8) {
                        if(IS_IOS8_1) {
                            [weakSelf forceLandscape:UIInterfaceOrientationPortrait];
                        }
                        else {
                            if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                                [weakSelf.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
                            }
                            else {
                                [weakSelf.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                            }
                            weakSelf.view.frame = CGRectMake(0, 0, maxSide, minSide);
                        }
                        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                        isNeedCorrect = YES;
                    }
                    else {
                        [weakSelf.view setTransform:CGAffineTransformIdentity];
                        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                        weakSelf.view.frame = CGRectMake(0, 0, minSide, maxSide);
                    }
                    [weakPlayerView updateFrame:CGRectMake(10, 80, 300, 200)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                    
                }completion:^(BOOL finished) {
                    weakSelf.isRotating = NO;
                }];
            }
            else {
                [UIView animateWithDuration:0.3f animations:^{
                    if(!IS_IOS8) {
                        if(CGAffineTransformIsIdentity(weakSelf.view.transform)) {
                            [weakSelf.view setTransform:CGAffineTransformIdentity];
                            weakSelf.view.frame = CGRectMake(0, 0, minSide, maxSide);
                        }
                    }
                    [weakPlayerView updateFrame:CGRectMake(10, 80, 300, 200)];
                    [weakMediaControl setFrame:weakPlayerView.bounds];
                }];
            }
        }
        else {
            [UIView animateWithDuration:0.3f animations:^{
                [weakPlayerView updateFrame:CGRectMake(10, 80, 600, 400)];
                [weakMediaControl setFrame:weakPlayerView.bounds];
            }];
        }
    }];
    
    [mediaControl setBackButtonTappedToDo:^{
        //        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        /**
         *  返回按钮方法必须设置,如果需要返回按钮点击切回小屏,只要设置
         *  [weakPlayerView enterOrExitFullScreen:NO];
         *
         *  如果希望退出这个播放页面则
         *  [weakPlayerView stopAndDestoryView];   //重要,一定要调用,不然内存不释放
         *  [weakSelf dismissViewControllerAnimated:YES completion:nil];
         */
        
        [weakMediaControl enterOrExitFullScreen:NO];
    }];
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, 25, 80, 30)];
    [backButton setBackgroundColor:[UIColor blackColor]];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40, CGRectGetMaxY(playerView.frame) + 10, 80, 50)];
    [fullScreenButton setBackgroundColor:[UIColor blackColor]];
    [fullScreenButton setTitle:@"全屏" forState:UIControlStateNormal];
    [fullScreenButton addTarget:self action:@selector(fullScreenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fullScreenButton];
    
    [playerView startLoadingVideo];
}

- (void) backButtonTapped:(id)sender {
    [playerView stopAndDestoryView];
    [mediaControl endPlay];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) fullScreenButtonTapped:(id)sender {
    [mediaControl enterOrExitFullScreen:![playerView isFullScreen]];
}

- (void) viewWillLayoutSubviews {
    //调整横竖屏按钮位置
    [super viewWillLayoutSubviews];
    CGFloat maxSide = MAX(self.view.frame.size.width , self.view.frame.size.height);
    CGFloat minSide = MIN(self.view.frame.size.width , self.view.frame.size.height);
    CGFloat useWidth;
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        useWidth = minSide;
    }
    else {
        useWidth = maxSide;
    }
    [backButton setFrame:CGRectMake(useWidth / 2 - 40, 25, 80, 30)];
    
    [fullScreenButton setFrame:CGRectMake(useWidth / 2 - 40, CGRectGetMaxY(playerView.frame) + 10, 80, 50)];
    
//    [mediaControl setFrame:playerView.bounds];
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSLog(@"D:%ld,%ld",[[UIApplication sharedApplication] statusBarOrientation],[UIDevice currentDevice].orientation);
    //靠旋转,还没切换到全屏的时候
    if(!IS_IPAD) {
        //转到向下不修改
        if(orientation == UIDeviceOrientationPortraitUpsideDown) {
            return;
        }
        if(!isFullScreen) {
            //切换竖屏纠正
            if(isNeedCorrect && !UIDeviceOrientationIsLandscape(orientation)) {
                [UIView animateWithDuration:0.3f animations:^{
                    CGFloat maxSide = MAX(self.view.frame.size.width , self.view.frame.size.height);
                    CGFloat minSide = MIN(self.view.frame.size.width , self.view.frame.size.height);
                    if(IS_IOS8) {
                        [self.view setTransform:CGAffineTransformIdentity];
                        self.view.frame = CGRectMake(0, 0, minSide, maxSide);
                    }
                    isNeedCorrect = NO;
                }];
                return;
            }
            //进入全屏
            if(UIDeviceOrientationIsLandscape(orientation)) {
                [mediaControl enterOrExitFullScreen:YES];
            }
        }
        else {
            //纠正
            if(isNeedCorrect && !UIDeviceOrientationIsPortrait(orientation)) {
                [UIView animateWithDuration:0.3f animations:^{
                    CGFloat maxSide = MAX(self.view.frame.size.width , self.view.frame.size.height);
                    CGFloat minSide = MIN(self.view.frame.size.width , self.view.frame.size.height);
                    if(IS_IOS8) {
                        [self.view setTransform:CGAffineTransformIdentity];
                        self.view.frame = CGRectMake(0, 0, maxSide, minSide);
                    }
                    isNeedCorrect = NO;
                }];
                return;
            }
            //退出全屏
            if(UIDeviceOrientationIsPortrait(orientation)) {
                [mediaControl enterOrExitFullScreen:NO];
            }
            
        }
    }
}

- (BOOL) shouldAutorotate {
    if(!isRotating) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSUInteger) supportedInterfaceOrientations
{
    if(IS_IPAD || (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        if(isFullScreen) {
            return UIInterfaceOrientationMaskPortrait;
        }
        else {
            return UIInterfaceOrientationMaskLandscape;
        }
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    if(IS_IPAD  || (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))) {
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            return UIInterfaceOrientationLandscapeRight;
        }
        else {
            return UIInterfaceOrientationLandscapeLeft;
        }
    }
    else if([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown){
        if(isFullScreen) {
            return UIInterfaceOrientationPortrait;
        }
        else {
            if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                return UIInterfaceOrientationLandscapeRight;
            }
            else {
                return UIInterfaceOrientationLandscapeLeft;
            }
        }
    }
    else {
        return UIInterfaceOrientationPortrait;
    }
}

//强制旋转设备
- (void)forceLandscape:(UIInterfaceOrientation)orientation
{
    UIDevice  *myDevice = [UIDevice currentDevice];
    if([myDevice respondsToSelector:@selector(setOrientation:)])
    {
        NSInteger param;
        
        param = orientation;
        
        NSMethodSignature *signature  = [[myDevice class] instanceMethodSignatureForSelector:@selector(setOrientation:)];
        NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:myDevice];
        [invocation setSelector:@selector(setOrientation:)];
        [invocation setArgument:&param
                        atIndex:2];
        [invocation invoke];
    }
}


@end
