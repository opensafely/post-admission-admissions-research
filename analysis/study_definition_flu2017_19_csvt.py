
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
start_date = "2017-01-01"


# Specifiy study defeinition

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "2017-01-01", "latest": "2019-12-31"},
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
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2017-01-01", "latest": "2019-12-31"},
            "incidence": 1,
        },
    ),
    discharged1_date=patients.admitted_to_hospital(
        returning="date_discharged",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2017-01-01", "latest": "2019-12-31"},
            "incidence": 1,        
        },
    ),
    
    admitted1_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 1,
        },
    ),

    admitted1_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 1,
        },
        ),    
    
# import demographic and clinical variables,
# calculated as at first admission date (=patient_index_date)
    
    patient_index_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2017-01-01", "latest": "2019-12-31"},
            "incidence": 1,
        },
    ),

    
    admitted_i636_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=i636_code,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_i636_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=i636_code,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),    
    
    admitted_i676_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=i676_code,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_i676_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=i676_code,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),        

    admitted_g08_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=g08_code,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_g08_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=g08_code,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),     
    
    **demographic_variables,
    
    **clinical_variables,
    
    **postadm_adm,
    
    **death_outcomes,
)
