//
//  GuideView.m
//  莲和医疗
//
//  Created by Zxt3310 on 2016/12/12.
//  Copyright © 2016年 莲和医疗. All rights reserved.
//

#import "GuideView.h"
#import "CONST.h"

#define DEF_GUIDE_COUNT 4

@implementation GuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bounces=NO;
        self.contentSize = CGSizeMake(SCREEN_WIDTH * (DEF_GUIDE_COUNT - 1)+1, SCREEN_HEIGHT);
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.delegate=self;
        self.backgroundColor = [UIColor whiteColor];
        
        for (int i=1; i<DEF_GUIDE_COUNT; i++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*(i-1), 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
            [imageView setBackgroundColor:[UIColor whiteColor]];
            [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"引导页%d-1136.png",i]]];
            if ([UIScreen mainScreen].bounds.size.height == 960) {
                [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"引导页%d-960.png",i]]];
            }
            [self addSubview:imageView];
            if (i == DEF_GUIDE_COUNT - 1) {
                UIButton*button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT);
                button.alpha = 0.5;
                [button addTarget:self action:@selector(beginClick) forControlEvents:UIControlEventTouchUpInside];
                imageView.userInteractionEnabled = YES;
                [imageView addSubview:button];
            }
            
            UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            skipBtn.frame = CGRectMake(SCREEN_WIDTH - 85 *SCREEN_WIDTH/375,
                                       28 *SCREEN_HEIGHT/667,
                                       60 *SCREEN_WIDTH/375,
                                       42 *SCREEN_HEIGHT/667);
            [skipBtn addTarget:self action:@selector(beginClick) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:skipBtn];
        }
    }
    return self;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x>SCREEN_WIDTH*2) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}
#pragma mark - 点击事件

- (void)beginClick
{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end


