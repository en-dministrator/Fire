global function ChatCommand_SendMsg_Init

void function ChatCommand_SendMsg_Init()
{
    AddChatCommandCallback( "/sendmsg", ChatCommand_SendMsg_Threaded )
}

void function ChatCommand_SendMsg_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() < 2 ){
        Fire_ChatServerPrivateMessage( player, "用法: /sendmsg <name/all/imc/militia> <message>" )
        return
    }

    string arg0 = args[0]
    array<entity> targets

    switch( arg0.tolower() ){
        case "all":
            targets = GetPlayerArray()
            break
        case "imc":
            targets = GetPlayerArrayOfTeam( TEAM_IMC )
            break
        case "militia":
            targets = GetPlayerArrayOfTeam( TEAM_MILITIA )
            break
        default:
            targets = GetPlayersByNamePrefix( arg0 )
            break
    }
    if( targets.len() == 0 ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + arg0 )
        return
    }
    
    string msg = ""
    for( int i = 1; i < args.len(); i++ )
    {
        msg += args[i] + " "
    }
    
    foreach( target in targets )
    {
        Chat_Impersonate( target, msg, false )
    }
}