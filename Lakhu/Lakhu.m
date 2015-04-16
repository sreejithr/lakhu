//
//  Lakhu.m
//  Lakhu
//
//  Created by Sreejith on 10/04/15.
//  Copyright (c) 2015 Sreejith. All rights reserved.
//

#import "Lakhu.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

static sqlite3 *database = nil;

@implementation Lakhu

@synthesize bridge = _bridge;

-(void)connect:(NSString *)filename callback:(RCTResponseSenderBlock)callback {
    RCT_EXPORT();
    // Get the 'Documents/' directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = dirPaths[0];
    
    // Construct path to the db file
    NSString *dbPath = [documentsDir stringByAppendingFormat:@"/%@", filename];
    
    // Get file manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:dbPath] == YES) {
        const char *dbPathUTF = [dbPath UTF8String];
        
        if (sqlite3_open(dbPathUTF, &database) == SQLITE_OK) {
            // Success
            callback(@[[NSNull null], filename]);
            return;
        }
        callback(@[@"Could not open database file"]);
    } else {
        // If the db file isn't present in the filesystem, attempt c1opying it from the bundle
        NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:srcPath]) {
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dbPath error:&error];
            
            if (error != nil)
                callback(@[@"Cannot copy db file from bundle to filesystem"]);
        }
        // Success
        callback(@[[NSNull null], filename]);
        return;
    }
    callback(@[@"Could not find database file", filename]);
}

-(void)executeSelectQuery:(NSString *)query withCallback:(RCTResponseSenderBlock)callback {
    RCT_EXPORT();
    dispatch_queue_t selectQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(selectQueue, ^{
        sqlite3_stmt *statement = nil;
        NSMutableArray *rows = [[NSMutableArray alloc] init];

        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableArray *columns = [[NSMutableArray alloc] init];
                for (int i=0; i<sqlite3_column_count(statement); i++) {
                    // TODO: Infer the column type and allocate them as their corresponding type
                    [columns addObject:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, i)]];
                }
                [rows addObject:columns];
            }
        }
        sqlite3_reset(statement);
        callback(@[[NSNull null], rows]);
    });
}

-(void)executeUpdateQuery:(NSString *)query withCallback:(RCTResponseSenderBlock)callback {
    RCT_EXPORT();
    sqlite3_stmt *statement = nil;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        int queryStatus = sqlite3_step(statement);
        switch (queryStatus) {
            case SQLITE_DONE:
                callback(@[ [NSNull null] ]);
                break;
                
            case SQLITE_ERROR:
                callback(@[ [NSString stringWithUTF8String:sqlite3_errmsg(database)] ]);
                break;
                
            default:
                callback(@[ [NSString stringWithUTF8String:sqlite3_errmsg(database)] ]);
                break;
        }
    }
    sqlite3_reset(statement);
}

-(void)close {
    RCT_EXPORT();
    sqlite3_close(database);
}

-(void)dealloc {
    sqlite3_close(database);
}

@end
