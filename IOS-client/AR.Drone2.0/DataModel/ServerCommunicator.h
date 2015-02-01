//
//  ServerCommunicator.h
//  AR.Drone2.0
//
//  Created by Jeason on 14-10-10.
//  Copyright (c) 2014年 Jeason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

/**
 *  Ah...Because the Communicator should not know about "HeartBeat" means.
 */
@protocol ServerCommunicatorProtocol <NSObject>
@required
- (void)sendHeartBeat;
@end


@interface ServerCommunicator : NSObject

/**
 *  Just connect to Server
 */
- (void)setupDefaults;

- (void)connectToServer:(NSString *)ip
                 OnPort:(int)port
         WithCompletion:(confirmBlock)handler;

- (void)startHeartBeat;

- (BOOL)sendData:(NSData *)data ToServerWithCompletion:(confirmBlock)completion;

/**
 *  receive queue handler, set by the caller or, the delegate
 */
@property (nonatomic, strong) onReceiveBlock receiveFilter;

@property (nonatomic,readonly, getter=isConnected) BOOL connected;

@property (nonatomic, weak) id<ServerCommunicatorProtocol> delegate;

@end
