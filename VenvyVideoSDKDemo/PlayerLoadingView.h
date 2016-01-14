//
//  PlayerLoadingView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VenvyVideoSDK/VVMediaPlayback.h>

@protocol PlayerLoadingViewDelegate <NSObject>

@required
- (void) backButtonTapped:(id)sender;

@end

@interface PlayerLoadingView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic,weak) id<PlayerLoadingViewDelegate> delegate;

+ (PlayerLoadingView *)instancePlayerLoadingView;

- (void) startAnimation;
- (void) stopAnimation;

- (void) hideBackButton:(BOOL)isHide;

- (void) sendErrorMessage:(VVSDKPlayerErrorState)errorState;


@end
