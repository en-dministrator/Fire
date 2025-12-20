global function ChatCommand_Bcst_Init

void function ChatCommand_Bcst_Init()
{
    AddChatCommandCallback( "/bcst", ChatCommand_Bcst_Threaded )
}

void function ChatCommand_Bcst_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    string msg = ""
    for(int i; i < args.len(); i++)
    {
        msg += args[i] + " "
    }

    Fire_ChatServerBroadcast( msg )
}