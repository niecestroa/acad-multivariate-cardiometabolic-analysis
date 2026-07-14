/* Source data sampled from this repo's data/Diabetes_Final_Data_V2.csv (DiaHealth, Kaggle). */
/* Columns match those the cleaning step reads; PROC IMPORT of the CSV is replaced by an inline read so the bundle is self-contained. */
DATA WORK.Diabetes_unclean;
    LENGTH gender $8;
    INPUT age gender $ pulse_rate systolic_bp diastolic_bp glucose bmi hypertensive;
    DATALINES;
42 Female 66 110 73 5.88 25.75 0
35 Female 68 161 113 6.01 27.7 0
35 Female 78 139 81 6.68 27.81 0
22 Female 78 130 91 5.31 28.2 0
60 Female 65 176 103 6.83 29.9 1
50 Female 70 184 111 5.75 26.29 0
50 Female 58 176 89 7.02 29.64 1
70 Female 85 162 92 12 25.96 0
33 Female 67 116 84 6.41 27.28 0
50 Female 68 148 82 6.5 29.58 0
35 Female 74 114 78 5.77 29.03 0
45 Female 74 126 81 7.8 26.69 0
30 Female 65 144 105 6.18 28.98 0
23 Female 68 149 102 7.32 26.85 0
40 Female 77 155 100 6.22 26.26 0
26 Female 59 126 86 6.24 27.21 0
27 Female 72 124 83 5.61 29.07 0
28 Male 75 142 99 8.47 26.81 0
35 Female 60 125 68 5.71 19.58 0
62 Female 57 127 74 6.85 20.24 0
73 Male 55 193 112 6.28 21.72 0
40 Male 48 131 73 7.22 23.42 0
35 Female 66 123 72 5.4 20.91 0
25 Female 84 152 90 7.2 24.84 0
70 Male 64 129 75 8.04 20.54 0
56 Female 72 130 84 7.35 20.93 0
32 Female 73 130 73 4.96 20.54 0
46 Female 76 114 88 7.41 19.04 0
30 Female 85 142 82 5.35 20.95 0
35 Female 84 123 76 6.98 21.41 0
55 Female 79 137 78 8.34 24.58 1
55 Female 62 150 86 7.51 20.67 0
60 Female 78 174 77 6.57 21.87 0
52 Female 70 155 94 6.11 21.53 0
26 Male 68 126 75 8.32 21.46 0
45 Male 70 132 81 8 23.48 0
68 Female 71 150 81 5.71 17.79 0
65 Male 75 128 85 5.84 17.26 0
50 Male 69 139 80 11.62 17.21 0
18 Female 83 124 73 6.91 18.12 0
50 Female 56 151 91 6.23 17.75 1
52 Female 92 207 98 6 16.28 0
65 Female 82 132 75 10.23 18.13 0
65 Female 57 125 79 7.98 16.59 0
50 Male 72 114 75 6.35 15.17 0
32 Male 65 115 81 5.03 16.8 0
62 Male 57 104 69 5.44 16.94 0
28 Female 68 120 76 5.98 16.13 0
55 Female 86 158 99 5.05 17.06 0
40 Male 83 121 95 7.09 16.81 0
60 Male 59 152 85 5.87 16.88 1
75 Female 68 167 71 6.56 17.17 0
33 Male 69 115 54 5.73 18.23 0
60 Female 71 106 74 6.07 17.02 0
35 Female 66 152 81 5.08 38.27 0
60 Male 61 172 94 7.62 34.99 1
50 Female 104 120 81 11.36 30.14 0
51 Female 60 145 90 9.4 30.85 0
38 Male 91 159 102 9.22 33.27 0
63 Male 76 137 83 7.52 30.75 0
27 Female 76 127 82 5.52 36.86 0
28 Female 83 124 83 4.49 30.91 0
51 Female 57 144 101 4.97 32.95 1
30 Female 70 130 92 5.76 30.2 0
50 Female 71 188 118 6.2 36.07 1
;
RUN;

DATA WORK.Diabetes_clean;
    SET WORK.Diabetes_unclean;
    IF age >= 18 AND
       bmi >= 15 AND bmi <= 55 AND
       pulse_rate >= 40 AND
       systolic_bp <= 210 AND
       glucose >= 4.0 AND glucose <= 13.3;
    LENGTH bmi_cat $12;
    IF bmi < 18.5 THEN bmi_cat = "Underweight";
    ELSE IF bmi < 25 THEN bmi_cat = "Healthy";
    ELSE IF bmi < 30 THEN bmi_cat = "Overweight";
    ELSE bmi_cat = "Obese";
    KEEP pulse_rate systolic_bp diastolic_bp glucose age gender hypertensive bmi_cat;
RUN;

DATA WORK.Diabetes_transformed;
    SET WORK.Diabetes_clean;
    pulse_rate_t    = LOG(pulse_rate);
    systolic_bp_t   = LOG(systolic_bp);
    diastolic_bp_t  = LOG(diastolic_bp);
    glucose_t       = LOG(glucose);
    KEEP pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t age gender hypertensive bmi_cat;
RUN;

/*-------------------------------------------------------------*/
/*        ONE-WAY MANOVA and POST-HOC TESTS in SAS             */
/*-------------------------------------------------------------*/

/* Perform MANOVA: Response vs BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat;
    MANOVA H=bmi_cat / PRINTE PRINTH;
RUN;
QUIT;
