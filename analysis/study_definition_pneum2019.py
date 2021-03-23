
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
start_date = "2019-02-01"

# Specifiy study defeinition
study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "2019-02-01", "latest": "2019-12-31"},
        "rate": "uniform",
        "incidence": 1
    },
    
    population=patients.satisfying(
        """
        registered
        AND (age >=18 AND age <= 110)
        AND discharged1_date
        """,
        registered=patients.registered_with_one_practice_between(
            "patient_index_date - 1 year", "patient_index_date"
        ),
    ),
    
    
# Index admission 

    admitted1_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=pneumonia_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2019-12-31"},
            "incidence": 0.1,
        },
    ),
    discharged1_date=patients.admitted_to_hospital(
        returning="date_discharged",
        with_these_diagnoses=pneumonia_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2019-12-31"},
            "incidence": 0.05,        
        },
    ),
    
    admitted1_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=pneumonia_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted1_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.95,
        },
        ),
    
# import demographic and clinical variables,
# calculated as at first admission date (=patient_index_date)
    
    patient_index_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=pneumonia_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-02-01", "latest": "2019-12-31"},
            "incidence": 0.1,
        },
    ),
    
    **demographic_variables,
    
    **clinical_variables,
    
    **postadm_adm,
    
    **death_outcomes,
)
