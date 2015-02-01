//
//  ProtocolInterpreter.m
//  AR.Drone2.0
//
//  Created by Jeason on 14-11-3.
//  Copyright (c) 2014年 Jeason. All rights reserved.
//

#import "ProtocolInterpreter.h"
#import "Constant.h"
#import "DroneNavigationState.h"
#import "DroneCommunicator+Convenience.h"
#import "FunctionClass.h"
#import "Log.h"

@interface ProtocolInterpreter ()<ServerCommunicatorProtocol>

@property (nonatomic, strong) DroneCommunicator *droneCommunicator;
@property (nonatomic, strong) ServerCommunicator *svrCommunicator;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, strong) NSTimer *moveCommandTimer;

@end

@implementation ProtocolInterpreter

- (instancetype)init
{
    self = [super init];
    __weak id weakSelf = self;
    if ( self ) {
        self.packageId = @"0";
        self.droneCommunicator = [[DroneCommunicator alloc] init];
        self.svrCommunicator = [[ServerCommunicator alloc] init];
        self.svrCommunicator.delegate = self;
        self.svrCommunicator.receiveFilter = ^(NSData *receiveData, long tag) {
            NSString *messages = [[NSString alloc] initWithData:receiveData encoding:NSASCIIStringEncoding];
            NSArray *messagesArray = [messages componentsSeparatedByString:End];
            NSLog(@"Recv Message Array: %@", messagesArray);
            for ( NSString *msg in messagesArray ) {
                NSArray *argvs = [msg componentsSeparatedByString:Br];
                if ( [argvs count] > argvsBeginIndex ) {
                    NSString *packageId = argvs[packageIdIndex];
                    [weakSelf setPackageId:packageId];
                    NSString *command = argvs[commandIndex];
                    NSUInteger commandArgvsLen = [argvs count] - argvsBeginIndex - 1;
                    NSArray *commandRecvArgvs = [argvs subarrayWithRange:NSMakeRange(argvsBeginIndex, commandArgvsLen)];
                    NSString *checkSum = [argvs lastObject];
                    if ( [commandRecvArgvs count] != [checkSum integerValue] ) {
                        NSLog(@"Check Sum Fail: %@", messagesArray);
                        return;
                    }
                    if ( [command isEqualToString:HEARTBEAT] ) {
                        [weakSelf sendHeartBeat];
                    } else if ( [command isEqualToString:QueryState] ) {
                        [weakSelf processStateQuery];
                    } else if ( [command isEqualToString:TakeOff] ) {
                        [weakSelf processTakeoff];
                    } else if ( [command isEqualToString:Land] ) {
                        [weakSelf processLand];
                    } else if ( [command isEqualToString:Horver] ) {
                        [weakSelf processHorver];
                    } else if ( [command isEqualToString:FlyForward] ) {
                        [weakSelf processFlyForWard: commandRecvArgvs];
                    } else if ( [command isEqualToString:ArgChange] ) {
                        [weakSelf processArgChange:commandRecvArgvs];
                    } else if ( [command isEqualToString:HeightChange] ) {
                        [weakSelf processHeightChange:commandRecvArgvs];
                    } else {
                        NSLog(@"Error command: %@", command);
                    }
                }
            }
        };
    }
    return self;
}

- (void)processStateQuery
{
    NSArray *stateArray = @[@(_droneCommunicator.navigationState.controlState),
                            @(_droneCommunicator.navigationState.batteryLevel),
                            @(_droneCommunicator.navigationState.pitch),
                            @(_droneCommunicator.navigationState.roll),
                            @(_droneCommunicator.navigationState.yaw),
                            @(_droneCommunicator.navigationState.altitude),
                            @(_droneCommunicator.navigationState.speedX),
                            @(_droneCommunicator.navigationState.speedY),
                            @(_droneCommunicator.navigationState.speedZ)
                            ];
    NSMutableArray *stateStrs = [NSMutableArray new];
    for ( int i = 0; i < 2; i++ ) {
        [stateStrs addObject:[NSString stringWithFormat:@"%d", [stateArray[i] intValue]]];
    }
    for ( int i = 2; i < [stateArray count]; i++ ) {
        [stateStrs addObject:[NSString stringWithFormat:@"%lf",[stateArray[i] doubleValue]]];
    }
    NSData *package = [FunctionClass generateSocketPacket:QueryState Identifier:self.packageId object:stateStrs[0], stateStrs[1], stateStrs[2], stateStrs[3],stateStrs[4],stateStrs[5],stateStrs[6],stateStrs[7],stateStrs[8], nil];
    [self.svrCommunicator sendData:package ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Return Query State Success");
        } else {
            NSLog(@"Return Query State Error: %@", err);
        }
    }];
}

