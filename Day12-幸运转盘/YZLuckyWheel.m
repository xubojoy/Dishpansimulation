//
//  YZLuckyWheel.m
//  Day12-幸运转盘
//
//  Created by Yin jianxun on 16/6/22.
//  Copyright © 2016年 Yin jianxun. All rights reserved.
//

#import "YZLuckyWheel.h"
#import "YZButton.h"

#define kBtnNum 12

@interface YZLuckyWheel ()<UIAlertViewDelegate>

//转轮上的wheel
@property (weak, nonatomic) IBOutlet UIImageView *luckyWheel;

//按钮的集合
@property (nonatomic,strong) NSMutableArray *btnsArray;

//记录选中状态的 按钮
@property (nonatomic,weak) YZButton *selectedBtn;

//link
@property (weak, nonatomic)  CADisplayLink *link;

@end


@implementation YZLuckyWheel

#pragma mark - 动画停止时，弹出提示框
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"幸运号码" message:@"1,6,8" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //删除核心动画
    [self.luckyWheel.layer removeAnimationForKey:@"luck"];
    
    
    //1.让转盘转到 真实的位置
    CGFloat angle = 2 * M_PI /12  * self.selectedBtn.tag;
    
    angle = 10 * M_PI - angle;
    
    self.luckyWheel.transform = CGAffineTransformMakeRotation(angle);
    
    
    //2.恢复旋转
    self.link.paused = NO;
    
    
    
}


#pragma mark - 开始选号，监听按钮的响应事件
- (IBAction)startSelectAction:(UIButton *)sender {
    
    //为了避免 多次点击选号按钮时重复出现提示框
    //需要进行当前的核心动画是否存在
    if ([self.luckyWheel.layer animationForKey:@"luck"]) {
        return;
    }
    
    self.link.paused = YES;
    
    [self basicAnimation];
    
}


//核心动画
- (void)basicAnimation{
    
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
//    basic.toValue = @(10 * M_PI);
//    basic.duration = 40;
//    basic.repeatCount = CGFLOAT_MAX;
//    
//    [self.luckyWheel.layer addAnimation:basic forKey:@"luck"];
    
    //每次转动完毕就让选中的按钮停止到12 点钟方向
    CGFloat angle = 2 * M_PI /12  * self.selectedBtn.tag;
    angle = 10 * M_PI - angle;
    
    //2.设置属性
    basic.toValue = @(angle);
    basic.duration = 2;
    
    //时间函数 速度函数
    basic.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //让动画 停止不返回
    basic.removedOnCompletion = NO;
    basic.fillMode = kCAFillModeForwards;
    
    
    //设置代理
    basic.delegate = self;
    
    //3.添加动画
    [self.luckyWheel.layer addAnimation:basic forKey:@"luck"];
    
    
}

#pragma mark - 一进入界面，自动开始转动
- (void)start{
    
    //创建link
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(move)];
    
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

//转动速率
- (void)move{
    
    self.luckyWheel.transform = CGAffineTransformRotate(self.luckyWheel.transform, M_PI_4 * 0.01);
    
}



//添加的按钮的监听事件
- (void)clickBtn:(YZButton *)sender{
    
    //将之前的选中按钮的状态改变
    self.selectedBtn.selected = NO;
    
    //将按钮的状态变成 选中状态
    sender.selected = YES;
    
    //将现在选中的按钮赋值给 选中标识
    self.selectedBtn = sender;
    
}

#pragma mark - 懒加载 创建按钮

-(NSMutableArray *)btnsArray{
    
    if (!_btnsArray) {
        
        //开辟空间!!!!!!!
        _btnsArray = [NSMutableArray array];
        
        //创建12个按钮
        for (NSInteger i = 0 ; i < kBtnNum ; i++) {
            
            YZButton *btn = [[YZButton alloc]init];
//            btn.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0];
            
            //设置tag 为了计算当前选中按钮的角度
            btn.tag = i;
            
            //设置选中状态的背景图片
            [btn setBackgroundImage:[UIImage imageNamed:@"LuckyRototeSelected"] forState:UIControlStateSelected];
            
#pragma mark - 裁剪图片
            //设置normal状态图片
            UIImage *normalImage = [self clipImage:@"LuckyAstrology" withIndex:i];
            [btn setImage:normalImage forState:UIControlStateNormal];
            
            //设置选中状态下的按钮图片
            UIImage *selectedImage = [self clipImage:@"LuckyAstrologyPressed" withIndex:i];
            [btn setImage:selectedImage forState:UIControlStateSelected];
            
            //监听按钮的点击事件
            [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            //改变按钮的锚点
            btn.layer.anchorPoint = CGPointMake(0.5, 1.0);
            
            
//            btn.center = self.luckyWheel.center;
//            btn.bounds = CGRectMake(0, 0, 100, 100);---->layoutSubViews中设置
            
            [self.luckyWheel addSubview:btn];
            
            [_btnsArray addObject:btn];
            
        }
    }
    
    
    return _btnsArray;
}

#pragma mark - 裁剪图片的方法 <---抽成方法

- (UIImage *)clipImage:(NSString *)imageName withIndex:(NSInteger)index{
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    //裁剪位置的计算
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat imageW = image.size.width / 12 * scale;
    CGFloat imageH = image.size.height * scale;
    CGFloat imageX = imageW * index;
    CGFloat imageY = 0;
    
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(imageX, imageY, imageW, imageH));
    
    //裁剪后图片转化
    UIImage *clipImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return clipImage;
}


-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    /**
     wheel图片 高286 宽286 -->像素
     每个按钮的图片 宽132 高286  -->像素
     添加的按钮 宽：132/2 = 66  -->点位
               高:286/2 = 143  -->点位
     */
    
    CGFloat btnW = 66;
    CGFloat btnH = 143;
    
    [self.btnsArray enumerateObjectsUsingBlock:^(YZButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        btn.frame = CGRectMake(self.luckyWheel.center.x * 0.5, self.luckyWheel.center.y * 0.5, btnW, btnH);
        
        btn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        
        btn.bounds = CGRectMake(0, 0, btnW, btnH);
        
        //修改角度
        //一个园别分成12分 对应于相应的按钮
        CGFloat angle = (2 * M_PI) / 12 * idx;
        btn.transform = CGAffineTransformMakeRotation(angle);
//        btn.transform = CGAffineTransformRotate(btn.transform, angle);
        
    }];
    
}


#pragma mark - 加载XIB
//加载XIB文件 通过XIB文件名进行加载

+ (instancetype)loadWheelXib{
    
    return [[[NSBundle mainBundle]loadNibNamed:@"YZLuckyWheel" owner:nil options:nil]lastObject];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
