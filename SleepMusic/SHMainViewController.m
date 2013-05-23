//
//  SHMainViewController.m
//  SleepMusic
//
//  Created by sherwin.chen on 13-5-11.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SHMainViewController.h"
#import "VolumeBar.h"
#import "MusicPlaySettingViewController.h"

AVAudioPlayer *thePlayer = nil;

@interface SHMainViewController ()

-(void)PlayButtionState:(BOOL) state; //YES:play  NO:stop
-(void)configNowPlayingInfoCenter;

-(void)onVolumeBarChange:(VolumeBar*) sender;
@end

@implementation SHMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_mrMusicList  = [[NSMutableArray alloc] init];
		nCurPalyMusic = 0;
		nOldSeletMusic= 0;
		isPlay = NO;
		curPlaytime = 0;
		setPlayTime = 0; //为零为无限循环
		curPlayIndex= 0;
		curSelectPalyTimeRow = 3;
    }
    return self;
}

#pragma mark - View init
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //NSString
    
    for (int i=1; i<4; i++) {
        NSString *testPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Acoustic Noodling%d",i] ofType:@"caf"];
        [_mrMusicList addObject:testPath];
    }
	
	//加入定时器
	//timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
	
	//禁止锁屏
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //2. 让后台可以处理多媒体的事件
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // add music volume UI
    CGRect frame = CGRectMake(745, 530,0,0);// 大小由背景图决定
    VolumeBar *bar = [[VolumeBar alloc] initWithFrame:frame minimumVolume:0 maximumVolume:10];
    [bar addTarget:self action:@selector(onVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:bar];
    bar.currentVolume = 4;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [self configNowPlayingInfoCenter];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    //else
    [UIApplication sharedApplication].idleTimerDisabled = NO;
	//[timer invalidate];
}



- (void)viewDidUnload{
	[super viewDidUnload];
    [thePlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_flipsidePopoverController release];
    [super dealloc];
}

