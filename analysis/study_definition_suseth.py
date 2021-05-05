# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
)

from codelists import *

from common_variables import (
    demographic_variables, 
    clinical_variables, 
    postadm_adm,
    death_outcomes,
)

## study dates
start_date = "2020-02-01"


# Specifiy study defeinition

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "2020-03-01", "latest": "2020-10-31"},
        "rate": "uniform",
        "incidence": 1
    },
    
    population=patients.satisfying(
        """
        ethnicity_sus
        """,
        ),
        

    ethnicity_sus=patients.with_ethnicity_from_sus(
        returning="group_6",
        use_most_frequent_code=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ), 
    

)
