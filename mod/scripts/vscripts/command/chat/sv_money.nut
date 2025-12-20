global function ChatCommand_Money_Init

void function ChatCommand_Money_Init()
{
    AddChatCommandCallback( "/money", ChatCommand_Money_Threaded )
}

void function ChatCommand_Money_Threaded( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() != 2 ){
        Fire_ChatServerPrivateMessage( player, "Usage: /money <name/all> <money>" )
        return
    }

    string arg0 = args[0]
    array<entity> targets

    switch( arg0.tolower() ){
        case "all":
            targets = GetPlayerArray()
            break
        default:
            targets = GetPlayersByNamePrefix( arg0 )
            break
    }
    if( targets.len() == 0 ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + arg0 )
        return
    }

    string arg1 = args[1]

    if( hasNonDigit(arg1) ){
        Fire_ChatServerPrivateMessage( player, "钱必须是数字" )
        return
    }

    int money = arg1.tointeger()

    if( money > 10000 ){
        Fire_ChatServerPrivateMessage( player, "你最多只能增加10000钱" )
        return
    }

    foreach( target in targets ){
        string targetName = target.GetPlayerName()
        if( !IsAlive( target ) ){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 已死亡" )
            continue
        }
        AddMoneyToPlayer( target, money )
        Fire_ChatServerPrivateMessage( player, "已为玩家 " + targetName + " 增加 " + money + " 钱" )
    }
}