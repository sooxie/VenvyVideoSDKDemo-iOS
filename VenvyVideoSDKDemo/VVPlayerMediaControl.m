//
//  VVPlayerMediaControl.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/9/16.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import "VVPlayerMediaControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import <VenvyVideoSDK/VVMediaPlayback.h>
#import <VenvyVideoSDK/VVGestureInfoView.h>
#import <VenvyVideoSDK/VVExpandTableView.h>

#define VVMAXSIDE (MAX((UIScreen.mainScreen.bounds.size.width),(UIScreen.mainScreen.bounds.size.height)))
//更新:分离界面层和手势层,解决按钮点击延时问题

//在6代之前的机子部分长宽大小设为原来的0.8倍
#define VVModelScale (VVMAXSIDE >= 667 ? 1 : 0.8)

@interface VVPlayerMediaControl()<UIGestureRecognizerDelegate,VVPlayerLoadingViewDelegate,VVGestureInfoViewDelegate,VVExpandTableViewDelegate>
{
    void (^switchToFullScreen)(void);
    void (^turnOffFullScreen)(void);
    void (^backButtonTappedToDo)(void);
}
@property (nonatomic) NSMutableArray *registerNotifications;
@property (nonatomic,assign) BOOL isLongTime;
@property (nonatomic,assign) BOOL isSeeking;
@property (nonatomic) NSString *totalTimeStr;
@property (nonatomic,assign) BOOL isShowing;
@property (nonatomic,assign) BOOL isShowControl;
@property (nonatomic) UISlider *volumeSlider;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UITapGestureRecognizer *singleRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleRecognizer;
@property (nonatomic) VVGestureInfoView *gestureInfoView;
@property (nonatomic,assign) VVPanType panType;
@property (nonatomic,assign) CGFloat firstX;
@property (nonatomic,assign) CGFloat firstY;
@property (nonatomic,assign) BOOL isLive;
@property (nonatomic,assign) CGFloat originSliderValue;
@property (nonatomic,assign) BOOL isDisablePanGesture;
@property (nonatomic,assign) BOOL isExpand;
@property (nonatomic,assign) BOOL isExpanding;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isToPlay;
@property (nonatomic) NSTimer *refreshTimeTimer;
@property (nonatomic) NSTimer *loadingTimer;
@property (nonatomic) NSMutableArray *expandViewControllerArray;
@property (nonatomic) NSMutableArray *expandViewArray;
@property (nonatomic) NSMutableArray *buttonForExpandViewArray;
@property (nonatomic) NSMutableArray *strFormatArray;
@property (nonatomic) NSString *currentFormat;
@property (nonatomic,assign) VVSDKPlayerScreenSize currentSize;

@end

@implementation VVPlayerMediaControl
@synthesize playerView;
@synthesize registerNotifications;
@synthesize backButton,iconButton,moreButton,playButton,pauseButton,definitionButton,venvyTagButton,lockScreenButton,screenSizeButton,switchFullScreenButton;
@synthesize timeLabel,titleLabel;
@synthesize progressSlider;
@synthesize bufferProgressView;
@synthesize topControlView,bottomControlView;
@synthesize sliderHintView,sliderHintLabel,sliderHintImageView;
@synthesize bufferLoadingView,loadingLabel;
@synthesize brightnessView;
@synthesize mediaControl;
@synthesize playerLoadingView;
@synthesize playerLockScreenView;
@synthesize isSeeking;
@synthesize isLongTime;
@synthesize totalTimeStr;
@synthesize isShowing,isShowControl;
@synthesize isFullScreen;
@synthesize volumeSlider;
@synthesize panGesture,singleRecognizer,doubleRecognizer;
@synthesize panType;
@synthesize firstX,firstY;
@synthesize isLive;
@synthesize originSliderValue;
@synthesize isDisablePanGesture;
@synthesize isExpand,isExpanding;
@synthesize isPlaying,isToPlay;
@synthesize refreshTimeTimer,loadingTimer;
@synthesize expandViewArray,expandViewControllerArray,buttonForExpandViewArray;
@synthesize strFormatArray,currentFormat;
@synthesize gestureInfoView;
@synthesize currentSize;
@synthesize gestureView;

+(VVPlayerMediaControl *)instanceMediaControl {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"VVPlayerMediaControl" owner:nil options:nil];
    VVPlayerMediaControl *mediaControl = [nibViews objectAtIndex:0];
    return mediaControl;
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
    [self registerNotification];
    [self initView];
    [self initGesture];
    [self addExpandTableView];
}

- (void)dealloc {
    
}

