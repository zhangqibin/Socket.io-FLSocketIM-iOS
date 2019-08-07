//
//  FLChatListViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatListViewController.h"
#import "FLChatViewController.h"
#import "FLConversationModel.h"
#import "FLChatListCell.h"
#import "FLChatViewController.h"
#import "FLStatusTitleView.h"

@interface FLChatListViewController () <UITableViewDelegate, UITableViewDataSource, FLClientManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FLStatusTitleView *titleView;

@end

@implementation FLChatListViewController

#pragma mark - Lazy
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UIView *)titleView {
    if (!_titleView) {
        
        _titleView = [[FLStatusTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth*2/3, 40)];
    }
    return _titleView;
}
#pragma mark - LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [FLClientManager shareManager].chatListVC = self;
    [[FLClientManager shareManager] addDelegate:self];
    [self setupUI];
    
    [self queryDataFromDB];
}
- (void)dealloc {
    [[FLClientManager shareManager] removeDelegate:self];
}
#pragma mark - UI
- (void)setupUI {
    
    
    self.navigationItem.titleView = self.titleView;
    
    UIBarButtonItem *chat = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(chat)];
    self.navigationItem.rightBarButtonItem = chat;
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 70;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[FLChatListCell class] forCellReuseIdentifier:@"FLChatListCell"];
    [_tableView setSeparatorColor:[UIColor colorWithHex:0xe5e5e5]];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 80, 0, 0)];
}
#pragma mark - Data
- (void)queryDataFromDB {
    
    
    NSArray *conversations = [[FLChatDBManager shareManager] queryAllConversations];
    [self.dataSource addObjectsFromArray:conversations];
    
    [self.tableView reloadData];
}
#pragma mark - Public
- (FLConversationModel *)isExistConversationWithToUser:(NSString *)toUser {
    
    FLConversationModel *conversationModel;
    NSInteger index = 0;
    for (FLConversationModel *conversation in self.dataSource) {
        
        if ([conversation.userName isEqualToString:toUser]) {
            
            conversationModel = conversation;
            break;
        }
        index++;
    }
    return conversationModel;
}

- (void)addOrUpdateConversation:(NSString *)conversationName latestMessage:(FLMessageModel *)message isRead:(BOOL)isRead{
    
    
    FLConversationModel *conversation = [self isExistConversationWithToUser:conversationName];
    if (conversation) {
        
        [self updateLatestMsgForConversation:conversation latestMessage:message isRead:isRead];
    }
    else {
        
        // 如果当前会话开启，则已读消息
        [self addConversationWithMessage:message conversationId:conversationName isReaded:isRead];
    }
}

- (void)addConversationWithMessage:(FLMessageModel *)message conversationId:(NSString *)conversationId isReaded:(BOOL)read{
 
    FLConversationModel *conversation = [[FLConversationModel alloc] initWithMessageModel:message conversationId:conversationId];
    conversation.unReadCount = read?0:1;
    
    [self.dataSource insertObject:conversation atIndex:0];
    [self.tableView reloadData];
}

- (void)updateLatestMsgForConversation:(FLConversationModel *)conversation latestMessage:(FLMessageModel *)message isRead:(BOOL)isRead{

    conversation.unReadCount += 1;
    if (isRead) {
        conversation.unReadCount = 0;
    }
    conversation.latestMessage = message;
    // 将会话放到最前面
    [self.dataSource removeObject:conversation];
    [self.dataSource insertObject:conversation atIndex:0];
    
    [self.tableView reloadData];

    
}

- (void)updateRedPointForUnreadWithConveration:(NSString *)conversationName {
    
    FLConversationModel *conversation = [self isExistConversationWithToUser:conversationName];
    if (conversation) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:conversation] inSection:0];
        [self updateRedPointForCellAtIndexPath:indexPath];
    }
}
#pragma mark - Private
- (void)chat {
    
    FLChatViewController *chatVC = [[FLChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

// 打开会话，更新未读消息数量
- (void)updateRedPointForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    FLConversationModel *model = self.dataSource[indexPath.row];
    model.unReadCount = 0;
    FLChatListCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell updateUnreadCount];
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FLChatListCell" forIndexPath:indexPath];
    FLConversationModel *model = self.dataSource[indexPath.row];
    model.imageStr = [NSString stringWithFormat:@"Fruit-%ld", indexPath.row];
    cell.model = model;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLConversationModel *model = self.dataSource[indexPath.row];
    FLChatViewController *chatVC = [[FLChatViewController alloc] initWithToUser:model.userName];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - FLClientManagerDelegate

- (void)clientManager:(FLClientManager *)manager didReceivedMessage:(FLMessageModel *)message {
    
    
    NSString *conversationName = message.from;
    
    BOOL isRead = [conversationName isEqualToString:[FLClientManager shareManager].chattingConversation.toUser];
    [self addOrUpdateConversation:conversationName latestMessage:message isRead:isRead];
    
}

- (void)clientManager:(FLClientManager *)manager didChangeStatus:(SocketIOStatus)status {
    [self.titleView updateWithLinkStatus:status];
}

@end
