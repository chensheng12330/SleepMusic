//
//  PopViewController.h
//  MPRSP
//
//  Created by sherwin on 13-4-13.
//  Copyright (c) 2013年 sherwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlaySettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *myTableDataSource;
}

@property (retain, nonatomic) NSMutableArray *myTableDataSource;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;

@end
