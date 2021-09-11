# This function imitates the functionality of Excel's vlookup

vlookup <- function(data_vec, key_old, key_new){
  new_names <- c()
  for(i in 1:length(data_vec)){
    new_name <- data_vec[i]
    if(new_name %in% key_old){
      new_name = key_new[match(new_name, key_old)]
    }
    new_names <- c(new_names, new_name)
  }
  return(new_names)
}

# It takes three arguments:

### data_vec -- a character vector of names that you wish to replace

### key_old -- a character vector of names matching unique occurances 
### of existing names observed in data_vec (there can be extra names as well)

### key_new -- a character vector corresponding to the replacement names for 
### key old.  key_new should have the same length as key_old and in a
### corresponding order.

