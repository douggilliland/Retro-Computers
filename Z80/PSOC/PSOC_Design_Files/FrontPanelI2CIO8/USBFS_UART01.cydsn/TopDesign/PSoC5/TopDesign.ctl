-- =============================================================================
-- The following directives assign pins to the locations specific for the
-- CY8CKIT-030 kit.
-- =============================================================================

-- === USBFS ===
attribute port_location of \USBUART:Dp(0)\   : label is "PORT(15,6)";
attribute port_location of \USBUART:Dm(0)\   : label is "PORT(15,7)";


-- === LCD ===
attribute port_location of \LCD:LCDPort(0)   : label is "PORT(2,0)";
