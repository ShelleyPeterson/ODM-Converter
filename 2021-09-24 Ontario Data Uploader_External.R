#Wastewater Surveillance Data Hub Uploader
#Written by Shelley Peterson, Wastewater Surveillance, Public Health Agency of Canada
#Version: 2021-09-24

library(tidyverse)
library(dplyr)
library(readxl)
library(writexl)
library(zoo)
library(lubridate)


file_rawdata <- file.choose()
data.df <- read_excel(file_rawdata, guess_max = 10000)

##-----------------------------------------------------SAMPLE TAB
Sample <- select(data.df, Sample_ID, Location, Date_sampled, Collection_start, Collection_end)

Sample <- rename(Sample,
                 "sampleID" = Sample_ID,
                 "siteID" = Location,
                 "dateTime" = Date_sampled,
                 "dateTimeStart" = Collection_start,
                 "dateTimeEnd" = Collection_end)

#Constants that are the same for each sample
Sample$type <- "rawWW"
Sample$collection <- "cp"
Sample$sizeL <- "0.5"
Sample$fieldSampleTempC <- "4.0"
Sample$shippedOnIce <- "yes"
Sample$notes <- NA

Sample <- relocate(Sample, c(type, collection), .after = siteID)

Sample <- Sample %>% mutate(dateTime = replace(dateTime, !is.na(dateTimeStart), NA))

##-----------------------------------------------------MEASUREMENT TAB

###Liquid concentrates data
MeasurementC <- select(data.df, Sample_ID, InstrumentC, Reported_by, C_qPCR_date, Date_reported, C_N1_1_cp, C_N1_2_cp, C_N2_1_cp, C_N2_2_cp, C_PMMV_1_cp, C_PMMV_2_cp)
MeasurementC <- gather(MeasurementC, key = type, value = value, c(C_N1_1_cp, C_N1_2_cp, C_N2_1_cp, C_N2_2_cp, C_PMMV_1_cp, C_PMMV_2_cp))
MeasurementC <- filter(MeasurementC, !is.na(value))

#Constants that are the same for each Concentrates sample
MeasurementC$assayMethodID <- "NML_Conc"
MeasurementC$fractionAnalyzed <- "Liquid"
MeasurementC$index <- MeasurementC$type
MeasurementC$index <- sub(".*_1_cp*","1", MeasurementC$index)
MeasurementC$index <- sub(".*_2_cp*","2", MeasurementC$index)
MeasurementC$type <- recode(MeasurementC$type, "C_N1_1_cp" = "covN1", "C_N1_2_cp" = "covN1", "C_N2_1_cp" = "covN2", "C_N2_2_cp" = "covN2", 
                              "C_PMMV_1_cp" = "nPMMoV", "C_PMMV_2_cp" = "nPMMoV")
MeasurementC$CF <- 30
MeasurementC$ESV <- 0.75
MeasurementC <- rename(MeasurementC, "analysisDate" = C_qPCR_date,
                                     "instrumentID" = InstrumentC)

###Solids data
MeasurementS<- select(data.df, Sample_ID, InstrumentS, S_qPCR_date, Reported_by, Date_reported, S_N1_1_cp, S_N1_2_cp, S_N2_1_cp, S_N2_2_cp, S_PMMV_1_cp, S_PMMV_2_cp)
MeasurementS <- gather(MeasurementS, key = type, value = value, c(S_N1_1_cp, S_N1_2_cp, S_N2_1_cp, S_N2_2_cp, S_PMMV_1_cp, S_PMMV_2_cp))
MeasurementS <- filter(MeasurementS, !is.na(value))

#Constants that are the same for each Solids sample
MeasurementS$assayMethodID <- "NML_Conc"
MeasurementS$fractionAnalyzed <- "Solid"
MeasurementS$index <- MeasurementS$type
MeasurementS$index <- sub(".*_1_cp*","1", MeasurementS$index)
MeasurementS$index <- sub(".*_2_cp*","2", MeasurementS$index)
MeasurementS$type <- recode(MeasurementS$type, "S_N1_1_cp" = "covN1", "S_N1_2_cp" = "covN1", "S_N2_1_cp" = "covN2", "S_N2_2_cp" = "covN2", 
                              "S_PMMV_1_cp" = "nPMMoV", "S_PMMV_2_cp" = "nPMMoV")
MeasurementS$CF <- 60
MeasurementS$ESV <- 1.5
MeasurementS <- rename(MeasurementS, "analysisDate" = S_qPCR_date,
                                     "instrumentID" = InstrumentS)

#Combine Concentrates and Solids Data
Measurement <- rbind(MeasurementC, MeasurementS)

#Constants in the Measurement tab that are the same for both Concentrates and Solids
Measurement$labID <- "NML_MangatCh"
Measurement$typeOther <- NA
Measurement$unit <- "gcMl"
Measurement$unitOther <- NA
Measurement$qualityFlag <- NA
Measurement$notes <- NA

#Reorganize, rename, and reformat to match Ontario Data Template
Measurement <- rename(Measurement,
                      "sampleID" = Sample_ID,
                      "reportDate" = Date_reported,
                      "ReporterID" = Reported_by)

Measurement$analysisDate <- as.Date(Measurement$analysisDate)
Measurement$reportDate <- as.Date(Measurement$reportDate)
Measurement <- relocate(Measurement, c(labID, assayMethodID, instrumentID, ReporterID), .after = sampleID)
Measurement <- relocate(Measurement, fractionAnalyzed, .after = reportDate)
Measurement <- relocate(Measurement, c(typeOther, unit, unitOther, index), .after = type)
Measurement <- relocate(Measurement, qualityFlag, .after = value)
Measurement <- arrange(Measurement, sampleID)
Measurement$qualityFlag[Measurement$value == "ND"] <- "ND"
Measurement$value <- gsub("ND", "", Measurement$value)
Measurement$qualityFlag[Measurement$value == "UQ"] <- "UQ"
Measurement$value <- gsub("UQ", "", Measurement$value)


#=============================================  Now put all tabs together into a Excel single workbook


write_xlsx(list("Sample" = Sample,
                "Measurement" = Measurement),
                paste(format(Sys.time(), "%Y-%m-%d"), "_national_export.xlsx"))
cat("\n\ Data Uploader is ready! :)\n\n")
