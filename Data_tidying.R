.libPaths(c("./R_local_packages", .libPaths()))
library(tidyr)
library(dplyr)

filenames=list.files(".",pattern="R1_bestguess_G.txt",recursive=T,full.names=T)
#filenames

data_names<- gsub("./(.*?)/.*", "\\1", filenames)
data_names

processed_data_list <- list()

for (i in seq_along(filenames)) {
  data <- read.table(filenames[i], header = TRUE)
  
  # Remove unwanted columns 
    data <- data[-c(4:12)]
  
  # Create a new column combining Locus and Chromosome
  data$Locus.Chromosome <- paste(data$Locus, 
                                 data$Chromosome, 
                                 sep = ".")
  
  # Remove Locus and Chromosome columns
  data <- data[-c(1:2)]
  
  # Reshape data to wide format
  data <- pivot_wider(data, 
                   names_from = Locus.Chromosome, 
                   values_from = Allele)
  
  # Add sample number (from `data_names`) to the data frame
  data$Sample <- data_names[i]
  
  # Store the processed data in the list
  processed_data_list[[i]] <- data
}

# Combine all processed data into a single data frame
combined_data <- bind_rows(processed_data_list)

# Move Sample column to the front
combined_data <- combined_data %>% select(Sample, everything())

# Store combined data in an excel sheet
write.csv(combined_data, "Analysis_Results.csv")