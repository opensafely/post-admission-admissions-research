# Overall and cause-specific hospitalisation and death after COVID-19 hospitalisation in England: a cohort study using linked primary care, secondary care and death registration data in the OpenSAFELY platform

This project looked at hospitalisations and deaths in the months after discharge from an initial COVID-19 hospitalisation. 

*The final paper is published in PLoS Medicine:
https://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1003871
* Analysis outputs will be in `released_analysis_results`/`released_outputs`
* If you are interested in how we defined our variables, take a look at the [study definition](analysis/study_definition.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/).
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)

# About the OpenSAFELY framework

The OpenSAFELY framework is a secure analytics platform for
electronic health records research in the NHS.

Instead of requesting access for slices of patient data and
transporting them elsewhere for analysis, the framework supports
developing analytics against dummy data, and then running against the
real data *within the same infrastructure that the data is stored*.
Read more at [OpenSAFELY.org](https://opensafely.org).
