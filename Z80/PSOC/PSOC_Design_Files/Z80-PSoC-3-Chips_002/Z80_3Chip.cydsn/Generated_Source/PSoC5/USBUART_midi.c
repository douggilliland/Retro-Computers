/***************************************************************************//**
* \file USBUART_midi.c
* \version 3.20
*
* \brief
*  MIDI Streaming request handler.
*  This file contains routines for sending and receiving MIDI
*  messages, and handles running status in both directions.
*
* Related Document:
*  Universal Serial Bus Device Class Definition for MIDI Devices Release 1.0
*  MIDI 1.0 Detailed Specification Document Version 4.2
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_midi.h"
#include "USBUART_pvt.h"
#include "cyapicallbacks.h"

#if defined(USBUART_ENABLE_MIDI_STREAMING)

/***************************************
*    MIDI Constants
***************************************/

#if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
    /* The Size of the MIDI messages (MIDI Table 4-1) */
    static const uint8 CYCODE USBUART_MIDI_SIZE[] = {
    /*  Miscellaneous function codes(Reserved)  */ 0x03u,
    /*  Cable events (Reserved)                 */ 0x03u,
    /*  Two-byte System Common messages         */ 0x02u,
    /*  Three-byte System Common messages       */ 0x03u,
    /*  SysEx starts or continues               */ 0x03u,
    /*  Single-byte System Common Message or
        SysEx ends with following single byte   */ 0x01u,
    /*  SysEx ends with following two bytes     */ 0x02u,
    /*  SysEx ends with following three bytes   */ 0x03u,
    /*  Note-off                                */ 0x03u,
    /*  Note-on                                 */ 0x03u,
    /*  Poly-KeyPress                           */ 0x03u,
    /*  Control Change                          */ 0x03u,
    /*  Program Change                          */ 0x02u,
    /*  Channel Pressure                        */ 0x02u,
    /*  PitchBend Change                        */ 0x03u,
    /*  Single Byte                             */ 0x01u
    };
#endif  /* USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF */



/***************************************
*  Global variables
***************************************/


#if (USBUART_MIDI_IN_BUFF_SIZE > 0)
    #if (USBUART_MIDI_IN_BUFF_SIZE >= 256)
        /** Input endpoint buffer pointer. This pointer is used as an index for the
        * USBMIDI_midiInBuffer to write data. It is cleared to zero by the
        * USBMIDI_MIDI_EP_Init() function.*/
        volatile uint16 USBUART_midiInPointer;                            /* Input endpoint buffer pointer */
    #else
        volatile uint8 USBUART_midiInPointer;                             /* Input endpoint buffer pointer */
    #endif /* (USBUART_MIDI_IN_BUFF_SIZE >= 256) */
    /** Contains the midi IN endpoint number, It is initialized after a
     * SET_CONFIGURATION request based on a user descriptor. It is used in MIDI
     * APIs to send data to the host.*/
    volatile uint8 USBUART_midi_in_ep;
    /** Input endpoint buffer with a length equal to MIDI IN EP Max Packet Size.
     * This buffer is used to save and combine the data received from the UARTs,
     * generated internally by USBMIDI_PutUsbMidiIn() function messages, or both.
     * The USBMIDI_MIDI_IN_Service() function transfers the data from this buffer to the host.*/
    uint8 USBUART_midiInBuffer[USBUART_MIDI_IN_BUFF_SIZE];       /* Input endpoint buffer */
#endif /* (USBUART_MIDI_IN_BUFF_SIZE > 0) */

#if (USBUART_MIDI_OUT_BUFF_SIZE > 0)
    /** Contains the midi OUT endpoint number. It is initialized after a
     * SET_CONFIGURATION request based on a user descriptor. It is used in
     * MIDI APIs to receive data from the host.*/
    volatile uint8 USBUART_midi_out_ep;                                   /* Output endpoint number */
    /** Output endpoint buffer with a length equal to MIDI OUT EP Max Packet Size.
     * This buffer is used by the USBMIDI_MIDI_OUT_EP_Service() function to save
     * the data received from the host. The received data is then parsed. The
     * parsed data is transferred to the UARTs buffer and also used for internal
     * processing by the USBMIDI_callbackLocalMidiEvent() function.*/
    uint8 USBUART_midiOutBuffer[USBUART_MIDI_OUT_BUFF_SIZE];     /* Output endpoint buffer */
#endif /* (USBUART_MIDI_OUT_BUFF_SIZE > 0) */

#if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)

    static USBUART_MIDI_RX_STATUS USBUART_MIDI1_Event;            /* MIDI RX status structure */
    static volatile uint8 USBUART_MIDI1_TxRunStat;                         /* MIDI Output running status */
    /** The USBFS supports a maximum of two external Jacks. The two flag variables
     * are used to represent the status of two external Jacks. These optional variables
     * are allocated when External Mode is enabled. The following flags help to
     * detect and generate responses for SysEx messages. The USBMIDI_MIDI2_InqFlags
     * is optional and is not available when only one external Jack is configured.
     * Flag                          | Description
     * ------------------------------|---------------------------------------
     * USBMIDI_INQ_SYSEX_FLAG        | Non-real-time SysEx message received.
     * USBMIDI_INQ_IDENTITY_REQ_FLAG | Identity Request received. You should clear this bit when an Identity Reply message is generated.
     * SysEX messages are intended for local device and shouldn't go out on the
     * external MIDI jack, this flag indicates when a MIDI SysEx OUT message is
     * in progress for the application */
    volatile uint8 USBUART_MIDI1_InqFlags;                                 /* Device inquiry flag */

    #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
        static USBUART_MIDI_RX_STATUS USBUART_MIDI2_Event;        /* MIDI RX status structure */
        static volatile uint8 USBUART_MIDI2_TxRunStat;                     /* MIDI Output running status */
        /** See description of \ref USBUART_MIDI1_InqFlags*/
        volatile uint8 USBUART_MIDI2_InqFlags;                             /* Device inquiry flag */
    #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF) */
#endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */


/***************************************
* Custom Declarations
***************************************/

/* `#START MIDI_CUSTOM_DECLARATIONS` Place your declaration here */

/* `#END` */


