
# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *

from common_variables_pool import (
    demographic_variables, 
    clinical_variables, 
    postadm_adm,
    death_outcomes,
)

# Specifiy study defeinition

study = StudyDefinition(
    
    index_date = "2019-05-01",    
    
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
            "index_date - 1 year", "index_date"
        ),
    ),
    
    **demographic_variables,
    
    **clinical_variables,
    
    **postadm_adm,
    
    **death_outcomes,
    
    )