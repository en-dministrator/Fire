global function Fire_GetAdminArray
global function Fire_IsPlayerAdmin
global function Fire_SetPlayerAdmin
global function Fire_NotifyAllAdmins

array<entity> function Fire_GetAdminArray()
{
    array<entity> admins = []
    foreach(player in GetPlayerArray())
    {
        if( !IsValid(player) )
            continue
        if( Fire_IsPlayerAdmin(player) )
            admins.append(player)
    }
    return admins
}

bool function Fire_IsPlayerAdmin(entity player)
{
    if(!IsValid(player))
        return false
    return split(GetConVarString("Fire_AdminUIDs"), ",").contains(player.GetUID())
}

void function Fire_SetPlayerAdmin(entity player, bool enabled)
{
    if(!IsValid(player))
        return
    
    string adminString = GetConVarString("Fire_AdminUIDs")
    string playerUID = player.GetUID()
    
    adminString = strip(adminString)
    array<string> adminUIDs = split(adminString, ",")
    
    for(int i = adminUIDs.len() - 1; i >= 0; i--)
    {
        if(strip(adminUIDs[i]) == "")
        {
            adminUIDs.remove(i)
        }
    }
    
    bool wasChanged = false
    
    if(enabled)
    {
        if(adminUIDs.find(playerUID) == -1)
        {
            adminUIDs.append(playerUID)
            wasChanged = true
        }
    }else
    {
        int index = adminUIDs.find(playerUID)
        if (index != -1)
        {
            adminUIDs.remove(index)
            wasChanged = true
        }
    }
    
    if(wasChanged)
    {
        string newAdminString = join(adminUIDs, ",")
        SetConVarString("Fire_AdminUIDs", newAdminString)
    }
}

string function join(array<string> strings, string separator)
{ 
    if(strings.len() == 0)
        return ""
    
    string result = ""
    bool first = true
    
    foreach(string str in strings)
    {
        if(str == "")
            continue
        if(first)
        {
            result = str
            first = false
        }else
        {
            result += separator + str
        }
    }
    
    return result
}

void function Fire_NotifyAllAdmins(string msg)
{
    array<entity> admins = Fire_GetAdminArray()
    foreach(admin in admins)
    {
        Fire_ChatServerPrivateMessage(admin, msg)
    }
}