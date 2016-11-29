//
//  ViewController.m
//  Day12-幸运转盘
//
//  Created by Yin jianxun on 16/6/22.
//  Copyright © 2016年 Yin jianxun. All rights reserved.
//

#import "ViewController.h"
#import "YZLuckyWheel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置背景
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"LuckyBackground"].CGImage);
    
    //在storyBoard中设置 三个按钮
    //参照board
    
    //设置转盘 从XIB文件中加载
    YZLuckyWheel *wheelView = [YZLuckyWheel loadWheelXib];
    wheelView.center = self.view.center;
    [self.view addSubview:wheelView];
    
    //转动
    [wheelView start];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
