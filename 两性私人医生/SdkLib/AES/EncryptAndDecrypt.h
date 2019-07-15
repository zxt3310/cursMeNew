//
//  EncryptAndDecrypt.h
//  123
//
//  Created by qunjie.he on 13-8-27.
//  Copyright (c) 2013年 qunjie.he. All rights reserved.
//


#import <Foundation/Foundation.h>
@class NSString;

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSData *)key;   //加密
- (NSData *)AES256DecryptWithKey:(NSData *)key;   //解密
- (NSString *)newStringInBase64FromData;            //追加64编码
+ (NSString*)base64encode:(NSString*)str;           //同上64编码


@end
