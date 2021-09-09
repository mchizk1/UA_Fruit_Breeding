library(tidyverse)

test <- c("Apf_123T", "a2526TC", "prime_ark freedom", "Navajo (wrong spelling)", "a876", "APF-008", "APF-010")

StandardName <- function(names) {
  # Hard coded names of UA releases and selection numbers
  cultivars <- c("COMANCHE", "CHEROKEE", "CHEYENNE", "SHAWNEE", "CHOCTAW",
                 "NAVAHO", "KIOWA", "ARAPAHO", "CHICKASAW", "APACHE",
                 "OUACHITA", "NATCHEZ", "STELLA", "OSAGE", "PRIME-JAN",
                 "PRIME-JIM", "PA_45", "BLACK_MAGIC","SHARON'S_DELIGHT", "PA_FREEDOM",
                 "PA_TRAVELER", "BABY_CAKES", "CADDO", "PONCA", "PA_HORIZON",
                 "BLACK_GEM")
  selections <- c("A-527", "A-531", "A-544", "A-730", "A-876",
                  "A-1172T", "A-1380", "A-1536T", "A-1647", "A-1798T",
                  "A-1905T", "A-2241T", "A-2312", "A-2362T", "APF-8",
                  "APF-12", "APF-45", "APF-77", "APF-132", "APF-153T",
                  "APF-190T", "APF-236T", "A-2428T", "A-2538T", "APF-268",
                  "APF-205T")
  
  # Remove parenthetic notes from names
  StdNms <- str_remove(names, "\\((.*)\\)") %>%
    # Strip leading/trailing white space
    str_trim(side = "both") %>%
    # Make all uppercase
    toupper() %>%
    # Now for some regex replacements
    # If A-____ or APF-___
    str_replace("(?<=(^A|^APF))_?(?=[:digit:]{1,4}.*)", "-") %>%
    # Replace all spaces with underscores
    str_replace(" ", "_") %>%
    # Replace Prime-Ark with PA
    str_replace("^PRIME(-|_?)ARK(?=.*)", "PA") %>%
    # Replace Sweet-Ark with SA
    str_replace("^SWEET(-|_?)ARK(?=.*)", "SA") %>%
    # Replace alternate spelling of Navaho
    str_replace("NAVAJO", "NAVAHO") %>%
    # Replace alternate spelling of traveler
    str_replace("PA_TRAVELLER", "PA_TRAVELER") %>%
    # Remove leading zeros in low number selections
    str_remove("(?<=^A-|^APF-)0*(?=.*)")
  
  new_names <- c()
  for(i in 1:length(StdNms)){
    new_name <- StdNms[i]
    if(new_name %in% selections){
      new_name = cultivars[match(new_name, selections)]
    }
    new_names <- c(new_names, new_name)
  }
  return(new_names)
}

StandardName(test)
