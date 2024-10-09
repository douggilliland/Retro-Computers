[Previous: Next Steps](A_NextSteps.md)
---

# Supporting Older Cards

I've only bothered to support SDHC cards or newer, as the API changed a bit for
SDHC and anything older feels obsolete these days anyway.

If, however, you do need to support older cards, here are some pointers:

* CMD8 might fail, but you can ignore it; it's required for SDHC but may not
have been required before

* ACMD41 will fail (possibly at the CMD55 stage) - if this happens, it's an
older card, so fall back to polling CMD1 instead of ACMD41 to complete the
initialization

* Small cards (<4GB) may (or may not?) start up in byte-offset mode instead of
sector-offset mode, where the parameter to CMD17 (read sector) and similar
commands will be in bytes rather than sectors.  I believe you can use CMD16
to change this to 512-byte units if you want to use SDHC-compatible code on
the older cards.

As always, refer to <http://elm-chan.org/docs/mmc/mmc_e.html> for more details.

---
[Contents](../README.md)
