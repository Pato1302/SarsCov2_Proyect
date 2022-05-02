#Código para identificar las secuencias codificantes de un genoma completo

# Antonio Noguerón.
#A01423759@tec.mx
# 01 / 05 / 2022

cat("\f")

#Importamos la librería para poder leer archivos en formato fasta
library(seqinr)
genome = read.fasta("Archivos/wuhan_complete_sequence.fasta")

#Extraemos del archivo fasta la cadena de caracteres y los ponemos en mayúsculas.
ADNprimario = genome[[1]]
ADNprimario = toupper(ADNprimario)

# Creamos la función que nos transforma el ADN primario al ARN mensajero
# En la célula se crearía el ADN complementario cambiando los nucleótidos con su correspondiente
# pareja A -> T, G -> C , T -> A, C -> G. Después se cambiaría a ARN mensajero realizando 
# un proceso similar pero ahora cambiando las A -> U. Lo que resultaría en que a la secuencia de ADN
# principal solo se le cambian las T's por U's T -> U y de esa manera obtenemos el ARNm.

ADN_to_ARNm = function(nucleotido){
  return (switch(nucleotido,"C"="C","G"="G","T"="U","A"="A"))
}

ARNmensajero = as.vector(sapply(ADNprimario, ADN_to_ARNm))
ARNmensajero = unlist(ARNmensajero)
ARNmensajero = paste(ARNmensajero,collapse="")

longitud = nchar(ARNmensajero)

inicios = c()
finales = c()


print(substr(ARNmensajero,25382,25384))

ultimoindice = 0

for(i in seq(1,longitud,1)){
  codonInicio = substr(ARNmensajero,i,i+2)
  if(codonInicio == "AUG" & (i > ultimoindice)){
    inicios = append(inicios,i)
    for(a in seq(i+3,longitud,3)){
      codonParo = substr(ARNmensajero,a,a+2)
      if(codonParo=="UAA" | codonParo=="UAG" | codonParo=="UGA"){
        finales = append(finales,a+2)
        ultimoindice = a+2
        break
      }
    }
  }
}

exones = c()
intrones = c(substr(ARNmensajero,1,inicios[1]-1))

for(i in seq(1,min(c(length(inicios),length(finales))),1)){
  exones = append(exones,substr(ARNmensajero,inicios[i],finales[i]))
  intrones = append(intrones,substr(ARNmensajero,finales[i]+1,inicios[i+1]-1))
}

exones
intrones


