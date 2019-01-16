//
//  AppDelegate.m
//  UploadPdfDemo
//
//  Created by eric sue on 2019/1/15.
//  Copyright © 2019 eric sue. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "ESFileManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    if (url != nil) {
        NSString* urlStr = [url absoluteString];
        NSString* suffix = [urlStr substringWithRange:NSMakeRange(urlStr.length-3, 3)];
        
        NSString* msg = nil;
        
        if ([suffix isEqualToString:@"pdf"]) {
            
            //1.文件拷贝到本地沙盒
            //2.上传操作，在ViewController中手动操作了
            // 沙盒Library目录
            NSURL* localUrl = [[ESFileManager shareInstance] copyFileToLocalFrom:url];
            /*
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths lastObject];
        
            NSString *path = [url absoluteString];
            path = [path stringByRemovingPercentEncoding];
            NSMutableString *string = [[NSMutableString alloc] initWithString:path];
            if ([path hasPrefix:@"file:///private"]) {
                [string replaceOccurrencesOfString:@"file:///private" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
            }
            NSArray *tempArray = [string componentsSeparatedByString:@"/"];
            NSString *fileName = @"document.pdf";//tempArray.lastObject;
            NSString *sourceName = options[@"UIApplicationOpenURLOptionsSourceApplicationKey"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
//            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",sourceName,fileName]];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSLog(@"文件已存在");
                NSError *error;
                [fileManager removeItemAtPath:filePath error:&error];
            }
            BOOL isSuccess = [fileManager copyItemAtPath:string toPath:filePath error:nil];
            if (isSuccess == YES) {
                NSLog(@"拷贝成功");
                msg = @"拷贝成功";
                NSLog(@"path:%@ --",path);
                self.fileUrl = [[NSURL alloc] initWithString:filePath];
                
            } else {
                NSLog(@"拷贝失败");
                msg = @"拷贝失败";
            }
             */
            if (localUrl == nil) {
                self.fileUrl = nil;
                msg = @"拷贝失败";
            }
            else {
                self.fileUrl = localUrl;
                msg = [NSString stringWithFormat:@"%@:%@",@"拷贝成功",[localUrl absoluteString]];
            }
        }
        else {
            msg = @"上传失败\n请检查文件格式是否为pdf";
        }
    
        //找到顶部视图控制器
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        [alertWindow makeKeyAndVisible];
        //初始化弹窗口控制器
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        //显示弹出框
        [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
