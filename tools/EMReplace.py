
# -*- coding: utf-8 -*-

__author__ = "xyjxyf"

"替换枚举类型"

import os
import re
import sys

walk_path = sys.argv[1]
# 需要替换的字典：key->旧值， value->新值
replace_dic = {
    #EMClient
    '"EaseMob.h"': '"EMClient.h"',
    '\[EaseMob sharedInstance\]': '[EMClient shareClient]',
    'IChatManager': 'IEMChatManager',
    'EMCommandMessageBody': 'EMCmdMessageBody',
    'IChatManagerDelegate': 'EMChatManagerDelegate',
    #Group
    '"EMGroupStyleSetting.h"': '"EMGroupOptions.h"',
    'EMGroupStyleSetting': 'EMGroupOptions',
    '.groupSubject': '.subject',
    '.groupDescription': '.description',
    '.groupOccupantsCount': '.occupantsCount',
    '.groupSetting': '.setting',
    '.groupStyle': '.style',
    '.groupMaxUsersCount': '.maxUsersCount',
    'eGroupStyle_PrivateOnlyOwnerInvite': 'EMGroupStylePrivateOnlyOwnerInvite',
    'eGroupStyle_PrivateMemberCanInvite': 'EMGroupStylePrivateMemberCanInvite',
    'eGroupStyle_PublicJoinNeedApproval': 'EMGroupStylePublicJoinNeedApproval',
    'eGroupStyle_PublicOpenJoin': 'EMGroupStylePublicOpenJoin',
    'eGroupStyle_Default': 'EMGroupStylePrivateOnlyOwnerInvite',
    'eGroupLeaveReason_BeRemoved': 'EMGroupLeaveReasonBeRemoved',
    'eGroupLeaveReason_UserLeave': 'EMGroupLeaveReasonUserLeave',
    'eGroupLeaveReason_Destroyed': 'EMGroupLeaveReasonDestroyed',
    'fetchMyGroupsListWithError:': 'getMyGroupsFromServerWithError:',
    'chatManager destroyGroup:': 'groupManager leaveGroup:',
    'chatManager leaveGroup:': 'groupManager leaveGroup:',
    'chatManager addOccupants:': 'groupManager addOccupants:',
    'chatManager removeOccupants:': 'groupManager removeOccupants:',
    'chatManager blockOccupants:': 'groupManager blockOccupants:',
    'chatManager unblockOccupants:': 'groupManager unblockOccupants:',
    'chatManager changeGroupSubject:': 'groupManager changeGroupSubject:',
    'chatManager changeDescription:': 'groupManager changeDescription:',
    'chatManager fetchGroupBansList:': 'groupManager fetchGroupBansList:',
    'chatManager joinPublicGroup:': 'groupManager joinPublicGroup:',
    'chatManager searchPublicGroupWithGroupId:': 'groupManager searchPublicGroupWithGroupId:',
    #Contact
    'didReceiveBuddyRequest:': 'didReceiveFriendInvitationFromUsername:',
    'didAcceptedByBuddy:': 'didReceiveAgreedFromUsername:',
    'didRejectedByBuddy:': 'didReceiveDeclinedFromUsername:',
    'didRemovedByBuddy:': 'didReceiveDeletedFromUsernames:',
    #Chat
    '.messageBodyType': '.type',
    '.attachmentDownloadStatus': '.downloadStatus',
    '.chatter': '.conversationId',
    '.conversationType': '.type',
    '.conversationChatter': '.conversationId',
    '.groupSenderName': '.from',
    '.deliveryState': '.status',
    '.messageType': '.chatType',
    '.chatId': '.messageId',
    'id<IEMMessageBody>': 'EMMessageBody',
    'removeMessageWithId:': 'deleteMessageWithId:',
    'removeAllMessages': 'deleteAllMessages',
    'MessageBodyType': 'EMMessageBodyType',
    'eMessageBodyType_Text': 'EMMessageBodyTypeText',
    'eMessageBodyType_Image': 'EMMessageBodyTypeImage',
    'eMessageBodyType_Video': 'EMMessageBodyTypeVideo',
    'eMessageBodyType_Location': 'EMMessageBodyTypeLocation',
    'eMessageBodyType_Voice': 'EMMessageBodyTypeVoice',
    'eMessageBodyType_File': 'EMMessageBodyTypeFile',
    'eMessageBodyType_Command': 'EMMessageBodyTypeCmd',
    'EMAttachmentDownloadStatus': 'EMDownloadStatus',
    'EMAttachmentDownloading': 'EMDownloadStatusDownloading',
    'EMAttachmentDownloadSuccessed': 'EMDownloadStatusSuccessed',
    'EMAttachmentDownloadFailure': 'EMDownloadStatusFailed',
    'EMAttachmentNotStarted': 'EMDownloadStatusPending',
    'eConversationTypeChat': 'EMConversationTypeChat',
    'eConversationTypeGroupChat': 'EMConversationTypeGroupChat',
    'eConversationTypeChatRoom': 'EMConversationTypeChatRoom',
    'EMMessageType': 'EMChatType',
    'eMessageTypeChat': 'EMChatTypeChat',
    'eMessageTypeGroupChat': 'EMChatTypeGroupChat',
    'eMessageTypeChatRoom': 'EMChatTypeChatRoom',
    'MessageDeliveryState': 'EMMessageStatus',
    'eMessageDeliveryState_Pending': 'EMMessageStatusPending',
    'eMessageDeliveryState_Delivering': 'EMMessageStatusDelivering',
    'eMessageDeliveryState_Delivered': 'EMMessageStatusSuccessed',
    'eMessageDeliveryState_Failure': 'EMMessageStatusFailed',
    #ChatRoom
    '.chatroomSubject': '.subject',
    '.chatroomDescription': '.description',
    '.chatroomMaxOccupantsCount': '.maxOccupantsCount',
    'eChatroomBeKickedReason_BeRemoved': 'EMChatroomBeKickedReasonBeRemoved',
    'eChatroomBeKickedReason_Destroyed': 'EMChatroomBeKickedReasonDestroyed',
    'beKickedOutFromChatroom:': 'didReceiveKickedFromChatroom:',
    #Call
    '.sessionChatter': '.remoteUsername',
    'asyncAnswerCall:': 'answerCall:',
    'asyncEndCall:': 'endCall:',
    'eCallSessionStatusDisconnected': 'EMCallSessionStatusDisconnected',
    'eCallSessionStatusRinging': 'EMCallSessionStatusRinging',
    'eCallSessionStatusAnswering': 'EMCallSessionStatusConnecting',
    'eCallSessionStatusPausing': 'EMCallSessionStatusConnecting',
    'eCallSessionStatusConnecting': 'EMCallSessionStatusConnecting',
    'eCallSessionStatusConnected': 'EMCallSessionStatusConnected',
    'eCallSessionStatusAccepted': 'EMCallSessionStatusAccepted',
    'eCallConnectTypeNone': 'EMCallConnectTypeNone',
    'eCallConnectTypeDirect': 'EMCallConnectTypeDirect',
    'eCallConnectTypeRelay': 'EMCallConnectTypeRelay',
    'EMCallSessionType': 'EMCallType',
    'eCallSessionTypeAudio': 'EMCallTypeVoice',
    'eCallSessionTypeVideo': 'EMCallTypeVideo',
    'eCallSessionTypeContent': 'EMCallTypeVoice',
    'EMCallStatusChangedReason': 'EMCallEndReason',
    'eCallReasonNull': 'EMCallEndReasonHangup',
    'eCallReasonOffline': 'EMCallEndReasonNoResponse',
    'eCallReasonNoResponse': 'EMCallEndReasonNoResponse',
    'eCallReasonHangup': 'EMCallEndReasonHangup',
    'eCallReasonReject': 'EMCallEndReasonDecline',
    'eCallReasonBusy': 'EMCallEndReasonBusy',
    'eCallReasonFailure': 'EMCallEndReasonFailed',
    'eCallReason_Null': 'EMCallEndReasonHangup',
    'eCallReason_Offline': 'EMCallEndReasonNoResponse',
    'eCallReason_NoResponse': 'EMCallEndReasonNoResponse',
    'eCallReason_Hangup': 'EMCallEndReasonHangup',
    'eCallReason_Reject': 'EMCallEndReasonReject',
    'eCallReason_Busy': 'EMCallEndReasonBusy',
    'eCallReason_Failure': 'EMCallEndReasonFailed',
    #Apns
    '"EMPushNotificationOptions.h"': '"EMPushOptions.h"',
    'EMPushNotificationOptions': 'EMPushOptions',
    #Error
    '.errorCode': '.code',
    '.description': '.domain',
    'EMErrorType': 'EMErrorCode',
    'EMErrorNotFound': 'EMErrorNotExist',
#    'EMErrorServerMaxCountExceeded': '',
    'EMErrorConfigInvalidAppKey': 'EMErrorInvalidAppkey',
    'EMErrorServerAuthenticationFailure': 'EMErrorUserAuthenticationFailed',
    'EMErrorServerAPNSRegistrationFailure': 'EMErrorApnsBindDeviceTokenFailed',
    'EMErrorServerDuplicatedAccount': 'EMErrorUserAlreadyExist',
    'EMErrorServerInsufficientPrivilege': 'EMErrorUserIllegalArgument',
    'EMErrorServerTooManyOperations': 'EMErrorServerBusy',
    'EMErrorAttachmentNotFound': 'EMErrorFileNotFound',
    'EMErrorAttachmentUploadFailure': 'EMErrorFileUploadFailed',
    'EMErrorIllegalURI': 'EMErrorInvalidURL',
    'EMErrorMessageInvalid_NULL': 'EMErrorMessageInvalid',
    'EMErrorMessageContainSensitiveWords': 'EMErrorMessageIncludeIllegalSpeech',
    'EMErrorGroupInvalidID_NULL': 'EMErrorGroupInvalidId',
    'EMErrorGroupJoined': 'EMErrorGroupAlreadyJoined',
    'EMErrorGroupJoinNeedRequired': 'EMErrorGroupPermissionDenied',
#    'EMErrorGroupFetchInfoFailure': '',
#    'EMErrorGroupInvalidRequired': '',
#    'EMErrorGroupInvalidSubject_NULL': '',
#    'EMErrorGroupAddOccupantFailure': '',
    'EMErrorInvalidUsername_NULL': 'EMErrorInvalidUsername',
    'EMErrorInvalidUsername_Chinese': 'EMErrorInvalidUsername',
    'EMErrorInvalidPassword_NULL': 'EMErrorInvalidPassword',
    'EMErrorInvalidPassword_Chinese': 'EMErrorInvalidPassword',
#    'EMErrorApnsInvalidOption': '',
#    'EMErrorHasFetchedBuddyList': '',
#    'EMErrorBlockBuddyFailure': '',
#    'EMErrorUnblockBuddyFailure': '',
    'EMErrorCallConnectFailure': 'EMErrorCallConnectFailed',
#    'EMErrorExisted': '',
#    'EMErrorInitFailure': '',
    'EMErrorNetworkNotConnected': 'EMErrorNerworkUnavailable',

    'EMErrorFailure': 'EMErrorGeneral',
#    'EMErrorFeatureNotImplemented': '',
#    'EMErrorRequestRefused': '',
    'EMErrorChatroomInvalidID_NULL': 'EMErrorChatroomInvalidId',
    'EMErrorChatroomJoined': 'EMErrorChatroomAlreadyJoined',
#    'EMErrorReachLimit': '',
#    'EMErrorOutOfRateLimited': '',
#    'EMErrorGroupOccupantsReachLimit': '',
#    'EMErrorTooManyLoginRequest': '',
#    'EMErrorTooManyLogoffRequest': '',
#    'EMErrorPermissionFailure': '',
#    'EMErrorIsExist': '',
#    'EMErrorPushNotificationInvalidOption': '',
#    'EMErrorCallChatterOffline': '',
}

def check_main(root_path):
    for root, dirs, files in os.walk(root_path):
        for file_path in files:
            if file_path.endswith('.m') or file_path.endswith('.h') or file_path.endswith('.pch'):
                full_path = os.path.join(root, file_path)

                # 不检查 pod 第三方库
                if 'Pods/' in full_path:
                    break

                fr = open(full_path, 'r')
                content = fr.read()
                fr.close()

                for key in replace_dic:
                    match = re.search(key, content)
                    if match:
                        #替换
                        content = re.sub(key, replace_dic[key], content);

                #重新写入文件
                open(full_path,'w').write(content)

if __name__ == '__main__':
    check_main(walk_path)
