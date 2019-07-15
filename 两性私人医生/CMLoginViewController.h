//
//  CMLoginViewController.h
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/20.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

#import "CMregisterViewController.h"

@interface CMLoginViewController : CustomBaseViewController <wxBackDelegate>
@property id<CMLoginDelegate> cmDelegate;
@end
