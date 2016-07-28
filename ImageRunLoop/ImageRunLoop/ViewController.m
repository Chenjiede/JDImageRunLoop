//
//  ViewController.m
//  ImageRunLoop
//
//  Created by JKDP01 on 16/7/26.
//  Copyright © 2016年 BA. All rights reserved.
//

#import "ViewController.h"

#import "JDRunLoopPhotoView.h"

@interface ViewController ()

@property (nonatomic, weak) JDRunLoopPhotoView *RunLoopView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加图片轮播器
    [self setupRunLoopPhoto];

}

/**
 *  添加图片轮播器
 */
- (void)setupRunLoopPhoto {
    JDRunLoopPhotoView *runLoopView = [[JDRunLoopPhotoView alloc] initWithFrame:CGRectMake(10, 100, 400, 200)];
//    JDRunLoopPhotoView *runLoopView = [[JDRunLoopPhotoView alloc] init];
    
    // 设置图片数组
    runLoopView.photos = @[@"img_01", @"img_02", @"img_03", @"img_04", @"img_05"];
    
    // 设置间隔时间
//    runLoopView.durationTime = 2.0;
    
    // 设置分页控件的颜色
    runLoopView.currentPageIndicatorTintColor = [UIColor blueColor];
    
    // 图片被点击的监听方法
    runLoopView.touchUpImage = ^(NSInteger imageIndex) {
        NSLog(@"%ld", (long)imageIndex);
    };

//    runLoopView.frame = CGRectMake(10, 100, 400, 200);
    [self.view addSubview:runLoopView];
    self.RunLoopView = runLoopView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.RunLoopView removeFromSuperview];
}

@end
