//
//  ExpandTableView.h
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpandTableViewDelegate <NSObject>

@required
- (void) tableViewIndex:(NSInteger)index didSelectRowAtTow:(NSInteger)row;

@end
@interface ExpandTableView:UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak,nonatomic) id<ExpandTableViewDelegate> delegate;

//所有可展开表排列顺序
@property (nonatomic,assign) NSInteger index;

//需要显示的字符串数组
@property (nonatomic) NSMutableArray *strArray;

//是否要显示被选中
@property (nonatomic) BOOL isShowSelected;

//选中位置
@property (nonatomic) NSIndexPath *selectedIndexPath;

//是否展开
@property (nonatomic,assign) BOOL isExpand;


- (void)reloadData;

//携带需要展现出来的字符串数组来新建tableview
- (id) initWithFrame:(CGRect)frame Index:(NSInteger)_index NumberOfRow:(NSInteger)rows StrArray:(NSMutableArray *)array;

- (void) setSelectedIndexPathFromNumber:(NSInteger)selectedRow;

//携带需要展现出来的字符串数组来更新tableview
- (void) updateTableView:(CGRect)frame numberOfRow:(NSInteger)rows strArray:(NSMutableArray *)array;

@end