- (void)sendHeartBeat
{
    NSData *package = [FunctionClass generateSocketPacket:HEARTBEAT Identifier:self.packageId object:nil];
    [self.svrCommunicator sendData:package ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Send HeartBeat");
        } else {
            NSLog(@"HeartBeat Error: %@", err);
        }
    }];
}

- (void)processTakeoff
{
    [_droneCommunicator takeoff];
    NSData *package = [FunctionClass generateSocketPacket:TakeOff Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:package ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"TakeOff Success");
        } else {
            NSLog(@"Response TakeOff Error: %@", err);
        }
    }];
}

- (void)processLand
{
    [_droneCommunicator land];
    NSData *package = [FunctionClass generateSocketPacket:Land Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:package ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Land success");
        } else {
            NSLog(@"Response Land Error: %@", err);
        }
    }];
}

- (void)processHorver
{
    [_droneCommunicator hover];
    NSData *package = [FunctionClass generateSocketPacket:Horver Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:package ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Hover success");
        } else {
            NSLog(@"Response Hover Error: %@", err);
        }
    }];
}

- (void)processFlyForWard:(NSArray *)argvs
{
    [self.moveCommandTimer invalidate];
    NSString *speed = argvs[0];
    _droneCommunicator.forwardSpeed = [speed doubleValue];
    _droneCommunicator.rotationSpeed = 0;
    _droneCommunicator.verticalSpeed = 0;
    NSString *time = argvs[1];
    self.moveCommandTimer = [NSTimer scheduledTimerWithTimeInterval:[time doubleValue] target:self selector:@selector(processEndMove:) userInfo:nil repeats:NO];
    NSData *packet = [FunctionClass generateSocketPacket:FlyForward Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:packet ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"send fly forward succ to server");
        } else {
            NSLog(@"Response Fly Forward Error:%@", err);
        }
    }];
}

- (void)processEndMove:(NSTimer *)sender
{
    [sender invalidate];
    [_droneCommunicator hover];
}

- (void)processArgChange:(NSArray *)argvs
{
    [self.moveCommandTimer invalidate];
    NSString *argSpeed = argvs[0];
    NSString *time = argvs[1];
    _droneCommunicator.forwardSpeed = 0;
    _droneCommunicator.rotationSpeed = [argSpeed doubleValue];
    _droneCommunicator.verticalSpeed = 0;
    self.moveCommandTimer = [NSTimer scheduledTimerWithTimeInterval:[time doubleValue] target:self selector:@selector(processEndMove:) userInfo:nil repeats:NO];
    NSData *packet = [FunctionClass generateSocketPacket:ArgChange Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:packet ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Send Arg Change Response to Server Success");
        } else {
            NSLog(@"Response arg error: %@", err);
        }
    }];
}

- (void)processHeightChange:(NSArray *)argvs
{
    [self.moveCommandTimer invalidate];
    NSString *heightChange = argvs[0];
    NSString *time = argvs[1];
    _droneCommunicator.verticalSpeed = [heightChange doubleValue];
    _droneCommunicator.forwardSpeed = 0;
    _droneCommunicator.rotationSpeed = 0;
    self.moveCommandTimer = [NSTimer scheduledTimerWithTimeInterval:[time doubleValue]
                                                             target:self
                                                           selector:@selector(processEndMove:)
                                                           userInfo:nil
                                                            repeats:NO];
    NSData *packet = [FunctionClass generateSocketPacket:HeightChange Identifier:self.packageId object:Succ, nil];
    [_svrCommunicator sendData:packet ToServerWithCompletion:^(BOOL success, NSError *err) {
        if ( success ) {
            NSLog(@"Send Height change response to Server success");
        } else {
            NSLog(@"Response arg error: %@", err);
        }
    }];
}

- (void)start
{
    [_droneCommunicator setupDefaults];
    [_svrCommunicator setupDefaults];
}

@end
