//
//  PopViewController.m
//  MPRSP
//
//  Created by sherwin on 13-4-13.
//  Copyright (c) 2013年 zhangli. All rights reserved.
//

#import "PopViewController.h"


@implementation PopTableViewCell
@synthesize lbTitleName,ivImageView;
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
    }
    return self;
}

-(void) dealloc
{
    self.lbTitleName  = nil;
    self.ivImageView   = nil;
    [super dealloc];
}
@end

@interface PopViewController ()

@end

@implementation PopViewController
@synthesize delegate = _delegate;
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
        NSMutableDictionary *dic = [[NSMutableDictionary alloc ] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"popViewData" ofType:@"plist"]];
        

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
    [myTableDataSource  release];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return myTableDataSource.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopCell";
    UITableViewCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    NSDictionary *dicData = [ myTableDataSource objectAtIndex:indexPath.row];
    
    [cell.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[dicData objectForKey:@"pic"]]]];
    [cell.imageView setHighlightedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_checked.png",[dicData objectForKey:@"pic"]]]];
    
    [cell.textLabel setText:[dicData objectForKey:@"name"]];
    return cell;
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sentAction = @selector(PopViewController:didSelectRow:PopDataModel:CellText:);
    if(_delegate!=NULL && [_delegate retainCount]>0 && [_delegate respondsToSelector:sentAction])
    {
        UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
        //[_delegate PopViewController:self didSelectRow:indexPath PopDataModel:myPopDataModel CellText:cell.textLabel.text];
    }
    return;
}
@end
