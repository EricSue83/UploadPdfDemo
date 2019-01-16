//
//  ViewController.m
//  UploadPdfDemo
//
//  Created by eric sue on 2019/1/15.
//  Copyright © 2019 eric sue. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import "AFNetworking.h"
#import "ESFileManager.h"

@interface ViewController ()<UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate> {
    
}

@property (nonatomic, strong) AFHTTPSessionManager* sessionManager;

@property (nonatomic, strong) UIDocumentPickerViewController* documentPickerVC;
@property (nonatomic, strong) UIDocumentInteractionController* documentInteractionC;

@property (nonatomic, strong) AppDelegate* appDel;
@property (nonatomic, strong) UIAlertController *alertCtrl;     
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *openBtn = [[UIButton alloc] init];
    openBtn.frame = CGRectMake(100, 100, 150, 40);
    openBtn.backgroundColor = [UIColor redColor];
    [openBtn setTitle:@"open文件" forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openDocumentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
    UIButton *uploadBtn = [[UIButton alloc] init];
    uploadBtn.frame = CGRectMake(100, 200, 150, 40);
    uploadBtn.backgroundColor = [UIColor redColor];
    [uploadBtn setTitle:@"upload other" forState:UIControlStateNormal];
    [uploadBtn addTarget:self action:@selector(uploadOtherAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadBtn];
}

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        //设置请求超时时间
        _sessionManager.requestSerializer.timeoutInterval = 45.f;
        //设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    }
    return _sessionManager;
}

- (UIDocumentPickerViewController *)documentPickerVC {
    if (!_documentPickerVC) {
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content",@"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"] inMode:UIDocumentPickerModeOpen];
        _documentPickerVC.delegate = self;
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet; //设置模态弹出方式
    }
    return _documentPickerVC;
}

- (UIDocumentInteractionController *)documentInteractionC {
    if (!_documentInteractionC) {
        self.documentInteractionC = [[UIDocumentInteractionController alloc] init];
        _documentInteractionC.delegate = self;
    }
    return _documentInteractionC;
}

- (AppDelegate *)appDel {
    if (!_appDel) {
        self.appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return _appDel;
}

- (void)openDocumentAction:(UIButton *)sender {
    //文件选取，浏览
    [self presentViewController:self.documentPickerVC animated:YES completion:nil];
}

- (void)uploadOtherAction:(UIButton*)sender {
    NSString* filePath = [self.appDel.fileUrl absoluteString];
    if (![filePath hasPrefix:@"file:///private"]) {
        filePath = [NSString stringWithFormat:@"file:///private%@",filePath];
    }
    NSURL* fileUrl = [[NSURL alloc] initWithString:filePath];
    [self upload:fileUrl];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        NSURL* localUrl = [[ESFileManager shareInstance] copyFileToLocalFrom:urls.firstObject];
        NSString* filePath = [localUrl absoluteString];
        if (![filePath hasPrefix:@"file:///private"]) {
            filePath = [NSString stringWithFormat:@"file:///private%@",filePath];
        }
        NSURL* fileUrl = [[NSURL alloc] initWithString:filePath];
        [self upload:fileUrl];
//        [self upload:urls.firstObject];
    }
    else {
        //授权失败
        dispatch_async(dispatch_get_main_queue(), ^{
            self.alertCtrl.message = @"授权失败";
            [self presentViewController:self.alertCtrl animated:YES completion:nil];
        });
    }
}

- (void) upload:(NSURL *)url{
    //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    
    [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        [self dismissViewControllerAnimated:YES completion:nil];
        //读取文件
        NSString *fileName = [newURL lastPathComponent];
        NSError *error = nil;
        NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            //读取出错
            dispatch_async(dispatch_get_main_queue(), ^{
                self.alertCtrl.message = @"读取出错";
                [self presentViewController:self.alertCtrl animated:YES completion:nil];
            });
        } else {
            //文件 上传或者其它操作
            //[self uploadingWithFileData:fileData fileName:fileName fileURL:newURL];
            NSLog(@"------------->文件 上传或者其它操作");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //预览文件
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"文件 上传成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"预览" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self previewFileWithURL:url];
                }] ;
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
//                [self previewFileWithURL:url];
            });
        }
    }];
    [url stopAccessingSecurityScopedResource];
}

/**
 预览文件
 
 @param url 文件路径
 */
- (void)previewFileWithURL:(NSURL *)url {
    if ([url isFileURL]) {
        if ([[[NSFileManager alloc] init] fileExistsAtPath:url.path]) {
            //指定预览文件的URL
            self.documentInteractionC.URL = url;
            //弹出预览文件窗口
            [self.documentInteractionC presentPreviewAnimated:YES];
        }
        else {
            NSLog(@"文件不存在");
//            self.alertCtrl.message = @"文件不存在";
//            [self presentViewController:self.alertCtrl animated:YES completion:nil];
        }
        
    }
    else {
        NSLog(@"文件地址错误");
//        self.alertCtrl.message = @"文件地址错误";
//        [self presentViewController:self.alertCtrl animated:YES completion:nil];
    }
         
}

#pragma mark - UIDocumentInteractionControllerDelegate
//返回一个视图控制器，代表在此视图控制器弹出
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
//返回一个视图，将此视图作为父视图
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}
//返回一个CGRect，做为预览文件窗口的坐标和大小
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.frame;
}

#pragma mark - Accessor
- (UIAlertController *)alertCtrl {
    if (!_alertCtrl) {
        _alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }] ;
        [_alertCtrl addAction:action];
    }
    return _alertCtrl;
}

@end