#if (USBUART_ENABLE_MIDI_API != 0u)
/*******************************************************************************
* Function Name: USBUART_MIDI_Init
****************************************************************************//**
*
*  This function initializes the MIDI interface and UART(s) to be ready to
*   receive data from the PC and MIDI ports.
*
* \globalvars
*
*  \ref USBUART_midiInBuffer: This buffer is used for saving and combining
*    the received data from UART(s) and(or) generated internally by
*    PutUsbMidiIn() function messages. USBUART_MIDI_IN_EP_Service()
*    function transfers the data from this buffer to the PC.
*
*  \ref USBUART_midiOutBuffer: This buffer is used by the
*    USBUART_MIDI_OUT_Service() function for saving the received
*    from the PC data, then the data are parsed and transferred to UART(s)
*    buffer and to the internal processing by the
*
*  \ref USBUART_callbackLocalMidiEvent function.
*
*  \ref USBUART_midi_out_ep: Used as an OUT endpoint number.
*
*  \ref USBUART_midi_in_ep: Used as an IN endpoint number.
*
*   \ref USBUART_midiInPointer: Initialized to zero.
*
* \sideeffect
*   The priority of the UART RX ISR should be higher than UART TX ISR. To do
*   that this function changes the priority of the UARTs TX and RX interrupts.
*
* \reentrant
*  No
*
*******************************************************************************/
void USBUART_MIDI_Init(void) 
{
#if (USBUART_MIDI_IN_BUFF_SIZE > 0)
   USBUART_midiInPointer = 0u;
#endif /* (USBUART_MIDI_IN_BUFF_SIZE > 0) */

#if (USBUART_EP_MANAGEMENT_DMA_AUTO)
    #if (USBUART_MIDI_IN_BUFF_SIZE > 0)
        /* Provide buffer for IN endpoint. */
        USBUART_LoadInEP(USBUART_midi_in_ep, USBUART_midiInBuffer,
                                                               USBUART_MIDI_IN_BUFF_SIZE);
    #endif  /* (USBUART_MIDI_IN_BUFF_SIZE > 0) */

    #if (USBUART_MIDI_OUT_BUFF_SIZE > 0)
        /* Provide buffer for OUT endpoint. */
        (void)USBUART_ReadOutEP(USBUART_midi_out_ep, USBUART_midiOutBuffer,
                                                                       USBUART_MIDI_OUT_BUFF_SIZE);
    #endif /* (USBUART_MIDI_OUT_BUFF_SIZE > 0) */
#endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */

#if (USBUART_MIDI_OUT_BUFF_SIZE > 0)
    USBUART_EnableOutEP(USBUART_midi_out_ep);
#endif /* (USBUART_MIDI_OUT_BUFF_SIZE > 0) */

    /* Initialize the MIDI port(s) */
#if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
    USBUART_MIDI_InitInterface();
#endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */
}


#if (USBUART_MIDI_OUT_BUFF_SIZE > 0)
    /*******************************************************************************
    * Function Name: USBUART_MIDI_OUT_Service
    ****************************************************************************//**
    *
    *  This function services the traffic from the USBMIDI OUT endpoint and
    *  sends the data to the MIDI output ports (TX UARTs). It is blocked by the
    *  UART when not enough space is available in the UART TX buffer.
    *  This function is automatically called from OUT EP ISR in DMA with
    *  Automatic Memory Management mode. In Manual and DMA with Manual EP
    *  Management modes you must call it from the main foreground task.
    *
    * \globalvars
    *
    *  \ref USBUART_midiOutBuffer: Used as temporary buffer between USB
    *       internal memory and UART TX buffer.
    *
    *  \ref USBUART_midi_out_ep: Used as an OUT endpoint number.
    *
    * \reentrant
    *  No
    *
    *******************************************************************************/
    void USBUART_MIDI_OUT_Service(void) 
    {
    #if (USBUART_MIDI_OUT_BUFF_SIZE >= 256)
        uint16 outLength;
        uint16 outPointer;
    #else
        uint8 outLength;
        uint8 outPointer;
    #endif /* (USBUART_MIDI_OUT_BUFF_SIZE >= 256) */

        /* Service the USB MIDI output endpoint. */
        if (USBUART_OUT_BUFFER_FULL == USBUART_GetEPState(USBUART_midi_out_ep))
        {
        #if (USBUART_MIDI_OUT_BUFF_SIZE >= 256)
            outLength = USBUART_GetEPCount(USBUART_midi_out_ep);
        #else
            outLength = (uint8)USBUART_GetEPCount(USBUART_midi_out_ep);
        #endif /* (USBUART_MIDI_OUT_BUFF_SIZE >= 256) */

        #if (!USBUART_EP_MANAGEMENT_DMA_AUTO)
            #if (USBUART_MIDI_OUT_BUFF_SIZE >= 256)
                outLength = USBUART_ReadOutEP(USBUART_midi_out_ep,
                                                       USBUART_midiOutBuffer, outLength);
            #else
                outLength = (uint8)USBUART_ReadOutEP(USBUART_midi_out_ep,
                                                              USBUART_midiOutBuffer, (uint16) outLength);
            #endif /* (USBUART_MIDI_OUT_BUFF_SIZE >= 256) */

            #if (USBUART_EP_MANAGEMENT_DMA_MANUAL)
                /* Wait until DMA complete transferring data from OUT endpoint buffer. */
                while (USBUART_OUT_BUFFER_FULL == USBUART_GetEPState(USBUART_midi_out_ep))
                {
                }

                /* Enable OUT endpoint for communication with host. */
                USBUART_EnableOutEP(USBUART_midi_out_ep);
            #endif /* (USBUART_EP_MANAGEMENT_DMA_MANUAL) */
        #endif /* (!USBUART_EP_MANAGEMENT_DMA_AUTO) */

            if (outLength >= USBUART_EVENT_LENGTH)
            {
                outPointer = 0u;
                while (outPointer < outLength)
                {
                    /* In some OS OUT packet could be appended by nulls which could be skipped. */
                    if (USBUART_midiOutBuffer[outPointer] == 0u)
                    {
                        break;
                    }

                /* Route USB MIDI to the External connection */
                #if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
                    if ((USBUART_midiOutBuffer[outPointer] & USBUART_CABLE_MASK) ==
                         USBUART_MIDI_CABLE_00)
                    {
                        USBUART_MIDI1_ProcessUsbOut(&USBUART_midiOutBuffer[outPointer]);
                    }
                    else if ((USBUART_midiOutBuffer[outPointer] & USBUART_CABLE_MASK) ==
                             USBUART_MIDI_CABLE_01)
                    {
                    #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
                         USBUART_MIDI2_ProcessUsbOut(&USBUART_midiOutBuffer[outPointer]);
                    #endif /*  USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF */
                    }
                    else
                    {
                        /* `#START CUSTOM_MIDI_OUT_EP_SERV` Place your code here */

                        /* `#END` */

                        #ifdef USBUART_MIDI_OUT_EP_SERVICE_CALLBACK
                            USBUART_MIDI_OUT_EP_Service_Callback();
                        #endif /* USBUART_MIDI_OUT_EP_SERVICE_CALLBACK */
                    }
                #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */

                    /* Process any local MIDI output functions */
                    USBUART_callbackLocalMidiEvent(USBUART_midiOutBuffer[outPointer] & USBUART_CABLE_MASK,
                                                            &USBUART_midiOutBuffer[outPointer + USBUART_EVENT_BYTE1]);
                    outPointer += USBUART_EVENT_LENGTH;
                }
            }

        #if (USBUART_EP_MANAGEMENT_DMA_AUTO)
            /* Enable OUT endpoint for communication */
            USBUART_EnableOutEP(USBUART_midi_out_ep);
        #endif  /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */
        }
    }
