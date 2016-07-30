//
//  JDRunLoopPhotoView.m
//  ImageRunLoop
//
//  Created by JKDP01 on 16/7/26.
//  Copyright © 2016年 BA. All rights reserved.
//

#import "JDRunLoopPhotoView.h"

@interface JDRunLoopPhotoView () <UIScrollViewDelegate>
/** 图片轮播视图的宽度 */
@property (nonatomic, assign) CGFloat viewHeight;
/** 图片轮播视图的宽度 */
@property (nonatomic, assign) CGFloat viewWidth;

/** 滚动子视图 */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 左边图片视图 */
@property (nonatomic, weak) UIImageView *leftImageView;
/** 中间显示的图片视图 */
@property (nonatomic, weak) UIImageView *centerImageView;
/** 右边图片视图 */
@property (nonatomic, weak) UIImageView *rightImageView;

/** 分页控件 */
@property (nonatomic, weak) UIPageControl *pageControl;

/** 图片数组的数量 */
@property (nonatomic, assign) NSInteger imageCount;

/** 定时器 */
@property (strong, nonatomic) NSTimer *timer;

/** 是否手动拖拽图片，判断是否要重新刷新表格 */
@property (nonatomic, assign, getter=isManual) BOOL manual;

/** 判断已经设置好内部scrollView */
@property (nonatomic, assign, getter=isBeginSetupView) BOOL beginSetupView;

/**
 *  当前显示的图片索引
 */
@property (nonatomic, assign) NSUInteger currentImageIndex;

@end

@implementation JDRunLoopPhotoView

@synthesize viewHeight, viewWidth, imageCount, currentImageIndex, durationTime;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // init code
        [self setupDefaultInfo];
    }
    
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}


#pragma mark - 外部接口方法
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (frame.size.width != 0 || frame.size.height != 0) {
        viewWidth = frame.size.width;
        viewHeight = frame.size.height;
        
        [self setupContentView];
    }
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    
    // 内部的控件还没初始化
    if (!self.isBeginSetupView) return;
    
    // 停止时钟
    [self.timer invalidate];
    self.timer = nil;
    
    imageCount = self.photos.count;
    
    // 设置分页控件
    [self setupPageControl];
    
    // 设置默认图片
    [self setupDefaultImage];
    
    // 启动定时器
    [self startTimer];
}

- (void)setDurationTime:(NSTimeInterval)time {
    durationTime = time;
    
    // 停止时钟
    [self.timer invalidate];
    self.timer = nil;
    
    // 重新启动时钟
    [self startTimer];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

#pragma mark - 私有方法
/**
 *  设置默认属性
 */
- (void)setupDefaultInfo {
    durationTime = 1.5;
    self.manual = YES;
    
    // 分页控件的颜色
    self.pageIndicatorTintColor = [UIColor redColor];
    self.currentPageIndicatorTintColor = [UIColor blackColor];
}

/**
 *  设置scrollView
 */
- (void)setupContentView {
    // 清空子视图
    [self.scrollView removeFromSuperview];
    
    /**
     * 设置scrollView
     */
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    // 设置滚动范围
    scrollView.contentSize = CGSizeMake(viewWidth * 3, viewHeight);
    // 设置当前显示的位置为中间图片
    [scrollView setContentOffset:CGPointMake(viewWidth, 0) animated:NO];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    /**
     *  左边图片视图
     */
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
//    leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:leftImageView];
    self.leftImageView = leftImageView;
    
    /**
     *  中间图片视图
     */
    UIImageView *centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, viewHeight)];
//    centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:centerImageView];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    centerImageView.userInteractionEnabled = YES;
    [centerImageView addGestureRecognizer:tap];
    
    self.centerImageView = centerImageView;
    
    /**
     *  右边图片视图
     */
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2 * viewWidth, 0, viewWidth, viewHeight)];
//    rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:rightImageView];
    self.rightImageView = rightImageView;
    
    self.beginSetupView = YES;
    
    if (self.photos.count > 0) {
        [self setPhotos:_photos];
    }
}

/**
 *  图片被点击
 */
- (void)imageTap {
    
    if (self.touchUpImage) {
        self.touchUpImage(currentImageIndex);
    }
}

/**
 *  分页控件
 */
- (void)setupPageControl {
    // 清空分页控件
    [self.pageControl removeFromSuperview];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    CGSize pageSize = [pageControl sizeForNumberOfPages:imageCount];
    pageControl.bounds = CGRectMake(0, 0, pageSize.width, pageSize.width);
    pageControl.center = CGPointMake(viewWidth / 2, viewHeight - 20);
    // 设置颜色
    pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor;
    pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
    pageControl.numberOfPages = imageCount;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

/**
 *  设置默认图片
 */
- (void)setupDefaultImage {
    self.leftImageView.image = [UIImage imageNamed:[self.photos lastObject]];
    self.centerImageView.image = [UIImage imageNamed:self.photos[0]];
    self.rightImageView.image = [UIImage imageNamed:self.photos[1]];
    
    // 设置当前页
    currentImageIndex = 0;
    self.pageControl.currentPage = currentImageIndex;
}

#pragma mark - 重新加载图片
- (void)reloadImage {
    NSUInteger leftImageIndex, rightImageIndex;
    CGPoint offset = self.scrollView.contentOffset;
    
    // 判断左右滑动
    if (offset.x > viewWidth) { // 向右滑动
        currentImageIndex = (currentImageIndex + 1) % imageCount;
    } else if (offset.x < viewWidth) { // 向左滑动
        currentImageIndex = (currentImageIndex + imageCount - 1) % imageCount;
    }
    
    // 重新设置图片
    self.centerImageView.image = [UIImage imageNamed:self.photos[self.currentImageIndex]];
    
    leftImageIndex = (self.currentImageIndex + self.imageCount - 1) % self.imageCount;
    self.leftImageView.image = [UIImage imageNamed:self.photos[leftImageIndex]];
    
    rightImageIndex = (self.currentImageIndex + 1) % self.imageCount;
    self.rightImageView.image = [UIImage imageNamed:self.photos[rightImageIndex]];
    
    // 移动到中间
    [self.scrollView setContentOffset:CGPointMake(viewWidth, 0) animated:NO];
    
    // 更新pagecontrol的页码
    self.pageControl.currentPage = self.currentImageIndex;
}

#pragma mark - scrollView的代理方法
/** 滚动完成 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.isManual) {
        // 重新加载图片
        [self reloadImage];
    }
    
    self.manual = YES;
}

/** 开始抓获scrollView */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 停止时钟
    [self.timer invalidate];
    self.timer = nil;
}

/** 结束抓获scrollView */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGPoint offset = scrollView.contentOffset;
    
    // 判断左右滑动
    if (offset.x > (viewWidth * 1.5)) { // 向右滑动
        
        self.manual = YES;
    } else if (offset.x < viewWidth / 2) { // 向左滑动
        
        self.manual = YES;
    } else {
        self.manual = NO;
    }
    
    // 启动时钟
    [self startTimer];
}

#pragma mark - 时钟方法
/** 启动时钟 */
- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:durationTime target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    // 添加到运行循环
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/** 时钟的监听方法 */
- (void)updateTimer {
    // 移动
    CGFloat x = 2 * viewWidth;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = CGPointMake(x, 0);
    } completion:^(BOOL finished) {
        
        // 重新加载图片
        [self reloadImage];
    }];
}

@end
