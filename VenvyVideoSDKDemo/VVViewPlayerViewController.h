//
//  VVViewPlayerViewController.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/8/4.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 使用VVSDKPlayerView,执行view级测试播放器,已更新旋转方法,可供参考(复杂)
 */
@interface VVViewPlayerViewController : UIViewController

- (id) initWithUrl:(NSString *)url VideoType:(NSInteger)videoType LocalVideoTitle:(NSString *)localVideoTitle;

@end