#endif /* (USBUART_MIDI_OUT_BUFF_SIZE > 0) */


#if (USBUART_MIDI_IN_BUFF_SIZE > 0)
    /*******************************************************************************
    * Function Name: USBUART_MIDI_IN_EP_Service
    ****************************************************************************//**
    *
    *  Services the USB MIDI IN endpoint. Non-blocking.
    *  Checks that previous packet was processed by HOST, otherwise service the
    *  input endpoint on the subsequent call. It is called from the
    *  USBUART_MIDI_IN_Service() and from the
    *  USBUART_PutUsbMidiIn() function.
    *
    * \globalvars
    *  USBUART_midi_in_ep: Used as an IN endpoint number.
    *  USBUART_midiInBuffer: Function loads the data from this buffer to
    *    the USB IN endpoint.
    *   USBUART_midiInPointer: Cleared to zero when data are sent.
    *
    * \reentrant
    *  No
    *
    *******************************************************************************/
    void USBUART_MIDI_IN_EP_Service(void) 
    {
        /* Service the USB MIDI input endpoint */
        /* Check that previous packet was processed by HOST, otherwise service the USB later */
        if (USBUART_midiInPointer != 0u)
        {
            if(USBUART_GetEPState(USBUART_midi_in_ep) == USBUART_EVENT_PENDING)
            {
            #if (USBUART_EP_MANAGEMENT_DMA_AUTO)
                USBUART_LoadInEP(USBUART_midi_in_ep, NULL, (uint16)USBUART_midiInPointer);
            #else
                USBUART_LoadInEP(USBUART_midi_in_ep, USBUART_midiInBuffer,
                                                              (uint16) USBUART_midiInPointer);
            #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */

            /* Clear the midiInPointer. For DMA mode, clear this pointer in the ARB ISR when data are moved by DMA */
            #if (USBUART_EP_MANAGEMENT_MANUAL)
                USBUART_midiInPointer = 0u;
            #endif /* (USBUART_EP_MANAGEMENT_MANUAL) */
            }
        }
    }


    /*******************************************************************************
    * Function Name: USBUART_MIDI_IN_Service
    ****************************************************************************//**
    *
    *  This function services the traffic from the MIDI input ports (RX UART)
    *  and prepare data in USB MIDI IN endpoint buffer.
    *  Calls the USBUART_MIDI_IN_EP_Service() function to sent the
    *  data from buffer to PC. Non-blocking. Should be called from main foreground
    *  task.
    *  This function is not protected from the reentrant calls. When it is required
    *  to use this function in UART RX ISR to guaranty low latency, care should be
    *  taken to protect from reentrant calls.
    *  In PSoC 3, if this function is called from an ISR, you must declare this
    *  function as re-entrant so that different variable storage space is
    *  created by the compiler. This is automatically taken care for PSoC 4 and
    *  PSoC 5LP devices by the compiler.
    *
    * \globalvars
    *
    *   USBUART_midiInPointer: Cleared to zero when data are sent.
    *
    * \reentrant
    *  No
    *
    *******************************************************************************/
    void USBUART_MIDI_IN_Service(void) 
    {
        /* Service the MIDI UART inputs until either both receivers have no more
        *  events or until the input endpoint buffer fills up.
        */
    #if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
            uint8 m1 = 0u;
            uint8 m2 = 0u;

        if (0u == USBUART_midiInPointer)
        {
            do
            {
                if (USBUART_midiInPointer <= (USBUART_MIDI_IN_BUFF_SIZE - USBUART_EVENT_LENGTH))
                {
                    /* Check MIDI1 input port for a complete event */
                    m1 = USBUART_MIDI1_GetEvent();
                    if (m1 != 0u)
                    {
                        USBUART_PrepareInBuffer(m1, (uint8 *)&USBUART_MIDI1_Event.msgBuff[0],
                                                                       USBUART_MIDI1_Event.size, USBUART_MIDI_CABLE_00);
                    }
                }

            #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
                if (USBUART_midiInPointer <= (USBUART_MIDI_IN_BUFF_SIZE - USBUART_EVENT_LENGTH))
                {
                    /* Check MIDI2 input port for a complete event */
                    m2 = USBUART_MIDI2_GetEvent();
                    if (m2 != 0u)
                    {
                        USBUART_PrepareInBuffer(m2, (uint8 *)&USBUART_MIDI2_Event.msgBuff[0],
                                                                       USBUART_MIDI2_Event.size, USBUART_MIDI_CABLE_01);
                    }
                }
            #endif /*  USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF */
            }
            while((USBUART_midiInPointer <= (USBUART_MIDI_IN_BUFF_SIZE - USBUART_EVENT_LENGTH)) &&
                  ((m1 != 0u) || (m2 != 0u)));
        }
    #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */

        /* Service the USB MIDI input endpoint */
        USBUART_MIDI_IN_EP_Service();
    }


    /***************************************************************************
    * Function Name: USBUART_PutUsbMidiIn
    ************************************************************************//**
    *
    *  This function puts one MIDI message into the USB MIDI In endpoint buffer.
    *  This is a MIDI input message to the host. This function is used only if
    *  the device has internal MIDI input functionality.
    *  The USBUART_MIDI_IN_Service() function should also be called to
    *  send the message from local buffer to the IN endpoint.
    *
    *  \param ic: The length of the MIDI message or command is described on the
    *  following table.
    *  Value          | Description
    *  ---------------|---------------------------------------------------------
    *  0              | No message (should never happen)
    *  1 - 3          | Complete MIDI message in midiMsg
    *  3 IN EP LENGTH | Complete SySEx message(without EOSEX byte) in midiMsg. The length is limited by the max BULK EP size(64)
    *  MIDI_SYSEX     | Start or continuation of SysEx message (put event bytes in midiMsg buffer)
    *  MIDI_EOSEX     | End of SysEx message (put event bytes in midiMsg buffer)
    *  MIDI_TUNEREQ   | Tune Request message (single byte system common message)
    *  0xF8 - 0xFF    | Single byte real-time message
    *
    *  \param midiMsg: pointer to MIDI message.
    *  \param cable:   cable number.
    *
    * \return
    *   Return Value          | Description
    *   ----------------------|-----------------------------------------
    *  USBUART_TRUE  | Host is not ready to receive this message
    *  USBUART_FALSE | Success transfer
    *
    * \globalvars
    *
    *  \ref USBUART_midi_in_ep: MIDI IN endpoint number used for
    *        sending data.
    *
    *  \ref USBUART_midiInPointer: Checked this variable to see if
    *        there is enough free space in the IN endpoint buffer. If buffer is
    *        full, initiate sending to PC.
    *
    * \reentrant
    *  No
    *
    ***************************************************************************/
    uint8 USBUART_PutUsbMidiIn(uint8 ic, const uint8 midiMsg[], uint8 cable)
                                                                
    {
        uint8 retError = USBUART_FALSE;

        /* Protect PrepareInBuffer() function from concurrent calls */
    #if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
        MIDI1_UART_DisableRxInt();
        #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
            MIDI2_UART_DisableRxInt();
        #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF) */
    #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */

        if (USBUART_midiInPointer >
                    (USBUART_EP[USBUART_midi_in_ep].bufferSize - USBUART_EVENT_LENGTH))
        {
            USBUART_MIDI_IN_EP_Service();
        }

        if (USBUART_midiInPointer <=
                    (USBUART_EP[USBUART_midi_in_ep].bufferSize - USBUART_EVENT_LENGTH))
        {
            if((ic < USBUART_EVENT_LENGTH) || (ic >= USBUART_MIDI_STATUS_MASK))
            {
                USBUART_PrepareInBuffer(ic, midiMsg, ic, cable);
            }
            else /* Only SysEx message is greater than 4 bytes */
            {
                /* Convert SysEx message into midi message format */
                uint8 idx = 0u;
                do
                {
                    /* Process 3 bytes of message until 0-2 bytes are left. These bytes are handled by MIDI_EOSEX. */
                    USBUART_PrepareInBuffer(USBUART_MIDI_SYSEX, &midiMsg[idx],
                                                     USBUART_EVENT_BYTE3, cable);

                    /* Move to next 3 bytes of message */
                    ic  -= USBUART_EVENT_BYTE3;
                    idx += USBUART_EVENT_BYTE3;

                    if (USBUART_midiInPointer >
                        (USBUART_EP[USBUART_midi_in_ep].bufferSize - USBUART_EVENT_LENGTH))
                    {
                        /* Load message into endpoint */
                        USBUART_MIDI_IN_EP_Service();

                        if (USBUART_midiInPointer >
                           (USBUART_EP[USBUART_midi_in_ep].bufferSize - USBUART_EVENT_LENGTH))
                        {
                            /* Error condition. Host is not ready to receive this packet. */
                            retError = USBUART_TRUE;
                            break;
                        }
                    }
                }
                while (ic >= USBUART_EVENT_BYTE3);

                if (retError == USBUART_FALSE)
                {
                    /* Handle end of message: valid size of messages is 0, 1 and 2 */
                    USBUART_PrepareInBuffer(USBUART_MIDI_EOSEX, &midiMsg[idx], ic, cable);
                }
            }
        }
        else
        {
            /* Error condition. Host is not ready to receive this packet. */
            retError = USBUART_TRUE;
        }

    #if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
        MIDI1_UART_EnableRxInt();
        #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
            MIDI2_UART_EnableRxInt();
        #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF) */
    #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */

        return (retError);
    }


    /*******************************************************************************
    * Function Name: USBUART_PrepareInBuffer
    ****************************************************************************//**
    *
    *  Builds a USB MIDI event in the input endpoint buffer at the current pointer.
    *  Puts one MIDI message into the USB MIDI In endpoint buffer.
    *
    *  \param ic:   0 = No message (should never happen)
    *        1 - 3 = Complete MIDI message at pMdat[0]
    *        MIDI_SYSEX = Start or continuation of SysEx message
    *                     (put eventLen bytes in buffer)
    *        MIDI_EOSEX = End of SysEx message
    *                     (put eventLen bytes in buffer,
    *                      and append MIDI_EOSEX)
    *        MIDI_TUNEREQ = Tune Request message (single byte system common msg)
    *        0xf8 - 0xff = Single byte real-time message
    *
    *  \param srcBuff: pointer to MIDI data
    *  \param eventLen: number of bytes in MIDI event
    *  \param cable: MIDI source port number
    *
    * \globalvars
    *  USBUART_midiInBuffer: This buffer is used for saving and combine the
    *    received from UART(s) and(or) generated internally by
    *    USBUART_PutUsbMidiIn() function messages.
    *  USBUART_midiInPointer: Used as an index for midiInBuffer to
    *     write data.
    *
    * \reentrant
    *  No
    *
    *******************************************************************************/
    void USBUART_PrepareInBuffer(uint8 ic, const uint8 srcBuff[], uint8 eventLen, uint8 cable)
                                                                 
    {
        uint8 srcBuffZero;
        uint8 srcBuffOne;

        srcBuffZero = srcBuff[0u];
        srcBuffOne  = srcBuff[1u];

        if (ic >= (USBUART_MIDI_STATUS_MASK | USBUART_MIDI_SINGLE_BYTE_MASK))
        {
            USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_SINGLE_BYTE | cable;
            USBUART_midiInPointer++;
            USBUART_midiInBuffer[USBUART_midiInPointer] = ic;
            USBUART_midiInPointer++;
            USBUART_midiInBuffer[USBUART_midiInPointer] = 0u;
            USBUART_midiInPointer++;
            USBUART_midiInBuffer[USBUART_midiInPointer] = 0u;
            USBUART_midiInPointer++;
        }
        else if((ic < USBUART_EVENT_LENGTH) || (ic == USBUART_MIDI_SYSEX))
        {
            if(ic == USBUART_MIDI_SYSEX)
            {
                USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_SYSEX | cable;
                USBUART_midiInPointer++;
            }
            else if (srcBuffZero < USBUART_MIDI_SYSEX)
            {
                USBUART_midiInBuffer[USBUART_midiInPointer] = (srcBuffZero >> 4u) | cable;
                USBUART_midiInPointer++;
            }
            else if (srcBuffZero == USBUART_MIDI_TUNEREQ)
            {
                USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_1BYTE_COMMON | cable;
                USBUART_midiInPointer++;
            }
            else if ((srcBuffZero == USBUART_MIDI_QFM) || (srcBuffZero == USBUART_MIDI_SONGSEL))
            {
                USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_2BYTE_COMMON | cable;
                USBUART_midiInPointer++;
            }
            else if (srcBuffZero == USBUART_MIDI_SPP)
            {
                USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_3BYTE_COMMON | cable;
                USBUART_midiInPointer++;
            }
            else
            {
            }

            USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuffZero;
            USBUART_midiInPointer++;
            USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuffOne;
            USBUART_midiInPointer++;
            USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuff[2u];
            USBUART_midiInPointer++;
        }
        else if (ic == USBUART_MIDI_EOSEX)
        {
            switch (eventLen)
            {
                case 0u:
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_SYSEX_ENDS_WITH1 | cable;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_MIDI_EOSEX;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = 0u;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = 0u;
                    USBUART_midiInPointer++;
                    break;
                case 1u:
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_SYSEX_ENDS_WITH2 | cable;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuffZero;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_MIDI_EOSEX;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = 0u;
                    USBUART_midiInPointer++;
                    break;
                case 2u:
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_SYSEX_ENDS_WITH3 | cable;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuffZero;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = srcBuffOne;
                    USBUART_midiInPointer++;
                    USBUART_midiInBuffer[USBUART_midiInPointer] = USBUART_MIDI_EOSEX;
                    USBUART_midiInPointer++;
                    break;
                default:
                    break;
            }
        }
        else
        {
        }
    }

