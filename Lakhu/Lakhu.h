//
//  Lakhu.h
//  Lakhu
//
//  Created by Sreejith on 10/04/15.
//  Copyright (c) 2015 Sreejith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "RCTBridgeModule.h"
#import "RCTLog.h"

@interface Lakhu : NSObject <RCTBridgeModule>

-(void)connect:(NSString *)name callback:(RCTResponseSenderBlock)callback;
-(void)executeUpdateQuery:(NSString *)query withCallback:(RCTResponseSenderBlock)callback;
-(void)executeSelectQuery:(NSString *)query withCallback:(RCTResponseSenderBlock)callback;

@end