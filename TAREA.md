Vamos a diseñar y verificar un divisor binario. Desde el punto de vista del diseño vamos a practicar conocimientos previos vistos de cursos anteriores sobre diseños especificados mediante ASM. El diseño ya tiene una cierta complejidad y queremos que el desarrollo de la tarea os guíe paso a paso sobre la forma  de proceder bottom-up  ordenada. Desde el punto de vista de la verificación el aspecto más interesante será desarrollar completamente desde cero un banco de pruebas en systemVerilog con la estructura y componentes típicos de los bancos de verificación más modernos:  program, RCSG, cobertura funcional, clases, modelos de referencia, interfaces,  bloques de reloj, aserciones, etc.

# OBJETIVOS
* Implementación directa de ASM mediante systemVerilog
* Ejercitar la realización de bancos de pruebas con systemVerilog con RCSG, cobertura funcional, clases, modelos de referencia, interfaces, bloques de reloj y aserciones.

# CONOCIMIENTOS PREVIOS
Los conocimientos previos necesarios para la realización de esta práctica están centrados fundamentalmente en el bloque de teoría de particionado y diseño arquitectural del curso anterior, si bien vamos a plantear una implementación directa del ASM mediante un único fichero systemVerilog, que implementará de forma única tanto el Control-Path como el Data-Path. Haciendo referencia a los circuitos aritméticos secuenciales se pueden consultar los siguientes libros. Creo que es un conocimiento interesante de formas de hacer las cosas cuando los recursos son caros y limitados. No suele haber tiempo en la estructura actual de los títulos para este tipo de conocimientos; pero cuando vayáis a trabajar puede proporcionaros soluciones interesantes que conviene que tengáis en cuenta.

# ESQUEMA DE LA TAREA
1. Diseño en SystemVerilog  del divisor y posterior verificación
2. Compilación del diseño sobre una FPGA. Simulación lógica del "top".
3. Diseño y verificación de opción segmentada
4. Configuración de la FPGA y verificación del funcionamiento en la placa.
5. Entrega al final del proyecto generado.

# ESPECIFICACIÓN DEL DIVISOR EN COMPLEMENTO A DOS
El código ASM de la solución lo tenemos en la siguiente figura:
![Divisor Algoritmico](./img/Divisor_algoritmico.jpg)

Las señales externas que permiten el acceso al divisor actuando como entradas o como salidas son:

![Entradas y salidas](./img/Divisor_Alg2.svg)

## Generics
| Generic Name | Type | Value | Description |
|--------------|------|-------|-------------|
|`tamanyo`     |      |       |             |

## Ports
| Generic Name | Type   | Value         | Description                               |
|--------------|--------|---------------|-------------------------------------------|
|`CLK`         |`input` |               | Reloj                                     |
|`RSTa`        |`input` |               | Reset asíncrono, activa a nivel bajo      |
|`Start`       |`input` |               | Empieza la operación, activa a nivel alto |
|`Num`         |`input` |`[tamanyo-1:0]`| Numerador                                 |
|`Den`         |`input` |`[tamanyo-1:0]`| Denominador                               |
|`Coc`         |`output`|`[tamanyo-1:0]`| Cociente                                  |
|`Res`         |`output`|`[tamanyo-1:0]`| Resto                                     |
|`Done`        |`output`|               | Fin de la operación                       |

# DESARROLLO DE LA TAREA
Vamos a intentar reproducir en el desarrollo de la práctica la metodología de diseño y verificación adecuada para afrontar diseños de mediana complejidad. Cuando los diseños son más complejos, no todas estas etapas son asumidas por un único grupo pero no se difiere excesivamente en la evolución de las etapas que son las siguientes.

