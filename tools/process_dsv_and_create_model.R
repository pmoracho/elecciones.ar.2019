#' Procesa los dsv de las paso 2019 y genera el modelo de datos.
#' No es necesario correrlo ya que el modelo completo ya se distribuye en
#' el paquete.
#'
process_dsv_and_create_model <- function() {

    require("tidyverse")
    require("paso2019")
    require("stringi")

    read_dsv <- function(file, colClasses) {
        read.table(file, header = TRUE, sep = "|", quote = "", colClasses = colClasses, stringsAsFactors = FALSE, encoding = "UTF-8")
    }

    descripcion_postulaciones <- read_dsv("ext-data/descripcion_postulaciones.dsv", "character")
    descripcion_regiones <- read_dsv("ext-data/descripcion_regiones.dsv","character")
    mesas_totales <- read_dsv("ext-data/mesas_totales.dsv", c(rep("character",6), "numeric"))
    mesas_agrp_politicas <- read_dsv("ext-data/mesas_agrp_politicas.dsv", c(rep("character",7), "numeric"))
    medios_sim_leg_nac <- read_dsv("ext-data/medios_sim_leg_nac.dsv", c("character", "numeric", "character", "character", "integer", "character"))

    ################################################################################################################
    # Meta Agrupaciones
    ################################################################################################################
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

    ################################################################################################################
    # Agrupaciones
    ################################################################################################################
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

    ################################################################################################################
    # Categorias
    ################################################################################################################
    descripcion_postulaciones %>%
        distinct(CODIGO_CATEGORIA, NOMBRE_CATEGORIA) %>%
        mutate(id_categoria = row_number()) %>%
        select(id_categoria,
               codigo_categoria = CODIGO_CATEGORIA,
               nombre_categoria = NOMBRE_CATEGORIA) %>%
        as.data.frame() -> categorias

    ################################################################################################################
    # Distritos
    ################################################################################################################
    mesas_agrp_politicas %>%
        distinct(CODIGO_DISTRITO) %>%
        left_join(descripcion_regiones, by = c('CODIGO_DISTRITO' = "CODIGO_REGION")) %>%
        mutate(id = row_number()) %>%
        select(id_distrito = id,
               codigo_distrito = CODIGO_DISTRITO,
               nombre_distrito = NOMBRE_REGION) %>%
        as.data.frame() -> distritos

    ################################################################################################################
    # Secciones
    ################################################################################################################
    mesas_agrp_politicas %>%
        distinct(CODIGO_SECCION) %>%
        full_join(paso2019::mesas_totales_lista %>%
                      distinct(CODIGO_SECCION),
                  by = c("CODIGO_SECCION")) %>%
        left_join(descripcion_regiones, by = c('CODIGO_SECCION' = "CODIGO_REGION")) %>%
        mutate(id = row_number()) %>%
        select(id_seccion = id,
               codigo_seccion = CODIGO_SECCION ,
               nombre_seccion = NOMBRE_REGION)  %>%
        as.data.frame() -> secciones

    ################################################################################################################
    # Circuitos
    ################################################################################################################
    mesas_agrp_politicas %>%
        distinct(CODIGO_CIRCUITO) %>%
        full_join(paso2019::mesas_totales_lista %>%
                      distinct(CODIGO_CIRCUITO),
                  by = c("CODIGO_CIRCUITO")) %>%
        left_join(descripcion_regiones, by = c('CODIGO_CIRCUITO' = "CODIGO_REGION")) %>%
        mutate(id_circuito = row_number()) %>%
        select(id_circuito,
               codigo_circuito = CODIGO_CIRCUITO,
               nombre_circuito = NOMBRE_REGION) %>%
        as.data.frame() -> circuitos



    ################################################################################################################
    # Listas
    ################################################################################################################
    descripcion_postulaciones %>%
        distinct(CODIGO_LISTA) %>%
        full_join(paso2019::descripcion_postulaciones %>%
                      distinct(CODIGO_LISTA),
                  by = "CODIGO_LISTA") %>%
        left_join(descripcion_postulaciones %>%
                      distinct(CODIGO_LISTA, NOMBRE_LISTA, CODIGO_AGRUPACION),
                  by="CODIGO_LISTA") %>%
        left_join(paso2019::descripcion_postulaciones %>%
                      distinct(CODIGO_LISTA, NOMBRE_LISTA, CODIGO_AGRUPACION),
                  by="CODIGO_LISTA") %>%
        mutate(CODIGO_LISTA,
               NOMBRE_LISTA = ifelse(is.na(NOMBRE_LISTA.x), NOMBRE_LISTA.y, NOMBRE_LISTA.x),
               CODIGO_AGRUPACION = ifelse(is.na(CODIGO_AGRUPACION.x), CODIGO_AGRUPACION.y, CODIGO_AGRUPACION.x)
        ) %>%
        select(CODIGO_LISTA, NOMBRE_LISTA, CODIGO_AGRUPACION) %>%
        union(data.frame(CODIGO_LISTA = "Voto blanco",
                         NOMBRE_LISTA = "VOTOS en BLANCO",
                         CODIGO_AGRUPACION = "VB",
                         stringsAsFactors = FALSE)
        ) %>%
        left_join(agrupaciones, by = c("CODIGO_AGRUPACION" = "codigo_agrupacion")) %>%
        arrange(CODIGO_LISTA) %>%
        mutate(id_lista = row_number()) %>%
        select(id_lista, id_agrupacion, codigo_lista = CODIGO_LISTA, nombre_lista = NOMBRE_LISTA) %>%
        as.data.frame() -> listas


    ################################################################################################################
    # Mesas
    ################################################################################################################
    mesas_agrp_politicas %>%
        distinct(CODIGO_MESA, CODIGO_DISTRITO, CODIGO_SECCION, CODIGO_CIRCUITO) %>%
        full_join(paso2019::mesas_totales_lista %>%
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


    ################################################################################################################
    # Votos
    ################################################################################################################
    mesas_agrp_politicas %>%
        distinct(CODIGO_MESA, CODIGO_CATEGORIA, CODIGO_LISTA, VOTOS_AGRUPACION) %>%
        full_join(paso2019::mesas_totales_lista %>%
                      distinct(CODIGO_MESA, CODIGO_CATEGORIA, CODIGO_LISTA, VOTOS_LISTA),
                  by = c("CODIGO_MESA", "CODIGO_CATEGORIA", "CODIGO_LISTA")) %>%
        union_all(
            mesas_totales %>%
                filter(CONTADOR == "Voto blanco") %>%
                distinct(CODIGO_MESA, CODIGO_CATEGORIA, VALOR) %>%
                full_join(paso2019::mesas_totales %>%
                              filter(CONTADOR == "VB") %>%
                              distinct(CODIGO_MESA, CODIGO_CATEGORIA, VALOR),
                          by = c("CODIGO_MESA", "CODIGO_CATEGORIA")
                ) %>%
                mutate(CODIGO_LISTA = "Voto blanco") %>%
                select(CODIGO_MESA,
                       CODIGO_CATEGORIA,
                       CODIGO_LISTA,
                       VOTOS_AGRUPACION = VALOR.x,
                       VOTOS_LISTA = VALOR.x)
        ) %>%
        left_join(categorias, by=c("CODIGO_CATEGORIA" = "codigo_categoria")) %>%
        left_join(listas, by=c("CODIGO_LISTA" = "codigo_lista")) %>%
        left_join(mesas, by=c("CODIGO_MESA" = "codigo_mesa")) %>%
        mutate(id_voto = row_number(),
               votos = ifelse(is.na(VOTOS_AGRUPACION), 0, VOTOS_AGRUPACION),
               votos_paso = ifelse(is.na(VOTOS_LISTA), 0, VOTOS_LISTA)
        ) %>%
        select(id_voto,
               id_mesa,
               id_categoria,
               id_lista,
               votos,
               votos_paso) %>%
        as.data.frame() -> votos

    # Actualizo escrutadas
    mesas %>%
        left_join(votos %>%
                      group_by(id_mesa) %>%
                      summarise(votos = sum(votos),
                                escrutada = votos > 0),
                  by  = "id_mesa"
        ) %>%
        select(id_mesa,
               id_distrito,
               id_seccion,
               id_circuito,
               codigo_mesa,
               escrutada) -> mesas

    # rehacemos mesas para agregar el id del establecimiento
    mesas %>%
        left_join(
            paso2019::scrap_establecimientos_mesas %>%
                distinct(codigo_establecimiento,codigo_circuito,nombre_establecimiento,codigo_mesa),
            by = "codigo_mesa") %>%
        left_join(establecimientos, by = "codigo_establecimiento") %>%
        select(id_mesa,
               id_distrito = id_distrito.x,
               id_seccion = id_seccion.x,
               id_circuito = id_circuito.x,
               id_establecimiento,
               codigo_mesa,
               escrutada) -> mesas



    # Totales de votos por categoria
    categorias %>%
        left_join(votos, by = "id_categoria") %>%
        group_by(id_categoria) %>%
        summarize(votos_totales = sum(ifelse(id_lista != 1761, votos, 0)),
                  votos_totales_paso = sum(votos_paso)) %>%
        left_join(categorias, by="id_categoria") %>%
        select(id_categoria,
               codigo_categoria,
               nombre_categoria,
               votos_totales,
               votos_totales_paso)  %>%
        as.data.frame() -> categorias


    usethis::use_data(meta_agrupaciones, overwrite = TRUE)
    usethis::use_data(agrupaciones, overwrite = TRUE)
    usethis::use_data(categorias, overwrite = TRUE)
    usethis::use_data(listas, overwrite = TRUE)
    usethis::use_data(mesas, overwrite = TRUE)
    usethis::use_data(votos, overwrite = TRUE)
    usethis::use_data(distritos, overwrite = TRUE)
    usethis::use_data(secciones, overwrite = TRUE)
    usethis::use_data(circuitos, overwrite = TRUE)
    usethis::use_data(establecimientos, overwrite = TRUE)

    usethis::use_data(descripcion_postulaciones, overwrite = TRUE)
    usethis::use_data(descripcion_regiones, overwrite = TRUE)
    usethis::use_data(mesas_totales, overwrite = TRUE)
    usethis::use_data(mesas_agrp_politicas, overwrite = TRUE)
    usethis::use_data(medios_sim_leg_nac, overwrite = TRUE)


    # glimpse(meta_agrupaciones)
    # glimpse(agrupaciones)
    # glimpse(categorias)
    # glimpse(listas)
    # glimpse(mesas)
    # glimpse(votos)
    # glimpse(distritos)
    # glimpse(secciones)
    # glimpse(circuitos)
    # glimpse(establecimientos)

}
