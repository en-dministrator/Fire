untyped
global function Fire_Init

void function Fire_Init()
{
    AddCallback_OnClientConnected(OnClientConnected)
}

void function OnClientConnected(entity player)
{
    string announcement = GetConVarString("Fire_Announcement")
    if(announcement != ""){
        Fire_ChatServerPrivateMessage(player, "公告：" + announcement)
    }
}