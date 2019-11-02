# Requerimientos de memoria


modelo_original <- c("elecciones.ar.2019::descripcion_postulaciones",
                     "elecciones.ar.2019::descripcion_regiones",
                     "elecciones.ar.2019::mesas_totales",
                     "elecciones.ar.2019::mesas_agrp_politicas",
                     "elecciones.ar.2019::medios_sim_leg_nac")

elecciones.ar.2019::mesas_agrp_politicas
size = 0
for (o in modelo_original) {

  os <- object.size(eval(parse(text=o)))
  message(paste0(o, ": "), appendLF = F)
  print(os, units='auto')

  size = size + os
}
message("Requerimiento de memoria del modelo original: ", appendLF = F); print(size, units='auto')


modelo_nuevo <- c("elecciones.ar.2019::agrupaciones",
                  "elecciones.ar.2019::categorias",
                  "elecciones.ar.2019::circuitos",
                  "elecciones.ar.2019::distritos",
                  "elecciones.ar.2019::listas",
                  "elecciones.ar.2019::mesas",
                  "elecciones.ar.2019::meta_agrupaciones",
                  "elecciones.ar.2019::secciones",
                  "elecciones.ar.2019::votos",
                  "elecciones.ar.2019::establecimientos")


size = 0
for (o in modelo_nuevo) {

  os <- object.size(eval(parse(text=o)))
  message(paste0(o, ": "), appendLF = F)
  print(os, units='auto')

  size = size + os
}
message("Requerimiento de memoria del modelo nuevo: ", appendLF = F); print(size, units='auto')

