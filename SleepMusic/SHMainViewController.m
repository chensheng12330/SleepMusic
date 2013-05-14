//
//  SHMainViewController.m
//  SleepMusic
//
//  Created by sherwin.chen on 13-5-11.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import "SHMainViewController.h"

AVAudioPlayer *thePlayer = nil;

@interface SHMainViewController ()

@end

@implementation SHMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		mr_musicList  = [[NSMutableArray alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //add music
    [self AddMusicPlay:0];
	
	//加入定时器
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
	
	//禁止锁屏
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidUnload{
	[super viewDidUnload];
    [thePlayer stop];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
	[timer invalidate];
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

#pragma mark - Music Manage
-(void) AddMusicPlay:(NSInteger) index
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setDelegate: self];
    
	NSURL *musicURL = [[NSBundle mainBundle] URLForResource: [mr_musicList objectAtIndex:index]
											  withExtension: @"mp3"];
    
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
	if(++curPlayIndex>= [ar_musicName count])
	{
		curPlayIndex = 0;
	}
    
	//[thePlayer release],thePlayer=nil;
	[self AddMusicPlay:curPlayIndex];
}

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
			[self PlayButtionState:TRUE];
		}
	}else{
		//未播放处理
		curPlaytime = 0;
	}
    
}

- (IBAction) playMusic:		 (id) sender
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
    if(++curPlayIndex>= [ar_musicName count])
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

#pragma mark - AVAudioPlayer
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSLog(@"play over");
	//[self SwitchMusic];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

-(void) didSelectAtIndex:(int)index FileName:(NSString *)_fFileName
{
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}
@end
