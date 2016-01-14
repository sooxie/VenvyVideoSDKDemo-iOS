//
//  ExpandTableView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "ExpandTableView.h"

#ifndef MAX_SIDE
#define MAX_SIDE (MAX((UIScreen.mainScreen.bounds.size.width),(UIScreen.mainScreen.bounds.size.height)))
#endif

#ifndef SCREEN_SCALE
#define SCREEN_SCALE (MAX_SIDE >= 667 ? 1 : 0.8)
#endif

#ifndef CELL_HEIGHT
#define CELL_HEIGHT (40.0f)
#endif


@interface ExpandTableView() {
    UITableView *expandTableView;
    NSString *strTitle;
    NSInteger numberOfRows;
    
    CGRect viewFrame;
    UIView *coverView;
}


@end

@implementation ExpandTableView
@synthesize index;
@synthesize isExpand;
@synthesize strArray;
@synthesize isShowSelected;
@synthesize selectedIndexPath;

- (instancetype)initWithFrame:(CGRect)frame Index:(NSInteger)_index NumberOfRow:(NSInteger)rows StrArray:(NSMutableArray *)array
{
    self = [super init];
    if(self) {
        index = _index;
        numberOfRows = rows;
        strArray = array;
        if(frame.size.height < numberOfRows * SCREEN_SCALE * SCREEN_SCALE)
        {
            frame.size.height = numberOfRows * SCREEN_SCALE * SCREEN_SCALE;
        }
        viewFrame = frame;
        isShowSelected = YES;
    }
    return self;
}

- (void)updateTableView:(CGRect)frame numberOfRow:(NSInteger)rows strArray:(NSMutableArray *)array{
    numberOfRows = rows;
    strArray = array;
    if(frame.size.height < numberOfRows * SCREEN_SCALE * SCREEN_SCALE)
    {
        frame.size.height = numberOfRows * SCREEN_SCALE * SCREEN_SCALE;
    }
    viewFrame = frame;
    isShowSelected = YES;
    [self.view setFrame:viewFrame];
    [expandTableView setFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    [coverView setFrame:expandTableView.bounds];
    [expandTableView reloadData];
    
}

- (void)viewDidLoad
{
    //    [self.view setBackgroundColor:[UIColor clearColor]];
    self.view.frame = viewFrame;
    
    expandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height) style:UITableViewStylePlain];
    [expandTableView setScrollEnabled:NO];
    [expandTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [expandTableView setBackgroundColor:[UIColor clearColor]];
    
    expandTableView.delegate = self;
    expandTableView.dataSource = self;
    
    coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    [coverView setBackgroundColor:[UIColor darkGrayColor]];
    [coverView setAlpha:0.6];
    [self.view addSubview:coverView];
    
    [self.view addSubview:expandTableView];
}

- (void)setSelectedIndexPath:(NSIndexPath *)_selectedIndexPath
{
    if(_selectedIndexPath == nil) {
        _selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    selectedIndexPath = _selectedIndexPath;
    UITableViewCell *cell = (UITableViewCell *)[expandTableView cellForRowAtIndexPath:selectedIndexPath];
    if(isShowSelected) {
        [cell.textLabel setTextColor:[UIColor blueColor]];
    }
}

- (void)setSelectedIndexPathFromNumber:(NSInteger)selectedRow
{
    selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[expandTableView cellForRowAtIndexPath:selectedIndexPath];
    if(isShowSelected) {
        [cell.textLabel setTextColor:[UIColor blueColor]];
    }
}

- (void)reloadData {
    [expandTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return SCREEN_SCALE * SCREEN_SCALE;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellWithIdentifier];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [strArray objectAtIndex:row];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f* SCREEN_SCALE]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setTextColor:[UIColor blueColor]];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(indexPath != selectedIndexPath) {
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *deselectedCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:selectedIndexPath];
    [deselectedCell.textLabel setTextColor:[UIColor whiteColor]];
    
    NSInteger row = [indexPath row];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setTextColor:[UIColor blueColor]];
    selectedIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if(!isShowSelected) {
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    [self.delegate tableViewIndex:index didSelectRowAtTow:row];
    
    //    [cell setSelected:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(!isShowSelected) {
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
}

@end
