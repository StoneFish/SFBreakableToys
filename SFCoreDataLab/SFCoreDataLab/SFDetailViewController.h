//
//  SFDetailViewController.h
//  SFCoreDataLab
//
//  Created by Plato on 11/2/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
