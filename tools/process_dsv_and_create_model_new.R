library("tidyverse")
library("paso2019")
library("stringi")


# Meta Agrupaciones
descripcion_postulaciones %>%
    distinct(NOMBRE_AGRUPACION) %>%
    mutate(NOMBRE_AGRUPACION = stri_trans_general(NOMBRE_AGRUPACION,"Latin-ASCII")) %>%
    full_join(paso2019::descripcion_postulaciones %>%
                  distinct(NOMBRE_AGRUPACION) %>%
                  mutate(NOMBRE_AGRUPACION = stri_trans_general(NOMBRE_AGRUPACION,"Latin-ASCII")),
              by = "NOMBRE_AGRUPACION") %>%
    union(data.frame(NOMBRE_AGRUPACION="VOTOS en BLANCO", stringsAsFactors = FALSE)) %>%
    arrange(NOMBRE_AGRUPACION) %>%
    mutate(id_meta_agrupacion = row_number(),
           nombre_meta_agrupacion = NOMBRE_AGRUPACION) %>%
    select(id_meta_agrupacion, nombre_meta_agrupacion) %>%
    as.data.frame() -> meta_agrupaciones

# Agrupaciones
descripcion_postulaciones %>%
    distinct(CODIGO_AGRUPACION, NOMBRE_AGRUPACION) %>%
    mutate(NOMBRE_AGRUPACION = stri_trans_general(NOMBRE_AGRUPACION,"Latin-ASCII")) %>%
    union(data.frame(CODIGO_AGRUPACION="VB", NOMBRE_AGRUPACION="VOTOS en BLANCO", stringsAsFactors = FALSE)) %>%
    full_join(paso2019::descripcion_postulaciones %>%
                  distinct(CODIGO_AGRUPACION, NOMBRE_AGRUPACION) %>%
                  mutate(NOMBRE_AGRUPACION = stri_trans_general(NOMBRE_AGRUPACION,"Latin-ASCII")),
              by = c("CODIGO_AGRUPACION")) %>%
    mutate(id_agrupacion = row_number(),
           nombre_agrupacion = ifelse(is.na(NOMBRE_AGRUPACION.x), NOMBRE_AGRUPACION.y, NOMBRE_AGRUPACION.x)) %>%
    left_join(meta_agrupaciones, by = c("nombre_agrupacion" = "nombre_meta_agrupacion")) %>%
    select(id_agrupacion, id_meta_agrupacion, codigo_agrupacion = CODIGO_AGRUPACION) %>%
    as.data.frame() -> agrupaciones

# Categorias
descripcion_postulaciones %>%
    distinct(CODIGO_CATEGORIA, NOMBRE_CATEGORIA) %>%
    mutate(id_categoria = row_number()) %>%
    select(id_categoria,
           codigo_categoria = CODIGO_CATEGORIA,
           nombre_categoria = NOMBRE_CATEGORIA) %>%
    as.data.frame() -> categorias

# Distritos
mesas_agrp_politicas %>%
    distinct(CODIGO_DISTRITO) %>%
    left_join(descripcion_regiones, by = c('CODIGO_DISTRITO' = "CODIGO_REGION")) %>%
    mutate(id = row_number()) %>%
    select(id_distrito = id,
           codigo_distrito = CODIGO_DISTRITO,
           nombre_distrito = NOMBRE_REGION) %>%
    as.data.frame() -> distritos

# Secciones
mesas_agrp_politicas %>%
    distinct(CODIGO_SECCION) %>%
    full_join(paso2019::mesas_totales_agrp_politica %>%
                  distinct(CODIGO_SECCION),
              by = c("CODIGO_SECCION")) %>%
    left_join(descripcion_regiones, by = c('CODIGO_SECCION' = "CODIGO_REGION")) %>%
    mutate(id = row_number()) %>%
    select(id_seccion = id,
           codigo_seccion = CODIGO_SECCION ,
           nombre_seccion = NOMBRE_REGION)  %>%
    as.data.frame() -> secciones

# Circuitos
mesas_agrp_politicas %>%
    distinct(CODIGO_CIRCUITO) %>%
    full_join(paso2019::mesas_totales_agrp_politica %>%
                  distinct(CODIGO_CIRCUITO),
              by = c("CODIGO_CIRCUITO")) %>%
    left_join(descripcion_regiones, by = c('CODIGO_CIRCUITO' = "CODIGO_REGION")) %>%
    mutate(id_circuito = row_number()) %>%
    select(id_circuito,
           codigo_circuito = CODIGO_CIRCUITO,
           nombre_circuito = NOMBRE_REGION) %>%
    as.data.frame() -> circuitos

# Mesas
mesas_agrp_politicas %>%
    distinct(CODIGO_MESA, CODIGO_DISTRITO, CODIGO_SECCION, CODIGO_CIRCUITO) %>%
    full_join(paso2019::mesas_totales_agrp_politica %>%
                  distinct(CODIGO_MESA, CODIGO_DISTRITO, CODIGO_SECCION, CODIGO_CIRCUITO),
              by = c("CODIGO_MESA")) %>%
    mutate(id_mesa = row_number(),
           codigo_distrito = ifelse(is.na(CODIGO_DISTRITO.x), CODIGO_DISTRITO.y, CODIGO_DISTRITO.x),
           codigo_seccion = ifelse(is.na(CODIGO_SECCION.x), CODIGO_SECCION.y, CODIGO_SECCION.x),
           codigo_circuito = ifelse(is.na(CODIGO_CIRCUITO.x), CODIGO_CIRCUITO.y, CODIGO_CIRCUITO.x)
    ) %>%
    left_join(distritos, by = "codigo_distrito") %>%
    left_join(secciones, by = c('codigo_seccion' = "codigo_seccion")) %>%
    left_join(circuitos, by = c('codigo_circuito' = "codigo_circuito")) %>%
    mutate(id_mesa = row_number()) %>%
    select(id_mesa,
           id_distrito,
           id_seccion,
           id_circuito,
           codigo_mesa = CODIGO_MESA) %>%
    as.data.frame() -> mesas