#endif /* (USBUART_MIDI_IN_BUFF_SIZE > 0) */


/* The implementation for external serial input and output connections
*  to route USB MIDI data to and from those connections.
*/
#if (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF)
    /*******************************************************************************
    * Function Name: USBUART_MIDI_InitInterface
    ****************************************************************************//**
    *
    *  Initializes MIDI variables and starts the UART(s) hardware block(s).
    *
    * \sideeffect
    *  Change the priority of the UART(s) TX interrupts to be higher than the
    *  default EP ISR priority.
    *
    * \globalvars
    *   USBUART_MIDI_Event: initialized to zero.
    *   USBUART_MIDI_TxRunStat: initialized to zero.
    *
    *******************************************************************************/
    void USBUART_MIDI_InitInterface(void) 
    {
        USBUART_MIDI1_Event.length  = 0u;
        USBUART_MIDI1_Event.count   = 0u;
        USBUART_MIDI1_Event.size    = 0u;
        USBUART_MIDI1_Event.runstat = 0u;
        USBUART_MIDI1_TxRunStat     = 0u;
        USBUART_MIDI1_InqFlags      = 0u;

        /* Start UART block */
        MIDI1_UART_Start();

        /* Change the priority of the UART TX and RX interrupt */
        CyIntSetPriority(MIDI1_UART_TX_VECT_NUM, USBUART_CUSTOM_UART_TX_PRIOR_NUM);
        CyIntSetPriority(MIDI1_UART_RX_VECT_NUM, USBUART_CUSTOM_UART_RX_PRIOR_NUM);

    #if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
        USBUART_MIDI2_Event.length  = 0u;
        USBUART_MIDI2_Event.count   = 0u;
        USBUART_MIDI2_Event.size    = 0u;
        USBUART_MIDI2_Event.runstat = 0u;
        USBUART_MIDI2_TxRunStat     = 0u;
        USBUART_MIDI2_InqFlags      = 0u;

        /* Start second UART block */
        MIDI2_UART_Start();

        /* Change the priority of the UART TX interrupt */
        CyIntSetPriority(MIDI2_UART_TX_VECT_NUM, USBUART_CUSTOM_UART_TX_PRIOR_NUM);
        CyIntSetPriority(MIDI2_UART_RX_VECT_NUM, USBUART_CUSTOM_UART_RX_PRIOR_NUM);
    #endif /* (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF) */

        /* `#START MIDI_INIT_CUSTOM` Init other extended UARTs here */

        /* `#END` */

    #ifdef USBUART_MIDI_INIT_CALLBACK
        USBUART_MIDI_Init_Callback();
    #endif /* (USBUART_MIDI_INIT_CALLBACK) */
    }


    /*******************************************************************************
    * Function Name: USBUART_ProcessMidiIn
    ****************************************************************************//**
    *
    *  Processes one byte of incoming MIDI data.
    *
    *   mData = current MIDI input data byte
    *   *rxStat = pointer to a MIDI_RX_STATUS structure
    *
    * \return
    *   0, if no complete message
    *   1 - 4, if message complete
    *   MIDI_SYSEX, if start or continuation of system exclusive
    *   MIDI_EOSEX, if end of system exclusive
    *   0xf8 - 0xff, if single byte real time message
    *
    *******************************************************************************/
    uint8 USBUART_ProcessMidiIn(uint8 mData, USBUART_MIDI_RX_STATUS *rxStat)
                                                                
    {
        uint8 midiReturn = 0u;

        /* Check for a MIDI status byte.  All status bytes, except real time messages,
        *  which are a single byte, force the start of a new buffer cycle.
        */
        if ((mData & USBUART_MIDI_STATUS_BYTE_MASK) != 0u)
        {
            if ((mData & USBUART_MIDI_STATUS_MASK) == USBUART_MIDI_STATUS_MASK)
            {
                if ((mData & USBUART_MIDI_SINGLE_BYTE_MASK) != 0u) /* System Real-Time Messages(single byte) */
                {
                    midiReturn = mData;
                }
                else                              /* System Common Messages */
                {
                    switch (mData)
                    {
                        case USBUART_MIDI_SYSEX:
                            rxStat->msgBuff[0u] = USBUART_MIDI_SYSEX;
                            rxStat->runstat = USBUART_MIDI_SYSEX;
                            rxStat->count = 1u;
                            rxStat->length = 3u;
                            break;
                        case USBUART_MIDI_EOSEX:
                            rxStat->runstat = 0u;
                            rxStat->size = rxStat->count;
                            rxStat->count = 0u;
                            midiReturn = USBUART_MIDI_EOSEX;
                            break;
                        case USBUART_MIDI_SPP:
                            rxStat->msgBuff[0u] = USBUART_MIDI_SPP;
                            rxStat->runstat = 0u;
                            rxStat->count = 1u;
                            rxStat->length = 3u;
                            break;
                        case USBUART_MIDI_SONGSEL:
                            rxStat->msgBuff[0u] = USBUART_MIDI_SONGSEL;
                            rxStat->runstat = 0u;
                            rxStat->count = 1u;
                            rxStat->length = 2u;
                            break;
                        case USBUART_MIDI_QFM:
                            rxStat->msgBuff[0u] = USBUART_MIDI_QFM;
                            rxStat->runstat = 0u;
                            rxStat->count = 1u;
                            rxStat->length = 2u;
                            break;
                        case USBUART_MIDI_TUNEREQ:
                            rxStat->msgBuff[0u] = USBUART_MIDI_TUNEREQ;
                            rxStat->runstat = 0u;
                            rxStat->size = 1u;
                            rxStat->count = 0u;
                            midiReturn = rxStat->size;
                            break;
                        default:
                            break;
                    }
                }
            }
            else /* Channel Messages */
            {
                rxStat->msgBuff[0u] = mData;
                rxStat->runstat = mData;
                rxStat->count = 1u;
                switch (mData & USBUART_MIDI_STATUS_MASK)
                {
                    case USBUART_MIDI_NOTE_OFF:
                    case USBUART_MIDI_NOTE_ON:
                    case USBUART_MIDI_POLY_KEY_PRESSURE:
                    case USBUART_MIDI_CONTROL_CHANGE:
                    case USBUART_MIDI_PITCH_BEND_CHANGE:
                        rxStat->length = 3u;
                        break;
                    case USBUART_MIDI_PROGRAM_CHANGE:
                    case USBUART_MIDI_CHANNEL_PRESSURE:
                        rxStat->length = 2u;
                        break;
                    default:
                        rxStat->runstat = 0u;
                        rxStat->count = 0u;
                        break;
                }
            }
        }

        /* Otherwise, it's a data byte */
        else
        {
            if (rxStat->runstat == USBUART_MIDI_SYSEX)
            {
                rxStat->msgBuff[rxStat->count] = mData;
                rxStat->count++;
                if (rxStat->count >= rxStat->length)
                {
                    rxStat->size = rxStat->count;
                    rxStat->count = 0u;
                    midiReturn = USBUART_MIDI_SYSEX;
                }
            }
            else if (rxStat->count > 0u)
            {
                rxStat->msgBuff[rxStat->count] = mData;
                rxStat->count++;
                if (rxStat->count >= rxStat->length)
                {
                    rxStat->size = rxStat->count;
                    rxStat->count = 0u;
                    midiReturn = rxStat->size;
                }
            }
            else if (rxStat->runstat != 0u)
            {
                rxStat->msgBuff[0u] = rxStat->runstat;
                rxStat->msgBuff[1u] = mData;
                rxStat->count = 2u;
                switch (rxStat->runstat & USBUART_MIDI_STATUS_MASK)
                {
                    case USBUART_MIDI_NOTE_OFF:
                    case USBUART_MIDI_NOTE_ON:
                    case USBUART_MIDI_POLY_KEY_PRESSURE:
                    case USBUART_MIDI_CONTROL_CHANGE:
                    case USBUART_MIDI_PITCH_BEND_CHANGE:
                        rxStat->length = 3u;
                        break;
                    case USBUART_MIDI_PROGRAM_CHANGE:
                    case USBUART_MIDI_CHANNEL_PRESSURE:
                        rxStat->size = rxStat->count;
                        rxStat->count = 0u;
                        midiReturn = rxStat->size;
                        break;
                    default:
                        rxStat->count = 0u;
                    break;
                }
            }
            else
            {
            }
        }
        return (midiReturn);
    }


    /*******************************************************************************
    * Function Name: USBUART_MIDI1_GetEvent
    ****************************************************************************//**
    *
    *  Checks for incoming MIDI data, calls the MIDI event builder if so.
    *  Returns either empty or with a complete event.
    *
    * \return
    *   0, if no complete message
    *   1 - 4, if message complete
    *   MIDI_SYSEX, if start or continuation of system exclusive
    *   MIDI_EOSEX, if end of system exclusive
    *   0xf8 - 0xff, if single byte real time message
    *
    * \globalvars
    *  USBUART_MIDI1_Event: RX status structure used to parse received
    *    data.
    *
    *******************************************************************************/
    uint8 USBUART_MIDI1_GetEvent(void) 
    {
        uint8 msgRtn = 0u;
        uint8 rxData;
        #if (MIDI1_UART_RXBUFFERSIZE >= 256u)
            uint16 rxBufferRead;
            #if (CY_PSOC3) /* This local variable is required only for PSOC3 and large buffer */
                uint16 rxBufferWrite;
            #endif /* (CY_PSOC3) */
        #else
            uint8 rxBufferRead;
        #endif /* (MIDI1_UART_RXBUFFERSIZE >= 256u) */

        uint8 rxBufferLoopDetect;
        /* Read buffer loop condition to the local variable */
        rxBufferLoopDetect = MIDI1_UART_rxBufferLoopDetect;

        if ((MIDI1_UART_rxBufferRead != MIDI1_UART_rxBufferWrite) || (rxBufferLoopDetect != 0u))
        {
            /* Protect variables that could change on interrupt by disabling Rx interrupt.*/
            #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                CyIntDisable(MIDI1_UART_RX_VECT_NUM);
            #endif /* ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

            rxBufferRead = MIDI1_UART_rxBufferRead;
            #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                rxBufferWrite = MIDI1_UART_rxBufferWrite;
                CyIntEnable(MIDI1_UART_RX_VECT_NUM);
            #endif /* ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

            /* Stay here until either the buffer is empty or we have a complete message
            *  in the message buffer. Note that we must use a temporary buffer pointer
            *  since it takes two instructions to increment with a wrap, and we can't
            *  risk doing that with the real pointer and getting an interrupt in between
            *  instructions.
            */

            #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                while ( ((rxBufferRead != rxBufferWrite) || (rxBufferLoopDetect != 0u)) && (msgRtn == 0u) )
            #else
                while ( ((rxBufferRead != MIDI1_UART_rxBufferWrite) || (rxBufferLoopDetect != 0u)) && (msgRtn == 0u) )
            #endif /*  ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
                {
                    rxData = MIDI1_UART_rxBuffer[rxBufferRead];
                    /* Increment pointer with a wrap */
                    rxBufferRead++;
                    if (rxBufferRead >= MIDI1_UART_RXBUFFERSIZE)
                    {
                        rxBufferRead = 0u;
                    }

                    /* If loop condition was set - update real read buffer pointer
                    *  to avoid overflow status
                    */
                    if (rxBufferLoopDetect != 0u )
                    {
                        MIDI1_UART_rxBufferLoopDetect = 0u;
                    #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                        CyIntDisable(MIDI1_UART_RX_VECT_NUM);
                    #endif /*  MIDI1_UART_RXBUFFERSIZE >= 256 */

                        MIDI1_UART_rxBufferRead = rxBufferRead;
                    #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                        CyIntEnable(MIDI1_UART_RX_VECT_NUM);
                    #endif /*  MIDI1_UART_RXBUFFERSIZE >= 256 */
                    }

                    msgRtn = USBUART_ProcessMidiIn(rxData,
                                                    (USBUART_MIDI_RX_STATUS *)&USBUART_MIDI1_Event);

                    /* Read buffer loop condition to the local variable */
                    rxBufferLoopDetect = MIDI1_UART_rxBufferLoopDetect;
                }

            /* Finally, update the real output pointer, then return with
            *  an indication as to whether there's a complete message in the buffer.
            */
        #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
            CyIntDisable(MIDI1_UART_RX_VECT_NUM);
        #endif /* ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

        MIDI1_UART_rxBufferRead = rxBufferRead;
        #if ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
            CyIntEnable(MIDI1_UART_RX_VECT_NUM);
        #endif /* ((MIDI1_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
        }

        return (msgRtn);
    }


    /*******************************************************************************
    * Function Name: USBUART_MIDI1_ProcessUsbOut
    ****************************************************************************//**
    *
    *  Process a USB MIDI output event.
    *  Puts data into the MIDI TX output buffer.
    *
    *  \param *epBuf: pointer on MIDI event.
    *
    * \globalvars
    *  USBUART_MIDI1_TxRunStat: This variable used to save the MIDI
    *    status byte and skip to send the repeated status byte in subsequent event.
    *  USBUART_MIDI1_InqFlags: The following flags are set when SysEx
    *    message comes.
    *    USBUART_INQ_SYSEX_FLAG: Non-Real Time SySEx message received.
    *    USBUART_INQ_IDENTITY_REQ_FLAG: Identity Request received.
    *      This bit should be cleared by user when Identity Reply message generated.
    *
    *******************************************************************************/
    void USBUART_MIDI1_ProcessUsbOut(const uint8 epBuf[])
                                                            
    {
        uint8 cmd;
        uint8 len;
        uint8 i;

        /* User code is required at the beginning of the procedure */
        /* `#START MIDI1_PROCESS_OUT_BEGIN` */

        /* `#END` */

    #ifdef USBUART_MIDI1_PROCESS_USB_OUT_ENTRY_CALLBACK
        USBUART_MIDI1_ProcessUsbOut_EntryCallback();
    #endif /* (USBUART_MIDI1_PROCESS_USB_OUT_ENTRY_CALLBACK) */

        cmd = epBuf[USBUART_EVENT_BYTE0] & USBUART_CIN_MASK;

        if ((cmd != USBUART_RESERVED0) && (cmd != USBUART_RESERVED1))
        {
            len = USBUART_MIDI_SIZE[cmd];
            i = USBUART_EVENT_BYTE1;
            /* Universal System Exclusive message parsing */
            if (cmd == USBUART_SYSEX)
            {
                if ((epBuf[USBUART_EVENT_BYTE1] == USBUART_MIDI_SYSEX) &&
                    (epBuf[USBUART_EVENT_BYTE2] == USBUART_MIDI_SYSEX_NON_REAL_TIME))
                {
                    /* Non-Real Time SySEx starts */
                    USBUART_MIDI1_InqFlags |= USBUART_INQ_SYSEX_FLAG;
                }
                else
                {
                    USBUART_MIDI1_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
                }
            }
            else if (cmd == USBUART_SYSEX_ENDS_WITH1)
            {
                USBUART_MIDI1_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
            }
            else if (cmd == USBUART_SYSEX_ENDS_WITH2)
            {
                USBUART_MIDI1_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
            }
            else if (cmd == USBUART_SYSEX_ENDS_WITH3)
            {
                /* Identify Request support */
                if ((USBUART_MIDI1_InqFlags & USBUART_INQ_SYSEX_FLAG) != 0u)
                {
                    USBUART_MIDI1_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
                    if ((epBuf[USBUART_EVENT_BYTE1] == USBUART_MIDI_SYSEX_GEN_INFORMATION) &&
                        (epBuf[USBUART_EVENT_BYTE2] == USBUART_MIDI_SYSEX_IDENTITY_REQ))
                    {
                        /* Set the flag about received the Identity Request.
                        *  The Identity Reply message may be send by user code.
                        */
                        USBUART_MIDI1_InqFlags |= USBUART_INQ_IDENTITY_REQ_FLAG;
                    }
                }
            }
            else /* Do nothing for other command */
            {
            }

            /* Running Status for Voice and Mode messages only. */
            if ((cmd >= USBUART_NOTE_OFF) && (cmd <= USBUART_PITCH_BEND_CHANGE))
            {
                if (USBUART_MIDI1_TxRunStat == epBuf[USBUART_EVENT_BYTE1])
                {
                    /* Skip the repeated Status byte */
                    i++;
                }
                else
                {
                    /* Save Status byte for next event */
                    USBUART_MIDI1_TxRunStat = epBuf[USBUART_EVENT_BYTE1];
                }
            }
            else
            {
                /* Clear Running Status */
                USBUART_MIDI1_TxRunStat = 0u;
            }

            /* Puts data into the MIDI TX output buffer.*/
            do
            {
                MIDI1_UART_PutChar(epBuf[i]);
                i++;
            }
            while (i <= len);
        }

        /* User code is required at the end of the procedure */
        /* `#START MIDI1_PROCESS_OUT_END` */

        /* `#END` */

    #ifdef USBUART_MIDI1_PROCESS_USB_OUT_EXIT_CALLBACK
        USBUART_MIDI1_ProcessUsbOut_ExitCallback();
    #endif /* (USBUART_MIDI1_PROCESS_USB_OUT_EXIT_CALLBACK) */
    }


