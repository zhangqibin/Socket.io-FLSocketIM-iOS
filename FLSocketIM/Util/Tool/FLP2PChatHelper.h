//
//  FLP2PChatHelper.h
//  FLSocketIM
//
//  Created by qibin on 2019/8/25.
//  Copyright © 2019 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCMediaStream.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCPeerConnection.h"
#import "RTCPair.h"
#import "RTCMediaConstraints.h"
#import "RTCAudioTrack.h"
#import "RTCVideoTrack.h"
#import "RTCVideoCapturer.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCEAGLVideoView.h"
#import "RTCICEServer.h"
#import "RTCVideoSource.h"
#import "RTCAVFoundationVideoSource.h"
#import "RTCICECandidate.h"

@protocol FLP2PChatHelperDelegate;

@interface FLP2PChatHelper : NSObject

@property (nonatomic, weak) id<FLP2PChatHelperDelegate>delegate;

+ (instancetype)sharedInstance;
/**
 连接到房间
 
 @param room 房间号
 */
- (void)connectRoom:(NSString *)room;

/**
 *  退出房间
 */
- (void)exitRoom;

@end


@protocol FLP2PChatHelperDelegate <NSObject>

@optional
- (void)videoChatHelper:(FLP2PChatHelper *)videoChatHelper setLocalStream:(RTCMediaStream *)stream userId:(NSString *)userId;
- (void)videoChatHelper:(FLP2PChatHelper *)videoChatHelper addRemoteStream:(RTCMediaStream *)stream userId:(NSString *)userId;
- (void)videoChatHelper:(FLP2PChatHelper *)videoChatHelper closeWithUserId:(NSString *)userId;
- (void)closeRoomWithVideoChatHelper:(FLP2PChatHelper *)videoChatHelper;
@end

//
//@interface FLPeer : NSObject
//
//@end
