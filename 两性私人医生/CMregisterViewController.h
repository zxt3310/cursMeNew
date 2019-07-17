//
//  CMregisterViewController.h
//  女性私人医生
//
//  Created by Zxt3310 on 2017/11/1.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"

@protocol CMLoginDelegate <NSObject>
@optional
- (void)moreActionAfterLogin;
@end
@interface CMregisterViewController : CustomBaseViewController
@property id<CMLoginDelegate> cmDelegate;
@end
