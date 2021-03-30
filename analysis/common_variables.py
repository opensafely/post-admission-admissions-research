
from cohortextractor import (
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *

## NOTE
## ANY CHANGES HERE
## REPLICATE IN common_variables_pool

demographic_variables = dict(
    
    age=patients.age_as_of(
        "patient_index_date",
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
        on_or_before="patient_index_date",
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
        "patient_index_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "incidence": 1,
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.2, "400": 0.2, "500": 0.3}},
        },
    ),
     
     stp=patients.registered_practice_as_of(
         "patient_index_date",
         returning="stp_code",
         return_expectations={
             "incidence": 0.99,
             "category": {"ratios": {"1": 0.5, "2": 0.5}},
         },
     ),
     
     region=patients.registered_practice_as_of(
             "patient_index_date",
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
     
    dereg_date=patients.date_deregistered_from_all_supported_practices(
    on_or_after="patient_index_date",
    date_format="YYYY-MM",
    return_expectations={
        "date": {"earliest": "2020-03-01"},
        "incidence": 0.05
    },
    
)

)

clinical_variables = dict(
    
    # 
    
    bmi=patients.most_recent_bmi(
        on_or_before="patient_index_date - 1 day",
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
             on_or_before="patient_index_date - 1 day",
             returning="category",
         ),
         ever_smoked=patients.with_these_clinical_events(
             filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
             on_or_before="patient_index_date - 1 day",
         ),
     ),
    
    
    # cardiovascular
    
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="patient_index_date - 1 day",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),
    
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="patient_index_date - 1 day",
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),
    
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    af=patients.with_these_clinical_events(
        af_codes,
        on_or_before="patient_index_date - 1 day",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 0.05},
    ),
    
    stroke=patients.with_these_clinical_events(
        stroke_gp_codes,
        date_format="YYYY-MM-DD",
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),

    # kidney
    
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="patient_index_date - 1 day",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "2019-02-28", "latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),
    
    dialysis=patients.with_these_clinical_events(
        dialysis_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    
    # diabetes
    
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        between=["patient_index_date - 2 years", "patient_index_date - 1 day"],
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
        between=["patient_index_date - 2 years", "patient_index_date - 1 day"],
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
        on_or_before="patient_index_date - 1 day",
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
            between=["patient_index_date - 3 years", "patient_index_date - 1 day"],
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            prednisolone_codes,
            between=["patient_index_date - 1 years", "patient_index_date - 1 day"],
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
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    dysplenia=patients.with_these_clinical_events(
        spleen_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    sickle_cell=patients.with_these_clinical_events(
        sickle_cell_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes, return_last_date_in_period=True, include_month=True,
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes, return_last_date_in_period=True, include_month=True,
    ),
    
    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    
    # neuro
    
    other_neuro=patients.with_these_clinical_events(
        other_neuro_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    dementia=patients.with_these_clinical_events(
        dementia_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    
    # gastro
    
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
   
    
    # medication
    
    anticoag_rx=patients.with_these_medications(
        combine_codelists(doac_codes, warfarin_codes),
        between=["patient_index_date - 3 months", "patient_index_date - 1 day"],
        return_expectations={"incidence": 0.05},
    ),
    
)

postadm_adm = dict(

    admitted_circulatory_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=circulatory_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),
    
    admitted_circulatory_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=circulatory_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),
            
    admitted_cancer_ex_nmsc_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=cancer_ex_nmsc_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_cancer_ex_nmsc_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=cancer_ex_nmsc_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_digestive_date =patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=digestive_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_digestive_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=digestive_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),
 

    admitted_endo_nutr_metabol_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=endocrine_nutritional_metabolic_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_endo_nutr_metabol_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=endocrine_nutritional_metabolic_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_external_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=external_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),       
    
    admitted_external_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=external_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_genitourinary_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=genitourinary_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_genitourinary_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=genitourinary_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_mentalhealth_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=mentalhealth_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_mentalhealth_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=mentalhealth_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_musculoskeletal_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=musculoskeletal_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),
    
    admitted_musculoskeletal_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=musculoskeletal_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_nervoussystem_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=nervoussystem_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_nervoussystem_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=nervoussystem_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),
    
    admitted_otherinfections_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=otherinfections_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),
    
    admitted_otherinfections_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=otherinfections_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),

    admitted_respiratory_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=respiratory_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_respiratory_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=respiratory_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),
    

    admitted_respiratorylrti_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=respiratorylrti_icd,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_respiratorylrti_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=respiratorylrti_icd,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),


    admitted_covid_date=patients.admitted_to_hospital(
        returning="date_admitted",
        with_these_primary_diagnoses=covid_codelist,
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    admitted_covid_reason=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_primary_diagnoses=covid_codelist,
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"X999": 0.1, "Y999": 0.2, "Z999": 0.7}},
            "incidence": 0.1,
        },
    ),
    
    admitted2_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged2_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged1_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
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
    

    admitted2_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        on_or_after="discharged1_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.95,
        },
    ),

    admitted3_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged2_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged3_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged2_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
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

    admitted3_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        on_or_after="discharged2_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.95,
        },
    ),

    admitted4_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged3_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged4_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged3_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
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

    admitted4_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        on_or_after="discharged3_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.95,
        },
    ),


    admitted5_date=patients.admitted_to_hospital(
        returning="date_admitted",
        on_or_after="discharged4_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-09-30"},
            "incidence": 0.03,
        },
    ),

    discharged5_date=patients.admitted_to_hospital(
        returning="date_discharged",
        on_or_after="discharged4_date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={
            "date": {"earliest": "2020-10-01", "latest": "2020-11-30"},
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
    
    admitted5_dayscritical = patients.admitted_to_hospital(
        returning="days_in_critical_care",
        on_or_after="discharged4_date",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"20": 0.5, "40": 0.5}},
            "incidence": 0.95,
        },
    ),
 
                
)


death_outcomes = dict(
# Deaths info
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),

    died_date_ons=patients.died_from_any_cause(
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={
            "date": {"earliest": "2020-08-01"},
            "incidence": 0.1,
            },
    ),

    died_cause_ons=patients.died_from_any_cause(
        returning="underlying_cause_of_death",
        return_expectations={"category": {"ratios": {"U071":0.2, "I21":0.2, "C34":0.15, "C83":0.05 , "J09":0.05 , "J45":0.1 ,"G30":0.2, "A01":0.05}},},
    ),     

    died_date_1ocare=patients.with_death_recorded_in_primary_care(
        returning="date_of_death",
        date_format="YYYY-MM-DD",
    ),              
)



            