#if (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF)
    /*******************************************************************************
    * Function Name: USBUART_MIDI2_GetEvent
    ****************************************************************************//**
    *
    *  Checks for incoming MIDI data, calls the MIDI event builder if so.
    *  Returns either empty or with a complete event.
    *
    * \return
    *   0, if no complete message
    *   1 - 4, if message complete
    *   MIDI_SYSEX, if start or continuation of system exclusive
    *   MIDI_EOSEX, if end of system exclusive
    *   0xf8 - 0xff, if single byte real time message
    *
    * \globalvars
    *  USBUART_MIDI2_Event: RX status structure used to parse received
    *    data.
    *
    *******************************************************************************/
    uint8 USBUART_MIDI2_GetEvent(void) 
    {
        uint8 msgRtn = 0u;
        uint8 rxData;

        #if (MIDI2_UART_RXBUFFERSIZE >= 256u)
            uint16 rxBufferRead;
            #if (CY_PSOC3) /* This local variable required only for PSOC3 and large buffer */
                uint16 rxBufferWrite;
            #endif /* (CY_PSOC3) */
        #else
            uint8 rxBufferRead;
        #endif /* (MIDI2_UART_RXBUFFERSIZE >= 256) */

        uint8 rxBufferLoopDetect;
        /* Read buffer loop condition to the local variable */
        rxBufferLoopDetect = MIDI2_UART_rxBufferLoopDetect;

        if ( (MIDI2_UART_rxBufferRead != MIDI2_UART_rxBufferWrite) || (rxBufferLoopDetect != 0u) )
        {
            /* Protect variables that could change on interrupt by disabling Rx interrupt.*/
            #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                CyIntDisable(MIDI2_UART_RX_VECT_NUM);
            #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
            rxBufferRead = MIDI2_UART_rxBufferRead;
            #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                rxBufferWrite = MIDI2_UART_rxBufferWrite;
                CyIntEnable(MIDI2_UART_RX_VECT_NUM);
            #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

            /* Stay here until either the buffer is empty or we have a complete message
            *  in the message buffer. Note that we must use a temporary output pointer to
            *  since it takes two instructions to increment with a wrap, and we can't
            *  risk doing that with the real pointer and getting an interrupt in between
            *  instructions.
            */

            #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                while ( ((rxBufferRead != rxBufferWrite) || (rxBufferLoopDetect != 0u)) && (msgRtn == 0u) )
            #else
                while ( ((rxBufferRead != MIDI2_UART_rxBufferWrite) || (rxBufferLoopDetect != 0u)) && (msgRtn == 0u) )
            #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
                {
                    rxData = MIDI2_UART_rxBuffer[rxBufferRead];
                    rxBufferRead++;
                    if(rxBufferRead >= MIDI2_UART_RXBUFFERSIZE)
                    {
                        rxBufferRead = 0u;
                    }

                    /* If loop condition was set - update real read buffer pointer
                    *  to avoid overflow status
                    */
                    if (rxBufferLoopDetect != 0u)
                    {
                        MIDI2_UART_rxBufferLoopDetect = 0u;
                    #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                        CyIntDisable(MIDI2_UART_RX_VECT_NUM);
                    #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

                        MIDI2_UART_rxBufferRead = rxBufferRead;
                    #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
                        CyIntEnable(MIDI2_UART_RX_VECT_NUM);
                    #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
                    }

                    msgRtn = USBUART_ProcessMidiIn(rxData,
                                                    (USBUART_MIDI_RX_STATUS *)&USBUART_MIDI2_Event);

                    /* Read buffer loop condition to the local variable */
                    rxBufferLoopDetect = MIDI2_UART_rxBufferLoopDetect;
                }

            /* Finally, update the real output pointer, then return with
            *  an indication as to whether there's a complete message in the buffer.
            */
        #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
            CyIntDisable(MIDI2_UART_RX_VECT_NUM);
        #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */

            MIDI2_UART_rxBufferRead = rxBufferRead;
        #if ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3))
            CyIntEnable(MIDI2_UART_RX_VECT_NUM);
        #endif /* ((MIDI2_UART_RXBUFFERSIZE >= 256u) && (CY_PSOC3)) */
        }

        return (msgRtn);
    }


    /*******************************************************************************
    * Function Name: USBUART_MIDI2_ProcessUsbOut
    ****************************************************************************//**
    *
    *  Process a USB MIDI output event.
    *  Puts data into the MIDI TX output buffer.
    *
    *  \param *epBuf: pointer on MIDI event.
    *
    * \globalvars
    *  USBUART_MIDI2_TxRunStat: This variable used to save the MIDI
    *    status byte and skip to send the repeated status byte in subsequent event.
    *  USBUART_MIDI2_InqFlags: The following flags are set when SysEx
    *    message comes.
    *  USBUART_INQ_SYSEX_FLAG: Non-Real Time SySEx message received.
    *  USBUART_INQ_IDENTITY_REQ_FLAG: Identity Request received.
    *    This bit should be cleared by user when Identity Reply message generated.
    *
    *******************************************************************************/
    void USBUART_MIDI2_ProcessUsbOut(const uint8 epBuf[])
                                                            
    {
        uint8 cmd;
        uint8 len;
        uint8 i;

        /* User code is required at the beginning of the procedure */
        /* `#START MIDI2_PROCESS_OUT_START` */

        /* `#END` */

    #ifdef USBUART_MIDI2_PROCESS_USB_OUT_ENTRY_CALLBACK
        USBUART_MIDI2_ProcessUsbOut_EntryCallback();
    #endif /* (USBUART_MIDI2_PROCESS_USB_OUT_ENTRY_CALLBACK) */

        cmd = epBuf[USBUART_EVENT_BYTE0] & USBUART_CIN_MASK;

        if ((cmd != USBUART_RESERVED0) && (cmd != USBUART_RESERVED1))
        {
            len = USBUART_MIDI_SIZE[cmd];
            i = USBUART_EVENT_BYTE1;

            /* Universal System Exclusive message parsing */
            if(cmd == USBUART_SYSEX)
            {
                if((epBuf[USBUART_EVENT_BYTE1] == USBUART_MIDI_SYSEX) &&
                   (epBuf[USBUART_EVENT_BYTE2] == USBUART_MIDI_SYSEX_NON_REAL_TIME))
                {
                    /* SySEx starts */
                    USBUART_MIDI2_InqFlags |= USBUART_INQ_SYSEX_FLAG;
                }
                else
                {
                    USBUART_MIDI2_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
                }
            }
            else if(cmd == USBUART_SYSEX_ENDS_WITH1)
            {
                USBUART_MIDI2_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
            }
            else if(cmd == USBUART_SYSEX_ENDS_WITH2)
            {
                USBUART_MIDI2_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;
            }
            else if(cmd == USBUART_SYSEX_ENDS_WITH3)
            {
                /* Identify Request support */
                if ((USBUART_MIDI2_InqFlags & USBUART_INQ_SYSEX_FLAG) != 0u)
                {
                    USBUART_MIDI2_InqFlags &= (uint8)~USBUART_INQ_SYSEX_FLAG;

                    if((epBuf[USBUART_EVENT_BYTE1] == USBUART_MIDI_SYSEX_GEN_INFORMATION) &&
                       (epBuf[USBUART_EVENT_BYTE2] == USBUART_MIDI_SYSEX_IDENTITY_REQ))
                    {   /* Set the flag about received the Identity Request.
                        *  The Identity Reply message may be send by user code.
                        */
                        USBUART_MIDI2_InqFlags |= USBUART_INQ_IDENTITY_REQ_FLAG;
                    }
                }
            }
            else /* Do nothing for other command */
            {
            }

            /* Running Status for Voice and Mode messages only. */
            if ((cmd >= USBUART_NOTE_OFF) && ( cmd <= USBUART_PITCH_BEND_CHANGE))
            {
                if (USBUART_MIDI2_TxRunStat == epBuf[USBUART_EVENT_BYTE1])
                {   /* Skip the repeated Status byte */
                    i++;
                }
                else
                {   /* Save Status byte for next event */
                    USBUART_MIDI2_TxRunStat = epBuf[USBUART_EVENT_BYTE1];
                }
            }
            else
            {   /* Clear Running Status */
                USBUART_MIDI2_TxRunStat = 0u;
            }

            /* Puts data into the MIDI TX output buffer.*/
            do
            {
                MIDI2_UART_PutChar(epBuf[i]);
                i++;
            }
            while (i <= len);
        }

        /* User code is required at the end of the procedure */
        /* `#START MIDI2_PROCESS_OUT_END` */

        /* `#END` */

    #ifdef USBUART_MIDI2_PROCESS_USB_OUT_EXIT_CALLBACK
        USBUART_MIDI2_ProcessUsbOut_ExitCallback();
    #endif /* (USBUART_MIDI2_PROCESS_USB_OUT_EXIT_CALLBACK) */
    }
#endif /* (USBUART_MIDI_EXT_MODE >= USBUART_TWO_EXT_INTRF) */
#endif /* (USBUART_MIDI_EXT_MODE >= USBUART_ONE_EXT_INTRF) */

#endif  /*  (USBUART_ENABLE_MIDI_API != 0u) */


/* `#START MIDI_FUNCTIONS` Place any additional functions here */

/* `#END` */

#endif  /* defined(USBUART_ENABLE_MIDI_STREAMING) */


/* [] END OF FILE */
