//
//  WebViewCoverView.h
//  女性私人医生
//
//  Created by Zxt3310 on 2017/10/11.
//  Copyright © 2017年 Tim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CONST.h"

@protocol pageCoverDismissDelegate <NSObject>
- (void)dismissPageAndSelectOffice:(NSInteger)Btntag;
@end

@interface WebViewCoverView : UIView
@property NSArray *btnArray;
@property (nonatomic) NSDictionary *btnDic;
@property id<pageCoverDismissDelegate> delegate;
- (void)superSelectBtnAction:(NSInteger) tag;
@end
