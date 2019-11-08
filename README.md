<!-- badges: start -->
  [![Travis build status](https://travis-ci.org/pmoracho/paso2019.svg?branch=master)](https://travis-ci.org/pmoracho/elecciones.ar.2019)
<!-- badges: end -->


# elecciones.ar.2019

Paquete de datos con los resultados del escrutinio de las "Elecciones Nacionales 2019" de Argentina, tal cual como los publica la **[Dirección Nacional Electoral (DINE)](https://www.argentina.gob.ar/interior/dine)**. Este paquete se puede complementar con el de las [paso2019](https://github.com/pmoracho/paso2019).

## Contenido

### Datos

Los datos están actualizados al `28/10/2019 02:46 AM (-03:00 UTC)` según informa la **DINE**.

#### Modelo original

El modelo original representa las tablas originales distribuidas por la justicia electoral, tal cual se pueden acceder desde: https://resultados2019.gob.ar/resultados_detalle.zip. Los archivos (de tipo DSV), fueron importados sin ninguna transformación importante, son `data.frames` básicos, la mayoría de las columnas son `character`, salvo las que representan cantidades de votos que son numéricas.

* descripcion_postulaciones (210.1 Kb)
* descripcion_regiones (836 kb)
* mesas_totales (141.7 mb)
* mesas_totales_agrp_politicas (114.7 mb)
* medios_sim_leg_nac (10.6 Kb)

Requerimiento de memoria total: **257.4 Mb**

#### Modelo nuevo

![Modelo nuevo](doc/img/modelo_paso2019.png)

Son tablas derivadas de las anteriores. La idea es transformar los datos en tablas que respeten mejor un modelo relacional. Estas tablas están en pleno procesos de creación y modificación, eventualmente podrá cambiar algo.

* agrupaciones (14 kb)
* categorias (52.1 kb)
* circuitos (785.9 Kb)
* distritos (4.3 kb)
* listas (319.9 kb)
* mesas (9.3 mb)
* meta_agrupaciones (10.8 kb)
* secciones (67.9 kb)
* votos (131.7 MB)
* establecimientos (2.3 Mb)

Requerimiento de memoria total: **114.5 Mb**

Este modelo elimina mucha de la redundancia de datos de los archivos originales, se generaron también `id's` numéricos para cada tabla, y así reducir los requerimientos de memoria. Claro, que las consultas requieren ir agregando varias relaciones. Asimismo, **en este paquete integramos los resultados de las paso 2019**, la misma información que podemos encotrar en el paquete `pmoracho/paso2019`. 

Por ejemplo, para consultar el total de votos de cada agrupación en la elección de presidente, habría que hacer algo así:

    library("tidyverse")
    library("elecciones.ar.2019")

    ############################################################################
    # Resultados de la Eleccion     
    ############################################################################
    votos %>% 
        left_join(listas, by = "id_lista") %>% 
        left_join(agrupaciones, by = "id_agrupacion") %>% 
        left_join(categorias, by = "id_categoria") %>% 
        left_join(meta_agrupaciones, by = "id_meta_agrupacion") %>% 
        filter(nombre_categoria == "Presidente y Vicepresidente de la República") %>% 
        group_by(nombre_meta_agrupacion, votos_totales) %>% 
        summarise(votos = sum(votos)) %>% 
        mutate(porcentaje = votos / votos_totales) %>% 
        select(nombre_meta_agrupacion, votos, porcentaje ) %>% 
        arrange(-votos) -> elecciones
      
    ############################################################################
    # Resultados de las Paso
    ############################################################################
    votos %>% 
        left_join(listas, by = "id_lista") %>% 
        left_join(agrupaciones, by = "id_agrupacion") %>% 
        left_join(categorias, by = "id_categoria") %>% 
        left_join(meta_agrupaciones, by = "id_meta_agrupacion") %>% 
        filter(nombre_categoria == "Presidente y Vicepresidente de la República") %>% 
        group_by(nombre_meta_agrupacion, votos_totales_paso) %>% 
        summarise(votos = sum(votos_paso)) %>% 
        mutate(porcentaje = votos / votos_totales_paso) %>% 
        select(nombre_meta_agrupacion, votos, porcentaje ) %>% 
        arrange(-votos) -> paso
    
    
    elecciones %>% 
        full_join(paso, by = c("nombre_meta_agrupacion")) %>% 
        mutate(votos_eleccion=votos.x,
               porcentaje_eleccion = porcentaje.x,  
               votos_paso = votos.y,
               porcentaje_paso = porcentaje.y,
               dif_votos = votos_eleccion - votos_paso,
               dif_porcentaje = porcentaje_eleccion - porcentaje_paso,
               variacion_votos = (votos_eleccion - votos_paso)/votos_paso) %>% 
        select(agrupacion = nombre_meta_agrupacion,
               votos_eleccion, 
               porcentaje_eleccion,
               votos_paso,
               porcentaje_paso,
               dif_votos,
               dif_porcentaje,
               variacion_votos
               )
    
    # A tibble: 11 x 8
    # Groups:   agrupacion [11]
       agrupacion         votos_eleccion porcentaje_elec~ votos_paso porcentaje_paso dif_votos dif_porcentaje variacion_votos
       <chr>                       <dbl>            <dbl>      <dbl>           <dbl>     <dbl>          <dbl>           <dbl>
     1 FRENTE DE TODOS          12473709           0.481    11622428         0.477      851281        0.00447          0.0732
     2 JUNTOS POR EL CAM~       10470607           0.404     7825208         0.321     2645399        0.0829           0.338 
     3 CONSENSO FEDERAL          1599707           0.0617    2007035         0.0823    -407328       -0.0206          -0.203 
     4 FRENTE DE IZQUIER~         561214           0.0216     697776         0.0286    -136562       -0.00697         -0.196 
     5 FRENTE NOS                 443507           0.0171     642662         0.0264    -199155       -0.00925         -0.310 
     6 VOTOS en BLANCO            399751           0.0154     758988         0.0311    -359237       -0.0157          -0.473 
     7 UNITE POR LA LIBE~         382820           0.0148     533100         0.0219    -150280       -0.00710         -0.282 
     8 FRENTE PATRIOTA                 0           0           58575         0.00240    -58575       -0.00240         -1     
     9 MOVIMIENTO AL SOC~              0           0          173585         0.00712   -173585       -0.00712         -1     
    10 MOVIMIENTO DE ACC~              0           0           36324         0.00149    -36324       -0.00149         -1     
    11 PARTIDO AUTONOMIS~              0           0           32562         0.00134    -32562       -0.00134         -1     
Los procesos de importación, tanto de los archivos, como los de la "captura" de los datos de la web, como así también la creación del nuevo modelo, puede consultarse y verificarse mirando los scripts (en el orden de ejecución):

* `tools/download_and_process_establecimientos.R`: descarga y procesa todos los archivos `json` para generar la tabla de `scrap_establecimientos_mesas`, dónde tenemos código de mesa y nombre del establecimiento
* `tools/process_dsv_and_create_model.R`: Procesamos los DSV originales, para crear las tablas originales y el nuevo modelo

### Funciones

* **get_telegrama_url()**: Para generar la url de la imagen digitalizada del telegrama
* **view_telegrama()**: Para ver la imagen del telegrama

## Instalación

Como cualquier otro paquete mantenido en github.com, el proceso es relativamente sencillo. En primer lugar necesitaremos `devtools`:

    install.packages("devtools")

una vez instalada este paquete, simplemente podremos instalar `elecciones.ar.2019` directamente desde el código fuente del repositorio:

    devtools::install_github("pmoracho/elecciones.ar.2019")

## Requerimientos

Ninguno en particular, salvo `devtools` para poder instalar este paquete, son datos, y eventualmente alguna que otra función que en principio intentaré que no requiera ningún paquete extra. 

## Actualizaciones

* 2019/11/02 - Inicio del proyecto
