//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include "net.h"

// Network
DWORD        dwLength = 4096;           // Length of send and receive buffers
WSADATA      wsd;
SOCKET       sock = NULL;
char         *recvbuf;
char         *sendbuf;
int          ret = 0;
DWORD        remoteAddrSize = 0;
SOCKADDR_IN  remote, local;
bool         netInitialized = false;
bool         bound = false;
char         mode = UNINITIALIZED;
int          type = UNCONNECTED;
USHORT       port = 40000;

//---------------------------------------------------------------------------
// Initialize network
// protocol = UDP or TCP
// Pre:
//   port = Port number.
//   protocol = UDP or TCP.
// Post:
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".

int __fastcall netInit(int port, int protocol)
{
  unsigned long ul = 1;
  int           nRet;
  int status;

  if(netInitialized)            // if network currently initialized
    netCloseSockets();          // close current network and start over

  mode = UNINITIALIZED;

  status = WSAStartup(0x0101, &wsd);    // Winsock 1.1
  if (status != 0)
    return ( (status << 16) + NET_INIT_FAILED);

  switch (protocol)
  {
    case UDP:     // UDP
      // Create UDP socket and bind it to a local interface and port
      sock = socket(AF_INET, SOCK_DGRAM, 0);
      if (sock == INVALID_SOCKET) {
        WSACleanup();
        status = WSAGetLastError();          // get detailed error
        return ( (status << 16) + NET_INVALID_SOCKET);
      }
      type = UDP;
      break;
    case TCP:     // TCP
      // Create TCP socket and bind it to a local interface and port
      sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
      if (sock == INVALID_SOCKET) {
        WSACleanup();
        status = WSAGetLastError();          // get detailed error
        return ( (status << 16) + NET_INVALID_SOCKET);
      }
      type = UNCONNECTED_TCP;
      break;
    default:    // Invalid type
      return (NET_INIT_FAILED);
  }

  // put socket in non-blocking mode
  nRet = ioctlsocket(sock, FIONBIO, (unsigned long *) &ul);
  if (nRet == SOCKET_ERROR) {
    WSACleanup();
    status = WSAGetLastError();         // get detailed error
    return ( (status << 16) + NET_INVALID_SOCKET);
  }

  // set local family and port
  local.sin_family = AF_INET;
  local.sin_port = htons((u_short)port);        // port number

  // set remote family and port
  remote.sin_family = AF_INET;
  remote.sin_port = htons((u_short)port);       // port number

  // Allocate the receive buffer
  recvbuf = (char *)GlobalAlloc(GMEM_FIXED, dwLength);
  if (!recvbuf)
    return NET_INIT_FAILED;

  // Allocate the send buffer
  sendbuf = (char *)GlobalAlloc(GMEM_FIXED, dwLength);
  if (!sendbuf)
    return NET_INIT_FAILED;

  netInitialized = true;
  return NET_OK;
}

//---------------------------------------------------------------------------
// Setup network for use as server
// May not be configured as Server and Client at the same time.
// Pre:
//   port = Port number to listen on.
//     Port numbers 0-1023 are used for well-known services.
//     Port numbers 1024-65535 may be freely used.
//   protocol = UDP or TCP
// Post:
//   Returns NET_OK on success
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".

int __fastcall netCreateServer(int port, int protocol) {

  int status;

  // ----- Initialize network stuff -----
  status = netInit(port, protocol);
  if (status != NET_OK)
    return status;

  local.sin_addr.s_addr = htonl(INADDR_ANY);    // listen on all addresses

  // bind socket
  if (bind(sock, (SOCKADDR *)&local, sizeof(local)) == SOCKET_ERROR)
  {
    status = WSAGetLastError();          // get detailed error
    return ((status << 16) + NET_BIND_FAILED);
  }
  bound = true;
  mode = SERVER;

  return NET_OK;
}

//------------------------------------------------------------------------
// Setup network for use as a client
// Pre: 
//   *server = IP address of server to connect to as null terminated
//     string (e.g. "192.168.1.100") or null terminated hostname
//     (e.g. "www.programming2dgames.com").
//   port = Port number. Port numbers 0-1023 are used for well-known services.
//     Port numbers 1024-65535 may be freely used.
//   protocol = UDP or TCP
// Post:
//   Returns NET_OK on success
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".
//   *server = IP address connected to as null terminated string.

