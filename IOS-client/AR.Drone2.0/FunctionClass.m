//
//  FunctionClass.m
//  Myproject
//
//  Created by JInbo on 14-3-22.
//  Copyright (c) 2014年 Myproject. All rights reserved.
//

#import "FunctionClass.h"
#import "Constant.h"
#import "NSString+stringFromArrayWithSeperator.h"

@implementation FunctionClass

+ (NSData *)generateSocketPacket:(NSString *)command Identifier:(NSString *)packageId object:(id)first, ... {
    packetId++; //first
    NSMutableArray *argvs = [NSMutableArray new];   //third
    [argvs addObjectsFromArray:@[command, packageId]];
    id eachObject;
    va_list argvsList;
    if ( first ) {
        va_start(argvsList, first); //skip first object(nil)
        while ( (eachObject = va_arg(argvsList, id)) ) {
            if ( [eachObject isKindOfClass:[NSString class]] ) {
                [argvs addObject:eachObject];
            } else {
                NSLog(@"Generate Error: objects are not strings");
                return nil;
            }
        }
    }
    NSString *argvsString = [NSString stringFromArray:argvs WithSeperator:Br];
    NSLog(@"ArgvsString: %@", argvsString);
    NSString *toCommand;
    if ( [command isEqualToString:HEARTBEAT] ) {
        toCommand = HEARTBEAT;
    } else {
        toCommand = Response;
    }
    NSString *packet = [NSString stringWithFormat:@"%d %@ %@ %lu%@", packetId, toCommand, argvsString, (unsigned long)[argvs count], End];
    NSLog(@"Packet: %@ send to Server...", packet);
    return [packet dataUsingEncoding:NSASCIIStringEncoding];
}
@end
