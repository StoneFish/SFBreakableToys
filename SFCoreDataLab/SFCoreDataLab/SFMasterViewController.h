//
//  SFMasterViewController.h
//  SFCoreDataLab
//
//  Created by Plato on 11/2/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFDetailViewController;

#import <CoreData/CoreData.h>

@interface SFMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SFDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
