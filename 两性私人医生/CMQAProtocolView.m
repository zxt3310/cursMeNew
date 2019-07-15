//
//  CMQAProtocolView.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/12.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "CMQAProtocolView.h"

@implementation CMQAProtocolView{
    UIView *protocolView;
}
@synthesize protcolViewFrame = _protcolViewFrame;

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        UIView *protocolView = [[UIView alloc] initWithFrame:CGRectMake(35*SCREEN_WIDTH/375, 110 *SCREEN_HEIGHT/667, 306 *SCREEN_WIDTH/375, 362*SCREEN_HEIGHT/667)];
        protocolView.backgroundColor = [UIColor whiteColor];
        protocolView.layer.cornerRadius = 10;
        
        UILabel *titleLb = [[UILabel alloc] initWithFrame:CGRectMake(117*SCREEN_WIDTH/375, 8, 75 *SCREEN_WIDTH/375, 20)];
        titleLb.font = [UIFont systemFontOfSize:18];
        titleLb.text = @"用户协议";
        titleLb.textColor = UIColorFromHex(0xd0021b, 0.8);
        [protocolView addSubview:titleLb];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(270 *SCREEN_WIDTH/375, 10, 15, 15);
        [cancelBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_del" ofType:@"png" inDirectory:@"images"]] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [protocolView addSubview:cancelBtn];
        
        UILabel *lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, protocolView.frame.size.width, 1)];
        lineLb.layer.borderWidth = 1;
        lineLb.layer.borderColor = UIColorFromHex(0xdbdbdb, 1).CGColor;
        [protocolView addSubview:lineLb];
        
        UIWebView *Web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 38, protocolView.frame.size.width, 275* SCREEN_HEIGHT/667)];
        [protocolView addSubview:Web];
        
        NSString* path=[[NSBundle mainBundle] pathForResource:@"protocol" ofType:@".html"];
        NSURL* url=[NSURL fileURLWithPath:path];
        [Web loadRequest:[NSURLRequest requestWithURL:url]];
        
        UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeBtn.frame = CGRectMake(81 *SCREEN_WIDTH/375, 320*SCREEN_HEIGHT/667, 150*SCREEN_WIDTH/375, 33);
        [agreeBtn setTitle:@"同意并立即咨询" forState:UIControlStateNormal];
        [agreeBtn setBackgroundColor:titleLb.textColor];
        agreeBtn.titleLabel.textColor = [UIColor whiteColor];
        agreeBtn.layer.cornerRadius = 10;
        [agreeBtn addTarget:self action:@selector(agreeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [protocolView addSubview:agreeBtn];
        
        [self addSubview:protocolView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleBtnClick)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (CGRect)protcolViewFrame{
    return _protcolViewFrame;
}

- (void)setProtcolViewFrame:(CGRect)protcolViewFrame{
    _protcolViewFrame = protcolViewFrame;
    protocolView.frame = _protcolViewFrame;
}

- (void)cancleBtnClick{
    [self removeFromSuperview];
}
- (void)agreeBtnClick{
    [UIView animateWithDuration:0.3 animations:^{
    
        self.alpha = 0;
    
    } completion:^(BOOL finished){
        if (finished) {
            NSNumber *hasAgreeProtocol = [NSNumber numberWithInt:1];
            [[NSUserDefaults standardUserDefaults] setObject:hasAgreeProtocol forKey:HAS_AGREEPROTOCOL];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (_CmLocationDelegate) {
                [_CmLocationDelegate pushNewQuary:_office1 and:_office2];
            }
            _CmLocationDelegate = nil;
            [self cancleBtnClick];
        }
    }];
}
@end
