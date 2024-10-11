-- ======================================================================
-- USBFS_UART01.ctl generated from USBFS_UART01
-- 09/27/2019 at 12:13
-- This file is auto generated. ANY EDITS YOU MAKE MAY BE LOST WHEN THIS FILE IS REGENERATED!!!
-- ======================================================================

-- I2C

-- TopDesign
-- =============================================================================
-- The following directives assign pins to the locations specific for the
-- CY8CKIT-030 kit.
-- =============================================================================

-- === USBFS ===
attribute port_location of \USBUART:Dp(0)\   : label is "PORT(15,6)";
attribute port_location of \USBUART:Dm(0)\   : label is "PORT(15,7)";


-- === LCD ===
attribute port_location of \LCD:LCDPort(0)   : label is "PORT(2,0)";

-- PSoC Clock Editor
-- Directives Editor
-- Analog Device Editor
