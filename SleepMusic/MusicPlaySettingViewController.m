//
//  PopViewController.m
//  MPRSP
//
//  Created by sherwin on 13-4-13.
//  Copyright (c) 2013年 sherwin. All rights reserved.
//

#import "MusicPlaySettingViewController.h"

@interface MusicPlaySettingViewController ()

@end

@implementation MusicPlaySettingViewController
@synthesize myTableDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //init with data
        
    }
    return self;
}

- (id)initWith
{
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_myTableView       release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopCell";
    UITableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"睡眠开关"];
        
        //UISwitch *sleepSwitch = [UISwitch alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    else if (indexPath.row == 1)
    {
        [cell.textLabel setText:@"睡眠时间设置"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}
@end
