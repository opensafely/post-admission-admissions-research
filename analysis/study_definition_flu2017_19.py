
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
start_date = "2017-01-01"
end_date = "2019-12-31"
#reg_start_date = "2018-01-01"

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
        AND discharged1_date
        """,
        registered=patients.registered_with_one_practice_between(
            "patient_index_date - 1 year", "patient_index_date"
        ),
    ),
    
    
    # Admission dates

    admitted1_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2019-05-31"},
            "incidence": 0.1,
        },
    ),
    discharged1_date=patients.admitted_to_hospital(
        returning="date_discharged",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-06-01", "latest": "2019-07-31"},
            "incidence": 0.05,        
        },
    ),
    
    admitted1_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=influenza_codes,
        on_or_after=start_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),
    
    admitted2_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2019-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged2_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-10-01", "latest": "2019-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted2_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted3_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged2_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2019-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged3_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged2_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-10-01", "latest": "2019-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted3_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after="discharged2_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted4_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged3_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2019-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged4_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged3_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-10-01", "latest": "2019-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted4_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after="discharged3_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted5_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged4_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2019-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged5_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged4_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-10-01", "latest": "2019-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted5_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after="discharged4_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

# Deaths info
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2019-03-01"}},
    ),

    died_date_ons=patients.died_from_any_cause(
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "2019-03-01"}},
    ),

    died_cause_ons=patients.died_from_any_cause(
        returning="underlying_cause_of_death",
        return_expectations={"category": {"ratios": {"U071":0.2, "I21":0.2, "C34":0.15, "C83":0.05 , "J09":0.05 , "J45":0.1 ,"G30":0.2, "A01":0.05}},},
    ),
    
    died_date_1ocare=patients.with_death_recorded_in_primary_care(
        returning="date_of_death",
        date_format="YYYY-MM-DD",
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
            "date": {"earliest": "2019-03-01", "latest": "2019-05-31"},
            "incidence": 0.1,
        },
    ),
    
    **demographic_variables,
    
    **clinical_variables
)
