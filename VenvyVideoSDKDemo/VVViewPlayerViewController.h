//
//  VVViewPlayerViewController.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 15/8/4.
//  Copyright (c) 2015年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  使用VVSDKPlayerView,执行view级测试播放器,已更新旋转方法,可供参考(复杂)
 *  更新:iOS8.1,8.2实在没辙,已改为调用系统私有api,谨慎使用
 *  更新:如果为了键盘出现方向正确,请务必使用系统私有api更改设备方向!
 *  注意:使用里面旋转方法必须开启横竖屏!必须开启横竖屏!必须开启横竖屏!(重要说3遍!!!,开启方法见文档).不想开启横竖屏请自行解决全屏
 */
@interface VVViewPlayerViewController : UIViewController

- (id) initWithUrl:(NSString *)url VideoType:(NSInteger)videoType LocalVideoTitle:(NSString *)localVideoTitle IsLive:(BOOL)isLive;

@end
