
from cohortextractor import (
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *


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

    #ethnicity=patients.with_these_clinical_events(
    #    ethnicity_codes,
    #    returning="category",
    #    find_last_match_in_period=True,
    #    on_or_before="patient_index_date",
    #    return_expectations={
    #        "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
    #        "incidence": 0.75,
    #    },
    #),

    # imd=patients.address_as_of(
    #     "patient_index_date",
    #     returning="index_of_multiple_deprivation",
    #     round_to_nearest=100,
    #     return_expectations={
    #         "incidence": 1,
    #         "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.2, "400": 0.2, "500": 0.3}},
    #     },
    # ),
    # 
    # practice_id=patients.registered_practice_as_of(
    #     "patient_index_date",
    #     returning="pseudo_id",
    #     return_expectations={
    #         "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
    #         "incidence": 1,
    #     },
    # ),
    # 
    # # msoa=patients.registered_practice_as_of(
    # #     "patient_index_date",
    # #     returning="msoa_code",
    # #     return_expectations={
    # #         "incidence": 0.99,
    # #         "category": {"ratios": {"MSOA1": 0.5, "MSOA2": 0.5}},
    # #     },
    # # ),
    # 
    # stp=patients.registered_practice_as_of(
    #     "patient_index_date",
    #     returning="stp_code",
    #     return_expectations={
    #         "incidence": 0.99,
    #         "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
    #     },
    # ),
    # 
    # region=patients.registered_practice_as_of(
    #         "patient_index_date",
    #         returning="nuts1_region_name",
    #         return_expectations={
    #             "rate": "universal",
    #             "category": {
    #                 "ratios": {
    #                     "North East": 0.1,
    #                     "North West": 0.1,
    #                     "Yorkshire and The Humber": 0.1,
    #                     "East Midlands": 0.1,
    #                     "West Midlands": 0.1,
    #                     "East": 0.1,
    #                     "London": 0.2,
    #                     "South East": 0.1,
    #                     "South West": 0.1,
    #                 },
    #             },
    #         },
    #     ),

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
    
    # smoking_status=patients.categorised_as(
    #     {
    #         "S": "most_recent_smoking_code = 'S' OR smoked_last_18_months",
    #         "E": """
    #              (most_recent_smoking_code = 'E' OR (
    #                most_recent_smoking_code = 'N' AND ever_smoked
    #                )
    #              ) AND NOT smoked_last_18_months
    #         """,
    #         "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
    #         "M": "DEFAULT",
    #     },
    #     return_expectations={
    #         "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
    #     },
    #     most_recent_smoking_code=patients.with_these_clinical_events(
    #         clear_smoking_codes,
    #         find_last_match_in_period=True,
    #         on_or_before=days_before(start_date, 1),
    #         returning="category",
    #     ),
    #     ever_smoked=patients.with_these_clinical_events(
    #         filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
    #         on_or_before=days_before(start_date, 1),
    #     ),
    #     smoked_last_18_months=patients.with_these_clinical_events(
    #         filter_codes_by_category(clear_smoking_codes, include=["S"]),
    #         between=[days_before(start_date, 548), start_date],
    #     ),
    # ),
    
    
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
    
    hba1c_percentage_1=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        between=["patient_index_date - 2 years", "patient_index_date - 1 day"],
        returning="numeric_value",
        return_expectations={
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.98,
        },
    ),
    
    hba1c_mmol_per_mol_1=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        between=["patient_index_date - 2 years", "patient_index_date - 1 day"],
        returning="numeric_value",
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
            between=["2017-02-01", "2020-02-01"],
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            prednisolone_codes,
            between=["2019-02-01", "2020-02-01"],
            returning="number_of_matches_in_period",
        ),
    ),
    
    # cancer
    
    lung_cancer=patients.with_these_clinical_events(
        lung_cancer_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    haem_cancer=patients.with_these_clinical_events(
        haem_cancer_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    other_cancer=patients.with_these_clinical_events(
        other_cancer_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
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
        aplastic_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    hiv=patients.with_these_clinical_events(
        hiv_codes,
        returning="category",
        find_first_match_in_period=True,
        return_expectations={
            "category": {"ratios": {"43C3.": 0.8, "XaFuL": 0.2}},
        },
    ),
    permanent_immunodeficiency=patients.with_these_clinical_events(
        permanent_immune_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes,
        on_or_before="patient_index_date - 1 day",
        return_expectations={"incidence": 0.05},
    ),
    
    
    # neuro
    
    other_neuro=patients.with_these_clinical_events(
        other_neuro_codes,
        return_first_date_in_period=True,
        include_month=True,
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
    
    
    # misc
    
        
    # previous outcomes
    
    previous_dvt=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                        (historic_dvt_gp OR historic_dvt_hospital) 
                AND NOT (recent_dvt_gp OR recent_dvt_hospital)
                """,
            "2": "recent_dvt_gp OR recent_dvt_hospital",
        },
        historic_dvt_gp=patients.with_these_clinical_events(
            filter_codes_by_category(vte_gp_codes, include=["dvt"]),
            on_or_before="patient_index_date - 3 months",
        ),
        recent_dvt_gp=patients.with_these_clinical_events(
            filter_codes_by_category(vte_gp_codes, include=["dvt"]),
            between=["patient_index_date - 3 months", "patient_index_date"],
        ),
        historic_dvt_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=filter_codes_by_category(
                vte_hospital_codes, include=["dvt"]
            ),
            on_or_before="patient_index_date - 3 months",
        ),
        recent_dvt_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=filter_codes_by_category(
                vte_hospital_codes, include=["dvt"]
            ),
            between=["patient_index_date - 3 months", "patient_index_date"],
        ),
        
        return_expectations={
            "category": {"ratios": {"0": 0.7, "1": 0.1, "2": 0.2}}
        },
    ),
    
    previous_pe=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                        (historic_pe_gp OR historic_pe_hospital) 
                AND NOT (recent_pe_gp OR recent_pe_hospital)
                """,
            "2": "recent_pe_gp OR recent_pe_hospital",
        },
        historic_pe_gp=patients.with_these_clinical_events(
            filter_codes_by_category(vte_gp_codes, include=["pe"]),
            on_or_before="patient_index_date - 3 months",
        ),
        recent_pe_gp=patients.with_these_clinical_events(
            filter_codes_by_category(vte_gp_codes, include=["pe"]),
            between=["patient_index_date - 3 months", "patient_index_date - 1 day"],
        ),
        historic_pe_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=filter_codes_by_category(
                vte_hospital_codes, include=["pe"]
            ),
            on_or_after="patient_index_date - 3 months",
        ),
        recent_pe_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=filter_codes_by_category(
                vte_hospital_codes, include=["pe"]
            ),
            between=["patient_index_date - 3 months", "patient_index_date - 1 day"],
        ),
        
        return_expectations={
            "category": {"ratios": {"0": 0.7, "1": 0.1, "2": 0.2}}
        },
    ),
    
    previous_stroke=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                        (historic_pe_gp OR historic_pe_hospital) 
                AND NOT (recent_pe_gp OR recent_pe_hospital)
                """,
            "2": "recent_pe_gp OR recent_pe_hospital",
        },
        historic_stroke_gp=patients.with_these_clinical_events(
            stroke_gp_codes,
            on_or_after="patient_index_date - 3 months",
        ),
        recent_stroke_gp=patients.with_these_clinical_events(
            stroke_gp_codes,
            between=["patient_index_date - 3 months", "patient_index_date - 1 day"],
            return_expectations={"incidence": 0.05},
        ),
        historic_stroke_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=stroke_hospital_codes,
            on_or_after="patient_index_date - 3 months",
        ),
        recent_stroke_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=stroke_hospital_codes,
            between=["patient_index_date - 3 months", "patient_index_date - 1 day"],
        ),
        
        return_expectations={
            "category": {"ratios": {"0": 0.7, "1": 0.1, "2": 0.2}}
        },
    ),
    
)
