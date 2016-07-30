//
//  JDRunLoopPhotoView.h
//  ImageRunLoop
//
//  Created by JKDP01 on 16/7/26.
//  Copyright © 2016年 BA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^touchUpBlock)(NSInteger tapImageIndex);

@interface JDRunLoopPhotoView : UIView
/**
 *  轮播的图片名数组
 */
@property (strong, nonatomic) NSArray *photos;

/**
 *  轮播的间隔时间，默认时间是1秒
 */
@property (nonatomic, assign) NSTimeInterval durationTime;

/**
 *  分页控件的展示点圈颜色
 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

/**
 *  分页控件的当前点圈颜色
 */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

/**
 *  图片被点击的监听block，传出被点击的图片索引
 */
@property (nonatomic, copy) touchUpBlock touchUpImage;
@end
