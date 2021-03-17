
# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *

from common_variables_pool import (
    all_pool_variables, 
)

## index dates
patient_index_date = "2019-03-01"
patient_index_date_m1 = "2019-02-28"
patient_index_date_m3m = "2018-12-01"
patient_index_date_m1y = "2018-03-01"
patient_index_date_m2y = "2017-03-01"
patient_index_date_m3y = "2016-03-01"

start_date = "2019-03-01"
end_date = "2019-12-31"
reg_start_date = "2018-03-01"

# Specifiy study defeinition

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
            reg_start_date, start_date
        ),
    ),
    
    **all_pool_variables    
    
)