int __fastcall netCreateClient(char *server, int port, int protocol) {

    int status;
    int timeout = 5000;         // attempt to connect for 5 seconds before returnning an error
    char serverIP[16] = "255.255.255.255";
    char localIP[16] =  "255.255.255.255";
    hostent* host;

    // ----- Initialize network stuff -----
    status = netInit(port, protocol);
    if (status != NET_OK)
        return status;

  // if server does not contain a dotted quad IP address nnn.nnn.nnn.nnn
  if ((remote.sin_addr.s_addr = inet_addr(server)) == INADDR_NONE) {
    host = gethostbyname(server);
    if(host == NULL)                    // if gethostbyname failed
      return NET_DOMAIN_NOT_FOUND;

    // set serverIP to IP address as string "aaa.bbb.ccc.ddd"
    sprintf(serverIP, "%d.%d.%d.%d",
          (unsigned char)host->h_addr_list[0][0],
          (unsigned char)host->h_addr_list[0][1],
          (unsigned char)host->h_addr_list[0][2],
          (unsigned char)host->h_addr_list[0][3]);
    remote.sin_addr.s_addr = inet_addr(serverIP);
    strncpy(server, inet_ntoa(remote.sin_addr), 16);  // return IP of server
  }

    // set local IP address
    netLocalIP(localIP);          // get local IP
    local.sin_addr.s_addr = inet_addr(localIP);   // local IP

    mode = CLIENT;

    // attempt to connect to server
    while(type == UNCONNECTED_TCP && timeout > 0)
    {
        ret = connect(sock,(SOCKADDR*)(&remote),sizeof(remote));
        if (ret == SOCKET_ERROR) {
            status = WSAGetLastError();
            if (status == WSAEISCONN)   // if connected
            {
                ret = 0;          // clear SOCKET_ERROR
                type = CONNECTED_TCP;
            }
            else
            {
                if ( status == WSAEWOULDBLOCK || status == WSAEALREADY)
                {
                    Sleep(500); // wait 500 milli-seconds before next attempt
                    timeout -= 500;
                }
                else
                    return ((status << 16) + NET_ERROR);
            }
        }
    }
    return NET_OK;
}

//-------------------------------------------------------------------------
// Send data to remoteIP
// Pre:
//   *data = Data to send
//   size = Number of bytes to send
//   if SERVER
//     *remoteIP = Destination IP address as null terminated char array
// Post:
//   Returns NET_OK on success. Success does not indicate data was sent.
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".
//   size = Number of bytes sent, 0 if no data sent.
//
int __fastcall netSendData(char *data, unsigned int &size, char *remoteIP) {
    int status;
    int sendSize = size;
    size = 0;       // assume 0 bytes sent, changed if send successful

    if (mode == SERVER)
    {
        remote.sin_addr.s_addr = inet_addr(remoteIP);
    }

    if(mode == CLIENT && type == UNCONNECTED_TCP)
    {
        ret = connect(sock,(SOCKADDR*)(&remote),sizeof(remote));
        if (ret == SOCKET_ERROR) {
            status = WSAGetLastError();
            if (status == WSAEISCONN)   // if connected
            {
                ret = 0;          // clear SOCKET_ERROR
                type = CONNECTED_TCP;
            }
            else
            {
                if ( status == WSAEWOULDBLOCK || status == WSAEALREADY)
                    return NET_OK;  // no connection yet
                else
                    return ((status << 16) + NET_ERROR);
            }
        }
    }

    ret = sendto(sock, data, sendSize, 0, (SOCKADDR *)&remote, sizeof(remote));
    if (ret == SOCKET_ERROR)
    {
        status = WSAGetLastError();
        return ((status << 16) + NET_ERROR);
    }
    bound = true;         // automatic binding by sendto if unbound
    size = ret;           // number of bytes sent, may be 0
    return NET_OK;
}

