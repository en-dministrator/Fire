global function ChatCommand_Reload_Init

void function ChatCommand_Reload_Init()
{
    AddChatCommandCallback( "/reload", ChatCommand_Reload_Threaded )
}

void function ChatCommand_Reload_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 0){
        Fire_ChatServerPrivateMessage(player, "用法: /reload")
        return
    }

    ServerCommand("reload")
    Fire_ChatServerBroadcast("已重新加载")
}