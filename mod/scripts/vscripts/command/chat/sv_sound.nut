global function ChatCommand_Sound_Init

void function ChatCommand_Sound_Init()
{
    AddChatCommandCallback( "/sound", ChatCommand_Sound )
}

void function ChatCommand_Sound(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if( args.len() != 2 )
    {
        Fire_ChatServerPrivateMessage( player, "用法: /sound <name/all/imc/militia> <sound>" )
        return
    }

    string arg0 = args[0]
    array<entity> targets

    switch( arg0.tolower() )
    {
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
    if(targets.len() == 0)
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + arg0 )
        return
    }

    string sound = args[1]
    
    foreach(target in targets)
    {
        string name = target.GetPlayerName()
        if( !IsAlive(target)){
            Fire_ChatServerPrivateMessage( player, "玩家 " + target.GetPlayerName() + " 已死亡" )
            continue
        }
        EmitSoundOnEntityOnlyToPlayer( target, target, sound )
        Fire_ChatServerPrivateMessage( player, "已向玩家 " + name + " 播放声音 " + sound )
    }
}