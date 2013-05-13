//
//  NSString+NSString_File.h
//  SleepMusic
//
//  Created by sherwin on 13-5-13.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_File)
+(NSString*) getDocumentsPath;
+(NSString*) getCachesPath;

+(NSProcessInfo*) getProcessInfo;
+(NSInteger) getFileSizeFromPath:(char *)path;
@end
