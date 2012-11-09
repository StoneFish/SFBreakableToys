//
//  SFMainViewController.m
//  ViewDeckLab
//
//  Created by Plato on 11/5/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import "SFMainViewController.h"
#import "IIViewDeckController.h"

@interface SFMainViewController ()

@end

@implementation SFMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //left buttonItems
    UIBarButtonItem * leftItem = [[[UIBarButtonItem alloc]initWithTitle:@"left" style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)] autorelease];
    
    UIBarButtonItem * bounceItem = [[[UIBarButtonItem alloc]initWithTitle:@"bounceLeft" style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(bounceLeftView)] autorelease];
    
    
    self.navigationItem.leftBarButtonItems = @[leftItem,bounceItem];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
