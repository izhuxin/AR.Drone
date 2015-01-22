//
//  ViewController.m
//  AR.Drone2.0
//
//  Created by Jeason on 14-9-28.
//  Copyright (c) 2014年 Jeason. All rights reserved.
//

#import "ViewController.h"
#import "ProtocolInterpreter.h"

@interface ViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) ProtocolInterpreter *listen;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Auto control
    self.listen = [[ProtocolInterpreter alloc] init];
    [_listen start];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_listen == nil) {
        self.listen = [[ProtocolInterpreter alloc] init];
        [_listen start];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.listen = nil;
}
@end
