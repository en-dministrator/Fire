global function ChatCommand_Loadout_Init

void function ChatCommand_Loadout_Init()
{
    AddChatCommandCallback( "/load",  ChatCommand_Loadout_Threaded )
}

void function ChatCommand_Loadout_Threaded(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法：/loadout <name/all/imc/militia>")
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
    if(targets.len() == 0){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + arg0 )
        return
    }

    foreach( target in targets ){
        string name = target.GetPlayerName()
        if( !IsAlive( target ) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + name + " 已死亡")
            continue
        }
        if( IsPilot( target ) ) {
            Loadouts_TryGivePilotLoadout( target )
            Fire_ChatServerPrivateMessage( player, "已为玩家 " + name + " 给予铁驭装备" )
        } else if( player.IsTitan() ) {
            Loadouts_TryGiveTitanLoadout( target )
            Fire_ChatServerPrivateMessage( player, "已为玩家 " + name + " 给予泰坦装备" )
        }
    }
}