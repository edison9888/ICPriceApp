//
//  MyTTThumbsDataSource.m
//  ICPriceAppV2
//
//  Created by 高飞 on 12-2-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyTTThumbsDataSource.h"

@implementation MyTTThumbsDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
    return @"";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForEmpty {
    return @"";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForError:(NSError*)error {
    return TTIMAGE(@"");
}

@end