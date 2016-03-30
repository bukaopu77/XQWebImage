//
//  XQWebImage.m
//  FactoryCell
//
//  Created by 周剑 on 16/2/29.
//  Copyright © 2016年 bukaopu. All rights reserved.
//

#import "XQWebImage.h"
#import <CommonCrypto/CommonCrypto.h>

static XQWebImage *_manager = nil;
@implementation XQWebImage

+ (instancetype)defaultManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

#pragma mark - 类方法下载图片
+ (void)downloadImageWithUrlString:(NSString *)urlString result:(void (^)(UIImage *, NSError *))resultImage {
    XQWebImage *manager = [XQWebImage defaultManager];
//    调用对象方法下载
    [manager downloadImageWithUrlString:urlString result:^(UIImage *image, NSError *error) {
        resultImage(image, error);
    }];
}

- (void)downloadImageWithUrlString:(NSString *)urlString result:(void (^)(UIImage *, NSError *))resultImage {
    NSURL *imageUrl = [NSURL URLWithString:urlString];
    // 转换md5获取文件路径
    NSString *name = [self md5String:urlString];
    NSString *filePath = [[self caches] stringByAppendingPathComponent:name];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        resultImage(image, nil);
        return;
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"图片下载出错:%@", error);
            return ;
        }
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            NSLog(@"图片格式出错");
            return;
        }
        [data writeToFile:filePath atomically:YES];
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                resultImage(image, nil);
            });
        }
    }];
    [task resume];
    
}

// 文件路径
- (NSString *)caches {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

// 得到通用散列字符串
- (NSString *)md5String:(NSString *)str {
    unsigned char result[16];
    
    CC_MD5(str.UTF8String, (unsigned int)strlen(str.UTF8String), result);
    NSMutableString *resultStr = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [resultStr appendFormat:@"%02x",result[i]];
    }
    return resultStr;
}

@end


@implementation UIImageView (ImageUrl)

- (void)xq_setImageWithUrlString:(NSString *)urlString {
    [self xq_setImageWithUrlString:urlString placeHolderImage:nil];
}

- (void)xq_setImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)image {
    self.image = image;
    __weak UIImageView *weakImageView = self;
    [XQWebImage downloadImageWithUrlString:urlString result:^(UIImage *image, NSError *error) {
        if (error) {
            return ;
        }
        if (!image) {
            return;
        }
        weakImageView.image = image;
    }];
}

@end




