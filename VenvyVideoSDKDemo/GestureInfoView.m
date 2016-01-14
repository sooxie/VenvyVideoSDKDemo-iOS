//
//  GestureInfoView.m
//  VenvyVideoSDKDemo
//
//  Created by Zard1096 on 16/1/14.
//  Copyright (c) 2016年 VenvyVideo. All rights reserved.
//

#import "GestureInfoView.h"

@implementation GestureInfoView

+ (GestureInfoView *)instanceGestureInfoView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"GestureInfoView" owner:nil options:nil];
    GestureInfoView *gestureInfoView = [nibViews objectAtIndex:0];
    return gestureInfoView;
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

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(removeGestureInfoView)]) {
            [self.delegate removeGestureInfoView];
        }
    }
    
}

@end
