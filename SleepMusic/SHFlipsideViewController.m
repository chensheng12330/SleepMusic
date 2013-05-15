//
//  SHFlipsideViewController.m
//  SleepMusic
//
//  Created by sherwin.chen on 13-5-11.
//  Copyright (c) 2013年 sherwin.chen. All rights reserved.
//

#import "SHFlipsideViewController.h"

#import "SHCommon.h"

@interface SHFlipsideViewController ()
-(void) searchAllFiles;
//开始重新加载时调用的方法
- (void)reloadTableViewDataSource;
//完成加载时调用的方法
- (void)doneLoadingTableViewData;
@end

@implementation SHFlipsideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}
							
- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //load file list from documnt
    
    fileList = [[[NSString getCachesPath] stringByAppendingPathComponent:[SHCommon getMusicListFileName]] retain];
    
    NSFileManager *fileMg = [NSFileManager defaultManager];
    if([fileMg fileExistsAtPath:fileList])
    {
        _myTableDataSource = [[NSMutableArray alloc] initWithContentsOfFile:fileList];
    }
    else
    {
        //查找
        _myTableDataSource =  [[NSMutableArray alloc] init];
        
        [self searchAllFiles];
    }
    
    
    //初始化下拉刷新控件
    if (_refreshTableView == nil) {
        
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.myTableView.bounds.size.height, self.view.frame.size.width, self.myTableView.bounds.size.height)];
        refreshView.delegate = self;
        //将下拉刷新控件作为子控件添加到UITableView中
        [self.myTableView addSubview:refreshView];
        _refreshTableView = refreshView;
    }
    
    self.myTableView.initialCellTransformBlock = ADLivelyTransformFan;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [fileList           release];
    [_myTableView       release];
    [_myTableDataSource release];
    [_refreshTableView  release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    self.delegate = nil;
    [super viewDidUnload];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _myTableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UIView * backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.backgroundView = backgroundView;
        [backgroundView release];
    }
    
    cell.textLabel.text = [_myTableDataSource objectAtIndex:indexPath.row];
    
    UIColor * altBackgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    cell.backgroundView.backgroundColor = [indexPath row] % 2 == 0 ? [UIColor whiteColor] : altBackgroundColor;
    cell.textLabel.backgroundColor = cell.backgroundView.backgroundColor;

    return cell;
}


#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL sentAction = @selector(onSHSocket:didRecvDataOfLength:TotalLength:operTag:);
    if(_delegate!=NULL && [_delegate retainCount]>0 && [_delegate respondsToSelector:sentAction])
    {
        [_delegate didSelectAtIndex:indexPath.row FileName:[_myTableDataSource objectAtIndex:indexPath.row]];
    }
    
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - Actions
-(void) searchAllFiles
{
    [_myTableDataSource removeAllObjects];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:[NSString getDocumentsPath] error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [_myTableDataSource addObject:filename];
    }
    [_myTableDataSource writeToFile:fileList atomically:YES];
}

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)reloadFileList:(UIBarButtonItem *)sender {
    
    [self searchAllFiles];
    [self.myTableView reloadData];
}

//开始重新加载时调用的方法
- (void)reloadTableViewDataSource{
	_reloading = YES;
    
    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

//完成加载时调用的方法
- (void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");
    
	_reloading = NO;
	[_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.myTableView];
    //刷新表格内容
    [self.myTableView reloadData];
}

//重新加载数据
-(void)doInBackground
{
    NSLog(@"doInBackground");
    
    [self searchAllFiles];

    [NSThread sleepForTimeInterval:1];
    
    //后台操作线程执行完后，到主线程更新UI
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉被触发调用的委托方法
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
}

//返回当前是刷新还是无刷新状态
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

//返回刷新时间的回调方法
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
//滚动控件的委托方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
}
@end
