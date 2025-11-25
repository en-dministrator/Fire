global function SpacebasedCannon_Init

const float REQUEST_TIMEOUT = 20.0
const float COUNTDOWN_DELAY = 1.2
const int DAMAGE_INNER_RADIUS = 200
const int DAMAGE_OUTER_RADIUS = 200
const vector FX_COLOR = <255, 255, 255>
const vector REAPER_SPAWN_OFFSET = <0, 0, 3000>

struct Request
{
    entity player
    entity target
    string targetName
    float requestTime
}

table<string, Request> PendingRequests = {}

void function SpacebasedCannon_Init()
{
    RegisterWeaponDamageSource( "SpacebasedCannon", "Space-based Cannon" )
    RegisterSignal( "SpacebasedConfirm" )
    RegisterSignal( "SpacebasedCancel" )
    
    AddChatCommandCallback("/sbc", ServerChatCommand_Spacebased_Cannon)
    //AddChatCommandCallback("/sbc_test_fx", ServerChatCommand_TestFX)
}

void function ServerChatCommand_TestFX(entity player, array<string> args)
{
    vector playerOrigin = player.GetOrigin()
    vector offset = <0, 100, 0>
    
    array<asset> fxList = [
        $"ar_rocket_strike_small_friend",
        $"ar_rocket_strike_small_foe", 
        $"ar_rocket_strike_large_friend",
        $"ar_rocket_strike_large_foe",
        $"wpn_orbital_beam"
    ]
    
    foreach( fx in fxList )
    {
        PlayFX( fx, playerOrigin + offset )
        offset.y += 500
    }
}

void function ServerChatCommand_Spacebased_Cannon(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin(player) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    string playerUID = player.GetUID()
    
    if( playerUID in PendingRequests ){
        HandleSpacebasedCannonConfirmation(player, args)
        return
    }
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法: /sbc <玩家名称>")
        return
    }

    entity target = GetPlayerByNamePrefix(args[0])
    if( !IsValid(target) ){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args[0])
        return
    }

    // 创建请求
    CreatePendingRequest(player, target)
    thread RequestExpireCheck(playerUID)
}

void function CreatePendingRequest(entity player, entity target)
{
    Request request
    request.player = player
    request.target = target
    request.targetName = target.GetPlayerName()
    request.requestTime = Time()
    
    PendingRequests[player.GetUID()] <- request

    // 显示请求信息
    DisplayRequestInfo(player, request.targetName)
}

void function DisplayRequestInfo(entity player, string targetName)
{
    array<string> messages = [
        "|==================[天基炮]==================|",
        " 目标: " + targetName,
        "|============================================|",
        "请输入 /sbc (yes/no) 确认执行/取消操作",
        "天基炮将在" + REQUEST_TIMEOUT + "秒后自动取消"
    ]
    
    foreach( message in messages )
    {
        Fire_ChatServerPrivateMessage(player, message)
    }
}

void function HandleSpacebasedCannonConfirmation(entity player, array<string> args)
{
    string playerUID = player.GetUID()
    
    if( !(playerUID in PendingRequests) )
        return

    Request request = PendingRequests[playerUID]
    
    // 检查超时
    if( Time() - request.requestTime > REQUEST_TIMEOUT ){
        delete PendingRequests[playerUID]
        Fire_ChatServerPrivateMessage(player, "天基炮已取消，请重新输入")
        return
    }
    
    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "请输入 /sbc (yes/no) 确认执行/取消操作")
        return
    }

    string confirm = args[0].tolower()
    ProcessConfirmation(player, request, confirm)
}

