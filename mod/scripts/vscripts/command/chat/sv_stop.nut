global function ChatCommand_Stop_Init


void function ChatCommand_Stop_Init()
{
    AddChatCommandCallback( "/stop",  ChatCommand_Stop_Threaded )
}

void function ChatCommand_Stop_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /stop <reason>")
        return
    }

    foreach(player in GetPlayerArray())
    {
        if( !IsValid( player ) )
            continue
        NSDisconnectPlayer( player, args[0] )
    }
    wait 0.2
    ServerCommand( "quit" )
}