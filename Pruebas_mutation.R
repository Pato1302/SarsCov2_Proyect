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
  protein_change = logical(),
  compared_to = character()
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
                "UGC"="C","UGU"="C",
                codon))
}

adn_to_arnm = function(elemento){
  return (switch(elemento,"C"="C","G"="G","A"="A","T"="U"))
}

Alineacion = function(A,B){
  m <- matrix(data = 0, nrow = length(B)+1, ncol = length(A)+1)
  m[1, ] = seq(0,length(A)*-2,-2)
  m[ , 1] = seq(0,length(B)*-2,-2)
  m
  
  for (fila in seq(2,length(B)+1)){
    for (col in seq(2,length(A)+1)){
      m[fila, col] = CalcularPeso(A,B,fila, col, m)
    }
  }
  
  #back-trace
  
  iFila = length(B) + 1
  iColumna = length(A) + 1
  A_res = c()
  B_res = c()
  
  while (iFila != 1 && iColumna != 1){
    if(A[iColumna-1] == B[iFila-1]){
      A_res = append(A_res,A[iColumna-1])
      B_res = append(B_res,A[iColumna-1])
      iColumna = iColumna - 1
      iFila = iFila - 1
    } else {
      if(m[iFila, iColumna-1] > m[iFila-1, iColumna]){
        A_res = append(A_res, A[iColumna-1])
        B_res = append(B_res, "-")
        iColumna = iColumna - 1
      } else { 
        A_res = append(A_res, "-")
        B_res = append(B_res, B[iFila-1])
        iFila = iFila - 1
      }
    }
  }
  resultado = c(rev(A_res),rev(B_res))
  return(resultado)
}

CalcularPeso = function(A, B, fila,col,m){
  if(A[col-1] == B[fila-1]){
    diagonal = m[fila-1,col-1] + 1
  } else {
    diagonal = m[fila-1,col-1] - 1
  }
  up = m[fila-1, col] -2
  left = m[fila, col-1] -2
  peso = max(diagonal,up,left)
  return(peso)
}

Mutaciones = function(original, vector_paises, vector_genes_wuhan, vector_genes, file_name, continuo){
  for (p in seq (1,length(vector_paises),1)) {
    mexican = read.fasta(paste(c(file_name,vector_paises[p],".txt"),collapse=""))
    gr = 1
    while(gr<=length(vector_genes)) {    

      genWuhan = original[[vector_genes_wuhan[gr]]]
      genWuhan = toupper(genWuhan)
      genWuhan = as.vector(sapply(genWuhan,adn_to_arnm))
      
      
      for (find_gen in seq(1,12,1)) {
        genMexico = mexican[[find_gen]]
        attr1 = attr(genMexico,"Annot")
        vec = unlist(strsplit(attr1,"\\[|\\]|:|=|\\."))
        gen = vec[which(vec=="gene")+1]
        if (gen==vector_genes[gr]) {
          g = find_gen
          inicio = as.integer(vec[which(vec=="location")+1])-1
          break
        }
      }
      
      
      for(k in seq(g,length(mexican),12)){
        genMexico = mexican[[k]]      
        genMexico = toupper(genMexico)
        genMexico = as.vector(sapply(genMexico,adn_to_arnm))
        
        #Check if there is an insertion or deletion mutation
        if(length(genMexico)!=length(genWuhan)){
           genesAlineados = Alineacion(genWuhan,genMexico)
           genWuhan = genesAlineados[1]
           genMexico = genesAlineados[2]
         }
        
        
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
            
            df[nrow(df)+1, 1] = vector_paises[p]
            df[nrow(df), 2] = gen
            df[nrow(df), 3] = paste(c(genWuhan[i],genMexico[i]),collapse = " to ")
            df[nrow(df), 4] = i + inicio
            df[nrow(df), 5] = paste(c(codonWuhan,codonMexico), collapse = " to ") 
            df[nrow(df), 6] = paste(c(abreviatura(codonWuhan), abreviatura(codonMexico)), collapse = " to ")
            df[nrow(df), 7] = codonIndex
            df[nrow(df), 8] = cambio
            
            if (continuo && p>1) {
              df[nrow(df), 9] = paste(c("Mexico ",p),collapse="")
            } else {
              df[nrow(df), 9] = "Wuhan"
            }
          }
        }
      }
      gr = gr + 1
    }
    
    if (continuo) {
      original = mexican
    }
    
    
  }
  return(df)
}

vector_paises = c("Francia","Tailandia","Japon","Italia","USA","Mexico")
vector_genes_wuhan = c(3,5,6,11)
vector_genes = c("S","E","M","N")
vector_num_genomas = c(1,2,3)
file_names_first = "Archivos/first_B_sequences/first_B_"
file_names_months = "Archivos/2Meses_Despues_sequences/2Meses_Despues_"
file_names_multiple = "Archivos/Mexico_multiple/Mexico_"

dataFrame_genS = Mutaciones(original,vector_paises,vector_genes_wuhan,vector_genes,file_names_first,FALSE)
print(dataFrame_genS)

dataFrame_2months_later = Mutaciones(original,vector_paises,vector_genes_wuhan,vector_genes,file_names_months,FALSE)
print(dataFrame_2months_later)

dataFrame_mexico = Mutaciones(original,vector_num_genomas,vector_genes_wuhan,vector_genes,file_names_multiple,TRUE)
print(dataFrame_mexico)