void function ProcessConfirmation(entity player, Request request, string confirm)
{
    string playerUID = player.GetUID()
    
    switch( confirm )
    {
        case "yes":
        case "y":
        case "confirm":
            delete PendingRequests[playerUID]
            player.Signal( "SpacebasedConfirm" )
            thread ExecuteSpacebasedCannon(player, request.target)
            break
            
        case "no":
        case "n":
        case "cancel":
            delete PendingRequests[playerUID]
            player.Signal( "SpacebasedCancel" )
            Fire_ChatServerPrivateMessage(player, "已取消对目标 " + request.targetName + " 的天基炮")
            break
            
        default:
            Fire_ChatServerPrivateMessage(player, "请输入: /sbc yes 或 /sbc no")
            break
    }
}

void function ExecuteSpacebasedCannon(entity player, entity target)
{
    if( !IsValid(player) || !IsValid(target) )
        return

    // 广播开始信息
    BroadcastStartInfo(player, target)
    wait 1.0

    // 执行倒计时
    ExecuteCountdown()
    
    vector targetOrigin = target.GetOrigin()

    // 准备目标并生成特效
    target.SetInvulnerable()
    entity fx = CreateTargetFX(targetOrigin)
    
    // 生成并等待Reaper落地
    entity reaper = CreateAndSpawnReaper(player, targetOrigin)
    thread WaitUntilReaperGround(reaper)
    
    // 执行攻击
    target.ClearInvulnerable()
    wait 0.1
    
    ExecuteExplosion(player, targetOrigin)
    
    // 清理
    if( IsValid(reaper) )
        reaper.Destroy()
        
    wait 0.5
    StopFX(fx)
}

void function BroadcastStartInfo(entity player, entity target)
{
    array<string> messages = [
        "|==================[天基炮]==================|",
        " 玩家: " + player.GetPlayerName(),
        " 目标: " + target.GetPlayerName(), 
        "|============================================|"
    ]
    
    foreach( message in messages )
    {
        Fire_ChatServerBroadcast(message)
    }
}

void function ExecuteCountdown()
{
    for( int i = 4; i > 0; i-- ) 
    {
        Fire_ChatServerBroadcast("倒计时：" + i.tostring())
        wait COUNTDOWN_DELAY
    }
}

entity function CreateTargetFX(vector origin)
{
    entity fx = PlayFX($"P_ar_titan_droppoint", origin)
    EffectSetControlPointVector(fx, 1, FX_COLOR)
    return fx
}

entity function CreateAndSpawnReaper(entity player, vector origin)
{
    entity reaper = CreateSuperSpectre(player.GetTeam(), origin + REAPER_SPAWN_OFFSET, <0, 0, 0>)
    DispatchSpawn(reaper)
    thread SuperSpectre_WarpFall(reaper)
    return reaper
}

void function ExecuteExplosion(entity player, vector origin)
{
    Explosion(
        origin,                             // 爆炸中心点
        player,                             // 爆炸发起者
        player,                             // 伤害施加者
        9999,                               // 基础伤害
        9999,                               // 对重甲伤害
        DAMAGE_INNER_RADIUS,                // 内圈半径
        DAMAGE_OUTER_RADIUS,                // 外圈半径
        SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES, // 爆炸标记
        player.GetOrigin(),                 // 抛射物原点
        0,                                  // 冲击力
        damageTypes.explosive,              // 伤害类型
        eDamageSourceId.SpacebasedCannon,   // 伤害来源
        ARC_CANNON_FX_TABLE                 // 特效表
    )
}

void function WaitUntilReaperGround(entity ent)
{
    if( !IsValid(ent) )
        return
        
    while( ent.IsOnGround() )
    {
        WaitFrame()
    }
}

void function RequestExpireCheck(string playerUID)
{
    if( !(playerUID in PendingRequests) )
        return

    Request request = PendingRequests[playerUID]
    
    request.player.EndSignal("SpacebasedConfirm")
    wait REQUEST_TIMEOUT
    
    if( playerUID in PendingRequests && IsValid(request.player) )
    {
        delete PendingRequests[playerUID]
        Fire_ChatServerPrivateMessage(request.player, "天基炮已取消")
    }
}