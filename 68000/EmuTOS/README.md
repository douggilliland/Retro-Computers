These binaries have been produced by
[GitHub Actions build #491882600](https://github.com/emutos/emutos/actions/runs/491882600)
for commits [6c4b356d..409c7e05](https://github.com/emutos/emutos/compare/6c4b356d4035...409c7e05c83b).

``commit`` [409c7e05c83b55a0dc663ed9d9b6ed829da4fe2d](https://github.com/emutos/emutos/commit/409c7e05c83b55a0dc663ed9d9b6ed829da4fe2d)   
``Author: Christian Zietz <czietz@gmx.net>``  
``Date:   Sun Jan 17 16:28:29 2021 +0000``  
  
``    Make Kbshift only return the status for any negative argument``  
``    ``  
``    On Atari TOS, any negative argument (not just -1) causes Kbshift``  
``    only to return the current status of the keyboard modifiers without``  
``    changing it.``  
``    ``  
``    This fixes an issue with Jay-MSA v.1.08. Thank you to Matthias Arndt``  
``    for reporting this.``  
  
``M	bios/ikbd.c``  
