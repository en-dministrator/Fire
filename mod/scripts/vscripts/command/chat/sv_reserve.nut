global function ChatCommand_Reserve_Init

void function ChatCommand_Reserve_Init()
{
    AddChatCommandCallback( "/reserve", ChatCommand_Reserve_Threaded )
}

void function ChatCommand_Reserve_Threaded( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage( player, "Usage: /reserve <TeamReserve>" )
        return
    }

    string arg0 = args[0]

    if( hasNonDigit(arg0) ){
        Fire_ChatServerPrivateMessage( player, "团队预留必须是数字" )
        return
    }

    int teamReserve = arg0.tointeger()

    if( teamReserve <= 0 ){
        Fire_ChatServerPrivateMessage( player, "团队预留必须大于0" )
        return
    }
    UpdateTeamReserve( teamReserve )
    Fire_ChatServerPrivateMessage( player, "已设置团队预留: " + teamReserve )
}