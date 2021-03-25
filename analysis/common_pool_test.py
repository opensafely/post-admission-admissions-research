# -*- coding: utf-8 -*-
"""
Created on Thu Mar 25 11:02:15 2021

@author: Krish
"""



from cohortextractor import (
    patients, 
    combine_codelists,
    filter_codes_by_category,
)

from codelists import *


allvariables = dict(

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
    
)
