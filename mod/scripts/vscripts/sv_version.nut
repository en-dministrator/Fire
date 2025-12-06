untyped
global function FireVersion_Init
global function Fire_GetVersion
global function Fire_IsDevVersion
global function Fire_HasNewVersion
global function Fire_GetLatestVersion
global function IsVersionNewer

bool FireVersionHasUpdate = false      // 是否有新版本
string FireLatestVersion = ""          // 最新版本号
string FireModVersion = ""             // 当前版本号

void function FireVersion_Init()
{
    FireModVersion = NSGetModVersionByModName("Fire")
    AddCallback_OnClientConnected(OnClientConnected)
    AddChatCommandCallback("/checkver", OnChatCommand_CheckVer)
    thread CheckForNewVersion()
}

void function OnClientConnected(entity player)
{
    if( Fire_IsPlayerAdmin(player) && Fire_HasNewVersion() )
    {
        Fire_ChatServerPrivateMessage(
            player,
            format("当前版本：%s，最新版本：%s", FireModVersion, Fire_GetLatestVersion())
        )
    }
}
void function OnChatCommand_CheckVer(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(Fire_IsDevVersion()){
        Fire_ChatServerPrivateMessage(player, "当前使用的是开发版本，不参与新版本自动检测。")
        return
    }
    Fire_ChatServerPrivateMessage(player, "正在检测新版本...")
    CheckForNewVersion(player)
}

void function CheckForNewVersion(entity manualChecker = null)
{
    if(Fire_IsDevVersion())
        return

    table<string, array<string> > params
    NSHttpGet( "https://thunderstore.io/api/experimental/package/MiyamaeNonoa/Fire/", params, 
    void function( HttpRequestResponse response ) : (manualChecker)
    {
        table data = DecodeJSON(response.body)
        string latestVersion = string(data["latest"]["version_number"])
        FireLatestVersion = latestVersion

        if(IsVersionNewer(latestVersion, FireModVersion))
        {
            FireVersionHasUpdate = true
            print(format("[Fire]检测到新版本：%s（当前：%s）", latestVersion, FireModVersion))
            Fire_NotifyAllAdmins(format("检测到新版本！当前：%s，最新：%s", FireModVersion, FireLatestVersion))
        }
        else
        {
            FireVersionHasUpdate = false
            if(manualChecker != null)
            {
                Fire_ChatServerPrivateMessage(
                    manualChecker,
                    format("已是最新版本：%s", FireModVersion)
                )
            }
        }
    }, void function( HttpRequestFailure response ) : (manualChecker)
    {
        print("[Fire]版本检查请求失败")
        if(manualChecker != null)
            Fire_ChatServerPrivateMessage(manualChecker, "版本检查请求失败")
    } )
}

string function Fire_GetVersion()
{
    return FireModVersion
}

bool function Fire_IsDevVersion()
{
    string ver = NSGetModVersionByModName("Fire")
    return (ver.find("-dev") != null)
}

bool function Fire_HasNewVersion()
{
    return FireVersionHasUpdate
}

string function Fire_GetLatestVersion()
{
    return FireLatestVersion
}

bool function IsVersionNewer(string remote, string Local)
{
    array<string> remoteParts = split(remote, ".")
    array<string> localParts = split(Local,".")
    float len = max(remoteParts.len(), localParts.len())
    for(int i=0; i<len; ++i)
    {
        int remoteNum = (i < remoteParts.len()) ? remoteParts[i].tointeger() : 0
        int localNum = (i < localParts.len()) ? localParts[i].tointeger() : 0
        if(remoteNum > localNum)
            return true
        if(remoteNum < localNum)
            return false
    }
    return false
}