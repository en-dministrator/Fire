global function ChatCommand_Uid_Init

void function ChatCommand_Uid_Init()
{
    AddChatCommandCallback( "/uid", ChatCommand_Uid_Threaded )
}

void function ChatCommand_Uid_Threaded( entity player, array<string> args )
{
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /uid < name >")
        return
    }

    string args0 = args[0]
    entity target = GetPlayerByNamePrefix(args0)
    
    if( target == null ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }
    if( !IsValid( target ) ){
        Fire_ChatServerPrivateMessage( player, "无效玩家: " + args0 )
        return
    }
    
    Fire_ChatServerPrivateMessage( player, "Name: " + target.GetPlayerName() + " | UID: " + target.GetUID() )
}