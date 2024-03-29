## import

from cohortextractor import codelist, codelist_from_csv

covid_codelist = codelist(["U071", "U072"], system="icd10")

influenza_codes = codelist(["J090", "J100", "J101", "J108", "J110", "J111", "J118"], system="icd10")

i636_code = codelist(["I636"], system="icd10")
i676_code = codelist(["I676"], system="icd10")
g08_code = codelist(["G08", "G080"], system="icd10")



## cause-specific hospitalisations
circulatory_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_circulatory.csv",
    system="icd10",
    column="icd10",  
    )

cancer_ex_nmsc_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_cancer_ex_nmsc.csv",
    system="icd10",
    column="icd10",  
    )

digestive_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_digestive.csv",
    system="icd10",
    column="icd10",  
    )

endocrine_nutritional_metabolic_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_endocrine_nutritional_metabolic.csv",
    system="icd10",
    column="icd10",  
    )

external_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_external.csv",
    system="icd10",
    column="icd10",  
    )

genitourinary_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_genitourinary.csv",
    system="icd10",
    column="icd10",  
    )

mentalhealth_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_mentalhealth.csv",
    system="icd10",
    column="icd10",  
    )

circulatory_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_circulatory.csv",
    system="icd10",
    column="icd10",  
    )

circulatory_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_circulatory.csv",
    system="icd10",
    column="icd10",  
    )

musculoskeletal_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_musculoskeletal.csv",
    system="icd10",
    column="icd10",  
    )

nervoussystem_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_nervoussystem.csv",
    system="icd10",
    column="icd10",  
    )

otherinfections_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_otherinfections.csv",
    system="icd10",
    column="icd10",  
    )

respiratory_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_respiratory.csv",
    system="icd10",
    column="icd10",  
    )

respiratorylrti_icd = codelist_from_csv(
    "codelists/local-codelists/cr_icd10_respiratorylrti.csv",
    system="icd10",
    column="icd10",  
    )

## demographic codelists

ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)
## clinical finding codelists

covid_codes = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)


pneumonia_codes = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)


# Neuro

dementia_codes = codelist_from_csv(
    "codelists/opensafely-dementia-complete.csv", system="ctv3", column="code"
)


other_neuro_codes = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv",
    system="ctv3",
    column="CTV3ID",
)

# respiratory

chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    system="ctv3",
    column="CTV3ID",
)


pneumonia_codes = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)


asthma_codes = codelist_from_csv(
    "codelists/opensafely-asthma-diagnosis.csv", system="ctv3", column="CTV3ID"
)

salbutamol_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-salbutamol-medication.csv",
    system="snomed",
    column="id",
)

ics_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

prednisolone_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="snomed_id",
)


clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)


# cardiovascular 

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv", system="ctv3", column="CTV3ID"
)

af_codes = codelist_from_csv(
    "codelists/opensafely-atrial-fibrillation-clinical-finding.csv",
    system="ctv3",
    column="CTV3Code",
)

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID"
)

systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

stroke_gp_codes = codelist_from_csv(
    "codelists/opensafely-incident-non-traumatic-stroke.csv", system="ctv3", column="CTV3ID"
)

stroke_hospital_codes = codelist_from_csv(
    "codelists/opensafely-stroke-secondary-care.csv", system="icd10", column="icd"
)

stroke_for_dementia_defn_codes = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv", system="ctv3", column="CTV3ID"
)

vte_gp_codes = codelist_from_csv(
    "codelists/opensafely-incident-venous-thromboembolic-disease.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="type",
)


vte_hospital_codes = codelist_from_csv(
    "codelists/opensafely-venous-thromboembolic-disease-hospital.csv",
    system="icd10",
    column="ICD_code",
    category_column="type",
)


# cancer

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID"
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID"
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)


chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID"
)
inflammatory_bowel_disease_codes = codelist_from_csv(
    "codelists/opensafely-inflammatory-bowel-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

# immuno

chemo_radio_therapy_codes = codelist_from_csv(
    "codelists/opensafely-chemotherapy-or-radiotherapy-updated.csv",
    system="ctv3",
    column="CTV3ID",
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID", category_column="CTV3ID"
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID"
)


spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv", system="ctv3", column="CTV3ID"
)

bone_marrow_transplant_codes = codelist_from_csv(
    "codelists/opensafely-bone-marrow-transplant.csv", system="ctv3", column="CTV3ID"
)

organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    system="ctv3",
    column="CTV3ID",
)

sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv", system="ctv3", column="CTV3ID"
)

ra_sle_psoriasis_codes = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv", system="ctv3", column="CTV3ID"
)


# gastro

chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID"
)
gi_bleed_and_ulcer_codes = codelist_from_csv(
    "codelists/opensafely-gi-bleed-or-ulcer.csv", system="ctv3", column="CTV3ID"
)
inflammatory_bowel_disease_codes = codelist_from_csv(
    "codelists/opensafely-inflammatory-bowel-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

# diabetes

diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes.csv", system="ctv3", column="CTV3ID"
)

dialysis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID"
)

# bloods

creatinine_codes = codelist(["XE2q5"], system="ctv3")
hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

# medication

warfarin_codes = codelist_from_csv(
    "codelists/opensafely-warfarin.csv",
    system="snomed",
    column="id",
)

doac_codes = codelist_from_csv(
    "codelists/opensafely-direct-acting-oral-anticoagulants-doac.csv",
    system="snomed",
    column="id",
)
