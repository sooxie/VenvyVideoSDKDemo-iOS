//
//  GestureInfoView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GestureInfoViewDelegate <NSObject>

@required
- (void) removeGestureInfoView;

@end

@interface GestureInfoView : UIView

@property (nonatomic,weak) id<GestureInfoViewDelegate>delegate;

+ (GestureInfoView *)instanceGestureInfoView;


@end
