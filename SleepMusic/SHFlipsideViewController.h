//
//  SHFlipsideViewController.h
//  SleepMusic
//
//  Created by sherwin.chen on 13-5-11.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ADLivelyTableView.h"


@class SHFlipsideViewController;

@protocol SHFlipsideViewControllerDelegate <NSObject>
- (void)flipsideViewControllerDidFinish:(SHFlipsideViewController *)controller;

- (void)didSelectAtIndex:(int )index FileName:(NSString*) _fFileName;
@end

@interface SHFlipsideViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,
EGORefreshTableHeaderDelegate>
{
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshTableView;
    
    ///
    NSString *fileList;
    
    NSMutableArray *_myTableDataSource;
}

- (IBAction)reloadFileList:(UIBarButtonItem *)sender;

@property (retain, nonatomic) IBOutlet ADLivelyTableView *myTableView;
@property (assign, nonatomic) id <SHFlipsideViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSMutableArray *myTableDataSource;
- (IBAction)done:(id)sender;

@end
