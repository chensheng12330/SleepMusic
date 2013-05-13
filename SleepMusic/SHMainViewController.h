//
//  SHMainViewController.h
//  SleepMusic
//
//  Created by sherwin.chen on 13-5-11.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import "SHFlipsideViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/NSTimer.h>


@interface SHMainViewController : UIViewController <SHFlipsideViewControllerDelegate,
AVAudioPlayerDelegate>
{
    //AVAudioPlayer *thePlayer;
    
    NSTimer *timer ;
    NSTimer *color_timer ;
	NSInteger nCurPalyMusic,nOldSeletMusic;
	NSMutableArray *mr_musicList;//歌曲列表
	NSArray *dataSource;
	NSArray *ar_musicName;
	//AVAudioPlayer *thePlayer;
	
	long setPlayTime;  //用户设置时间
	long curPlaytime;  //当前已播放时间
	int  curPlayIndex; //当前播放的序号
	int  curSelectPalyTimeRow;
    int  before_index;
	BOOL isPlay;//是否在播放
}


@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
- (IBAction)showInfo:(id)sender;

///
- (IBAction) playMusic:		 (id) sender;
- (IBAction) playSetting:	 (id) sender;
- (IBAction) MusicKindSelect:(id) sender;
- (IBAction) SetterPageBack: (id) sender;
- (IBAction) ChangeMusic_prev:(id) sender;
- (IBAction) ChangeMusic_next:(id) sender;
- (IBAction) ChoiceMusic:(id) sender;

- (void)handleTimer:(NSTimer *)timer; //定时器处理
@end
