//
//  ESFileManager.m
//  UploadPdfDemo
//
//  Created by eric sue on 2019/1/15.
//  Copyright © 2019 eric sue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESFileManager.h"

#define kFileName   @"DocumentDemo.pdf"

static ESFileManager *_shareInstance = nil;

@implementation ESFileManager

+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[ESFileManager alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}


- (NSURL*)copyFileToLocalFrom:(NSURL*)url {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    
    NSString *path = [url absoluteString];
    path = [path stringByRemovingPercentEncoding];
    NSMutableString *string = [[NSMutableString alloc] initWithString:path];
    if ([path hasPrefix:@"file:///private"]) {
        [string replaceOccurrencesOfString:@"file:///private" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
    }
    NSArray *tempArray = [string componentsSeparatedByString:@"/"];
//    NSString *fileName = tempArray.lastObject;
//    NSString *sourceName = options[@"UIApplicationOpenURLOptionsSourceApplicationKey"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",sourceName,fileName]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",kFileName]];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSLog(@"文件已存在");
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    BOOL isSuccess = [fileManager copyItemAtPath:string toPath:filePath error:nil];
    if (isSuccess == YES) {
        NSLog(@"拷贝成功");
        NSLog(@"path:%@ --",path);
        NSURL* localUrl = [[NSURL alloc] initWithString:filePath];
        
        return localUrl;
    }
    else {
        NSLog(@"拷贝失败");
    }
    return nil;
}

@end
