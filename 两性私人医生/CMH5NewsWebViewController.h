//
//  CMH5NewsWebViewController.h
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/17.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBaseViewController.h"
#import "WebViewCoverView.h"
#import "CMCustomViews.h"
#import "WebViewController.h"
#import "CMLoginViewController.h"

@interface CMH5NewsWebViewController : CustomBaseViewController <pageCoverDismissDelegate,UITableViewDelegate,UITableViewDataSource>

@property NSArray *officeTypeArray;

@end
