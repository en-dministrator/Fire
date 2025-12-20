global function ChatCommand_Skip_Init
global function Fire_Skip

void function ChatCommand_Skip_Init()
{
    AddChatCommandCallback( "/skip", ChatCommand_Skip_Threaded )
}

void function ChatCommand_Skip_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 0)
    {
        Fire_ChatServerPrivateMessage(player, "用法: /skip")
        return
    }

    Fire_Skip()
}

void function Fire_Skip()
{
    SetGameState(eGameState.Postmatch)
    Fire_ChatServerBroadcast("已跳过当前地图")
}