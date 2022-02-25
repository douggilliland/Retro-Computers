//---------------------------------------------------------------------------
// Network file definitions

#ifndef netH
#define netH

#include <winsock.h>
#include <stdio.h>

// network
#define DEFAULT_PORT            48161
#define DEFAULT_BUFFER_LENGTH    4096
#define UNINITIALIZED               0
#define SERVER                      1
#define CLIENT                      2
#define UNCONNECTED                -1
#define UDP                         0
#define TCP                         1
#define UNCONNECTED_TCP             2
#define CONNECTED_TCP               3

const int NET_OK = 0;
const int NET_ERROR = 1;
const int NET_INIT_FAILED = 2;
const int NET_INVALID_SOCKET = 3;
const int NET_GET_HOST_BY_NAME_FAILED = 4;
const int NET_BIND_FAILED = 5;
const int NET_CONNECT_FAILED = 6;
const int NET_ADDR_IN_USE = 7;
const int NET_DOMAIN_NOT_FOUND = 8;
const int REMOTE_DISCONNECT = 0x2775;

const int BAD_PACKET_LIMIT = 60*15;     // 60 Packets/Sec * 15 Sec
const char CLIENT_ID[] = "EASy68Kc1";   // client ID
const char SERVER_ID[] = "EASy68Ks1";   // server ID
const char SERVER_GO[] = "StartNow";    // server Start
const int NET_UDP = 0;
const int NET_TCP = 1;
const int IP_SIZE = 16;

// prototypes
int __fastcall netInit(int port, int protocol);  // initialize network
int __fastcall netCreateServer(int port, int protocol);  // setup network for server
int __fastcall netCreateClient(char *server, int port, int protocol);   // setup network for client
int __fastcall netLocalIP(char *localIP);            // returns localIP
int __fastcall netSendData(char *data, unsigned int &size, char *remoteIP); // sends network data
int __fastcall netReadData(char *data, unsigned int &size, char *senderIP); // returns network data
int __fastcall netSendData(char *data, unsigned int &size, char *remoteIP, USHORT port); // sends network data
int __fastcall netReadData(char *data, unsigned int &size, char *senderIP, USHORT &port); // returns network data
int __fastcall netCloseSockets();


//---------------------------------------------------------------------------
#endif



