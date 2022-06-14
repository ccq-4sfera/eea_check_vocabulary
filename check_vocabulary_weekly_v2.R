# https://taskman.eionet.europa.eu/issues/149713#change-690045


library(renv)
# renv::init()
renv::restore()

library(tidyr)
library(dplyr)
library(lubridate)

rdf_url <- "https://dd.eionet.europa.eu/vocabularyfolder/aq/rdf"

aux <- data.frame("rows" = readLines(rdf_url), stringsAsFactors = F)
list_of_vocabularies <- aux %>% filter(grepl("dcterms:hasPart rdf:resource",rows))


prefix <- "https://dd.eionet.europa.eu/vocabulary/aq/"
suffix <- "/csv"

# read vocabulary list from txt (part of output from rdf)
# url_list_txt <- read.delim("./vocabulary_list.txt", header = F, stringsAsFactors = F)

# extract only the parameter (e.g. 'pollutant')
# url_list <- strsplit(url_list_txt$V1,"/")
url_list <- strsplit(list_of_vocabularies$rows,"/")
parameters <- data.frame(matrix(unlist(url_list),nrow=length(url_list),byrow = T),stringsAsFactors = F)
parameters <- parameters[,6]

# loop through parameters to read the vocabulary of each parameter
for(p in parameters){
    # reconstruct the url
    csv_url <- paste0(prefix,p,suffix)

    # read this week's vocabulary
    df_now <- read.csv(csv_url)
    
    # get year and week number (e.g. "2022_19")
    date_now <- format(now(),"%Y_%V")
    
    
    # save this week's vocabulary
    saveRDS(df_now,paste0("./Historical_vocabulary/vocabulary_",p,"_",date_now,".RDS"))

    
    # read last week's df
    date_last_week <- format(now()-weeks(1),"%Y_%V")
    df_last_week <- readRDS(paste0("./Historical_vocabulary/vocabulary_",p,"_",date_last_week,".RDS"))
    
    
    # check the $URI in last week's df that are missing in df_now
    missing_voc <- anti_join(df_now,df_last_week, by="URI")
    
    # if there are any missing, send alert
    if(is.data.frame(missing_voc) & nrow(missing_voc)>0){
        print(paste0("Vocabulary missing from ",p))
        print(missing_voc$Label)
        
        #TODO send alert
        
    }
    
}



renv::snapshot()
