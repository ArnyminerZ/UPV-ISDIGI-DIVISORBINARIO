
// Importamos el archivo del módulo
`include "../Dividor_Segmentado.sv"

// Declaramos el nombre del módulo
`define MODULO Dividor_Segmentado

// Declaramos el nombre que asignar al testbench
`define NOMBRE_TESTBENCH testbench_segmentado

// Para controlar parámetros genéricos como DEBUG, el objetivo del coverage,
// o el tamaño de bits, modificar testbench.sv

`include "testbench.sv"
