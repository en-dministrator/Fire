global function ChatCommand_Switch_Init

void function ChatCommand_Switch_Init()
{
    AddChatCommandCallback( "/swit", ChatCommand_Switch )
}

void function ChatCommand_Switch(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /swit <name/all/imc/militia>")
        return
    }

    string arg0 = args[0]
    array<entity> targets = []

    switch(arg0.tolower()){
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
    if(targets.len() == 0){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + arg0)
        return
    }

    foreach(target in targets)
    {
        if( !IsValid(target) || !IsValid(target) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        int team = GetEnemyTeam( target.GetTeam() )
        try{
            SetTeam(target, team)
            Fire_ChatServerPrivateMessage(player, "已设置玩家 " + target.GetPlayerName() + " 的队伍为 " + team)
        }catch (error){
            Fire_ChatServerPrivateMessage(player, "错误: " + string(error))
        }
    }
}