//-------------------------------------------------------------------------
// Send data to remoteIP and port
// Pre:
//   *data = Data to send
//   size = Number of bytes to send
//   if SERVER
//     *remoteIP = Destination IP address as null terminated char array
//     port = Destination port number.
// Post:
//   Returns NET_OK on success. Success does not indicate data was sent.
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".
//   size = Number of bytes sent, 0 if no data sent.
//
int __fastcall netSendData(char *data, unsigned int &size, char *remoteIP, const USHORT port) {
    int status;
    int sendSize = size;
    size = 0;       // assume 0 bytes sent, changed if send successful

    if (mode == SERVER)
    {
        remote.sin_addr.s_addr = inet_addr(remoteIP);
        remote.sin_port = port;
    }

    if(mode == CLIENT && type == UNCONNECTED_TCP)
    {
        ret = connect(sock,(SOCKADDR*)(&remote),sizeof(remote));
        if (ret == SOCKET_ERROR) {
            status = WSAGetLastError();
            if (status == WSAEISCONN)   // if connected
            {
                ret = 0;          // clear SOCKET_ERROR
                type = CONNECTED_TCP;
            }
            else
            {
                if ( status == WSAEWOULDBLOCK || status == WSAEALREADY)
                    return NET_OK;  // no connection yet
                else
                    return ((status << 16) + NET_ERROR);
            }
        }
    }

    ret = sendto(sock, data, sendSize, 0, (SOCKADDR *)&remote, sizeof(remote));
    if (ret == SOCKET_ERROR)
    {
        status = WSAGetLastError();
        return ((status << 16) + NET_ERROR);
    }
    bound = true;         // automatic binding by sendto if unbound
    size = ret;           // number of bytes sent, may be 0
    return NET_OK;
}

//---------------------------------------------------------------------------
// Read data, return sender's IP
// Pre:
//   *data = Buffer for received data.
//   size = Number of bytes to receive.
//   *senderIP = NULL
// Post:
//   Returns NET_OK on success.
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".
//   size = Number of bytes received, may be 0.
//   *senderIP = IP address of sender as null terminated string.
int __fastcall netReadData(char *data, unsigned int &size, char *senderIP)
{
    int status;
    int readSize = size;

    size = 0;           // assume 0 bytes read, changed if read successful
    if(bound == false)  // no receive from unbound socket
        return NET_OK;

    if(mode == SERVER && type == UNCONNECTED_TCP)
    {
        ret = listen(sock,1);
        if (ret == SOCKET_ERROR)
        {
            status = WSAGetLastError();
            return ((status << 16) + NET_ERROR);
        }
        SOCKET tempSock;
        tempSock = accept(sock,NULL,NULL);
        if (tempSock == INVALID_SOCKET)
        {
            status = WSAGetLastError();
            if ( status != WSAEWOULDBLOCK)  // don't report WOULDBLOCK error
                return ((status << 16) + NET_ERROR);
            return NET_OK;      // no connection yet
        }
        closesocket(sock);      // don't need old socket
        sock = tempSock;        // TCP client connected
        type = CONNECTED_TCP;
    }

    if(mode == CLIENT && type == UNCONNECTED_TCP)
        return NET_OK;  // no connection yet

    if(sock != NULL)
    {
        remoteAddrSize = sizeof(remote);
        ret = recvfrom(sock, data, readSize, 0, (SOCKADDR *)&remote, (int *)&remoteAddrSize);
        if (ret == SOCKET_ERROR) {
            status = WSAGetLastError();
            if ( status != WSAEWOULDBLOCK)  // don't report WOULDBLOCK error
                return ((status << 16) + NET_ERROR);
            ret = 0;            // clear SOCKET_ERROR
        // if TCP connection did graceful close
        } else if(ret == 0 && type == CONNECTED_TCP)
            // return Remote Disconnect error
            return ((REMOTE_DISCONNECT << 16) + NET_ERROR);
        if (ret)
        {
            //IP of sender
            strncpy(senderIP, inet_ntoa(remote.sin_addr), IP_SIZE);
        }
        size = ret;           // number of bytes read, may be 0
    }
    return NET_OK;
}

