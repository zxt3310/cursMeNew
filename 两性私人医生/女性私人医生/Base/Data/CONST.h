
//
//  Header.h
//  私密健康医生
//
//  Created by Tim on 13-1-10.
//  Copyright (c) 2013年 Tim. All rights reserved.
//

#ifndef _______Header_h
#define _______Header_h

#define CLASS_NUMBER @"NSNumber"
#define CLASS_STRING @"NSString"
#define CLASS_DICTIONARY @"NSDictionary"
#define CLASS_ARRAY @"NSArray"

//*********************咨询列表相关常量***********************
// 咨询列表，TableView的头部高度
#define QATABLEVIEW_HEADERCELL_HEIGHT 50
// 咨询项，Question内容最小高度
#define QATABLEVIEW_Q_MINHEIGHT 47
// 咨询项，Answer内容最小高度
#define QATABLEVIEW_A_MINHEIGHT 66

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define NAVIGATIONBAR_HEIGHT (IOS_VERSION >= 7.0 ? 44 : 0)
#define FitIpX(a) ((SCREEN_HEIGHT/SCREEN_WIDTH >= 2)? a+20 : a)

// 颜色
#define CM_BACKGROUND_COLOR [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0]
#define CM_BACKGROUND_GRAYCOLOR [UIColor colorWithRed:228.0/255 green:228.0/255 blue:228.0/255 alpha:1.0]
#define CM_BACKGROUND_RED [UIColor colorWithRed:249.0/255 green:80.0/255 blue:118.0/255 alpha:1.0]

#define UIColorFromHex(s,a)  [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:a]

#define APPLE_APPID @"566849177"
//*********************定义App中埋点Event******************************
// 主界面定位按钮点击
#define MAINPAGE_LOCATEBTN @"MainpageLocationButton"
#define MAINPAGE_CHANGELOCATIONBTN @"MainpageChangeLocation"

#define MEDAPP_MAINDOMAIN @"http://new.medapp.ranknowcn.com"
#define MEDAPP_MAINPAGE   @"http://new.medapp.ranknowcn.com/h5_new/index.html"

// 接收Push统计
#define PUSH_OPEN_CHAT @"PushOpenChat"
#define PUSH_OPEN_CHATLIST @"PushOpenChatList"
#define PUSH_OPEN_BOOK @"PushOpenBook"
#define PUSH_OPEN_BOOKLIST @"PushOpenBookList"
#define PUSH_OPEN_HUODONG @"PushOpenHuodong"
#define PUSH_OPEN_HUODONGLIST @"PushOpenHuodongList"
#define PUSH_OPEN_URL @"PushOpenURL"

// 咨询列表页面
#define QUERY_MAINTYPE_SEL @"QueryMainTypeSelect"
#define QUERY_MAINTYPE_DISPINTERVAL @"QueryMainTypeDispInterval"
#define QUERY_SUBTYPE_CLICK @"QuerySubTypeClick"
#define QUERY_SUBTYPE_DISPINTERVAL @"QuerySubTypeDispInterval"

#endif
