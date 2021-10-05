

variable "networksecuritygroup" {
   type = any

}

variable "resource_group" {
   type = object({
      name=string
      location=string
   })
}