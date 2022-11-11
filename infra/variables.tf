variable "regiao_aws" {
  type = string
}
variable "chave" {
    type = string
}
variable "instancia" {
  type = string
}
variable "grupoDeSeguranca" {
  type= string
  
}
variable "minimo" {
  type = number
  
}
variable "maximo" {
  type = number
  
}
variable "instancias-desejadas"{
  type = number
}
variable "nomeGrupo" {
  type = string
 
}
variable "producao" {
  type = bool
}
variable "ambiente"{
  type = string
}
