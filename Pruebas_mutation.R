#Código para analizar mutaciones en varios genes comparando 2 secuencias

cat("\f")

library(seqinr)

original = read.fasta("Archivos/Wuhan_coding_sequences.txt")

df = data.frame(
  pais = character(),
  gen = character(),
  mutation = character(),
  nucleo = numeric(),
  codon = character(),
  protein = character(),
  index = numeric(),
  protein_change = logical()
)

abreviatura = function(codon){
  return(switch(codon,"GAC"="D","GAU"="D",
                "GAA"="E","GAG"="E",
                "CGA"="R","CGC"="R","CGG"="R","CGU"="R","AGA"="R","AGG"="R",
                "AAA"="K","AAG"="K",
                "AAC"="N","AAU"="N",
                "CAC"="H","CAU"="H",
                "CAA"="Q","CAG"="Q",
                "UCA"="S","UCC"="S","UCG"="S","UCU"="S","AGC"="S","AGU"="S",
                "ACA"="T","ACC"="T","ACG"="T","ACU"="T",
                "GCA"="A","GCC"="A","GCG"="A","GCU"="A",
                "GGA"="G","GGC"="G","GGG"="G","GGU"="G",
                "GUA"="V","GUC"="V","GUG"="V","GUU"="V",
                "CCA"="P","CCC"="P","CCG"="P","CCU"="P",
                "CUA"="L","CUC"="L","CUG"="L","CUU"="L","UUA"="L","UUG"="L",
                "UUC"="F","UUU"="F",
                "UAC"="Y","UAU"="Y",
                "AUA"="I","AUC"="I","AUU"="I",
                "AUG"="M",
                "UGG"="W",
                "UGC"="C","UGU"="C"))
}

adn_to_arnm = function(elemento){
  return (switch(elemento,"C"="C","G"="G","A"="A","T"="U"))
}

Mutaciones = function(original, vector_paises){
  for (p in seq (1,length(vector_paises),1)) {
    mexican = read.fasta(paste(c("Archivos/first_B_sequences/first_B_",vector_paises[p],".txt"),collapse=""))
    genWuhan = original[[3]]
    genWuhan = toupper(genWuhan)
    genWuhan = as.vector(sapply(genWuhan,adn_to_arnm))
    
    
    for (find_gen in seq(1,12,1)) {
      genMexico = mexican[[find_gen]]
      attr1 = attr(genMexico,"Annot")
      vec = unlist(strsplit(attr1,"\\[|\\]|:|=|\\."))
      gen = vec[which(vec=="gene")+1]
      if (gen=="S") {
        g = find_gen
        inicio = as.integer(vec[which(vec=="location")+1])-1
        break
      }
    }
    
    
    fila = 1
    
    for(k in seq(g,length(mexican),12)){ #g+12 por que en la espícula del primer registro hay una inserción y el df tiene más de 2000 filas
      genMexico = mexican[[k]]      
      genMexico = toupper(genMexico)
      genMexico = as.vector(sapply(genMexico,adn_to_arnm))
      for(i in seq(1, min(c(length(genMexico), length(genWuhan))), 1)){
        if(genWuhan[i] != genMexico[i]){
          codonIndex = as.integer((i) %/% 3) + 1 
          codonWuhan = paste(c(genWuhan[((codonIndex*3)-2):(codonIndex*3)]), collapse = "")
          codonMexico = paste(c(genMexico[((codonIndex*3)-2):(codonIndex*3)]), collapse = "")
          
          if (abreviatura(codonWuhan)==abreviatura(codonMexico)) {
            cambio = FALSE
          } else {
            cambio = TRUE
          }
          
          df[fila, 1] = vector_paises[p]
          df[fila, 2] = gen
          df[fila, 3] = paste(c(genWuhan[i],genMexico[i]),collapse = " to ")
          df[fila, 4] = i + inicio
          df[fila, 5] = paste(c(codonWuhan,codonMexico), collapse = " to ") 
          df[fila, 6] = paste(c(abreviatura(codonWuhan), abreviatura(codonMexico)), collapse = " to ")
          df[fila, 7] = codonIndex
          df[fila, 8] = cambio
          fila = fila + 1
        }
      }
      df[fila, ] = ""   #Dejamos un espacio entre cada genoma para facilitar la visualización
      fila = fila + 1
    }
  }
  return(df)
}

vector_paises = c("Francia","Tailandia","Japon","Italia","USA","Mexico")

dataFrame_genS = Mutaciones(original,vector_paises)
print(dataFrame_genS)


