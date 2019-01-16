//
//  ESFileManager.h
//  UploadPdfDemo
//
//  Created by eric sue on 2019/1/15.
//  Copyright © 2019 eric sue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESFileManager : NSObject

+ (instancetype)shareInstance;

- (NSURL*)copyFileToLocalFrom:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