//---------------------------------------------------------------------------
// Read data, return sender's IP and port
// Pre:
//   *data = Buffer for received data.
//   size = Number of bytes to receive.
//   *senderIP = NULL
//   port = undefined
// Post:
//   Returns NET_OK on success.
//   Returns two part int code on error.
//     The low 16 bits contains Status code as defined in net.h.
//     The high 16 bits contains "Windows Socket Error Code".
//   size = Number of bytes received, may be 0.
//   *senderIP = IP address of sender as null terminated string.
//   port = port number of sender.
int __fastcall netReadData(char *data, unsigned int &size, char *senderIP, USHORT &port)
{
    int status;
    int readSize = size;

    size = 0;           // assume 0 bytes read, changed if read successful
    if(bound == false)  // no receive from unbound socket
        return NET_OK;

    if(mode == SERVER && type == UNCONNECTED_TCP)
    {
        ret = listen(sock,1);
        if (ret == SOCKET_ERROR)
        {
            status = WSAGetLastError();
            return ((status << 16) + NET_ERROR);
        }
        SOCKET tempSock;
        tempSock = accept(sock,NULL,NULL);
        if (tempSock == INVALID_SOCKET)
        {
            status = WSAGetLastError();
            if ( status != WSAEWOULDBLOCK)  // don't report WOULDBLOCK error
                return ((status << 16) + NET_ERROR);
            return NET_OK;      // no connection yet
        }
        closesocket(sock);      // don't need old socket
        sock = tempSock;        // TCP client connected
        type = CONNECTED_TCP;
    }

    if(mode == CLIENT && type == UNCONNECTED_TCP)
        return NET_OK;  // no connection yet

    if(sock != NULL)
    {
        remoteAddrSize = sizeof(remote);
        ret = recvfrom(sock, data, readSize, 0, (SOCKADDR *)&remote, (int *)&remoteAddrSize);
        if (ret == SOCKET_ERROR) {
            status = WSAGetLastError();
            if ( status != WSAEWOULDBLOCK)  // don't report WOULDBLOCK error
                return ((status << 16) + NET_ERROR);
            ret = 0;            // clear SOCKET_ERROR
        // if TCP connection did graceful close
        } else if(ret == 0 && type == CONNECTED_TCP)
            // return Remote Disconnect error
            return ((REMOTE_DISCONNECT << 16) + NET_ERROR);
        if (ret)
        {
            //IP of sender
            strncpy(senderIP, inet_ntoa(remote.sin_addr), IP_SIZE);
            port = remote.sin_port;     //port number of sender
        }
        size = ret;           // number of bytes read, may be 0
    }
    return NET_OK;
}

//--------------------------------------------------------------------------
// Close socket and free buffers
//
int __fastcall netCloseSockets() {
  int status;
  BOOL linger;

  type = UNCONNECTED;

  // closesocket() implicitly causes a shutdown sequence to occur
  if (closesocket(sock) == SOCKET_ERROR) {
    status = WSAGetLastError();
    if ( status != WSAEWOULDBLOCK) {  // don't report WOULDBLOCK error
      return ((status << 16) + NET_ERROR);
    }
  }

  GlobalFree(sendbuf);
  GlobalFree(recvbuf);
  netInitialized = false;

  if (WSACleanup())
    return NET_ERROR;
  return NET_OK;
}

//-------------------------------------------------------------------------
// Get the IP address of this computer as a string
int __fastcall netLocalIP(char *localIP) {

  char hostName[40];
  hostent* host;
  int status;

  gethostname (hostName,40);
  host = gethostbyname(hostName);
  if(host == NULL) {                    // if gethostbyname failed
    status = WSAGetLastError();         // get detailed error
    return ( (status << 16) + NET_ERROR);
  }

  sprintf(localIP, "%d.%d.%d.%d",
          (unsigned char)host->h_addr_list[0][0],
          (unsigned char)host->h_addr_list[0][1],
          (unsigned char)host->h_addr_list[0][2],
          (unsigned char)host->h_addr_list[0][3]);
  return NET_OK;
}




