# JDImageRunLoop
图片无限轮播器; Picture carousel device;

##一个图片视图循环利用的轮播器
  这个轮播器使用三个UIimageView，只要你设置好图片名数组，内部会实现轮播效果，也有拖拽滑动的功能
  
## 使用步骤
  1. 导入PictureCarouselDevice文件夹到项目中
  2. 导入JDRunLoopPhotoView.h头文件
  3. 事例代码 <br>
```
    JDRunLoopPhotoView *runLoopView = [[JDRunLoopPhotoView alloc] initWithFrame:CGRectMake(10, 100, 400, 200)];

    // 设置图片数组
    runLoopView.photos = 你的图片名数组;
  // 图片被点击的监听方法
    runLoopView.touchUpImage = ^(NSInteger imageIndex) { // imageIndex 是被点击时的图片在数组中的下标
        NSLog(@"%ld", (long)imageIndex);
    };
    [self.view addSubview:runLoopView];
```
