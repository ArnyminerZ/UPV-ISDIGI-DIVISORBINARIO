// La clase bus nos proporciona las constraints que nos permiten
// detallar qué queremos comprobar.
class RCSG;
randc logic signed [`LAST_BIT:0] num;
randc logic signed [`LAST_BIT:0] den;

// Para limitar a sólo denominadores positivos o negativos
constraint num_positivo {num[`LAST_BIT] == 1'b0;}
constraint num_negativo {num[`LAST_BIT] == 1'b1;}

// Para limitar a sólo numeradores positivos o negativos
constraint den_positivo {den[`LAST_BIT] == 1'b0;}
constraint den_negativo {den[`LAST_BIT] == 1'b1;}

// Como bien sabemos denominador nulo implica un estado ilegalisimo ya que no podemos dividir entre 0, evitando asi uno de los estados mas ilegales que podamos imaginar
constraint den_nozero {den != 0;}

// Para limitar a resultados sin residuo
constraint div_exactaaa {num%den == 0;}

// Limitamos el valor máximo, para dejar sitio para el signo. No
// desactivar esta constraint.
// Nota:
// - 2^15 = 32768      -> 16 bits
// - 2^31 = 2147483648 -> 32 bits
// constraint lim_grandeee {(abs(num)<32768) && (abs(den)<32768);}
endclass
