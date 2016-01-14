//
//  VVPlayerMediaControl.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/9/16.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VenvyVideoSDK/VVSDKPlayerView.h>
#import "BrightnessProgressView.h"
#import "PlayerLoadingView.h"
#import "PlayerLockScreenView.h"

@interface VVPlayerMediaControl : UIView

@property (nonatomic,weak) VVSDKPlayerView *playerView;

//是否启用云泡
@property (nonatomic,assign) BOOL isEnableBubble;

//手势层
@property (nonatomic) UIView *gestureView;

//返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backButton;
//清晰度按钮
@property (weak, nonatomic) IBOutlet UIButton *definitionButton;
//更多按钮
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
//暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
//图标按钮(无法点击)
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
//切换全屏按钮
@property (weak, nonatomic) IBOutlet UIButton *switchFullScreenButton;
//锁屏按钮
@property (weak, nonatomic) IBOutlet UIButton *lockScreenButton;
//控制云链开关按钮(请确保你使用的播放器上有这个按钮)
@property (weak, nonatomic) IBOutlet UIButton *venvyTagButton;
//切换屏幕尺寸按钮
@property (weak, nonatomic) IBOutlet UIButton *screenSizeButton;
//标题文本框
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//显示时间文本框
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//进度条
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
//缓冲条
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UIView *topControlView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlView;
//滑动提示界面
@property (weak, nonatomic) IBOutlet UIView *sliderHintView;
@property (weak, nonatomic) IBOutlet UIImageView *sliderHintImageView;
@property (weak, nonatomic) IBOutlet UILabel *sliderHintLabel;
//缓冲加载界面
@property (weak, nonatomic) IBOutlet UIView *bufferLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

//亮度调节控制
@property (nonatomic) BrightnessProgressView *brightnessView;

@property (weak, nonatomic) IBOutlet UIView *mediaControl;

//首次加载界面
@property (nonatomic) PlayerLoadingView *playerLoadingView;
//锁屏用界面
@property (nonatomic) PlayerLockScreenView *playerLockScreenView;


@property (nonatomic,assign) BOOL isFullScreen;


+(VVPlayerMediaControl *)instanceMediaControl;

- (IBAction)playButtonTapped:(id)sender;
- (IBAction)pauseButtonTapped:(id)sender;
- (IBAction)backButtonTapped:(id)sender;
- (IBAction)moreButtonTapped:(id)sender;
- (IBAction)definitionButtonTapped:(id)sender;
- (IBAction)switchFullScreenButtonTapped:(id)sender;
- (IBAction)lockScreenButtonTapped:(id)sender;
- (IBAction)venvyTagButtonTapped:(id)sender;
- (IBAction)screenSizeTapped:(id)sender;

//更新更多按钮列表(设置是否有开启云泡功能)
- (void)updateWithEnableBubble;

//结束播放
- (void)endPlay;
//进入或退出全屏
- (void)enterOrExitFullScreen:(BOOL)fullScreen;

//无界面播放器不实现这些功能,需自己控制
- (void) setSwitchToFullScreen:(void (^)(void))switchToFullScreen;
- (void) setTurnOffFullScreen:(void (^)(void))turnOffFullScreen;
- (void) setBackButtonTappedToDo:(void (^)(void))backButtonTapped;

@end

typedef NS_ENUM(NSInteger, VVPanType) {
    VVPanTypeNil = -1,                      //没有
    VVPanTypeBrightness,                    //调节亮度
    VVPanTypeVolume,                        //调节音量
    VVPanTypeProgress                       //调节进度
};
