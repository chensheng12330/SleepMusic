//
//  VolumeBar.h
//  VolumeBar
//
//  Created by luyf on 13-2-28.
//  Copyright (c) 2013年 luyf. All rights reserved.
//

/*
 CGRect frame = CGRectMake(100, 100, 0, 0);// 大小由背景图决定
VolumeBar *bar = [[VolumeBar alloc] initWithFrame:frame minimumVolume:0 maximumVolume:10];

[bar addTarget:self action:@selector(onVolumeBarChange:) forControlEvents:UIControlEventValueChanged];

[self.view addSubview:bar];
bar.currentVolume = 4;
 */

#import <UIKit/UIKit.h>

@interface VolumeBar : UIControl
{
@private
    NSInteger _minimumVolume;
    NSInteger _maximumVolume;
    
    NSInteger _currentVolume;
}
@property (nonatomic, assign) NSInteger currentVolume;

- (id)initWithFrame:(CGRect)frame minimumVolume:(NSInteger)minimumVolume maximumVolume:(NSInteger)maximumVolume;

@end
