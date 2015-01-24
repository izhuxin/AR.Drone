//
//  ViewController.m
//  AR.Drone2.0
//
//  Created by Jeason on 14-9-28.
//  Copyright (c) 2014年 Jeason. All rights reserved.
//
//
#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIKit.h>
#import "ProtocolInterpreter.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(strong, nonatomic) UIImagePickerController *takePhotoPicker;
@property(strong, nonatomic) UIImagePickerController *takeVideoPicker;
@property(strong, nonatomic) ProtocolInterpreter *listen;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    cameraBtn.frame = CGRectMake(100, 50, 88, 88);
    [cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    [cameraBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(onClickOpenCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    albumBtn.frame = CGRectMake(100, 150, 88, 88);
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    [albumBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(onClickOpenAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    videoBtn.frame = CGRectMake(100, 250, 88, 88);
    [videoBtn setTitle:@"录像" forState:UIControlStateNormal];
    [videoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(onClickOpenVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoBtn];
    
    //    //Auto control
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.listen = nil;

}

// 录像
-(void)onClickOpenVideo: (id)sender {
    if ([self isRearCameraAvailable]) {
        if (_takeVideoPicker == nil) {
            _takeVideoPicker = [[UIImagePickerController alloc] init];
            _takeVideoPicker.delegate = self;
            _takeVideoPicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            _takeVideoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _takeVideoPicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _takeVideoPicker.showsCameraControls = NO;
            //            _takeVideoPicker.videoMaximumDuration = 15.0f;
            _takeVideoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        }
        
        [self presentViewController:self.takeVideoPicker animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(startTakingVideo:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

// 相册
-(void)onClickOpenAlbum: (id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie, nil];
    //    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:^(){}];
}

// 相机
-(void)onClickOpenCamera: (id)sender {
    if ([self isRearCameraAvailable]) {
        if (_takePhotoPicker == nil) {
            _takePhotoPicker = [[UIImagePickerController alloc] init];
            _takePhotoPicker.delegate = self;
            _takePhotoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _takePhotoPicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _takePhotoPicker.showsCameraControls = NO;
        }
        
        [self presentViewController:self.takePhotoPicker animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(takePhoto:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

// 拍照
-(void)takePhoto: (id)sender {
    [self.takePhotoPicker takePicture];
}

// 开始录制视频
-(void)startTakingVideo: (id)sender {
    [self.takeVideoPicker startVideoCapture];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopTakingVideo:) userInfo:nil repeats:NO];
}

// 结束录制
-(void)stopTakingVideo: (id)sender {
    [self.takeVideoPicker stopVideoCapture];
}

// 判断后置摄像头是否可用
-(bool)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// 保存照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (CFStringCompare ((CFStringRef)mediaType, kUTTypeImage, 0)
            == kCFCompareEqualTo) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        if (CFStringCompare ((CFStringRef)mediaType, kUTTypeMovie, 0)
            == kCFCompareEqualTo) {
            NSURL *movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString *moviePath = [movieURL path];
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
            }
        }
    } else {
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// 点击取消
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

@end
