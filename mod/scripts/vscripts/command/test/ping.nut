global function Test_ChatCommand_Ping_Init


void function Test_ChatCommand_Ping_Init()
{
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_mid_pilot.vmt" )
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_front_pilot.vmt" )
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_back.vmt" )

    AddChatCommandCallback( "/ping", Ping )
}

void function Ping(entity player, array<string> args)
{
    vector playerOrigin = player.GetOrigin()

    entity sprite = CreateSprite_Server( playerOrigin, player.EyeAngles(), $"materials/vgui/hud/weapons/target_ring_front_pilot.vmt", "0 255 0", 0.5, 5 )
    sprite.kv.fade_dist = 990000
    SetTeam( sprite, player.GetTeam() )
    sprite.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
    sprite.SetOwner( player )
}

entity function CreateSprite_Server( vector origin, vector angles, asset sprite, string lightcolor = "255 0 0", float scale = 0.5, int rendermode = 10 )
{
    entity env_sprite = CreateEntity( "env_sprite" )
    env_sprite.SetScriptName( UniqueString( "molotov_sprite" ) )
    env_sprite.kv.rendermode = rendermode
    env_sprite.kv.origin = origin
    env_sprite.kv.angles = angles
    env_sprite.kv.rendercolor = lightcolor
    env_sprite.kv.renderamt = 255
    env_sprite.kv.framerate = "30.0"
    env_sprite.SetValueForModelKey( sprite )
    env_sprite.kv.scale = string( scale )
    env_sprite.kv.spawnflags = 1
    env_sprite.kv.GlowProxySize = 64.0
    env_sprite.kv.HDRColorScale = 4.0
    DispatchSpawn( env_sprite )
    EntFireByHandle( env_sprite, "ShowSprite", "", 0, null, null )

    return env_sprite
}