#include <sourcemod>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "PM",
	author = "xSLOW",
	description = "Send a private message to a player",
	version = "1.0"
};

bool g_IsPMon[MAXPLAYERS + 1];
Handle g_PM_Cookie;

public void OnPluginStart()
{
    LoadTranslations("common.phrases");

    RegConsoleCmd("sm_pm", Command_SendPM);
    RegConsoleCmd("sm_pmon", Command_PMon);
    RegConsoleCmd("sm_pmoff", Command_PMoff);

    g_PM_Cookie = RegClientCookie("PM On/Off", "PM On/Off", CookieAccess_Protected);
}


public void OnClientPutInServer(int client)
{
	g_IsPMon[client] = true;
	char buffer[64];
	GetClientCookie(client, g_PM_Cookie, buffer, sizeof(buffer));
	if(StrEqual(buffer,"0"))
		g_IsPMon[client] = false;
}


public Action Command_PMoff(int client, int args) 
{
	PrintToChat(client, " ★ \x02PM\'s are now disabled.");
	g_IsPMon[client] = false;
	SetClientCookie(client, g_PM_Cookie, "0");
}
public Action Command_PMon(int client, int args) 
{
	PrintToChat(client, " ★ \x04PM\'s are now enabled.");
	g_IsPMon[client] = true;
	SetClientCookie(client, g_PM_Cookie, "1");
}

public Action Command_SendPM(int client, int args)
{
    if(args < 2)
	{
		ReplyToCommand(client, " \x04[SM]: \x07Usage sm_pm <#player> <message>");
		return Plugin_Handled;
	}

    char ClientName[32], TargetName[32], iTarget[64], Message[200];

    GetCmdArg(1, iTarget, sizeof(iTarget));
    GetCmdArg(2, Message, sizeof(Message));

    int Target = FindTarget(client, iTarget, true, false);


    if(g_IsPMon[client] == false || g_IsPMon[Target] == false) 
	{
		PrintToChat(client, " \x03[PM System]: \x07You or the target disabled the PM\'s");
		return Plugin_Handled;
	}

    if(Target == client)
    {
		ReplyToCommand( client, " \x03[PM System]: \x07You can\'t send yourself a message!" );
		return Plugin_Handled;
    }

    if(Target == -1)
        return Plugin_Handled;
    
    if(IsClientValid(Target))
    {
        GetClientName(Target, TargetName, sizeof(TargetName));
        GetClientName(client, ClientName, sizeof(ClientName));
        GetCmdArgString(Message, sizeof(Message));

        ReplaceStringEx(Message, sizeof(Message), iTarget, "", -1, -1, true);

        PrintToChat(Target, " \x03[PM from \x04%s\x03]: \x01%s", ClientName, Message);
        PrintToChat(client, " \x03[PM to \x04%s\x03]: \x01%s", TargetName, Message);
    }

    return Plugin_Handled;
}



stock bool IsClientValid(int client)
{
    if (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
        return true;
    return false;
}