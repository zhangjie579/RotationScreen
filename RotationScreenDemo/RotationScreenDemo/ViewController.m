//
//  ViewController.m
//  RotationScreenDemo
//
//  Created by 张杰 on 2017/1/8.
//  Copyright © 2017年 张杰. All rights reserved.
//
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

#import "ViewController.h"
#import "ZJViewController.h"

@interface ViewController ()<UINavigationControllerDelegate>

@property(nonatomic,strong)UIView  *contentView;
@property(nonatomic,strong)UIButton *btn_landspace;//横屏
@property(nonatomic,strong)UIButton *btn_Portrait;//竖屏
@property(nonatomic,strong)UIButton *btn_change;//转屏
@property(nonatomic,strong)UIButton *btn_push;//去下一个页面

/** 是否为全屏 */
@property(nonatomic,assign)BOOL     isFullScreen;
@end

@implementation ViewController

#warning 注意，一个大小，还有全屏的时候，系统会默认把状态栏隐藏，so要显示的时候，可以自己去设置
- (void)test
{
    //1.屏幕的中心，不管横屏还是竖屏
    CGPoint center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    
    //2.如果view的大小为全屏的时候,需要把屏幕的宽高调换下位置
    UIView *contentView;
    //竖屏时候的设置
    contentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //横屏时候的设置
    contentView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    //3.显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    //监听状态栏的改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    [self.view addSubview:self.btn_push];
    
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.btn_change];
    [self.contentView addSubview:self.btn_landspace];
    [self.contentView addSubview:self.btn_Portrait];
    
    
    [self setupFrameWithSubviewsIsLandSpace:NO w:[UIScreen mainScreen].bounds.size.width h:230];
}

#warning 千万要写这个不然状态栏不能旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [UIApplication sharedApplication].statusBarHidden = YES;
}

//转屏
- (void)changeScreen
{
    if (!self.isFullScreen)//改为横屏
    {
        [self changeToLandspace];
    }
    else
    {
        [self changeToPortrait];
    }
}

