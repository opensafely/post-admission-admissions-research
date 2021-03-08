
# Import libraries and functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *



## index dates
patient_index_date = "2019-08-01"
patient_index_date_m1 = "2019-07-31"
patient_index_date_m3m = "2019-05-01"
patient_index_date_m1y = "2018-08-01"
patient_index_date_m2y = "2017-08-01"
patient_index_date_m3y = "2016-08-01"

start_date = "2019-08-01"
end_date = "2019-12-31"
reg_start_date = "2018-08-01"

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
    
    
    # Admission dates
 
    admitted_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after= patient_index_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2019-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after=patient_index_date,
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-10-01", "latest": "2019-11-30"},
            "incidence": 0.02,
        },
    ),

    admitted_reason = patients.admitted_to_hospital(
        returning="primary_diagnosis",
        on_or_after=patient_index_date,
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"U071": 0.1, "G060": 0.2, "I269": 0.7}},
            "incidence": 0.1,
        },
    ),

    lastprioradmission_adm_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_before = patient_index_date_m1,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-01-01", "latest": "2019-02-28"},
            "incidence": 0.03,
        },
    ),

    lastprioradmission_dis_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_before=patient_index_date_m1,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2019-01-01", "latest": "2019-02-28"},
            "incidence": 0.03,
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
     
    age=patients.age_as_of(
        patient_index_date,
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        on_or_before=patient_index_date,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),
    ethnicity_16=patients.with_these_clinical_events(
        ethnicity_codes_16,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),
    imd=patients.address_as_of(
        patient_index_date,
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "incidence": 1,
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.2, "400": 0.2, "500": 0.3}},
        },
    ),
     
    # practice_id=patients.registered_practice_as_of(
    #     patient_index_date,
    #     returning="pseudo_id",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
    #         "incidence": 1,
    #     },
    # ),
    # 
    # # msoa=patients.registered_practice_as_of(
    # #     patient_index_date,
    # #     returning="msoa_code",
    # #     return_expectations={
    # #         "incidence": 0.99,
    # #         "category": {"ratios": {"MSOA1": 0.5, "MSOA2": 0.5}},
    # #     },
    # # ),
    # 
     stp=patients.registered_practice_as_of(
         patient_index_date,
         returning="stp_code",
         return_expectations={
             "incidence": 0.99,
             "category": {"ratios": {"1": 0.5, "2": 0.5}},
         },
     ),
     
     region=patients.registered_practice_as_of(
             patient_index_date,
             returning="nuts1_region_name",
             return_expectations={
                 "rate": "universal",
                 "category": {
                     "ratios": {
                         "North East": 0.1,
                         "North West": 0.1,
                         "Yorkshire and The Humber": 0.1,
                         "East Midlands": 0.1,
                         "West Midlands": 0.1,
                         "East": 0.1,
                         "London": 0.2,
                         "South East": 0.1,
                         "South West": 0.1,
                     },
                 },
             },
         ),
    
    
    
    bmi=patients.most_recent_bmi(
        on_or_before=patient_index_date_m1,
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "incidence": 0.98,
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),
    
     smoking_status=patients.categorised_as(
         {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
         },
         return_expectations={
             "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
         },
         most_recent_smoking_code=patients.with_these_clinical_events(
             clear_smoking_codes,
             find_last_match_in_period=True,
             on_or_before=patient_index_date_m1,
             returning="category",
         ),
         ever_smoked=patients.with_these_clinical_events(
             filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
             on_or_before=patient_index_date_m1,
         ),
     ),
    
    
    # cardiovascular
    
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before=patient_index_date_m1,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"latest": "2019-02-28"},
            "incidence": 0.95,
        },
    ),
    
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before=patient_index_date_m1,
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"latest": "2019-02-28"},
            "incidence": 0.95,
        },
    ),
    
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    af=patients.with_these_clinical_events(
        af_codes,
        on_or_before=patient_index_date_m1,
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.05},
    ),
    
    stroke=patients.with_these_clinical_events(
        stroke_gp_codes,
        date_format="YYYY-MM-DD",
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),

    # kidney
    
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before=patient_index_date_m1,
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "2018-02-28", "latest": "2019-02-28"},
            "incidence": 0.95,
        },
    ),
    
    dialysis=patients.with_these_clinical_events(
        dialysis_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    
    # diabetes
    
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        between=[patient_index_date_m2y, patient_index_date_m1],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.98,
        },
    ),
    
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        between=[patient_index_date_m2y, patient_index_date_m1],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.98,
        },
    ),
    
    


    # respiratory
    
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    asthma=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
            (
              recent_asthma_code OR (
                asthma_code_ever AND NOT
                copd_code_ever
              )
            ) AND (
              prednisolone_last_year = 0 OR 
              prednisolone_last_year > 4
            )
        """,
            "2": """
            (
              recent_asthma_code OR (
                asthma_code_ever AND NOT
                copd_code_ever
              )
            ) AND
            prednisolone_last_year > 0 AND
            prednisolone_last_year < 5
            
        """,
        },
        return_expectations={
            "category": {"ratios": {"0": 0.8, "1": 0.1, "2": 0.1}},
        },
        recent_asthma_code=patients.with_these_clinical_events(
            asthma_codes,
            between=[patient_index_date_m3y, patient_index_date_m1],
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            prednisolone_codes,
            between=[patient_index_date_m1y, patient_index_date_m1],
            returning="number_of_matches_in_period",
        ),
    ),
    
    # cancer
    

    lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes, return_first_date_in_period=True, include_month=True,
    ),
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes, return_first_date_in_period=True, include_month=True,
    ),
    other_cancer=patients.with_these_clinical_events(
        other_cancer_codes, return_first_date_in_period=True, include_month=True,
    ),
    
    # immuno
    
    organ_transplant=patients.with_these_clinical_events(
        organ_transplant_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    dysplenia=patients.with_these_clinical_events(
        spleen_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    sickle_cell=patients.with_these_clinical_events(
        sickle_cell_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes, return_last_date_in_period=True, include_month=True,
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes, return_last_date_in_period=True, include_month=True,
    ),
    
    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    
    # neuro
    
    other_neuro=patients.with_these_clinical_events(
        other_neuro_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    dementia=patients.with_these_clinical_events(
        dementia_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
    
    
    # gastro
    
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        on_or_before=patient_index_date_m1,
        return_expectations={"incidence": 0.05},
    ),
   
    
    # medication
    
    anticoag_rx=patients.with_these_medications(
        combine_codelists(doac_codes, warfarin_codes),
        between=[patient_index_date_m3m, patient_index_date_m1],
        return_expectations={"incidence": 0.05},
    ),
    
    
    
)
