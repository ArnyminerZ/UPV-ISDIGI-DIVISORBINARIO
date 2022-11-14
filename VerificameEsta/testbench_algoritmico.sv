
// Importamos el archivo del módulo
`include "../Divisor_Algoritmico.sv"

// Declaramos el nombre del módulo
`define MODULO Divisor_Algoritmico

// Declaramos el nombre que asignar al testbench
`define NOMBRE_TESTBENCH testbench_algoritmico

// Para controlar parámetros genéricos como DEBUG, el objetivo del coverage,
// o el tamaño de bits, modificar testbench.sv

`include "testbench.sv"