#pragma mark - back music play setting
//设置锁屏状态，显示的歌曲信息
-(void)configNowPlayingInfoCenter
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"name" forKey:MPMediaItemPropertyTitle];
        [dict setObject:@"singer" forKey:MPMediaItemPropertyArtist];
        [dict setObject:@"album" forKey:MPMediaItemPropertyAlbumTitle];
        UIImage *image = [UIImage imageNamed:@"back_image.png"];
        
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause...");
                [self playMusic:nil];
                break;
            }
            case UIEventSubtypeRemoteControlPlay:
                
            {
                NSLog(@"UIEventSubtypeRemoteControlPlay...");
                break;
            }
            case UIEventSubtypeRemoteControlPause:
                
            {
                NSLog(@"UIEventSubtypeRemoteControlPause...");
                break;
            }
            case UIEventSubtypeRemoteControlStop:
                
            {
                NSLog(@"UIEventSubtypeRemoteControlStop...");
                break;
            }
                
            case UIEventSubtypeRemoteControlNextTrack:
                
            {
                //[self nextSongAuto];
                
                //[self configNowPlayingInfoCenter];
                [self ChangeMusic_next:nil];
                NSLog(@"UIEventSubtypeRemoteControlNextTrack...");
                break;
            }
            case UIEventSubtypeRemoteControlPreviousTrack:
                
            {
                [self ChangeMusic_prev:nil];
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack...");
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Music Manage
//加入播放队列
-(void) AddMusicPlay:(NSInteger) index
{
    if (index>= _mrMusicList.count || index<0) {
        return;
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setDelegate: self];
    
	NSURL *musicURL = [NSURL fileURLWithPath:[_mrMusicList objectAtIndex:index]];
    
    if (thePlayer == nil)
    {
        thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    else
    {
        [thePlayer stop];
        [thePlayer release];
        thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    
	thePlayer.volume		= 1;
	thePlayer.numberOfLoops = 0;
	thePlayer.delegate		= self;
    
    [session setActive:YES error:nil];
	return;
}

-(void) SwitchMusic
{
	if(++curPlayIndex>= [_mrMusicList count])
	{
		curPlayIndex = 0;
	}
    
	//[thePlayer release],thePlayer=nil;
	[self AddMusicPlay:curPlayIndex];
}

//睡眠时间设定
- (void)handleTimer:(NSTimer *)timer
{
	//播放状态处理
	//NSLog(@"%ld,%ld",setPlayTime,curPlaytime);
    
    
	if (setPlayTime == 0) { //循环播放，不做处理
		curSelectPalyTimeRow = 3;
		curPlaytime = 0;
        return;
	}
	
	//播放处理
	if (isPlay) {
		curPlaytime++;
		if (curPlaytime>= setPlayTime*60) {
			//播放超时处理
			[thePlayer stop];
			isPlay = NO;
            setPlayTime = 0;
			//[self PlayButtionState:TRUE];
		}
	}else{
		//未播放处理
		curPlaytime = 0;
	}
}

- (IBAction) playMusic:(id) sender
{
    curPlaytime =0;
    //[thePlayer release],thePlayer=nil;
    [self AddMusicPlay:curPlayIndex];
	if (isPlay) {
		isPlay = NO;
		[thePlayer stop];
		[self PlayButtionState:TRUE];
	}else{
		isPlay = YES;
		[thePlayer play];
		[self PlayButtionState:FALSE];
	}
	return ;
}

//选择播放
- (IBAction) ChoiceMusic:(id) sender
{
    UIButton *btnMusicIndex = (UIButton *)(sender);
    curPlayIndex = btnMusicIndex.tag;
	//[thePlayer release],thePlayer=nil;
	[self AddMusicPlay:curPlayIndex];
    if (isPlay)
    {
		[thePlayer play];
		[self PlayButtionState:FALSE];
	}
    return;
}

//上一曲
- (IBAction) ChangeMusic_prev:(id) sender
{
    if(--curPlayIndex< 0)
	{
        NSLog(@"当前已为第一首歌曲！");
		curPlayIndex = 0;
	}
    else
    {
        curPlaytime--;
    }
    
	//[thePlayer release],thePlayer=nil;
	[self AddMusicPlay:curPlayIndex];
    
    if (isPlay)
    {
		[thePlayer play];
		[self PlayButtionState:FALSE];
	}
}

//下一曲
- (IBAction) ChangeMusic_next:(id) sender
{
    if(++curPlayIndex>= [_mrMusicList count])
	{
        NSLog(@"当前已为最后一首歌曲！");
        curPlayIndex = 0;
	}
    else
    {
        curPlaytime++;
    }
    
	//[thePlayer release],thePlayer=nil;
	[self AddMusicPlay:curPlayIndex];
    
    if (isPlay)
    {
		[thePlayer play];
		[self PlayButtionState:FALSE];
	}
}

- (IBAction) playSetting:	 (id) sender
{
    /*
    [m_tableView reloadData];
	[self.view addSubview:m_seterView];
	[MyTransitionAnimation animation:kCATransitionFade transView:self.view];
     */
}
- (IBAction) SetterPageBack: (id) sender
{
    /*
	[m_seterView removeFromSuperview];
	[MyTransitionAnimation animation:kCATransitionFade transView:self.view];
     */
}

//音量调节
-(void)onVolumeBarChange:(VolumeBar*) sender
{
    int volume = sender.currentVolume;
    [thePlayer setVolume:volume/10.0];
}

#pragma mark - View lifecycle
- (void) ReadConfigWithFile
{
	NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *directory = [paths objectAtIndex:0];
	
	NSString *filePath;
	filePath = [directory stringByAppendingPathComponent:@"setting"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:filePath])
	{
		NSDictionary *tDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		NSString *tstr = (NSString *)[tDic objectForKey:@"playtime"];
		setPlayTime = [tstr intValue];
		[tDic release];
	}
	else
	{
		NSDictionary *tDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"10",@"playtime",nil];
		[tDic writeToFile:filePath atomically:YES];
		setPlayTime = 10;
		[tDic release];
	}
	return ;
}

-(void)PlayButtionState:(BOOL) state
{
    NSLog(@"play: %d",state);
}

#pragma mark - AVAudioPlayer
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSLog(@"play over");
	[self SwitchMusic];
	[thePlayer play];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	//中断
	[thePlayer stop];
	//[self PlayButtionState:TRUE];
}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	[thePlayer play];
	//[self PlayButtionState:FALSE];
}

#pragma mark - Flipside View Controller
- (void)flipsideViewControllerDidFinish:(SHFlipsideViewController *)controller
{
    //copy SHFlipsideViewController.datasource to muMusicList
    
    //1. remvoe music list all
    [_mrMusicList removeAllObjects];
    
    //2. add to music list
    for (NSString* musicName in controller.myTableDataSource) {
        NSString* strMusicPath = [[NSString getDocumentsPath] stringByAppendingPathComponent:musicName];
        [_mrMusicList addObject:strMusicPath];
    }
    
    //3. else
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

-(void) didSelectAtIndex:(int)index FileName:(NSString *)_fFileName
{
    [self AddMusicPlay:index];
    [self playMusic:nil];
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        SHFlipsideViewController *controller = [[[SHFlipsideViewController alloc] initWithNibName:@"SHFlipsideViewController" bundle:nil] autorelease];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (!self.flipsidePopoverController) {
            SHFlipsideViewController *controller = [[[SHFlipsideViewController alloc] initWithNibName:@"SHFlipsideViewController" bundle:nil] autorelease];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[[UIPopoverController alloc] initWithContentViewController:controller] autorelease];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)musicPlaySetting:(id)sender {
    

    MusicPlaySettingViewController *mvc = [[MusicPlaySettingViewController alloc] init];
                                           
    popoverController = [[[UIPopoverController alloc] initWithContentViewController:mvc] autorelease];
    popoverController.popoverContentSize = CGSizeMake(320,42*2);
    
    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 10,5) inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}
@end
