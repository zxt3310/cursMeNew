//
//  ALTabBarView.m
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//

#import "ALTabBarView.h"


@implementation ALTabBarView

@synthesize delegate;
@synthesize selectedButton;
@synthesize unreadMsgCount = _unreadMsgCount;

- (void)dealloc {
    selectedButton = nil;
    delegate = nil;
}

- (id)initWithFrame:(CGRect)frame {
//    CGRect temp = frame;
//    temp.size.width = SCREEN_WIDTH;
//    frame = temp;
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

//Let the delegate know that a tab has been touched
-(IBAction) touchButton:(id)sender {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if ([button isSelected]) {
                [button setSelected:NO];
            }
        }
    }


    if( delegate != nil && [delegate respondsToSelector:@selector(tabWasSelected:)]) {
        
        if (selectedButton) {
            [selectedButton setSelected:NO];
            selectedButton = nil;
        }
        
        selectedButton = (UIButton *)sender;
        [selectedButton setSelected:YES];

        [delegate tabWasSelected:selectedButton.tag];
    }
}

-(void)selectButtonAtIndex:(NSInteger)index
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if ([button isSelected]) {
                [button setSelected:NO];
            }
        }
    }
    
    NSArray *btnArray = self.subviews;
    if (index < btnArray.count && [[btnArray objectAtIndex:index] isKindOfClass:[UIButton class]]) {
        UIButton *button = [btnArray objectAtIndex:index];
        [button setSelected:YES];
    }
}

- (void)setUnreadMsgCount:(NSInteger)unreadMsgCount
{
    _unreadMsgCount = unreadMsgCount;
    
    NSArray *btnArray = self.subviews;
    UIButton *unreadMsgBtn = nil;
    
    for (int i = 0; i < btnArray.count; i++) {
        UIButton *btn = (UIButton *)[btnArray objectAtIndex:i];
        if (btn.tag == 100) {
            unreadMsgBtn = btn;
            break;
        }
    }
    
    if (!unreadMsgBtn)
        return;

    if (_unreadMsgCount > 0) {
        [unreadMsgBtn setTitle:[NSString stringWithFormat:@"%ld", (long)unreadMsgCount] forState:UIControlStateNormal];
        [unreadMsgBtn setHidden:NO];
    }
    else {
        [unreadMsgBtn setHidden:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
