//
//  ServerCommunicator.h
//  AR.Drone2.0
//
//  Created by Jeason on 14-10-10.
//  Copyright (c) 2014年 Jeason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@protocol ServerCommunicatorProtocol <NSObject>

@required
- (void)sendHeartBeat;

@end

@interface ServerCommunicator : NSObject

- (void)setupDefaults;
- (void)connectToServer:(NSString *)ip
                 OnPort:(int)port
         WithCompletion:(confirmBlock)handler;

- (void)startHeartBeat;

- (BOOL)sendData:(NSData *)data ToServerWithCompletion:(confirmBlock)completion;

/**
 *  receive queue handler
 */
@property (nonatomic, strong) onReceiveBlock receiveFilter;
@property (nonatomic,readonly, getter=isConnected) BOOL connected;
#warning Strongly unrecommand design pattern !
@property (nonatomic, weak) id<ServerCommunicatorProtocol> delegate;

@end
