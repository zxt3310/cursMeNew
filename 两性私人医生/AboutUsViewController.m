//
//  AboutUsViewController.m
//  私密健康医生
//
//  Created by 张信涛 on 2017/4/19.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import "AboutUsViewController.h"
#import "CMemulateLocationPageController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们";
    
    NSDictionary *appInfoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [appInfoDic objectForKey:@"CFBundleShortVersionString"];
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 36*SCREEN_WIDTH/375,
                                                                          42 *SCREEN_HEIGHT/667,
                                                                          72 *SCREEN_WIDTH/375,
                                                                          72 *SCREEN_HEIGHT/667)];
    logoView.image = [UIImage imageNamed:@"man.png"];
    [self.view addSubview:logoView];
    
    UILabel *logoLb = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                127 *SCREEN_HEIGHT/667,
                                                                SCREEN_WIDTH,
                                                                20)];
    logoLb.textAlignment = NSTextAlignmentCenter;
    logoLb.text = @"私密健康医生";
    logoLb.textColor = UIColorFromHex(0xd0ccd1, 1);
    logoLb.font = [UIFont systemFontOfSize:20 weight:16];
    [self.view addSubview:logoLb];
    
    UITextView *adviceUV = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                        202 *SCREEN_HEIGHT/667,
                                                                        SCREEN_WIDTH,
                                                                        114 *SCREEN_HEIGHT/667)];
    adviceUV.text = @"世界很美好，需要健康的体魄去探寻。\n\n有诗有远方，我们更需要有健康的身体。\n\n私人医生，为您提供贴心服务。";
    adviceUV.editable = NO;
    adviceUV.font = [UIFont fontWithName:@"PingFangSC-Thin" size:15 ];
    adviceUV.textColor = UIColorFromHex(0x343434, 1);
    adviceUV.textAlignment = NSTextAlignmentCenter;
    adviceUV.backgroundColor = [UIColor clearColor];
    adviceUV.layer.borderWidth = 0;
    [self.view addSubview:adviceUV];
    
    UITextView *copyRight = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                         526* SCREEN_HEIGHT/667 ,
                                                                         SCREEN_WIDTH,
                                                                         54 *SCREEN_HEIGHT/667)];
    copyRight.text = [NSString stringWithFormat:@"V %@\nICP备12009104号-2.\n北京天亚科创科技有限公司",app_version];
    copyRight.editable = NO;
    copyRight.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    copyRight.textColor = UIColorFromHex(0x343434, 1);
    copyRight.textAlignment = NSTextAlignmentCenter;
    copyRight.backgroundColor = [UIColor clearColor];
    copyRight.layer.borderWidth = 0;
    [self.view addSubview:copyRight];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    gesture.numberOfTapsRequired = 6;
    [self.view addGestureRecognizer:gesture];
}

- (void)tapAction{
    CMemulateLocationPageController *emulate = [[CMemulateLocationPageController alloc] init];
    [self.navigationController pushViewController:emulate animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
