//
//  WebViewCoverView.m
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/11.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "WebViewCoverView.h"

@implementation WebViewCoverView
@synthesize btnDic = _btnDic;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromHex(0xE1E1E1, 0.9);
        
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        subView.backgroundColor = [UIColor whiteColor];
        //全部按钮
        UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        subBtn.frame = CGRectMake(0, 0, 48, 40);
        [subBtn setTitleColor:UIColorFromHex(0xdb2239, 1) forState:UIControlStateNormal];
        [subBtn setTitle:@"全部" forState:UIControlStateNormal];
        subBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13];
        subBtn.tag = 0;
        [subBtn addTarget:self action:@selector(officeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:subBtn];
        
        
        //收回按钮
        UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleBtn.frame = CGRectMake(332 *SCREEN_WIDTH/375, 14, 18, 18);
        [cancleBtn setImage:[UIImage imageNamed:@"cancleList_both"] forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [subView addSubview:cancleBtn];
        
        [self addSubview:subView];
    }
    return self;
}

- (NSDictionary *)btnDic{
    return _btnDic;
}

- (void)setBtnDic:(NSDictionary *)btnDic{
    _btnDic = btnDic;
    //绘制按钮
    if (_btnDic.count>0) {
        int i=0;
        for (NSString *key in _btnDic.allKeys) {
            UIButton *officeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            officeBtn.frame = CGRectMake(26*SCREEN_WIDTH/375 + i%3*122*SCREEN_WIDTH/375, 50*SCREEN_HEIGHT/667 + i/3*49*SCREEN_HEIGHT/667, 85*SCREEN_WIDTH/375, 29*SCREEN_HEIGHT/667);
            [officeBtn setBackgroundColor:[UIColor whiteColor]];
            [officeBtn setTitle:[_btnDic objectForKey:key] forState:UIControlStateNormal];
            officeBtn.layer.cornerRadius = 15;
            [officeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            officeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:13];
            [officeBtn addTarget:self action:@selector(officeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            officeBtn.tag = [key integerValue];
            i++;
            [self addSubview:officeBtn];
        }
    }

}

- (void)cancleBtnClick{
    if (_delegate) {
        [_delegate dismissPageAndSelectOffice:999];
    }
}

- (void)officeBtnClick:(UIButton *)sender{
    if (sender.tag == 0) {
        for (NSString *key in _btnDic.allKeys) {
            UIButton *button = (UIButton *)[self viewWithTag:[key integerValue]];
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    else{
        sender.backgroundColor = UIColorFromHex(0xdb2239, 1);
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        for (NSString *key in _btnDic.allKeys) {
            if (sender.tag == [key integerValue]) {
                continue;
            }
            UIButton *button = (UIButton*)[self viewWithTag:[key integerValue]];
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    if (_delegate) {
        [_delegate dismissPageAndSelectOffice:sender.tag];
    }
}

- (void)superSelectBtnAction:(NSInteger) tag{
    for (NSString *key in _btnDic.allKeys){
        if (key.integerValue == tag) {
            UIButton *button = (UIButton *)[self viewWithTag:tag];
            button.backgroundColor = UIColorFromHex(0xdb2239, 1);
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else{
            UIButton *button = (UIButton*)[self viewWithTag:[key integerValue]];
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}
@end