//竖屏
- (void)changeToPortrait
{
    self.isFullScreen = NO;
    
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

//横屏
- (void)changeToLandspace
{
    self.isFullScreen = YES;
    
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}


/**
 设置子控件的frame

 @param isLandSpace 是否为横屏
 @param w contentView的宽
 @param h contentView的高
 */
- (void)setupFrameWithSubviewsIsLandSpace:(BOOL)isLandSpace w:(CGFloat)w h:(CGFloat)h
{
    self.isFullScreen = isLandSpace;
    
    //按钮的宽高
    CGFloat btnW = 80;
    
    if (isLandSpace)//横屏
    {
        self.contentView.frame = CGRectMake(0, 0, w, h);
        
#warning 注意:发现个问题，不管横屏还是竖屏，self.contentView的宽度是不变的不是我们想要的屏幕高度，so横屏的时候求centenY，lineW将宽高调换了
        NSLog(@"frame   %@",NSStringFromCGRect(self.contentView.frame));
        
        CGFloat centenY = self.contentView.frame.size.width / 2;
        
        //按钮间的间隙
        CGFloat lineW = (self.contentView.frame.size.height - btnW * 3) / 4;
        
        self.btn_change.frame = CGRectMake(lineW, centenY - btnW / 2, btnW, btnW);
        
        self.btn_Portrait.frame = CGRectMake(lineW * 2 + btnW, centenY - btnW / 2, btnW, btnW);
        
        self.btn_landspace.frame = CGRectMake(lineW * 3 + btnW * 2, centenY - btnW / 2, btnW, btnW);
    }
    else
    {
        self.contentView.frame = CGRectMake(0, 0, w, h);
        
        CGFloat centenY = self.contentView.frame.size.height / 2;
        
        //按钮间的间隙
        CGFloat lineW = (self.contentView.frame.size.width - btnW * 3) / 4;
        
        self.btn_change.frame = CGRectMake(lineW, centenY - btnW / 2, btnW, btnW);
        
        self.btn_Portrait.frame = CGRectMake(lineW * 2 + btnW, centenY - btnW / 2, btnW, btnW);
        
        self.btn_landspace.frame = CGRectMake(lineW * 3 + btnW * 2, centenY - btnW / 2, btnW, btnW);
    }
    
}

#pragma mark - 转屏

- (void)toOrientation:(UIInterfaceOrientation)orientation
{
    // 获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }
    
    // 根据要旋转的方向,使用Masonry重新修改限制
    if (orientation != UIInterfaceOrientationPortrait)//旋转为全屏
    {
        // 这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
        if (currentOrientation == UIInterfaceOrientationPortrait)
        {
//            self.contentView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
//            self.contentView.center = [UIApplication sharedApplication].keyWindow.center;
        }
    }
    
    // iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.contentView.transform = CGAffineTransformIdentity;
    self.contentView.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
    [self.contentView layoutIfNeeded];
    [self.contentView setNeedsLayout];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle
{
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    //注意：转屏后屏幕的高度和宽度不变，so设置的时候要留意
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        
        [self toOrientation:orientation];
        
        [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
        
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        
        [self toOrientation:UIInterfaceOrientationPortrait];
        
        
        [self setupFrameWithSubviewsIsLandSpace:NO w:ScreenWidth h:230];
    }
}

/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        return;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown )
        return;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            if (self.isFullScreen)
            {
                [self toOrientation:UIInterfaceOrientationPortrait];
                
                [self setupFrameWithSubviewsIsLandSpace:NO w:ScreenWidth h:230];
                
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            if (self.isFullScreen == NO)
            {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
                self.isFullScreen = YES;
                
                [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
            }
            else
            {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
                
                [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
            }
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            if (self.isFullScreen == NO)
            {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
                self.isFullScreen = YES;
                
                [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
            }
            else
            {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
                
                [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
            }
        }
            break;
        default:
            break;
    }
}

// 状态条变化通知（在前台播放才去处理）
- (void)onStatusBarOrientationChange
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        // 获取到当前状态条的方向
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (currentOrientation == UIInterfaceOrientationPortrait)
        {
            [self toOrientation:UIInterfaceOrientationPortrait];
            
            [self setupFrameWithSubviewsIsLandSpace:NO w:ScreenWidth h:230];
        }
        else
        {
            if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            } else if (currentOrientation == UIDeviceOrientationLandscapeLeft){
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
            
            [self setupFrameWithSubviewsIsLandSpace:YES w:ScreenHeight h:ScreenWidth];
        }
    }
}

#pragma mark -隐藏导航栏
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)pushToOther
{
    ZJViewController *vc = [[ZJViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return _contentView;
}

- (UIButton *)btn_change
{
    if (!_btn_change) {
        _btn_change = [[UIButton alloc] init];
        [_btn_change setTitle:@"转屏" forState:UIControlStateNormal];
        [_btn_change addTarget:self action:@selector(changeScreen) forControlEvents:UIControlEventTouchUpInside];
        _btn_change.backgroundColor = [UIColor redColor];
        _btn_change.tag = 1;
    }
    return _btn_change;
}

- (UIButton *)btn_Portrait
{
    if (!_btn_Portrait) {
        _btn_Portrait = [[UIButton alloc] init];
        [_btn_Portrait setTitle:@"竖屏" forState:UIControlStateNormal];
        [_btn_Portrait addTarget:self action:@selector(changeToPortrait) forControlEvents:UIControlEventTouchUpInside];
        _btn_Portrait.backgroundColor = [UIColor blueColor];
    }
    return _btn_Portrait;
}

- (UIButton *)btn_landspace
{
    if (!_btn_landspace) {
        _btn_landspace = [[UIButton alloc] init];
        [_btn_landspace setTitle:@"横屏" forState:UIControlStateNormal];
        [_btn_landspace addTarget:self action:@selector(changeToLandspace) forControlEvents:UIControlEventTouchUpInside];
        _btn_landspace.backgroundColor = [UIColor greenColor];
    }
    return _btn_landspace;
}

- (UIButton *)btn_push
{
    if (!_btn_push) {
        _btn_push = [[UIButton alloc] init];
        [_btn_push setTitle:@"去下一个页面" forState:UIControlStateNormal];
        [_btn_push addTarget:self action:@selector(pushToOther) forControlEvents:UIControlEventTouchUpInside];
        _btn_push.backgroundColor = [UIColor orangeColor];
        _btn_push.frame = CGRectMake(100, 300, 70, 70);
    }
    return _btn_push;
}


@end
