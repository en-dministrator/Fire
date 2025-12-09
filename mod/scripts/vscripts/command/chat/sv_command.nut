global function ChatCommand_Command_Init

void function ChatCommand_Command_Init()
{
    AddChatCommandCallback( "/command", ChatCommand_Command )
}

void function ChatCommand_Command(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() == 0 ){
        Fire_ChatServerPrivateMessage(player, "用法: /command <command>")
        return
    }
    string command = ""
    for(int i; i < args.len(); i++){
        command += args[i] + " "
    }
    ServerCommand(command)
}