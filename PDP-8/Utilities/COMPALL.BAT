tcc -w -G -O -DPC dumprx01.c ents.lib > t
tcc -w -G -O -DPC restrx01.c ents.lib >> t
tcc -w -G -O -DPC dumprk05.c ents.lib >> t
tcc -w -G -O -DPC restrk05.c ents.lib >> t
tcc -w -G -O -DPC dumptd8e.c ents.lib >> t
tcc -w -G -O -DPC resttd8e.c ents.lib >> t
tcc -w -G -O -DPC sendtape.c ents.lib >> t
type t | more
