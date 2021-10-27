# Ontario Data Model Formatter
Converts from NML data to ODM data

## Description

This tool will convert wastewater SARS-CoV-2 surveillance data into the Ontario Data Model format.

## Getting Started

This tool can be run using RStudio (available at https://www.rstudio.com/)

### Prerequisites

This tool requires the use of R packages: tidyverse, readxl, writexl, zoo, lubridate which can be loaded using:

```sh
   library(tidyverse)
   library(readxl)
   library(writexl)
   library(zoo)
   library(lubridate)
```

### Installation

1. Install R from https://www.r-project.org/
2. Install RStudio from https://www.rstudio.com/
3. Install required packages
   ```sh
   install.packages("tidyverse")
   install.packages("readxl")
   install.packages("writexl")
   install.packages("zoo")
   install.packages("lubridate")
   ```

## Usage

This tool requires input of a .xlsx file formatted as per the Ontario Data Uploader Sample Data file and will output a file that includes the Sample and Measurement tabs for the Ontario Data Model Template.

## Contact

Shelley Peterson - shelley.peterson@phac-aspc.gc.ca
Wastewater Surveillance, Public Health Agency of Canada

Project Link: [https://github.com/Big-Life-Lab/ODM](https://github.com/Big-Life-Lab/ODM)
