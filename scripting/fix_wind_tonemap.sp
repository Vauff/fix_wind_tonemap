#include <sourcemod>
#include <sdktools>
#include <entitylump>

#pragma semicolon 1
#pragma newdecls required

bool g_bCreatedTonemap;

public Plugin myinfo =
{
	name = "Fix Wind/Tonemap Carryover",
	author = "Vauff",
	description = "Fixes env_wind & env_tonemap_controller settings carrying over into other maps",
	version = "1.0",
	url = "https://github.com/Vauff/fix_wind_tonemap"
};

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin only runs on CS:GO!");
}

public void OnMapEntitiesParsed()
{
	bool windExists = false;
	bool tonemapExists = false;
	g_bCreatedTonemap = false;

	for (int i = 0; i < EntityLump.Length(); i++)
	{
		EntityLumpEntry entity = EntityLump.Get(i);
		char classname[64];
		entity.GetNextKey("classname", classname, sizeof(classname));

		if (StrEqual(classname, "env_wind"))
			windExists = true;
		else if (StrEqual(classname, "env_tonemap_controller"))
			tonemapExists = true;

		delete entity;
	}

	if (!windExists)
	{
		EntityLumpEntry wind = EntityLump.Get(EntityLump.Append());
		wind.Append("classname", "env_wind");

		// Default to no wind (max/min gustdelay is required to prevent server crash)
		wind.Append("gustdirchange", "0");
		wind.Append("gustduration", "0");
		wind.Append("maxgust", "0");
		wind.Append("mingust", "0");
		wind.Append("maxgustdelay", "20");
		wind.Append("mingustdelay", "10");
		wind.Append("maxwind", "0");
		wind.Append("minwind", "0");

		delete wind;
	}

	if (!tonemapExists)
	{
		EntityLumpEntry tonemap = EntityLump.Get(EntityLump.Append());
		tonemap.Append("classname", "env_tonemap_controller");

		g_bCreatedTonemap = true;
		delete tonemap;
	}
}

public void OnMapStart()
{
	int tonemap = FindEntityByClassname(-1, "env_tonemap_controller");

	if (g_bCreatedTonemap && tonemap != -1)
	{
		// Default values from https://github.com/perilouswithadollarsign/cstrike15_src/blob/master/game/server/env_tonemap_controller.cpp#L126
		AcceptEntityInput(tonemap, "UseDefaultAutoExposure");
		AcceptEntityInput(tonemap, "UseDefaultBloomScale");
		SetVariantFloat(1.0);
		AcceptEntityInput(tonemap, "SetTonemapRate");
		SetVariantFloat(2.5);
		AcceptEntityInput(tonemap, "SetBloomExponent");
		SetVariantFloat(1.0);
		AcceptEntityInput(tonemap, "SetBloomSaturation");
		SetVariantFloat(2.0);
		AcceptEntityInput(tonemap, "SetTonemapPercentBrightPixels");
		SetVariantFloat(65.0);
		AcceptEntityInput(tonemap, "SetTonemapPercentTarget");
		SetVariantFloat(3.0);
		AcceptEntityInput(tonemap, "SetTonemapMinAvgLum");
	}
}