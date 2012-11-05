//
//  Entity.h
//  SFCoreDataLab
//
//  Created by Plato on 11/2/12.
//  Copyright (c) 2012 hand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) NSTimeInterval creationDate;

@end
