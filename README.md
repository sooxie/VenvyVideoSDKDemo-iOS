# VenvyVideoSDKDemo-iOS
This is iOS SDK Demo for Video++

接入指南
--------
1.	下载SDK文件，SDK文件包括 VenvyVideoSDK.framework和VenvyVideoSDKResources.bundle两个。可使用的播放器有两个: VVSDKPlayerView(view级播放器)和VVSDKPlayerViewController(Controller级播放器)。view级播放器详细请看头文件和高手进阶。含有Cocoapod和没有的接入方法一样。
(注：请使用Xcode5及以上版本，SDK目前支持系统为iOS7,8。已知在有含ffmepg的第三方库情况下无法正常运行)。

2.	将这两个文件添加到你的工程中，如果是协同开发、使用git或svn等版本控制系统，最好不要将framework复制到项目目录下，请采用Reference的方法(不要勾选Copy items if needed)。播放器支持模拟器和真机测试。（framework中包含编译ijkPlayer(ffmpeg)的库(https://github.com/Bilibili/ijkplayer) ,所以库很大。打包后会增加ipa包3.5M左右的大小(v1.1及以前为7M左右)。模拟器播放使用软解的视频会音画不同步且退出播放器时有几率闪退，CPU跟不上，真机没有此问题。另模拟器在硬解时打开全局断点会在播放前进入断点，点继续运行3～5次即可）。
 
    如果使用demo请重新绑定framework和bundle，并删除红色占位的SDK。

3.	在Info.plist中需要添加View controller-based status bar appearance，值为NO。
 
4.	在工程设置项的TARGETS中，General标签中的Deployment Info 需要加上Landscape Left和Landscape Right。(也可在Info.plist中修改Supported interface orientations项)
注:如果只使用VVSDKPlayerView则可以不设置横屏，但Demo中针对view级的演示controller也无法使用，请自行斟酌或者重写控制器。

5.	如图在Build Settings标签下的Linking中的Other Linker Flags中添加 –ObjC。(注意大小写!!有使用Cocoapod的项目自带，无需设置)
 
6.	由于有使用系统的多媒体播放功能和网页访问(iOS 8会使用WebKit)，所以需要在Build Phases中的Link Binary With Libraries要添加
```
    AudioToolbox.framework,
    AVFoundation.framework,
    MediaPlayer.framework,
    CoreMedia.framework,
    WebKit.framework,
    libz.dylib,
    libbz2.dylib。
    如果没有使用Cocoapod可能需要多添加
    MobileCoreServices.framework
    Security.framework
    SystemConfiguration.framework
```

7.	在AppDelegate.m中引入头文件
```
 #import <VenvyVideoSDK/VenvyVideoSDK.h>
 并在didFinishLaunchingWithOptions函数中向云视链注册你的AppKey：
[VenvyVideoSDK setAppKey:@"xxxx"];
```

8.	使用时在需要接入播放器的View Controller中引入头
```
 #import <VenvyVideoSDK/VVSDKPlayerViewController.h>
```
在需要使用的地方接入
//自行填入视频路径，视频类型和播放器上显示的标题(可选)
```
//视频类型为 0:八大视频网站链接，1:视频原始播放地址，2:直播
VVSDKPlayerViewController *player = [[VVSDKPlayerViewController alloc] initWithUrl:url VideoType:0 LocalVideoTitle:nil]; 
[self presentViewController:player animated:YES completion:nil];
```
注意：present去SDKPlayerViewController的VC的shouldAutorotate必须为YES。(为NO目前已知8.1和8.2会出错)
SDKPlayerView使用方法详见高手进阶和头文件。

9.	修改图标方面，在VenvyVIdeoSDKResources.bundle下,
loading_logo和loading_view是加载时显示的，3倍大小分别为150和267。
播放器界面logo是player_logo，3倍大小是150。

高手进阶
--------
1.	view级播放器需要一个承载的UIViewController，Demo中的VVViewPlayerViewController是一个测试控制器(present,如果要使用push请自行根据生命周期作出调整)，只提供显示view级播放器的测试，您可以自行根据需要编写自己的控制器。

2.	具体view级播放器的属性和方法详见framework中的头文件，其中canSwitchFullScreen为设置是否能全屏，设置后会修改isFullScreen(是否全屏)的值，请于设置canSwitchFullScreen之后再设置isFullScreen。canSwitchFullScreen默认为NO，此时isFullScreen默认为YES；canSwitchFullScreen设置为YES时isFullScreen默认为NO。建议在canSwitchFullScreen为NO时保持isFullScreen为YES。

3.	请在startLoadingVideo之前完成所有设置，注意有切换全屏方法最好在方法block中加入updateFrame。startLoadingVideo之后将无法设置参数，在stop之后可重新设置url，videoType和localVideoTitle。如需重新设置block的方法或是否能切换全屏请释放本播放器并重新生成播放器。

4.	如果是在初始化controller时创建VVSDKPlayerView并且在viewDidLoad中调用startLoadingVideo的，一定要注意对controller的view修改一定要放在VVSDKPlayerView初始化之后(比如修改view的背景颜色)，不然会提前调用viewDidLoad导致VVSDKPlayerView还未生成就调用方法导致出错。

5.	在结束播放器并要释放时一定要调用stopAndDestoryView，不然内存无法释放。

6.	在切换全屏的方法中可加入Core Animation使切换更平滑。

7.	旋转相关
>* 利用present一个ViewController然后dismiss来触发ViewController的检查旋转机制，达到设置为横屏，这样做的坏处是无法或者很难设置旋转动画。
>* 目前较为寻常的做法是：
> ```
> [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];    
> // iOS8 还要把shouldAutorotate设为NO,转完才设为YES,不然设备会转回竖屏
> [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
> self.view.bounds = CGRectMake(0, 0, screenRect.width, screenRect.height); // iOS8  不要执行
> ```
> 但是这个方法由于旋转机制改变在iOS8中失效，强行旋转view后再旋转设备有可能屏幕错位或者有部分屏幕触摸失效（一般为右屏幕）。注：iOS8不要设置view.bounds。
>* 使用UIDevice的私有接口setOrientation强制旋转设备，这样keyboard出现的方向也不会出错（包括用户锁定设备旋转），但有拒审的可能，谨慎使用。（该方法效果最好）
>* 全屏不旋转，只有当用户旋转设备时才进行旋转。
>* Demo提供一个较为完整旋转方案，基于第二种方案。
>* #####**如果需要键盘方向正确请全部使用3)，即系统私有api。

8.	通知
> 具体见VVMediaPlayback.h
> 在自己应用内打开链接：（目前支持百科和云窗）
> 在编辑添加链接时将链接的协议头http://或者https://替换为相应的tomyapp://或tomyapps://，通过通知VVSDKMyAppLinkDidOpenNotification传递。

9.	无界面的界面设置
>* 需要分离成两个界面，即视图层和手势层，视图层不能包含手势操作（UIScrollView及其子类除外，但大小不能覆盖于整个视图导致无法触发正常的点击手势）。
>* 手势层无需添加到视图层中。手势层和视图层均无需添加到view上，传给SDK由SDK分配添加至合理位置。 
> ```
> //设置customUIView不能含有手势(UIScrollView的除外),不然会被云链层覆盖
> [playerView setCustomUIView:mediaControl];
> //手势请置于这层
> [playerView setCustomGestureView:mediaControl.gestureView];
> ```
>* 如果视图层含有手势则将被置于视频交互层的下方，防止视频交互的手势被阻挡。
>* 具体可以参考Demo中的VVPlayerMediaControl和VVViewNoControlPlayerViewController。
>* 视图层必须加入以下代码（其中self或者mediaControl根据界面改成相应获取到手势的总界面即可）
> ```
> //必须添加,不然手势层无法正确触发
> -(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
> 	UIView *hitView = [super hitTest:point withEvent:event];
> 	if(hitView == self || hitView == mediaControl) {
> 		return nil;
> 	}
> 	else {
> 		return hitView;
> 	}
> }
> ```
