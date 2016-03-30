//
//  XQWebImage.h
//  FactoryCell
//
//  Created by 周剑 on 16/2/29.
//  Copyright © 2016年 bukaopu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XQWebImage : NSObject

+ (void)downloadImageWithUrlString:(NSString *)urlString result:(void(^)(UIImage *image, NSError *error))resultImage;

- (void)downloadImageWithUrlString:(NSString *)urlString result:(void(^)(UIImage *image, NSError *error))resultImage;

@end

@interface UIImageView (ImageUrl)

- (void)xq_setImageWithUrlString:(NSString *)urlString;
- (void)xq_setImageWithUrlString:(NSString *)urlString placeHolderImage:(UIImage *)image;

@end
