global function ChatCommand_Mhp_Init

void function ChatCommand_Mhp_Init()
{
    AddChatCommandCallback( "/mhp", ChatCommand_Mhp_Threaded )
}

void function ChatCommand_Mhp_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin(player) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() != 2 ){
        Fire_ChatServerPrivateMessage( player, "用法: /mhp <name/all/imc/militia> <health>" )
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

    string args1 = args[1]

    if( hasNonDigit(args1) ){
        Fire_ChatServerPrivateMessage( player, "血量必须是数字" )
        return
    }
    int hp = args1.tointeger()
    if( hp < 1 ){
        Fire_ChatServerPrivateMessage( player, "血量必须大于等于1" )
        return
    }

    foreach(target in targets){
        string targetName = target.GetPlayerName()
        if( !IsAlive( target ) ){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 已死亡" )
            continue
        }
        target.SetMaxHealth(hp)
        Fire_ChatServerPrivateMessage( player, "已设置玩家 " + targetName + " 最大血量为" + hp )
    }
}