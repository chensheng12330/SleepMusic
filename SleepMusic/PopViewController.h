//
//  PopViewController.h
//  MPRSP
//
//  Created by sherwin on 13-4-13.
//  Copyright (c) 2013年 zhangli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopTableViewCell:UITableViewCell
@property (nonatomic, retain) UILabel     *lbTitleName;
@property (nonatomic, retain) UIImageView *ivImageView;
@end


@class PopViewController;

@protocol PopViewControllerDelegate <NSObject>

@end

@interface PopViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *myTableDataSource;
}
@property (retain, nonatomic) NSMutableArray *myTableDataSource;
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) id<PopViewControllerDelegate> delegate;
@end
