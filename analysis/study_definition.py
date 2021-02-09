
# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
)

from codelists import *

from common_variables import (
    demographic_variables, 
    clinical_variables
)

## index dates
index_date = "2020-02-01"
start_date = "2020-02-01"
end_date = "2020-12-31"
reg_start_date = "2019-02-01"

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
        registered
        AND (age >=18 AND age <= 110)
        AND discharged1_date
        """,
        registered=patients.registered_with_one_practice_between(
            reg_start_date, start_date
        ),
        dead = patients.died_from_any_cause(
            on_or_before=index_date,
            returning="binary_flag"
        ),
    ),
    
    
    # Dates

    admitted1_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-03-01", "latest": "2020-05-31"},
            "incidence": 0.1,
        },
    ),
    discharged1_date=patients.admitted_to_hospital(
        returning="date_discharged",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-06-01", "latest": "2020-07-31"},
            "incidence": 0.05,        
        },
    ),
    
    admitted1_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),
    
    admitted2_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged1_date + 1 day",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged2_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged1_date + 1 day",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted2_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after="discharged1_date + 1 day",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    died_date=patients.died_from_any_cause(
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
            "incidence": 0.1
        },
    ),

    
    # import demographic and clinical variables,
    # calculated as at first admission date (=patient_index_date)
    
    patient_index_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=covid_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-03-01", "latest": "2020-05-31"},
            "incidence": 0.1,
        },
    ),
    
    **demographic_variables,
    
    **clinical_variables
)
