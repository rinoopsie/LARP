// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#pragma tabsize 0
#pragma warning disable 239
#pragma warning disable 214
#pragma warning disable 213
#pragma warning disable 217
#pragma warning disable 219

#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <zcmd>
#include <foreach>

// Suburban Clothes

new DynamicPickup:EnterShopPickup;
new DynamicPickup:ExitShopPickup;
new DynamicPickup:ClothingPickup;
new ShopNPC;
#define DIALOG_CLOTHES_SHOP 2222
#define DIALOG_CLOTHES_CONFIRM 2223
new bool:gIsInClothingMenu[MAX_PLAYERS];

// ��������� ��� ������������� �������
#define PICKUP_TYPE_SHOP_ENTER   1
#define PICKUP_TYPE_SHOP_EXIT    2
#define PICKUP_TYPE_SHOP_CLOTHES 3

// ������� ��� ��������
new Float:gShopEnterPos[4] = {2112.8, -1211.4, 24.0, 0.0};          // ���� �������
new Float:gShopInsidePos[4] = {203.89999, -48.4, 1001.8, 0.0};      // ����� ������
new Float:gShopExitPos[4] = {203.8, -51.0, 1001.8, 0.0};            // ����� ������
new Float:gShopOutsidePos[4] = {2112.8999, -1214.4, 24.0, 180.0};   // ����� �� �����
new Float:gClothingPos[4] = {208.6, -45.2, 1001.8, 0.0};            // ������� ������ ������

// ������ ������ � ID � �����
enum SkinInfo {
    SkinID,
    SkinPrice,
    SkinName[32]
}

new Skins[][SkinInfo] = {
    {13, 4500, "bfyst"},
    {22, 4000, "bmyst"},
    {23, 5500, "wmybmx"},
    {99, 4500, "wmyro"},
    {100, 6500, "wmycr"},
    {19, 6000, "bmydj"},
    {181, 5500, "vwmycr"},
    {247, 6500, "bikera"},
    {248, 6500, "bikerb"},
    {261, 5000, "wmycd1"},
    {241, 4000, "smyst"},
    {242, 4000, "smyst2"}
};

// ������� ������ ���� ������ ������
ShowClothingSelection(playerid)
{
    new string[512];
    format(string, sizeof(string), "������\t����\n");

    // ��������� ����� � ������ � ���������� ��� ������� ��������������
    for (new i = 0; i < sizeof(Skins); i++)
    {
        format(string, sizeof(string), "%s%s\t$%d\n", string, Skins[i][SkinName], Skins[i][SkinPrice]);
    }
    ShowPlayerDialog(playerid, DIALOG_CLOTHES_SHOP, DIALOG_STYLE_TABLIST_HEADERS, "������� ������", string, "�������", "������");
}




new RentedVehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};


// SANN
// ����������� ��������
#define FACTION_SANN 11  // ID �������
#define MAX_SANN_RANK 14 // ���������� ������

// ������ ������ SANN
new gSANNRanks[MAX_SANN_RANK][32] = {
    "Intern",
    "Assistant Reporter",
    "Field Reporter",
    "News Editor",
    "Camera Operator",
    "Journalist",
    "Lead Reporter",
    "News Anchor",
    "Senior Journalist",
    "Chief Editor",
    "Producer",
    "Head of Broadcasting",
    "Vice President",
    "President"
};

// ������ ������ ��� ������� ����� (����� ��������� ���������� ID ������)
new gSANNSkins[MAX_SANN_RANK] = {
    147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147, 147
};

// ���������� ������ � ����������
new Float:gSANNSpawn[4] = {2465.294677, 2095.147705, 62.446033, 0.003}; // ����� � ����
new Float:gSANNEnter[4] = {1788.4, -1298.7, 13.4, 0.003}; // ���� � ����
new Float:gSANNExit[4] = {2467.443359, 2095.486572, 62.446033, 0.003}; // ����� �� ����
new Float:gSANNExitSpawn[4] = {1788.5, -1292.6, 13.6, 0.003}; // ����� �� ����� ����� ������
new Float:gSANNRoofEnter[4] = {2467.456054, 2084.032226, 62.446033, 0.003}; // ���� �� �����
new Float:gSANNRoofSpawn[4] = {1823.5, -1306.2, 131.7, 0.003}; // ����� �� �����
new Float:gSANNRoofExit[4] = {1823.9, -1311.7, 131.7, 0.003}; // ����� � �����
new Float:gSANNRoofReturn[4] = {2464.844970, 2084.500244, 62.446033, 0.003}; // ����� � ���� ����� �����

// ������ ��� ���������� SANN
new SANNVehicles[6];
new const Float:SANNVehicleSpawns[][4] = {
    {1822.5000000, -1278.9000000, 132.0000000, 0.0000000}, // News Chopper
    {1770.4000000, -1302.4000000, 13.8000000, 10.0000000}, // Newsvan 1
    {1765.9000000, -1304.5000000, 13.8000000, 9.9980000}, // Newsvan 2
    {1761.8000000, -1306.6000000, 13.8000000, 9.9980000}, // Newsvan 3
    {1813.0000000, -1276.8000000, 13.8000000, 9.9980000}, // Newsvan 4
    {1808.8000000, -1277.6000000, 13.8000000, 9.9980000}  // Newsvan 5
};
new const SANNVehicleModels[] = {488, 582, 582, 582, 582, 582};

// ������
new SANNEntrancePickup;
new SANNExitPickup;
new SANNRoofEnterPickup;
new SANNRoofExitPickup;


CreateSANNVehicles()
{
    for(new i = 0; i < sizeof(SANNVehicles); i++)
    {
        new vehicleid = CreateVehicle(
            SANNVehicleModels[i],
            SANNVehicleSpawns[i][0],
            SANNVehicleSpawns[i][1],
            SANNVehicleSpawns[i][2],
            SANNVehicleSpawns[i][3],
            1, // ����� ����
            1, // ����� ����
            -1
        );

        SANNVehicles[i] = vehicleid;

        new plate[32];
        format(plate, sizeof(plate), "SANN %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);

        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}

// ���������� ���������� ��� ������� ������ ������
new bool:gLiveActive = false;          // ������� �� ����
new gLiveHost;                         // ID ��������
new gLiveGuest = INVALID_PLAYER_ID;    // ID �����
new gLiveType;                         // ��� ����� (1 - ��������, 2 - ����)
new Text3D:gLiveLabel;                 // 3D ����� ��� �������

// ���������� ��� ������������ �������� SMS
new gLastSMSTime[MAX_PLAYERS];


// Aztec
#define FACTION_AZTEC 10
#define MAX_AZTEC_RANK 14

// ������� ��� ������ � ������
new gAztecRanks[MAX_AZTEC_RANK][32] = {
    "Novato",
    "Soldado",
    "Maton",
    "Luchador",
    "Veterano",
    "Capataz",
    "Cazador",
    "Lider de Escuadron",
    "Sicario",
    "Comandante",
    "Jefe de Operaciones",
    "Mano Derecha",
    "Consejero",
    "El Jefe"
};

// ����������� ����� Aztec
new gAztecSkins[MAX_AZTEC_RANK] = {
    114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114, 114 // ���������� ����������� ���� Aztec
};

// ���������� ������ � ����������
new Float:gAztecSpawn[4] = {2647.7, -2021.6, 13.5, 90.003}; // �������� �����
new Float:gAztecEnter[4] = {2651.1001, -2021.9, 14.2, -79.997}; // ���� � ����
new Float:gAztecExit[4] = {318.70001, 1114.5, 1083.9, 0.003}; // ����� �� ����
new Float:gAztecExitSpawn[4] = {2648.3, -2023.3, 13.5, 100.002}; // ����� ����� ������
new Float:gAztecSpawnInside[4] = {318.89999, 1118.3, 1083.9, -19.997}; // ����� � ����

// ������ ��� ����������
new AztecVehicles[5];
new const Float:AztecVehicleSpawns[][4] = {
    {2643.2000000, -2031.8000000, 13.8000000, 0.0000000},
    {2658.3999000, -2041.8000000, 14.1000000, 0.0000000},
    {2653.7000000, -2041.5000000, 14.1000000, 0.0000000},
    {2659.3999000, -2007.3000000, 13.4000000, -90.0000000},
    {2651.3000000, -2007.2000000, 13.4000000, -90.0000000}
};
new const AztecVehicleModels[] = {482, 579, 579, 567, 567}; // Burrito, Huntley, Huntley, Savanna, Savanna

// ������
new AztecEntrancePickup;
new AztecExitPickup;

CreateAztecVehicles()
{
    for(new i = 0; i < sizeof(AztecVehicles); i++)
    {
        new vehicleid = CreateVehicle(
            AztecVehicleModels[i],
            AztecVehicleSpawns[i][0],
            AztecVehicleSpawns[i][1],
            AztecVehicleSpawns[i][2],
            AztecVehicleSpawns[i][3],
            2, // ������� ����
            2, // ������� ����
            -1
        );

        AztecVehicles[i] = vehicleid;

        // ������������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "AZTEC %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);

        // ������������� ��������� ����������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}


// Vagos
#define FACTION_VAGOS 9
#define MAX_VAGOS_RANK 14

// Vagos ranks array
new gVagosRanks[MAX_VAGOS_RANK][32] = {
    "Novato",
    "Ladron",
    "Maton",
    "Pandillero",
    "Veterano",
    "Soldado",
    "El Patron",
    "Sicario",
    "Comandante",
    "Teniente",
    "Capitan",
    "OG",
    "El Mano Derecha",
    "Jefe"
};

// Vagos skins array (���������� ����������� ����� Vagos)
new gVagosSkins[MAX_VAGOS_RANK] = {
    108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108
};

// Vagos spawn coordinates
new Float:gVagosSpawn[4] = {-69.0, 1354.9, 1080.2, 0.003};
new Float:gVagosEnter[4] = {2288.3, -1104.4, 38.7, 0.003};
new Float:gVagosExit[4] = {-68.7, 1351.0, 1080.2, 0.003};
new Float:gVagosExitSpawn[4] = {2288.1001, -1106.8, 38.0, 170.002};

// Vagos vehicles array
new VagosVehicles[5];
new const Float:VagosVehicleSpawns[][4] = {
    {2263.5000000, -1101.9000000, 38.5000000, 150.0000000},
    {2267.6001000, -1104.1000000, 38.5000000, 149.9960000},
    {2274.3999000, -1107.3000000, 37.9000000, 154.0000000},
    {2278.3000000, -1109.5000000, 37.9000000, 153.9950000},
    {2287.8000000, -1117.5000000, 38.2000000, 90.0000000}
};
new const VagosVehicleModels[] = {579, 579, 566, 566, 482}; // Huntley, Huntley, Tahoma, Tahoma, Burrito
// Pickups
new VagosEntrancePickup;
new VagosExitPickup;

CreateVagosVehicles()
{
    for(new i = 0; i < sizeof(VagosVehicles); i++)
    {
        new vehicleid = CreateVehicle(
            VagosVehicleModels[i],
            VagosVehicleSpawns[i][0],
            VagosVehicleSpawns[i][1],
            VagosVehicleSpawns[i][2],
            VagosVehicleSpawns[i][3],
            6, // ������ ���� (Yellow)
            6, // ��� �� ������ ��� ������� �����
            -1
        );
        VagosVehicles[i] = vehicleid;
        new plate[32];
        format(plate, sizeof(plate), "VAGOS %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}



// Ballas

// Ballas faction definition
#define FACTION_BALLAS 8
#define MAX_BALLAS_RANK 14

// Ballas ranks array
new gBallasRanks[MAX_BALLAS_RANK][32] = {
    "Thug",
    "Hustler",
    "Gangsta",
    "Soldier",
    "Enforcer",
    "Shot Caller",
    "Lieutenant",
    "Street Boss",
    "Underboss",
    "Capo",
    "Gang Captain",
    "OG",
    "Right Hand",
    "Boss"
};

// Ballas skins array (you can adjust the skin IDs)
new gBallasSkins[MAX_BALLAS_RANK] = {
    102, // Thug
    102, // Hustler
    102, // Gangsta
    102, // Soldier
    102, // Enforcer
    102, // Shot Caller
    108, // Lieutenant
    103, // Street Boss
    103, // Underboss
    103, // Capo
    103, // Gang Captain
    103, // OG
    103, // Right Hand
    104  // Boss
};

// Ballas spawn coordinates
new Float:gBallasSpawn[4] = {2001.2, -1120.3, 26.8, 0.0};


// ������ ��� ���������� Ballas
new BallasVehicles[5];
new const Float:BallasVehicleSpawns[][4] = {
    {2003.9000000, -1120.6000000, 26.6000000, 180.0000000}, // Tahoma
    {1995.2000000, -1128.7000000, 26.2000000, 90.0000000}, // Huntley
    {1988.1000000, -1128.7000000, 26.3000000, 90.0000000}, // Huntley
    {2007.5996000, -1129.4004000, 25.2000000, 90.0000000}, // Tahoma
    {2016.7000000, -1129.2000000, 25.0000000, 90.0000000}  // Savanna
};
new const BallasVehicleModels[] = {566, 579, 579, 566, 567};

// ���������� ������� � ������ Ballas
new Float:gBallasEnter[4] = {2000.0, -1113.7, 27.1, 0.003};          // ���� � ����
new Float:gBallasExit[4] = {2333.1001, -1077.6, 1049.0, -179.995};   // ����� �� ����
new Float:gBallasExitSpawn[4] = {2000.1, -1117.2, 26.8, -179.995};   // ����� �� �����
new Float:gBallasSpawnInside[4] = {2332.8, -1073.5, 1049.0, 0.003};  // ����� � ���������

// ������
new BallasEntrancePickup;
new BallasExitPickup;

// ������� ��� �������� ���������� Ballas
CreateBallasVehicles()
{
    for(new i = 0; i < sizeof(BallasVehicles); i++)
    {
        // ������� ��������� (���������� ����)
        new vehicleid = CreateVehicle(
            BallasVehicleModels[i],
            BallasVehicleSpawns[i][0],
            BallasVehicleSpawns[i][1],
            BallasVehicleSpawns[i][2],
            BallasVehicleSpawns[i][3],
            85, // ������ ���� (����������)
            85, // ������ ���� (����������)
            -1
        );

        BallasVehicles[i] = vehicleid;

        // ������������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "BALLAS %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);

        // ������������� ��������� ����������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}

//


#define DIALOG_HELP 6000

// ARMY
#define MAX_ARMY_RANK 14
#define DIALOG_SHOW_MILITARY_ID 8005  // ���������, ��� ���� ID �� ����������� � ������� ���������

// ������� ��� ������ � ������ Army
new gARMYSkins[MAX_ARMY_RANK] = {
    287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 179, 179
};

new gARMYRanks[MAX_ARMY_RANK][32] = {
    "Private",
    "Private First Class",
    "Corporal",
    "Sergeant",
    "Staff Sergeant",
    "Sergeant First Class",
    "Master Sergeant",
    "First Sergeant",
    "Sergeant Major",
    "Second Lieutenant",
    "First Lieutenant",
    "Captain",
    "Major",
    "Colonel"
};

// ���������� ������ Army
new Float:gARMYSpawn[4] = {211.60001, 1861.8, 13.1, 0.003};

// � ������ �����, ��� ���������� ������ ������� ����������
new ARMYVehicles[14]; // ������ 14 ��� ���� ������������ �������

// ������ ��������� ������ ����������
new const Float:ARMYVehicleSpawns[][4] = {
    {282.1000100, 1949.7000000, 18.2000000, -90.0000000}, // Barracks 1
    {281.8999900, 1955.4000000, 18.2000000, -90.0000000}, // Barracks 2
    {281.8999900, 1960.8000000, 18.2000000, -90.0000000}, // Barracks 3
    {282.2000100, 1983.1000000, 18.0000000, -90.0000000}, // FBI Rancher 1
    {282.3999900, 1988.1000000, 18.0000000, -90.0000000}, // FBI Rancher 2
    {282.1000100, 1993.9000000, 18.0000000, -90.0000000}, // FBI Rancher 3
    {281.6000100, 2016.3000000, 17.5000000, -90.0000000}, // Police Car 1
    {281.5000000, 2021.6000000, 17.5000000, -90.0000000}, // Police Car 2
    {280.8999900, 2026.1000000, 17.5000000, -90.0000000}, // Police Car 3
    {280.7999900, 2030.6000000, 17.5000000, -90.0000000}, // Police Car 4
    {316.7999900, 2051.2000000, 16.6000000, 0.0000000},   // Leviathan 1
    {299.7000100, 2049.5000000, 16.6000000, 0.0000000},   // Leviathan 2
    {317.1000100, 2029.8000000, 17.9000000, 0.0000000},   // Maverick 1
    {302.7999900, 2027.0000000, 17.9000000, 0.0000000}    // Maverick 2
};

// ������ ������� ����������
new const ARMYVehicleModels[] = {
    433, // Barracks
    433, // Barracks
    433, // Barracks
    490, // FBI Rancher
    490, // FBI Rancher
    490, // FBI Rancher
    597, // Police Car (SFPD)
    597, // Police Car (SFPD)
    597, // Police Car (SFPD)
    597, // Police Car (SFPD)
    417, // Leviathan
    417, // Leviathan
    487, // Maverick
    487  // Maverick
};


// ���������� ���������� ��� ����� Army
new ARMYGateObject1;
new ARMYGateObject2;
new ARMYGateTimer1 = -1;
new ARMYGateTimer2 = -1;
new bool:ARMYGateState1 = false;
new bool:ARMYGateState2 = false;

// GOV
// ����������� ��� GOV
#define MAX_GOV_RANK 14

// ������� ��� ������ � ������ GOV
new gGOVSkins[MAX_GOV_RANK] = {295, 295, 295, 295, 295, 295, 295, 295, 295, 295, 295, 295, 294, 294}; // ��������� ���������� ID ������
new gGOVRanks[MAX_GOV_RANK][32] = {
    "Trainee",
    "Assistant",
    "Driver",
    "Chief of Staff",
    "Security Guard",
    "Chief of Security",
    "Lawyer",
    "Attorney General",
    "Deputy Minister",
    "Minister",
    "Deputy Mayor",
    "Mayor",
    "Deputy Governor",
    "Governor"
};

// GOV Salaries
new GOVSalaries[MAX_GOV_RANK] = {
    500,    // Trainee
    1000,   // Assistant
    1200,   // Driver
    1500,   // Chief of Staff
    2000,   // Security Guard
    2500,   // Chief of Security
    3000,   // Lawyer
    3500,   // Attorney General
    4000,   // Deputy Minister
    5000,   // Minister
    6000,   // Deputy Mayor
    7000,   // Mayor
    8000,   // Deputy Governor
    9000    // Governor
};

// ���������� GOV
new Float:gGOVSpawn[4] = {358.10001, 162.0, 1025.8, -79.995};              // �������� ����� �������
new Float:gGOVParkingEnter[4] = {1413.3, -1790.5, 15.4, 0.003};           // ���� � ��������
new Float:gGOVParkingSpawn[4] = {1409.9, -1790.4, 13.5, 90.004};          // ����� �� ��������
new Float:gGOVParkingExit[4] = {368.79999, 194.0, 1008.4, 0.003};         // ����� �� ��������
new Float:gGOVParkingIntSpawn[4] = {366.39999, 191.89999, 1008.4, -179.995}; // ����� � ��������� ����� ��������

new Float:gGOVRoofEnter[4] = {371.0, 160.0, 1025.8, 0.003};              // ���� �� �����
new Float:gGOVRoofExit[4] = {1438.0, -1786.5, 33.4, 0.003};              // ����� �� �����
new Float:gGOVRoofSpawn[4] = {1434.5, -1786.6, 33.4, 90.004};            // ����� �� �����
new Float:gGOVRoofIntSpawn[4] = {371.0, 162.8, 1025.8, 0.003};           // ����� � ��������� ����� �����

// ������ GOV
new GOVParkingEnterPickup;    // ����� ����� � ��������
new GOVParkingExitPickup;     // ����� ������ �� ��������
new GOVRoofEnterPickup;       // ����� ����� �� �����
new GOVRoofExitPickup;        // ����� ������ �� �����

// ������ ��� �������� ID ���������� GOV
new GOVVehicles[7]; // 7 ������������ �������

// ������� � ������������ � �������� ����������
new const Float:GOVVehicleSpawns[][4] = {
    {1404.2000000, -1775.5000000, 13.5000000, 90.0000000}, // Admiral 1
    {1404.2002000, -1779.2002000, 13.5000000, 90.0000000}, // Admiral 2
    {1404.2000000, -1783.1000000, 14.1000000, 90.0000000}, // Huntley 1
    {1404.2002000, -1786.7998000, 14.1000000, 90.0000000}, // Huntley 2
    {1521.4000000, -2619.6001000, 14.5000000, 0.0000000},  // Shamal
    {1416.3000000, -1790.7000000, 33.7000000, 90.0000000}, // Maverick
    {1403.7000000, -1790.8000000, 13.5000000, 90.0000000}  // Stretch
};

new const GOVVehicleModels[] = {445, 445, 579, 579, 519, 487, 409}; // ID �������



// ���������
#define DIALOG_DEALERSHIP 7700
#define DIALOG_VEHICLE_MENU 7701
#define DIALOG_VEHICLE_ACTION 7702
#define DIALOG_VEHICLE_KEYS 7703
#define KEY_Y 89

// ��������� ��� ����� �����������
#define DEALERSHIP_PREMIUM 1
#define DEALERSHIP_MEDIUM 2
#define DEALERSHIP_ECONOMY 3
#define DEALERSHIP_MOTO 4
#define DEALERSHIP_HELI 5

// ��������� ������ ��� ����������
enum DealershipInfo {
    dExists,
    dType,
    dName[32],
    Float:dNPCX,
    Float:dNPCY,
    Float:dNPCZ,
    Float:dNPCAngle,
    dNPCSkin,
    Float:dMenuX,
    Float:dMenuY,
    Float:dMenuZ,
    Float:dSpawnX,
    Float:dSpawnY,
    Float:dSpawnZ,
    Float:dSpawnAngle,
    Text3D:dLabel,
    dPickup,
    dActor
}

new Dealership[5][DealershipInfo];

enum VehicleInfo {
    bool:vExists,
    vModel,
    vName[32],
    vPrice,
    vDealershipType,
    vRealLife[32] // �������� ��������� ���������
}

new DealershipVehicles[100][VehicleInfo];

// ��������� ��� ������� ���������� ������
enum OVehicleInfo {
    bool:ovExists,
    ovModel,
    ovOwner[MAX_PLAYER_NAME],
    Float:ovParkX,
    Float:ovParkY,
    Float:ovParkZ,
    Float:ovParkAngle,
    ovVehicleID
}

new OwnedVehicle[MAX_PLAYERS][5][OVehicleInfo];



// ����
#define MAX_HOUSES 100
#define HOUSE_TAX_RATE 1 // $1 � ���
#define DIALOG_HOUSE_MENU 8000
#define DIALOG_HOUSE_BUY 8001
#define DIALOG_HOUSE_SELL 8002
#define DIALOG_HOUSE_SELL_TO 8003
#define DIALOG_HOUSE_INFO 8004

new const Float:HouseLocations[][20] = {
    // ��� 1
    {2486.3999, -1645.1, 14.1,  // ���� (X, Y, Z)
     2486.6001, -1647.9, 14.1,  // ����� �� ����� (X, Y, Z)
     223.39999, 1289.7, 1092.1, // ����� � ���� (X, Y, Z)
     223.10001, 1286.8, 1092.1, // ����� �� ���� (X, Y, Z)
     150000.0, // ���� - ������ ��� Float
     1.0,      // ��������
     0.0},    // Dimension

    // ��� 2
    {2498.5, -1642.1, 14.1,    // ���� (X, Y, Z)
     2498.3, -1644.5, 13.8,    // ����� �� ����� (X, Y, Z)
     222.8, 1288.7, 1093.9,    // ����� � ���� (X, Y, Z)
     223.2, 1286.7, 1093.9,    // ����� �� ���� (X, Y, Z)
     150000.0, // ���� - ������ ��� Float
     1.0,      // ��������
     0.0}     // Dimension
};

enum HouseInfo {
    bool:hExists,
    hOwner[MAX_PLAYER_NAME],
    Float:hEntranceX,
    Float:hEntranceY,
    Float:hEntranceZ,
    Float:hSpawnX,
    Float:hSpawnY,
    Float:hSpawnZ,
    Float:hSpawnInteriorX,
    Float:hSpawnInteriorY,
    Float:hSpawnInteriorZ,
    Float:hExitX,
    Float:hExitY,
    Float:hExitZ,
    hPrice,
    bool:hLocked,
    hInteriorID,
    hPickup,
    Text3D:hLabel,
    hLastTax,
    bool:hOwned,
    hVirtualWorld
}
new House[MAX_HOUSES][HouseInfo];

// ���

#define MAX_BUSINESSES 100
#define DEFAULT_TAX_RATE 10 // 10% ����� �� ���������
#define DIALOG_SHOW_BUSINESS 7100
#define DIALOG_BUY_BUSINESS 7101

// ��������� ��� �������� ���������� � �������
enum BusinessInfo {
    bool:bExists,
    bName[64],
    bOwner[MAX_PLAYER_NAME],
    Float:bEntranceX,
    Float:bEntranceY,
    Float:bEntranceZ,
    bPrice,
    bProfitPerHour,
    bLastProfit,
    bPickup,
    Text3D:bLabel
}
new Business[MAX_BUSINESSES][BusinessInfo];

//

#define ANIM_BOMBER "BOMBER"
#define ANIM_BOM_PLANT "BOM_Plant"
#define TIMER_STASH "OnStashPlaced"

// NPC Big Jhon
#define DIALOG_MISSIONS 7000
#define DIALOG_STASH_CONFIRM 7001
// �������� ��� ����������� � ������ �����
#define DIALOG_TITLE_MISSIONS "������� �� Big John"
#define DIALOG_CONTENT_MISSIONS "��������� ��������\n������ ����"
#define DIALOG_BUTTON_SELECT "�������"
#define DIALOG_BUTTON_CANCEL "������"

// ���������� ����������
new Text3D:BigJohnLabel;
new bool:PlayerDoingStashMission[MAX_PLAYERS];
new PlayerStashesLeft[MAX_PLAYERS];
new PlayerNextStashTimer[MAX_PLAYERS];
new PlayerCurrentCP[MAX_PLAYERS];
new const Float:BIGJOHN_POS[4] = {2538.3999, -1705.0, 13.4, 0.003}; // x, y, z, angle

// ���������� ����� �� ���������������� ������
new const Float:StashPoints[][3] = {
    {2460.7, -1708.6, 13.5},
    {2322.0, -1693.8, 13.5},
    {2307.2, -1813.5, 13.5},
    {2031.1, -1885.1, 13.6},
    {1953.6, -1837.5, 6.7},
    {1693.8, -1780.4, 4.0},
    {1364.2, -1694.0, 8.6},
    {1380.1, -1631.6, 13.5},
    {1565.8, -1564.7, 13.5},
    {1425.9, -1291.1, 13.6},
    {1323.1, -1237.2, 13.5},
    {1204.9, -1213.1, 18.8},
    {1118.7, -1252.5, 16.0},
    {1020.2, -794.29999, 102.0},
    {915.0, -671.5, 117.2},
    {1071.7, -905.59998, 43.4},
    {900.79999, -1076.0, 24.3},
    {777.0, -1309.1, 13.6},
    {787.29999, -1552.7, 13.6},
    {714.59998, -1640.3, 2.4},
    {777.90002, -1714.9, 5.0},
    {742.20001, -1849.9, 8.0},
    {822.5, -2049.7, 12.9},
    {997.29999, -2075.3, 8.1},
    {1008.0, -2227.0, 13.1},
    {1192.8, -2345.2, 13.8},
    {1367.4, -2369.5, 13.5},
    {1292.1, -2043.5, 58.6},
    {1388.6, -1892.8, 13.5},
    {1512.0, -1930.9, 22.0},
    {1640.8, -1887.6, 13.6},
    {1699.1, -1844.2, 13.5},
    {1730.5, -1754.7, 13.5},
    {1687.1, -1675.8, 20.2},
    {1679.3, -1611.1, 22.5},
    {1798.8, -1442.5, 13.4},
    {1952.5, -1382.5, 18.6},
    {2002.3, -1308.5, 20.9},
    {2085.7, -1259.0, 24.0},
    {2164.7, -1200.0, 24.1},
    {2192.7, -1090.5, 40.5},
    {2234.8999, -1045.8, 55.6},
    {2317.3999, -1062.3, 52.1},
    {2573.3999, -1072.2, 69.3},
    {2672.8, -1113.9, 69.3},
    {2809.7, -1289.6, 42.4},
    {2819.8, -1439.8, 40.1},
    {2907.1001, -1597.0, 11.0},
    {2776.8999, -1685.4, 10.3},
    {2766.8999, -2061.1001, 12.4},
    {2637.6001, -2111.3999, 13.5},
    {2399.0, -2142.3, 13.5},
    {2288.0, -2105.2, 13.5},
    {2133.2, -2099.0, 13.5},
    {2098.2, -2055.3999, 13.5},
    {2007.6105, -2065.218, 16.85716},
    {1935.3, -2096.3999, 13.6},
    {1852.1, -2142.3999, 13.5},
    {1811.5, -2067.1001, 13.6},
    {1793.7, -1975.8, 13.5}
};



// Grove
#define FACTION_GROVE 7
#define MAX_GROVE_RANK 6

// ������� ��� ������ � ������ Grove Street
new gGroveRanks[MAX_GROVE_RANK][32] = {
    "Outsider",
    "Thug",
    "Hustler",
    "O.G.",
    "Shot Caller",
    "Gang Leader"
};

new gGroveSkins[MAX_GROVE_RANK] = {107, 106, 105, 269, 271, 270};

// ���������� ������ Grove Street
new Float:gGroveSpawn[4] = {2496.3, -1696.5, 1014.7, -179.995};
new Float:gGroveEnter[4] = {2495.5, -1691.3, 14.8, -179.995};
new Float:gGroveExit[4] = {2496.0, -1692.0, 1014.7, 0.003};
new Float:gGroveExitSpawn[4] = {2495.3, -1686.8, 13.5, 0.003};


// ����������� ��� ���������� Grove
new GroveVehicles[7]; // �������� � 9 �� 7
new const Float:GroveVehicleSpawns[][4] = {
    {2500.3999, -1657.9000, 13.8000, 64.0000},    // ������� � 13.4 �� 13.8
    {2486.8000, -1655.2000, 13.7000, 92.0000},    // ������� � 13.3 �� 13.7
    {2507.2000, -1664.3000, 13.8000, 24.0000},    // ������� � 13.4 �� 13.8
    {2497.6001, -1682.3000, 13.9000, 280.0000},   // ������� � 13.5 �� 13.9, ��������� ���� � -80 �� 280
    {2488.3000, -1682.6000, 13.8000, 270.0000},   // ������� � 13.4 �� 13.8, ��������� ���� � -90 �� 270
    {2507.8999, -1672.3000, 13.7000, 340.0000},   // ������� � 13.3 �� 13.7, ��������� ���� � -20 �� 340
    {2504.3999, -1678.4000, 13.7000, 320.0000}    // ������� � 13.3 �� 13.7, ��������� ���� � -40 �� 320
};
new const GroveVehicleModels[] = {567, 567, 567, 579, 579, 412, 412};

//cuff&uncuff
new bool:PlayerCuffed[MAX_PLAYERS];
new PlayerCuffedTime[MAX_PLAYERS];


#define VIRTUAL_WORLD_SHERIFF 2


// Sheriff
#define MAX_SHERIFF_RANK 13
new gSheriffSkins[MAX_SHERIFF_RANK] = {71, 300, 300, 284, 267, 267, 265, 266, 280, 281, 310, 282, 283};
new gSheriffRanks[MAX_SHERIFF_RANK][32] = {
    "Cadet", "Officer", "Officer II", "Officer III", "Sergeant", "Sergeant II",
    "Lieutenant", "Captain", "Captain II", "Inspector", "Assistant Sheriff", "Deputy Sheriff Chief", "Sheriff"
};

new Float:gSheriffSpawn[4] = {247.89999, 72.0, 986.79999, 0.003};

new SheriffVehicles[7]; // �������� � 9 �� 7
new const Float:SheriffVehicleSpawns[][4] = {
    {622.5000000, -611.0000000, 17.6000000, -90.0000000},
    {622.9000200, -606.0999800, 17.5000000, -90.0000000},
    {615.2000100, -601.5000000, 17.1000000, -90.0000000},
    {615.5000000, -597.0996100, 17.1000000, -90.0000000},
    {614.0999800, -574.7999900, 26.4000000, 0.0000000},
    {616.2999900, -590.7999900, 17.1000000, -90.0000000},
    {638.0000000, -610.5000000, 16.4000000, -90.0000000}
};
new const SheriffVehicleModels[] = {599, 599, 596, 596, 497, 596, 579};
#define DIMENSION_SHERIFF 1 // ���������� dimension ��� Sheriff


// Add after other faction salary definitions
new SheriffSalaries[MAX_SHERIFF_RANK] = {500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 9000};


new SheriffDoorObject;
new bool:SheriffDoorState = false; // false - �������, true - �������

//



#define ApplyAnimationEx(%0,%1,%2,%3,%4,%5,%6,%7,%8,%9) \
    ApplyAnimation(%0,(%1),(%2),%3,%4,%5,%6,%7,%8,%9)
    
#define ANIM_CRACK "CRACK"
#define ANIM_CRCKDETH2 "crckdeth2"
#define DIALOG_TITLE_ATM_WITHDRAW "������ �����"
#define DIALOG_INFO_ATM_WITHDRAW "������� ����� ��� ������:"
#define DIALOG_BUTTON_WITHDRAW "�����"
#define DIALOG_BUTTON_CANCEL "������"
#define TIMER_CLOSE_GATE "CloseGate"
#define TIMER_FORMAT "i"



// EMS
#define MAX_EMS_RANK 14
new gEMSSkins[MAX_EMS_RANK] = {276, 276, 276, 276, 275, 276, 276, 276, 275, 275, 275, 274, 70, 228};
new gEMSRanks[MAX_EMS_RANK][64] = {
    "Intern", "Junior Paramedic", "Paramedic", "Senior Paramedic",
    "Nurse", "Senior Nurse", "Doctor", "Senior Doctor",
    "Head Doctor", "Medical Supervisor", "Chief of Staff",
    "Deputy Chief of Medical Services", "Chief of Medical Services",
    "Director of Health Services"
};

new Float:gEMSEnter[4] = {1172.0, -1325.4, 15.4, 0.003};
new Float:gEMSSpawn[4] = {2462.656250, -1118.583740, 1312.040527, 0.003};
new Float:gEMSExit[4] = {2464.597656, -1120.524536, 1312.040527, 0.003};
new Float:gEMSExitSpawn[4] = {1178.3, -1325.9, 14.1, 0.003};

new EMSVehicles[9];
new const Float:EMSVehicleSpawns[][4] = {
    {1177.4000000, -1339.1000000, 14.2000000, -90.0000000},
    {1177.8000000, -1308.8000000, 14.1000000, -90.0000000},
    {1131.6000000, -1332.1000000, 13.4000000, -90.0000000},
    {1131.6000000, -1327.6000000, 13.5000000, -90.0000000},
    {1131.5000000, -1323.5000000, 13.5000000, -90.0000000},
    {1118.4000000, -1357.3000000, 25.7000000, -82.0000000},
    {1124.4000000, -1328.7000000, 13.1000000, 0.0000000},
    {1111.0000000, -1329.2000000, 13.0000000, 0.0000000},
    {1097.8000000, -1328.7000000, 13.1000000, 0.0000000}
};
new const EMSVehicleModels[] = {416, 416, 560, 560, 560, 487, 560, 560, 560};

// EMS Function

#define MAX_EMS_CALLS 10
#define EMS_CALL_TIME 120000 // 2 ������ � �������������

new Float:EMSSpawnPoints[][] = {
    {2433.703857, -1125.594726, 1312.046508},
    {2433.724609, -1127.432617, 1312.046508},
    {2434.051025, -1128.594726, 1312.046508},
    {2434.512939, -1130.432617, 1312.046508},
    {2433.946044, -1131.592407, 1312.046508},
    {2434.967285, -1133.553100, 1312.046508},
    {2434.057617, -1134.594726, 1312.046508},
    {2434.969726, -1136.432617, 1312.046508},
    {2434.007080, -1137.594726, 1312.046508},
    {2434.497314, -1139.432617, 1312.046508},
    {2429.496337, -1137.486572, 1312.046508},
    {2429.495361, -1134.712890, 1312.046508},
    {2429.496337, -1131.779296, 1312.046508},
    {2429.497314, -1128.826171, 1312.046508},
    {2429.495605, -1125.626708, 1312.046508},
    {2430.815673, -1109.154785, 1312.046508},
    {2430.875000, -1106.579467, 1312.046508},
    {2430.871093, -1103.719238, 1312.046508},
    {2430.850097, -1100.891357, 1312.044555},
    {2430.833007, -1098.549560, 1312.044555}
};

enum E_EMS_CALL {
    bool:isActive,
    playerID,
    Float:posX,
    Float:posY,
    Float:posZ,
    timeLeft
}
new EMSCalls[MAX_EMS_CALLS][E_EMS_CALL];

new PlayerDeathTimer[MAX_PLAYERS];
new PlayerHealTimer[MAX_PLAYERS];

#define COLOR_INFO 0x00FF00AA  // ������� ���� ��� �������������� ���������
#define COLOR_ERROR 0xFF0000AA // ������� ���� ��� ��������� �� �������
#define COLOR_EMS 0xFF8C00AA   // ��������� ���� ��� ��������� EMS
#define COLOR_USAGE 0xFFFF00AA // ������ ���� ��� ��������� � ������������� ������
#define COLOR_GREY 0xAFAFAFAA

new bool:PlayerIsDying[MAX_PLAYERS];
new Float:LastPlayerPos[MAX_PLAYERS][3];
new PlayerLastSkin[MAX_PLAYERS];
new PlayerSkins[MAX_PLAYERS];


// FIB
new FBIVehicles[10];
new const Float:FBIVehicleSpawns[][4] = {
    {1534.4000000, -1397.8000000, 14.3000000, -90.0000000},
    {1543.8000000, -1397.6000000, 14.3000000, -90.0000000},
    {1553.4000000, -1397.7000000, 14.3000000, -90.0000000},
    {1523.6000000, -1398.0000000, 14.3000000, -90.0000000},
    {1501.9000000, -1368.3000000, 14.1000000, 0.0000000},
    {1501.9000000, -1377.0000000, 14.1000000, 0.0000000},
    {1510.8000000, -1366.6000000, 14.1000000, 30.0000000},
    {1517.0000000, -1375.2000000, 14.1000000, 49.9980000},
    {1544.2002000, -1352.5996000, 329.7000100, 0.0000000}
};
new const FBIVehicleModels[] = {490, 490, 490, 490, 579, 579, 413, 413, 487};

#define MAX_FBI_RANK 14
new gFBISkins[MAX_FBI_RANK] = {286, 161, 286, 163, 164, 165, 166, 166, 98, 144, 187, 294, 294, 295};
new gFBIRanks[MAX_FBI_RANK][32] = {
    "Trainee", "Jr. Agent", "Agent", "Senior Agent", "Senior Lead Agent",
    "Special Agent I", "Special Agent II", "Special Agent III", "Secret Agent",
    "Dep. Head", "Head", "Assistant of Director", "Deputy of Director", "Director"
};

new Float:gFBIEnter[4] = {1569.5, -1335.1, 16.5, 140.004};
new Float:gFBISpawn[4] = {2261.664550, -227.019042, 982.599487, 0.003};
new Float:gFBIExit[4] = {2261.913574, -229.580245, 982.599487, 0.003};
new Float:gFBIExitSpawn[4] = {1572.3, -1331.4, 16.5, 0.003};


new bool:FBIGateState1 = false, bool:FBIGateState2 = false;
new FBIGateTimer1 = -1, FBIGateTimer2 = -1;

new FBIGateObject1 = INVALID_OBJECT_ID;
new FBIGateObject2 = INVALID_OBJECT_ID;
#define DIALOG_FBI_ARMOR 5001

new FBISalaries[MAX_FBI_RANK] = {600, 1200, 1800, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 8500, 9000};





// ���������

#define DIALOG_ATM_MENU 3000
#define DIALOG_ATM_WITHDRAW 3001
#define ATM_COMMISSION 0.02 // 2% ��������

new Float:gATMLocations[][3] = {
    {2249.7, -1666.9, 15.1},
    {1971.3, -1966.6, 13.2},
    {1843.5, -1860.4, 13.0},
    {1548.1, -1679.5, 13.2},
    {1178.4, -1290.4, 13.2},
    {1008.8, -929.29999, 42.3},
    {715.90002, -1425.8, 13.2},
    {513.40002, -1647.8, 17.7},
    {-83.3, -1183.6, 1.4}
};

#define DIALOG_TITLE_BANK_ACCOUNT "���������� ����"
#define DIALOG_BUTTON_OPERATIONS "��������"
#define DIALOG_BUTTON_CLOSE "�������"
#define DIALOG_TITLE_ATM "��������"
#define DIALOG_BUTTON_SELECT "�������"
#define DIALOG_BUTTON_CANCEL "������"


//

#define SafeShowPlayerDialog(%0,%1,%2,%3,%4,%5,%6) \
    ShowPlayerDialog(%0,%1,%2,(%3),(%4),(%5),(%6))

// BANK
#define DIALOG_BANK_MENU 2000
#define DIALOG_BANK_OPERATIONS 2001
#define DIALOG_BANK_DEPOSIT 2002
#define DIALOG_BANK_WITHDRAW 2003
#define MESSAGE_BANK_OPERATIONS "���������� ��������"
#define MESSAGE_DEPOSIT "��������� ����"
#define MESSAGE_WITHDRAW "����� �� �����"
#define DIALOG_TITLE_WITHDRAW "������ �� �����"
#define DIALOG_INFO_WITHDRAW "������� ����� ��� ������:"
#define DIALOG_BUTTON1_WITHDRAW "�����"
#define DIALOG_BUTTON2_WITHDRAW "������"
#define DIALOG_TITLE_DEPOSIT "���������� �����"
#define DIALOG_INFO_DEPOSIT "������� ����� ��� ����������:"
#define DIALOG_BUTTON1_DEPOSIT "���������"
#define DIALOG_BUTTON2_DEPOSIT "������"
#define DIALOG_TITLE_BANK_OPERATIONS "���������� ��������"
#define DIALOG_INFO_BANK_OPERATIONS "1. ��������� ����\n2. ����� �� �����"
#define DIALOG_BUTTON1_SELECT "�������"
#define DIALOG_BUTTON2_BACK "�����"
#define DIALOG_MSG_INVALID_AMOUNT "�������� ����� ��� ������������ �������."
#define DIALOG_MSG_INVALID_AMOUNT_WITHDRAW "�������� ����� ��� ������������ ������� �� �����."
#define DIALOG_MSG_DEPOSIT_SUCCESS "�� ������� ��������� ���� �� $%d. ������� ������: $%d"
#define DIALOG_MSG_WITHDRAW_SUCCESS "�� ������� ����� �� ����� $%d. ������� ������: $%d"
new BankMenuPickup;
new bool:gPlayerInBankMenu[MAX_PLAYERS];


#define COLOR_WHITE 0xFFFFFFAA

// ����� LSPD
new LSPDDoorObject;
new bool:LSPDDoorState = false; // false - �������, true - �������


// ������ LSPD
new gateObject1;
new gateObject2;
new bool:gateState1 = false; // false = �������, true = �������
new bool:gateState2 = false;
new gateTimer1 = -1;
new gateTimer2 = -1;
#define COLOR_YELLOW 0xFFFF00AA


// ����������� �������� � ��������
#define DIALOG_VEHICLE_CONTROL 1000
#define DIALOG_VEHICLE_DOORS 1001
#define MAX_FUEL 70.0
#define FUEL_PRICE 2

// ������� ��� �������� ������ � ������� � ��������� ��������� �� ������
new Float:VehicleFuel[MAX_VEHICLES];
new PlayerText:FuelTextDraw[MAX_PLAYERS];

// ������� ��� ����������� ������� ���������� ������������ ���������
ShowCarControlDialog(playerid)
{
    new string[512];
    format(string, sizeof(string),
        "������� �����\n\
        ������� �����\n\
        �������� ���������\n\
        ��������� ���������\n\
        ������� ��������\n\
        ������� ��������\n\
        ���������� �������\n\
        �������� ����\n\
        ��������� ����\n\
        �������� ������\n\
        ��������� ������");

    new title[32], button1[16], button2[16];
    format(title, sizeof(title), "���������� �������");
    format(button1, sizeof(button1), "�������");
    format(button2, sizeof(button2), "������");
    ShowPlayerDialog(playerid, DIALOG_VEHICLE_CONTROL, DIALOG_STYLE_LIST, title, string, button1, button2);
}

// ������� ��� ����������� ������� ���������� ������� ������
ShowCarDoorsDialog(playerid)
{
    new string[512];
    format(string, sizeof(string),
        "������� ������������ �����\n\
        ������� ������������ �����\n\
        ������� ������������ �����\n\
        ������� ������������ �����\n\
        ������� ����� ������ �����\n\
        ������� ����� ������ �����\n\
        ������� ������ ������ �����\n\
        ������� ������ ������ �����");

	new title[32], button1[16], button2[16];
	format(title, sizeof(title), "���������� �������");
	format(button1, sizeof(button1), "�������");
	format(button2, sizeof(button2), "������");
	ShowPlayerDialog(playerid, DIALOG_VEHICLE_DOORS, DIALOG_STYLE_LIST, title, string, button1, button2);
}

// ������� ��� �������� ���������� ������ ����� � ������������ ���������
IsPlayerNearVehicle(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < MAX_VEHICLES; i++)
    {
        if(IsValidVehicle(i))
        {
            new Float:vx, Float:vy, Float:vz;
            GetVehiclePos(i, vx, vy, vz);
            if(IsPlayerInRangeOfPoint(playerid, 3.0, vx, vy, vz))
            {
                return 1;
            }
        }
    }
    return 0;
}

// ������� ��� ��������, �������� �� ������������ �������� ����������
stock IsValidVehicle(vehicleid)
{
    if(vehicleid < 1 || vehicleid > MAX_VEHICLES) return 0;
    new model = GetVehicleModel(vehicleid);
    return (model != 0);
}

// ������� ��� ��������� ������ ������� ������������� ��������
Float:GetVehicleFuel(vehicleid)
{
    return VehicleFuel[vehicleid];
}

// ������� ��� ���������� ������� � ������������ ��������
GiveVehicleFuel(vehicleid, Float:amount)
{
    VehicleFuel[vehicleid] += amount;
    if(VehicleFuel[vehicleid] > MAX_FUEL)
    {
        VehicleFuel[vehicleid] = MAX_FUEL;
    }
}

// ������� ��� �������� ���������� ������ �� ����������� �������
IsPlayerAtGasStation(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new Float:gasStations[][] = {
        {1942.7, -1778.4, 13.4},
        {1942.8, -1767.1, 13.4},
        {1940.5, -1778.4, 13.4},
        {1940.5, -1767.2, 13.4},
        {999.20001, -938.70001, 42.2},
        {1009.8, -937.09998, 42.2},
        {1009.6, -934.70001, 42.2},
        {998.90002, -936.40002, 42.2},
        {-98.2, -1173.2, 2.4},
        {-93.5, -1161.7, 2.2},
        {-86.7, -1164.6, 2.3},
        {-91.6, -1176.1, 2.2},
        {-95.9, -1173.7, 2.3},
        {-91.2, -1162.7, 2.3},
        {-88.8, -1177.0, 2.1},
        {-84.2, -1165.9, 2.3},
        {2858.1001, -1942.1, 10.9},
        {654.255676, -559.378295, 16.335937},
		{654.183227, -569.748229, 16.335937},
		{657.381469, -570.509216, 16.335937},
		{657.162963, -560.846801, 16.335937}

    };

    for(new i = 0; i < sizeof(gasStations); i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 10.0, gasStations[i][0], gasStations[i][1], gasStations[i][2]))
        {
            return 1;
        }
    }
    return 0;
}


new LSPDVehicles[18];
new const Float:LSPDVehicleSpawns[][4] = {
    {1558.6999500, -1709.8000500, 6.1000000, 0.0000000},
    {1564.6000000, -1709.9000000, 6.1000000, 0.0000000},
    {1544.8000500, -1684.3000500, 5.7000000, 90.0000000},
    {1544.7000000, -1680.3000000, 5.7000000, 90.0000000},
    {1545.0000000, -1676.3000000, 5.7000000, 90.0000000},
    {1544.8000000, -1671.9000000, 5.7000000, 90.0000000},
    {1544.7000000, -1667.7000000, 5.7000000, 90.0000000},
    {1544.8000000, -1663.2000000, 5.7000000, 90.0000000},
    {1544.8000000, -1658.7000000, 5.7000000, 90.0000000},
    {1544.7998000, -1655.0996000, 5.7000000, 90.0000000},
    {1529.0000000, -1688.5000000, 6.3000000, 270.0000000},
    {1528.5000000, -1683.0999800, 6.3000000, 270.0000000},
    {1530.6999500, -1646.0000000, 5.8000000, 180.0000000},
    {1538.5000000, -1646.0000000, 5.8000000, 180.0000000},
    {1574.5999800, -1710.1999500, 6.0000000, 0.0000000},
    {1570.5000000, -1710.0000000, 6.0000000, 0.0000000},
    {1548.4000000, -1708.0000000, 28.7000000, 90.0000000}, // ����� ��������
    {1565.9000000, -1707.0000000, 28.7000000, 90.0000000}  // ����� ��������
};
new const LSPDVehicleModels[] = {
    427, 427, 596, 596, 596, 596, 596, 596, 596, 596, 599, 599, 601, 601, 579, 579, 497, 497
};


new PlayerPreviousSkin[MAX_PLAYERS];
#define DIALOG_LSPD_ARMOR 5000 // Oieeaeuiue ID aey aeaeiaa neeaaa
#define COLOR_RED 0xFF0000AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_BLUE 0x0000FFAA
#define COLOR_MEGAPHONE 0xFFFF00AA // ?aeoue oaao aey niiauaiee iaaaoiia


#define ADMIN_NONE 0
#define ADMIN_HELPER 1
#define ADMIN_MODERATOR 2
#define ADMIN_ADMIN 3
#define ADMIN_HEADADMIN 4


#define PICKUP_LSPD_DUTY 1
new Float:gLSPDBoothEnter[4] = {1577.0, -1636.59998, 13.6, 270.001};
new Float:gLSPDBoothExit[4] = {1577.59998, -1636.59998, 13.6, 0.003};
new Float:gLSPDBoothSpawnInside[4] = {1579.30005, -1636.40002, 13.6, 0.003};
new Float:gLSPDBoothSpawnOutside[4] = {1574.09998, -1635.59998, 13.5, 0.003};
new Float:gLSPDRoofExit[4] = {1565.3, -1684.1, 28.4, 0.003};
new Float:gLSPDInteriorAfterRoof[4] = {244.89999, 66.4, 1003.6, 0.003};
new Float:gLSPDRoofEntrance[4] = {242.10001, 66.3, 1003.6, 90.003};
new Float:gLSPDRoofSpawn[4] = {1565.1, -1686.4, 28.4, 180.005}; // 180.005 = -179.995


#define MAX_LSPD_RANK 13
#define FACTION_LSPD 1
#define FACTION_FBI 2
#define FACTION_ARMY 3
#define FACTION_SHERIFF 4
#define FACTION_GOV 5
#define FACTION_EMS 6

new Float:gLSPDSpawn[4] = {246.60001, 65.8, 1003.6, 0.003};
new gLSPDSkins[MAX_LSPD_RANK] = {71, 300, 300, 284, 267, 267, 265, 266, 266, 280, 281, 282, 288};
new gLSPDRanks[MAX_LSPD_RANK][32] = {
    "Cadet", "Officer", "Officer II", "Officer III", "Sergeant", "Sergeant II",
    "Lieutenant", "Captain", "Captain II", "Inspector", "Assistant Chief", "Deputy Chief", "Chief of Police"
};

#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_GENDER 3
#define DIALOG_AGE 4
#define DIALOG_NATIONALITY 5
#define DIALOG_RENTAL 6
#define DIALOG_PASSPORT 7
#define DIALOG_PASSPORT_INFO 8
#define DIALOG_TIPS 9
#define DIALOG_QUEST 10
#define TIMER_ENDRENTAL "EndRental"

#define FILE_USERS "Users/%s.ini"
#define STARTING_MONEY 2500
#define RENTAL_NPC_SKIN 221
#define PASSPORT_NPC_SKIN 192

enum PlayerInfo {
    pPassword[65],
    pGender,
    pAge,
    pNationality,
    bool:pHasPassport,
    pMoney,
    pBankMoney,
    pBankAccount,
    pFaction,
    pRank,
    pAdminLevel,
    pWantedLevel,
    pWantedReason[64],
    pLastPayday,
    pPaycheckAmount,
    bool:pCanDoStashMission,
    pStashMissionCooldown,
    bool:pHasMilitaryID,           // ��������� ����� ����
    pMilitaryIDIssuer[MAX_PLAYER_NAME],
    pMilitaryIDDate[32],
    PlayerSkin,
    pTruckerLevel,
    pTruckerExp
}
new Player[MAX_PLAYERS][PlayerInfo];

// Vagos
stock SetPlayerVagosRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_VAGOS_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gVagosSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � Vagos: %s", gVagosRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}


// Aztec
stock SetPlayerAztecRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_AZTEC_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gAztecSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � Aztec: %s", gAztecRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

stock SetPlayerSANNRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_SANN_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gSANNSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � SANN: %s", gSANNRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

new CityHallEntrancePickup;
new CityHallExitPickup;

forward SetCustomPlayerWantedLevel(playerid, level, const reason[]);


Float:GetVehicleSpeed(vehicleid)
{
    new Float:x, Float:y, Float:z;
    GetVehicleVelocity(vehicleid, x, y, z);
    return floatsqroot(x*x + y*y + z*z) * 180.0;
}

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
    print("\n--------------------------------------");
    print(" Authentication System Loaded");
    print("--------------------------------------\n");
    return 1;
}

public OnFilterScriptExit()
{
    return 1;
}

#else

main()
{
    print("\n----------------------------------");
    print(" Blank Gamemode by your name here");
    print("----------------------------------\n");
}

#endif

new LSPDEntrancePickup;
new LSPDExitPickup;
new LSPDArmorPickup;
new LSPDRoofExitPickup;
new LSPDRoofEntrancePickup;
new BankEntrancePickup;
new BankExitPickup;
new BankNPC;
new Text3D:gFBIExitLabel;
new
    DynamicFBIElevator1Up,
    DynamicFBIElevator1Down,
    DynamicFBIElevator2Up,
    DynamicFBIElevator2Down,
    DynamicFBIExitPickup;
new FBIArmorPickup;
new SheriffEntrancePickup;
new SheriffExitPickup;
new SheriffRoofEntrancePickup;
new SheriffRoofExitPickup;
new GroveEntrancePickup;
new GroveExitPickup;

CreateSheriffDoors()
{
SheriffDoorObject = CreateObject(1569, 246.5, 78.0, 985.79999, 0.0, 0.0, 0.0);
}
public OnGameModeInit()
{
    SetGameModeText("Authentication System");
    Streamer_ToggleIdleUpdate(STREAMER_TYPE_OBJECT, true);
    DisableInteriorEnterExits();
    CreateARMYVehicles();
    CreateGOVVehicles();
    CreateLSPDPickups();
    CreateLSPDGates();
    CreateLSPDDoors();
    CreateSheriffDoors();
    CreateGroveVehicles();
    LoadDealerships();
	LoadDealershipVehicles();
	CreateDealershipNPCs();
	new timerName[32];
 	LoadBusinesses();
    SetTimer("UpdateBusinessProfits", 60000, true); // ��������� ������ ������
    LoadHouses();
    SetTimer("CheckHouseTaxes", 60000, true); // ��������� ������ ������
	format(timerName, sizeof(timerName), "UpdateVehicleFuel");
	SetTimer(timerName, 1000, true);
//    print("Fuel update timer set. UpdateVehicleFuel() should be called every second.");
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

    // Create NPCs
    CreateActor(RENTAL_NPC_SKIN, 1680.4, -2325.8999, 13.5, 0.0);
    CreateActor(PASSPORT_NPC_SKIN, 359.79999, 173.60001, 1008.4, 0.0);

    // Create pickups
    CityHallEntrancePickup = CreatePickup(1318, 1, 1481.1, -1772.5, 18.8, -1);
    CityHallExitPickup = CreatePickup(1318, 1, 390.89999, 173.8, 1008.4, -1);


	// LSPD
    LSPDEntrancePickup = CreatePickup(1318, 1, 1555.8, -1675.6, 16.2, -1);
    LSPDExitPickup = CreatePickup(1318, 1, 246.89999, 62.0, 1003.6, -1);
    LSPDArmorPickup = CreatePickup(1318, 1, 253.2, 76.5, 1003.6, -1);

    CreateDynamicObjectEx(983,1544.5000000,-1620.8000500,13.2000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (1)
	CreateDynamicObjectEx(983,1543.9000200,-1636.0000000,13.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (2)
	CreateDynamicObjectEx(983,1543.9000200,-1636.0000000,14.4000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (3)
	CreateDynamicObjectEx(1569,1577.1999500,-1637.3000500,12.7000000,0.0000000,0.0000000,90.0000000); //object(adam_v_door) (1)
	CreateDynamicObjectEx(1649,1579.8000500,-1633.0000000,14.0000000,0.0000000,0.0000000,180.0000000); //object(wglasssmash) (1)
	CreateDynamicObjectEx(1649,1582.0000000,-1635.1999500,14.2000000,0.0000000,0.0000000,89.9950000); //object(wglasssmash) (2)
	CreateDynamicObjectEx(1649,1579.5000000,-1633.0000000,13.6000000,0.0000000,0.0000000,359.9950000); //object(wglasssmash) (3)
	CreateDynamicObjectEx(1649,1582.0999800,-1635.3000500,14.2000000,0.0000000,0.0000000,270.4950000); //object(wglasssmash) (4)
	CreateDynamicObjectEx(2724,1579.4000200,-1634.4000200,13.1000000,0.0000000,0.0000000,180.0000000); //object(lm_stripchair) (1)
	CreateDynamicObjectEx(2724,1580.6999500,-1635.4000200,13.1000000,0.0000000,0.0000000,119.9950000); //object(lm_stripchair) (2)
	CreateDynamicObjectEx(2190,1579.4000200,-1633.3000500,13.7000000,0.0000000,0.0000000,0.0000000); //object(pc_1) (1)
	CreateDynamicObjectEx(2190,1581.6999500,-1635.1999500,13.7000000,0.0000000,0.0000000,280.0000000); //object(pc_1) (2)
	CreateDynamicObjectEx(2951,249.7000000,72.6000000,1002.6000000,0.0000000,0.0000000,0.0000000); //����� � ����

	// LSPD ROOF
	CreateDynamicObjectEx(14819,1565.9000000,-1683.8000000,28.5000000,0.0000000,0.0000000,0.0000000); //object(og_door) (1)
	CreateDynamicObjectEx(3934,1548.3000000,-1708.1000000,27.4000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (1)
	CreateDynamicObjectEx(3934,1566.4000000,-1707.1000000,27.4000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (2)
	CreateDynamicObjectEx(982,1555.3000000,-1714.5000000,28.1000000,0.0000000,0.0000000,-90.0000000); //object(fenceshit) (1)
	CreateDynamicObjectEx(984,1571.5000000,-1714.5000000,28.0000000,0.0000000,0.0000000,90.0000000); //object(fenceshit2) (1)
	CreateDynamicObjectEx(982,1577.9000000,-1701.7000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit) (2)
	CreateDynamicObjectEx(982,1577.9000000,-1676.1000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit) (3)
	CreateDynamicObjectEx(982,1577.9000000,-1650.5000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit) (4)
	CreateDynamicObjectEx(983,1577.9000000,-1640.4000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (1)
	CreateDynamicObjectEx(982,1565.1000000,-1637.2000000,28.1000000,0.0000000,0.0000000,90.0000000); //object(fenceshit) (5)
	CreateDynamicObjectEx(984,1548.9000000,-1637.2000000,28.0000000,0.0000000,0.0000000,90.0000000); //object(fenceshit2) (2)
	CreateDynamicObjectEx(984,1542.6000000,-1643.6000000,28.0000000,0.0000000,0.0000000,-180.0000000); //object(fenceshit2) (3)
	CreateDynamicObjectEx(983,1542.5000000,-1647.6000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (2)
	CreateDynamicObjectEx(983,1545.7000000,-1650.8000000,28.1000000,0.0000000,0.0000000,-90.0000000); //object(fenceshit3) (3)
	CreateDynamicObjectEx(983,1550.4000000,-1650.8000000,28.1000000,0.0000000,0.0000000,-90.0000000); //object(fenceshit3) (4)
	CreateDynamicObjectEx(984,1553.6000000,-1657.1000000,28.0000000,0.0000000,0.0000000,0.0000000); //object(fenceshit2) (5)
	CreateDynamicObjectEx(984,1553.6000000,-1666.4000000,28.0000000,0.0000000,0.0000000,0.0000000); //object(fenceshit2) (6)
	CreateDynamicObjectEx(984,1553.5000000,-1684.8000000,28.0000000,0.0000000,0.0000000,0.0000000); //object(fenceshit2) (7)
	CreateDynamicObjectEx(984,1553.5000000,-1693.9000000,28.0000000,0.0000000,0.0000000,0.0000000); //object(fenceshit2) (8)
	CreateDynamicObjectEx(983,1550.3000000,-1700.4000000,28.1000000,0.0000000,0.0000000,-90.0000000); //object(fenceshit3) (7)
	CreateDynamicObjectEx(983,1545.8000000,-1700.4000000,28.1000000,0.0000000,0.0000000,-90.0000000); //object(fenceshit3) (8)
	CreateDynamicObjectEx(983,1542.6000000,-1703.6000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (9)
	CreateDynamicObjectEx(983,1542.6000000,-1710.0000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (10)
	CreateDynamicObjectEx(983,1542.6000000,-1711.5000000,28.1000000,0.0000000,0.0000000,0.0000000); //object(fenceshit3) (11)
	CreateDynamicObjectEx(3806,1554.3000000,-1674.1000000,27.3000000,0.0000000,0.0000000,-177.2500000); //object(sfx_winplant07) (1)
	CreateDynamicObjectEx(3806,1554.3000000,-1676.8000000,27.3000000,0.0000000,0.0000000,-177.2530000); //object(sfx_winplant07) (2)
 	LSPDRoofExitPickup = CreatePickup(1318, 1, gLSPDRoofExit[0], gLSPDRoofExit[1], gLSPDRoofExit[2], -1);
    LSPDRoofEntrancePickup = CreatePickup(1318, 1, gLSPDRoofEntrance[0], gLSPDRoofEntrance[1], gLSPDRoofEntrance[2], -1);


	// AZS
	CreateDynamicObjectEx(970,1942.1000000,-1777.6000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (1)
	CreateDynamicObjectEx(970,1942.1000000,-1773.5000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (2)
	CreateDynamicObjectEx(970,1942.1000000,-1769.4000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (3)
	CreateDynamicObjectEx(970,1942.2000000,-1768.0000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (4)
	CreateDynamicObjectEx(970,1941.2000000,-1768.3000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (5)
	CreateDynamicObjectEx(970,1941.2000000,-1772.4000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (6)
	CreateDynamicObjectEx(970,1941.2000000,-1776.5000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (7)
	CreateDynamicObjectEx(970,1941.2000000,-1778.3000000,13.2000000,0.0000000,0.0000000,-90.0000000); //object(fencesmallb) (8)
	CreateDynamicObjectEx(1676,999.0000000,-937.5999800,42.9000000,0.0000000,0.0000000,10.0000000); //object(washgaspump) (1)
	CreateDynamicObjectEx(1676,1002.7999900,-937.0000000,42.9000000,0.0000000,0.0000000,10.0000000); //object(washgaspump) (2)
	CreateDynamicObjectEx(1676,1005.3000000,-936.7000100,42.9000000,0.0000000,0.0000000,9.9980000); //object(washgaspump) (3)
	CreateDynamicObjectEx(1676,1009.7000000,-936.0999800,42.9000000,0.0000000,0.0000000,9.9980000); //object(washgaspump) (4)
	CreateDynamicObjectEx(970,1008.3000000,-935.7999900,41.9000000,0.0000000,0.0000000,8.0000000); //object(fencesmallb) (9)
	CreateDynamicObjectEx(970,1004.2000000,-936.4000200,41.9000000,0.0000000,0.0000000,7.9980000); //object(fencesmallb) (10)
	CreateDynamicObjectEx(970,1000.1000000,-937.0000000,41.9000000,0.0000000,0.0000000,7.9980000); //object(fencesmallb) (11)
	CreateDynamicObjectEx(970,999.2000100,-937.0999800,41.9000000,0.0000000,0.0000000,7.9980000); //object(fencesmallb) (12)
	CreateDynamicObjectEx(970,999.5000000,-938.0000000,42.0000000,0.0000000,0.0000000,7.9980000); //object(fencesmallb) (13)
	CreateDynamicObjectEx(970,1003.6000000,-937.4000200,41.9000000,0.0000000,0.0000000,7.9980000); //object(fencesmallb) (14)
	CreateDynamicObjectEx(970,1007.7000000,-936.7999900,41.9000000,0.0000000,0.0000000,8.2430000); //object(fencesmallb) (15)
	CreateDynamicObjectEx(970,1009.0000000,-936.7999900,41.9000000,0.0000000,0.0000000,8.2400000); //object(fencesmallb) (16)
	CreateDynamicObjectEx(16360,2867.5000000,-1942.4000000,10.3000000,0.0000000,0.0000000,-90.0000000); //object(desn2_tsfuelpay) (1)
	CreateDynamicObjectEx(18452,2858.1001000,-1942.4000000,12.9000000,0.0000000,0.0000000,-90.0000000); //object(cw_tscanopy01) (1)
	CreateDynamicObjectEx(1676,2855.3999000,-1942.5000000,11.7000000,0.0000000,0.0000000,-90.0000000); //object(washgaspump) (5)
	CreateDynamicObjectEx(1676,2861.0000000,-1942.7000000,11.7000000,0.0000000,0.0000000,-90.0000000); //object(washgaspump) (6)
	CreateDynamicObjectEx(3460,2861.6001000,-1949.8000000,14.2000000,0.0000000,0.0000000,90.0000000); //object(vegaslampost) (1)
	CreateDynamicObjectEx(3460,2854.3000000,-1948.8000000,14.2000000,0.0000000,0.0000000,-90.0000000); //object(vegaslampost) (2)
	CreateDynamicObjectEx(1359,2865.3999000,-1947.5000000,10.8000000,0.0000000,0.0000000,0.0000000); //object(cj_bin1) (1)
	CreateDynamicObjectEx(1372,2870.5000000,-1942.4000000,10.3000000,0.0000000,0.0000000,90.0000000); //object(cj_dump2_low) (1)

	// BANK
	CreateDynamicObjectEx(13007,2287.2000000,-15.8000000,27.5000000,0.0000000,0.0000000,0.0000000); //object(sw_bankbits) (1)
	CreateDynamicObjectEx(3095,2282.3999000,-8.1000000,25.1000000,-89.7500000,0.0000000,0.0000000); //object(a51_jetdoor) (2)
	CreateDynamicObjectEx(3095,2296.8000000,-18.7000000,25.7000000,-89.7530000,0.0000000,-90.0000000); //object(a51_jetdoor) (3)
	CreateDynamicObjectEx(1569,2296.5000000,-17.9000000,25.7000000,0.0000000,0.0000000,-88.2500000); //object(adam_v_door) (1)
	CreateDynamicObjectEx(1569,2278.8000000,-8.3000000,25.7000000,0.0000000,0.0000000,1.2500000); //object(adam_v_door) (2)
	CreateDynamicObjectEx(1569,2281.8000000,-8.3000000,25.7000000,0.0000000,0.0000000,178.7500000); //object(adam_v_door) (3)
	CreateDynamicObjectEx(1569,2278.8000000,-8.3000000,25.6000000,0.0000000,0.0000000,-177.0030000); //object(adam_v_door) (4)
	CreateDynamicObjectEx(3095,2292.0000000,-12.7000000,25.3000000,1.0030000,180.0000000,-180.0000000); //object(a51_jetdoor) (4)
	CreateDynamicObjectEx(1359,2283.6001000,-17.5000000,26.5000000,0.0000000,0.0000000,0.0000000); //object(cj_bin1) (1)
 	BankEntrancePickup = CreatePickup(1318, 1, 1457.1, -1009.6, 26.8, -1);
    BankExitPickup = CreatePickup(1318, 1, 2280.3999, -9.3, 27.0, -1);

    // �������� NPC � �����
    BankNPC = CreateActor(214, 2288.6001, -21.1, 26.7, 0.003);


    // �������� ���� ��� ��������� ����������� ����
    BankMenuPickup = CreatePickup(1274, 1, 2288.5, -19.8, 26.7, -1); // ���������� ������ 1274 ��� �������

	// ���������
    CreateDynamicObjectEx(2942,2249.7000000,-1666.9000000,15.1000000,0.0000000,0.0000000,166.2500000); //�������� #1
	CreateDynamicObjectEx(2942,1971.3000000,-1966.6000000,13.2000000,0.0000000,0.0000000,-92.5050000); //�������� #2
	CreateDynamicObjectEx(2942,1843.5000000,-1860.4000000,13.0000000,0.0000000,0.0000000,-0.7550000); //�������� #3
	CreateDynamicObjectEx(2942,1548.1000000,-1679.5000000,13.2000000,0.0000000,0.0000000,-0.7580000); //�������� #4
	CreateDynamicObjectEx(2942,1178.4000000,-1290.4000000,13.2000000,0.0000000,0.0000000,-178.7580000); //�������� #5
	CreateDynamicObjectEx(2942,715.9000200,-1425.8000000,13.2000000,0.0000000,0.0000000,0.0000000); //�������� #7
	CreateDynamicObjectEx(2942,513.4000200,-1647.8000000,17.7000000,0.0000000,0.0000000,0.0000000); //�������� #8
	CreateDynamicObjectEx(2942,-83.3000000,-1183.6000000,1.4000000,0.0000000,0.0000000,-22.0000000); //�������� #9

 	// ������� ������ ������ (��������)
    FBIGateObject1 = CreateObject(968, 1506.7, -1352.2, 13.8, -0.125, 90.215, -179.333);

    FBIGateObject2 = CreateObject(980, 1562.3, -1392.3, 15.8, 0.0, 0.0, -90.0);

    FBIArmorPickup = CreatePickup(1318, 1, 2278.291259, -212.071243, 982.599487, -1);


    // �������� ������� ��� �����/������ FBI
	DynamicFBIElevator1Up = CreateDynamicPickup(1318, 1, 2270.503662, -205.257537, 982.599487, -1, -1, -1, 100.0);
	DynamicFBIElevator1Down = CreateDynamicPickup(1318, 1, 2270.462646, -205.240417, 987.339477, -1, -1, -1, 100.0);
	DynamicFBIElevator2Up = CreateDynamicPickup(1318, 1, 2253.530761, -205.257354, 982.599487, -1, -1, -1, 100.0);
	DynamicFBIElevator2Down = CreateDynamicPickup(1318, 1, 2253.402832, -205.239501, 987.339477, -1, -1, -1, 100.0);
	DynamicFBIExitPickup = CreateDynamicPickup(1318, 1, gFBIExit[0], gFBIExit[1], gFBIExit[2], -1, -1, -1, 100.0);


	// EMS
	CreatePickup(1318, 1, gEMSEnter[0], gEMSEnter[1], gEMSEnter[2], -1);
	CreatePickup(1318, 1, gEMSExit[0], gEMSExit[1], gEMSExit[2], -1);
	
	// SHPD
	CreateObject(3934,614.2999900,-574.7999900,25.2000000,0.0000000,0.0000000,0.0000000); //object(helipad01) (1)
	CreateObject(3061,621.5999800,-568.7000100,26.3000000,0.0000000,0.0000000,90.0000000); //object(ad_flatdoor) (1)
	SheriffEntrancePickup = CreatePickup(1318, 1, 626.59998, -571.90002, 17.9, -1);
	SheriffExitPickup = CreatePickup(1318, 1, 247.89999, 68.0, 986.79999, VIRTUAL_WORLD_SHERIFF); // ��������� ����������� ���
	SheriffRoofEntrancePickup = CreatePickup(1318, 1, 243.2, 71.9, 986.79999, VIRTUAL_WORLD_SHERIFF); // ���� �� ����� �� ���������
	SheriffRoofExitPickup = CreatePickup(1318, 1, 621.09998, -568.90002, 26.1, -1); // ����� � �����
	
	//SHPD INT
    CreateDynamicObjectEx(14846,243.2000000,82.9000000,988.2000100,0.0000000,0.0000000,90.0000000); //object(int_ppol) (1)
	CreateDynamicObjectEx(1535,249.3999900,67.8000000,985.7999900,0.0000000,0.0000000,-176.0000000); //object(gen_doorext14) (2)
	CreateDynamicObjectEx(1535,246.3000000,67.8000000,985.7999900,0.0000000,0.0000000,-4.0000000); //object(gen_doorext14) (3)
	CreateDynamicObjectEx(14843,267.3999900,86.8000000,984.4000200,0.0000000,0.0000000,90.0000000); //object(int_policea01) (1)
	CreateDynamicObjectEx(1535,247.3000000,67.6000000,985.7999900,0.0000000,0.0000000,-0.7500000); //object(gen_doorext14) (4)
	CreateDynamicObjectEx(2607,252.3999900,71.9000000,986.2000100,0.0000000,0.0000000,-90.0000000); //object(polce_desk2) (1)
	CreateDynamicObjectEx(2607,252.5000000,74.8000000,986.2000100,0.0000000,0.0000000,-90.0000000); //object(polce_desk2) (2)
	CreateDynamicObjectEx(1330,252.3999900,73.3000000,986.2000100,0.0000000,0.0000000,0.0000000); //object(binnt14_la) (1)
	CreateDynamicObjectEx(2356,252.8999900,71.9000000,985.7999900,0.0000000,0.0000000,89.9950000); //object(police_off_chair) (1)
	CreateDynamicObjectEx(2356,253.0000000,74.9000000,985.7999900,0.0000000,0.0000000,89.9890000); //object(police_off_chair) (2)
	CreateDynamicObjectEx(2610,258.7000100,73.6000000,986.5999800,0.0000000,0.0000000,-90.0000000); //object(cj_p_fileing2) (1)
	CreateDynamicObjectEx(2610,258.7000100,72.6000000,986.5999800,0.0000000,0.0000000,-90.0000000); //object(cj_p_fileing2) (2)
	CreateDynamicObjectEx(2610,258.7000100,73.1000000,986.5999800,0.0000000,0.0000000,-90.0000000); //object(cj_p_fileing2) (3)
	CreateDynamicObjectEx(14680,258.6000100,67.1000000,987.7999900,0.0000000,0.0000000,0.0000000); //object(int_tat_lights01) (1)
	CreateDynamicObjectEx(14680,258.6000100,71.9000000,987.7999900,0.0000000,0.0000000,0.0000000); //object(int_tat_lights01) (2)
	CreateDynamicObjectEx(2611,258.7999900,74.7000000,987.5000000,0.0000000,0.0000000,-89.0000000); //object(police_nb1) (1)
	CreateDynamicObjectEx(2614,258.8999900,72.9000000,988.2000100,0.0000000,0.0000000,-90.0000000); //object(cj_us_flag) (1)
	CreateDynamicObjectEx(2190,252.3999900,72.5000000,986.5999800,0.0000000,0.0000000,40.0000000); //object(pc_1) (1)
	CreateDynamicObjectEx(2190,252.3000000,74.6000000,986.5999800,0.0000000,0.0000000,99.9960000); //object(pc_1) (2)
	CreateDynamicObjectEx(2604,236.2000000,86.3000000,988.0000000,0.0000000,0.0000000,-90.0000000); //object(cj_police_counter) (1)
	CreateDynamicObjectEx(2604,236.1000100,77.9000000,988.0000000,0.0000000,0.0000000,-90.0000000); //object(cj_police_counter) (2)
	CreateDynamicObjectEx(2604,232.2000000,86.3000000,988.0000000,0.0000000,0.0000000,-90.0000000); //object(cj_police_counter) (3)
	CreateDynamicObjectEx(2604,230.8999900,77.9000000,988.0000000,0.0000000,0.0000000,-90.0000000); //object(cj_police_counter) (4)
	CreateDynamicObjectEx(2608,229.8000000,88.2000000,989.4000200,0.0000000,0.0000000,0.0000000); //object(polce_shelf) (1)
	CreateDynamicObjectEx(2608,234.5000000,88.2000000,989.5000000,0.0000000,0.0000000,0.0000000); //object(polce_shelf) (2)
	CreateDynamicObjectEx(2609,227.8000000,82.7000000,987.9000200,0.0000000,0.0000000,90.0000000); //object(cj_p_fileing1) (1)
	CreateDynamicObjectEx(2609,227.8000000,83.1000000,987.9000200,0.0000000,0.0000000,90.0000000); //object(cj_p_fileing1) (2)
	CreateDynamicObjectEx(2609,227.8000000,83.5000000,987.9000200,0.0000000,0.0000000,90.0000000); //object(cj_p_fileing1) (3)
	CreateDynamicObjectEx(2606,242.5000000,81.4000000,990.0000000,0.0000000,0.0000000,-96.7500000); //object(cj_police_counter2) (1)
	CreateDynamicObjectEx(2724,235.1000100,78.6000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (1)
	CreateDynamicObjectEx(2724,229.8999900,78.7000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (2)
	CreateDynamicObjectEx(2724,231.3000000,85.3000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (3)
	CreateDynamicObjectEx(2724,230.8999900,87.0000000,988.2000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (4)
	CreateDynamicObjectEx(2724,234.8999900,76.9000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (5)
	CreateDynamicObjectEx(2724,229.7000000,76.8000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (6)
	CreateDynamicObjectEx(2724,235.0000000,86.9000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (7)
	CreateDynamicObjectEx(2724,235.1000100,85.3000000,987.7000100,0.0000000,0.0000000,90.0000000); //object(lm_stripchair) (8)
	CreateDynamicObjectEx(1712,258.2999900,68.4000000,985.7999900,0.0000000,0.0000000,-180.0000000); //object(kb_couch05) (1)
	CreateDynamicObjectEx(955,258.3999900,76.4000000,986.2000100,0.0000000,0.0000000,0.0000000); //object(cj_ext_sprunk) (1)
	CreateDynamicObjectEx(2951,250.8000000,78.1000000,985.2000100,0.0000000,0.0000000,-1.0000000); //object(a51_labdoor) (1)
	
	// Groove
	GroveEntrancePickup = CreatePickup(1318, 1, gGroveEnter[0], gGroveEnter[1], gGroveEnter[2], -1);
	GroveExitPickup = CreatePickup(1318, 1, gGroveExit[0], gGroveExit[1], gGroveExit[2], -1);
	
	// NPC BigJohn
	CreateActor(28, BIGJOHN_POS[0], BIGJOHN_POS[1], BIGJOHN_POS[2], BIGJOHN_POS[3]);
	new textLabel[16];
	format(textLabel, sizeof(textLabel), "Big John");
	BigJohnLabel = Create3DTextLabel(textLabel, 0xFFFFFFFF, BIGJOHN_POS[0], BIGJOHN_POS[1], BIGJOHN_POS[2] + 2.0, 20.0, 0, 1);
	
	// GOV
 	GOVParkingEnterPickup = CreatePickup(1318, 1, gGOVParkingEnter[0], gGOVParkingEnter[1], gGOVParkingEnter[2], -1);
    GOVParkingExitPickup = CreatePickup(1318, 1, gGOVParkingExit[0], gGOVParkingExit[1], gGOVParkingExit[2], -1);
    GOVRoofEnterPickup = CreatePickup(1318, 1, gGOVRoofEnter[0], gGOVRoofEnter[1], gGOVRoofEnter[2], -1);
    GOVRoofExitPickup = CreatePickup(1318, 1, gGOVRoofExit[0], gGOVRoofExit[1], gGOVRoofExit[2], -1);
    CreateDynamicObjectEx(1569,1438.2000000,-1785.7000000,32.4000000,0.0000000,0.0000000,-90.0000000); //object(adam_v_door) (1)
	CreateDynamicObjectEx(1569,1413.6000000,-1789.0000000,14.5000000,0.0000000,0.0000000,-90.0000000); //object(adam_v_door) (2)
	CreateDynamicObjectEx(1569,1413.6000000,-1791.9000000,14.5000000,0.0000000,0.0000000,90.0000000); //object(adam_v_door) (3)
	CreateDynamicObjectEx(1569,371.7999900,159.8000000,1024.8000000,0.0000000,0.0000000,-180.0000000); //object(adam_v_door) (4)
	
	// ARMY
	CreateDynamicObjectEx(5822,285.6000100,1861.5000000,22.2000000,0.0000000,0.0000000,-180.0000000); //object(lhroofst14) (1)
	CreateDynamicObjectEx(5822,277.1000100,1860.3000000,22.2000000,0.0000000,0.0000000,2.4950000); //object(lhroofst14) (2)
    ARMYGateObject1 = CreateDynamicObjectEx(988, 96.7, 1920.3, 17.1, 0.0, 0.0, -90.0);
    ARMYGateObject2 = CreateDynamicObjectEx(2990, 345.20001, 1797.6, 21.3, 0.0, 0.0, 38.0);
    
	// Ballas

	// ������� ��������� Ballas
    CreateBallasVehicles();

    // ������� ������ Ballas
    BallasEntrancePickup = CreatePickup(1318, 1, gBallasEnter[0], gBallasEnter[1], gBallasEnter[2], -1);
    BallasExitPickup = CreatePickup(1318, 1, gBallasExit[0], gBallasExit[1], gBallasExit[2], -1);
    
	// Vagos
 	CreateVagosVehicles();

    // Create Vagos pickups
    VagosEntrancePickup = CreatePickup(1318, 1, gVagosEnter[0], gVagosEnter[1], gVagosEnter[2], -1);
    VagosExitPickup = CreatePickup(1318, 1, gVagosExit[0], gVagosExit[1], gVagosExit[2], -1);
    
    // Aztec
    CreateAztecVehicles();
    AztecEntrancePickup = CreatePickup(1318, 1, gAztecEnter[0], gAztecEnter[1], gAztecEnter[2], -1);
    AztecExitPickup = CreatePickup(1318, 1, gAztecExit[0], gAztecExit[1], gAztecExit[2], -1);
	// CNN
	CreateDynamicObjectEx(10829,1825.0000000,-1314.0000000,130.7000000,0.0000000,0.0000000,-90.0000000); //object(gatehouse1_sfse) (1)
	CreateSANNVehicles();
	SANNEntrancePickup = CreatePickup(1318, 1, gSANNEnter[0], gSANNEnter[1], gSANNEnter[2], -1);
	SANNExitPickup = CreatePickup(1318, 1, gSANNExit[0], gSANNExit[1], gSANNExit[2], -1);
	SANNRoofEnterPickup = CreatePickup(1318, 1, gSANNRoofEnter[0], gSANNRoofEnter[1], gSANNRoofEnter[2], -1);
	SANNRoofExitPickup = CreatePickup(1318, 1, gSANNRoofExit[0], gSANNRoofExit[1], gSANNRoofExit[2], -1);
	
	
	// SubUrban clothes
    // ������� ������������ ������
    printf("[DEBUG] Creating shop pickups...");

    // ������� ����� ����� (�� �����, interior 0)
    EnterShopPickup = CreateDynamicPickup(1239, 1,
        gShopEnterPos[0], gShopEnterPos[1], gShopEnterPos[2],
        0,      // VW
        0,      // Interior (�����: ������� = 0)
        -1,     // PlayerID
        100.0); // Stream distance

    printf("[DEBUG] Enter pickup created at %.4f, %.4f, %.4f",
        gShopEnterPos[0], gShopEnterPos[1], gShopEnterPos[2]);

    // ������� ����� ������ (������, interior 1)
    ExitShopPickup = CreateDynamicPickup(1239, 1,
        gShopExitPos[0], gShopExitPos[1], gShopExitPos[2],
        0,      // VW
        1,      // Interior (�����: ������ = 1)
        -1,
        50.0);

    printf("[DEBUG] Exit pickup created at %.4f, %.4f, %.4f",
        gShopExitPos[0], gShopExitPos[1], gShopExitPos[2]);

    // ������� ����� ������ ������ (������, interior 1)
    ClothingPickup = CreateDynamicPickup(1274, 1,
        gClothingPos[0], gClothingPos[1], gClothingPos[2],
        0,      // VW
        1,      // Interior (�����: ������ = 1)
        -1,
        50.0);

    printf("[DEBUG] Clothing pickup created at %.4f, %.4f, %.4f",
        gClothingPos[0], gClothingPos[1], gClothingPos[2]);

    // ������� NPC �������� (������)
    ShopNPC = CreateActor(233, 203.4, -41.9, 1001.8, 180.0);
    SetActorVirtualWorld(ShopNPC, 0);



	
	for(new i = 0; i < sizeof(SheriffVehicles); i++)
	{
	    // ���������� ���� � ����������� �� ������
	    new color1, color2;

	    if(SheriffVehicleModels[i] == 497 || SheriffVehicleModels[i] == 579) // ���� ��� Maverick ��� Huntley
	    {
	        color1 = 0; // ������
	        color2 = 0; // ������
	    }
	    else
	    {
	        color1 = -1; // ����������� ���� ��� ��������� �����
	        color2 = -1;
	    }

	    new vehicleid = CreateVehicle(SheriffVehicleModels[i],
	        SheriffVehicleSpawns[i][0],
	        SheriffVehicleSpawns[i][1],
	        SheriffVehicleSpawns[i][2],
	        SheriffVehicleSpawns[i][3],
	        color1,
	        color2,
	        -1);

	    SheriffVehicles[i] = vehicleid;

	    new plate[32];
	    format(plate, sizeof(plate), "SHPD %04d", i);
	    SetVehicleNumberPlate(vehicleid, plate);

	    SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
	}
	
	for(new i = 0; i < sizeof(EMSVehicles); i++)
	{
	    new vehicleid = CreateVehicle(EMSVehicleModels[i], EMSVehicleSpawns[i][0], EMSVehicleSpawns[i][1], EMSVehicleSpawns[i][2], EMSVehicleSpawns[i][3], 3, 3, -1);
	    EMSVehicles[i] = vehicleid;

	    // ��������� �������� ����
	    new plate[32];
	    format(plate, sizeof(plate), "EMS %03d", i);
	    SetVehicleNumberPlate(vehicleid, plate);

	    // ��������� ���������� ������
	    SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
	}
 	for(new i = 0; i < MAX_VEHICLES; i++)
    {
        VehicleFuel[i] = MAX_FUEL;
    }

    // ����� ����� LSPD
    for(new i = 0; i < sizeof(LSPDVehicles); i++)
    {
        new vehicleid = CreateVehicle(LSPDVehicleModels[i], LSPDVehicleSpawns[i][0], LSPDVehicleSpawns[i][1], LSPDVehicleSpawns[i][2], LSPDVehicleSpawns[i][3], 0, 0, -1);
        LSPDVehicles[i] = vehicleid;

        // ��������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "LSPD %04d", i);
        SetVehicleNumberPlate(vehicleid, plate);

        // ��������� ���������� ������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
    // �������� ���������� FBI
    for(new i = 0; i < sizeof(FBIVehicles); i++)
    {
        new vehicleid = CreateVehicle(FBIVehicleModels[i], FBIVehicleSpawns[i][0], FBIVehicleSpawns[i][1], FBIVehicleSpawns[i][2], FBIVehicleSpawns[i][3], 0, 0, -1);
        FBIVehicles[i] = vehicleid;

        // ��������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "FBI %04d", i);
        SetVehicleNumberPlate(vehicleid, plate);

        // ��������� ���������� ������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        Player[i][pHasMilitaryID] = false;
        Player[i][pMilitaryIDIssuer][0] = '\0';
        Player[i][pMilitaryIDDate][0] = '\0';
    }

    return 1;

}

public OnGameModeExit()
{
    Delete3DTextLabel(gFBIExitLabel);
    SaveBusinesses();
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    return 1;
}

public OnPlayerConnect(playerid)
{
    new file[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), FILE_USERS, name);

    // ���������, ���������� �� ���� ������������
    if(fexist(file))
    {
        new caption[] = "�����������";
        new info[] = "������� ������:";
        new button1[] = "�����";
        new button2[] = "������";
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, caption, info, button1, button2);
    }
    else
    {
        new caption[] = "�����������";
        new info[] = "������� ������ ��� �����������:";
        new button1[] = "������������������";
        new button2[] = "������";
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, caption, info, button1, button2);
    }

    // ������� ������ ��� ������, ����� ������� ����� �� �����
    RemoveBuildingForPlayer(playerid, 4192, 1591.6953, -1674.8516, 20.49219, 58.829674);
    RemoveBuildingForPlayer(playerid, 1440, 1141.9844, -1346.1094, 13.26563, 3.6364884);
    RemoveBuildingForPlayer(playerid, 1411, 347.19531, 1799.2656, 18.75781, 5.3890729);
    
    // skin
    SetPlayerSkin(playerid, Player[playerid][PlayerSkin]);
    gIsInClothingMenu[playerid] = false;
    
	// Autosalon
 	LoadOwnedVehicles(playerid);

    // ������� ��������� ����������� ������ ������� ��� ������
    CreateFuelTextDraw(playerid);

    // ������������� ����������� ����� ������
    Player[playerid][pBankMoney] = 0;
    Player[playerid][pBankAccount] = 10000 + random(90000); // ��������� ���������� ������ �����
    Player[playerid][pLastPayday] = gettime();

    // ������ ��� �������� ��������� ������
    new timerName[] = "CheckPlayerDyingState";
    SetTimerEx(timerName, 1000, true, "i", playerid);

    // ������������� ���������� ������
    PlayerLastSkin[playerid] = GetPlayerSkin(playerid);
    PlayerSkins[playerid] = GetPlayerSkin(playerid);
    PlayerCuffed[playerid] = false;
    PlayerCuffedTime[playerid] = 0;
    PlayerDoingStashMission[playerid] = false;
    PlayerStashesLeft[playerid] = 0;
    PlayerNextStashTimer[playerid] = -1;
    Player[playerid][pStashMissionCooldown] = 0;
    Player[playerid][pCanDoStashMission] = true;

    // ���������, ������� �� ����� �����-���� �����
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(House[i][hExists] && !strcmp(House[i][hOwner], name, true))
        {
            // ��������� 3D ����� ��� �����
            new label[256];
            format(label, sizeof(label), "���\n��������: %s\n%s",
                name, House[i][hLocked] ? "������" : "������");
            Update3DTextLabelText(House[i][hLabel], 0xFFFFFFAA, label);
            House[i][hOwned] = true;
            break;
        }
    }

    return 1;
}



public OnPlayerDisconnect(playerid, reason)
{
    if(RentedVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(RentedVehicle[playerid]);
        RentedVehicle[playerid] = INVALID_VEHICLE_ID;
    }
    
    SaveUser(playerid);
    SaveOwnedVehicles(playerid);
    gIsInClothingMenu[playerid] = false;

    // ������� ��� ������������ �������� ������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] == true && OwnedVehicle[playerid][i][ovVehicleID] != 0)
        {
            DestroyVehicle(OwnedVehicle[playerid][i][ovVehicleID]);
            OwnedVehicle[playerid][i][ovVehicleID] = 0;
        }
    }
    return 1;
}



public OnPlayerSpawn(playerid)
{
    if(PlayerIsDying[playerid])
    {
        // ���������� ������ � ��������� ������� "������"
        SetPlayerPos(playerid, LastPlayerPos[playerid][0], LastPlayerPos[playerid][1], LastPlayerPos[playerid][2]);
        SetPlayerHealth(playerid, 1.0);
        TogglePlayerControllable(playerid, 0);
        ApplyDeathAnimation(playerid);

        // ��������� ������
        SetPlayerCameraPos(playerid, LastPlayerPos[playerid][0] + 2.0, LastPlayerPos[playerid][1] + 2.0, LastPlayerPos[playerid][2] + 1.0);
        SetPlayerCameraLookAt(playerid, LastPlayerPos[playerid][0], LastPlayerPos[playerid][1], LastPlayerPos[playerid][2]);

        // ��������������� ����������� ���� ������
        SetPlayerSkin(playerid, PlayerSkins[playerid]);
        return 1;
    }

    // ���������, ���� �� � ������ ���
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    new bool:hasHouse = false;
    new houseID = -1;

    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(House[i][hExists] && !strcmp(House[i][hOwner], name, true))
        {
            hasHouse = true;
            houseID = i;
            break;
        }
    }

    SetPlayerSkin(playerid, PlayerSkins[playerid]);
    SetPlayerColor(playerid, 0xFFFFFF00);

    if(Player[playerid][pFaction] == FACTION_LSPD)
    {
        SetPlayerPos(playerid, gLSPDSpawn[0], gLSPDSpawn[1], gLSPDSpawn[2]);
        SetPlayerFacingAngle(playerid, gLSPDSpawn[3]);
        SetPlayerInterior(playerid, 6);
        SetPlayerLSPDRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_FBI)
    {
        SetPlayerPos(playerid, gFBISpawn[0], gFBISpawn[1], gFBISpawn[2]);
        SetPlayerFacingAngle(playerid, gFBISpawn[3]);
        SetPlayerInterior(playerid, 1);
        SetPlayerFBIRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_EMS)
    {
        SetPlayerPos(playerid, gEMSSpawn[0], gEMSSpawn[1], gEMSSpawn[2]);
        SetPlayerFacingAngle(playerid, gEMSSpawn[3]);
        SetPlayerInterior(playerid, 1);
        SetPlayerEMSRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        SetPlayerPos(playerid, gSheriffSpawn[0], gSheriffSpawn[1], gSheriffSpawn[2]);
        SetPlayerFacingAngle(playerid, gSheriffSpawn[3]);
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, VIRTUAL_WORLD_SHERIFF);
        SetPlayerSheriffRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_GOV)
    {
        SetPlayerPos(playerid, 358.10001, 162.0, 1025.8);
        SetPlayerFacingAngle(playerid, -79.995);
        SetPlayerInterior(playerid, 3);
        SetPlayerGOVRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_GROVE)
    {
        SetPlayerPos(playerid, gGroveSpawn[0], gGroveSpawn[1], gGroveSpawn[2]);
        SetPlayerFacingAngle(playerid, gGroveSpawn[3]);
        SetPlayerInterior(playerid, 3);
        SetPlayerGroveRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_ARMY)
    {
        SetPlayerPos(playerid, gARMYSpawn[0], gARMYSpawn[1], gARMYSpawn[2]);
        SetPlayerFacingAngle(playerid, gARMYSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SetPlayerARMYRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_BALLAS)
    {
        SetPlayerPos(playerid, gBallasSpawn[0], gBallasSpawn[1], gBallasSpawn[2]);
        SetPlayerFacingAngle(playerid, gBallasSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SetPlayerBallasRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_VAGOS)
    {
        SetPlayerPos(playerid, gVagosSpawn[0], gVagosSpawn[1], gVagosSpawn[2]);
        SetPlayerFacingAngle(playerid, gVagosSpawn[3]);
        SetPlayerInterior(playerid, 6);
        SetPlayerVagosRank(playerid, Player[playerid][pRank]);
    }
    else if(Player[playerid][pFaction] == FACTION_AZTEC)
	{
    SetPlayerPos(playerid, gAztecSpawn[0], gAztecSpawn[1], gAztecSpawn[2]);
    SetPlayerFacingAngle(playerid, gAztecSpawn[3]);
    SetPlayerInterior(playerid, 0);
    SetPlayerAztecRank(playerid, Player[playerid][pRank]);
	}
 	else if(Player[playerid][pFaction] == FACTION_SANN)
    {
        SetPlayerPos(playerid, gSANNSpawn[0], gSANNSpawn[1], gSANNSpawn[2]);
        SetPlayerFacingAngle(playerid, gSANNSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SetPlayerSANNRank(playerid, Player[playerid][pRank]);
    }
    else if(hasHouse)
    {
        SetPlayerPos(playerid, HouseLocations[houseID][3], HouseLocations[houseID][4], HouseLocations[houseID][5]);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        new skinid = (Player[playerid][pGender] == 0) ? 1 : 12;
        SetPlayerSkin(playerid, skinid);
    }
    else
    {
        SetPlayerPos(playerid, 1685.7, -2335.7, 13.5);
        SetPlayerFacingAngle(playerid, 0.003);
        SetPlayerInterior(playerid, 0);
        new skinid = (Player[playerid][pGender] == 0) ? 1 : 12;
        SetPlayerSkin(playerid, skinid);
    }

    SetCameraBehindPlayer(playerid);

    if(Player[playerid][pMoney] > 0)
    {
        GivePlayerMoney(playerid, Player[playerid][pMoney]);
    }
    else
    {
        GivePlayerMoney(playerid, STARTING_MONEY);
        Player[playerid][pMoney] = STARTING_MONEY;
    }

    // ���������� ��������� ������
    PlayerIsDying[playerid] = false;
    if(PlayerDeathTimer[playerid] != -1)
    {
        KillTimer(PlayerDeathTimer[playerid]);
        PlayerDeathTimer[playerid] = -1;
    }

    // ������� ������ ��������� ������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] && !OwnedVehicle[playerid][i][ovVehicleID])
        {
            new vehicleid = CreateVehicle(
                OwnedVehicle[playerid][i][ovModel],
                OwnedVehicle[playerid][i][ovParkX],
                OwnedVehicle[playerid][i][ovParkY],
                OwnedVehicle[playerid][i][ovParkZ],
                OwnedVehicle[playerid][i][ovParkAngle],
                -1, -1, -1);

            OwnedVehicle[playerid][i][ovVehicleID] = vehicleid;

            // ������������� �������� ����
            new plate[32];
            format(plate, sizeof(plate), "%s_%d", OwnedVehicle[playerid][i][ovOwner], i + 1);
            SetVehicleNumberPlate(vehicleid, plate);
        }
    }

    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(!PlayerIsDying[playerid])
    {
        PlayerIsDying[playerid] = true;
        SetPlayerHealth(playerid, 1.0);
        TogglePlayerControllable(playerid, 0);
        ApplyDeathAnimation(playerid);

        new timerName[32];
        format(timerName, sizeof(timerName), "PlayerDeathState");
        new formatStr[8];
        format(formatStr, sizeof(formatStr), "i");
        PlayerDeathTimer[playerid] = SetTimerEx(timerName, EMS_CALL_TIME, false, formatStr, playerid);

        CreateEMSCall(playerid);
        // ��������� ������
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerCameraPos(playerid, x + 2.0, y + 2.0, z + 1.0);
        SetPlayerCameraLookAt(playerid, x, y, z);
    }
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
    // ������������ �������� LSPD
    new bool:isLSPDVehicle = false;
    for(new i = 0; i < sizeof(LSPDVehicles); i++)
    {
        if(vehicleid == LSPDVehicles[i])
        {
            isLSPDVehicle = true;
            break;
        }
    }

    // ��������� �������� GOV
    new bool:isGOVVehicle = false;
    for(new i = 0; i < sizeof(GOVVehicles); i++)
    {
        if(vehicleid == GOVVehicles[i])
        {
            isGOVVehicle = true;
            break;
        }
    }

    // ���� ��� ��������� LSPD ��� GOV, ������������� ���������
    if(isLSPDVehicle || isGOVVehicle)
    {
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }

    // ������������� ������ ��� ������� ��� ���� ���������� ������������ �������
    VehicleFuel[vehicleid] = MAX_FUEL;
    return 1;
}



public OnVehicleDeath(vehicleid, killerid)
{
    return 1;
}

public OnPlayerText(playerid, text[])
{
    new message[256], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    format(message, sizeof(message), "%s �������: %s", playerName, text);

    // ���������� ��������� ������ ������� � ������� 20 ������
    SendNearbyMessage(playerid, 20.0, COLOR_WHITE, message);

    // ���������� 0, ����� ������������� �������� ��������� � ���������� ���
    return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp("/mycommand", cmdtext, true, 10) == 0)
    {
        // Do something here
        return 1;
    }
    return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(!ispassenger && !HasVehicleAccess(playerid, vehicleid))
    {
        ClearAnimations(playerid);
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerPos(playerid, x, y, z);
        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������ �� ����� ����������!");
        return 0;
    }
    return 1;
}


public OnPlayerExitVehicle(playerid, vehicleid)
{
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(IsValidVehicle(vehicleid))
        {
            // ��������, �������� �� ��� ����������� LSPD
            new bool:isLSPDVehicle = false;
            for(new i = 0; i < sizeof(LSPDVehicles); i++)
            {
                if(vehicleid == LSPDVehicles[i])
                {
                    isLSPDVehicle = true;
                    break;
                }
            }

            if(isLSPDVehicle && Player[playerid][pFaction] != FACTION_LSPD)
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "�� �� ������ ����� ��������� ���� ������������ ���������.");
                return 1;
            }

            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective); // �������� ���������

            // ��������� ��������� � ����������� � �������
            UpdateVehicleFuelTextDraw(playerid, vehicleid);
        }
    }
    else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
    {
        PlayerTextDrawHide(playerid, FuelTextDraw[playerid]);
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(PlayerDoingStashMission[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
        SetTimerEx("OnStashPlaced", 3000, false, "i", playerid);
        return 1;
    }

    // ������������ ��� ��� EMS...
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, COLOR_INFO, "�� ������� �� ����� ������. ����������� /rescue [ID] ��� �������� ������.");
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
    return 1;
}

public OnRconCommand(cmd[])
{
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    return 1;
}

public OnObjectMoved(objectid)
{
    return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    // ��������� ��� ����
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        // �������� �� ���� � ���
        if(pickupid == House[i][hPickup])
        {
            if(House[i][hLocked] && strcmp(House[i][hOwner], ReturnPlayerName(playerid), true))
            {
                SendClientMessage(playerid, COLOR_RED, "���� ��� ������.");
                return 1;
            }

            SetPlayerPos(playerid, House[i][hSpawnInteriorX], House[i][hSpawnInteriorY], House[i][hSpawnInteriorZ]);
            SetPlayerInterior(playerid, House[i][hInteriorID]);
            SetPlayerVirtualWorld(playerid, i + 1); // ���������� i + 1 ��� ���������� ����������� ���
            return 1;
        }

        // �������� �� ����� �� ����
        if(GetPlayerVirtualWorld(playerid) == i + 1 && // ��������� ����������� ���
           GetPlayerInterior(playerid) == House[i][hInteriorID] && // ��������� ��������
           IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hExitX], House[i][hExitY], House[i][hExitZ]))
        {
            SetPlayerPos(playerid, House[i][hSpawnX], House[i][hSpawnY], House[i][hSpawnZ]);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            return 1;
        }
    }
    if (pickupid == CityHallEntrancePickup)
    {
        SetPlayerPos(playerid, 380.79999, 174.10001, 1008.4);
        SetPlayerInterior(playerid, 3);
    }
    else if (pickupid == CityHallExitPickup)
    {
        SetPlayerPos(playerid, 1481.2, -1768.7, 18.8);
        SetPlayerInterior(playerid, 0);
    }
    else if (pickupid == LSPDEntrancePickup)
    {
        SetPlayerPos(playerid, 246.60001, 65.8, 1003.6);
        SetPlayerInterior(playerid, 6);
    }
    else if (pickupid == LSPDExitPickup)
    {
        SetPlayerPos(playerid, 1552.6, -1675.5, 16.2);
        SetPlayerFacingAngle(playerid, 90.003);
        SetPlayerInterior(playerid, 0);
    }
    else if (pickupid == LSPDArmorPickup)
    {
        if (Player[playerid][pFaction] != FACTION_LSPD)
            return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� LSPD.");
        ShowLSPDArmorMenu(playerid);
    }
    else if (IsPlayerInRangeOfPoint(playerid, 1.0, gLSPDBoothEnter[0], gLSPDBoothEnter[1], gLSPDBoothEnter[2]))
    {
        if (Player[playerid][pFaction] == FACTION_LSPD)
        {
            SetPlayerPos(playerid, gLSPDBoothSpawnInside[0], gLSPDBoothSpawnInside[1], gLSPDBoothSpawnInside[2]);
            SetPlayerFacingAngle(playerid, gLSPDBoothSpawnInside[3]);
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "�� �� ������ ������� � ������ LSPD.");
        }
    }
    else if (IsPlayerInRangeOfPoint(playerid, 1.0, gLSPDBoothExit[0], gLSPDBoothExit[1], gLSPDBoothExit[2]))
    {
        SetPlayerPos(playerid, gLSPDBoothSpawnOutside[0], gLSPDBoothSpawnOutside[1], gLSPDBoothSpawnOutside[2]);
        SetPlayerFacingAngle(playerid, gLSPDBoothSpawnOutside[3]);
    }
    else if (pickupid == LSPDRoofExitPickup)
    {
        if (Player[playerid][pFaction] == FACTION_LSPD)
        {
            SetPlayerPos(playerid, gLSPDInteriorAfterRoof[0], gLSPDInteriorAfterRoof[1], gLSPDInteriorAfterRoof[2]);
            SetPlayerFacingAngle(playerid, gLSPDInteriorAfterRoof[3]);
            SetPlayerInterior(playerid, 6);
            SendClientMessage(playerid, COLOR_BLUE, "�� ���������� � ����� LSPD.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ����� �����.");
        }
    }
    else if (pickupid == LSPDRoofEntrancePickup)
    {
        if (Player[playerid][pFaction] == FACTION_LSPD)
        {
            SetPlayerPos(playerid, gLSPDRoofSpawn[0], gLSPDRoofSpawn[1], gLSPDRoofSpawn[2]);
            SetPlayerFacingAngle(playerid, gLSPDRoofSpawn[3]);
            SetPlayerInterior(playerid, 0);
            SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ����� LSPD.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ����� LSPD.");
        }
    }
    else if (pickupid == BankEntrancePickup)
    {
        SetPlayerPos(playerid, 2280.5, -11.8, 26.8);
        SetPlayerInterior(playerid, 1);
        SetPlayerFacingAngle(playerid, 180.0);
    }
    else if (pickupid == BankExitPickup)
    {
        SetPlayerPos(playerid, 1457.6, -1013.3, 26.8);
        SetPlayerInterior(playerid, 0);
        SetPlayerFacingAngle(playerid, 180.0);
    }
    else if (pickupid == BankMenuPickup)
    {
        if (!gPlayerInBankMenu[playerid])
        {
            gPlayerInBankMenu[playerid] = true;
            ShowBankMenu(playerid);
        }
    }
    else if (pickupid == FBIArmorPickup)
	{
    if (Player[playerid][pFaction] != FACTION_FBI)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� FBI.");
    ShowFBIArmorMenu(playerid);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, gEMSEnter[0], gEMSEnter[1], gEMSEnter[2]))
	{
    SetPlayerPos(playerid, gEMSSpawn[0], gEMSSpawn[1], gEMSSpawn[2]);
    SetPlayerInterior(playerid, 1); // ������������, ��� �������� �������� ����� ID 1
    SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ EMS.");
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, gEMSExit[0], gEMSExit[1], gEMSExit[2]))
	{
    SetPlayerPos(playerid, gEMSExitSpawn[0], gEMSExitSpawn[1], gEMSExitSpawn[2]);
    SetPlayerInterior(playerid, 0);
    SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ������ EMS.");
	}
    else if (pickupid == SheriffEntrancePickup)
	{
	    if(Player[playerid][pFaction] == FACTION_SHERIFF)
	    {
	        SetPlayerPos(playerid, 247.89999, 72.0, 986.79999);
	        SetPlayerFacingAngle(playerid, 0.003);
	        SetPlayerInterior(playerid, 6);
	        SetPlayerVirtualWorld(playerid, VIRTUAL_WORLD_SHERIFF); // ���������� ����� ����������� ���
	        SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ Sheriff Department.");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ������ Sheriff Department.");
	    }
	}
	else if (pickupid == SheriffExitPickup)
	{
	    SetPlayerPos(playerid, 631.5, -571.70001, 16.3);
	    SetPlayerInterior(playerid, 0);
	    SetPlayerVirtualWorld(playerid, 0);
	    SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ������ Sheriff Department.");
	}
	else if (pickupid == SheriffRoofEntrancePickup)
	{
	    if(Player[playerid][pFaction] == FACTION_SHERIFF)
	    {
	        SetPlayerPos(playerid, 621.40002, -572.59998, 26.1); // �������� �� �����
	        SetPlayerInterior(playerid, 0);
	        SetPlayerVirtualWorld(playerid, 0);
	        SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ����� Sheriff Department.");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� �� ����� Sheriff Department.");
	    }
	}
	else if (pickupid == SheriffRoofExitPickup)
	{
	    SetPlayerPos(playerid, 245.2, 71.8, 986.79999); // �������� ������� � ��������
	    SetPlayerFacingAngle(playerid, -89.993);
	    SetPlayerInterior(playerid, 6);
	    SetPlayerVirtualWorld(playerid, VIRTUAL_WORLD_SHERIFF);
	    SendClientMessage(playerid, COLOR_BLUE, "�� ���������� � ����� Sheriff Department.");
	}
    else if (pickupid == GroveEntrancePickup)
    {
        if(Player[playerid][pFaction] == FACTION_GROVE)
        {
            SetPlayerPos(playerid, gGroveSpawn[0], gGroveSpawn[1], gGroveSpawn[2]);
            SetPlayerFacingAngle(playerid, gGroveSpawn[3]);
            SetPlayerInterior(playerid, 3);
            SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ��� Grove Street Gang.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ������ Grove Street Gang.");
        }
    }
    else if (pickupid == GroveExitPickup)
    {
        SetPlayerPos(playerid, gGroveExitSpawn[0], gGroveExitSpawn[1], gGroveExitSpawn[2]);
        SetPlayerFacingAngle(playerid, gGroveExitSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ���� Grove Street Gang.");
    }
    else if (pickupid == GOVParkingEnterPickup) // ���� � �������� � ������
	{
	    if(Player[playerid][pFaction] == FACTION_GOV)
	    {
	        SetPlayerPos(playerid, gGOVParkingIntSpawn[0], gGOVParkingIntSpawn[1], gGOVParkingIntSpawn[2]);
	        SetPlayerFacingAngle(playerid, gGOVParkingIntSpawn[3]);
	        SetPlayerInterior(playerid, 3);
	        SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ GOV � ��������.");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ������ GOV.");
	    }
	}
	else if (pickupid == GOVParkingExitPickup) // ����� �� ��������
	{
	    SetPlayerPos(playerid, gGOVParkingSpawn[0], gGOVParkingSpawn[1], gGOVParkingSpawn[2]);
	    SetPlayerFacingAngle(playerid, gGOVParkingSpawn[3]);
	    SetPlayerInterior(playerid, 0);
	    SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� �������� GOV.");
	}
	else if (pickupid == GOVRoofEnterPickup) // ���� �� �����
	{
	    if(Player[playerid][pFaction] == FACTION_GOV)
	    {
	        SetPlayerPos(playerid, gGOVRoofSpawn[0], gGOVRoofSpawn[1], gGOVRoofSpawn[2]);
	        SetPlayerFacingAngle(playerid, gGOVRoofSpawn[3]);
	        SetPlayerInterior(playerid, 0);
	        SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ����� GOV.");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� �� ����� GOV.");
	    }
	}
	else if (pickupid == GOVRoofExitPickup) // ����� � �����
	{
	    SetPlayerPos(playerid, gGOVRoofIntSpawn[0], gGOVRoofIntSpawn[1], gGOVRoofIntSpawn[2]);
	    SetPlayerFacingAngle(playerid, gGOVRoofIntSpawn[3]);
	    SetPlayerInterior(playerid, 3);
	    SendClientMessage(playerid, COLOR_BLUE, "�� ���������� � ����� GOV.");
	}
 	else if(pickupid == BallasEntrancePickup)
    {
        if(Player[playerid][pFaction] == FACTION_BALLAS)
        {
            SetPlayerPos(playerid, gBallasSpawnInside[0], gBallasSpawnInside[1], gBallasSpawnInside[2]);
            SetPlayerFacingAngle(playerid, gBallasSpawnInside[3]);
            SetPlayerInterior(playerid, 6);
            SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ��� Ballas.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "�� �� �������� � Ballas.");
        }
    }
    else if(pickupid == BallasExitPickup)
    {
        SetPlayerPos(playerid, gBallasExitSpawn[0], gBallasExitSpawn[1], gBallasExitSpawn[2]);
        SetPlayerFacingAngle(playerid, gBallasExitSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ���� Ballas.");
    }
    else if(pickupid == VagosEntrancePickup)
    {
        if(Player[playerid][pFaction] == FACTION_VAGOS)
        {
            SetPlayerPos(playerid, gVagosSpawn[0], gVagosSpawn[1], gVagosSpawn[2]);
            SetPlayerFacingAngle(playerid, gVagosSpawn[3]);
            SetPlayerInterior(playerid, 6);
            SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ��� Vagos.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "�� �� �������� � Vagos.");
        }
    }
    else if(pickupid == VagosExitPickup)
    {
        SetPlayerPos(playerid, gVagosExitSpawn[0], gVagosExitSpawn[1], gVagosExitSpawn[2]);
        SetPlayerFacingAngle(playerid, gVagosExitSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ���� Vagos.");
    }
    else if(pickupid == AztecEntrancePickup)
	{
    if(Player[playerid][pFaction] == FACTION_AZTEC)
    {
        SetPlayerPos(playerid, gAztecSpawnInside[0], gAztecSpawnInside[1], gAztecSpawnInside[2]);
        SetPlayerFacingAngle(playerid, gAztecSpawnInside[3]);
        SetPlayerInterior(playerid, 5);
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ��� Aztec.");
    }
    else
    {
        SendClientMessage(playerid, COLOR_RED, "�� �� �������� � Aztec.");
    }
	}
	else if(pickupid == AztecExitPickup)
	{
    SetPlayerPos(playerid, gAztecExitSpawn[0], gAztecExitSpawn[1], gAztecExitSpawn[2]);
    SetPlayerFacingAngle(playerid, gAztecExitSpawn[3]);
    SetPlayerInterior(playerid, 0);
    SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ���� Aztec.");
	}
 	else if(pickupid == SANNEntrancePickup) // ���� � ������
    {
        SetPlayerPos(playerid, gSANNSpawn[0], gSANNSpawn[1], gSANNSpawn[2]);
        SetPlayerFacingAngle(playerid, gSANNSpawn[3]);
        SetPlayerInterior(playerid, 3); // ���������� ���������� interior ID
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ SANN.");
    }
    else if(pickupid == SANNExitPickup) // ����� �� ������
    {
        SetPlayerPos(playerid, gSANNExitSpawn[0], gSANNExitSpawn[1], gSANNExitSpawn[2]);
        SetPlayerFacingAngle(playerid, gSANNExitSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ������ SANN.");
    }
    else if(pickupid == SANNRoofEnterPickup) // ���� �� �����
    {
        SetPlayerPos(playerid, gSANNRoofSpawn[0], gSANNRoofSpawn[1], gSANNRoofSpawn[2]);
        SetPlayerFacingAngle(playerid, gSANNRoofSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ����� SANN.");
    }
    else if(pickupid == SANNRoofExitPickup) // ����� � �����
    {
        SetPlayerPos(playerid, gSANNRoofReturn[0], gSANNRoofReturn[1], gSANNRoofReturn[2]);
        SetPlayerFacingAngle(playerid, gSANNRoofReturn[3]);
        SetPlayerInterior(playerid, 3); // ���������� ���������� interior ID
        SendClientMessage(playerid, COLOR_BLUE, "�� ���������� � ����� SANN.");
    }
    
    return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
    return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
    return 1;
}

public OnPlayerExitedMenu(playerid)
{
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    if(oldinteriorid == 1 && newinteriorid != 1) // ����� �� ��������
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health < 100)
        {
            SetPlayerPos(playerid, EMSSpawnPoints[0][0], EMSSpawnPoints[0][1], EMSSpawnPoints[0][2]);
            SetPlayerInterior(playerid, 1);
            SendClientMessage(playerid, COLOR_ERROR, "�� �� ������ �������� ��������, ���� ���� �������� �� ������������� ���������.");
        }
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // ��������� ������� ������� Y (KEY_WALK)
    if(newkeys & KEY_WALK)
    {
        // Big John NPC
        if(IsPlayerInRangeOfPoint(playerid, 3.0, BIGJOHN_POS[0], BIGJOHN_POS[1], BIGJOHN_POS[2]))
        {
            ShowPlayerDialog(playerid, DIALOG_MISSIONS, DIALOG_STYLE_LIST, "������� �� Big John",
                "��������� ��������\n������ ����", "�������", "������");
            return 1;
        }

        // ����������
	    for(new i = 0; i < sizeof(Dealership); i++)
	    {
	        if(!Dealership[i][dExists]) continue;
	        if(IsPlayerInRangeOfPoint(playerid, 2.0,
	            Dealership[i][dMenuX],
	            Dealership[i][dMenuY],
	            Dealership[i][dMenuZ]))
	        {
	            ShowDealershipMenu(playerid, Dealership[i][dType]);
	            return 1;
	        }
	    }

	    // ����� �������� ����������� �� �����������
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, 566.0, -1293.9, 17.2)) // Premium
	    {
	        ShowDealershipMenu(playerid, DEALERSHIP_PREMIUM);
	        return 1;
	    }
	    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 338.0, -1816.0, 4.3)) // Medium
	    {
	        ShowDealershipMenu(playerid, DEALERSHIP_MEDIUM);
	        return 1;
	    }
	    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1993.9, -2057.0, 13.4)) // Economy
	    {
	        ShowDealershipMenu(playerid, DEALERSHIP_ECONOMY);
	        return 1;
	    }
	    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1527.4, -2432.7, 13.6)) // Helicopter
	    {
	        ShowDealershipMenu(playerid, DEALERSHIP_HELI);
	        return 1;
	    }
	    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 2133.7998, -1151.2002, 24.1)) // Moto
	    {
	        ShowDealershipMenu(playerid, DEALERSHIP_MOTO);
	        return 1;
	    }

        // ������ ����������
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 1680.4, -2325.8999, 13.5))
        {
            ShowRentalDialog(playerid);
            return 1;
        }

        // ��������� ��������
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 359.79999, 173.60001, 1008.4) && GetPlayerInterior(playerid) == 3)
        {
            ShowPlayerDialog(playerid, DIALOG_PASSPORT, DIALOG_STYLE_MSGBOX,
                "��������� ��������",
                "�� ������ �������� �������?",
                "��", "���");
            return 1;
        }

        // ����� LSPD
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 245.3999900, 72.6000000, 1002.6000000) &&
           GetPlayerInterior(playerid) == 6)
        {
            if(Player[playerid][pFaction] == FACTION_LSPD)
            {
                LSPDDoorState = !LSPDDoorState;
                AnimateLSPDDoor(LSPDDoorState);
                new string[64];
                format(string, sizeof(string), "�� %s ����� LSPD.", LSPDDoorState ? "�������" : "�������");
                SendClientMessage(playerid, COLOR_BLUE, string);
            }
            else
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� ������.");
            }
            return 1;
        }

        // ����� Sheriff
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 246.5, 78.0, 985.79999) &&
           GetPlayerInterior(playerid) == 6 &&
           GetPlayerVirtualWorld(playerid) == VIRTUAL_WORLD_SHERIFF)
        {
            if(Player[playerid][pFaction] == FACTION_SHERIFF)
            {
                SheriffDoorState = !SheriffDoorState;
                AnimateSheriffDoor(SheriffDoorState);
                new string[64];
                format(string, sizeof(string), "�� %s ����� SHPD.", SheriffDoorState ? "�������" : "�������");
                SendClientMessage(playerid, COLOR_BLUE, string);
            }
            else
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� ������.");
            }
            return 1;
        }

        // ����
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 2288.5, -19.8, 26.7) && GetPlayerInterior(playerid) == 1)
        {
            ShowBankMenu(playerid);
            return 1;
        }

        // ���������
        for(new i = 0; i < sizeof(gATMLocations); i++)
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, gATMLocations[i][0], gATMLocations[i][1], gATMLocations[i][2]))
            {
                ShowATMMenu(playerid);
                return 1;
            }
        }
    }

    // ���������� ������������ �������� �� ����� ������ � ����������
    if(PlayerDoingStashMission[playerid] == true)
    {
        // ��������� ������������� ������ � ������ ��������
        if(newkeys & KEY_FIRE || newkeys & KEY_ACTION)
        {
            return 0;
        }
    }

    return 1;
}



public OnRconLoginAttempt(ip[], password[], success)
{
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(PlayerIsDying[playerid])
    {
        // ������������ ��������� "������"
        SetPlayerHealth(playerid, 1.0);
        TogglePlayerControllable(playerid, 0);
        ApplyDeathAnimation(playerid);

        // ��������� ������
        SetPlayerCameraPos(playerid, LastPlayerPos[playerid][0] + 2.0, LastPlayerPos[playerid][1] + 2.0, LastPlayerPos[playerid][2] + 1.0);
        SetPlayerCameraLookAt(playerid, LastPlayerPos[playerid][0], LastPlayerPos[playerid][1], LastPlayerPos[playerid][2]);

        return 0;
    }

    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);

    if(keys == KEY_YES) // KEY_YES ������������� ������� Y
    {
        if(GetPlayerInterior(playerid) == 1) // ����� ������ FBI
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, 2270.503662, -205.257537, 982.599487)) // ���� 1 �����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������������ ���� ������.");
                    return 1;
                }
                SetPlayerPos(playerid, 2271.731933, -208.509765, 987.339477);
                SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ������ ���� FBI.");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2270.462646, -205.240417, 987.339477)) // ���� 1 ����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������������ ���� ������.");
                    return 1;
                }
                SetPlayerPos(playerid, 2270.092529, -207.825561, 982.599487);
                SendClientMessage(playerid, COLOR_BLUE, "�� ���������� �� ������ ���� FBI.");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2253.530761, -205.257354, 982.599487)) // ���� 2 �����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������������ ���� ������.");
                    return 1;
                }
                SetPlayerPos(playerid, 2252.453613, -208.120864, 987.339477);
                SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ������ ���� FBI (������ �������).");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2253.402832, -205.239501, 987.339477)) // ���� 2 ����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������������ ���� ������.");
                    return 1;
                }
                SetPlayerPos(playerid, 2253.025146, -208.246917, 982.599487);
                SendClientMessage(playerid, COLOR_BLUE, "�� ���������� �� ������ ���� FBI (������ �������).");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, gFBIExit[0], gFBIExit[1], gFBIExit[2])) // ����� �� FBI
            {
                SetPlayerPos(playerid, gFBIExitSpawn[0], gFBIExitSpawn[1], gFBIExitSpawn[2]);
                SetPlayerFacingAngle(playerid, gFBIExitSpawn[3]);
                SetPlayerInterior(playerid, 0);
                SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ������ FBI.");
            }
            // ����� ��������� ������ FBI
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2256.777099, -209.620666, 987.339477)) // ����� �� �������
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������ � ��������.");
                    return 1;
                }
                SetPlayerPos(playerid, 1546.707031, -1385.064453, 14.023437);
                SetPlayerInterior(playerid, 0);
                SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� �������� FBI.");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2267.323486, -209.741439, 987.339477)) // ���� �� �����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������ � �����.");
                    return 1;
                }
                SetPlayerPos(playerid, 1547.1, -1366.5, 326.20001);
                SetPlayerInterior(playerid, 0);
                SetPlayerFacingAngle(playerid, 90.004);
                SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ����� FBI.");
            }
        }
        else if(GetPlayerInterior(playerid) == 0) // ����� �� �����
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, gFBIEnter[0], gFBIEnter[1], gFBIEnter[2])) // ���� � FBI
            {
                SetPlayerPos(playerid, gFBISpawn[0], gFBISpawn[1], gFBISpawn[2]);
                SetPlayerFacingAngle(playerid, gFBISpawn[3]);
                SetPlayerInterior(playerid, 1);
                SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ FBI.");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 1546.707031, -1385.064453, 14.023437)) // ���� � ��������
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������ � ����� �����.");
                    return 1;
                }
                SetPlayerPos(playerid, 2256.777099, -209.620666, 987.339477);
                SetPlayerInterior(playerid, 1);
                SendClientMessage(playerid, COLOR_BLUE, "�� ����� � ������ FBI ����� ��������.");
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2.0, 1548.6, -1363.6, 326.20001)) // ����� � �����
            {
                if(Player[playerid][pFaction] != FACTION_FBI)
                {
                    SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������ � ����� �����.");
                    return 1;
                }
                SetPlayerPos(playerid, 2270.711914, -209.688796, 987.339477);
                SetPlayerInterior(playerid, 1);
                SendClientMessage(playerid, COLOR_BLUE, "�� ���������� � ����� FBI.");
            }
        }
    }

    // ����������� ���������
    if(GetPlayerInterior(playerid) == 0) // ����� �� �����
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, gFBIEnter[0], gFBIEnter[1], gFBIEnter[2]) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 1546.707031, -1385.064453, 14.023437) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 1548.6, -1363.6, 326.20001))
        {
            GameTextForPlayer(playerid, "������� ~y~Y~w~ ��� �����", 1000, 4);
        }
    }
    else if(GetPlayerInterior(playerid) == 1) // ����� ������ FBI
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, 2256.777099, -209.620666, 987.339477) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 2267.323486, -209.741439, 987.339477) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, gFBIExit[0], gFBIExit[1], gFBIExit[2]) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 2270.503662, -205.257537, 982.599487) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 2270.462646, -205.240417, 987.339477) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 2253.530761, -205.257354, 982.599487) ||
           IsPlayerInRangeOfPoint(playerid, 2.0, 2253.402832, -205.239501, 987.339477))
        {
            GameTextForPlayer(playerid, "������� ~y~Y~w~ ��� �������������", 1000, 4);
        }
    }

    return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
    return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
    return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
    return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
    return 1;
}

GetDealershipSpawnPoint(dealershipType, &Float:x, &Float:y, &Float:z, &Float:angle)
{
    switch(dealershipType)
    {
        case DEALERSHIP_PREMIUM:
        {
            x = 557.20001;
            y = -1266.8;
            z = 17.1;
            angle = 0.0;
        }
        case DEALERSHIP_MEDIUM:
        {
            x = 349.20001;
            y = -1791.3;
            z = 4.8;
            angle = 0.0;
        }
        case DEALERSHIP_ECONOMY:
        {
            x = 1977.1;
            y = -2057.8999;
            z = 13.2;
            angle = 90.0;
        }
        case DEALERSHIP_HELI:
        {
            x = 1525.2002;
            y = -2467.7998;
            z = 13.8;
            angle = 0.0;
        }
        case DEALERSHIP_MOTO:
        {
            x = 2127.1006;
            y = -1132.7998;
            z = 25.2;
            angle = 0.0;
        }
    }
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_REGISTER:
        {
            if(!response) return Kick(playerid);
            if(strlen(inputtext) < 6)
            {
                new caption[] = "������";
                new info[] = "������ ������ ��������� ��� ������� 6 ��������\n������� ����� ������:";
                new button1[] = "������";
                new button2[] = "�����";
                return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, caption, info, button1, button2);
            }
            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name, sizeof(name));
            if(!IsValidName(name))
            {
                new caption[] = "������";
                new info[] = "�������� ���. ������ �����: ���_�������";
                new button1[] = "��";
                new button2[] = "";
                return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_MSGBOX, caption, info, button1, button2);
            }
            format(Player[playerid][pPassword], 65, inputtext);
            new caption[] = "����� ����";
            new info[] = "�������\n�������";
            new button1[] = "�������";
            new button2[] = "������";
            ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, caption, info, button1, button2);
            Player[playerid][pMoney] = 0;
        }
        case DIALOG_DEALERSHIP:
        {
            if(!response) return 1;

            new dealershipType = GetPVarInt(playerid, "DealershipType");
            new vehicleIndex = -1;
            new currentItem = 0;

            // ����� ���������� ����������
            for(new i = 0; i < sizeof(DealershipVehicles); i++)
            {
                if(!DealershipVehicles[i][vExists]) continue;
                if(DealershipVehicles[i][vDealershipType] != dealershipType) continue;

                if(currentItem == listitem)
                {
                    vehicleIndex = i;
                    break;
                }
                currentItem++;
            }

            if(vehicleIndex == -1) return 1;

            // �������� �����
            if(GetPlayerMoney(playerid) < DealershipVehicles[vehicleIndex][vPrice])
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ������������ �����!");
                return 1;
            }

            // ����� ���������� �����
            new slot = -1;
            for(new i = 0; i < 5; i++)
            {
                if(!OwnedVehicle[playerid][i][ovExists])
                {
                    slot = i;
                    break;
                }
            }

            if(slot == -1)
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ��� ��������� ������ ��� ����������!");
                return 1;
            }

            // ������� ����������
            GivePlayerMoney(playerid, -DealershipVehicles[vehicleIndex][vPrice]);

            // �������� ���������� ������ ��� ���������������� ����������
            new Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnAngle;
            switch(dealershipType)
            {
                case DEALERSHIP_PREMIUM:
                {
                    spawnX = 557.20001;
                    spawnY = -1266.8;
                    spawnZ = 17.1;
                    spawnAngle = 0.0;
                }
                case DEALERSHIP_MEDIUM:
                {
                    spawnX = 349.20001;
                    spawnY = -1791.3;
                    spawnZ = 4.8;
                    spawnAngle = 0.0;
                }
                case DEALERSHIP_ECONOMY:
                {
                    spawnX = 1977.1;
                    spawnY = -2057.8999;
                    spawnZ = 13.2;
                    spawnAngle = 90.0;
                }
                case DEALERSHIP_HELI:
                {
                    spawnX = 1525.2002;
                    spawnY = -2467.7998;
                    spawnZ = 13.8;
                    spawnAngle = 0.0;
                }
                case DEALERSHIP_MOTO:
                {
                    spawnX = 2127.1006;
                    spawnY = -1132.7998;
                    spawnZ = 25.2;
                    spawnAngle = 0.0;
                }
            }

            // ������� ������ � ����������
            OwnedVehicle[playerid][slot][ovExists] = true;
            OwnedVehicle[playerid][slot][ovModel] = DealershipVehicles[vehicleIndex][vModel];
            format(OwnedVehicle[playerid][slot][ovOwner], MAX_PLAYER_NAME, ReturnPlayerName(playerid));
            OwnedVehicle[playerid][slot][ovParkX] = spawnX;
            OwnedVehicle[playerid][slot][ovParkY] = spawnY;
            OwnedVehicle[playerid][slot][ovParkZ] = spawnZ;
            OwnedVehicle[playerid][slot][ovParkAngle] = spawnAngle;

            // ������� ���������
            new vehicleid = CreateVehicle(
                DealershipVehicles[vehicleIndex][vModel],
                spawnX, spawnY, spawnZ, spawnAngle,
                -1, -1, -1
            );

            OwnedVehicle[playerid][slot][ovVehicleID] = vehicleid;

            // ������������� �������� ����
            new plate[32];
            format(plate, sizeof(plate), "%s_%d", ReturnPlayerName(playerid), slot + 1);
            SetVehicleNumberPlate(vehicleid, plate);

            // ��������� � �������
            new string[128];
            format(string, sizeof(string), "�� ������ %s �� $%d",
                DealershipVehicles[vehicleIndex][vName],
                DealershipVehicles[vehicleIndex][vPrice]
            );
            SendClientMessage(playerid, COLOR_GREEN, string);

            // ��������� ������
            SaveOwnedVehicles(playerid);
        }
        case DIALOG_LOGIN:
        {
            if(!response) return Kick(playerid);
            new file[128], name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name, sizeof(name));
            format(file, sizeof(file), FILE_USERS, name);
            LoadUser(playerid, file);

            if(!strcmp(inputtext, Player[playerid][pPassword], true))
            {
                SendClientMessage(playerid, -1, "�� ������� ��������������!");
                SetSpawnInfo(playerid, 0, 0, 1680.4, -2325.8999, 13.5, 0.003, 0, 0, 0, 0, 0, 0);
                SpawnPlayer(playerid);
            }
            else
            {
                new caption[] = "������ �����������";
                new info[] = "�������� ������\n������� ������ ��� ���:";
                new button1[] = "����������� �����";
                new button2[] = "�����";
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, caption, info, button1, button2);
            }
        }
        case DIALOG_GENDER:
        {
            if(!response)
            {
                new caption[] = "������";
                new info[] = "������� ����� ������:";
                new button1[] = "������";
                new button2[] = "�����";
                return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, caption, info, button1, button2);
            }
            Player[playerid][pGender] = listitem;
            new caption[] = "����� ��������";
            new info[] = "������� ��� �������:";
            new button1[] = "�����������";
            new button2[] = "������";
            ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, caption, info, button1, button2);
        }
        case DIALOG_AGE:
        {
            if(!response)
            {
                new caption[] = "����� ����";
                new info[] = "�������\n�������";
                new button1[] = "�������";
                new button2[] = "������";
                return ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, caption, info, button1, button2);
            }
            new age = strval(inputtext);
            if(age < 18 || age > 80)
            {
                new caption[] = "������ ��������";
                new info[] = "������� ������ ���� �� 18 �� 80 ���\n������� �������:";
                new button1[] = "�����������";
                new button2[] = "������";
                return ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, caption, info, button1, button2);
            }
            Player[playerid][pAge] = age;
            new caption[] = "����� ��������������";
            new info[] = "����������\n���������\n��������\n�����\n������";
            new button1[] = "�������";
            new button2[] = "������";
            ShowPlayerDialog(playerid, DIALOG_NATIONALITY, DIALOG_STYLE_LIST, caption, info, button1, button2);
        }
        case DIALOG_NATIONALITY:
        {
            if(!response)
            {
                new caption[] = "������ ��������";
                new info[] = "������� �������:";
                new button1[] = "�����������";
                new button2[] = "������";
                return ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, caption, info, button1, button2);
            }
            Player[playerid][pNationality] = listitem;
            Player[playerid][pHasPassport] = false;
            SaveUser(playerid);
            SpawnPlayer(playerid);
        }
		case DIALOG_RENTAL:
		{
		    if (response)
		    {
		        switch(listitem)
		        {
		            case 0: // ������ �������
		            {
		                if (GetPlayerMoney(playerid) >= 150)
		                {
		                    GivePlayerMoney(playerid, -150);
		                    new Float:x, Float:y, Float:z;
		                    GetPlayerPos(playerid, x, y, z);
		                    new vehicleid = CreateVehicle(462, x + 2.0, y, z, 0.0, -1, -1, 600);
		                    RentedVehicle[playerid] = vehicleid; // ��������� ID ������������� ����������
		                    SetTimerEx("EndRental", 3600000, false, "ii", playerid, vehicleid);
		                    SendClientMessage(playerid, -1, "�� ���������� ������ �� 1 ��� �� 150$.");
		                }
		                else
		                {
		                    SendClientMessage(playerid, -1, "� ��� ������������ ����� ��� ������ �������.");
		                }
		            }
		            case 1: // ������ ����
		            {
		                ShowPlayerDialog(playerid, DIALOG_TIPS, DIALOG_STYLE_MSGBOX,
		                    "������ ����",
		                    "1. ��������� ������\n2. ��������� �����\n3. ���������� �������",
		                    "OK", "");
		            }
		            case 2: // ������ �������
		            {
		                ShowPlayerDialog(playerid, DIALOG_QUEST, DIALOG_STYLE_MSGBOX,
		                    "������ �������",
		                    "���������� ������� ��� ��������� �����.",
		                    "OK", "");
		            }
		        }
		    }
		}
        case DIALOG_PASSPORT:
        {
            if (response)
            {
                if (!Player[playerid][pHasPassport])
                {
                    Player[playerid][pHasPassport] = true;
                    new name[MAX_PLAYER_NAME], string[128];
                    GetPlayerName(playerid, name, sizeof(name));
                    format(string, sizeof(string), "�� ������� �������� ������� �� ��� %s", name);
                    SendClientMessage(playerid, -1, string);
                    SaveUser(playerid);
                }
                else
                {
                    SendClientMessage(playerid, -1, "� ��� ��� ���� �������.");
                }
            }
        }
        case DIALOG_VEHICLE_CONTROL:
        {
            if(!response) return 1;

            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == 0)
            {
                vehicleid = GetClosestVehicle(playerid);
            }

            if(vehicleid == INVALID_VEHICLE_ID)
            {
                SendClientMessage(playerid, COLOR_RED, "����� ��� ����������.");
                return 1;
            }

            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

            switch(listitem)
            {
                case 0: // ������� �����
                {
                    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
                }
                case 1: // ������� �����
                {
                    SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
                }
                case 2: // �������� ���������
                {
                    SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "��������� �������.");
                }
                case 3: // ��������� ���������
                {
                    SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "��������� ��������.");
                }
                case 4: // ������� ��������
                {
                    SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 1, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "�������� ������.");
                }
                case 5: // ������� ��������
                {
                    SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 0, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "�������� ������.");
                }
                case 6: // ���������� �������
                {
                    ShowCarDoorsDialog(playerid);
                }
                case 7: // �������� ����
                {
                    SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "���� ��������.");
                }
                case 8: // ��������� ����
                {
                    SetVehicleParamsEx(vehicleid, engine, 0, alarm, doors, bonnet, boot, objective);
                    SendClientMessage(playerid, COLOR_GREEN, "���� ���������.");
                }
            }
        }
        case DIALOG_VEHICLE_DOORS:
        {
            if(!response)
            {
                ShowCarControlDialog(playerid);
                return 1;
            }

            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == 0)
            {
                vehicleid = GetClosestVehicle(playerid);
            }

            if(vehicleid == INVALID_VEHICLE_ID)
            {
                SendClientMessage(playerid, COLOR_RED, "����� ��� ����������.");
                return 1;
            }

            new door = listitem / 2;
            new action = listitem % 2;
            new doors, driver, passenger, backleft, backright;
            GetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright);

            if(action == 0) // ������� �����
            {
                switch(door)
                {
                    case 0: driver = 1;
                    case 1: passenger = 1;
                    case 2: backleft = 1;
                    case 3: backright = 1;
                }
                SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
            }
            else // ������� �����
            {
                switch(door)
                {
                    case 0: driver = 0;
                    case 1: passenger = 0;
                    case 2: backleft = 0;
                    case 3: backright = 0;
                }
                SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
            }

            SetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright);
        }
        case DIALOG_BANK_MENU:
        {
            if(response)
            {
                new title[64], info[128], button1[32], button2[32];
                format(title, sizeof(title), "%s", DIALOG_TITLE_BANK_OPERATIONS);
                format(info, sizeof(info), "%s", DIALOG_INFO_BANK_OPERATIONS);
                format(button1, sizeof(button1), "%s", DIALOG_BUTTON1_SELECT);
                format(button2, sizeof(button2), "%s", DIALOG_BUTTON2_BACK);
                ShowPlayerDialog(playerid, DIALOG_BANK_OPERATIONS, DIALOG_STYLE_LIST, title, info, button1, button2);
            }
        }
        case DIALOG_BANK_OPERATIONS:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // ��������� ����
                    {
                        new title[64], info[128], button1[32], button2[32];
                        format(title, sizeof(title), "%s", DIALOG_TITLE_DEPOSIT);
                        format(info, sizeof(info), "%s", DIALOG_INFO_DEPOSIT);
                        format(button1, sizeof(button1), "%s", DIALOG_BUTTON1_DEPOSIT);
                        format(button2, sizeof(button2), "%s", DIALOG_BUTTON2_DEPOSIT);
                        ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, title, info, button1, button2);
                    }
                    case 1: // ����� �� �����
                    {
                        new title[64], info[128], button1[32], button2[32];
                        format(title, sizeof(title), "%s", DIALOG_TITLE_WITHDRAW);
                        format(info, sizeof(info), "%s", DIALOG_INFO_WITHDRAW);
                        format(button1, sizeof(button1), "%s", DIALOG_BUTTON1_WITHDRAW);
                        format(button2, sizeof(button2), "%s", DIALOG_BUTTON2_WITHDRAW);
                        ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, title, info, button1, button2);
                    }
                }
            }
            else
            {
                ShowBankMenu(playerid);
            }
        }
        case DIALOG_BANK_DEPOSIT:
        {
            if(response)
            {
                new amount = strval(inputtext);
                if(amount > 0 && amount <= GetPlayerMoney(playerid))
                {
                    GivePlayerMoney(playerid, -amount);
                    Player[playerid][pBankMoney] += amount;
                    new string[128];
                    format(string, sizeof(string), DIALOG_MSG_DEPOSIT_SUCCESS, amount, Player[playerid][pBankMoney]);
                    SendClientMessage(playerid, COLOR_GREEN, string);
                    SaveUser(playerid);
                }
                else
                {
                    SendClientMessage(playerid, COLOR_RED, DIALOG_MSG_INVALID_AMOUNT);
                }
                ShowBankMenu(playerid);
            }
            else
            {
                new title[64], info[128], button1[32], button2[32];
                format(title, sizeof(title), "%s", DIALOG_TITLE_BANK_OPERATIONS);
                format(info, sizeof(info), "%s", DIALOG_INFO_BANK_OPERATIONS);
                format(button1, sizeof(button1), "%s", DIALOG_BUTTON1_SELECT);
                format(button2, sizeof(button2), "%s", DIALOG_BUTTON2_BACK);
                ShowPlayerDialog(playerid, DIALOG_BANK_OPERATIONS, DIALOG_STYLE_LIST, title, info, button1, button2);
            }
        }
        case DIALOG_BANK_WITHDRAW:
        {
            if(response)
            {
                new amount = strval(inputtext);
                if(amount > 0 && amount <= Player[playerid][pBankMoney])
                {
                    GivePlayerMoney(playerid, amount);
                    Player[playerid][pBankMoney] -= amount;
                    new string[128];
                    format(string, sizeof(string), DIALOG_MSG_WITHDRAW_SUCCESS, amount, Player[playerid][pBankMoney]);
                    SendClientMessage(playerid, COLOR_GREEN, string);
                    SaveUser(playerid);
                }
                else
                {
                    SendClientMessage(playerid, COLOR_RED, DIALOG_MSG_INVALID_AMOUNT_WITHDRAW);
                }
                ShowBankMenu(playerid);
            }
            else
            {
                new title[64], info[128], button1[32], button2[32];
                format(title, sizeof(title), "%s", DIALOG_TITLE_BANK_OPERATIONS);
                format(info, sizeof(info), "%s", DIALOG_INFO_BANK_OPERATIONS);
                format(button1, sizeof(button1), "%s", DIALOG_BUTTON1_SELECT);
                format(button2, sizeof(button2), "%s", DIALOG_BUTTON2_BACK);
                ShowPlayerDialog(playerid, DIALOG_BANK_OPERATIONS, DIALOG_STYLE_LIST, title, info, button1, button2);
            }
        }
        case DIALOG_ATM_MENU:
        {
            if(response)
            {
                if(listitem == 0) // ����� ������
                {
                    ShowPlayerDialog(playerid, DIALOG_ATM_WITHDRAW, DIALOG_STYLE_INPUT,
                        DIALOG_TITLE_ATM_WITHDRAW,
                        DIALOG_INFO_ATM_WITHDRAW,
                        DIALOG_BUTTON_WITHDRAW,
                        DIALOG_BUTTON_CANCEL);
                }
            }
        }
		case DIALOG_ATM_WITHDRAW:
		{
		    if(response)
		    {
		        new amount = strval(inputtext);
		        if(amount <= 0 || amount > Player[playerid][pBankMoney])
		        {
		            SendClientMessage(playerid, COLOR_RED, "�������� ����� ��� ������������ ������� �� �����.");
		            ShowATMMenu(playerid);
		            return 1;
		        }

		        new commission = floatround(amount * ATM_COMMISSION);
		        new totalAmount = amount + commission;

		        if(totalAmount > Player[playerid][pBankMoney])
		        {
		            SendClientMessage(playerid, COLOR_RED, "������������ ������� �� ����� � ������ ��������.");
		            ShowATMMenu(playerid);
		            return 1;
		        }

		        Player[playerid][pBankMoney] -= totalAmount;
		        GivePlayerMoney(playerid, amount);

		        new string[128];
		        format(string, sizeof(string), "�� ����� $%d. ��������: $%d.", amount, commission);
		        SendClientMessage(playerid, COLOR_GREEN, string);
		        SendClientMessage(playerid, COLOR_YELLOW, "� ��� ������� 2 �������� �� ����� �� ������������� ���������.");

		        SaveUser(playerid);
		    }
		    ShowATMMenu(playerid);
		}
        case DIALOG_CLOTHES_SHOP:
        {
            if(!response)
            {
                gIsInClothingMenu[playerid] = false;
                SetPlayerSkin(playerid, GetPVarInt(playerid, "OldSkin"));
                return 1;
            }

            if(GetPlayerMoney(playerid) < Skins[listitem][SkinPrice])
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ������������ ����� ��� ������� ���� ������!");
                gIsInClothingMenu[playerid] = false;
                SetPlayerSkin(playerid, GetPVarInt(playerid, "OldSkin"));
                return 1;
            }

            // ��������� ����� ������
            SetPVarInt(playerid, "SelectedSkinID", Skins[listitem][SkinID]);
            SetPVarInt(playerid, "SelectedSkinPrice", Skins[listitem][SkinPrice]);
            SetPVarInt(playerid, "SelectedSkinIndex", listitem);

            // ���������� ��������������� ��������
            SetPlayerSkin(playerid, Skins[listitem][SkinID]);

            // ������ �������������
            new string[128];
            format(string, sizeof(string), "�� ������ ������ ���� �������� ������ �� $%d?\n������� '��' ��� ������������� �������.",
                Skins[listitem][SkinPrice]);

            ShowPlayerDialog(playerid, DIALOG_CLOTHES_CONFIRM, DIALOG_STYLE_MSGBOX,
                "������������� �������",
                string,
                "��", "���");
        }

        case DIALOG_CLOTHES_CONFIRM:
        {
            if(!response)
            {
                // ���������� ������ ���� ���� ����� ���������
                SetPlayerSkin(playerid, GetPVarInt(playerid, "OldSkin"));
                ShowClothingSelection(playerid); // ���������� ���� �����
                return 1;
            }

            new skinid = GetPVarInt(playerid, "SelectedSkinID");
            new price = GetPVarInt(playerid, "SelectedSkinPrice");
            new skinIndex = GetPVarInt(playerid, "SelectedSkinIndex");

            // ��������� ������ ��� ���
            if(GetPlayerMoney(playerid) < price)
            {
                SendClientMessage(playerid, COLOR_RED, "� ��� ������������ �����!");
                SetPlayerSkin(playerid, GetPVarInt(playerid, "OldSkin"));
                gIsInClothingMenu[playerid] = false;
                return 1;
            }

            // ������� ������ � ������������� ����
            GivePlayerMoney(playerid, -price);
            SetPlayerSkin(playerid, skinid);

            // ��������� ����� ���� ��� �����������
            Player[playerid][PlayerSkin] = skinid;

            new string[128];
            format(string, sizeof(string), "�� ������� ��������� ����� ������ '%s' �� $%d!",
                Skins[skinIndex][SkinName], price);
            SendClientMessage(playerid, COLOR_GREEN, string);

            // ������� ��������� ����������
            DeletePVar(playerid, "SelectedSkinID");
            DeletePVar(playerid, "SelectedSkinPrice");
            DeletePVar(playerid, "SelectedSkinIndex");
            DeletePVar(playerid, "OldSkin");

            // ���������� ���� ����� �������� �������
            gIsInClothingMenu[playerid] = false;
        }
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    return 1;
}

CMD:pass(playerid, params[])
{
    new targetid;
    if (sscanf(params, "u", targetid))
    {
        new message[] = "�������������: /pass [id ������]";
        SendClientMessage(playerid, -1, message);
        return 1;
    }

    if (!IsPlayerConnected(targetid))
    {
        new message[] = "����� �� ���������.";
        SendClientMessage(playerid, -1, message);
        return 1;
    }

    if (!Player[targetid][pHasPassport])
    {
        new message[] = "� ����� ������ ��� ��������.";
        SendClientMessage(playerid, -1, message);
        return 1;
    }

    new name[MAX_PLAYER_NAME], string[256];
    GetPlayerName(targetid, name, sizeof(name));
    format(string, sizeof(string), "������� ������ %s:\n���: %s\n�������: %d\n��������������: %s\n�����: Los Santos Government",
        name, name, Player[targetid][pAge], GetNationalityName(Player[targetid][pNationality]));
    new title[] = "���������� � ��������";
    new button1[] = "�������";
    new button2[] = "";
    ShowPlayerDialog(playerid, DIALOG_PASSPORT_INFO, DIALOG_STYLE_MSGBOX, title, string, button1, button2);
    return 1;
}

stock SaveUser(playerid)
{
    new file[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), FILE_USERS, name);
    new File:fhandle = fopen(file, io_write);
    if(fhandle)
    {
        new string[512];
        format(string, sizeof(string), "Password=%s\n", Player[playerid][pPassword]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "Gender=%d\n", Player[playerid][pGender]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "Age=%d\n", Player[playerid][pAge]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "Nationality=%d\n", Player[playerid][pNationality]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "HasPassport=%d\n", Player[playerid][pHasPassport]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "Money=%d\n", GetPlayerMoney(playerid));
        fwrite(fhandle, string);
        format(string, sizeof(string), "Faction=%d\n", Player[playerid][pFaction]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "Rank=%d\n", Player[playerid][pRank]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "AdminLevel=%d\n", Player[playerid][pAdminLevel]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "WantedLevel=%d\n", Player[playerid][pWantedLevel]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "WantedReason=%s\n", Player[playerid][pWantedReason]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "BankMoney=%d\n", Player[playerid][pBankMoney]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "BankAccount=%d\n", Player[playerid][pBankAccount]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "LastPayday=%d\n", Player[playerid][pLastPayday]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "PaycheckAmount=%d\n", Player[playerid][pPaycheckAmount]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "CanDoStashMission=%d\n", Player[playerid][pCanDoStashMission]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "StashMissionCooldown=%d\n", Player[playerid][pStashMissionCooldown]);
        fwrite(fhandle, string);
        format(string, sizeof(string), "HasMilitaryID=%d\n", Player[playerid][pHasMilitaryID]);
		fwrite(fhandle, string);
		format(string, sizeof(string), "MilitaryIDIssuer=%s\n", Player[playerid][pMilitaryIDIssuer]);
		fwrite(fhandle, string);
		format(string, sizeof(string), "MilitaryIDDate=%s\n", Player[playerid][pMilitaryIDDate]);
		fwrite(fhandle, string);
		format(string, sizeof(string), "TruckerLevel=%d\n", Player[playerid][pTruckerLevel]);
		fwrite(fhandle, string);
		format(string, sizeof(string), "TruckerExp=%d\n", Player[playerid][pTruckerExp]);
		fwrite(fhandle, string);


        // ���������� ���������� � �������
        new bizID = -1;
        for(new i = 0; i < MAX_BUSINESSES; i++)
        {
            if(Business[i][bExists] && !strcmp(Business[i][bOwner], name, true))
            {
                bizID = i;
                break;
            }
        }
        format(string, sizeof(string), "OwnedBusiness=%d\n", bizID);
        fwrite(fhandle, string);

        // ���������� ���������� � ����
        new houseID = -1;
        for(new i = 0; i < MAX_HOUSES; i++)
        {
            if(House[i][hExists] && !strcmp(House[i][hOwner], name, true))
            {
                houseID = i;
                break;
            }
        }
        format(string, sizeof(string), "OwnedHouse=%d\n", houseID);
        fwrite(fhandle, string);

        // ���������� ���������� � ������ ����������
        new vehicleCount = 0;
        new vehicleString[512] = "";

        for(new i = 0; i < 5; i++)
        {
            if(OwnedVehicle[playerid][i][ovExists])
            {
                if(vehicleCount > 0) strcat(vehicleString, ";");
                format(vehicleString, sizeof(vehicleString), "%s%d,%f,%f,%f,%f",
                    vehicleString,
                    OwnedVehicle[playerid][i][ovModel],
                    OwnedVehicle[playerid][i][ovParkX],
                    OwnedVehicle[playerid][i][ovParkY],
                    OwnedVehicle[playerid][i][ovParkZ],
                    OwnedVehicle[playerid][i][ovParkAngle]
                );
                vehicleCount++;
            }
        }

        format(string, sizeof(string), "OwnedVehicles=%s\n", vehicleString);
        fwrite(fhandle, string);
        format(string, sizeof(string), "VehicleCount=%d\n", vehicleCount);
        fwrite(fhandle, string);

        fclose(fhandle);
    }
}

stock LoadUser(playerid, const file[])
{
    new File:fhandle = fopen(file, io_read);
    if(fhandle)
    {
        new string[512];
        while(fread(fhandle, string))
        {
            new key[32], value[480];
            sscanf(string, "p<=>s[32]s[480]", key, value);

            if(!strcmp(key, "Password"))
            {
                StripNewLine(value);
                format(Player[playerid][pPassword], 65, value);
            }
            else if(!strcmp(key, "Gender")) Player[playerid][pGender] = strval(value);
            else if(!strcmp(key, "Age")) Player[playerid][pAge] = strval(value);
            else if(!strcmp(key, "Nationality")) Player[playerid][pNationality] = strval(value);
            else if(!strcmp(key, "HasPassport")) Player[playerid][pHasPassport] = bool:strval(value);
            else if(!strcmp(key, "Money")) Player[playerid][pMoney] = strval(value);
            else if(!strcmp(key, "Faction")) Player[playerid][pFaction] = strval(value);
            else if(!strcmp(key, "Rank")) Player[playerid][pRank] = strval(value);
            else if(!strcmp(key, "AdminLevel")) Player[playerid][pAdminLevel] = strval(value);
            else if(!strcmp(key, "WantedLevel")) Player[playerid][pWantedLevel] = strval(value);
            else if(!strcmp(key, "WantedReason"))
            {
                StripNewLine(value);
                format(Player[playerid][pWantedReason], 64, value);
            }
            else if(!strcmp(key, "BankMoney")) Player[playerid][pBankMoney] = strval(value);
            else if(!strcmp(key, "BankAccount")) Player[playerid][pBankAccount] = strval(value);
            else if(!strcmp(key, "LastPayday")) Player[playerid][pLastPayday] = strval(value);
            else if(!strcmp(key, "PaycheckAmount")) Player[playerid][pPaycheckAmount] = strval(value);
            else if(!strcmp(key, "CanDoStashMission")) Player[playerid][pCanDoStashMission] = bool:strval(value);
            else if(!strcmp(key, "StashMissionCooldown")) Player[playerid][pStashMissionCooldown] = strval(value);
            else if(!strcmp(key, "HasMilitaryID")) Player[playerid][pHasMilitaryID] = bool:strval(value);
			else if(!strcmp(key, "MilitaryIDIssuer")) format(Player[playerid][pMilitaryIDIssuer], MAX_PLAYER_NAME, value);
			else if(!strcmp(key, "MilitaryIDDate")) format(Player[playerid][pMilitaryIDDate], 32, value);
			else if(!strcmp(key, "TruckerLevel")) Player[playerid][pTruckerLevel] = strval(value);
			else if(!strcmp(key, "TruckerExp")) Player[playerid][pTruckerExp] = strval(value);
            else if(!strcmp(key, "OwnedBusiness"))
            {
                new bizID = strval(value);
                if(bizID >= 0 && bizID < MAX_BUSINESSES && Business[bizID][bExists])
                {
                    new name[MAX_PLAYER_NAME];
                    GetPlayerName(playerid, name, sizeof(name));
                    format(Business[bizID][bOwner], MAX_PLAYER_NAME, name);

                    new label[256];
                    format(label, sizeof(label), "%s\n��������: %s\n�������: $%d/���",
                        Business[bizID][bName],
                        Business[bizID][bOwner],
                        Business[bizID][bProfitPerHour]
                    );
                    Update3DTextLabelText(Business[bizID][bLabel], 0xFFFF00AA, label);
                }
            }
            else if(!strcmp(key, "OwnedHouse"))
            {
                new houseID = strval(value);
                if(houseID >= 0 && houseID < MAX_HOUSES && House[houseID][hExists])
                {
                    new name[MAX_PLAYER_NAME];
                    GetPlayerName(playerid, name, sizeof(name));
                    format(House[houseID][hOwner], MAX_PLAYER_NAME, name);
                    House[houseID][hOwned] = true;

                    new label[256];
                    format(label, sizeof(label), "���\n��������: %s\n%s",
                        House[houseID][hOwner],
                        House[houseID][hLocked] ? "������" : "������"
                    );
                    Update3DTextLabelText(House[houseID][hLabel], 0xFFFFFFAA, label);
                }
            }
            else if(!strcmp(key, "OwnedVehicles"))
            {
                // ������� ������������ ������ � ����������
                for(new i = 0; i < 5; i++)
                {
                    OwnedVehicle[playerid][i][ovExists] = false;
                    OwnedVehicle[playerid][i][ovVehicleID] = 0;
                }

                // ��������� ������ � ����������
                new idx = 0;
                new vehicleData[32];
                new pos = 0;

                // ��������� ������ � ������� � ����������
                while(pos < strlen(value) && idx < 5)
                {
                    pos = split(value, vehicleData, pos, ';');
                    if(strlen(vehicleData) > 0)
                    {
                        new model, Float:x, Float:y, Float:z, Float:angle;
                        if(sscanf(vehicleData, "p<,>dffff", model, x, y, z, angle) == 5)
                        {
                            OwnedVehicle[playerid][idx][ovExists] = true;
                            OwnedVehicle[playerid][idx][ovModel] = model;
                            format(OwnedVehicle[playerid][idx][ovOwner], MAX_PLAYER_NAME, ReturnPlayerName(playerid));
                            OwnedVehicle[playerid][idx][ovParkX] = x;
                            OwnedVehicle[playerid][idx][ovParkY] = y;
                            OwnedVehicle[playerid][idx][ovParkZ] = z;
                            OwnedVehicle[playerid][idx][ovParkAngle] = angle;
                            OwnedVehicle[playerid][idx][ovVehicleID] = 0;
                            idx++;
                        }
                    }
                }
            }
        }
        fclose(fhandle);
    }
}

// ��������������� ������� ��� ���������� ������
stock split(const string[], return_str[], start_pos, delimiter)
{
    new pos = start_pos;
    new len = strlen(string);
    new retpos = 0;

    while(pos < len && string[pos] != delimiter && retpos < sizeof(return_str)-1)
    {
        return_str[retpos] = string[pos];
        pos++;
        retpos++;
    }
    return_str[retpos] = 0;

    if(pos < len)
        return pos + 1;
    else
        return pos;
}

stock IsValidName(const name[])
{
    new len = strlen(name);
    new underscore = 0;
    for(new i = 0; i < len; i++)
    {
        if(name[i] == '_') underscore++;
        else if((name[i] < 'A' || name[i] > 'Z') && (name[i] < 'a' || name[i] > 'z')) return 0;
    }
    return (underscore == 1);
}

stock StripNewLine(string[])
{
    new len = strlen(string);
    if (string[len - 1] == '\n') string[len - 1] = 0;
    if (string[len - 2] == '\r') string[len - 2] = 0;
}

stock GetNationalityName(nationality)
{
    new nation[20];
    switch(nationality)
    {
        case 0: nation = "����������";
        case 1: nation = "���������";
        case 2: nation = "�������";
        case 3: nation = "������";
        case 4: nation = "������";
        default: nation = "����������";
    }
    return nation;
}

ShowRentalDialog(playerid)
{
    new string[256];
    format(string, sizeof(string), "������ �������\n������ ����\n������ �������\n������");
    new title[] = "������ ����������";
    new button1[] = "�����������";
    new button2[] = "������";
    ShowPlayerDialog(playerid, DIALOG_RENTAL, DIALOG_STYLE_LIST, title, string, button1, button2);
}

forward EndRental(playerid, vehicleid);
public EndRental(playerid, vehicleid)
{
    DestroyVehicle(vehicleid);
    RentedVehicle[playerid] = INVALID_VEHICLE_ID;
    SendClientMessage(playerid, -1, "���� ������ ������������� �������� �����.");
}

stock SetPlayerLSPDRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_LSPD_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gLSPDSkins[rank-1]);
    SavePlayerSkin(playerid); // ��������� ����� ����
    new string[128];
    format(string, sizeof(string), "��� ����� ����: %s", GetLSPDRankName(rank));
    SendClientMessage(playerid, -1, string);
    return 1;
}

stock SetPlayerSheriffRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_SHERIFF_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gSheriffSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � SHPD: %s", gSheriffRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:makeleader(playerid, params[])
{
    if(Player[playerid][pAdminLevel] < 4)
        return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ���������� ���� �������.");

    new targetid, factionid;
    if(sscanf(params, "ud", targetid, factionid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /makeleader [id ������] [id �������] (0 ��� ������)");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "����� �� ������.");

    if(factionid != 0 && factionid != FACTION_LSPD && factionid != FACTION_FBI &&
       factionid != FACTION_EMS && factionid != FACTION_SHERIFF && factionid != FACTION_GROVE &&
       factionid != FACTION_GOV && factionid != FACTION_ARMY && factionid != FACTION_BALLAS &&
       factionid != FACTION_VAGOS && factionid != FACTION_AZTEC && factionid != FACTION_SANN) // ��������� SANN
        return SendClientMessage(playerid, -1, "�������� ID �������.");

    new string[128], targetName[MAX_PLAYER_NAME], adminName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));
    GetPlayerName(playerid, adminName, sizeof(adminName));

    if(factionid == 0)
    {
        if(Player[targetid][pFaction] == 0)
        {
            format(string, sizeof(string), "%s �� ������� �� � ����� �������.", targetName);
            SendClientMessage(playerid, -1, string);
            return 1;
        }
        new oldFaction = Player[targetid][pFaction];
        Player[targetid][pFaction] = 0;
        Player[targetid][pRank] = 0;
        format(string, sizeof(string), "�� ����� %s � ����� ������ ������� %s.", targetName, GetFactionName(oldFaction));
        SendClientMessage(playerid, -1, string);
        format(string, sizeof(string), "������������� %s ���� ��� � ����� ������ ������� %s.", adminName, GetFactionName(oldFaction));
        SendClientMessage(targetid, -1, string);
    }
    else
    {
        Player[targetid][pFaction] = factionid;
        switch(factionid)
        {
            case FACTION_LSPD:
            {
                SetPlayerLSPDRank(targetid, MAX_LSPD_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), GetLSPDRankName(MAX_LSPD_RANK));
            }
            case FACTION_FBI:
            {
                SetPlayerFBIRank(targetid, MAX_FBI_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gFBIRanks[MAX_FBI_RANK - 1]);
            }
            case FACTION_EMS:
            {
                SetPlayerEMSRank(targetid, MAX_EMS_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gEMSRanks[MAX_EMS_RANK - 1]);
            }
            case FACTION_SHERIFF:
            {
                SetPlayerSheriffRank(targetid, MAX_SHERIFF_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gSheriffRanks[MAX_SHERIFF_RANK - 1]);
            }
            case FACTION_GOV:
            {
                SetPlayerGOVRank(targetid, MAX_GOV_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gGOVRanks[MAX_GOV_RANK - 1]);
            }
            case FACTION_GROVE:
            {
                SetPlayerGroveRank(targetid, MAX_GROVE_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gGroveRanks[MAX_GROVE_RANK - 1]);
            }
            case FACTION_ARMY:
            {
                SetPlayerARMYRank(targetid, MAX_ARMY_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gARMYRanks[MAX_ARMY_RANK - 1]);
            }
            case FACTION_BALLAS:
            {
                SetPlayerBallasRank(targetid, MAX_BALLAS_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gBallasRanks[MAX_BALLAS_RANK - 1]);
            }
            case FACTION_VAGOS:
            {
                SetPlayerVagosRank(targetid, MAX_VAGOS_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gVagosRanks[MAX_VAGOS_RANK - 1]);
            }
            case FACTION_AZTEC:
            {
                SetPlayerAztecRank(targetid, MAX_AZTEC_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gAztecRanks[MAX_AZTEC_RANK - 1]);
            }
            case FACTION_SANN: // ��������� SANN
            {
                SetPlayerSANNRank(targetid, MAX_SANN_RANK);
                format(string, sizeof(string), "�� ��������� %s ������� ������� %s (������: %s).",
                    targetName, GetFactionName(factionid), gSANNRanks[MAX_SANN_RANK - 1]);
            }
        }
        SendClientMessage(playerid, -1, string);

        format(string, sizeof(string), "������������� %s �������� ��� ������� ������� %s", adminName, GetFactionName(factionid));
        SendClientMessage(targetid, -1, string);
    }

    SaveUser(targetid);
    return 1;
}



stock GetLSPDRankName(rank)
{
    static rankName[32];
    if(rank < 1 || rank > MAX_LSPD_RANK)
    {
        format(rankName, sizeof(rankName), "Iaecaanoiia caaiea");
    }
    else
    {
        format(rankName, sizeof(rankName), "%s", gLSPDRanks[rank - 1]);
    }
    return rankName;
}

CMD:makeadmin(playerid, params[])
{
    if(Player[playerid][pAdminLevel] < ADMIN_HEADADMIN) return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ��������� ������� ���������������.");

    new targetid, level;
    if(sscanf(params, "ud", targetid, level)) return SendClientMessage(playerid, -1, "�������������: /makeadmin [ID ������] [������� ������� (0-4)]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");

    if(level < ADMIN_NONE || level > ADMIN_HEADADMIN) return SendClientMessage(playerid, -1, "�������� ������� ������� (0-4).");

    Player[targetid][pAdminLevel] = level;

    new string[128], targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� ��������� ������� ������� ������ %s �� %d.", targetName, level);
    SendClientMessage(playerid, -1, string);

    format(string, sizeof(string), "��� ������� ������� ������� �� %d.", level);
    SendClientMessage(targetid, -1, string);

    // ���������� ��������� � ������ ������
    SaveUser(targetid);

    return 1;
}

CMD:rac(playerid, params[])
{
    // ���������, ����� �� ����� ����� ��������������
    if(Player[playerid][pAdminLevel] < ADMIN_MODERATOR) // ��������� ������� ���������� ��� ����
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���� ��� ������������� ���� �������.");

    // ���������� ��� ������������ �������� �� �������
    new count = 0;
    for(new i = 1; i <= MAX_VEHICLES; i++)
    {
        if(IsValidVehicle(i))
        {
            // ��������� ������� ��������� ����������
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);

            // ��������� ���������
            SetVehicleToRespawn(i);

            // ��������������� ��������� ����������
            SetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);

            // ��������������� ���������� �������
            VehicleFuel[i] = MAX_FUEL;

            count++;
        }
    }

    // ���������� ��������� ��������������
    new string[128];
    format(string, sizeof(string), "�� ���������� %d ������������ �������.", count);
    SendClientMessage(playerid, COLOR_GREEN, string);

    // ���������� ��������� ���� ������� � �������� �����
    new adminName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    format(string, sizeof(string), "������������� %s ��������� ��� ������������ ��������.", adminName);
    SendClientMessageToAll(COLOR_YELLOW, string);

    return 1;
}

CMD:a(playerid, params[])
{
    if(Player[playerid][pAdminLevel] < ADMIN_HELPER) return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ������������� ���� �������.");

    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /a [���������]");

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));

    new color;
    switch(Player[playerid][pAdminLevel])
    {
        case ADMIN_HELPER: color = 0xFFFF00AA;  // ��������
        case ADMIN_MODERATOR: color = 0x00FF00AA;  // ���������
        case ADMIN_ADMIN, ADMIN_HEADADMIN: color = 0xFF0000AA;  // �������������
    }

    format(message, sizeof(message), "[A] %s: %s", sender, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdminLevel] >= ADMIN_HELPER)
        {
            SendClientMessage(i, color, message);
        }
    }

    return 1;
}

CMD:ao(playerid, params[])
{
    if(Player[playerid][pAdminLevel] < ADMIN_MODERATOR) return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ������������� ���� �������.");

    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /ao [���������]");

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));

    format(message, sizeof(message), "[����� OOC] %s: %s", sender, params);

    SendClientMessageToAll(0xFF9900AA, message);  // ��������� ��� ����

    return 1;
}

CMD:invite(playerid, params[])
{
    if((Player[playerid][pFaction] == FACTION_GROVE && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_BALLAS && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_VAGOS && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_AZTEC && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_SANN && Player[playerid][pRank] < 12) || // ��������� SANN
       ((Player[playerid][pFaction] == FACTION_LSPD || Player[playerid][pFaction] == FACTION_FBI ||
         Player[playerid][pFaction] == FACTION_EMS || Player[playerid][pFaction] == FACTION_GOV ||
         Player[playerid][pFaction] == FACTION_ARMY) &&
         Player[playerid][pRank] < 7) ||
       Player[playerid][pFaction] == 0)
        return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ����������� �������.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "�������������: /invite [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "����� �� ������.");

    if(Player[targetid][pFaction] != 0)
        return SendClientMessage(playerid, -1, "���� ����� ��� ������� �� �������.");

    if((Player[playerid][pFaction] == FACTION_LSPD ||
        Player[playerid][pFaction] == FACTION_FBI ||
        Player[playerid][pFaction] == FACTION_SHERIFF) &&
        !Player[targetid][pHasMilitaryID])
    {
        return SendClientMessage(playerid, COLOR_RED, "� ������ ����������� ������� �����!");
    }

    Player[targetid][pFaction] = Player[playerid][pFaction];
    Player[targetid][pRank] = 1;

    new string[128], inviterName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, inviterName, sizeof(inviterName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� ���������� %s � %s.", targetName, GetFactionName(Player[playerid][pFaction]));
    SendClientMessage(playerid, -1, string);

    format(string, sizeof(string), "%s ��������� ��� � %s.", inviterName, GetFactionName(Player[playerid][pFaction]));
    SendClientMessage(targetid, -1, string);

    switch(Player[playerid][pFaction])
    {
        case FACTION_GROVE: SetPlayerGroveRank(targetid, 1);
        case FACTION_BALLAS: SetPlayerBallasRank(targetid, 1);
        case FACTION_VAGOS: SetPlayerVagosRank(targetid, 1);
        case FACTION_AZTEC: SetPlayerAztecRank(targetid, 1);
        case FACTION_GOV: SetPlayerGOVRank(targetid, 1);
        case FACTION_ARMY: SetPlayerARMYRank(targetid, 1);
        case FACTION_LSPD: SetPlayerLSPDRank(targetid, 1);
        case FACTION_FBI: SetPlayerFBIRank(targetid, 1);
        case FACTION_SHERIFF: SetPlayerSheriffRank(targetid, 1);
        case FACTION_EMS: SetPlayerEMSRank(targetid, 1);
        case FACTION_SANN: SetPlayerSANNRank(targetid, 1); // ��������� SANN
    }

    SaveUser(targetid);
    return 1;
}

// ������� ���������� �� �������
CMD:uninvite(playerid, params[])
{
    if((Player[playerid][pFaction] == FACTION_GROVE && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_BALLAS && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_VAGOS && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_AZTEC && Player[playerid][pRank] < 5) ||
       (Player[playerid][pFaction] == FACTION_SANN && Player[playerid][pRank] < 12) || // ��������� SANN
       ((Player[playerid][pFaction] == FACTION_LSPD || Player[playerid][pFaction] == FACTION_FBI ||
         Player[playerid][pFaction] == FACTION_EMS || Player[playerid][pFaction] == FACTION_GOV ||
         Player[playerid][pFaction] == FACTION_ARMY) &&
         Player[playerid][pRank] < 7) ||
       Player[playerid][pFaction] == 0)
        return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ���������� �������.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, -1, "�������������: /uninvite [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "����� �� ������.");

    if(Player[targetid][pFaction] != Player[playerid][pFaction])
        return SendClientMessage(playerid, -1, "���� ����� �� ������� � ����� �������.");

    new oldFaction = Player[targetid][pFaction];
    Player[targetid][pFaction] = 0;
    Player[targetid][pRank] = 0;

    new string[128], uninviterName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, uninviterName, sizeof(uninviterName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� ��������� %s �� %s.", targetName, GetFactionName(oldFaction));
    SendClientMessage(playerid, -1, string);

    format(string, sizeof(string), "%s �������� ��� �� %s.", uninviterName, GetFactionName(oldFaction));
    SendClientMessage(targetid, -1, string);

    SetPlayerSkin(targetid, (Player[targetid][pGender] == 0) ? 1 : 12);
    SavePlayerSkin(targetid);

    SaveUser(targetid);
    return 1;
}

// ����������� �������
#define FACTION_FIB 2
#define FACTION_ARMY 3
#define FACTION_SHERIFF 4
#define FACTION_GOV 5
#define FACTION_EMS 6


// ��������, �������� �� ����� ������ ��������������� �������
stock IsPlayerInGovFaction(playerid)
{
    new faction = Player[playerid][pFaction];
    return (faction == FACTION_LSPD || faction == FACTION_FBI ||
            faction == FACTION_ARMY || faction == FACTION_SHERIFF ||
            faction == FACTION_GOV || faction == FACTION_EMS ||
            faction == FACTION_SANN); // ��������� SANN � ���.������������
}


// ��������� �������� �������
stock GetFactionName(factionid)
{
    new factionName[32];
    switch(factionid)
    {
        case FACTION_LSPD: factionName = "LSPD";
        case FACTION_FBI: factionName = "FBI";
        case FACTION_ARMY: factionName = "ARMY";
        case FACTION_SHERIFF: factionName = "Sheriff";
        case FACTION_GOV: factionName = "GOV";
        case FACTION_EMS: factionName = "EMS";
        case FACTION_GROVE: factionName = "Grove Street Gang";
        case FACTION_BALLAS: factionName = "Ballas";
        case FACTION_VAGOS: factionName = "Vagos";
        case FACTION_AZTEC: factionName = "Aztec";
        case FACTION_SANN: factionName = "SANN"; // ��������� SANN
        default: factionName = "Unknown";
    }
    return factionName;
}

// ������� ���������� ����� ������
CMD:giverank(playerid, params[])
{
    if((Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI &&
        Player[playerid][pFaction] != FACTION_EMS && Player[playerid][pFaction] != FACTION_SHERIFF &&
        Player[playerid][pFaction] != FACTION_GROVE && Player[playerid][pFaction] != FACTION_GOV &&
        Player[playerid][pFaction] != FACTION_ARMY && Player[playerid][pFaction] != FACTION_BALLAS &&
        Player[playerid][pFaction] != FACTION_VAGOS && Player[playerid][pFaction] != FACTION_AZTEC &&
        Player[playerid][pFaction] != FACTION_SANN) || // ��������� SANN
        ((Player[playerid][pFaction] != FACTION_GROVE && Player[playerid][pFaction] != FACTION_BALLAS &&
          Player[playerid][pFaction] != FACTION_VAGOS && Player[playerid][pFaction] != FACTION_AZTEC &&
          Player[playerid][pFaction] != FACTION_SANN && // ��������� SANN
          Player[playerid][pRank] < 10) ||
         (Player[playerid][pFaction] == FACTION_GROVE && Player[playerid][pRank] < 6) ||
         (Player[playerid][pFaction] == FACTION_BALLAS && Player[playerid][pRank] < 6) ||
         (Player[playerid][pFaction] == FACTION_VAGOS && Player[playerid][pRank] < 6) ||
         (Player[playerid][pFaction] == FACTION_AZTEC && Player[playerid][pRank] < 6) ||
         (Player[playerid][pFaction] == FACTION_SANN && Player[playerid][pRank] < 12) || // ��������� SANN
         (Player[playerid][pFaction] == FACTION_GOV && Player[playerid][pRank] < 13) ||
         (Player[playerid][pFaction] == FACTION_ARMY && Player[playerid][pRank] < 10)))
        return SendClientMessage(playerid, -1, "� ��� ��� ���� �� ��������� ������.");

    new targetid, rank;
    if(sscanf(params, "ud", targetid, rank))
        return SendClientMessage(playerid, -1, "�������������: /giverank [ID ������] [����]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, -1, "����� �� ������.");

    if(Player[targetid][pFaction] != Player[playerid][pFaction])
        return SendClientMessage(playerid, -1, "���� �� ������� � ����� �������.");

    new maxRank;
    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD: maxRank = MAX_LSPD_RANK;
        case FACTION_FBI: maxRank = MAX_FBI_RANK;
        case FACTION_EMS: maxRank = MAX_EMS_RANK;
        case FACTION_SHERIFF: maxRank = MAX_SHERIFF_RANK;
        case FACTION_GROVE: maxRank = MAX_GROVE_RANK;
        case FACTION_GOV: maxRank = MAX_GOV_RANK;
        case FACTION_ARMY: maxRank = MAX_ARMY_RANK;
        case FACTION_BALLAS: maxRank = MAX_BALLAS_RANK;
        case FACTION_VAGOS: maxRank = MAX_VAGOS_RANK;
        case FACTION_AZTEC: maxRank = MAX_AZTEC_RANK;
        case FACTION_SANN: maxRank = MAX_SANN_RANK; // ��������� SANN
        default: return SendClientMessage(playerid, -1, "������: ����������� �������.");
    }

    if(rank < 1 || rank > maxRank)
        return SendClientMessage(playerid, -1, "�������� ����.");

    new string[128], giverName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, giverName, sizeof(giverName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    new rankName[32];
    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD:
        {
            SetPlayerLSPDRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", GetLSPDRankName(rank));
        }
        case FACTION_FBI:
        {
            SetPlayerFBIRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gFBIRanks[rank - 1]);
        }
        case FACTION_EMS:
        {
            SetPlayerEMSRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gEMSRanks[rank - 1]);
        }
        case FACTION_SHERIFF:
        {
            SetPlayerSheriffRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gSheriffRanks[rank - 1]);
        }
        case FACTION_GROVE:
        {
            SetPlayerGroveRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gGroveRanks[rank - 1]);
        }
        case FACTION_BALLAS:
        {
            SetPlayerBallasRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gBallasRanks[rank - 1]);
        }
        case FACTION_GOV:
        {
            SetPlayerGOVRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gGOVRanks[rank - 1]);
        }
        case FACTION_ARMY:
        {
            SetPlayerARMYRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gARMYRanks[rank - 1]);
        }
        case FACTION_VAGOS:
        {
            SetPlayerVagosRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gVagosRanks[rank - 1]);
        }
        case FACTION_AZTEC:
        {
            SetPlayerAztecRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gAztecRanks[rank - 1]);
        }
        case FACTION_SANN: // ��������� SANN
        {
            SetPlayerSANNRank(targetid, rank);
            format(rankName, sizeof(rankName), "%s", gSANNRanks[rank - 1]);
        }
    }

    format(string, sizeof(string), "�� ��������� ���� %s ������ %s.", rankName, targetName);
    SendClientMessage(playerid, -1, string);

    format(string, sizeof(string), "%s �������� ��� ���� %s.", giverName, rankName);
    SendClientMessage(targetid, -1, string);

    SaveUser(targetid);
    return 1;
}

// ������� �������� ��������� � ���������� �������
// ����������� ������� /f
CMD:f(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI &&
       Player[playerid][pFaction] != FACTION_EMS && Player[playerid][pFaction] != FACTION_SHERIFF &&
       Player[playerid][pFaction] != FACTION_GROVE && Player[playerid][pFaction] != FACTION_GOV &&
       Player[playerid][pFaction] != FACTION_ARMY && Player[playerid][pFaction] != FACTION_BALLAS &&
       Player[playerid][pFaction] != FACTION_VAGOS && Player[playerid][pFaction] != FACTION_AZTEC &&
       Player[playerid][pFaction] != FACTION_SANN) // ��������� SANN
        return SendClientMessage(playerid, -1, "�� �� �������� � �������.");

    if(isnull(params))
        return SendClientMessage(playerid, -1, "�������������: /f [���������]");

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));
    new rankName[32];

    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD:
            format(rankName, sizeof(rankName), "%s", GetLSPDRankName(Player[playerid][pRank]));
        case FACTION_FBI:
            format(rankName, sizeof(rankName), "%s", gFBIRanks[Player[playerid][pRank] - 1]);
        case FACTION_EMS:
            format(rankName, sizeof(rankName), "%s", gEMSRanks[Player[playerid][pRank] - 1]);
        case FACTION_SHERIFF:
            format(rankName, sizeof(rankName), "%s", gSheriffRanks[Player[playerid][pRank] - 1]);
        case FACTION_GROVE:
            format(rankName, sizeof(rankName), "%s", gGroveRanks[Player[playerid][pRank] - 1]);
        case FACTION_GOV:
            format(rankName, sizeof(rankName), "%s", gGOVRanks[Player[playerid][pRank] - 1]);
        case FACTION_ARMY:
            format(rankName, sizeof(rankName), "%s", gARMYRanks[Player[playerid][pRank] - 1]);
        case FACTION_BALLAS:
            format(rankName, sizeof(rankName), "%s", gBallasRanks[Player[playerid][pRank] - 1]);
        case FACTION_VAGOS:
            format(rankName, sizeof(rankName), "%s", gVagosRanks[Player[playerid][pRank] - 1]);
        case FACTION_AZTEC:
            format(rankName, sizeof(rankName), "%s", gAztecRanks[Player[playerid][pRank] - 1]);
        case FACTION_SANN: // ��������� SANN
            format(rankName, sizeof(rankName), "%s", gSANNRanks[Player[playerid][pRank] - 1]);
    }

    format(message, sizeof(message), "[%s] %s %s: %s", GetFactionName(Player[playerid][pFaction]), rankName, sender, params);

    new color = (Player[playerid][pFaction] == FACTION_GROVE) ? 0x33AA33AA : // ������� ��� Grove
                (Player[playerid][pFaction] == FACTION_BALLAS) ? 0x800080AA : // ���������� ��� Ballas
                (Player[playerid][pFaction] == FACTION_VAGOS) ? 0xFFFF00AA : // ������ ��� Vagos
                (Player[playerid][pFaction] == FACTION_AZTEC) ? 0x00BFFFFF : // ������� ��� Aztec
                (Player[playerid][pFaction] == FACTION_SANN) ? 0xFF8C00AA : // ��������� ��� SANN
                0x3333FFAA; // ����� ��� ���������

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pFaction] == Player[playerid][pFaction])
        {
            SendClientMessage(i, color, message);
        }
    }
    return 1;
}

CMD:fo(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI &&
       Player[playerid][pFaction] != FACTION_EMS && Player[playerid][pFaction] != FACTION_SHERIFF &&
       Player[playerid][pFaction] != FACTION_GROVE && Player[playerid][pFaction] != FACTION_GOV &&
       Player[playerid][pFaction] != FACTION_ARMY && Player[playerid][pFaction] != FACTION_BALLAS &&
       Player[playerid][pFaction] != FACTION_VAGOS && Player[playerid][pFaction] != FACTION_AZTEC &&
       Player[playerid][pFaction] != FACTION_SANN) // ��������� SANN
        return SendClientMessage(playerid, -1, "�� �� �������� � �������.");

    if(isnull(params))
        return SendClientMessage(playerid, -1, "�������������: /fo [���������]");

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));
    format(message, sizeof(message), "[%s OOC] %s: %s", GetFactionName(Player[playerid][pFaction]), sender, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pFaction] == Player[playerid][pFaction])
        {
            SendClientMessage(i, 0xAAAAAAAA, message);
        }
    }
    return 1;
}



// ������� ������� ������ � ������
CMD:incar(playerid, params[])
{
	if(Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI &&
	   Player[playerid][pFaction] != FACTION_SHERIFF && Player[playerid][pFaction] != FACTION_GOV &&
	   Player[playerid][pFaction] != FACTION_ARMY)
        return SendClientMessage(playerid, -1, "�� �� ��������� ����������� ������������������ �������.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "�������������: /incar [ID ������]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new vehicleid = GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, -1, "��� ���������� ����������.");

    PutPlayerInVehicle(targetid, vehicleid, 1);

    new string[128], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� �������� %s � ������������ ��������.", targetName);
    SendClientMessage(playerid, -1, string);

    format(string, sizeof(string), "%s ������� ��� � ������������ ��������.", officerName);
    SendClientMessage(targetid, -1, string);

    return 1;
}

// ������� �������� ��������� �� ������������
CMD:d(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid))
        return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    if(isnull(params))
        return SendClientMessage(playerid, -1, "�������������: /d [���������]");

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));

    new rankName[32];
    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD:
            format(rankName, sizeof(rankName), "%s", GetLSPDRankName(Player[playerid][pRank]));
        case FACTION_FBI:
            format(rankName, sizeof(rankName), "%s", gFBIRanks[Player[playerid][pRank] - 1]);
        case FACTION_EMS:
            format(rankName, sizeof(rankName), "%s", gEMSRanks[Player[playerid][pRank] - 1]);
        case FACTION_SHERIFF:
            format(rankName, sizeof(rankName), "%s", gSheriffRanks[Player[playerid][pRank] - 1]);
        case FACTION_GOV:
            format(rankName, sizeof(rankName), "%s", gGOVRanks[Player[playerid][pRank] - 1]);
        case FACTION_ARMY:
            format(rankName, sizeof(rankName), "%s", gARMYRanks[Player[playerid][pRank] - 1]);
        case FACTION_SANN: // ��������� SANN
            format(rankName, sizeof(rankName), "%s", gSANNRanks[Player[playerid][pRank] - 1]);
        default:
            format(rankName, sizeof(rankName), "���������");
    }

    format(message, sizeof(message), "[D] %s %s %s: %s", GetFactionName(Player[playerid][pFaction]), rankName, sender, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInGovFaction(i))
        {
            SendClientMessage(i, 0x33AA33AA, message);
        }
    }
    return 1;
}

// ������� ���� ������� � �������� �� �����
CMD:code(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid)) return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /code [���������]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new message[128], sender[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sender, sizeof(sender));

    new rankName[32];
    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD:
            format(rankName, sizeof(rankName), "%s", GetLSPDRankName(Player[playerid][pRank]));
        case FACTION_FBI:
            format(rankName, sizeof(rankName), "%s", gFBIRanks[Player[playerid][pRank] - 1]);
        case FACTION_SHERIFF:
            format(rankName, sizeof(rankName), "%s", gSheriffRanks[Player[playerid][pRank] - 1]);
        case FACTION_ARMY:
    		format(rankName, sizeof(rankName), "%s", gARMYRanks[Player[playerid][pRank] - 1]);
        default:
            format(rankName, sizeof(rankName), "���������");
    }

    format(message, sizeof(message), "[CODE] %s %s %s: %s", GetFactionName(Player[playerid][pFaction]), rankName, sender, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInGovFaction(i))
        {
            SendClientMessage(i, 0xFF0000AA, message);
            SetPlayerMarkerForPlayer(i, playerid, 0xFF0000AA);
        }
    }

    // �������� ������� ����� 1 ������
    new timerName[32];
    format(timerName, sizeof(timerName), "RemovePlayerMarker");
    SetTimerEx(timerName, 60000, false, "i", playerid);

    return 1;
}

// �������� ������� ������
forward RemovePlayerMarker(playerid);
public RemovePlayerMarker(playerid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInGovFaction(i))
        {
            SetPlayerMarkerForPlayer(i, playerid, GetPlayerColor(playerid));
        }
    }
}

// ������� ����������
CMD:cuff(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid)) return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "�������������: /cuff [ID ������]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");

    if(targetid == playerid) return SendClientMessage(playerid, -1, "�� �� ������ ������ ��������� �� ������ ����!");

    if(IsPlayerInGovFaction(targetid)) return SendClientMessage(playerid, -1, "�� �� ������ ������ ��������� �� ���������� ��������������� �������!");

    if(PlayerCuffed[targetid]) return SendClientMessage(playerid, -1, "����� ��� � ����������!");

    if(!IsPlayerNearPlayer(playerid, targetid, 3.0)) return SendClientMessage(playerid, -1, "�� ���������� ������� ������ �� ������.");

    new string[128], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    new factionName[20];
    format(factionName, sizeof(factionName), "%s", GetFactionName(Player[playerid][pFaction]));

    // �������� ���������
    SetPlayerAttachedObject(targetid, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
    SetPlayerSpecialAction(targetid, SPECIAL_ACTION_CUFFED);
    TogglePlayerControllable(targetid, 0);
    PlayerCuffed[targetid] = true;
    PlayerCuffedTime[targetid] = 3600;

    format(string, sizeof(string), "%s %s ����� ��������� �� %s, ������������ �� ����.", factionName, officerName, targetName);
    SendNearbyMessage(playerid, 20.0, 0xC2A2DAAA, string);

    format(string, sizeof(string), "%s %s ����� �� ��� ���������.", factionName, officerName);
    SendClientMessage(targetid, -1, string);

    return 1;
}

// ������� ������ ����������
CMD:uncuff(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid)) return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "�������������: /uncuff [ID ������]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");

    if(!PlayerCuffed[targetid]) return SendClientMessage(playerid, -1, "����� �� � ����������!");

    if(!IsPlayerNearPlayer(playerid, targetid, 3.0)) return SendClientMessage(playerid, -1, "�� ���������� ������� ������ �� ������.");

    new string[128], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    new factionName[20];
    format(factionName, sizeof(factionName), "%s", GetFactionName(Player[playerid][pFaction]));

    // ������� ���������
    RemovePlayerAttachedObject(targetid, 0);
    SetPlayerSpecialAction(targetid, SPECIAL_ACTION_NONE);
    TogglePlayerControllable(targetid, 1);
    PlayerCuffed[targetid] = false;
    PlayerCuffedTime[targetid] = 0;

    format(string, sizeof(string), "%s %s ���� ��������� � %s, ��������� �� ����.", factionName, officerName, targetName);
    SendNearbyMessage(playerid, 20.0, 0xC2A2DAAA, string);

    format(string, sizeof(string), "%s %s ���� � ��� ���������.", factionName, officerName);
    SendClientMessage(targetid, -1, string);

    return 1;
}

// ������� /wanted
CMD:wanted(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid)) return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    new targetid, stars, reason[64];
    if(sscanf(params, "uds[64]", targetid, stars, reason)) return SendClientMessage(playerid, -1, "�������������: /wanted [ID ������] [���������� ����] [�������]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");

    if(stars < 0 || stars > 6) return SendClientMessage(playerid, -1, "���������� ���� ������ ���� �� 0 �� 6.");

    SetPlayerWantedLevel(targetid, stars);
    format(Player[targetid][pWantedReason], 64, "%s", reason);

    new string[128], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    new factionName[20];
    format(factionName, sizeof(factionName), "%s", GetFactionName(Player[playerid][pFaction]));

    if(stars > 0)
    {
        format(string, sizeof(string), "%s: �� ��������� ������ ������ %s, ���������� ����: %d. �������: %s", factionName, targetName, stars, reason);
        SendClientMessage(playerid, -1, string);

        format(string, sizeof(string), "%s ������� ��� � ������. ���������� ����: %d. �������: %s", factionName, stars, reason);
        SendClientMessage(targetid, -1, string);
    }
    else
    {
        format(string, sizeof(string), "%s: �� ����� ������ � ������ %s.", factionName, targetName);
        SendClientMessage(playerid, -1, string);

        format(string, sizeof(string), "%s %s ���� � ��� ������.", factionName, officerName);
        SendClientMessage(targetid, -1, string);
    }

    return 1;
}

// ������� /wl ��� ������ ��������
CMD:wl(playerid, params[])
{
    if(!IsPlayerInGovFaction(playerid)) return SendClientMessage(playerid, -1, "�� �� �������� � ��������������� �������.");

    new string[128], count = 0;
    SendClientMessage(playerid, -1, "������ ������������� �������:");

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerWantedLevel(i) > 0)
        {
            new playerName[MAX_PLAYER_NAME], reason[64];
            GetPlayerName(i, playerName, sizeof(playerName));
            format(reason, sizeof(reason), "%s", Player[i][pWantedReason]);
            format(string, sizeof(string), "%s (ID: %d) - %d ���� - �������: %s", playerName, i, GetPlayerWantedLevel(i), reason);
            SendClientMessage(playerid, -1, string);
            count++;
        }
    }

    if(count == 0)
    {
        SendClientMessage(playerid, -1, "��� ������������� �������.");
    }

    return 1;
}

// ��������������� �������

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    return IsPlayerInRangeOfPoint(playerid, radius, x, y, z);
}

stock SendNearbyMessage(playerid, Float:radius, color, const message[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, radius, x, y, z))
        {
            SendClientMessage(i, color, message);
        }
    }
}

// ������� ��� ��������� ���������� ������������� ��������
stock GetClosestVehicle(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new Float:dist = 9999.0, Float:tmpdist, vehicleid = INVALID_VEHICLE_ID;

    for(new i = 1; i <= MAX_VEHICLES; i++)
    {
        if(!IsVehicleStreamedIn(i, playerid)) continue;
        GetVehiclePos(i, x, y, z);
        tmpdist = GetPlayerDistanceFromPoint(playerid, x, y, z);
        if(tmpdist < dist && tmpdist < 5.0)
        {
            dist = tmpdist;
            vehicleid = i;
        }
    }

    return vehicleid;
}


// ��������� ������� ������� ������
stock GetPlayerWantedReason(playerid, reason[], size = sizeof(reason))
{
    format(reason, size, Player[playerid][pWantedReason]);
}

// ������� ��� �������� ��������������

CMD:me(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /me [��������]");

    new message[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    format(message, sizeof(message), "* %s %s", playerName, params);
    SendNearbyMessage(playerid, 20.0, 0xC2A2DAAA, message);
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /do [��������]");

    new message[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    format(message, sizeof(message), "* %s (( %s ))", params, playerName);
    SendNearbyMessage(playerid, 20.0, 0xC2A2DAAA, message);
    return 1;
}

CMD:try(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /try [��������]");

    new message[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));

    if(random(2) == 0) // 50% ������
    {
        format(message, sizeof(message), "* %s ��������� %s - �����", playerName, params);
    }
    else
    {
        format(message, sizeof(message), "* %s ��������� %s - �������", playerName, params);
    }

    SendNearbyMessage(playerid, 20.0, 0xC2A2DAAA, message);
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /b [���������]");

    new message[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    format(message, sizeof(message), "(( %s: %s ))", playerName, params);
    SendNearbyMessage(playerid, 20.0, 0xE6E6E6AA, message);
    return 1;
}

CMD:s(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /s [���������]");

    new message[128], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    format(message, sizeof(message), "%s ������: %s!", playerName, params);
    SendNearbyMessage(playerid, 30.0, -1, message);
    return 1;
}

CMD:w(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "�������������: /w [id ������] [���������]");

    new targetid, text[128];
    if(sscanf(params, "us[128]", targetid, text)) return SendClientMessage(playerid, -1, "�������������: /w [id ������] [���������]");

    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "����� �� ������.");
    if(!IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendClientMessage(playerid, -1, "�� ������� ������ �� ������.");

    new message[128], playerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(message, sizeof(message), "%s ������: %s", playerName, text);
    SendClientMessage(targetid, 0xFFFF00AA, message);

    format(message, sizeof(message), "�� ���������� %s: %s", targetName, text);
    SendClientMessage(playerid, 0xFFFF00AA, message);

    // ���������� ���������� ��������� � ������
    format(message, sizeof(message), "* %s ������ ���-�� %s", playerName, targetName);
    SendNearbyMessageExcept(playerid, targetid, 10.0, 0xC2A2DAAA, message);

    return 1;
}

// �������� ��������� ����������, ����� ������ ������
stock SendNearbyMessageExcept(playerid, exceptid, Float:radius, color, const message[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && i != playerid && i != exceptid && IsPlayerInRangeOfPoint(i, radius, x, y, z))
        {
            SendClientMessage(i, color, message);
        }
    }
}

// ����������� ������
#define COLOR_RED 0xFF0000AA
#define COLOR_BLUE 0x0000FFAA
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA

// ���������� ��� �������� ������ � ������
new ArrestTime[MAX_PLAYERS];
new ArrestBail[MAX_PLAYERS];
new ArrestReason[MAX_PLAYERS][128];


// ������� /arrest
CMD:arrest(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI && Player[playerid][pFaction] != FACTION_SHERIFF)
        return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � LSPD, FBI ��� Sheriff.");

    new targetid, time, bail, reason[128];
    if(sscanf(params, "udds[128]", targetid, time, bail, reason))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /arrest [id ������] [����� (������)] [�����] [�������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    // �������� ������� ������ � ����������� �� �������
    if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, 267.79999, 83.1, 984.20001) ||
           GetPlayerInterior(playerid) != 6 ||
           GetPlayerVirtualWorld(playerid) != VIRTUAL_WORLD_SHERIFF)
        {
            return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� � ���� ������ Sheriff Department.");
        }
    }
    else if(Player[playerid][pFaction] == FACTION_LSPD)
    {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, 266.70001, 77.4, 1001.0) || GetPlayerInterior(playerid) != 6)
            return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� � ����������� �������.");
    }

    if(GetPlayerWantedLevel(targetid) == 0)
        return SendClientMessage(playerid, COLOR_RED, "����� �� ��������� � �������.");

    if(time < 1 || time > 60)
        return SendClientMessage(playerid, COLOR_RED, "����� ������ ������ ���� �� 1 �� 60 �����.");

    if(bail < 0)
        return SendClientMessage(playerid, COLOR_RED, "����� ������ �� ����� ���� �������������.");

    // ���������� ���������� ��� ���������� � ����������� �� �������
    new Float:arrest_x, Float:arrest_y, Float:arrest_z;
    if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        arrest_x = 265.10001;
        arrest_y = 83.0;
        arrest_z = 984.20001;
    }
    else
    {
        arrest_x = 264.10001;
        arrest_y = 77.5;
        arrest_z = 1001.0;
    }

    // ����� ������
    ArrestTime[targetid] = time * 60;
    ArrestBail[targetid] = bail;
    format(ArrestReason[targetid], sizeof(ArrestReason[]), reason);

    PlayerPreviousSkin[targetid] = GetPlayerSkin(targetid);
    SetPlayerSkin(targetid, 268);
    SetPlayerPos(targetid, arrest_x, arrest_y, arrest_z);

    if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        SetPlayerFacingAngle(targetid, -89.997);
        SetPlayerInterior(targetid, 6);
        SetPlayerVirtualWorld(targetid, VIRTUAL_WORLD_SHERIFF);
    }
    else
    {
        SetPlayerFacingAngle(targetid, 270.0);
        SetPlayerInterior(targetid, 6);
        SetPlayerVirtualWorld(targetid, 0);
    }

    SetPlayerWantedLevel(targetid, 0);

    new timerName[32];
    format(timerName, sizeof(timerName), "ArrestTimer");
    new timerID = SetTimerEx(timerName, 1000, true, "i", targetid);
    new varName[32];
    format(varName, sizeof(varName), "ArrestTimerID");
    SetPVarInt(targetid, varName, timerID);

    // �����������
    new string[256], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    new factionName[20];
    format(factionName, sizeof(factionName), "%s", GetFactionName(Player[playerid][pFaction]));

    format(string, sizeof(string), "�� ���������� ������ %s �� �������: %s, �� ����: %d �����.", targetName, reason, time);
    SendClientMessage(playerid, COLOR_BLUE, string);

    if(bail > 0) {
        format(string, sizeof(string), "%s %s ��������� ��� �� �������: %s, �� ����: %d �����, �����: $%d.",
            factionName, officerName, reason, time, bail);
    } else {
        format(string, sizeof(string), "%s %s ��������� ��� �� �������: %s, �� ����: %d �����, ��� ������.",
            factionName, officerName, reason, time);
    }
    SendClientMessage(targetid, COLOR_RED, string);

    return 1;
}


// ������� ������ ������
ArrestPlayer(playerid, time, bail, const reason[])
{
    ArrestTime[playerid] = time * 60; // ������� ������� ������ � �������
    ArrestBail[playerid] = bail;
    format(ArrestReason[playerid], sizeof(ArrestReason[]), reason);

    // ���������� ����������� ����� ������
    PlayerPreviousSkin[playerid] = GetPlayerSkin(playerid);

    // ��������� ��������� ����� (268)
    SetPlayerSkin(playerid, 268);

    // ����������� ������ � ������
    SetPlayerPos(playerid, 264.10001, 77.5, 1001.0);
    SetPlayerFacingAngle(playerid, 270.0);
    SetPlayerInterior(playerid, 6);

    // ��������� ������ �������
    SetPlayerWantedLevel(playerid, 0);

    // �������� ������� ��� ������� ������� ������
	new timerName[32];
	format(timerName, sizeof(timerName), "ArrestTimer");
	new timerID = SetTimerEx(timerName, 1000, true, "i", playerid);
	new varName[32];
	format(varName, sizeof(varName), "ArrestTimerID");
	SetPVarInt(playerid, varName, timerID);

    // ��������� ������ �� ������
    new string[128];
    format(string, sizeof(string), "�� ���������� �� %d �����. �����: $%d", time, bail);
    SendClientMessage(playerid, COLOR_RED, string);
}

// ������ ������
forward ArrestTimer(playerid);
public ArrestTimer(playerid)
{
    if(ArrestTime[playerid] > 0)
    {
        ArrestTime[playerid]--;

        // ����������� ����������� ������� ������
        new string[64];
        format(string, sizeof(string), "~r~���������� �����: ~w~%d ���. %d ���.", ArrestTime[playerid] / 60, ArrestTime[playerid] % 60);
        GameTextForPlayer(playerid, string, 1000, 3);
    }
    else
    {
        // ������������ ������
        ReleasePlayer(playerid);
    }
}

// ������������ ������ �� ������
ReleasePlayer(playerid)
{
    if(ArrestTime[playerid] == 0 && ArrestBail[playerid] == 0)
        return;

    ArrestTime[playerid] = 0;
    ArrestBail[playerid] = 0;
    ArrestReason[playerid][0] = 0;

    SetPlayerSkin(playerid, PlayerPreviousSkin[playerid]);

    // � ����������� �� ������������ ���� ����������, ��� ���������� ������
    if(GetPlayerVirtualWorld(playerid) == VIRTUAL_WORLD_SHERIFF)
    {
        SetPlayerPos(playerid, 247.654418, 73.784896, 986.762512);
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, VIRTUAL_WORLD_SHERIFF);
    }
    else
    {
        SetPlayerPos(playerid, 1552.6, -1675.5, 16.2);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
    }

    SendClientMessage(playerid, COLOR_GREEN, "�� ���� ����������� �� ������.");

    new varName[32];
    format(varName, sizeof(varName), "ArrestTimerID");
    KillTimer(GetPVarInt(playerid, varName));
    DeletePVar(playerid, varName);
}

// ������� ��� �������� ������
CMD:bail(playerid, params[])
{
    if(ArrestTime[playerid] == 0)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� ��� �������.");

    if(ArrestBail[playerid] == 0)
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������������.");

    if(GetPlayerMoney(playerid) < ArrestBail[playerid])
        return SendClientMessage(playerid, COLOR_RED, "� ��� ������������ ����� ��� �������� ������.");

    GivePlayerMoney(playerid, -ArrestBail[playerid]);

    new string[128];
    format(string, sizeof(string), "�� ������ ����� � ������� $%d � ���� �����������.", ArrestBail[playerid]);
    SendClientMessage(playerid, COLOR_GREEN, string);

    ReleasePlayer(playerid);

    return 1;
}

#define BYTES_PER_CELL 4

// ������� ��� �������������� ������ (������ ������������� asm)
stock fmt(const fmat[], {Float,_}:...)
{
    new
        arg_start,
        arg_end,
        result[256];

    // ��������� ������ � ����� ���������� ��� ��������������
    #emit ADDR.PRI fmat
    #emit STOR.S.PRI arg_start

    #emit LOAD.S.PRI 0
    #emit ADD.C 12
    #emit ADDR.ALT fmat
    #emit ADD
    #emit STOR.S.PRI arg_end

    // ������������� format ��� �������� ������
    format(result, sizeof(result), fmat, arg_start, arg_end);
    return result;
}

// ����� ���� �������� LSPD
ShowLSPDArmorMenu(playerid)
{
    if(Player[playerid][pFaction] != FACTION_LSPD)
    {
        SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� LSPD.");
        return 0; // ��������� ���������� �������
    }

    new string[512];
    strcat(string, "Colt45\n\n");
    strcat(string, "Desert Eagle\n");
    strcat(string, "Shotgun\n");
    strcat(string, "MP5\n");
    strcat(string, "M4\n");
    // ��������� ��������� ������ � ������

    new title[32], button1[16], button2[16];
    format(title, sizeof(title), "������� LSPD");
    format(button1, sizeof(button1), "�������");
    format(button2, sizeof(button2), "������");

    ShowPlayerDialog(playerid, DIALOG_LSPD_ARMOR, DIALOG_STYLE_LIST, title, string, button1, button2);
    return 1;
}

// ������� ��� �������� ���� �������� LSPD
CMD:lspdarmory(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� LSPD.");

    if(!IsPlayerInRangeOfPoint(playerid, 3.0, 253.2, 76.5, 1003.6))
        return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� ����� � ��������� LSPD.");

    ShowLSPDArmorMenu(playerid);
    return 1;
}


CreateLSPDPickups()
{
    CreatePickup(1318, 1, gLSPDBoothEnter[0], gLSPDBoothEnter[1], gLSPDBoothEnter[2], -1);
    CreatePickup(1318, 1, gLSPDBoothExit[0], gLSPDBoothExit[1], gLSPDBoothExit[2], -1);
}

CMD:ticket(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� LSPD.");

    new targetid, amount, reason[64];
    if(sscanf(params, "uds[64]", targetid, amount, reason))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /ticket [ID ������] [�����] [�������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� � ��������� ID �� ������.");

    if(!IsPlayerNearPlayer(playerid, targetid, 5.0))
        return SendClientMessage(playerid, COLOR_RED, "�� ���������� ������� ������ �� ������.");

    if(amount < 1 || amount > 10000)
        return SendClientMessage(playerid, COLOR_RED, "����� ������ ������ ���� �� $1 �� $10000.");

    new string[128], officerName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, officerName, sizeof(officerName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� �������� ����� ������ %s �� ����� $%d. �������: %s", targetName, amount, reason);
    SendClientMessage(playerid, COLOR_BLUE, string);

    format(string, sizeof(string), "������ %s ������� ��� ����� �� ����� $%d. �������: %s", officerName, amount, reason);
    SendClientMessage(targetid, COLOR_RED, string);

    GivePlayerMoney(targetid, -amount);

    return 1;
}

CMD:m(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_LSPD && Player[playerid][pFaction] != FACTION_FBI && Player[playerid][pFaction] != FACTION_SHERIFF)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ���. �����������");

    new option[128];
    new idx;
    new message[256];
    new factionName[10];

    // ���������� �������� �������
    if(Player[playerid][pFaction] == FACTION_LSPD)
    {
        format(factionName, sizeof(factionName), "LSPD");
    }
    else if(Player[playerid][pFaction] == FACTION_FBI)
    {
        format(factionName, sizeof(factionName), "FIB");
    }
    else if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        format(factionName, sizeof(factionName), "SHPD");
    }

    if(sscanf(params, "s[128]", option))
    {
        SendClientMessage(playerid, COLOR_GREY, "�������������: /m [���������/������]");
        if(Player[playerid][pFaction] == FACTION_LSPD)
        {
            SendClientMessage(playerid, COLOR_GREY, "1 - ��������, ��� ������� Los Santos'�");
            SendClientMessage(playerid, COLOR_GREY, "2 - ��������, ���������� ���������� ����������");
            SendClientMessage(playerid, COLOR_GREY, "3 - ��������, �������� ������� �� ����������");
            SendClientMessage(playerid, COLOR_GREY, "4 - �������� ������� ��������");
        }
        else if(Player[playerid][pFaction] == FACTION_FBI)
        {
            SendClientMessage(playerid, COLOR_GREY, "1 - ��������! ��� FIB, �������� ���������� � �������");
            SendClientMessage(playerid, COLOR_GREY, "2 - ��������, ���������� ���������� ����������");
            SendClientMessage(playerid, COLOR_GREY, "3 - ��������! �������� FIB ���� ���������� �� ����� ������");
            SendClientMessage(playerid, COLOR_GREY, "4 - �������� ������� �� ���������� � ��������� ������");
            SendClientMessage(playerid, COLOR_GREY, "5 - ��������! �������� ������� ��������");
        }
        else if(Player[playerid][pFaction] == FACTION_SHERIFF)
        {
            SendClientMessage(playerid, COLOR_GREY, "1 - ��������! ��� ������� Los Santos'�, �������� ���������� � �������");
            SendClientMessage(playerid, COLOR_GREY, "2 - ��������, ���������� ���������� ����������");
            SendClientMessage(playerid, COLOR_GREY, "3 - �������� ������� �� ���������� � ��������� ������");
            SendClientMessage(playerid, COLOR_GREY, "4 - ��������! �������� ������� ��������");
        }
        return 1;
    }

    if(sscanf(option, "i", idx))
    {
        // ���� ������ �����, � �� ������, ���������� ��� ��� ����
        if(Player[playerid][pFaction] == FACTION_SHERIFF)
        {
            format(message, sizeof(message), "SHPD ������� � �������: %s", option);
        }
        else
        {
            format(message, sizeof(message), "%s �������: %s", factionName, option);
        }
    }
    else
    {
        // ������������ �� �������
        if(Player[playerid][pFaction] == FACTION_LSPD)
        {
            switch(idx)
            {
                case 1: format(message, sizeof(message), "LSPD �������: ��������! ��� ������� Los Santos'�, �������� ���������� � ������� � ��������� ���������");
                case 2: format(message, sizeof(message), "LSPD �������: ��������, ���������� ���������� ���������� ��� �� ��� ����� ������� �����!");
                case 3: format(message, sizeof(message), "LSPD �������: �������� ������� �� ���������� � ��������� ������ ���, ����� �� ���� �����!");
                case 4: format(message, sizeof(message), "LSPD �������: ��������! �������� ������� ��������, ����� ������������� ����� ����������� ��� ������");
                default: return SendClientMessage(playerid, COLOR_RED, "�������� ������. ������� �������� �� 1 �� 4.");
            }
        }
        else if(Player[playerid][pFaction] == FACTION_FBI)
        {
            switch(idx)
            {
                case 1: format(message, sizeof(message), "FBI �������: ��������! ��� FBI, �������� ���������� � ������� � ��������� ���������");
                case 2: format(message, sizeof(message), "FBI �������: ��������, ���������� ���������� ���������� ��� �� ��� ����� ������� �����!");
                case 3: format(message, sizeof(message), "FBI �������: ��������! �������� FBI ���� ���������� �� ����� ������ � ������� ���� ����� ���, ����� �� ���� �����!");
                case 4: format(message, sizeof(message), "FBI �������: �������� ������� �� ���������� � ��������� ������ ���, ����� �� ���� �����! ��� ����� ������������� �� ��� ����� ������� �����!");
                case 5: format(message, sizeof(message), "FBI �������: ��������! �������� ������� ��������, ����� ������������� ����� ����������� ��� ������ � �� ��� ����� ������� �����!");
                default: return SendClientMessage(playerid, COLOR_RED, "�������� ������. ������� �������� �� 1 �� 5.");
            }
        }
        else if(Player[playerid][pFaction] == FACTION_SHERIFF)
        {
            switch(idx)
            {
                case 1: format(message, sizeof(message), "SHPD ������� � �������: ��������! ��� ������� Los Santos'�, �������� ���������� � ������� � ��������� ���������");
                case 2: format(message, sizeof(message), "SHPD ������� � �������: ��������, ���������� ���������� ���������� ��� �� ��� ����� ������� �����!");
                case 3: format(message, sizeof(message), "SHPD ������� � �������: �������� ������� �� ���������� � ��������� ������ ���, ����� �� ���� �����! ��� ����� ������������� �� ��� ����� ������� �����!");
                case 4: format(message, sizeof(message), "SHPD ������� � �������: ��������! �������� ������� ��������, ����� ������������� ����� ����������� ��� ������ � �� ��� ����� ������� �����!");
                default: return SendClientMessage(playerid, COLOR_RED, "�������� ������. ������� �������� �� 1 �� 4.");
            }
        }
    }

    // �������� ��������� ������� � ������� 30 ������
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, 30.0, x, y, z))
        {
            SendClientMessage(i, COLOR_MEGAPHONE, message);
        }
    }

    return 1;
}


// ������� ��� ���������� �����������
CMD:car(playerid, params[])
{
    new vehicleid;

    if(IsPlayerInAnyVehicle(playerid))
    {
        vehicleid = GetPlayerVehicleID(playerid);

        // ��������� ����� �� ����������
        if(!HasVehicleAccess(playerid, vehicleid))
        {
            RemovePlayerFromVehicle(playerid);
            SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������ �� ����� ����������!");
            return 1;
        }

        ShowCarControlDialog(playerid);
    }
    else
    {
        vehicleid = GetClosestVehicle(playerid);
        if(vehicleid == INVALID_VEHICLE_ID)
        {
            SendClientMessage(playerid, COLOR_RED, "����� ��� ����������.");
            return 1;
        }

        // ��������� ����� �� ����������
        if(!HasVehicleAccess(playerid, vehicleid))
        {
            SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������ �� ����� ����������!");
            return 1;
        }

        // ���������� ���������� ����
        new string[128];
        format(string, sizeof(string),
            "������� �����\n\
            ������� �����"
        );
        ShowPlayerDialog(playerid, DIALOG_VEHICLE_CONTROL, DIALOG_STYLE_LIST,
            "���������� �������", string, "�������", "������");
    }
    return 1;
}


// ������� ��� �������� ����������
CMD:fill(playerid)
{
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        new Float:fuel = GetVehicleFuel(vehicleid);

        if(IsPlayerAtGasStation(playerid))
        {
            new Float:fuelNeeded = MAX_FUEL - fuel;
            new cost = floatround(fuelNeeded * FUEL_PRICE);

            if(GetPlayerMoney(playerid) >= cost)
            {
                GiveVehicleFuel(vehicleid, fuelNeeded);
                GivePlayerMoney(playerid, -cost);
                new string[128];
                format(string, sizeof(string), "�� ��������� %.1f ������ ������� �� %d$", fuelNeeded, cost);
                SendClientMessage(playerid, -1, string);
                UpdateVehicleFuelTextDraw(playerid, vehicleid);
            }
            else
            {
                SendClientMessage(playerid, -1, "� ��� ������������ ����� ��� ��������.");
            }
        }
        else
        {
            SendClientMessage(playerid, -1, "�� ���������� �� �� ��������.");
        }
    }
    else
    {
        SendClientMessage(playerid, -1, "�� ������ ���������� � ����������, ����� �����������.");
    }
    return 1;
}


// �������� ���������� ����������� ������ �������
CreateFuelTextDraw(playerid)
{
    new text[32];
    format(text, sizeof(text), "�������: 0.0/70.0");
    FuelTextDraw[playerid] = CreatePlayerTextDraw(playerid, 550.0, 50.0, text);

    // ��������� �����������
    PlayerTextDrawFont(playerid, FuelTextDraw[playerid], 2);
    PlayerTextDrawLetterSize(playerid, FuelTextDraw[playerid], 0.3, 1.0);
    PlayerTextDrawColor(playerid, FuelTextDraw[playerid], -1);
    PlayerTextDrawShow(playerid, FuelTextDraw[playerid]);
}

// ���������� ���������� ����������� ������ �������
UpdateVehicleFuelTextDraw(playerid, vehicleid)
{
    new Float:fuel = VehicleFuel[vehicleid];
    new string[32];
    format(string, sizeof(string), "�������: %.1f/%.1f", fuel, MAX_FUEL);
    PlayerTextDrawSetString(playerid, FuelTextDraw[playerid], string);
    PlayerTextDrawShow(playerid, FuelTextDraw[playerid]);
}

// ������ ��� ���������� ������ �������
forward UpdateVehicleFuel();
public UpdateVehicleFuel()
{
    for(new i = 1; i <= MAX_VEHICLES; i++)
    {
        if(IsValidVehicle(i))
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);

            new bool:hasPlayers = false;
            for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
            {
                if(IsPlayerInVehicle(playerid, i))
                {
                    hasPlayers = true;
                    break;
                }
            }

            if(hasPlayers && engine == 1)
            {
                new Float:speed = GetVehicleSpeed(i);
                new Float:consumption;

                if(speed > 0.1)
                {
                    new Float:distance = speed / 3600.0;
                    new Float:baseConsumption = distance * 0.5;

                    new Float:speedMultiplier = 1.0 + (speed - 60.0) / 100.0;
                    if(speedMultiplier < 1.0) speedMultiplier = 1.0;

                    consumption = baseConsumption * speedMultiplier;
                }
                else
                {
                    consumption = 0.0025; // ��������� ����������� �� ������ ���������
                }

                VehicleFuel[i] -= consumption;
                if(VehicleFuel[i] < 0.0)
                {
                    VehicleFuel[i] = 0.0;
                    SetVehicleParamsEx(i, 0, lights, alarm, doors, bonnet, boot, objective); // ��������� ���������
                }

                for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
                {
                    if(IsPlayerInVehicle(playerid, i))
                    {
                        UpdateVehicleFuelTextDraw(playerid, i);
                    }
                }
            }
        }
    }
}

/*
SetCustomPlayerWantedLevel(playerid, level, const reason[])
{
    // ������������� ������� ������� ������
    SetPlayerWantedLevel(playerid, level);

    // ��������� ������� �������
    format(Player[playerid][pWantedReason], sizeof(Player[][pWantedReason]), "%s", reason);

    return 1;
}*/

// ������� ��� �������� ����� ��� ������� �������
CreateLSPDGates()
{
    // ������� ������ ������ (�������� �� ���������)
    gateObject1 = CreateObject(968, 1544.7000000, -1630.8000000, 13.1000000, 0.0000000, 90.0000000, 90.0000000);

    // ������� ������ ������ (�������� �� ���������)
    gateObject2 = CreateObject(971, 1588.7000000, -1638.0000000, 15.9000000, 0.0000000, 0.0000000, 179.9950000);
}

// ������� ��� ��������/�������� �����
CMD:gateopen(playerid, params[])
{
    // �������� �������������� � ����������� ��������
    if(Player[playerid][pFaction] != FACTION_LSPD &&
       Player[playerid][pFaction] != FACTION_FBI &&
       Player[playerid][pFaction] != FACTION_ARMY)
    {
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� LSPD, FBI ��� Army.");
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new string[128];
    new bool:nearGate = false;

    // ��������� ����� ��� ������ �������
    switch(Player[playerid][pFaction])
    {
        case FACTION_LSPD:
        {
            if(IsPlayerInRangeOfPoint(playerid, 10.0, 1544.7000000, -1630.8000000, 13.1000000))
            {
                gateState1 = !gateState1;
                AnimateGate(1, gateState1);
                format(string, sizeof(string), "������ LSPD 1 %s", gateState1 ? "�������" : "�������");
                nearGate = true;
            }
            else if(IsPlayerInRangeOfPoint(playerid, 10.0, 1588.7000000, -1638.0000000, 15.9000000))
            {
                gateState2 = !gateState2;
                AnimateGate(2, gateState2);
                format(string, sizeof(string), "������ LSPD 2 %s", gateState2 ? "�������" : "�������");
                nearGate = true;
            }
        }
        case FACTION_FBI:
        {
            if(IsPlayerInRangeOfPoint(playerid, 10.0, 1506.7, -1352.2, 13.8))
            {
                FBIGateState1 = !FBIGateState1;
                AnimateFBIGate(1, FBIGateState1);
                format(string, sizeof(string), "������ FBI 1 (��������) %s", FBIGateState1 ? "�������" : "�������");
                nearGate = true;
            }
            else if(IsPlayerInRangeOfPoint(playerid, 10.0, 1562.3, -1392.3, 15.8))
            {
                FBIGateState2 = !FBIGateState2;
                AnimateFBIGate(2, FBIGateState2);
                format(string, sizeof(string), "������ FBI 2 %s", FBIGateState2 ? "�������" : "�������");
                nearGate = true;
            }
        }
        case FACTION_ARMY:
        {
            if(IsPlayerInRangeOfPoint(playerid, 10.0, 96.7, 1920.3, 17.1))
            {
                ARMYGateState1 = !ARMYGateState1;
                AnimateARMYGate(1, ARMYGateState1);
                format(string, sizeof(string), "������ Army 1 %s", ARMYGateState1 ? "�������" : "�������");
                nearGate = true;
            }
            else if(IsPlayerInRangeOfPoint(playerid, 10.0, 345.20001, 1797.6, 21.3))
            {
                ARMYGateState2 = !ARMYGateState2;
                AnimateARMYGate(2, ARMYGateState2);
                format(string, sizeof(string), "������ Army 2 %s", ARMYGateState2 ? "�������" : "�������");
                nearGate = true;
            }
        }
    }

    if(!nearGate)
    {
        return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� ����� � �������� ����� �������.");
    }

    // ���������� ��������� �� ��������� ��������� �����
    SendClientMessage(playerid, COLOR_GREEN, string);

    // ���������, ����� �� ���������� ��������� �� �������������� ��������
    if((Player[playerid][pFaction] == FACTION_LSPD && (gateState1 || gateState2)) ||
       (Player[playerid][pFaction] == FACTION_FBI && (FBIGateState1 || FBIGateState2)) ||
       (Player[playerid][pFaction] == FACTION_ARMY && (ARMYGateState1 || ARMYGateState2)))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "������ ������������� ��������� ����� 7 ������.");
    }

    return 1;
}


// ������� ��� �������� �������� �����
AnimateGate(gateID, bool:openState)
{
    if(gateID == 1)
    {
        if(openState)
        {
            MoveObject(gateObject1, 1544.7000000, -1630.8000000, 13.1000000, 1.0, 0.0000000, 2.0000000, 90.0000000);
            if(gateTimer1 != -1) KillTimer(gateTimer1);
            gateTimer1 = SetTimerEx(TIMER_CLOSE_GATE, 7000, false, TIMER_FORMAT, 1);
        }
        else
        {
            MoveObject(gateObject1, 1544.7000000, -1630.8000000, 13.1000000, 1.0, 0.0000000, 90.0000000, 90.0000000);
        }
    }
    else if(gateID == 2)
    {
        if(openState)
        {
            MoveObject(gateObject2, 1597.1000000, -1638.0000000, 15.9000000, 1.0, 0.0000000, 0.0000000, -180.0000000);
            if(gateTimer2 != -1) KillTimer(gateTimer2);
            gateTimer2 = SetTimerEx(TIMER_CLOSE_GATE, 7000, false, TIMER_FORMAT, 2);
        }
        else
        {
            MoveObject(gateObject2, 1588.7000000, -1638.0000000, 15.9000000, 1.0, 0.0000000, 0.0000000, 179.9950000);
        }
    }
}

forward CloseGate(gateID);
public CloseGate(gateID)
{
    if(gateID == 1)
    {
        gateState1 = false;
        AnimateGate(1, false);
        gateTimer1 = -1;
    }
    else if(gateID == 2)
    {
        gateState2 = false;
        AnimateGate(2, false);
        gateTimer2 = -1;
    }
}

CreateLSPDDoors()
{
    LSPDDoorObject = CreateObject(1500, 245.3999900, 72.6000000, 1002.6000000, 0.0000000, 0.0000000, 0.0000000);
}
AnimateLSPDDoor(bool:openState)
{
    if(LSPDDoorObject == INVALID_OBJECT_ID)
    {
        return;
    }

    if(openState)
    {
        MoveObject(LSPDDoorObject, 245.3999900, 72.7000000, 1002.6000000, 1.0, 0.0000000, 0.0000000, 96.0000000);
    }
    else
    {
        MoveObject(LSPDDoorObject, 245.3999900, 72.6000000, 1002.6000000, 1.0, 0.0000000, 0.0000000, 0.0000000);
    }
}

ShowBankMenu(playerid)
{
    new string[128];
    format(string, sizeof(string), "��� ���������� ���� �%d\n����� � �����: $%d", Player[playerid][pBankAccount], Player[playerid][pBankMoney]);
    ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE_BANK_ACCOUNT, string, DIALOG_BUTTON_OPERATIONS, DIALOG_BUTTON_CLOSE);
    return 1;
}

ShowATMMenu(playerid)
{
    new content[128], title[32], button1[16], button2[16];
    format(content, sizeof(content), "������: $%d", Player[playerid][pBankMoney]);
    format(title, sizeof(title), "%s", DIALOG_TITLE_ATM);
    format(button1, sizeof(button1), "%s", DIALOG_BUTTON_SELECT);
    format(button2, sizeof(button2), "%s", DIALOG_BUTTON_CANCEL);

    ShowPlayerDialog(playerid, DIALOG_ATM_MENU, DIALOG_STYLE_LIST, title, content, button1, button2);
}

CheckAndPaySalary(playerid)
{
    new currentTime = gettime();
    if (currentTime - Player[playerid][pLastPayday] >= 3600) // 3600 seconds = 1 hour
    {
        new salary = 0;
        new faction = Player[playerid][pFaction];
        new rank = Player[playerid][pRank];

        if(faction == FACTION_LSPD)
        {
            new salaries[MAX_LSPD_RANK] = {500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000};
            salary = salaries[rank - 1];
        }
        else if(faction == FACTION_FBI)
        {
            salary = FBISalaries[rank - 1];
        }
        else if(faction == FACTION_SHERIFF)
        {
            salary = SheriffSalaries[rank - 1];
        }
        else if(faction == FACTION_GOV) // ��������� ��������� GOV
        {
            salary = GOVSalaries[rank - 1];
        }

        if(salary > 0)
        {
            Player[playerid][pBankMoney] += salary;
            Player[playerid][pLastPayday] = currentTime;
            Player[playerid][pPaycheckAmount] = salary;

            SendClientMessage(playerid, COLOR_GREEN, "������ ��������");

            new string[128];
            format(string, sizeof(string), "����� ������: $%d", salary);
            SendClientMessage(playerid, COLOR_GREEN, string);

            format(string, sizeof(string), "����� � �����: $%d", Player[playerid][pBankMoney]);
            SendClientMessage(playerid, COLOR_GREEN, string);

            SaveUser(playerid);
        }
    }
}

CMD:apayday(playerid, params[])
{
    if (Player[playerid][pAdminLevel] < 4) // �������� ADMIN_LEVEL_REQUIRED �� ����������� ������� ��������������
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������.");

    Player[playerid][pLastPayday] = 0; // ���������� ����� ��������� �������
    CheckAndPaySalary(playerid); // ���������� ��������� � ����������� ��������
    SendClientMessage(playerid, COLOR_GREEN, "�������� ��������� �������������.");
    return 1;
}

CMD:tpfbi(playerid)
{
    // ����� ���������� ��� ������������
    new Float:x = 2274.445800;
    new Float:y = -220.961898;
    new Float:z = 987.461120;

    // ������������� ������ �� ��������� ����������
    SetPlayerPos(playerid, x, y, z);

    // ������������� ������� ������ (���� ���������)
    SetPlayerFacingAngle(playerid, 320.0);

    // �������� ������ � ������������
    SendClientMessage(playerid, -1, "�� ���� ��������������� � ������� FBI!");

    return 1;
}

CMD:pos(playerid)
{
    // ���������� ��� �������� ���������
    new Float:x, Float:y, Float:z;

    // �������� ������� ���������� ������
    GetPlayerPos(playerid, x, y, z);

    // ������� ���������� � �������
    printf("����� ID: %d. ������� ����������: X: %f, Y: %f, Z: %f", playerid, x, y, z);

    // ���������� ��������� ������
    SendClientMessage(playerid, -1, "���� ���������� ���� �������� � ������� �������.");

    return 1;
}

CMD:slap(playerid, params[])
{
    new targetid;

    // ���������, ��� �� ������ ID ������
    if(sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, -1, "�����������: /slap [ID ������]");
        return 1;
    }

    // ���������, ��������� �� ����� � ������ ID
    if (!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, -1, "����� �� ���������.");
        return 1;
    }

    // �������� ������� ���������� ����
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);

    // ������������� ���� ���� ���� ������� �������, �������� "����"
    SetPlayerPos(targetid, x, y, z + 5.0); // 5.0 ������ �����

    // �������� ������, ��� ���� ���� "�������"
    SendClientMessage(playerid, -1, "�� ������� ������!");
    SendClientMessage(targetid, -1, "�� ���� ������� � ���������� �����!");

    return 1;
}

stock SetPlayerFBIRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_FBI_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gFBISkins[rank-1]);
    SavePlayerSkin(playerid); // ��������� ����� ����
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � FBI: %s", gFBIRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

stock GetFBIRankName(rank)
{
    if(rank < 1 || rank > MAX_FBI_RANK) return "����������� ����";
    return gFBIRanks[rank - 1];
}

CMD:hospital(playerid)
{
    // ���������� ��������
    new Float:x = 2457.46;
    new Float:y = -1115.0;
    new Float:z = 1312.05;

    // ������������� ������ �� ��������� ����������
    SetPlayerPos(playerid, x, y, z);

    // ��������� ������ � ������������
    SendClientMessage(playerid, COLOR_BLUE, "�� ���� ��������������� � ��������.");

    return 1;
}

CMD:comb(playerid)
{
    // ���������� ��� �������� ���������, ��������� � ������������ ����
    new Float:x, Float:y, Float:z;
    new interior, world;

    // �������� ������� ���������� ������
    GetPlayerPos(playerid, x, y, z);

    // �������� �������� ������
    interior = GetPlayerInterior(playerid);

    // �������� ����������� ��� (dimension) ������
    world = GetPlayerVirtualWorld(playerid);

    // ������� ������ � ������� �������
    printf("����� ID: %d. ����������: X: %f, Y: %f, Z: %f. ��������: %d. ����������� ���: %d", playerid, x, y, z, interior, world);

    // ��������� ������, ��� ���������� �������� � �������
    SendClientMessage(playerid, -1, "���� ����������, �������� � ����������� ��� ���� �������� � ������� �������.");

    return 1;
}

// ��������� ������������ �������
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if (pickupid == DynamicFBIExitPickup)
    {
        SetPlayerPos(playerid, gFBIExitSpawn[0], gFBIExitSpawn[1], gFBIExitSpawn[2]);
        SetPlayerFacingAngle(playerid, gFBIExitSpawn[3]);
        SetPlayerInterior(playerid, 0);
        SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ������ FBI.");
    }
    else if (pickupid == DynamicFBIElevator1Up || pickupid == DynamicFBIElevator1Down ||
             pickupid == DynamicFBIElevator2Up || pickupid == DynamicFBIElevator2Down)
    {
        if (Player[playerid][pFaction] != FACTION_FBI)
        {
            SendClientMessage(playerid, COLOR_RED, "������ ���������� FBI ����� ������������ ���� ������.");
            return 1;
        }

        new Float:x, Float:y, Float:z;
        if (pickupid == DynamicFBIElevator1Up)
        {
            x = 2271.731933; y = -208.509765; z = 987.339477;
            SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ������ ���� FBI.");
        }
        else if (pickupid == DynamicFBIElevator1Down)
        {
            x = 2270.092529; y = -207.825561; z = 982.599487;
            SendClientMessage(playerid, COLOR_BLUE, "�� ���������� �� ������ ���� FBI.");
        }
        else if (pickupid == DynamicFBIElevator2Up)
        {
            x = 2252.453613; y = -208.120864; z = 987.339477;
            SendClientMessage(playerid, COLOR_BLUE, "�� ��������� �� ������ ���� FBI (������ �������).");
        }
        else if (pickupid == DynamicFBIElevator2Down)
        {
            x = 2253.025146; y = -208.246917; z = 982.599487;
            SendClientMessage(playerid, COLOR_BLUE, "�� ���������� �� ������ ���� FBI (������ �������).");
        }

        SetPlayerPos(playerid, x, y, z);
        // ��������� ������� �������� � ����������� ���
        new interior = GetPlayerInterior(playerid);
        new vw = GetPlayerVirtualWorld(playerid);
        SetPlayerInterior(playerid, interior);
        SetPlayerVirtualWorld(playerid, vw);
    }
    // ������ �������� (�������� �� ����� FBI)
    else if(pickupid == EnterShopPickup)
    {
        // ������� ������������� ��������, ����� �������������
        SetPlayerInterior(playerid, 1);
        SetPlayerVirtualWorld(playerid, 0);
        // ��������� �������� ����� �������������
        SetTimerEx("TeleportToShop", 100, false, "i", playerid);
    }
    else if(pickupid == ExitShopPickup)
    {
        // ������� ������������� ��������, ����� �������������
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        // ��������� �������� ����� �������������
        SetTimerEx("TeleportFromShop", 100, false, "i", playerid);
    }
    else if(pickupid == ClothingPickup && !gIsInClothingMenu[playerid])
    {
        gIsInClothingMenu[playerid] = true;
        SetPVarInt(playerid, "OldSkin", GetPlayerSkin(playerid));
        ShowClothingSelection(playerid);
    }
    return 1;
}

// ������� �������� ����� FBI (�������� ��)
AnimateFBIGate(gateID, bool:openState)
{
    if(gateID == 1)
    {
        if(openState)
        {
            MoveObject(FBIGateObject1, 1506.6, -1352.1, 13.6, 1.0, 0.0, 0.0, 0.0);
            if(FBIGateTimer1 != -1) KillTimer(FBIGateTimer1);
            FBIGateTimer1 = SetTimerEx("CloseFBIGate", 7000, false, "i", 1);
        }
        else
        {
            MoveObject(FBIGateObject1, 1506.7, -1352.2, 13.8, 1.0, -0.125, 90.215, -179.333);
        }
    }
    else if(gateID == 2)
    {
        if(openState)
        {
            MoveObject(FBIGateObject2, 1562.4, -1379.6, 15.8, 1.0, 0.0, 0.0, -90.0);
            if(FBIGateTimer2 != -1) KillTimer(FBIGateTimer2);
            FBIGateTimer2 = SetTimerEx("CloseFBIGate", 7000, false, "i", 2);
        }
        else
        {
            MoveObject(FBIGateObject2, 1562.3, -1392.3, 15.8, 1.0, 0.0, 0.0, -90.0);
        }
    }
}

// ������� ��������������� �������� ����� FBI (�������� ��)
forward CloseFBIGate(gateID);
public CloseFBIGate(gateID)
{
    if(gateID == 1)
    {
        FBIGateState1 = false;
        AnimateFBIGate(1, false);
        FBIGateTimer1 = -1;
    }
    else if(gateID == 2)
    {
        FBIGateState2 = false;
        AnimateFBIGate(2, false);
        FBIGateTimer2 = -1;
    }
}

ShowFBIArmorMenu(playerid)
{
    if(Player[playerid][pFaction] != FACTION_FBI)
    {
        SendClientMessage(playerid, COLOR_RED, "�� �� ��������� ����������� FBI.");
        return 0;
    }

    new string[512];
    strcat(string, "Colt45\n");
    strcat(string, "Desert Eagle\n");
    strcat(string, "Shotgun\n");
    strcat(string, "MP5\n");
    strcat(string, "M4\n");
    strcat(string, "Sniper Rifle\n");

    ShowPlayerDialog(playerid, DIALOG_FBI_ARMOR, DIALOG_STYLE_LIST, "������� FBI", string, "�������", "������");
    return 1;
}

stock SetPlayerEMSRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_EMS_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gEMSSkins[rank-1]);
    SavePlayerSkin(playerid); // ��������� ����� ����
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � EMS: %s", gEMSRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if(!PlayerIsDying[playerid])
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        if(health - amount <= 0)
        {
            // ������������� ������ ������
            SetPlayerHealth(playerid, 1.0);
            TogglePlayerControllable(playerid, 0);
            PlayerIsDying[playerid] = true;

            // ��������� ������� ������
            GetPlayerPos(playerid, LastPlayerPos[playerid][0], LastPlayerPos[playerid][1], LastPlayerPos[playerid][2]);

            // ��������� �������� � ��������� ������
            ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.1, 1, 0, 0, 1, 0, 1);
            SetPlayerCameraPos(playerid, LastPlayerPos[playerid][0] + 2.0, LastPlayerPos[playerid][1] + 2.0, LastPlayerPos[playerid][2] + 1.0);
            SetPlayerCameraLookAt(playerid, LastPlayerPos[playerid][0], LastPlayerPos[playerid][1], LastPlayerPos[playerid][2]);

            // ������� ����� EMS � ������������� ������
            CreateEMSCall(playerid);
            PlayerDeathTimer[playerid] = SetTimerEx("PlayerDeathState", EMS_CALL_TIME, false, "i", playerid);

            // ������������� ��������� ������ ������
            SetPlayerHealth(playerid, 100.0);
            return 0;
        }
    }
    return 1;
}


forward PlayerDeathState(playerid);
public PlayerDeathState(playerid)
{
    if(PlayerIsDying[playerid])
    {
        PlayerIsDying[playerid] = false;
        TogglePlayerControllable(playerid, 1);

        // ��������������� ������ ������
        SetCameraBehindPlayer(playerid);

        // ���������� ������ � ��������
        SpawnPlayerInHospital(playerid);
        SendClientMessage(playerid, COLOR_INFO, "��� ��������� � ��������, ��� ��� ������ �� ������� �������.");

        // ��������������� ���� ������
        SetPlayerSkin(playerid, PlayerLastSkin[playerid]);
    }
}

SpawnPlayerInHospital(playerid)
{
    new spawnPoint = random(sizeof(EMSSpawnPoints));
    SetPlayerPos(playerid, EMSSpawnPoints[spawnPoint][0], EMSSpawnPoints[spawnPoint][1], EMSSpawnPoints[spawnPoint][2]);
    SetPlayerInterior(playerid, 1);
    SetPlayerHealth(playerid, 10);
    SendClientMessage(playerid, COLOR_INFO, "�� ���� ���������� � ��������.");

    // ��������������� ����������� ���� ������
    SetPlayerSkin(playerid, PlayerSkins[playerid]);

    if(PlayerHealTimer[playerid] != -1)
    {
        KillTimer(PlayerHealTimer[playerid]);
    }
    PlayerHealTimer[playerid] = SetTimerEx("HealPlayer", 60000, true, "i", playerid); // �������� �� 60000 �� (1 ������)
}

forward HealPlayer(playerid);
public HealPlayer(playerid)
{
    new Float:health;
    GetPlayerHealth(playerid, health);
    if(health < 100)
    {
        health += 20;
        if(health > 100) health = 100;
        SetPlayerHealth(playerid, health);
        SendClientMessage(playerid, COLOR_INFO, "��� ��������� +20 ��");
        if(health == 100)
        {
            KillTimer(PlayerHealTimer[playerid]);
            PlayerHealTimer[playerid] = -1;
            SendClientMessage(playerid, COLOR_INFO, "���� �������� ��������� �������������. �� ������ �������� ��������.");
        }
    }
}

CreateEMSCall(playerid)
{
    new callID = -1;
    for(new i = 0; i < MAX_EMS_CALLS; i++)
    {
        if(!EMSCalls[i][isActive])
        {
            callID = i;
            break;
        }
    }

    if(callID == -1) return;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    EMSCalls[callID][isActive] = true;
    EMSCalls[callID][playerID] = playerid;
    EMSCalls[callID][posX] = x;
    EMSCalls[callID][posY] = y;
    EMSCalls[callID][posZ] = z;
    EMSCalls[callID][timeLeft] = EMS_CALL_TIME / 1000;

    new string[128];
    format(string, sizeof(string), "������ #%d. ��������� ������ �������������. ����� ������� ����� ������� /acceptc %d", callID + 1, callID + 1);
    SendMessageToEMS(string);
}

SendMessageToEMS(const message[])
{
    foreach(new i : Player)
    {
        if(Player[i][pFaction] == FACTION_EMS)
        {
            SendClientMessage(i, COLOR_EMS, message);
        }
    }
}

CMD:acceptc(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_EMS) return SendClientMessage(playerid, COLOR_ERROR, "�� �� ��������� ����������� EMS.");

    new callID;
    if(sscanf(params, "d", callID)) return SendClientMessage(playerid, COLOR_USAGE, "�������������: /acceptc [����� ������]");

    callID--;
    if(callID < 0 || callID >= MAX_EMS_CALLS || !EMSCalls[callID][isActive])
        return SendClientMessage(playerid, COLOR_ERROR, "�������� ����� ������.");

    SetPlayerCheckpoint(playerid, EMSCalls[callID][posX], EMSCalls[callID][posY], EMSCalls[callID][posZ], 3.0);
    SendClientMessage(playerid, COLOR_INFO, "�� ������� �����. �������� � ������� �� �����.");

    return 1;
}

CMD:rescue(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_EMS)
        return SendClientMessage(playerid, COLOR_ERROR, "�� �� ��������� ����������� EMS.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_USAGE, "�������������: /rescue [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "����� �� ������.");

    if(!IsPlayerNearPlayer(playerid, targetid, 5.0))
        return SendClientMessage(playerid, COLOR_ERROR, "�� ���������� ������� ������ �� ������.");

    if(!PlayerIsDying[targetid])
        return SendClientMessage(playerid, COLOR_ERROR, "���� ����� �� ��������� � ����������.");

    // ���� �������� ���������� (��������, 70%)
    if(random(100) < 70)
    {
        // �������� ����������
        KillTimer(PlayerDeathTimer[targetid]);
        PlayerDeathTimer[targetid] = -1;
        PlayerIsDying[targetid] = false;
        ClearAnimations(targetid);
        SetPlayerHealth(targetid, 20);
        TogglePlayerControllable(targetid, 1);

        // ��������������� ������ ������
        SetCameraBehindPlayer(targetid);

        // ��������������� ����������� ���� ������
        SetPlayerSkin(targetid, PlayerSkins[targetid]);

        SendClientMessage(targetid, COLOR_INFO, "��� ������� �������������.");
        SendClientMessage(playerid, COLOR_INFO, "�� ������� ������������� ������.");

        // �������� ��� EMS ����������
        ApplyAnimation(playerid, "MEDIC", "CPR", 4.1, 0, 0, 0, 0, 0);

        // ������� ����� � �����, ���� ��� ����
        DisablePlayerCheckpoint(playerid);
    }
    else
    {
        // ��������� ������� ����������
        SendClientMessage(playerid, COLOR_INFO, "������� ���������� �� �������. ���������� ��� ���.");

        // �������� ��� ��������� �������
		ApplyAnimation(playerid, "MEDIC", "CPR", 4.1, 0, 0, 0, 0, 0, 1);
    }

    return 1;
}

forward CheckPlayerDyingState(playerid);
public CheckPlayerDyingState(playerid)
{
    if(PlayerIsDying[playerid])
    {
        SetPlayerHealth(playerid, 1.0);
        ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.1, 1, 0, 0, 1, 0, 1);
        TogglePlayerControllable(playerid, 0);

        // �������� ��������� ������
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerCameraPos(playerid, x + 2.0, y + 2.0, z + 1.0);
        SetPlayerCameraLookAt(playerid, x, y, z);
    }
    return 1;
}
stock SavePlayerSkin(playerid)
{
    PlayerSkins[playerid] = GetPlayerSkin(playerid);
}

CMD:heal(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_EMS)
        return SendClientMessage(playerid, COLOR_ERROR, "�� �� ��������� ����������� EMS.");

    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
        return SendClientMessage(playerid, COLOR_USAGE, "�������������: /heal [ID ������] [�����]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_ERROR, "����� �� ������.");

    if(targetid == playerid)
        return SendClientMessage(playerid, COLOR_ERROR, "�� �� ������ ������ ������ ����.");

    if(!IsPlayerNearPlayer(playerid, targetid, 5.0))
        return SendClientMessage(playerid, COLOR_ERROR, "�� ���������� ������� ������ �� ������.");

    if(amount < 1 || amount > 1000)
        return SendClientMessage(playerid, COLOR_ERROR, "����� ������ ���� �� 1 �� 1000$.");

    new Float:targetHealth;
    GetPlayerHealth(targetid, targetHealth);

    if(targetHealth >= 100.0)
        return SendClientMessage(playerid, COLOR_ERROR, "� ����� ������ ��� ������������ ��������.");

    if(GetPlayerMoney(targetid) < amount)
        return SendClientMessage(playerid, COLOR_ERROR, "� ������ ������������ ����� ��� ������ �������.");

    // ������� ������
    SetPlayerHealth(targetid, 100.0);
    GivePlayerMoney(targetid, -amount);
    GivePlayerMoney(playerid, amount);

    // �������� �������
	ApplyAnimationEx(playerid, "MEDIC", "CPR", 4.1, 0, 0, 0, 0, 0, 1);

	// ��������� �������
	new string[128], targetName[MAX_PLAYER_NAME];
	GetPlayerName(targetid, targetName, sizeof(targetName));
	format(string, sizeof(string), "�� �������� ������ %s � �������� $%d", targetName, amount);
	SendClientMessage(playerid, COLOR_INFO, string);

	new medicName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, medicName, sizeof(medicName));
	format(string, sizeof(string), "����� %s ������� ��� �� $%d", medicName, amount);
    SendClientMessage(targetid, COLOR_INFO, string);

    return 1;
}
ApplyDeathAnimation(playerid)
{
    ApplyAnimation(playerid, ANIM_CRACK, ANIM_CRCKDETH2, 4.1, 1, 0, 0, 1, 0, 1);
}



AnimateSheriffDoor(bool:openState)
{
    if(SheriffDoorObject == INVALID_OBJECT_ID)
    {
        return;
    }

    if(openState)
    {
        MoveObject(SheriffDoorObject, 246.5, 78.0, 985.70001, 1.0, 0.0, 0.0, 90.5);
    }
    else
    {
        MoveObject(SheriffDoorObject, 246.5, 78.0, 985.79999, 1.0, 0.0, 0.0, 0.0);
    }
}
stock SetPlayerGroveRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_GROVE_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gGroveSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � Grove Street: %s", gGroveRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

CreateGroveVehicles()
{
    for(new i = 0; i < sizeof(GroveVehicles); i++)
    {
        new vehicleid = CreateVehicle(GroveVehicleModels[i],
            GroveVehicleSpawns[i][0],
            GroveVehicleSpawns[i][1],
            GroveVehicleSpawns[i][2],
            GroveVehicleSpawns[i][3],
            86, // ������� ����
            86, // ������� ����
            -1);

        GroveVehicles[i] = vehicleid;

        new plate[32];
        format(plate, sizeof(plate), "GROVE %03d", i);
        SetVehicleNumberPlate(vehicleid, plate);

        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}
// �������� ���� ������
ShowMissionMenu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MISSIONS, DIALOG_STYLE_LIST, "������� �� Big John",
        "��������� ��������\n������ ����", "�������", "������");
}

// �������� ������������� ������� � ����������
ShowStashMissionConfirm(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_STASH_CONFIRM, DIALOG_STYLE_MSGBOX, "�������: ��������",
        "���� ����� ��������� 20 �������� � ������ ����� ������.\n��������� ����� �������� � 145$, ��� ���������� ������� ����������� 2900$.\n�� ������ ������� ������������ �������� �� �������� ������� � ������� 190$.",
        "����� �������", "������");
}

// ������ ������� � ����������
StartStashMission(playerid)
{
    // ���������� ����������
    new debugString[256];
    format(debugString, sizeof(debugString), "Debug: Current time: %d, Cooldown time: %d, CanDoMission: %d",
        gettime(),
        Player[playerid][pStashMissionCooldown],
        Player[playerid][pCanDoStashMission]
    );
    SendClientMessage(playerid, COLOR_GREEN, debugString);

    // ��������� �������
    if(Player[playerid][pStashMissionCooldown] > gettime())
    {
        new cooldown = Player[playerid][pStashMissionCooldown] - gettime();
        new string[128];
        format(string, sizeof(string), "��������� ��� %d ������ ����� ������� ������ �������. (Cooldown: %d, Current: %d)",
            cooldown,
            Player[playerid][pStashMissionCooldown],
            gettime()
        );
        SendClientMessage(playerid, COLOR_RED, string);
        return 0;
    }

    // ��������� ������� �����
    if(GetPlayerMoney(playerid) < 2900)
    {
        SendClientMessage(playerid, COLOR_RED, "� ��� ������������ ����� ��� ������ �������!");
        return 0;
    }

    // �������� ������
    GivePlayerMoney(playerid, -2900);
    PlayerDoingStashMission[playerid] = true;
    Player[playerid][pCanDoStashMission] = true; // ������� �� true
    Player[playerid][pStashMissionCooldown] = 0; // ���������� �������
    PlayerStashesLeft[playerid] = 20;
    SetNextStashPoint(playerid);

    SendClientMessage(playerid, COLOR_GREEN, "������� ������! �������� � ���������� �����.");

    // ���������� ���������� ����� ���������
    format(debugString, sizeof(debugString), "Debug After Start: Cooldown: %d, CanDoMission: %d",
        Player[playerid][pStashMissionCooldown],
        Player[playerid][pCanDoStashMission]
    );
    SendClientMessage(playerid, COLOR_GREEN, debugString);

    SaveUser(playerid);
    return 1;
}

// ���������� ��������� ����� ��� ��������
SetNextStashPoint(playerid)
{
    if(PlayerStashesLeft[playerid] <= 0) return 0;

    new randPoint = random(sizeof(StashPoints));
    SetPlayerCheckpoint(playerid, StashPoints[randPoint][0], StashPoints[randPoint][1], StashPoints[randPoint][2], 3.0);
    PlayerCurrentCP[playerid] = randPoint;
    return 1;
}
forward OnStashPlaced(playerid);
public OnStashPlaced(playerid)
{
    GivePlayerMoney(playerid, 190);
    PlayerStashesLeft[playerid]--;

    if(PlayerStashesLeft[playerid] > 0)
    {
        SendClientMessage(playerid, COLOR_GREEN, "�� �������� �������� � �������� 190$");
        SetNextStashPoint(playerid);
    }
    else
    {
        SendClientMessage(playerid, COLOR_GREEN, "�� ��������� ��� ��������. ��������� 3 ������");
        PlayerDoingStashMission[playerid] = false;
        PlayerNextStashTimer[playerid] = SetTimerEx("EnableStashMission", 180000, false, "i", playerid);
    }
}

// �������� ����������� ����� ����� �������
forward EnableStashMission(playerid);
public EnableStashMission(playerid)
{
    PlayerNextStashTimer[playerid] = -1;
    Player[playerid][pCanDoStashMission] = true;
    Player[playerid][pStashMissionCooldown] = 0;
    SendClientMessage(playerid, COLOR_GREEN, "�� ������ ����� ����� ������� � Big John");
    SaveUser(playerid);
}

// �������� �������� �� ����� ������������
LoadBusinesses()
{
    if(!fexist("businesses.cfg"))
    {
        new File:file = fopen("businesses.cfg", io_write);
        if(file)
        {
            new string[256];

			format(string, sizeof(string), "1|24/7 LS|None|1315.389648|-898.885803|39.578125|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "2|Burger Shot LS|None|1199.693847|-919.824829|43.107589|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "3|Sex Shop LS|None|1087.605468|-922.871948|43.390625|1500000|7500\n");
			fwrite(file, string);
			format(string, sizeof(string), "4|Cluckin Bell Beach|None|927.423706|-1352.795166|13.376624|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "5|Sex Shop Beach|None|953.874816|-1336.391479|13.538937|1500000|7500\n");
			fwrite(file, string);
			format(string, sizeof(string), "6|Cluckin Bell Grove|None|2421.620361|-1509.163085|23.992208|2600000|13000\n");
			fwrite(file, string);
			format(string, sizeof(string), "7|Ten Green Bottles|None|2309.676757|-1644.051757|14.827047|3800000|19000\n");
			fwrite(file, string);
			format(string, sizeof(string), "8|Pig Pen Club|None|2421.507324|-1219.351928|25.554723|4200000|21000\n");
			fwrite(file, string);
			format(string, sizeof(string), "9|Alhambra Club|None|1835.677490|-1682.488403|13.379734|4000000|20000\n");
			fwrite(file, string);
			format(string, sizeof(string), "10|Driving School|None|-2026.599121|-101.420875|35.164062|2200000|11000\n");
			fwrite(file, string);
			format(string, sizeof(string), "11|Misty's Bar SF|None|-2243.077392|-88.254119|35.320312|3700000|18500\n");
			fwrite(file, string);
			format(string, sizeof(string), "12|Four Dragons Casino|None|2020.498535|1007.743408|10.820311|7500000|37500\n");
			fwrite(file, string);
			format(string, sizeof(string), "13|Caligula's Casino|None|2195.840087|1677.150512|12.367186|8000000|40000\n");
			fwrite(file, string);
			format(string, sizeof(string), "14|City Planning|None|2413.159912|1123.804077|10.820311|2000000|10000\n");
			fwrite(file, string);
			format(string, sizeof(string), "15|LV Pizza Stack|None|2083.363037|2223.861572|11.023436|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "16|Burger Shot LV Center|None|1872.878784|2071.857666|11.062500|3000000|15000\n");
			fwrite(file, string);
			format(string, sizeof(string), "17|Strip Club Central LV|None|2507.153076|2121.128173|10.840012|4500000|22500\n");
			fwrite(file, string);
			format(string, sizeof(string), "18|Cluckin Bell East LV|None|2637.511718|1671.698120|11.023436|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "19|24/7 Central LV|None|2546.290283|1971.762695|10.820311|1300000|6500\n");
			fwrite(file, string);
			format(string, sizeof(string), "20|Cluckin Bell SF Beach|None|-2672.043945|258.937194|4.632812|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "21|Burger Shot SF North|None|-2356.885498|1008.085449|50.898437|2900000|14500\n");
			fwrite(file, string);
			format(string, sizeof(string), "22|Burger Shot SF West|None|-1911.886352|828.324584|35.190605|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "23|Pizza Stack SF|None|-1808.028808|945.119873|24.890625|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "24|Cluckin Bell SF Center|None|-1816.763427|617.589660|35.171875|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "25|Pizza Stack SF Shore|None|-1721.932250|1359.860717|7.185316|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "26|Cluckin Bell Angel Pine|None|-2154.623535|-2460.848876|30.851562|2500000|12500\n");
			fwrite(file, string);
			format(string, sizeof(string), "27|Pizza Stack Blueberry|None|203.338851|-203.111373|1.578125|2500000|12500\n");
			fwrite(file, string);
			format(string, sizeof(string), "28|Burger Shot SF South|None|-2336.397460|-166.919891|35.554687|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "29|Cluckin Bell Fort Carson|None|172.669723|1176.409179|14.764542|2500000|12500\n");
			fwrite(file, string);
			format(string, sizeof(string), "30|Pleasure Dome SF|None|-2624.398925|1411.984985|7.093750|4300000|21500\n");
			fwrite(file, string);
			format(string, sizeof(string), "31|Pizza Stack Palomino|None|2332.967041|75.052017|26.620975|2600000|13000\n");
			fwrite(file, string);
			format(string, sizeof(string), "32|Pizza Stack Montgomery|None|1367.071044|248.593109|19.566932|2600000|13000\n");
			fwrite(file, string);
			format(string, sizeof(string), "33|Burger Shot LS South|None|810.959289|-1616.228393|13.546875|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "34|Burger Shot LV East|None|2366.433105|2071.120605|10.820311|2900000|14500\n");
			fwrite(file, string);
			format(string, sizeof(string), "35|Burger Shot LV North|None|2472.081542|2034.191772|11.062500|2900000|14500\n");
			fwrite(file, string);
			format(string, sizeof(string), "36|Cluckin Bell LV Center|None|2393.012207|2043.314697|10.820311|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "37|Cluckin Bell LV North|None|2846.259521|2414.882568|11.068956|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "38|Pizza Stack LV North|None|2756.376708|2476.747314|11.062500|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "39|24/7 LV North|None|2885.277587|2453.478271|11.068956|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "40|Zero's RC Shop|None|-2242.484130|128.449966|35.320312|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "41|24/7 SF Central|None|-2442.768310|754.327941|35.171875|1300000|6500\n");
			fwrite(file, string);
			format(string, sizeof(string), "42|Inside Track LS|None|1631.911132|-1172.027099|24.078125|3500000|17500\n");
			fwrite(file, string);
			format(string, sizeof(string), "43|Inside Track Montgomery|None|1289.185424|270.880920|19.554687|3200000|16000\n");
			fwrite(file, string);
			format(string, sizeof(string), "44|Donut Shop LS|None|1038.215576|-1339.617309|13.726561|2200000|11000\n");
			fwrite(file, string);
			format(string, sizeof(string), "45|Tattoo Parlor LV|None|2094.657714|2122.192871|10.820311|2000000|10000\n");
			fwrite(file, string);
			format(string, sizeof(string), "46|Sex Shop LV|None|2085.687255|2074.024902|11.054686|1500000|7500\n");
			fwrite(file, string);
			format(string, sizeof(string), "47|Strip Club Bone County|None|693.628173|1966.920166|5.539062|3800000|19000\n");
			fwrite(file, string);
			format(string, sizeof(string), "48|Burger Shot LV North|None|1158.547973|2072.261474|11.062500|2900000|14500\n");
			fwrite(file, string);
			format(string, sizeof(string), "49|Burger Shot LV East|None|2170.229003|2795.691894|10.820311|2900000|14500\n");
			fwrite(file, string);
			format(string, sizeof(string), "50|Pizza Stack LV East|None|2330.606201|2532.529785|10.820311|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "51|Pro Laps LV|None|2825.737060|2407.213623|11.062500|1900000|9500\n");
			fwrite(file, string);
			format(string, sizeof(string), "52|Victim Store LV|None|2802.501220|2430.280273|11.062500|1900000|9500\n");
			fwrite(file, string);
			format(string, sizeof(string), "53|Suburban LV|None|2779.359375|2453.658691|11.062500|1900000|9500\n");
			fwrite(file, string);
			format(string, sizeof(string), "54|Cluckin Bell LV Central|None|2102.554687|2228.759033|11.023436|2800000|14000\n");
			fwrite(file, string);
			format(string, sizeof(string), "55|Binco LV|None|2102.572265|2257.474365|11.023436|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "56|24/7 LV Central|None|2097.767578|2223.978515|11.023436|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "57|Zip LV|None|2090.559570|2224.423828|11.023436|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "58|24/7 LV South|None|2194.563720|1991.017944|12.296875|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "59|24/7 LV East|None|2452.393310|2064.608154|10.820311|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "60|Craw Bar LV|None|2441.232421|2064.397949|10.820311|3500000|17500\n");
			fwrite(file, string);
			format(string, sizeof(string), "61|Barber Shop LV|None|2080.458740|2121.975341|10.812517|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "62|Barber Shop SF|None|-2571.014892|246.275955|10.185619|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "63|Tattoo Shop SF|None|-2492.447998|-38.669422|25.765625|2000000|10000\n");
			fwrite(file, string);
			format(string, sizeof(string), "64|Suburban SF|None|-2492.282470|-29.028230|25.765625|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "65|Zip SF|None|-1883.063476|865.582031|35.172843|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "66|Victim SF|None|-1693.950805|950.370056|24.890625|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "67|Binco SF|None|-2374.904052|910.287475|45.445312|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "68|Tattoo Parlor LS|None|2069.536621|-1779.876708|13.559158|2000000|10000\n");
			fwrite(file, string);
			format(string, sizeof(string), "69|Barber Shop LS|None|2071.437255|-1793.805786|13.553277|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "70|Pizza Stack LS|None|2104.495605|-1806.595214|13.554686|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "71|Didier Sachs LS|None|453.227142|-1478.244018|30.812078|2200000|11000\n");
			fwrite(file, string);
			format(string, sizeof(string), "72|Ammu-Nation LS|None|1368.388671|-1279.795898|13.546875|5000000|25000\n");
			fwrite(file, string);
			format(string, sizeof(string), "73|Cluckin Bell LS South|None|2397.941406|-1898.133666|13.546875|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "74|24/7 Rural|None|-1561.987426|-2733.466552|48.743457|1100000|5500\n");
			fwrite(file, string);
			format(string, sizeof(string), "75|Los Santos Forum|None|2781.348144|-1814.231079|11.843750|6000000|30000\n");
			fwrite(file, string);
			format(string, sizeof(string), "76|Ammu-Nation Rural|None|-2093.248046|-2464.454589|30.625000|4800000|24000\n");
			fwrite(file, string);
			format(string, sizeof(string), "77|Tattoo Parlor LS South|None|1975.763061|-2036.651611|13.546875|2000000|10000\n");
			fwrite(file, string);
			format(string, sizeof(string), "78|Sex Shop LS South|None|1941.082763|-2116.011474|13.695311|1500000|7500\n");
			fwrite(file, string);
			format(string, sizeof(string), "79|24/7 LS Center|None|1832.444946|-1842.604736|13.578125|1300000|6500\n");
			fwrite(file, string);
			format(string, sizeof(string), "80|Ammu-Nation LV|None|2158.767333|943.083129|10.820311|5000000|25000\n");
			fwrite(file, string);
			format(string, sizeof(string), "81|Pizza Stack LV East|None|2638.084228|1849.809326|11.023436|2700000|13500\n");
			fwrite(file, string);
			format(string, sizeof(string), "82|Rusty Brown's Donuts|None|-143.945327|1224.217529|19.899219|2200000|11000\n");
			fwrite(file, string);
			format(string, sizeof(string), "83|LV Gym|None|1969.270507|2294.182617|16.455863|3000000|15000\n");
			fwrite(file, string);
			format(string, sizeof(string), "84|24/7 LV North|None|1937.173583|2307.304931|10.820311|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "85|Ammu-Nation Desert|None|-1508.861572|2609.611572|55.835937|4800000|24000\n");
			fwrite(file, string);
			format(string, sizeof(string), "86|24/7 LV East|None|2247.947509|2397.572998|10.820311|1200000|6000\n");
			fwrite(file, string);
			format(string, sizeof(string), "87|Barber Shop LS East|None|2722.694335|-2026.645629|13.547199|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "88|Ammu-Nation LV Center|None|2538.900878|2084.042968|10.820311|5000000|25000\n");
			fwrite(file, string);
			format(string, sizeof(string), "89|Barber Shop Marina|None|823.392944|-1588.984252|13.554450|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "90|Pro-Laps Rodeo|None|499.961059|-1359.307128|16.257724|1900000|9500\n");
			fwrite(file, string);
			format(string, sizeof(string), "91|Victim Rodeo|None|460.946624|-1500.953002|31.058170|1900000|9500\n");
			fwrite(file, string);
			format(string, sizeof(string), "92|Welcome Pump|None|681.296936|-474.303710|16.536296|3500000|17500\n");
			fwrite(file, string);
			format(string, sizeof(string), "93|Binco Ganton|None|2244.590820|-1664.513061|15.476561|1800000|9000\n");
			fwrite(file, string);
			format(string, sizeof(string), "94|Barber Shop Dillimore|None|674.178527|-497.001251|16.335937|1000000|5000\n");
			fwrite(file, string);
			format(string, sizeof(string), "95|Gas Station Dillimore|None|661.015319|-573.572692|16.335937|3500000|17500\n");
			fwrite(file, string);
			format(string, sizeof(string), "96|Mexican Inn|None|2354.133056|-1512.185668|24.000000|3000000|15000\n");
			fwrite(file, string);
			format(string, sizeof(string), "97|Ammu-Nation SF|None|-2626.432128|209.431488|4.601754|5000000|25000\n");
			fwrite(file, string);
			format(string, sizeof(string), "98|Ammu-Nation LS South|None|2400.531738|-1980.582885|13.546875|5000000|25000\n");
			fwrite(file, string);
			format(string, sizeof(string), "99|Ammu-Nation Bone County|None|778.146789|1871.564575|4.907618|4800000|24000\n");
			fwrite(file, string);

            // ... ����������� ��������� ��� ������� ����� �� �������

            // ��������� ��������� ������
            format(string, sizeof(string), "100|LS City Hall|None|1481.034667|-1770.273193|18.795755|0|0\n");
            fwrite(file, string);

            fclose(file);
        }
    }


    new File:file = fopen("businesses.cfg", io_read);
    if(file)
    {
        new line[256], id, name[64], owner[MAX_PLAYER_NAME], Float:x, Float:y, Float:z, price, profit;
        while(fread(file, line))
        {
            if(sscanf(line, "p<|>ds[64]s[24]fffdd", id, name, owner, x, y, z, price, profit))
                continue;

            Business[id][bExists] = true;
            format(Business[id][bName], 64, name);
            format(Business[id][bOwner], MAX_PLAYER_NAME, owner);
            Business[id][bEntranceX] = x;
            Business[id][bEntranceY] = y;
            Business[id][bEntranceZ] = z;
            Business[id][bPrice] = price;
            Business[id][bProfitPerHour] = profit;
            Business[id][bLastProfit] = gettime();

            // ������� ����� � 3D �����
            Business[id][bPickup] = CreatePickup(1272, 1, x, y, z, -1);

            new label[256];
            if(!strcmp(owner, "None", true))
            {
                format(label, sizeof(label), "%s\n����: $%d\n�������: $%d/���\n������� /buybiz ��� �������",
                    name, price, profit);
            }
            else
            {
                format(label, sizeof(label), "%s\n��������: %s\n�������: $%d/���",
                    name, owner, profit);
            }
            Business[id][bLabel] = Create3DTextLabel(label, 0xFFFF00AA, x, y, z + 0.5, 20.0, 0, 1);
        }
        fclose(file);
    }
    return 1;
}

// ���������� �������� � ����
SaveBusinesses()
{
    new File:file = fopen("businesses.cfg", io_write);
    if(file)
    {
        new string[256];
        for(new i = 0; i < MAX_BUSINESSES; i++)
        {
            if(Business[i][bExists])
            {
                format(string, sizeof(string), "%d|%s|%s|%f|%f|%f|%d|%d\n",
                    i,
                    Business[i][bName],
                    Business[i][bOwner],
                    Business[i][bEntranceX],
                    Business[i][bEntranceY],
                    Business[i][bEntranceZ],
                    Business[i][bPrice],
                    Business[i][bProfitPerHour]
                );
                fwrite(file, string);
            }
        }
        fclose(file);
    }
    return 1;
}

// ���������� ������� ��������
forward UpdateBusinessProfits();
public UpdateBusinessProfits()
{
    new currentTime = gettime();

    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists] || !strcmp(Business[i][bOwner], "None", true))
            continue;

        // ���������, ������ �� ��� � ��������� �������
        if(currentTime - Business[i][bLastProfit] >= 3600)
        {
            new targetid = INVALID_PLAYER_ID;
            foreach(new playerid : Player)
            {
                new name[MAX_PLAYER_NAME];
                GetPlayerName(playerid, name, sizeof(name));
                if(!strcmp(name, Business[i][bOwner], true))
                {
                    targetid = playerid;
                    break;
                }
            }

            if(targetid != INVALID_PLAYER_ID)
            {
                new profit = Business[i][bProfitPerHour];
                new tax = (profit * DEFAULT_TAX_RATE) / 100;
                new finalProfit = profit - tax;

                GivePlayerMoney(targetid, finalProfit);

                new string[128];
                format(string, sizeof(string), "��� ������ '%s' ������ ������� $%d (�����: $%d)",
                    Business[i][bName], finalProfit, tax);
                SendClientMessage(targetid, 0x00FF00AA, string);

                Business[i][bLastProfit] = currentTime;
            }
        }
    }
}

// ������� ������� �������
CMD:buybiz(playerid, params[])
{
    new bizID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, Business[i][bEntranceX], Business[i][bEntranceY], Business[i][bEntranceZ]))
        {
            bizID = i;
            break;
        }
    }

    if(bizID == -1)
        return SendClientMessage(playerid, 0xFF0000AA, "�� ������ ���������� ����� � ��������.");

    if(strcmp(Business[bizID][bOwner], "None", true))
        return SendClientMessage(playerid, 0xFF0000AA, "���� ������ ��� ����� ���������.");

    if(GetPlayerMoney(playerid) < Business[bizID][bPrice])
        return SendClientMessage(playerid, 0xFF0000AA, "� ��� ������������ �����.");

    // ���������, ��� �� � ������ ��� �������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, sizeof(name));
        if(!strcmp(Business[i][bOwner], name, true))
            return SendClientMessage(playerid, 0xFF0000AA, "� ��� ��� ���� ������.");
    }

    // ������� �������
    GivePlayerMoney(playerid, -Business[bizID][bPrice]);
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(Business[bizID][bOwner], MAX_PLAYER_NAME, name);

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "%s\n��������: %s\n�������: $%d/���",
        Business[bizID][bName],
        Business[bizID][bOwner],
        Business[bizID][bProfitPerHour]
    );
    Update3DTextLabelText(Business[bizID][bLabel], 0xFFFF00AA, label);

    SaveBusinesses();

    new string[128];
    format(string, sizeof(string), "�� ������ ������ '%s' �� $%d", Business[bizID][bName], Business[bizID][bPrice]);
    SendClientMessage(playerid, 0x00FF00AA, string);

    return 1;
}

// ������� ������� ������� �����������
CMD:sellbiz(playerid, params[])
{
    new bizID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, Business[i][bEntranceX], Business[i][bEntranceY], Business[i][bEntranceZ]))
        {
            bizID = i;
            break;
        }
    }

    if(bizID == -1)
        return SendClientMessage(playerid, 0xFF0000AA, "�� ������ ���������� ����� � ��������.");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(Business[bizID][bOwner], name, true))
        return SendClientMessage(playerid, 0xFF0000AA, "�� �� �������� ���� ��������.");

    new sellPrice = (Business[bizID][bPrice] * 20) / 100; // 80% �� ��������� ����
    GivePlayerMoney(playerid, sellPrice);
    format(Business[bizID][bOwner], MAX_PLAYER_NAME, "None");

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "%s\n����: $%d\n�������: $%d/���\n������� /buybiz ��� �������",
        Business[bizID][bName],
        Business[bizID][bPrice],
        Business[bizID][bProfitPerHour]
    );
    Update3DTextLabelText(Business[bizID][bLabel], 0xFFFF00AA, label);

    SaveBusinesses();

    new string[128];
    format(string, sizeof(string), "�� ������� ������ '%s' ����������� �� $%d", Business[bizID][bName], sellPrice);
    SendClientMessage(playerid, 0x00FF00AA, string);

    return 1;
}
// ������� ������� ������� ������� ������
CMD:sellbizto(playerid, params[])
{
    new targetid, price;
    if(sscanf(params, "ud", targetid, price))
        return SendClientMessage(playerid, 0xFF0000AA, "�������������: /sellbizto [ID ������] [����]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, 0xFF0000AA, "����� �� ������.");

    if(price < 1)
        return SendClientMessage(playerid, 0xFF0000AA, "������������ ����.");

    new bizID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, Business[i][bEntranceX], Business[i][bEntranceY], Business[i][bEntranceZ]))
        {
            bizID = i;
            break;
        }
    }

    if(bizID == -1)
        return SendClientMessage(playerid, 0xFF0000AA, "�� ������ ���������� ����� � ��������.");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(Business[bizID][bOwner], name, true))
        return SendClientMessage(playerid, 0xFF0000AA, "�� �� �������� ���� ��������.");

    // ���������, ��� �� � ���������� ��� �������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        new targetName[MAX_PLAYER_NAME];
        GetPlayerName(targetid, targetName, sizeof(targetName));
        if(!strcmp(Business[i][bOwner], targetName, true))
            return SendClientMessage(playerid, 0xFF0000AA, "� ����� ������ ��� ���� ������.");
    }

    if(GetPlayerMoney(targetid) < price)
        return SendClientMessage(playerid, 0xFF0000AA, "� ���������� ������������ �����.");

    // ���������� ����������� ����������
    new string[128];
    format(string, sizeof(string), "����� %s ���������� ������ ������ '%s' �� $%d", name, Business[bizID][bName], price);
    ShowPlayerDialog(targetid, DIALOG_BUY_BUSINESS, DIALOG_STYLE_MSGBOX, "������� �������",
        string, "������", "����������");

    // ��������� ���������� � �����������
    SetPVarInt(targetid, "OfferedBusiness_ID", bizID);
    SetPVarInt(targetid, "OfferedBusiness_Price", price);
    SetPVarInt(targetid, "OfferedBusiness_Seller", playerid);

    format(string, sizeof(string), "�� ���������� ������ %s ������ ��� ������ �� $%d",
        ReturnPlayerName(targetid), price);
    SendClientMessage(playerid, 0x00FF00AA, string);

    return 1;
}
// ������� ��������� ���������� � �������
CMD:biz(playerid, params[])
{
    new bizID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ������
    for(new i = 0; i < MAX_BUSINESSES; i++)
    {
        if(!Business[i][bExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, Business[i][bEntranceX], Business[i][bEntranceY], Business[i][bEntranceZ]))
        {
            bizID = i;
            break;
        }
    }

    if(bizID == -1)
        return SendClientMessage(playerid, 0xFF0000AA, "�� ������ ���������� ����� � ��������.");

    new string[512];
    format(string, sizeof(string), "\
        {FFFFFF}��������: %s\n\
        ��������: %s\n\
        ������� � ���: $%d\n\
        �����: %d%%\n\
        ������ ������� � ���: $%d",
        Business[bizID][bName],
        Business[bizID][bOwner],
        Business[bizID][bProfitPerHour],
        DEFAULT_TAX_RATE,
        (Business[bizID][bProfitPerHour] * (100 - DEFAULT_TAX_RATE)) / 100
    );

    ShowPlayerDialog(playerid, DIALOG_SHOW_BUSINESS, DIALOG_STYLE_MSGBOX, "���������� � �������", string, "�������", "");
    return 1;
}

// ��������������� ������� ��� ��������� ����� ������
stock ReturnPlayerName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

CMD:biztp(playerid, params[])
{
    // ���������, �������� �� ����� ���������������
    if(Player[playerid][pAdminLevel] < 1) // ������ �������� ������� �������
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������!");

    new bizID;
    if(sscanf(params, "d", bizID))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /biztp [ID ������� (1-100)]");

    // ��������� ���������� ID �������
    if(bizID < 1 || bizID >= MAX_BUSINESSES)
        return SendClientMessage(playerid, COLOR_RED, "�������� ID �������! ��������� ID: 1-100");

    // ��������� ������������� �������
    if(!Business[bizID][bExists])
        return SendClientMessage(playerid, COLOR_RED, "������ � ����� ID �� ����������!");

    // ������������� ������
    SetPlayerPos(playerid, Business[bizID][bEntranceX], Business[bizID][bEntranceY], Business[bizID][bEntranceZ]);

    // ���������� ���������
    new string[128];
    format(string, sizeof(string), "�� ����������������� � ������� \"%s\" (ID: %d)",
        Business[bizID][bName], bizID);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

CMD:bizlist(playerid, params[])
{
    new count = 0;
    SendClientMessage(playerid, COLOR_GREEN, "������ ��������� ��������:");

    for(new i = 1; i < MAX_BUSINESSES; i++)
    {
        if(Business[i][bExists] && !strcmp(Business[i][bOwner], "None", true))
        {
            count++;
            new string[128];
            format(string, sizeof(string), "ID: %d | %s | ����: $%d | �������: $%d/���",
                i, Business[i][bName], Business[i][bPrice], Business[i][bProfitPerHour]);
            SendClientMessage(playerid, COLOR_WHITE, string);

            // ������ ����� ������ 10 ��������, ����� �� ������� ���
            if(count % 10 == 0)
            {
                SendClientMessage(playerid, COLOR_YELLOW, "--- �������� ��������� ---");
            }
        }
    }

    if(count == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "��� ��������� ��������!");
    }
    else
    {
        new string[64];
        format(string, sizeof(string), "����� ������� ��������� ��������: %d", count);
        SendClientMessage(playerid, COLOR_GREEN, string);
        SendClientMessage(playerid, COLOR_YELLOW, "����������� /findbiz [ID] ��� ������������ � ����������� �������");
    }

    return 1;
}

// ������������� �����
InitHouses()
{
    // ��� 1
    House[0][hExists] = true;
    format(House[0][hOwner], MAX_PLAYER_NAME, "None");
    House[0][hEntranceX] = 2486.3999;
    House[0][hEntranceY] = -1645.1;
    House[0][hEntranceZ] = 14.1;
    House[0][hExitX] = 223.10001;
    House[0][hExitY] = 1286.8;
    House[0][hExitZ] = 1082.1;
    House[0][hSpawnX] = 2486.6001;
    House[0][hSpawnY] = -1647.9;
    House[0][hSpawnZ] = 14.1;
    House[0][hSpawnInteriorX] = 223.39999;
    House[0][hSpawnInteriorY] = 1289.7;
    House[0][hSpawnInteriorZ] = 1082.1;
    House[0][hPrice] = 150000;
    House[0][hLocked] = true;
    House[0][hInteriorID] = 1;
    House[0][hLastTax] = gettime();

    // ��� 2
    House[1][hExists] = true;
    format(House[1][hOwner], MAX_PLAYER_NAME, "None");
    House[1][hEntranceX] = 2498.5;
    House[1][hEntranceY] = -1642.1;
    House[1][hEntranceZ] = 14.1;
    House[1][hExitX] = 223.2;
    House[1][hExitY] = 1286.7;
    House[1][hExitZ] = 1093.9;
    House[1][hSpawnX] = 2498.3;
    House[1][hSpawnY] = -1644.5;
    House[1][hSpawnZ] = 13.8;
    House[1][hSpawnInteriorX] = 222.8;
    House[1][hSpawnInteriorY] = 1288.7;
    House[1][hSpawnInteriorZ] = 1093.9;
    House[1][hPrice] = 150000;
    House[1][hLocked] = true;
    House[1][hInteriorID] = 1;
    House[1][hLastTax] = gettime();

    // ������� ������ � 3D ������ ��� �����
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(House[i][hExists])
        {
            House[i][hPickup] = CreatePickup(1273, 1, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ], -1);

            new label[256];
            if(!strcmp(House[i][hOwner], "None", true))
            {
                format(label, sizeof(label), "��� ��� �������\n����: $%d\n�����: $%d/���\n������� /buyhouse ��� �������",
                    House[i][hPrice], HOUSE_TAX_RATE);
            }
            else
            {
                format(label, sizeof(label), "���\n��������: %s\n%s",
                    House[i][hOwner], House[i][hLocked] ? "������" : "������");
            }
            House[i][hLabel] = Create3DTextLabel(label, 0xFFFFFFAA,
                House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ] + 0.5,
                20.0, 0, 1);
        }
    }
}

// ���������� ����� � ����
SaveHouses()
{
    new File:file = fopen("house_owners.cfg", io_write);
    if(file)
    {
        new string[256];
        for(new i = 0; i < MAX_HOUSES; i++)
        {
            if(House[i][hExists])
            {
                format(string, sizeof(string), "%d|%s|%d|%d|%d|%d\n",
                    i,
                    House[i][hOwner],
                    House[i][hLocked],
                    House[i][hLastTax],
                    House[i][hOwned],
                    House[i][hVirtualWorld]
                );
                fwrite(file, string);
            }
        }
        fclose(file);
    }
    return 1;
}

// �������� ����� �� �����
LoadHouses()
{
    printf("Starting house loading...");

    // ������� ��� ������������ ���� ����� ���������
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(House[i][hExists])
        {
            if(IsValidDynamic3DTextLabel(House[i][hLabel]))
                DestroyDynamic3DTextLabel(House[i][hLabel]);

            if(IsValidDynamicPickup(House[i][hPickup]))
                DestroyDynamicPickup(House[i][hPickup]);
        }
        House[i][hExists] = false;
    }

    new File:file = fopen("houses.cfg", io_read);
    if(file)
    {
        new line[256];
        while(fread(file, line))
        {
            // ���������� ����������� � ������ ������
            if(line[0] == '/' || line[0] == '\n' || line[0] == '\r' || !line[0])
            {
                printf("Skipping line: %s", line);
                continue;
            }

            printf("Processing line: %s", line);

            new houseId;
            new Float:entranceX, Float:entranceY, Float:entranceZ;
            new Float:spawnX, Float:spawnY, Float:spawnZ;
            new Float:intSpawnX, Float:intSpawnY, Float:intSpawnZ;
            new Float:exitX, Float:exitY, Float:exitZ;
            new price, interior, dimension;

            // ��������� ������ �� �����
            new tmp[8][128];
            if(sscanf(line, "p<|>ds[128]s[128]s[128]s[128]ddd",
                houseId,
                tmp[0], // entrance coords
                tmp[1], // spawn coords
                tmp[2], // interior spawn coords
                tmp[3], // exit coords
                price,
                interior,
                dimension))
            {
                printf("Failed to parse main data from line");
                continue;
            }

            // ������ ���������� �����
            if(sscanf(tmp[0], "p<,>fff", entranceX, entranceY, entranceZ))
            {
                printf("Failed to parse entrance coordinates");
                continue;
            }

            // ������ ���������� ������
            if(sscanf(tmp[1], "p<,>fff", spawnX, spawnY, spawnZ))
            {
                printf("Failed to parse spawn coordinates");
                continue;
            }

            // ������ ���������� ����������� ������
            if(sscanf(tmp[2], "p<,>fff", intSpawnX, intSpawnY, intSpawnZ))
            {
                printf("Failed to parse interior spawn coordinates");
                continue;
            }

            // ������ ���������� ������
            if(sscanf(tmp[3], "p<,>fff", exitX, exitY, exitZ))
            {
                printf("Failed to parse exit coordinates");
                continue;
            }

            printf("Successfully parsed house data: ID=%d, Price=%d", houseId, price);

            if(houseId >= 0 && houseId < MAX_HOUSES)
            {
                House[houseId][hExists] = true;
                format(House[houseId][hOwner], MAX_PLAYER_NAME, "None");
                House[houseId][hEntranceX] = entranceX;
                House[houseId][hEntranceY] = entranceY;
                House[houseId][hEntranceZ] = entranceZ;
                House[houseId][hSpawnX] = spawnX;
                House[houseId][hSpawnY] = spawnY;
                House[houseId][hSpawnZ] = spawnZ;
                House[houseId][hSpawnInteriorX] = intSpawnX;
                House[houseId][hSpawnInteriorY] = intSpawnY;
                House[houseId][hSpawnInteriorZ] = intSpawnZ;
                House[houseId][hExitX] = exitX;
                House[houseId][hExitY] = exitY;
                House[houseId][hExitZ] = exitZ;
                House[houseId][hPrice] = price;
                House[houseId][hInteriorID] = interior;
                House[houseId][hVirtualWorld] = dimension;
                House[houseId][hLocked] = true;
                House[houseId][hLastTax] = gettime();
                House[houseId][hOwned] = false;

		        // ������� ����� ��� �����
		        House[houseId][hPickup] = CreatePickup(1273, 1, entranceX, entranceY, entranceZ, -1);

		        // ������� 3D �����
		        new label[256];
		        format(label, sizeof(label), "���\n������: ���������\n����: $%d\n�����: $%d/���\n������� /buyhouse ��� �������",
		            price, HOUSE_TAX_RATE);
		        House[houseId][hLabel] = Create3DTextLabel(label, 0xFFFFFFAA,
		            entranceX, entranceY, entranceZ + 0.5,
		            20.0, 0, 1);

		        // ������� ����� ��� ������ � ��������� � ������������ ����
		        CreatePickup(1318, 1, exitX, exitY, exitZ, houseId + 1); // ����� ����� ��������� virtualworld

		        printf("Created house %d with pickups and label", houseId);
		    }
        }
        fclose(file);
        printf("Finished loading houses");
    }
    else
    {
        printf("Failed to open houses.cfg for reading");
    }

    LoadHouseOwners();
    return 1;
}

// ���������� ���������� � ���������� �����
LoadHouseOwners()
{
    new File:file = fopen("house_owners.cfg", io_read);
    if(file)
    {
        new line[256];
        new houseId;
        new owner[MAX_PLAYER_NAME];
        new bool:locked;
        new lastTax;
        new bool:owned;
        new virtualWorld;

        while(fread(file, line))
        {
            if(sscanf(line, "p<|>ds[24]dddd",
                houseId, owner, locked, lastTax, owned, virtualWorld))
            {
                continue;
            }

            if(houseId >= 0 && houseId < MAX_HOUSES && House[houseId][hExists])
            {
                format(House[houseId][hOwner], MAX_PLAYER_NAME, owner);
                House[houseId][hLocked] = bool:locked;
                House[houseId][hLastTax] = lastTax;
                House[houseId][hOwned] = bool:owned;
                House[houseId][hVirtualWorld] = virtualWorld;

                // ��������� 3D �����
                if(owned)
                {
                    new label[256];
                    format(label, sizeof(label), "���\n��������: %s\n%s",
                        owner, locked ? "������" : "������");
                    Update3DTextLabelText(House[houseId][hLabel], 0xFFFFFFAA, label);
                }
            }
        }
        fclose(file);
    }
    return 1;
}

// ������� ��� �������� ������� �� ����
forward CheckHouseTaxes();
public CheckHouseTaxes()
{
    new currentTime = gettime();

    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists] || !strcmp(House[i][hOwner], "None", true))
            continue;

        if(currentTime - House[i][hLastTax] >= 3600) // ������ ���
        {
            new targetid = INVALID_PLAYER_ID;
            foreach(new playerid : Player)
            {
                new name[MAX_PLAYER_NAME];
                GetPlayerName(playerid, name, sizeof(name));
                if(!strcmp(name, House[i][hOwner], true))
                {
                    targetid = playerid;
                    break;
                }
            }

            if(targetid != INVALID_PLAYER_ID)
            {
                if(GetPlayerMoney(targetid) >= HOUSE_TAX_RATE)
                {
                    GivePlayerMoney(targetid, -HOUSE_TAX_RATE);
                    House[i][hLastTax] = currentTime;

                    new string[128];
                    format(string, sizeof(string), "� ������ ����� ������ ����� �� ��� � ������� $%d", HOUSE_TAX_RATE);
                    SendClientMessage(targetid, COLOR_YELLOW, string);
                }
                else
                {
                    // ���� ��� ����� �� ������ - ��� ��������� �����������
                    format(House[i][hOwner], MAX_PLAYER_NAME, "None");
                    House[i][hLocked] = true;

                    new string[128];
                    format(string, sizeof(string), "��� ��� ������ ����������� ��-�� �������� ������ ($%d)", HOUSE_TAX_RATE);
                    SendClientMessage(targetid, COLOR_RED, string);

                    // ��������� 3D �����
                    new label[256];
                    format(label, sizeof(label), "��� ��� �������\n����: $%d\n�����: $%d/���\n������� /buyhouse ��� �������",
                        House[i][hPrice], HOUSE_TAX_RATE);
                    Update3DTextLabelText(House[i][hLabel], 0xFFFFFFAA, label);
                }
            }
        }
    }
    SaveHouses();
}

// ������� ������� ����
CMD:buyhouse(playerid, params[])
{
    new houseID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ���
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ]))
        {
            houseID = i;
            break;
        }
    }

    if(houseID == -1)
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � �����.");

    if(strcmp(House[houseID][hOwner], "None", true))
        return SendClientMessage(playerid, COLOR_RED, "���� ��� ��� ����� ���������.");

    if(GetPlayerMoney(playerid) < House[houseID][hPrice])
        return SendClientMessage(playerid, COLOR_RED, "� ��� ������������ �����.");

    // ���������, ��� �� � ������ ��� ����
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;
        if(!strcmp(House[i][hOwner], name, true))
            return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���� ���.");
    }

    // ������� ����
    GivePlayerMoney(playerid, -House[houseID][hPrice]);
    format(House[houseID][hOwner], MAX_PLAYER_NAME, name);
    House[houseID][hLocked] = true;
    House[houseID][hLastTax] = gettime();

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "���\n��������: %s\n%s",
        House[houseID][hOwner], House[houseID][hLocked] ? "������" : "������");
    Update3DTextLabelText(House[houseID][hLabel], 0xFFFFFFAA, label);

    SaveHouses();

    new string[128];
    format(string, sizeof(string), "�� ������ ��� �� $%d", House[houseID][hPrice]);
    SendClientMessage(playerid, COLOR_GREEN, string);
    SendClientMessage(playerid, COLOR_YELLOW, "����������� /hlock ��� ��������/�������� ���� � /hinfo ��� ��������� ����������.");

    return 1;
}

// ������� ������� ���� �����������
CMD:sellhouse(playerid, params[])
{
    new houseID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ���
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ]))
        {
            houseID = i;
            break;
        }
    }

    if(houseID == -1)
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � �����.");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(House[houseID][hOwner], name, true))
        return SendClientMessage(playerid, COLOR_RED, "�� �� �������� ���� �����.");

    new sellPrice = (House[houseID][hPrice] * 20) / 100; // 20% �� ��������� ����
    GivePlayerMoney(playerid, sellPrice);
    format(House[houseID][hOwner], MAX_PLAYER_NAME, "None");
    House[houseID][hLocked] = true;

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "��� ��� �������\n����: $%d\n�����: $%d/���\n������� /buyhouse ��� �������",
        House[houseID][hPrice], HOUSE_TAX_RATE);
    Update3DTextLabelText(House[houseID][hLabel], 0xFFFFFFAA, label);

    SaveHouses();

    new string[128];
    format(string, sizeof(string), "�� ������� ��� ����������� �� $%d", sellPrice);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

// ������� ������� ���� ������� ������
CMD:sellhouseto(playerid, params[])
{
    new targetid, price;
    if(sscanf(params, "ud", targetid, price))
        return SendClientMessage(playerid, COLOR_RED, "�������������: /sellhouseto [ID ������] [����]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    if(price < 1)
        return SendClientMessage(playerid, COLOR_RED, "������������ ����.");

    new houseID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ���
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ]))
        {
            houseID = i;
            break;
        }
    }

    if(houseID == -1)
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � �����.");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(House[houseID][hOwner], name, true))
        return SendClientMessage(playerid, COLOR_RED, "�� �� �������� ���� �����.");

    // ���������, ��� �� � ���������� ��� ����
    new targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;
        if(!strcmp(House[i][hOwner], targetName, true))
            return SendClientMessage(playerid, COLOR_RED, "� ����� ������ ��� ���� ���.");
    }

    if(GetPlayerMoney(targetid) < price)
        return SendClientMessage(playerid, COLOR_RED, "� ���������� ������������ �����.");

    // ��������� ������
    GivePlayerMoney(targetid, -price);
    GivePlayerMoney(playerid, price);
    format(House[houseID][hOwner], MAX_PLAYER_NAME, targetName);
    House[houseID][hLocked] = true;
    House[houseID][hLastTax] = gettime();

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "���\n��������: %s\n%s",
        House[houseID][hOwner], House[houseID][hLocked] ? "������" : "������");
    Update3DTextLabelText(House[houseID][hLabel], 0xFFFFFFAA, label);

    SaveHouses();

    new string[128];
    format(string, sizeof(string), "�� ������� ��� ������ %s �� $%d", targetName, price);
    SendClientMessage(playerid, COLOR_GREEN, string);
    format(string, sizeof(string), "�� ������ ��� � ������ %s �� $%d", name, price);
    SendClientMessage(targetid, COLOR_GREEN, string);
    SendClientMessage(targetid, COLOR_YELLOW, "����������� /hlock ��� ��������/�������� ���� � /hinfo ��� ��������� ����������.");

    return 1;
}

// ������� ��������/�������� ����
CMD:hlock(playerid, params[])
{
    new houseID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ���
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ]))
        {
            houseID = i;
            break;
        }
    }

    if(houseID == -1)
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � �����.");

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(House[houseID][hOwner], name, true))
        return SendClientMessage(playerid, COLOR_RED, "�� �� �������� ���� �����.");

    House[houseID][hLocked] = !House[houseID][hLocked];

    // ��������� 3D �����
    new label[256];
    format(label, sizeof(label), "���\n��������: %s\n%s",
        House[houseID][hOwner], House[houseID][hLocked] ? "������" : "������");
    Update3DTextLabelText(House[houseID][hLabel], 0xFFFFFFAA, label);

    SaveHouses();

    new string[128];
    format(string, sizeof(string), "�� %s ���", House[houseID][hLocked] ? "�������" : "�������");
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

// ������� ��������� ���������� � ����
CMD:houseinfo(playerid, params[])
{
    new houseID = -1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // ������� ��������� ���
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(!House[i][hExists]) continue;

        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hEntranceX], House[i][hEntranceY], House[i][hEntranceZ]))
        {
            houseID = i;
            break;
        }
    }

    if(houseID == -1)
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � �����.");

    new string[256];
    if(!strcmp(House[houseID][hOwner], "None", true))
    {
        format(string, sizeof(string), "���������� � ����:\n������: ���������\n����: $%d\n�����: $%d/���",
            House[houseID][hPrice], HOUSE_TAX_RATE);
    }
    else
    {
        format(string, sizeof(string), "���������� � ����:\n��������: %s\n������: %s\n�����: $%d/���",
            House[houseID][hOwner], House[houseID][hLocked] ? "������" : "������", HOUSE_TAX_RATE);
    }

    ShowPlayerDialog(playerid, DIALOG_HOUSE_INFO, DIALOG_STYLE_MSGBOX, "���������� � ����", string, "�������", "");

    return 1;
}

CMD:tphouse(playerid, params[])
{
    // ���������, �������� �� ����� ���������������
    if(Player[playerid][pAdminLevel] < 1) // ����������� ������� ������
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������!");

    new houseID;
    if(sscanf(params, "d", houseID))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /tphouse [ID ���� (0-99)]");

    // ��������� ���������� ID ����
    if(houseID < 0 || houseID >= MAX_HOUSES)
        return SendClientMessage(playerid, COLOR_RED, "�������� ID ����! ��������� ID: 0-99");

    // ��������� ������������� ����
    if(!House[houseID][hExists])
        return SendClientMessage(playerid, COLOR_RED, "��� � ����� ID �� ����������!");

    // ������������� ������
    SetPlayerPos(playerid, House[houseID][hEntranceX], House[houseID][hEntranceY], House[houseID][hEntranceZ]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    // ���������� ���������
    new string[128];
    format(string, sizeof(string), "�� ����������������� � ���� ID: %d (��������: %s)",
        houseID, House[houseID][hOwner]);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

CMD:givemoney(playerid, params[])
{
    // �������� ���� �������������� (������� 2 �������)
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /givemoney [ID ������] [�����]");

    // ���������, ��������� �� �����
    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    // ��������� ������������ �����
    if(amount <= 0)
        return SendClientMessage(playerid, COLOR_RED, "����� ������ ���� ������ 0!");

    // ������ ������
    GivePlayerMoney(targetid, amount);

    // ���������
    new string[128], adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    // ��������� ��������������
    format(string, sizeof(string), "�� ������ ������ %s ����� $%d", targetName, amount);
    SendClientMessage(playerid, COLOR_GREEN, string);

    // ��������� ������
    format(string, sizeof(string), "������������� %s ����� ��� $%d", adminName, amount);
    SendClientMessage(targetid, COLOR_GREEN, string);

    // ��� ��� ������ ���������������
    format(string, sizeof(string), "������������� %s ����� ������ %s ����� $%d", adminName, targetName, amount);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdminLevel] >= 1 && i != playerid)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    return 1;
}

CMD:respawn(playerid, params[])
{
    // �������� ���� ��������������
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /respawn [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    if(!PlayerIsDying[targetid])
        return SendClientMessage(playerid, COLOR_RED, "����� �� ��������� � ����������.");

    // ��������������� ������
    if(PlayerDeathTimer[targetid] != -1)
    {
        KillTimer(PlayerDeathTimer[targetid]);
        PlayerDeathTimer[targetid] = -1;
    }

    PlayerIsDying[targetid] = false;
    ClearAnimations(targetid);
    SetPlayerHealth(targetid, 50); // ���� �������� ��������
    TogglePlayerControllable(targetid, 1);
    SetCameraBehindPlayer(targetid);

    // ��������������� ����������� ����
    SetPlayerSkin(targetid, PlayerSkins[targetid]);

    // ���������
    new string[128], adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "������������� %s ������������ ���", adminName);
    SendClientMessage(targetid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� ������������� ������ %s", targetName);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

CMD:spawn(playerid, params[])
{
    // �������� ���� ��������������
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /spawn [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    // ���������� ����� ������ � ����������� �� �������
    if(Player[targetid][pFaction] == FACTION_LSPD)
    {
        SetPlayerPos(targetid, gLSPDSpawn[0], gLSPDSpawn[1], gLSPDSpawn[2]);
        SetPlayerFacingAngle(targetid, gLSPDSpawn[3]);
        SetPlayerInterior(targetid, 6);
    }
    else if(Player[targetid][pFaction] == FACTION_FBI)
    {
        SetPlayerPos(targetid, gFBISpawn[0], gFBISpawn[1], gFBISpawn[2]);
        SetPlayerFacingAngle(targetid, gFBISpawn[3]);
        SetPlayerInterior(targetid, 1);
    }
    else if(Player[targetid][pFaction] == FACTION_EMS)
    {
        SetPlayerPos(targetid, gEMSSpawn[0], gEMSSpawn[1], gEMSSpawn[2]);
        SetPlayerFacingAngle(targetid, gEMSSpawn[3]);
        SetPlayerInterior(targetid, 1);
    }
    else if(Player[targetid][pFaction] == FACTION_SHERIFF)
    {
        SetPlayerPos(targetid, gSheriffSpawn[0], gSheriffSpawn[1], gSheriffSpawn[2]);
        SetPlayerFacingAngle(targetid, gSheriffSpawn[3]);
        SetPlayerInterior(targetid, 6);
        SetPlayerVirtualWorld(targetid, VIRTUAL_WORLD_SHERIFF);
    }
    else if(Player[targetid][pFaction] == FACTION_GROVE)
    {
        SetPlayerPos(targetid, gGroveSpawn[0], gGroveSpawn[1], gGroveSpawn[2]);
        SetPlayerFacingAngle(targetid, gGroveSpawn[3]);
        SetPlayerInterior(targetid, 3);
    }
    else
    {
        // ���������, ���� �� � ������ ���
        new bool:hasHouse = false;
        new houseID = -1;
        new name[MAX_PLAYER_NAME];
        GetPlayerName(targetid, name, sizeof(name));

        for(new i = 0; i < MAX_HOUSES; i++)
        {
            if(House[i][hExists] && !strcmp(House[i][hOwner], name, true))
            {
                hasHouse = true;
                houseID = i;
                break;
            }
        }

        if(hasHouse)
        {
            SetPlayerPos(targetid, House[houseID][hSpawnX], House[houseID][hSpawnY], House[houseID][hSpawnZ]);
            SetPlayerInterior(targetid, 0);
            SetPlayerVirtualWorld(targetid, 0);
        }
        else
        {
            // ��������� ����� ��� ������� �������
            SetPlayerPos(targetid, 1685.7, -2335.7, 13.5);
            SetPlayerFacingAngle(targetid, 0.003);
            SetPlayerInterior(targetid, 0);
            SetPlayerVirtualWorld(targetid, 0);
        }
    }

    // ��������������� ��������
    SetPlayerHealth(targetid, 100);

    // ���������
    new string[128], adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "������������� %s �������������� ��� �� �����", adminName);
    SendClientMessage(targetid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� ��������������� ������ %s �� �����", targetName);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

CMD:sethp(playerid, params[])
{
    // �������� ���� ��������������
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    new targetid, Float:amount;
    if(sscanf(params, "uf", targetid, amount))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /sethp [ID ������] [���������� ��������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    // ��������� ������������ �������� �������� (�� 0 �� 100)
    if(amount < 0.0 || amount > 100.0)
        return SendClientMessage(playerid, COLOR_RED, "���������� �������� ������ ���� �� 0 �� 100!");

    // ������������� ��������
    SetPlayerHealth(targetid, amount);

    // ���� ����� ��� � ��������� ������, ������� ��� �� ����� ���������
    if(PlayerIsDying[targetid] && amount > 0)
    {
        PlayerIsDying[targetid] = false;
        if(PlayerDeathTimer[targetid] != -1)
        {
            KillTimer(PlayerDeathTimer[targetid]);
            PlayerDeathTimer[targetid] = -1;
        }
        ClearAnimations(targetid);
        TogglePlayerControllable(targetid, 1);
        SetCameraBehindPlayer(targetid);
    }

    // ���������
    new string[128], adminName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "������������� %s ��������� ��� �������� �� %.1f", adminName, amount);
    SendClientMessage(targetid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� ���������� ������ %s �������� �� %.1f", targetName, amount);
    SendClientMessage(playerid, COLOR_GREEN, string);

    // ��� ��� ������ ���������������
    format(string, sizeof(string), "������������� %s ��������� ������ %s �������� �� %.1f", adminName, targetName, amount);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdminLevel] >= 1 && i != playerid)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    return 1;
}
CMD:aveh(playerid, params[])
{
    // �������� ���� �������������� (������� 2 �������)
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    new model, color1 = -1, color2 = -1;
    if(sscanf(params, "iI(-1)I(-1)", model, color1, color2))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /aveh [ID ������] [����1] [����2]");

    // �������� ���������� ID ������ (400-611 - �������� ID ������������ �������)
    if(model < 400 || model > 611)
        return SendClientMessage(playerid, COLOR_RED, "������������ ID ������ ���������� (400-611)!");

    // �������� ������� ������
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, angle);

    // ������� ��������� ������� ������� ������
    x += (3.0 * floatsin(-angle, degrees));
    y += (3.0 * floatcos(-angle, degrees));

    // ������� ������������ ��������
    new vehicleid = CreateVehicle(model, x, y, z + 1.0, angle, color1, color2, -1);

    // ������������� ������ ���
    VehicleFuel[vehicleid] = MAX_FUEL;

    // ������� �������� ����
    new plate[32], adminName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    format(plate, sizeof(plate), "ADMIN %d", vehicleid);
    SetVehicleNumberPlate(vehicleid, plate);

    // ���������
    new string[128];
    format(string, sizeof(string), "�� ������� ������������ �������� (Model ID: %d, Vehicle ID: %d)", model, vehicleid);
    SendClientMessage(playerid, COLOR_GREEN, string);

    // ��� ��� ������ ���������������
    format(string, sizeof(string), "������������� %s ������ ��������� ID: %d (Model: %d)", adminName, vehicleid, model);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdminLevel] >= 1 && i != playerid)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    return 1;
}

// �������� ����������� �� �����
LoadDealerships()
{
    if(!fexist("dealerships.cfg"))
    {
        new File:file = fopen("dealerships.cfg", io_write);
        if(file)
        {
            new string[256];

            // Premium
            format(string, sizeof(string), "1|Premium|�������� ���� ����|566.0|-1293.9|17.2|0.003|189|566.0|-1293.3|17.2|557.20001|-1266.8|17.1|0.0\n");
            fwrite(file, string);

            // Medium
            format(string, sizeof(string), "2|Medium|�������� �������� ������|338.0|-1816.0|4.3|0.0|242|338.0|-1815.5|4.3|349.20001|-1791.3|4.8|0.0\n");
            fwrite(file, string);

            // Economy
            format(string, sizeof(string), "3|Economy|�������� ������ ������|1993.9|-2057.0|13.4|100.003|94|1993.8|-2057.1001|13.4|1977.1|-2057.8999|13.2|90.0\n");
            fwrite(file, string);

            // Helicopter
            format(string, sizeof(string), "4|Helicopter|�������� ���������� ����������|1527.4|-2432.7|13.6|0.0|61|1527.5|-2433.3|13.6|1525.2002|-2467.7998|13.8|0.0\n");
            fwrite(file, string);

            // Moto
            format(string, sizeof(string), "5|Moto|�������� ����������|2133.7998|-1151.2002|24.1|0.003|247|2133.7|-1150.5|24.2|2127.1006|-1132.7998|25.2|0.0\n");
            fwrite(file, string);

            fclose(file);
        }
    }

    new File:file = fopen("dealerships.cfg", io_read);
    if(file)
    {
        new string[256];
        new idx, type, name[32];
        new Float:npcX, Float:npcY, Float:npcZ, Float:npcAngle;
        new npcSkin;
        new Float:menuX, Float:menuY, Float:menuZ;
        new Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnAngle;

        while(fread(file, string))
        {
            if(sscanf(string, "p<|>ds[32]ffffdffffff",
                idx, type, name,
                npcX, npcY, npcZ, npcAngle, npcSkin,
                menuX, menuY, menuZ,
                spawnX, spawnY, spawnZ, spawnAngle))
            {
                continue;
            }

            if(idx >= 1 && idx <= 5)
            {
                idx--; // ������������ ��� �������

                Dealership[idx][dExists] = true;
                Dealership[idx][dType] = type;
                format(Dealership[idx][dName], 32, name);

                Dealership[idx][dNPCX] = npcX;
                Dealership[idx][dNPCY] = npcY;
                Dealership[idx][dNPCZ] = npcZ;
                Dealership[idx][dNPCAngle] = npcAngle;
                Dealership[idx][dNPCSkin] = npcSkin;

                Dealership[idx][dMenuX] = menuX;
                Dealership[idx][dMenuY] = menuY;
                Dealership[idx][dMenuZ] = menuZ;

                Dealership[idx][dSpawnX] = spawnX;
                Dealership[idx][dSpawnY] = spawnY;
                Dealership[idx][dSpawnZ] = spawnZ;
                Dealership[idx][dSpawnAngle] = spawnAngle;

                // ������� NPC � �����
                Dealership[idx][dActor] = CreateActor(npcSkin, npcX, npcY, npcZ, npcAngle);
                Dealership[idx][dPickup] = CreatePickup(1239, 1, menuX, menuY, menuZ, -1);

                // ������� 3D �����
                new label[64];
                format(label, sizeof(label), "%s\n������� Y ��� �������", name);
                Dealership[idx][dLabel] = Create3DTextLabel(label, 0xFFFFFFAA,
                    npcX, npcY, npcZ + 0.5,
                    10.0, 0, 1);
            }
        }
        fclose(file);
    }
}

// �������� ���������� �� �����
LoadDealershipVehicles()
{
    if(!fexist("dealership_vehicles.cfg"))
    {
        new File:file = fopen("dealership_vehicles.cfg", io_write);
        if(file)
        {
            // ��� ���� �������� ����� � ����������� ���� �����
            // ������ ��� ������� ������:
            fwrite(file, "411|Infernus|12000000|1|Lamborghini Diablo\n");
            fwrite(file, "451|Turismo|13500000|1|Ferrari F40\n");
            // � ��� ����� ��� ���� �����
            fclose(file);
        }
    }

    new File:file = fopen("dealership_vehicles.cfg", io_read);
    if(file)
    {
        new string[128];
        new idx;

        while(fread(file, string) && idx < sizeof(DealershipVehicles))
        {
            new model, name[32], price, type, reallife[32];

            if(sscanf(string, "p<|>ds[32]dds[32]",
                model, name, price, type, reallife))
            {
                continue;
            }

            DealershipVehicles[idx][vExists] = true;
            DealershipVehicles[idx][vModel] = model;
            format(DealershipVehicles[idx][vName], 32, name);
            DealershipVehicles[idx][vPrice] = price;
            DealershipVehicles[idx][vDealershipType] = type;
            format(DealershipVehicles[idx][vRealLife], 32, reallife);

            idx++;
        }
        fclose(file);
    }
}

// �������� ���� ����������
ShowDealershipMenu(playerid, dealershipType)
{
    new string[2048], title[32], count;

    switch(dealershipType)
    {
        case DEALERSHIP_PREMIUM: format(title, sizeof(title), "������� ���������");
        case DEALERSHIP_MEDIUM: format(title, sizeof(title), "������� �����");
        case DEALERSHIP_ECONOMY: format(title, sizeof(title), "������ �����");
        case DEALERSHIP_MOTO: format(title, sizeof(title), "���������");
        case DEALERSHIP_HELI: format(title, sizeof(title), "���������");
    }

    for(new i = 0; i < sizeof(DealershipVehicles); i++)
    {
        if(!DealershipVehicles[i][vExists]) continue;
        if(DealershipVehicles[i][vDealershipType] != dealershipType) continue;

        format(string, sizeof(string), "%s%s (%s) - $%d\n",
            string,
            DealershipVehicles[i][vName],
            DealershipVehicles[i][vRealLife],
            DealershipVehicles[i][vPrice]
        );
        count++;
    }

    if(count == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "� ���� ���������� ��� ��������� �����������.");
        return;
    }

    SetPVarInt(playerid, "DealershipType", dealershipType);
    ShowPlayerDialog(playerid, DIALOG_DEALERSHIP, DIALOG_STYLE_LIST, title, string, "������", "������");
}


// ���������� ������� ����������
SaveOwnedVehicles(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    new filename[64];
    format(filename, sizeof(filename), "vehicles/%s.txt", name);
    new File:file = fopen(filename, io_write);

    if(file)
    {
        new string[128];
        for(new i = 0; i < 5; i++)
        {
            if(OwnedVehicle[playerid][i][ovExists] == true)
            {
                format(string, sizeof(string), "%d|%s|%f|%f|%f|%f\n",
                    OwnedVehicle[playerid][i][ovModel],
                    OwnedVehicle[playerid][i][ovOwner],
                    OwnedVehicle[playerid][i][ovParkX],
                    OwnedVehicle[playerid][i][ovParkY],
                    OwnedVehicle[playerid][i][ovParkZ],
                    OwnedVehicle[playerid][i][ovParkAngle]
                );
                fwrite(file, string);
            }
        }
        fclose(file);
    }
}

// ������������ ������� ��������
LoadOwnedVehicles(playerid)
{
    printf("DEBUG: Loading vehicles for player %d", playerid);

    // ������� ��� �����
    for(new i = 0; i < 5; i++)
    {
        OwnedVehicle[playerid][i][ovExists] = false;
        OwnedVehicle[playerid][i][ovModel] = 0;
        OwnedVehicle[playerid][i][ovVehicleID] = 0;
        OwnedVehicle[playerid][i][ovOwner][0] = 0;
    }

    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    // ������� ������� ��������� �� ��������� ����� ������������
    new userfile[128];
    format(userfile, sizeof(userfile), "Users/%s.ini", name);

    if(fexist(userfile))
    {
        printf("DEBUG: Loading from user file: %s", userfile);
        new File:file = fopen(userfile, io_read);
        if(file)
        {
            new string[256];
            while(fread(file, string))
            {
                new key[32], value[224];
                if(sscanf(string, "p<=>s[32]s[224]", key, value))
                    continue;

                if(!strcmp(key, "OwnedVehicles"))
                {
                    printf("DEBUG: Found OwnedVehicles data: %s", value);

                    new model;
                    new Float:x, Float:y, Float:z, Float:angle;

                    if(sscanf(value, "p<,>dffff", model, x, y, z, angle) == 5)
                    {
                        printf("DEBUG: Setting vehicle in slot 0 - Model: %d", model);
                        OwnedVehicle[playerid][0][ovExists] = true;
                        OwnedVehicle[playerid][0][ovModel] = model;
                        format(OwnedVehicle[playerid][0][ovOwner], MAX_PLAYER_NAME, name);
                        OwnedVehicle[playerid][0][ovParkX] = x;
                        OwnedVehicle[playerid][0][ovParkY] = y;
                        OwnedVehicle[playerid][0][ovParkZ] = z;
                        OwnedVehicle[playerid][0][ovParkAngle] = angle;
                        OwnedVehicle[playerid][0][ovVehicleID] = 0;

                        printf("DEBUG: Vehicle loaded - Exists: %d", _:OwnedVehicle[playerid][0][ovExists]);
                    }
                }
            }
            fclose(file);
        }
    }

    // ����� ��������� ��������� ���� � �����������
    new vehfile[64];
    format(vehfile, sizeof(vehfile), "vehicles/%s.txt", name);

    if(fexist(vehfile))
    {
        printf("DEBUG: Loading from vehicle file: %s", vehfile);
        new File:file = fopen(vehfile, io_read);
        if(file)
        {
            new string[128];
            new model;
            new owner[MAX_PLAYER_NAME];
            new Float:parkX, Float:parkY, Float:parkZ, Float:parkAngle;

            if(fread(file, string))
            {
                if(sscanf(string, "p<|>ds[24]ffff", model, owner, parkX, parkY, parkZ, parkAngle) == 6)
                {
                    printf("DEBUG: Setting vehicle in slot 0 from vehicle file - Model: %d", model);
                    OwnedVehicle[playerid][0][ovExists] = true;
                    OwnedVehicle[playerid][0][ovModel] = model;
                    format(OwnedVehicle[playerid][0][ovOwner], MAX_PLAYER_NAME, owner);
                    OwnedVehicle[playerid][0][ovParkX] = parkX;
                    OwnedVehicle[playerid][0][ovParkY] = parkY;
                    OwnedVehicle[playerid][0][ovParkZ] = parkZ;
                    OwnedVehicle[playerid][0][ovParkAngle] = parkAngle;
                    OwnedVehicle[playerid][0][ovVehicleID] = 0;
                }
            }
            fclose(file);
        }
    }

    // ��������� ����������� ������
    for(new i = 0; i < 5; i++)
    {
        printf("DEBUG: Slot %d after loading - Exists: %d, Model: %d, Owner: %s",
            i,
            _:OwnedVehicle[playerid][i][ovExists],
            OwnedVehicle[playerid][i][ovModel],
            OwnedVehicle[playerid][i][ovOwner]
        );
    }

    return 1;
}


// ������� �������� ���������� ������ � ����������
bool:IsPlayerInDealership(playerid, &dealershipType)
{
    // Premium
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 566.0, -1293.3, 17.2))
    {
        dealershipType = DEALERSHIP_PREMIUM;
        return true;
    }
    // Medium
    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 338.0, -1815.5, 4.3))
    {
        dealershipType = DEALERSHIP_MEDIUM;
        return true;
    }
    // Economy
    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1993.8, -2057.1001, 13.4))
    {
        dealershipType = DEALERSHIP_ECONOMY;
        return true;
    }
    // Helicopter
    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 1527.5, -2433.3, 13.6))
    {
        dealershipType = DEALERSHIP_HELI;
        return true;
    }
    // Moto
    else if(IsPlayerInRangeOfPoint(playerid, 3.0, 2133.7, -1150.5, 24.2))
    {
        dealershipType = DEALERSHIP_MOTO;
        return true;
    }
    return false;
}


CMD:vpark(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� � ����������!");

    new vehicleid = GetPlayerVehicleID(playerid);
    new slot = -1;

    // ���������, �������� �� ��� ������ ����������� ������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] && OwnedVehicle[playerid][i][ovVehicleID] == vehicleid)
        {
            slot = i;
            break;
        }
    }

    if(slot == -1)
        return SendClientMessage(playerid, COLOR_RED, "��� �� ��� ������ ���������!");

    // �������� ������� ���������� ����������
    new Float:x, Float:y, Float:z, Float:angle;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, angle);

    // ��������� ����� ���������� ��������
    OwnedVehicle[playerid][slot][ovParkX] = x;
    OwnedVehicle[playerid][slot][ovParkY] = y;
    OwnedVehicle[playerid][slot][ovParkZ] = z;
    OwnedVehicle[playerid][slot][ovParkAngle] = angle;

    // ��������� � ����
    SaveOwnedVehicles(playerid);

    SendClientMessage(playerid, COLOR_GREEN, "����� �������� ���������� ������� ���������!");
    return 1;
}

// ������� ��� ������� ���������� �����������
CMD:vsell(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� � ����������!");

    new vehicleid = GetPlayerVehicleID(playerid);
    new slot = -1;

    // ���������, �������� �� ��� ������ ����������� ������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] && OwnedVehicle[playerid][i][ovVehicleID] == vehicleid)
        {
            slot = i;
            break;
        }
    }

    if(slot == -1)
        return SendClientMessage(playerid, COLOR_RED, "��� �� ��� ������ ���������!");

    // ������� ���� ����������
    new price = 0;
    new model = OwnedVehicle[playerid][slot][ovModel];

    for(new i = 0; i < sizeof(DealershipVehicles); i++)
    {
        if(DealershipVehicles[i][vExists] && DealershipVehicles[i][vModel] == model)
        {
            price = (DealershipVehicles[i][vPrice] * 20) / 100; // 20% �� ��������� ����
            break;
        }
    }

    // ������� ���������
    DestroyVehicle(vehicleid);
    OwnedVehicle[playerid][slot][ovExists] = false;
    OwnedVehicle[playerid][slot][ovVehicleID] = 0;

    // ������ ������
    GivePlayerMoney(playerid, price);

    // ��������� ���������
    SaveOwnedVehicles(playerid);

    new string[128];
    format(string, sizeof(string), "�� ������� ��������� ����������� �� $%d", price);
    SendClientMessage(playerid, COLOR_GREEN, string);
    return 1;
}

// ������� ��� ������� ���������� ������� ������
CMD:vsellto(playerid, params[])
{
    new targetid, price;
    if(sscanf(params, "ud", targetid, price))
        return SendClientMessage(playerid, COLOR_RED, "�������������: /vsellto [ID ������] [����]");

    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� � ����������!");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "��������� ����� �� ������!");

    if(price < 1)
        return SendClientMessage(playerid, COLOR_RED, "������������ ����!");

    new vehicleid = GetPlayerVehicleID(playerid);
    new slot = -1;

    // ���������, �������� �� ��� ������ ����������� ������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] && OwnedVehicle[playerid][i][ovVehicleID] == vehicleid)
        {
            slot = i;
            break;
        }
    }

    if(slot == -1)
        return SendClientMessage(playerid, COLOR_RED, "��� �� ��� ������ ���������!");

    // ���������, ���� �� � ���������� ��������� �����
    new targetSlot = -1;
    for(new i = 0; i < 5; i++)
    {
        if(!OwnedVehicle[targetid][i][ovExists])
        {
            targetSlot = i;
            break;
        }
    }

    if(targetSlot == -1)
        return SendClientMessage(playerid, COLOR_RED, "� ���������� ��� ��������� ������ ��� ����������!");

    if(GetPlayerMoney(targetid) < price)
        return SendClientMessage(playerid, COLOR_RED, "� ���������� ������������ �����!");

    // �������� ���������
    GivePlayerMoney(playerid, price);
    GivePlayerMoney(targetid, -price);

    new targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));

    OwnedVehicle[targetid][targetSlot] = OwnedVehicle[playerid][slot];
    format(OwnedVehicle[targetid][targetSlot][ovOwner], MAX_PLAYER_NAME, targetName);
    OwnedVehicle[playerid][slot][ovExists] = false;
    OwnedVehicle[playerid][slot][ovVehicleID] = 0;

    // ��������� ���������
    SaveOwnedVehicles(playerid);
    SaveOwnedVehicles(targetid);

    new string[128];
    format(string, sizeof(string), "�� ������� ���� ��������� ������ %s �� $%d", targetName, price);
    SendClientMessage(playerid, COLOR_GREEN, string);

    new sellerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, sellerName, sizeof(sellerName));
    format(string, sizeof(string), "�� ������ ��������� � ������ %s �� $%d", sellerName, price);
    SendClientMessage(targetid, COLOR_GREEN, string);

    return 1;
}

// ������� ��� ������ ������� ����������
CMD:vspawn(playerid, params[])
{
    printf("DEBUG: Starting vspawn for player %d", playerid);

    new slot = -1;

    // ���������� ������� ��������� ���� ������
    for(new i = 0; i < 5; i++)
    {
        printf("DEBUG: Slot %d status: exists=%d, model=%d, owner=%s",
            i,
            _:OwnedVehicle[playerid][i][ovExists],
            OwnedVehicle[playerid][i][ovModel],
            OwnedVehicle[playerid][i][ovOwner]
        );
    }

    // ���� ������ ����� �����
    if(!isnull(params))
    {
        slot = strval(params) - 1;
        printf("DEBUG: Requested slot: %d", slot);

        if(slot < 0 || slot >= 5)
        {
            SendClientMessage(playerid, COLOR_RED, "����� ����� ������ ���� �� 1 �� 5!");
            return 1;
        }

        if(OwnedVehicle[playerid][slot][ovExists] != true)
        {
            printf("DEBUG: Slot %d is empty (exists = %d)", slot, _:OwnedVehicle[playerid][slot][ovExists]);
            SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���������� � ���� �����!");
            return 1;
        }
    }
    else
    {
        // ���� ������ ��������� ���������
        for(new i = 0; i < 5; i++)
        {
            if(OwnedVehicle[playerid][i][ovExists] == true)
            {
                slot = i;
                printf("DEBUG: Found first available vehicle in slot %d", slot);
                break;
            }
        }
    }

    if(slot == -1)
    {
        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� ����������!");
        return 1;
    }

    printf("DEBUG: Spawning vehicle - Slot: %d, Model: %d, Coords: %f,%f,%f,%f",
        slot,
        OwnedVehicle[playerid][slot][ovModel],
        OwnedVehicle[playerid][slot][ovParkX],
        OwnedVehicle[playerid][slot][ovParkY],
        OwnedVehicle[playerid][slot][ovParkZ],
        OwnedVehicle[playerid][slot][ovParkAngle]
    );

    // ������� ������ ���������, ���� �� ����������
    if(OwnedVehicle[playerid][slot][ovVehicleID])
    {
        DestroyVehicle(OwnedVehicle[playerid][slot][ovVehicleID]);
    }

    // ������� ����� ���������
    new vehicleid = CreateVehicle(
        OwnedVehicle[playerid][slot][ovModel],
        OwnedVehicle[playerid][slot][ovParkX],
        OwnedVehicle[playerid][slot][ovParkY],
        OwnedVehicle[playerid][slot][ovParkZ],
        OwnedVehicle[playerid][slot][ovParkAngle],
        -1, -1, -1
    );

    if(vehicleid == 0)
    {
        printf("DEBUG: Failed to create vehicle!");
        SendClientMessage(playerid, COLOR_RED, "������ �������� ����������!");
        return 1;
    }

    OwnedVehicle[playerid][slot][ovVehicleID] = vehicleid;

    // ������������� �������� ����
    new plate[32];
    format(plate, sizeof(plate), "%s_%d", OwnedVehicle[playerid][slot][ovOwner], slot + 1);
    SetVehicleNumberPlate(vehicleid, plate);

    printf("DEBUG: Vehicle spawned successfully - VehicleID: %d", vehicleid);
    SendClientMessage(playerid, COLOR_GREEN, "��� ������ ��������� ��� ���������!");
    return 1;
}

// ������� ��� ��������� ������ ������� ����������
CMD:vmenu(playerid, params[])
{
    new string[512], count = 0;
    new vehicleName[32];

    printf("DEBUG: Starting vmenu for player %d", playerid);

    // ������� ��������� �������
    strcat(string, "����\t������\t������\n");

    for(new i = 0; i < 5; i++)
    {
        printf("DEBUG: Checking slot %d: exists=%d, model=%d",
            i,
            _:OwnedVehicle[playerid][i][ovExists],
            OwnedVehicle[playerid][i][ovModel]
        );

        if(OwnedVehicle[playerid][i][ovExists] == true)
        {
            // �������� �������� ������
            format(vehicleName, sizeof(vehicleName), "ID: %d", OwnedVehicle[playerid][i][ovModel]);
            for(new v = 0; v < sizeof(DealershipVehicles); v++)
            {
                if(DealershipVehicles[v][vExists] && DealershipVehicles[v][vModel] == OwnedVehicle[playerid][i][ovModel])
                {
                    format(vehicleName, sizeof(vehicleName), "%s", DealershipVehicles[v][vName]);
                    break;
                }
            }

            printf("DEBUG: Adding vehicle to menu - Slot: %d, Model: %s", i, vehicleName);

            format(string, sizeof(string), "%s%d\t%s\t%s\n",
                string,
                i + 1,
                vehicleName,
                OwnedVehicle[playerid][i][ovVehicleID] ? "���������" : "� ������"
            );
            count++;
        }
    }

    if(count == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� ����������!");
        return 1;
    }

    printf("DEBUG: Showing vehicle menu with %d vehicles", count);
    ShowPlayerDialog(playerid, DIALOG_VEHICLE_MENU, DIALOG_STYLE_TABLIST_HEADERS,
        "��� ���������", string, "�������", "�������");
    return 1;
}


// ������� ��� ������ ������ ����������
CMD:vfind(playerid, params[])
{
    new slot;
    if(sscanf(params, "d", slot))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /vfind [����� ����� 1-5]");

    slot -= 1;
    if(slot < 0 || slot >= 5)
        return SendClientMessage(playerid, COLOR_RED, "����� ����� ������ ���� �� 1 �� 5!");

    if(!OwnedVehicle[playerid][slot][ovExists])
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���������� � ���� �����!");

    if(!OwnedVehicle[playerid][slot][ovVehicleID])
        return SendClientMessage(playerid, COLOR_RED, "���� ��������� �� ���������!");

    // ������� ������ �� �����
    SetPlayerCheckpoint(playerid,
        OwnedVehicle[playerid][slot][ovParkX],
        OwnedVehicle[playerid][slot][ovParkY],
        OwnedVehicle[playerid][slot][ovParkZ],
        3.0);

    SendClientMessage(playerid, COLOR_GREEN, "�������������� ������ ���������� �������� �� �����!");
    return 1;
}

// ������� ��� �������� ������
CMD:vkeys(playerid, params[])
{
    new targetid, slot;
    if(sscanf(params, "ud", targetid, slot))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /vkeys [ID ������] [����� ����� 1-5]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "��������� ����� �� ������!");

    slot -= 1;
    if(slot < 0 || slot >= 5)
        return SendClientMessage(playerid, COLOR_RED, "����� ����� ������ ���� �� 1 �� 5!");

    if(!OwnedVehicle[playerid][slot][ovExists])
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���������� � ���� �����!");

    if(!IsPlayerNearPlayer(playerid, targetid, 5.0))
        return SendClientMessage(playerid, COLOR_RED, "�� ���������� ������� ������ �� ������!");

    SetPVarInt(targetid, "VehicleKeys", OwnedVehicle[playerid][slot][ovVehicleID]);

    new string[128], targetName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "�� �������� ����� �� ���������� ������ %s", targetName);
    SendClientMessage(playerid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� �������� ����� �� ���������� �� ������ %s", ReturnPlayerName(playerid));
    SendClientMessage(targetid, COLOR_GREEN, string);
    return 1;
}

// ������� �������� NPC � 3D ������
CreateDealershipNPCs()
{
    // Premium
    CreateActor(189, 566.0, -1293.9, 17.2, 0.003);
    Create3DTextLabel("�������� ���� ����\n������� Y ��� �������", 0xFFFFFFAA, 566.0, -1293.9, 17.2 + 0.5, 10.0, 0, 1);

    // Medium
    CreateActor(242, 338.0, -1816.0, 4.3, 0.0);
    Create3DTextLabel("�������� �������� ������\n������� Y ��� �������", 0xFFFFFFAA, 338.0, -1816.0, 4.3 + 0.5, 10.0, 0, 1);

    // Economy
    CreateActor(94, 1993.9, -2057.0, 13.4, 100.003);
    Create3DTextLabel("�������� ������ ������\n������� Y ��� �������", 0xFFFFFFAA, 1993.9, -2057.0, 13.4 + 0.5, 10.0, 0, 1);

    // Helicopter
    CreateActor(61, 1527.4, -2432.7, 13.6, 0.0);
    Create3DTextLabel("�������� ����������\n������� Y ��� �������", 0xFFFFFFAA, 1527.4, -2432.7, 13.6 + 0.5, 10.0, 0, 1);

    // Moto
    CreateActor(247, 2133.7998, -1151.2002, 24.1, 0.003);
    Create3DTextLabel("�������� ����������\n������� Y ��� �������", 0xFFFFFFAA, 2133.7998, -1151.2002, 24.1 + 0.5, 10.0, 0, 1);
}

// �������� ��� ������� �������� ��� ������� ����������
bool:IsPlayerNearDealership(playerid, &dealershipType)
{
    // Premium
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 566.0, -1293.9, 17.2))
    {
        dealershipType = DEALERSHIP_PREMIUM;
        return true;
    }
    // Medium
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 338.0, -1816.0, 4.3))
    {
        dealershipType = DEALERSHIP_MEDIUM;
        return true;
    }
    // Economy
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1993.9, -2057.0, 13.4))
    {
        dealershipType = DEALERSHIP_ECONOMY;
        return true;
    }
    // Helicopter
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1527.4, -2432.7, 13.6))
    {
        dealershipType = DEALERSHIP_HELI;
        return true;
    }
    // Moto
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 2133.7998, -1151.2002, 24.1))
    {
        dealershipType = DEALERSHIP_MOTO;
        return true;
    }
    return false;
}


CMD:tpgrott(playerid, params[])
{
    // �������� ���� �������������� (������� 2 �������)
    if (Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ���� �������! ��������� 2+ ������� ��������������.");

    // ������������ �� ���������� Grotti
    SetPlayerPos(playerid, 563.662109, -1292.803588, 17.248237);
    SendClientMessage(playerid, COLOR_GREEN, "�� ���� ��������������� �� ������� Grotti.");

    // ��� ��� ������ ���������������
    new adminName[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, adminName, sizeof(adminName));
    format(string, sizeof(string), "������������� %s ����������� ������� /grott ��� ������������.", adminName);
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && Player[i][pAdminLevel] >= 1 && i != playerid)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    return 1;
}

stock SetPlayerGOVRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_GOV_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gGOVSkins[rank-1]);
    SavePlayerSkin(playerid); // ��������� ��� ������
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � GOV: %s", gGOVRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:govuval(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_GOV || Player[playerid][pRank] < 13)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���� �� ������������� ���� �������.");

    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /govuval [id ������] [�������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������.");

    if(!IsPlayerInGovFaction(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������� � ��������������� �������.");

    new oldFaction = Player[targetid][pFaction];
    Player[targetid][pFaction] = 0;
    Player[targetid][pRank] = 0;

    new string[256], dismisserName[MAX_PLAYER_NAME], targetName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, dismisserName, sizeof(dismisserName));
    GetPlayerName(targetid, targetName, sizeof(targetName));

    format(string, sizeof(string), "Goverment: %s ������ ������ %s �� ������� %s, �� �������: %s",
        dismisserName, targetName, GetFactionName(oldFaction), reason);

    // ���������� ����������� ���������������
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pAdminLevel] >= 1)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    format(string, sizeof(string), "�� ���� ������� �� %s. �������: %s", GetFactionName(oldFaction), reason);
    SendClientMessage(targetid, COLOR_RED, string);

    format(string, sizeof(string), "�� ������� %s �� %s. �������: %s", targetName, GetFactionName(oldFaction), reason);
    SendClientMessage(playerid, COLOR_GREEN, string);

    SetPlayerSkin(targetid, (Player[targetid][pGender] == 0) ? 1 : 12);
    SavePlayerSkin(targetid);
    SaveUser(targetid);
    return 1;
}

CreateGOVVehicles()
{
    for(new i = 0; i < sizeof(GOVVehicles); i++)
    {
        // ������� ��������� � ������ ������
        new vehicleid = CreateVehicle(
            GOVVehicleModels[i],
            GOVVehicleSpawns[i][0],
            GOVVehicleSpawns[i][1],
            GOVVehicleSpawns[i][2],
            GOVVehicleSpawns[i][3],
            0, // ������ ����
            0, // ������ ����
            -1  // �������
        );

        GOVVehicles[i] = vehicleid;

        // ������������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "GOV %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);

        // ������������� ��������� ����������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}

stock SetPlayerARMYRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_ARMY_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gARMYSkins[rank-1]);
    PlayerSkins[playerid] = gARMYSkins[rank-1]; // ��������� ���� � ������ PlayerSkins
    SavePlayerSkin(playerid); // ��������� ����
    new string[128];
    format(string, sizeof(string), "��� ����� ���� � Army: %s", gARMYRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:bilet(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_ARMY)
        return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � Army!");

    if(Player[playerid][pRank] < 7)
        return SendClientMessage(playerid, COLOR_RED, "��� ������ �������� ������ ��������� ���� Master Sergeant ��� ����!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /bilet [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������!");

    if(Player[targetid][pHasMilitaryID])
        return SendClientMessage(playerid, COLOR_RED, "� ������ ��� ���� ������� �����!");

    if(Player[targetid][pFaction] != FACTION_ARMY || Player[targetid][pRank] < 4)
        return SendClientMessage(playerid, COLOR_RED, "����� ������ ���� � Army � ����� ������� ���� Sergeant!");

    // ������ ������� �����
    Player[targetid][pHasMilitaryID] = true;
    GetPlayerName(playerid, Player[targetid][pMilitaryIDIssuer], MAX_PLAYER_NAME);
    format(Player[targetid][pMilitaryIDDate], 32, "27.10.2024");

    new string[128], targetName[MAX_PLAYER_NAME], issuerName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));
    GetPlayerName(playerid, issuerName, sizeof(issuerName));

    format(string, sizeof(string), "�� ������ ������� ����� ������ %s", targetName);
    SendClientMessage(playerid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� �������� ������� ����� �� %s", issuerName);
    SendClientMessage(targetid, COLOR_GREEN, string);

    return 1;
}

CMD:showbilet(playerid, params[])
{
    if(!Player[playerid][pHasMilitaryID])
        return SendClientMessage(playerid, COLOR_RED, "� ��� ���� �������� ������. ����� ��� �������� �������� ��� � ������� Army.");

    new string[256], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    format(string, sizeof(string), "������� ����� �� ���: %s\n������ ������ � Army\n�����: %s\n���� ���������: %s",
        name,
        Player[playerid][pMilitaryIDIssuer],
        Player[playerid][pMilitaryIDDate]
    );

    ShowPlayerDialog(playerid, DIALOG_SHOW_MILITARY_ID, DIALOG_STYLE_MSGBOX,
        "������� �����", string, "�������", "");

    return 1;
}

CMD:abilet(playerid, params[])
{
    if(Player[playerid][pAdminLevel] < 2)
        return SendClientMessage(playerid, COLOR_RED, "� ��� ��� ���� �� ������������� ���� �������!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /abilet [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������!");

    // ������ ������� �����
    Player[targetid][pHasMilitaryID] = true;
    GetPlayerName(playerid, Player[targetid][pMilitaryIDIssuer], MAX_PLAYER_NAME);
    format(Player[targetid][pMilitaryIDDate], 32, "27.10.2024");

    new string[128], targetName[MAX_PLAYER_NAME], adminName[MAX_PLAYER_NAME];
    GetPlayerName(targetid, targetName, sizeof(targetName));
    GetPlayerName(playerid, adminName, sizeof(adminName));

    format(string, sizeof(string), "������������� %s ����� ��� ������� �����", adminName);
    SendClientMessage(targetid, COLOR_GREEN, string);

    format(string, sizeof(string), "�� ������ ������� ����� ������ %s", targetName);
    SendClientMessage(playerid, COLOR_GREEN, string);

    return 1;
}

CreateARMYVehicles()
{
    for(new i = 0; i < sizeof(ARMYVehicles); i++)
    {
        // ���������� ����� � ����������� �� ���� ����������
        new color1, color2;

        switch(ARMYVehicleModels[i])
        {
            case 433: // Barracks
            {
                color1 = 99; // ������-�������
                color2 = 99; // �����-�������
            }
            case 490: // FBI Rancher
            {
                color1 = 99;
                color2 = 99;
            }
            case 597: // Police Car
            {
                color1 = 99;
                color2 = 99;
            }
            case 417, 487: // Leviathan � Maverick
            {
                color1 = 99;
                color2 = 99;
            }
        }

        // ������� ���������
        new vehicleid = CreateVehicle(
            ARMYVehicleModels[i],
            ARMYVehicleSpawns[i][0],
            ARMYVehicleSpawns[i][1],
            ARMYVehicleSpawns[i][2],
            ARMYVehicleSpawns[i][3],
            color1,
            color2,
            -1
        );

        ARMYVehicles[i] = vehicleid;

        // ������������� �������� ����
        new plate[32];
        format(plate, sizeof(plate), "ARMY %03d", i + 1);
        SetVehicleNumberPlate(vehicleid, plate);

        // ������������� ��������� ����������
        SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    }
}




AnimateARMYGate(gateID, bool:openState)
{
    if(gateID == 1) // ������ ������ (988 - ������� ������)
    {
        if(openState)
        {
            // ��������� ������ � �������
            MoveDynamicObject(ARMYGateObject1, 96.7, 1925.3, 17.1, 3.0, 0.0, 0.0, -90.0);
            if(ARMYGateTimer1 != -1) KillTimer(ARMYGateTimer1);
            ARMYGateTimer1 = SetTimerEx("CloseARMYGate", 7000, false, "i", 1);
        }
        else
        {
            // ��������� ������ � �������� ���������
            MoveDynamicObject(ARMYGateObject1, 96.7, 1920.3, 17.1, 3.0, 0.0, 0.0, -90.0);
        }
    }
    else if(gateID == 2) // ������ ������ (2990 - ��������� ������)
    {
        if(openState)
        {
            // �������� ������
            MoveDynamicObject(ARMYGateObject2, 345.20001, 1797.6, 13.3, 3.0, 0.0, 0.0, 38.0);
            if(ARMYGateTimer2 != -1) KillTimer(ARMYGateTimer2);
            ARMYGateTimer2 = SetTimerEx("CloseARMYGate", 7000, false, "i", 2);
        }
        else
        {
            // ��������� ������
            MoveDynamicObject(ARMYGateObject2, 345.20001, 1797.6, 21.3, 3.0, 0.0, 0.0, 38.0);
        }
    }
}

// 4. ������� ��������������� �������� (������� � ��� ��� ����)
forward CloseARMYGate(gateID);
public CloseARMYGate(gateID)
{
    if(gateID == 1)
    {
        ARMYGateState1 = false;
        AnimateARMYGate(1, false);
        ARMYGateTimer1 = -1;
    }
    else if(gateID == 2)
    {
        ARMYGateState2 = false;
        AnimateARMYGate(2, false);
        ARMYGateTimer2 = -1;
    }
}

CMD:help(playerid, params[])
{
    new string[2048];
    strcat(string, "{FFFFFF}=== �������� ������� ===\n");
    strcat(string, "/vspawn - ���������� ������ ���������\n");
    strcat(string, "/vmenu - ���� ������� ����������\n");
    strcat(string, "/vpark - ������������ ���������\n");
    strcat(string, "/vsell - ������� ��������� �����������\n");
    strcat(string, "/vsellto - ������� ��������� ������\n");
    strcat(string, "/vfind - ����� ���� ���������\n");
    strcat(string, "/vkeys - �������� ����� �� ����������\n");
    strcat(string, "/car - ���������� �����������\n");
    strcat(string, "/fill - ��������� ���������\n\n");

    strcat(string, "{FFFFFF}=== ���� � ������� ===\n");
    strcat(string, "/buyhouse - ������ ���\n");
    strcat(string, "/sellhouse - ������� ��� �����������\n");
    strcat(string, "/sellhouseto - ������� ��� ������\n");
    strcat(string, "/hlock - �������/������� ���\n");
    strcat(string, "/houseinfo - ���������� � ����\n");
    strcat(string, "/buybiz - ������ ������\n");
    strcat(string, "/sellbiz - ������� ������ �����������\n");
    strcat(string, "/sellbizto - ������� ������ ������\n");
    strcat(string, "/biz - ���������� � �������\n\n");

    strcat(string, "{FFFFFF}=== ���� � ������ ===\n");
    strcat(string, "/pass - �������� �������\n");
    strcat(string, "��������� - ������ �����\n");
    strcat(string, "���� - �������/������ �����\n\n");

    if(Player[playerid][pFaction] == FACTION_LSPD)
    {
        strcat(string, "{FFFFFF}=== ������� LSPD ===\n");
        strcat(string, "/arrest - ���������� ������\n");
        strcat(string, "/wanted - ������ ������\n");
        strcat(string, "/wl - ������ �������������\n");
        strcat(string, "/cuff - ������ ���������\n");
        strcat(string, "/uncuff - ����� ���������\n");
        strcat(string, "/m - �������\n");
        strcat(string, "/lspdarmory - ������� �������\n");
        strcat(string, "/ticket - �������� �����\n");
        strcat(string, "/d - ����� ������������\n");
        strcat(string, "/code - ������� ������������\n");
        strcat(string, "/gateopen - ���������� ��������\n\n");
    }
    else if(Player[playerid][pFaction] == FACTION_FBI)
    {
        strcat(string, "{FFFFFF}=== ������� FBI ===\n");
        strcat(string, "/arrest - ���������� ������\n");
        strcat(string, "/wanted - ������ ������\n");
        strcat(string, "/wl - ������ �������������\n");
        strcat(string, "/cuff - ������ ���������\n");
        strcat(string, "/uncuff - ����� ���������\n");
        strcat(string, "/m - �������\n");
        strcat(string, "/d - ����� ������������\n");
        strcat(string, "/code - ������� ������������\n");
        strcat(string, "/gateopen - ���������� ��������\n\n");
    }
    else if(Player[playerid][pFaction] == FACTION_SHERIFF)
    {
        strcat(string, "{FFFFFF}=== ������� Sheriff ===\n");
        strcat(string, "/arrest - ���������� ������\n");
        strcat(string, "/wanted - ������ ������\n");
        strcat(string, "/wl - ������ �������������\n");
        strcat(string, "/cuff - ������ ���������\n");
        strcat(string, "/uncuff - ����� ���������\n");
        strcat(string, "/m - �������\n");
        strcat(string, "/d - ����� ������������\n");
        strcat(string, "/code - ������� ������������\n\n");
    }
    else if(Player[playerid][pFaction] == FACTION_EMS)
    {
        strcat(string, "{FFFFFF}=== ������� EMS ===\n");
        strcat(string, "/acceptc - ������� �����\n");
        strcat(string, "/rescue - ������������� ������\n");
        strcat(string, "/heal - �������� ������\n");
        strcat(string, "/d - ����� ������������\n\n");
    }
    else if(Player[playerid][pFaction] == FACTION_GOV)
    {
        strcat(string, "{FFFFFF}=== ������� GOV ===\n");
        strcat(string, "/govuval - ������� �� ���. �����������\n");
        strcat(string, "/d - ����� ������������\n");
        strcat(string, "/gateopen - ���������� ��������\n\n");
    }
    else if(Player[playerid][pFaction] == FACTION_ARMY)
    {
        strcat(string, "{FFFFFF}=== ������� ARMY ===\n");
        strcat(string, "/bilet - ������ ������� �����\n");
        strcat(string, "/showbilet - �������� ������� �����\n");
        strcat(string, "/gateopen - ���������� ��������\n\n");
    }

    if(Player[playerid][pAdminLevel] >= 1)
    {
        strcat(string, "{FFFFFF}=== ������� �������������� ===\n");
        if(Player[playerid][pAdminLevel] >= 2)
        {
            strcat(string, "/givemoney - ������ ������ ������\n");
            strcat(string, "/respawn - ������������� ������\n");
            strcat(string, "/spawn - ��������� ������ �� �����\n");
            strcat(string, "/sethp - ���������� ��������\n");
            strcat(string, "/aveh - ������� ���������\n");
            strcat(string, "/abilet - ������ ������� �����\n");
        }
        strcat(string, "/a - ��� ���������������\n");
        if(Player[playerid][pAdminLevel] >= 2)
        {
            strcat(string, "/ao - ���������� �� �������������\n");
        }
        if(Player[playerid][pAdminLevel] >= 4)
        {
            strcat(string, "/makeleader - ��������� ������\n");
            strcat(string, "/makeadmin - ��������� ��������������\n");
            strcat(string, "/apayday - �������������� ������� ��������\n");
        }
    }

    ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "������ �� ��������", string, "�������", "");
    return 1;
}

// Function to set Ballas rank
stock SetPlayerBallasRank(playerid, rank)
{
    if(rank < 1 || rank > MAX_BALLAS_RANK) return 0;
    Player[playerid][pRank] = rank;
    SetPlayerSkin(playerid, gBallasSkins[rank-1]);
    SavePlayerSkin(playerid);
    new string[128];
    format(string, sizeof(string), "Your new rank in Ballas: %s", gBallasRanks[rank-1]);
    SendClientMessage(playerid, -1, string);
    return 1;
}

// ������� �������� ������� � ����������
// ����������� ������� HasVehicleAccess
bool:HasVehicleAccess(playerid, vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID) return false;

    // �������� �� ������������ ���������
    if(RentedVehicle[playerid] == vehicleid)
        return true;

    // �������� �� ����������� ���������
    if(IsVehicleFaction(vehicleid, LSPDVehicles)) return (Player[playerid][pFaction] == FACTION_LSPD);
    if(IsVehicleFaction(vehicleid, SheriffVehicles)) return (Player[playerid][pFaction] == FACTION_SHERIFF);
    if(IsVehicleFaction(vehicleid, EMSVehicles)) return (Player[playerid][pFaction] == FACTION_EMS);
    if(IsVehicleFaction(vehicleid, GroveVehicles)) return (Player[playerid][pFaction] == FACTION_GROVE);
    if(IsVehicleFaction(vehicleid, GOVVehicles)) return (Player[playerid][pFaction] == FACTION_GOV);
    if(IsVehicleFaction(vehicleid, ARMYVehicles)) return (Player[playerid][pFaction] == FACTION_ARMY);
    if(IsVehicleFaction(vehicleid, VagosVehicles)) return (Player[playerid][pFaction] == FACTION_VAGOS);
    if(IsVehicleFaction(vehicleid, BallasVehicles)) return (Player[playerid][pFaction] == FACTION_BALLAS);
    if(IsVehicleFaction(vehicleid, AztecVehicles)) return (Player[playerid][pFaction] == FACTION_AZTEC);
    if(IsVehicleFaction(vehicleid, SANNVehicles)) return (Player[playerid][pFaction] == FACTION_SANN);

    // �������� �� ������ ���������
    for(new i = 0; i < 5; i++)
    {
        if(OwnedVehicle[playerid][i][ovExists] && OwnedVehicle[playerid][i][ovVehicleID] == vehicleid)
            return true;
    }

    // �������� �� ������� ������
    if(GetPVarInt(playerid, "VehicleKeys") == vehicleid)
        return true;

    return false;
}

bool:IsVehicleFaction(vehicleid, const FactionVehicles[], size = sizeof(FactionVehicles))
{
    for(new i = 0; i < size; i++)
    {
        if(vehicleid == FactionVehicles[i]) return true;
    }
    return false;
}
stock ProcessVehicleControlDialog(playerid, response, listitem)
{
    if(!response) return 1;

    new vehicleid = IsPlayerInAnyVehicle(playerid) ? GetPlayerVehicleID(playerid) : GetClosestVehicle(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return 1;

    if(!HasVehicleAccess(playerid, vehicleid))
    {
        SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������� � ����� ����������.");
        return 1;
    }

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(!IsPlayerInAnyVehicle(playerid))
    {
        // ���������� ���� (������ �����)
        switch(listitem)
        {
            case 0: // ������� �����
            {
                SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);
                SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
            }
            case 1: // ������� �����
            {
                SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
                SendClientMessage(playerid, COLOR_GREEN, "����� �������.");
            }
        }
        return 1;
    }

    // ������ ���� ��� ����������� � ������
    switch(listitem)
    {
        case 0: SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
        case 1: SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);
        case 2: SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        case 3: SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
        case 4: SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 1, objective);
        case 5: SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, 0, objective);
        case 6: ShowCarDoorsDialog(playerid);
        case 7: SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);
        case 8: SetVehicleParamsEx(vehicleid, engine, 0, alarm, doors, bonnet, boot, objective);
    }

    return 1;
}

// ������� ��� ������ ��������
CMD:startlive(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_SANN)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� SANN!");

    if(gLiveActive)
        return SendClientMessage(playerid, COLOR_RED, "���� ��� ����!");

    new targetid;
    if(sscanf(params, "u", targetid))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /startlive [ID ������]");

    if(!IsPlayerConnected(targetid))
        return SendClientMessage(playerid, COLOR_RED, "����� �� ������!");

    new string[256], hostName[MAX_PLAYER_NAME], guestName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, hostName, sizeof(hostName));
    GetPlayerName(targetid, guestName, sizeof(guestName));

    gLiveActive = true;
    gLiveHost = playerid;
    gLiveGuest = targetid;
    gLiveType = 1;

    format(string, sizeof(string), "[SANN LIVE] ������ ���� �����! � ������ %s � %s. ��������� ���� ���������!",
        hostName, guestName);
    SendClientMessageToAll(COLOR_YELLOW, string);

    return 1;
}

// ������� ��� �������� ��������� � ���� �� ��������
CMD:clive(playerid, params[])
{
    if(!gLiveActive || playerid != gLiveHost)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ������ ����!");

    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /clive [�����]");

    new string[256], hostName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, hostName, sizeof(hostName));

    format(string, sizeof(string), "[SANN LIVE] %s: %s", hostName, params);
    SendClientMessageToAll(COLOR_YELLOW, string);

    return 1;
}

// ������� ��� �������� ��������� � ���� �� �����
CMD:plive(playerid, params[])
{
    if(!gLiveActive || playerid != gLiveGuest)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� � �����!");

    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /plive [�����]");

    new string[256], guestName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, guestName, sizeof(guestName));

    format(string, sizeof(string), "[SANN LIVE | �����] %s: %s", guestName, params);
    SendClientMessageToAll(COLOR_YELLOW, string);

    return 1;
}

// ������� ��� ���������� �����
CMD:endlive(playerid, params[])
{
    if(!gLiveActive || playerid != gLiveHost)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ������ ����!");

    gLiveActive = false;
    gLiveHost = INVALID_PLAYER_ID;
    gLiveGuest = INVALID_PLAYER_ID;
    gLiveType = 0;

    SendClientMessageToAll(COLOR_YELLOW, "[SANN LIVE] ������ ���� ��������. ������� �� ��������!");

    return 1;
}

// ������� ��� ������ ���� �����
CMD:startsolo(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_SANN)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� SANN!");

    if(gLiveActive)
        return SendClientMessage(playerid, COLOR_RED, "���� ��� ����!");

    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /startsolo [�������� �����]");

    new string[256], hostName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, hostName, sizeof(hostName));

    gLiveActive = true;
    gLiveHost = playerid;
    gLiveType = 2;

    format(string, sizeof(string), "[SANN LIVE] ������ ���� \"%s\" �����! �������: %s", params, hostName);
    SendClientMessageToAll(COLOR_YELLOW, string);

    return 1;
}

CMD:endsolo(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_SANN)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� SANN!");

    if(!gLiveActive || gLiveHost != playerid || gLiveType != 2)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ������ ���� ����!");

    new hostName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, hostName, sizeof(hostName));

    // ��������� ����
    gLiveActive = false;
    gLiveHost = INVALID_PLAYER_ID;
    gLiveType = 0;

    // ���������� ��������� � ����������
    SendClientMessageToAll(COLOR_YELLOW, "[SANN LIVE] ������ ���� ��������. ������� �� ��������!");

    return 1;
}


// ������� ��� ������ ����������
CMD:ad(playerid, params[])
{
    if(Player[playerid][pFaction] != FACTION_SANN)
        return SendClientMessage(playerid, COLOR_RED, "�� �� ��������� SANN!");

    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /ad [����� ����������]");

    new string[256], editorName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, editorName, sizeof(editorName));

    // �������� ������� �����
    new hour, minute, second;
    gettime(hour, minute, second);

    // ���� ����� ������� �������, ��������� �� �����
    if(strlen(params) > 100) // ����� ��������� �����
    {
        new firstPart[101], secondPart[156];
        strmid(firstPart, params, 0, 100);
        strmid(secondPart, params, 100, strlen(params));

        format(string, sizeof(string), "[SANN | %02d:%02d] ����������: %s...", hour, minute, firstPart);
        SendClientMessageToAll(COLOR_GREEN, string);

        format(string, sizeof(string), "[SANN | %02d:%02d] ...%s. ��������: %s",
            hour, minute, secondPart, editorName);
        SendClientMessageToAll(COLOR_GREEN, string);
    }
    else
    {
        format(string, sizeof(string), "[SANN | %02d:%02d] ����������: %s. ��������: %s",
            hour, minute, params, editorName);
        SendClientMessageToAll(COLOR_GREEN, string);
    }

    return 1;
}

// ������� ��� �������� SMS � ��������
CMD:snn(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, COLOR_GREY, "�������������: /snn [�����]");

    // �������� �������� (1 ������)
    if(gettime() - gLastSMSTime[playerid] < 60)
    {
        new timeLeft = 60 - (gettime() - gLastSMSTime[playerid]);
        new string[64];
        format(string, sizeof(string), "��������� %d ������ ����� ��������� ������ SMS.", timeLeft);
        return SendClientMessage(playerid, COLOR_RED, string);
    }

    new string[256], playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));

    format(string, sizeof(string), "[SMS � SANN] �� %s: %s", playerName, params);

    // ���������� SMS ���� ����������� SANN
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Player[i][pFaction] == FACTION_SANN)
        {
            SendClientMessage(i, COLOR_YELLOW, string);
        }
    }

    gLastSMSTime[playerid] = gettime();
    SendClientMessage(playerid, COLOR_GREEN, "SMS ���������� � �������� SANN.");

    return 1;
}

// � �������� ���� (gamemode)
forward IsPlayerAdmin4(playerid);
public IsPlayerAdmin4(playerid)
{
    return (Player[playerid][pAdminLevel] >= 4);
}

// ������� ������������ � ���������
forward TeleportToShop(playerid);
public TeleportToShop(playerid)
{
    SetPlayerPos(playerid, gShopInsidePos[0], gShopInsidePos[1], gShopInsidePos[2]);
    SetPlayerFacingAngle(playerid, gShopInsidePos[3]);
    SendClientMessage(playerid, COLOR_BLUE, "�� ����� � �������.");
}

forward TeleportFromShop(playerid);
public TeleportFromShop(playerid)
{
    SetPlayerPos(playerid, gShopOutsidePos[0], gShopOutsidePos[1], gShopOutsidePos[2]);
    SetPlayerFacingAngle(playerid, gShopOutsidePos[3]);
    SendClientMessage(playerid, COLOR_BLUE, "�� ����� �� ��������.");
}

public SaveTruckerStats(playerid)
{
    SaveUser(playerid);
    return 1;
}
