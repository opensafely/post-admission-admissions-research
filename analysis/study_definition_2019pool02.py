
# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *

from common_variables import (
    demographic_variables, 
#    clinical_variables,
#    genpop_adm,
#    death_outcomes,
)


## index dates
patient_index_date = "2019-02-01"
patient_index_date_m1 = "2019-01-31"
reg_start_date = "2018-02-01"

# Specify study definition

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "2019-03-01", "latest": "2019-10-31"},
        "rate": "uniform",
        "incidence": 1
    },
    
    population=patients.satisfying(
        """
        registered
        AND (age >=18 AND age <= 110)
        """,
        registered=patients.registered_with_one_practice_between(
            reg_start_date, patient_index_date
        ),
    ),

    
   **demographic_variables,
 #   
 #   **clinical_variables,
 #   
 #   **genpop_adm,
 #   
 #   **death_outcomes,

)
