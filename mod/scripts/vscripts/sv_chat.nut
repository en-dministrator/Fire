global function FireChat_Init
global function Fire_GetPrefix
global function Fire_SetPrefix
global function Fire_ChatServerPrivateMessage
global function Fire_ChatServerBroadcast

struct Fire
{
    string prefix = "[31m[Fire][37m"
}

Fire SvFire

void function FireChat_Init()
{
    AddCallback_OnReceivedSayTextMessage( OnReceivedSayTextMessage )
}

ClServer_MessageStruct function OnReceivedSayTextMessage( ClServer_MessageStruct message )
{
    entity player = message.player
    
    if ( Fire_IsPlayerAdmin( player ) )
        return message

    if ( !Fire_IsChatEnabled() )
    {
        message.shouldBlock = true
        Fire_ChatServerPrivateMessage( player, "聊天已关闭（仅管理员可发言）" )
        return message
    }

    if ( Fire_IsMutePlayer( player ) )
    {
        float muteEndTime = Fire_GetPlayerMuteEndTime( player )
        
        if ( muteEndTime == 0 )
        {
            message.shouldBlock = true
            Fire_ChatServerPrivateMessage( player, "你已被永久禁言" )
            return message
        }

        float timeRemaining = muteEndTime - Time()
        
        if ( timeRemaining > 0 )
        {
            message.shouldBlock = true
            Fire_ChatServerPrivateMessage( player, "你已被禁言，剩余 " + format( "%.1f", timeRemaining ) + " 秒" )
            return message
        }
        else
        {
            Fire_UnmutePlayer( player )
        }
    }
    
    return message
}

string function Fire_GetPrefix()
{
    return SvFire.prefix
}

void function Fire_SetPrefix( string newPrefix )
{
    SvFire.prefix = newPrefix
}

void function Fire_ChatServerPrivateMessage( entity player, string message )
{
    Chat_ServerPrivateMessage( player, SvFire.prefix + message, false, false )
}

void function Fire_ChatServerBroadcast( string message )
{
    Chat_ServerBroadcast( SvFire.prefix + message, false )
}