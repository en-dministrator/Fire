global function ChatCommand_Model_Init

void function ChatCommand_Model_Init()
{
    AddChatCommandCallback( "/model", ChatCommand_Model_Threaded )
}

void function ChatCommand_Model_Threaded( entity player, array<string> args )
{
    if( !Fire_IsPlayerAdmin(player) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() != 2 ){
        Fire_ChatServerPrivateMessage( player, "用法: /model <name/all/imc/militia> <model>" )
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

    string strModel = args[1]
    asset model = StringToAsset( strModel )

    foreach(target in targets){
        string targetName = target.GetPlayerName()
        if( !IsAlive( target ) ){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 已死亡" )
            continue
        }
        target.SetModel( model )
        Fire_ChatServerPrivateMessage( player, "已设置玩家 " + targetName + " 模型为 " + strModel )
    }
}