-- HOSPITAL READMISSION ANALYSIS
CREATE DATABASE hospital_readmissions;

USE hospital_readmissions;

-- 1. DATA VALIDATION

SELECT COUNT(*) AS total_rows_in_diabetic_data
FROM diabetic_data_raw;

SELECT COUNT(*) AS total_rows_in_mapping
FROM IDS_mapping_raw;

SELECT TOP 10 *
FROM diabetic_data_raw;

EXEC sp_help 'diabetic_data_raw';


-- 2. DATA CLEANING

ALTER TABLE diabetic_data_raw
ALTER COLUMN race NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN weight NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN payer_code NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN medical_specialty NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN diag_1 NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN diag_2 NVARCHAR(100) NULL;

ALTER TABLE diabetic_data_raw
ALTER COLUMN diag_3 NVARCHAR(100) NULL;


UPDATE diabetic_data_raw
SET
    race = NULLIF(race, '?'),
    weight = NULLIF(weight, '?'),
    payer_code = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    diag_1 = NULLIF(diag_1, '?'),
    diag_2 = NULLIF(diag_2, '?'),
    diag_3 = NULLIF(diag_3, '?');

-- Verify nullable columns

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'diabetic_data_raw'
  AND COLUMN_NAME IN (
      'race',
      'weight',
      'payer_code',
      'medical_specialty',
      'diag_1',
      'diag_2',
      'diag_3'
  );

-- Verify missing values

SELECT
    SUM(CASE WHEN race IS NULL THEN 1 ELSE 0 END) AS race_nulls,
    SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS weight_nulls,
    SUM(CASE WHEN payer_code IS NULL THEN 1 ELSE 0 END) AS payer_code_nulls,
    SUM(CASE WHEN medical_specialty IS NULL THEN 1 ELSE 0 END) AS medical_specialty_nulls,
    SUM(CASE WHEN diag_1 IS NULL THEN 1 ELSE 0 END) AS diag_1_nulls,
    SUM(CASE WHEN diag_2 IS NULL THEN 1 ELSE 0 END) AS diag_2_nulls,
    SUM(CASE WHEN diag_3 IS NULL THEN 1 ELSE 0 END) AS diag_3_nulls
FROM diabetic_data_raw;

-- Check percentage of missing weight values

SELECT
    ROUND(
        SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        1
    ) AS missing_weight_percentage
FROM diabetic_data_raw;


-- 3. DATA UNIQUENESS CHECK

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT patient_nbr) AS unique_patients,
    COUNT(DISTINCT encounter_id) AS unique_encounters
FROM diabetic_data_raw;


SELECT
    encounter_id,
    COUNT(*) AS duplicate_count
FROM diabetic_data_raw
GROUP BY encounter_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;



-- 4. READMISSION OVERVIEW
SELECT
    readmitted,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY readmitted
ORDER BY encounter_count DESC;


SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END)
        AS readmitted_within_30_days,
    ROUND(
        100.0 *
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS readmission_rate_30_days
FROM diabetic_data_raw;



-- 5. BASIC CATEGORICAL ANALYSIS

SELECT
    gender,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY gender
ORDER BY encounter_count DESC;


SELECT
    age,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY age
ORDER BY age;


SELECT
    admission_type_id,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY admission_type_id
ORDER BY encounter_count DESC;


SELECT
    discharge_disposition_id,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY discharge_disposition_id
ORDER BY encounter_count DESC;



-- 6. ADMISSION TYPE ANALYSIS

SELECT TOP 20 *
FROM IDS_mapping_raw;

EXEC sp_help 'IDS_mapping_raw';


CREATE TABLE admission_type_map (
    admission_type_id TINYINT,
    admission_type NVARCHAR(100)
);


INSERT INTO admission_type_map (
    admission_type_id,
    admission_type
)
VALUES
    (1, 'Emergency'),
    (2, 'Urgent'),
    (3, 'Elective'),
    (4, 'Newborn'),
    (5, 'Not Available'),
    (6, 'Not Available'),
    (7, 'Trauma Center'),
    (8, 'Not Mapped');


SELECT *
FROM admission_type_map
ORDER BY admission_type_id;


SELECT
    a.admission_type_id,
    m.admission_type,
    COUNT(*) AS total_encounters,
    SUM(
        CASE
            WHEN a.readmitted = '<30' THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN a.readmitted = '<30' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_days
FROM diabetic_data_raw AS a
LEFT JOIN admission_type_map AS m
    ON a.admission_type_id = m.admission_type_id
GROUP BY
    a.admission_type_id,
    m.admission_type
ORDER BY readmission_rate_30_days DESC;

-- 7. AGE ANALYSIS

SELECT
    age,
    COUNT(*) AS total_encounters,
    SUM(
        CASE
            WHEN readmitted = '<30' THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_days
FROM diabetic_data_raw
GROUP BY age
ORDER BY
    CASE age
        WHEN '[0-10)' THEN 1
        WHEN '[10-20)' THEN 2
        WHEN '[20-30)' THEN 3
        WHEN '[30-40)' THEN 4
        WHEN '[40-50)' THEN 5
        WHEN '[50-60)' THEN 6
        WHEN '[60-70)' THEN 7
        WHEN '[70-80)' THEN 8
        WHEN '[80-90)' THEN 9
        WHEN '[90-100)' THEN 10
    END;


-- Age midpoint
SELECT
    age,
    CASE
        WHEN age = '[0-10)' THEN 5
        WHEN age = '[10-20)' THEN 15
        WHEN age = '[20-30)' THEN 25
        WHEN age = '[30-40)' THEN 35
        WHEN age = '[40-50)' THEN 45
        WHEN age = '[50-60)' THEN 55
        WHEN age = '[60-70)' THEN 65
        WHEN age = '[70-80)' THEN 75
        WHEN age = '[80-90)' THEN 85
        WHEN age = '[90-100)' THEN 95
    END AS age_midpoint,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY age
ORDER BY age_midpoint;


-- 8. DISCHARGE DISPOSITION ANALYSIS

SELECT
    discharge_disposition_id,
    COUNT(*) AS total_encounters,
    SUM(
        CASE
            WHEN readmitted = '<30' THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_days
FROM diabetic_data_raw
GROUP BY discharge_disposition_id
ORDER BY readmission_rate_30_days DESC;

-- 9. READMISSION RATE BY PREVIOUS INPATIENT VISITS

SELECT
    number_inpatient,
    COUNT(*) AS total_encounters,
    SUM(
        CASE
            WHEN readmitted = '<30' THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_days
FROM diabetic_data_raw
GROUP BY number_inpatient
ORDER BY number_inpatient;


-- 10. DIAGNOSIS ANALYSIS
SELECT
    CASE
        WHEN diag_1 LIKE '250%' THEN 'Diabetes'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
            THEN 'Circulatory'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
            THEN 'Respiratory'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
            THEN 'Digestive'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
            THEN 'Genitourinary'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
            THEN 'Injury'
        ELSE 'Other'
    END AS diagnosis_category,

    COUNT(*) AS total_encounters,

    SUM(
        CASE
            WHEN readmitted = '<30' THEN 1
            ELSE 0
        END
    ) AS readmitted_within_30_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS readmission_rate_30_days

FROM diabetic_data_raw

GROUP BY
    CASE
        WHEN diag_1 LIKE '250%' THEN 'Diabetes'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
            THEN 'Circulatory'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
            THEN 'Respiratory'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
            THEN 'Digestive'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
            THEN 'Genitourinary'
        WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
            THEN 'Injury'
        ELSE 'Other'
    END

ORDER BY readmission_rate_30_days DESC;

-- 11. ADVANCED SQL - CTE

WITH diagnosis_readmission AS
(
    SELECT
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
                THEN 'Circulatory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
                THEN 'Respiratory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
                THEN 'Digestive'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
                THEN 'Genitourinary'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
                THEN 'Injury'
            ELSE 'Other'
        END AS diagnosis_category,

        COUNT(*) AS total_encounters,

        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) AS readmitted_within_30_days

    FROM diabetic_data_raw

    GROUP BY
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
                THEN 'Circulatory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
                THEN 'Respiratory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
                THEN 'Digestive'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
                THEN 'Genitourinary'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
                THEN 'Injury'
            ELSE 'Other'
        END
)

SELECT
    diagnosis_category,
    total_encounters,
    readmitted_within_30_days,

    ROUND(
        100.0 * readmitted_within_30_days / total_encounters,
        2
    ) AS readmission_rate_30_days

FROM diagnosis_readmission

WHERE
    100.0 * readmitted_within_30_days / total_encounters
    >
    (
        SELECT
            100.0 *
            SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END)
            / COUNT(*)
        FROM diabetic_data_raw
    )

ORDER BY readmission_rate_30_days DESC;

-- 12. WINDOW FUNCTION - RANK()

WITH diagnosis_readmission AS
(
    SELECT
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
                THEN 'Circulatory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
                THEN 'Respiratory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
                THEN 'Digestive'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
                THEN 'Genitourinary'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
                THEN 'Injury'
            ELSE 'Other'
        END AS diagnosis_category,

        COUNT(*) AS total_encounters,

        SUM(
            CASE
                WHEN readmitted = '<30' THEN 1
                ELSE 0
            END
        ) AS readmitted_within_30_days

    FROM diabetic_data_raw

    GROUP BY
        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 390 AND 459
                THEN 'Circulatory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 460 AND 519
                THEN 'Respiratory'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 520 AND 579
                THEN 'Digestive'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 580 AND 629
                THEN 'Genitourinary'
            WHEN TRY_CAST(LEFT(diag_1, 3) AS INT) BETWEEN 800 AND 999
                THEN 'Injury'
            ELSE 'Other'
        END
)

SELECT
    diagnosis_category,
    total_encounters,
    readmitted_within_30_days,

    ROUND(
        100.0 * readmitted_within_30_days / total_encounters,
        2
    ) AS readmission_rate_30_days,

    RANK() OVER (
        ORDER BY
            100.0 * readmitted_within_30_days / total_encounters DESC
    ) AS readmission_rank

FROM diagnosis_readmission;