- (void)initView {
    //手势层(手势层无需添加在该页面上,设置给SDK会添加在合适位置)
    if(!gestureView) {
        gestureView = [[UIView alloc] initWithFrame:self.bounds];
    }
    
    [bufferProgressView setProgressTintColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0.9f]];
    [bufferProgressView setTrackTintColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:0.6f]];
    
    [progressSlider setThumbImage:[UIImage imageNamed:@"slider_button"] forState:UIControlStateNormal];
    [progressSlider setThumbImage:[UIImage imageNamed:@"slider_button_selected"] forState:UIControlStateSelected];
    [progressSlider setThumbImage:[UIImage imageNamed:@"slider_button_selected"] forState:UIControlStateHighlighted];
    [progressSlider setThumbImage:[UIImage imageNamed:@"slider_button"] forState:UIControlStateDisabled];
    [progressSlider setContinuous:NO];
    [progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [progressSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_progress_min"] forState:UIControlStateNormal];
    
    [progressSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [progressSlider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [progressSlider addTarget:self action:@selector(sliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [progressSlider addTarget:self action:@selector(sliderTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    
    [progressSlider addTarget:self action:@selector(sliderTouchDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [progressSlider addTarget:self action:@selector(sliderTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    
    [progressSlider setEnabled:NO];
    CGRect sliderFrame = progressSlider.frame;
    sliderFrame.size.height = 10;
    [progressSlider trackRectForBounds:sliderFrame];
    
    sliderHintView.layer.cornerRadius = 5.0f;
    sliderHintView.layer.masksToBounds = YES;
    
    bufferLoadingView.layer.cornerRadius = 5.0f;
    bufferLoadingView.layer.masksToBounds = YES;
    
    mediaControl.layer.masksToBounds = YES;
    
    [sliderHintView setHidden:YES];
    [bufferLoadingView setHidden:YES];
    [brightnessView setHidden:YES];
    [playerLockScreenView setHidden:YES];
    [pauseButton setHidden:YES];
    
    [playerLoadingView updateFrame:self.bounds];
    [playerLoadingView startAnimation];
    
}

- (void)initGesture {
    //取到音量
    MPVolumeView *mpVolumeView = [[MPVolumeView alloc] init];
    for (UIView *view in [mpVolumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }
    [mpVolumeView setHidden:YES];
    [mpVolumeView setShowsVolumeSlider:YES];
    [mpVolumeView sizeToFit];
    //移出显示区域
    [mpVolumeView setFrame:CGRectMake(-100, -100, 40, 40)];
    
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    //手指数
    singleRecognizer.numberOfTouchesRequired = 1;
    //点击次数
    singleRecognizer.numberOfTapsRequired = 1;
    //设置代理方法
    singleRecognizer.delegate = self;
    //增加事件者响应者
    [gestureView addGestureRecognizer:singleRecognizer];
    
    
    //单指双击
    doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    doubleRecognizer.numberOfTouchesRequired = 1;
    doubleRecognizer.numberOfTapsRequired = 2;
    doubleRecognizer.delegate= self;
    [gestureView addGestureRecognizer:doubleRecognizer];
    
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    
    //滑动
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panType = VVPanTypeNil;
    [gestureView addGestureRecognizer:panGesture];
}

- (void)loadComplete {
    CGFloat totalTime = [playerView getTotalDuration];
    [progressSlider setMaximumValue:totalTime];
    if(totalTime > 3600) {
        isLongTime = YES;
    }
    progressSlider.maximumValue = totalTime;
    totalTimeStr = [self convertTime:totalTime];
    [playerLoadingView stopAnimation];
    [progressSlider setEnabled:YES];
    isToPlay = YES;
    isShowControl = YES;
    [self quickHideControl];
    [playerView playerPlayorPause:YES];
    if(!refreshTimeTimer) {
        refreshTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshMediaControl) userInfo:nil repeats:YES];
        if(!isShowing && isShowControl) {
            [self pauseTimer];
        }
    }
}

- (void)showControl {
    if(isShowing) {
        [self performSelector:@selector(showControl) withObject:nil afterDelay:0.2f];
        return;
    }
    if(isShowControl) {
        return;
    }
    if(!isSeeking) {
        [self resumeTimer];
    }
    isShowing = YES;
    [self cancelDelayedHide];
    if(isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    [topControlView setHidden:NO];
    [bottomControlView setHidden:NO];
    [UIView animateWithDuration:0.5f animations:^{
        topControlView.alpha = 1;
        bottomControlView.alpha = 1;
    } completion:^(BOOL finished) {
        isShowing = NO;
        isShowControl = YES;
        [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
    }];
}

- (void)hideControl {
    if(isShowing) {
        [self performSelector:@selector(hideControl) withObject:nil afterDelay:0.2f];
        return;
    }
    if(!isShowControl) {
        return;
    }
    isShowing = YES;
    [self cancelDelayedHide];
    if(isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    [UIView animateWithDuration:0.5f animations:^{
        topControlView.alpha = 0;
        bottomControlView.alpha = 0;
    } completion:^(BOOL finished) {
        isShowing = NO;
        isShowControl = NO;
        [topControlView setHidden:YES];
        [bottomControlView setHidden:YES];
        if(!isSeeking) {
            [self pauseTimer];
        }
    }];
}

- (void)quickHideControl {
    isShowControl = NO;
    isShowing = NO;
    [self cancelDelayedHide];
    topControlView.alpha = 0;
    bottomControlView.alpha = 0;
    if(isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    }
    [topControlView setHidden:YES];
    [bottomControlView setHidden:YES];
    if(!isSeeking) {
        [self pauseTimer];
    }
}

- (void)cancelDelayedHide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
}

- (void)pauseTimer {
    if(!refreshTimeTimer) {
        return;
    }
    [refreshTimeTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    if(!refreshTimeTimer) {
        return;
    }
    [refreshTimeTimer setFireDate:[NSDate date]];
}

/**
 *  更新下方控制栏状态
 */
- (void)refreshMediaControl
{
    NSTimeInterval duration = [playerView getTotalDuration];
    NSTimeInterval position = [playerView getCurrentPlayTime];
    
    NSTimeInterval playableDuration = [playerView getcurrentBufferTime];
    
    NSInteger intDuration = duration + 0.5;
    NSInteger intPlayableDuration = playableDuration + 0.5;
    
    if(!isSeeking) {
        progressSlider.value = position;
    }
    
    [bufferProgressView setProgress:(1.0f * intPlayableDuration / intDuration)];
    
    [timeLabel setText:[NSString stringWithFormat:@"%@/%@",[self convertTime:progressSlider.value],totalTimeStr]];
    
    isPlaying = [playerView isPlaying];
    self.playButton.hidden = isPlaying;
    self.pauseButton.hidden = !isPlaying;
}


#pragma Gesture
- (void) handleTapGesture : (UITapGestureRecognizer *)sender {
    
    if(sender.numberOfTapsRequired == 1) {
        if(!isShowControl) {
            [self showControl];
        }
        else {
            //关闭可能打开的tableview
            if(isExpand) {
                [self hideTableView:-1 isSwitch:NO];
            }
            [self hideControl];
        }
    }
    else if(sender.numberOfTapsRequired == 2) {
        isPlaying = [playerView isPlaying];
        [self hideTableView:-1 isSwitch:NO];
        if(isPlaying) {
            [self pauseButtonTapped:pauseButton];
        }
        else {
            if(isToPlay) {
                [self pauseButtonTapped:pauseButton];
            }
            else {
                [self playButtonTapped:playButton];
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:mediaControl];
    firstX = touchPoint.x;
    firstY = touchPoint.y;
    panType = VVPanTypeNil;
}

- (void) handlePanGesture : (UIPanGestureRecognizer *)sender{
    //panType: 0 调节亮度(左侧上下滑) 1 调节音量(右侧上下滑) 2 调节进度条
    //NSLog(@"%ld",sender.numberOfTouches);
    
    if(sender.numberOfTouches > 1) {
        return;
    }
    
    if(isExpand) {
        [self hideTableView:-1 isSwitch:NO];
    }
    
    CGFloat maxSide = MAX(self.frame.size.height,self.frame.size.width);
    CGFloat minSide = MIN(self.frame.size.height,self.frame.size.width);
    
    CGPoint translation = [sender translationInView:mediaControl];
    CGPoint velocity = [sender velocityInView:mediaControl];
    CGPoint location = [sender locationInView:mediaControl];
    
    if(panType == VVPanTypeNil) {
        if((translation.y == 0 && fabs(translation.x) >= 5) || fabs(translation.x) / fabs(translation.y) >= 3) {
            if(!isLive) {
                [sliderHintView setHidden:NO];
            }
            isSeeking = YES;
            [self resumeTimer];
            originSliderValue = progressSlider.value;
            // 左右滑动
            panType = VVPanTypeProgress;
            
        }
        else if ((translation.x == 0 && fabs(translation.x) >= 5) || fabs(translation.y) / fabs(translation.x) >= 3) {
            if(firstX >= maxSide / 2 && firstY >= 30.0f && firstY <= minSide - 30.0f) {
                panType = VVPanTypeVolume;
            }
            else if(firstX < maxSide / 2 && firstY >= 30.0f && firstY <= minSide - 30.0f)
            {
                panType = VVPanTypeBrightness;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBrightnessView) object:nil];
            }
        }
        else {
            panType = -1;
        }
    }
    //NSLog(@"panType:%ld",panType);
    switch (panType) {
        case VVPanTypeBrightness:
        {
            CGFloat ratio = ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) ? 25000.0f : 15000.0f;
            
            CGFloat nowValue = [UIScreen mainScreen].brightness;
            [[UIScreen mainScreen] setBrightness:(nowValue - velocity.y / ratio)];
            [brightnessView setProgress:(nowValue - velocity.y / ratio)];
            [brightnessView setAlpha:1.0f];
            [brightnessView setHidden:NO];
            break;
        }
        case VVPanTypeVolume:
        {
            CGFloat ratio = ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) ? 20000.0f : 13000.0f;
            
            CGFloat nowValue = volumeSlider.value;
            CGFloat changedValue = 1.0f * (nowValue - velocity.y / ratio);
            if(changedValue < 0) {
                changedValue = 0;
            }
            if(changedValue > 1) {
                changedValue = 1;
            }
            
            [volumeSlider setValue:changedValue animated:YES];
            
            [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case VVPanTypeProgress:
        {
            if(isLive) {
                break;
            }
            if(location.x <= 50 || location.x >= maxSide - 50) {
                sliderHintImageView.image = [UIImage imageNamed:@"slider_cancel"];
                [sliderHintLabel setText:@"松开手指，取消进退"];
            }
            else {
                CGFloat ratio = ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) ? 200.0f : 100.0f;
                CGFloat nowValue = progressSlider.value;
                [progressSlider setValue:(nowValue + velocity.x / ratio) animated:NO];
                if(progressSlider.value < originSliderValue) {
                    sliderHintImageView.image = [UIImage imageNamed:@"slider_REW"];
                    [sliderHintLabel setText:[NSString stringWithFormat:@"后退至 %@",[self convertTime:progressSlider.value]]];
                }
                else {
                    sliderHintImageView.image = [UIImage imageNamed:@"slider_FF"];
                    [sliderHintLabel setText:[NSString stringWithFormat:@"快进至 %@",[self convertTime:progressSlider.value]]];
                }
                
            }
            break;
        }
        default:
            break;
    }
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        if(panType == VVPanTypeBrightness) {
            [self performSelector:@selector(hideBrightnessView) withObject:nil afterDelay:2.0f];
        }
        if(panType == VVPanTypeProgress) {
            if(!isLive) {
                [UIView animateWithDuration:0.5f animations:^{
                    [sliderHintView setAlpha:0];
                }completion:^(BOOL finished) {
                    [sliderHintView setHidden:YES];
                    [sliderHintView setAlpha:1.0];
                }];
                
                if(location.x <= 50 || location.x >= maxSide - 50) {
                    [self sliderTouchUpOutSide:progressSlider];
                }
                else {
                    [self sliderTouchUpInside:progressSlider];
                }
            }
        }
        firstX = firstY = -1;
        panType = VVPanTypeNil;
        originSliderValue = -1;
    }
}

- (void) hideBrightnessView {
    [UIView animateWithDuration:1.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [brightnessView setAlpha:0];
    }completion:^(BOOL finished) {
        [brightnessView setHidden:YES];
        [brightnessView setAlpha:1];
    }];
}

- (void)bufferLoading {
    CGFloat bufferingProgress = [playerView getBufferLoadingProgress];
    if(bufferingProgress < 100 && bufferingProgress >= 0) {
        [loadingLabel setText:[NSString stringWithFormat:@"加载中...%ld%%",(long)bufferingProgress]];
    }
    else {
        [loadingLabel setText:@"加载中..."];
    }
}

#pragma for expand tableview
- (void) addExpandTableView
{
    expandViewArray = [NSMutableArray array];
    expandViewControllerArray = [NSMutableArray array];
    buttonForExpandViewArray = [NSMutableArray arrayWithObjects:definitionButton,moreButton,screenSizeButton, nil];
    strFormatArray = [NSMutableArray arrayWithObjects:@"normal",@"high",@"super", nil];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:
                             [NSMutableArray arrayWithObjects:@"低清",@"高清",@"超清",nil],
                             [NSMutableArray arrayWithObjects:@"禁用手势",@"手势说明", nil],
                             [NSMutableArray arrayWithObjects:@"默认",@"16:9",@"4:3",nil],
                             nil];
    for(NSInteger i = 0; i < [array count]; i++) {
        NSMutableArray *strArray = [array objectAtIndex:i];
        CGFloat width = (i == 1 ? 120.0f : 80.0f) * VVModelScale;
        UIScrollView *viewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, [strArray count] * 40.0f * VVModelScale)];
        [viewContainer setScrollEnabled:NO];
        [mediaControl addSubview:viewContainer];
        [mediaControl sendSubviewToBack:viewContainer];
        
        VVExpandTableView *tableView = [[VVExpandTableView alloc] initWithFrame:CGRectMake(0, 0, width, 0) Index:i  NumberOfRow:[strArray count] StrArray:strArray];
        if(i == 1) {
            tableView.isShowSelected = NO;
        }
        
        UIButton *button = [buttonForExpandViewArray objectAtIndex:i];
        if(i != 1) {
            [button setTitle:[tableView.strArray objectAtIndex:0] forState:UIControlStateNormal];
        }
        if(i == 0) {
            [button setTitle:[tableView.strArray objectAtIndex:[tableView.strArray count] - 1] forState:UIControlStateNormal];
        }
        [tableView setIsExpand:NO];
        tableView.delegate = self;
        [expandViewArray addObject:viewContainer];
        [expandViewControllerArray addObject:tableView];
        [viewContainer addSubview:tableView.view];
        [viewContainer setHidden:YES];
    }
    [mediaControl bringSubviewToFront:topControlView];
    [mediaControl bringSubviewToFront:bottomControlView];
}

- (void)updateFormat:(NSArray *)formatList nowFormat:(NSString *)nowFormat{
    VVExpandTableView *expandTableView;
    for(VVExpandTableView *tempTableView in expandViewControllerArray) {
        //更新清晰度列表,在array第一项
        if(tempTableView.index == 0) {
            expandTableView = tempTableView;
            break;
        }
    }
    if(!expandTableView) {
        return;
    }
    [strFormatArray removeAllObjects];
    strFormatArray = [NSMutableArray arrayWithArray:formatList];
    NSInteger currentIndex = 0;
    for(NSInteger i = 0; i < [strFormatArray count]; i++) {
        NSString *tempFormat = [strFormatArray objectAtIndex:i];
        if([nowFormat isEqualToString:tempFormat]) {
            currentIndex = i;
            break;
        }
    }
    currentFormat = [strFormatArray objectAtIndex:currentIndex];
    
    //如果有需要,请自行新建一个数组存储你想自定义的清晰度名称
    
    UIView *viewContainer = [expandViewArray objectAtIndex:0];
    
    CGRect containerFrame = viewContainer.frame;
    containerFrame.size.height = [strFormatArray count] * 40.0f * VVModelScale;
    
    [viewContainer setFrame:containerFrame];
    
    CGRect frame = expandTableView.view.frame;
    frame.size.height = [strFormatArray count] * 40.0f * VVModelScale;
    [expandTableView updateTableView:frame numberOfRow:[strFormatArray count] strArray:strFormatArray];
    //更新清晰度列表,在array第一项
    UIButton *button = [buttonForExpandViewArray objectAtIndex:0];
    
    [button setTitle:currentFormat forState:UIControlStateNormal];
    
    //设置被选中
    [expandTableView setSelectedIndexPathFromNumber:currentIndex];
    
}

# pragma tableView control

- (void) showTableView:(NSInteger)index
{
    //如果控制栏在动画中,不显示
    if(isShowing) {
        return;
    }
    
    UIView *containerView = [expandViewArray objectAtIndex:index];
    VVExpandTableView *tableView = [expandViewControllerArray objectAtIndex:index];
    
    [tableView setSelectedIndexPath:tableView.selectedIndexPath];
    
    if(isExpand) {
        if(tableView.isExpand) {
            [self hideTableView:index isSwitch:NO];
            return;
        }
        [self hideTableView:-1 isSwitch:YES];
    }
    isExpand = YES;
    isExpanding = YES;
    [self cancelDelayedHide];
    
    UIButton *button = [buttonForExpandViewArray objectAtIndex:index];
    
    
    CGRect frame = containerView.frame;
    if(index == 1) {
        //更多显示位置不在正中间
        frame.origin.x = button.frame.origin.x + button.frame.size.width - frame.size.width + 10.0f;
    }
    else {
        frame.origin.x = button.frame.origin.x + (button.frame.size.width - frame.size.width) / 2;
    }
    if(index == 2) {
        //在下方显示,15为bttom空白区域
        frame.origin.y = bottomControlView.frame.origin.y - frame.size.height + 15;
    }
    else {
        //在上方显示
        frame.origin.y = CGRectGetMaxY(topControlView.frame);
    }
    containerView.frame = frame;
    
    UIView *showView = tableView.view;
    showView.alpha = 0.0f;
    [containerView setHidden:NO];
    
    [UIView animateWithDuration:0.3f animations:^{
        showView.alpha = 1.0f;
    }completion:^(BOOL finished) {
        tableView.isExpand = YES;
        isExpanding = NO;
    }];
}

- (void) waitAndHideTableView {
    [self hideTableView:-1 isSwitch:NO];
}

- (void) hideTableView:(NSInteger)index isSwitch:(BOOL)isSwitch
{
    VVExpandTableView *tableView;
    
    if(index == -1 && !isExpanding) {
        for(NSInteger i = 0; i < [expandViewControllerArray count]; i++) {
            VVExpandTableView *tempTableView = [expandViewControllerArray objectAtIndex:i];
            if(tempTableView.isExpand) {
                index = i;
                break;
            }
        }
    }
    if(index == -1) {
        //没有展开的tableview
        return;
    }
    
    if(!isSwitch) {
        isExpand = NO;
        [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
    }
    
    tableView = [expandViewControllerArray objectAtIndex:index];
    
    UIView *containerView = [expandViewArray objectAtIndex:index];
    
    UIView *showView = tableView.view;
    
    [UIView animateWithDuration:0.3f animations:^{
        showView.alpha = 0.0f;
    }completion:^(BOOL finished) {
        [containerView setHidden:YES];
        tableView.isExpand = NO;
    }];
}

#pragma VVExpandTableView delegate
- (void) tableViewIndex:(NSInteger)index didSelectRowAtTow:(NSInteger)row {
    switch (index) {
        case 0:
        {
            //清晰度
            NSString *oldFormat = currentFormat;
            currentFormat = [strFormatArray objectAtIndex:row];
            
            if([oldFormat isEqualToString:currentFormat]) {
                [self hideTableView:-1 isSwitch:NO];
                return;
            }
            UIButton *button = [buttonForExpandViewArray objectAtIndex:index];
            VVExpandTableView *tableView = [expandViewControllerArray objectAtIndex:index];
            [button setTitle:[tableView.strArray objectAtIndex:row] forState:UIControlStateNormal];

            [self hideTableView:-1 isSwitch:NO];
            
            [playerView changeVideoDefinition:row];
            break;
        }
        case 1:
        {
            //更多
            switch (row) {
                case 0:
                {
                    VVExpandTableView *tableView = [expandViewControllerArray objectAtIndex:index];
                    if(!isDisablePanGesture) {
                        [gestureView removeGestureRecognizer:panGesture];
                        isDisablePanGesture = YES;
                        [tableView.strArray replaceObjectAtIndex:0 withObject:@"启用手势"];
                    }
                    else {
                        [gestureView addGestureRecognizer:panGesture];
                        isDisablePanGesture = NO;
                        [tableView.strArray replaceObjectAtIndex:0 withObject:@"禁用手势"];
                    }
                    [tableView.expandTableView reloadData];
                    [self hideTableView:-1 isSwitch:NO];
                    break;
                }
                case 1:
                {
                    if(isPlaying) {
                        //                        [self btnPlayTapped:self];
                        [self pauseButtonTapped:pauseButton];
                    }
                    [self hideTableView:-1 isSwitch:NO];
                    gestureInfoView = [[VVGestureInfoView alloc] initWithFrame:self.bounds];
                    gestureInfoView.delegate = self;
                    [mediaControl addSubview:gestureInfoView];
                    
                    break;
                }
                default:
                    break;
            }
            
            
            break;
        }
        case 2:
        {
            //屏幕尺寸
            UIButton *button = [buttonForExpandViewArray objectAtIndex:index];
            VVExpandTableView *tableView = [expandViewControllerArray objectAtIndex:index];
            [button setTitle:[tableView.strArray objectAtIndex:row] forState:UIControlStateNormal];
            
            [self hideTableView:-1 isSwitch:NO];
            VVSDKPlayerScreenSize newSize = row;//可自行匹配
            if(currentSize == newSize) {
                return;
            }
            switch (row) {
                case 0:case 1:case 2:
                {
                    [playerView setScreenSize:newSize];
                    currentSize = newSize;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma tap gesture for button

- (IBAction)playButtonTapped:(id)sender {
    isPlaying = [playerView isPlaying];
    [playButton setHidden:YES];
    [pauseButton setHidden:NO];
    isToPlay = YES;
    if(!isPlaying) {
        [playerView playerPlayorPause:YES];
    }
        [self hideTableView:-1 isSwitch:NO];
    [self cancelDelayedHide];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
}

- (IBAction)pauseButtonTapped:(id)sender {
    isPlaying = [playerView isPlaying];
    [playButton setHidden:NO];
    [pauseButton setHidden:YES];
    isToPlay = NO;
    if(isPlaying) {
        [playerView playerPlayorPause:NO];
    }
    [self hideTableView:-1 isSwitch:NO];
    [self cancelDelayedHide];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
}

- (IBAction)backButtonTapped:(id)sender {
    if(backButtonTappedToDo) {
        backButtonTappedToDo();
    }
}

- (IBAction)moreButtonTapped:(id)sender {
    NSInteger index = [buttonForExpandViewArray indexOfObject:sender];
    [self showTableView:index];
}

- (IBAction)definitionButtonTapped:(id)sender {
    NSInteger index = [buttonForExpandViewArray indexOfObject:sender];
    [self showTableView:index];
}

- (IBAction)switchFullScreenButtonTapped:(id)sender {
//    if(isShowing || isShowControl) {
//        [self hideControl];
//    }
    [self enterOrExitFullScreen:!isFullScreen];
//    isFullScreen = !isFullScreen;
    isShowing = NO;
    isShowControl = NO;
    [self cancelDelayedHide];
//    [self performSelector:@selector(showControl) withObject:nil afterDelay:0.3f];
    
}

- (IBAction)lockScreenButtonTapped:(id)sender {
    [playerLockScreenView setScreenLock];
    [self cancelDelayedHide];
    if(isExpand) {
        [self hideTableView:-1 isSwitch:NO];
    }
    [self hideControl];
}

- (IBAction)venvyTagButtonTapped:(id)sender {
    BOOL isShow = [playerView getVenvyTagIsShow];
    isShow = !isShow;
    [playerView setShowVenvyTag:isShow];

    if(!isShow) {
        [venvyTagButton setImage:[UIImage imageNamed:@"btn_hide_tag_unselected"] forState:UIControlStateNormal];
    }
    else {
        [venvyTagButton setImage:[UIImage imageNamed:@"btn_hide_tag_selected"] forState:UIControlStateNormal];
    }
}

- (IBAction)screenSizeTapped:(id)sender {
    NSInteger index = [buttonForExpandViewArray indexOfObject:sender];
    [self showTableView:index];
}

/**
 *  注册通知
 */
- (void) registerNotification {
    if(!registerNotifications) {
        registerNotifications = [NSMutableArray array];
    }
    [registerNotifications removeAllObjects];
    //第一次能够播放通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIsPreparedToPlayNotification:) name:VVSDKPlayerIsPreparedToPlayNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerIsPreparedToPlayNotification];
    //播放器加载状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:) name:VVSDKPlayerLoadStateDidChangeNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerLoadStateDidChangeNotification];
    //快进快退通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSeekStateDidChange:) name:VVSDKPlayerSeekStateNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerSeekStateNotification];
    //播放错误通知(状态提示)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerError:) name:VVSDKPlayerErrorNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerErrorNotification];
    //云链被点击后通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerVenvyTagActive:) name:VVSDKPlayerVenvyTagNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerVenvyTagNotification];
    //播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinish:) name:VVSDKPlayerPlaybackDidFinishNotification object:nil];
    [registerNotifications addObject:VVSDKPlayerPlaybackDidFinishNotification];
    //需要在本地打开链接的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerVenvyLinkDidOpen:) name:VVSDKMyAppLinkDidOpenNotification object:nil];
    [registerNotifications addObject:VVSDKMyAppLinkDidOpenNotification];
}

- (void)removeAllNotifications {
    for (NSString *name in registerNotifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:nil];
    }
    registerNotifications = nil;
}

- (void)playerIsPreparedToPlayNotification:(NSNotification *)sender {
    NSString *title = [sender.userInfo objectForKey:@"ShowTitle"];
    NSArray *formatArray = [sender.userInfo objectForKey:@"SendFormatArray"];
    NSString *format = [sender.userInfo objectForKey:@"Format"];
    
    [self updateFormat:formatArray nowFormat:format];
    //加载成功
    titleLabel.text = title;
    [self loadComplete];
    
}

- (void)playerLoadStateDidChange:(NSNotification *)sender {
    /**
     *  MPMovieLoadStateStalled,                //阻塞
     *  MPMovieLoadStatePlaythroughOK           //能够播放
     */
    MPMovieLoadState loadState = [[sender.userInfo objectForKey:@"LoadState"] integerValue];
    switch (loadState) {
        case MPMovieLoadStateStalled:
        {
            //TODO:playback stalled
            [bufferLoadingView setHidden:NO];
            if(!loadingTimer) {
                loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(bufferLoading) userInfo:nil repeats:YES];
            }
            break;
        }
        case MPMovieLoadStatePlaythroughOK:
        {
            //TODO:playback could play
            [bufferLoadingView setHidden:YES];
            [loadingTimer invalidate];
            loadingTimer = nil;
            [loadingLabel setText:@"加载中..."];
            break;
        }
        default:
            break;
    }
    
}

- (void)playerSeekStateDidChange:(NSNotification *)sender {
    /**
     *  VVSDKPlayerSeekStart,                   //开始Seek
     *  VVSDKPlayerSeekComplete                 //Seek结束
     */
    VVSDKPlayerSeekState seekState = [[sender.userInfo objectForKey:@"SeekState"] integerValue];
    switch (seekState) {
        case VVSDKPlayerSeekStart:
        {
            //TODO:playback start seek
            
            
            break;
        }
        case VVSDKPlayerSeekComplete:
        {
            //TODO:playback seek complete
            isSeeking = NO;
            if(!isDisablePanGesture) {
                [gestureView addGestureRecognizer:panGesture];
            }
            if(!isShowing && !isShowControl) {
                [self pauseTimer];
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)playerError:(NSNotification *)sender {
    /**
     *  VVSDKPlayerErrorUrl,                    //错误的地址
     *  VVSDKPlayerErrorUrlFormat,              //错误的地址格式
     *  VVSDKPlayerErrorServer,                 //连接服务器出错
     *  VVSDKPlayerErrorSlowConnecting,         //网络连接超时
     *  VVSDKPlayerErrorInvalidAppKey,          //无效Appkey
     *  VVSDKPlayerErrorInvalidBundleID,        //Appkey与bundleID不匹配
     *  VVSDKPlayerErrorForLiveVideo,           //这是直播视屏
     *  VVSDKPlayerErrorForNoNet,               //无网络连接
     *  VVSDKPlayerHintForCeluar,               //使用蜂窝网络提示
     *  VVSDKPlayerHintForChangePlayer,         //切换到软解播放器
     *  VVSDKPlayerHintForServerLoadComplete    //与服务器通信完成
     */
    VVSDKPlayerErrorState errorState = [[sender.userInfo objectForKey:@"ErrorState"] integerValue];
    //playerLoadingView中没有VVSDKPlayerHintForCeluar的表现形式
    [playerLoadingView sendErrorMessage:errorState];
    switch (errorState) {
        case VVSDKPlayerErrorUrl:
        {
            
            break;
        }
        case VVSDKPlayerErrorUrlFormat:
        {
            
            break;
        }
        case VVSDKPlayerErrorSlowConnecting:
        {
            
            break;
        }
        case VVSDKPlayerErrorInvalidAppKey:
        {
            
            break;
        }
        case VVSDKPlayerErrorInvalidBundleID:
        {
            
            break;
        }
        case VVSDKPlayerErrorForNoNet:
        {
            
            break;
        }
        case VVSDKPlayerHintForCeluar:
        {
            NSLog(@"正在使用蜂窝网络");
            break;
        }
        case VVSDKPlayerHintForChangePlayer:
        {
            NSLog(@"切换至软解,消耗增大");
            break;
        }
        case VVSDKPlayerHintForServerLoadComplete:
        {
            NSLog(@"服务器加载完成");
            break;
        }
        default:
            break;
    }
}

- (void)playerVenvyTagActive:(NSNotification *)sender {
    /**
     *  VVSDKPlayerVenvyTagPause,               //VenvyTag被点击,暂停播放器
     *  VVSDKPlayerVenvyTagPlay,                //VenvyTag点击结束,之前不在播放状态,可以继续播放
     *  VVSDKPlayerVenvyTagPlaying              //VenvyTag点击结束,之前是播放,继续播放
     */
    VVSDKPlayerVenvyTagState tagState = [[sender.userInfo objectForKey:@"VenvyTagState"] integerValue];
    switch (tagState) {
        case VVSDKPlayerVenvyTagPause:
        {
            NSLog(@"云链被点击,暂停播放");
            break;
        }
        case VVSDKPlayerVenvyTagPlay:
        {
            NSLog(@"云链被关闭,能够播放");
            break;
        }
        case VVSDKPlayerVenvyTagPlaying: {
            NSLog(@"云链被关闭,能够播放并开始播放");
            break;
        }
        default:
            break;
    }
}

- (void)playerDidFinish:(NSNotification *)sender {
    NSLog(@"播放完成");
}

- (void)playerVenvyLinkDidOpen:(NSNotification *)sender {
    NSString *linkUrl = [sender.userInfo objectForKey:@"LinkUrl"];
    NSLog(@"打开我的链接:%@",linkUrl);
}

- (NSString *)convertTime:(CGFloat)second {
    
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:isLongTime ? @"HH:mm:ss" : @"mm:ss"];
    NSString *showTime = [formatter stringFromDate:currentDate];
    
    return showTime;
}

#pragma slider seek

- (void)sliderTouchDown:(id)sender
{
    isSeeking = YES;
    [self resumeTimer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    if(isExpand) {
        [self hideTableView:-1 isSwitch:NO];
    }
    originSliderValue = progressSlider.value;
    [gestureView removeGestureRecognizer:panGesture];
}

- (void)sliderTouchUpInside:(id)sender
{
    if(!isExpand) {
        [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
    }
    double value = progressSlider.value;
    [bufferLoadingView setHidden:NO];
    
    [playerView setSeekTime:value];
}

- (void)sliderTouchCancel:(id)sender
{
    [self sliderTouchUpInside:sender];
}

- (void)sliderTouchUpOutSide:(id)sender
{
    isSeeking = NO;
    if(!isShowing && !isShowControl) {
        [self pauseTimer];
    }
    if(!isExpand) {
        [self performSelector:@selector(hideControl) withObject:nil afterDelay:5.0f];
    }
    if(!isDisablePanGesture) {
        [gestureView addGestureRecognizer:panGesture];
    }
    double value = [playerView getCurrentPlayTime];
    [progressSlider setValue:value animated:NO];
}

- (void)sliderTouchDragInside:(id)sender
{
    //NSLog(@"dragInside!!");
}

- (void)sliderTouchDragOutside:(id)sender
{
    //NSLog(@"dragOutside!!");
}

- (void)sliderValueChanged:(id)sender
{
    [timeLabel setText:[NSString stringWithFormat:@"%@/%@",[self convertTime:progressSlider.value],totalTimeStr]];
}

#pragma view delegate
- (void)removeGestureInfoView {
    if(gestureInfoView) {
        gestureInfoView.delegate = nil;
        gestureInfoView = nil;
    }
    isPlaying = [playerView isPlaying];
    if(!isPlaying) {
        if(isToPlay) {
            [playerView playerPlayorPause:YES];
        }
    }
}

/* //为playerLoadingView的delegate,不过功能重复并且命名一致,我就使用了同一个方法
- (void)backButtonTapped:(id)sender {
    
}
*/




- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [gestureView setFrame:self.bounds];
    [playerLoadingView updateFrame:self.bounds];
    [playerLockScreenView updateFrame:self.bounds];
}

- (void)endPlay {
    if(refreshTimeTimer) {
        [refreshTimeTimer invalidate];
        refreshTimeTimer = nil;
    }
    if(loadingTimer) {
        [loadingTimer invalidate];
        loadingTimer = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    for(VVExpandTableView *tableView in expandViewControllerArray)
    {
        [tableView.view removeFromSuperview];
        [tableView removeFromParentViewController];
    }
    for(UIView *view in expandViewArray)
    {
        [view removeFromSuperview];
    }
    expandViewArray = nil;
    for(VVExpandTableView *tableView in expandViewControllerArray) {
        [tableView removeFromParentViewController];
        [tableView.view removeFromSuperview];
    }
    [gestureView removeGestureRecognizer:singleRecognizer];
    [gestureView removeGestureRecognizer:doubleRecognizer];
    [gestureView removeGestureRecognizer:panGesture];
    self.playerView = nil;
    
    [self removeAllNotifications];
}

- (void)enterOrExitFullScreen:(BOOL)fullScreen {
    if(isFullScreen == fullScreen) {
        return;
    }
    [self hideTableView:-1 isSwitch:NO];
    [playerView enterOrExitFullScreen:fullScreen];
    isFullScreen = fullScreen;
    if(isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        if(switchToFullScreen) {
            switchToFullScreen();
        }
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        if(turnOffFullScreen) {
            turnOffFullScreen();
        }
    }
    if(isFullScreen) {
        [switchFullScreenButton setImage:[UIImage imageNamed:@"button_full_screen_off"] forState:UIControlStateNormal];
    }
    else {
        [switchFullScreenButton setImage:[UIImage imageNamed:@"button_full_screen_on"] forState:UIControlStateNormal];
    }
    
    if(isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

- (void) setSwitchToFullScreen:(void (^)(void))sender {
    switchToFullScreen = [sender copy];
}
- (void) setTurnOffFullScreen:(void (^)(void))sender {
    turnOffFullScreen = [sender copy];
}
- (void) setBackButtonTappedToDo:(void (^)(void))sender {
    backButtonTappedToDo = [sender copy];
}

//必须添加,不然手势层无法正确触发
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if(hitView == self || hitView == mediaControl) {
        return nil;
    }
    else {
        return hitView;
    }
}

@end
