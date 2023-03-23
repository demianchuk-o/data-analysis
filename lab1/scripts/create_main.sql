DROP EXTENSION IF EXISTS dblink;
CREATE EXTENSION dblink;

SELECT d.*
    INTO billionaires_info
    FROM DBLINK('dbname=stage user=dalabs password=pass1234', 'SELECT name, year, rank, company_founded, company_name,
        company_relationship, company_sector, company_type, demographics_age, demographics_gender, location_citizenship,
        wealth_type, wealth_worth_in_billions, wealth_how_category, wealth_how_industry, wealth_how_inherited FROM stage.public.billionaires')
        AS d(name VARCHAR(255),
    year INTEGER,
    rank INTEGER,
    company_founded INTEGER,
    company_name VARCHAR(255),
    company_relationship VARCHAR(255),
    company_sector VARCHAR(255),
    company_type VARCHAR(255),
    demographics_age INTEGER,
    demographics_gender VARCHAR(255),
    location_citizenship VARCHAR(255),
    wealth_type VARCHAR(255),
    wealth_worth_in_billions FLOAT,
    wealth_how_category VARCHAR(255),
    wealth_how_industry VARCHAR(255),
    wealth_how_inherited VARCHAR(255)
            );

UPDATE billionaires_info
SET company_sector = lower(trim(company_sector))
WHERE company_sector IS NOT NULL;

UPDATE billionaires_info
SET company_type = trim(company_type)
WHERE company_type IS NOT NULL;

SELECT d.*
    INTO gdp_preinfo
FROM DBLINK('dbname=stage user=dalabs password=pass1234', 'SELECT * FROM stage.public.gdp_data')
        AS d(country VARCHAR(255),
  gdp_1980 FLOAT,
  gdp_1981 FLOAT,
  gdp_1982 FLOAT,
  gdp_1983 FLOAT,
  gdp_1984 FLOAT,
  gdp_1985 FLOAT,
  gdp_1986 FLOAT,
  gdp_1987 FLOAT,
  gdp_1988 FLOAT,
  gdp_1989 FLOAT,
  gdp_1990 FLOAT,
  gdp_1991 FLOAT,
  gdp_1992 FLOAT,
  gdp_1993 FLOAT,
  gdp_1994 FLOAT,
  gdp_1995 FLOAT,
  gdp_1996 FLOAT,
  gdp_1997 FLOAT,
  gdp_1998 FLOAT,
  gdp_1999 FLOAT,
  gdp_2000 FLOAT,
  gdp_2001 FLOAT,
  gdp_2002 FLOAT,
  gdp_2003 FLOAT,
  gdp_2004 FLOAT,
  gdp_2005 FLOAT,
  gdp_2006 FLOAT,
  gdp_2007 FLOAT,
  gdp_2008 FLOAT,
  gdp_2009 FLOAT,
  gdp_2010 FLOAT,
  gdp_2011 FLOAT,
  gdp_2012 FLOAT,
  gdp_2013 FLOAT,
  gdp_2014 FLOAT,
  gdp_2015 FLOAT,
  gdp_2016 FLOAT,
  gdp_2017 FLOAT,
  gdp_2018 FLOAT,
  gdp_2019 FLOAT,
  gdp_2020 FLOAT,
  gdp_2021 FLOAT,
  gdp_2022 FLOAT,
  gdp_2023 FLOAT);

DELETE FROM gdp_preinfo
WHERE gdp_preinfo.gdp_1980 IS NULL;

CREATE TABLE gdp_info (
    country VARCHAR(255),
    year INTEGER,
    gdp FLOAT
);

DO $$
DECLARE
  year int;
  sql text;
BEGIN
  FOR year IN 1980..2023 LOOP
    sql := format('INSERT INTO gdp_info (country, year, gdp) SELECT country, %s, %s FROM gdp_preinfo', year, 'gdp_'||year);
    EXECUTE sql;
  END LOOP;
END $$;

DROP TABLE gdp_preinfo;

SELECT d.*
    INTO countries_info
    FROM DBLINK('dbname=stage user=dalabs password=pass1234', 'SELECT name, alpha_2, alpha_3, region, sub_region, intermediate_region FROM stage.public.countries')
        AS d(name VARCHAR(255),
  alpha_2 CHAR(2),
  alpha_3 CHAR(3),
  region VARCHAR(255),
  sub_region VARCHAR(255),
  intermediate_region VARCHAR(255)
  );
-- CREATE BILLIONAIRE DIMS
CREATE TABLE dim_billionaire_name (
    id serial PRIMARY KEY,
    billionaire_name VARCHAR(255) NOT NULL
);

CREATE TABLE dim_company_name (
    id serial PRIMARY KEY,
    company_name VARCHAR(255)
);

CREATE TABLE dim_company_relationship (
    id serial PRIMARY KEY,
    company_relationship VARCHAR(255)
);

CREATE TABLE dim_company_sector (
    id serial PRIMARY KEY,
    company_sector VARCHAR(255)
);

CREATE TABLE dim_company_type (
    id serial PRIMARY KEY,
    company_type VARCHAR(255)
);

CREATE TABLE dim_gender (
    id serial PRIMARY KEY,
    gender VARCHAR(255)
);

CREATE TABLE dim_wealth_type (
    id serial PRIMARY KEY,
    wealth_type VARCHAR(255)
);

CREATE TABLE dim_wealth_category (
    id serial PRIMARY KEY,
    wealth_category VARCHAR(255)
);

CREATE TABLE dim_wealth_industry (
    id serial PRIMARY KEY,
    wealth_industry VARCHAR(255)
);

CREATE TABLE  dim_wealth_inherited (
    id serial PRIMARY KEY,
    wealth_inherited VARCHAR(255)
);
-- CREATE COUNTRY DIMS
CREATE TABLE dim_region(
    id serial PRIMARY KEY,
    region VARCHAR(255)
);

CREATE TABLE dim_sub_region(
    id serial PRIMARY KEY,
    sub_region VARCHAR(255)
);

CREATE TABLE dim_inter_region(
    id serial PRIMARY KEY,
    inter_region VARCHAR(255)
);
-- CREATE GENERAL DIMS
CREATE TABLE dim_year(
    id serial PRIMARY KEY,
    year SMALLINT
);

CREATE TABLE dim_country(
    id serial PRIMARY KEY,
    date_start date,
    date_end date,
    ref_id INTEGER,
    country VARCHAR(255) NOT NULL
);
-- FILL BILLIONAIRE DIMS
INSERT INTO dim_billionaire_name(billionaire_name)
SELECT DISTINCT billionaires_info.name
FROM billionaires_info;

INSERT INTO dim_company_name(company_name)
SELECT DISTINCT billionaires_info.company_name
FROM billionaires_info;

INSERT INTO dim_company_relationship(company_relationship)
SELECT DISTINCT billionaires_info.company_relationship
FROM billionaires_info;

INSERT INTO dim_company_sector(company_sector)
SELECT DISTINCT billionaires_info.company_sector
FROM billionaires_info;

INSERT INTO dim_company_type(company_type)
SELECT DISTINCT billionaires_info.company_type
FROM billionaires_info;

INSERT INTO dim_gender(gender)
SELECT DISTINCT billionaires_info.demographics_gender
FROM billionaires_info;

INSERT INTO dim_wealth_type(wealth_type)
SELECT DISTINCT billionaires_info.wealth_type
FROM billionaires_info;

INSERT INTO dim_wealth_category(wealth_category)
SELECT DISTINCT billionaires_info.wealth_how_category
FROM billionaires_info;

INSERT INTO dim_wealth_industry(wealth_industry)
SELECT DISTINCT billionaires_info.wealth_how_industry
FROM billionaires_info;

INSERT INTO dim_wealth_inherited(wealth_inherited)
SELECT DISTINCT billionaires_info.wealth_how_inherited
FROM billionaires_info;

-- FILL COUNTRY DIMS
INSERT INTO dim_region(region)
SELECT DISTINCT countries_info.region
FROM countries_info;

INSERT INTO dim_sub_region(sub_region)
SELECT DISTINCT countries_info.sub_region
FROM countries_info;

INSERT INTO dim_inter_region(inter_region)
SELECT DISTINCT countries_info.intermediate_region
FROM countries_info;

-- FILL GENERAL DIMS
INSERT INTO dim_year(year)
SELECT DISTINCT d.year
FROM (SELECT billionaires_info.year FROM billionaires_info
    UNION SELECT billionaires_info.company_founded FROM billionaires_info
    UNION SELECT year FROM gdp_info) as d(year);

INSERT INTO dim_country(country, date_start)
SELECT DISTINCT countries_info.name, now()
FROM countries_info;

-- CREATE FACT TABLES
CREATE TABLE fact_billionaires(
    id serial PRIMARY KEY,
    name_id INTEGER NOT NULL,
    year_id INTEGER,
    company_founded_id INTEGER,
    company_name_id INTEGER,
    company_relationship_id INTEGER,
    company_sector_id INTEGER,
    company_type_id INTEGER,
    demographics_gender_id INTEGER,
    location_citizenship_id INTEGER,
    wealth_type_id INTEGER,
    wealth_category_id INTEGER,
    wealth_industry_id INTEGER,
    wealth_inherited_id INTEGER,
    rank INTEGER NOT NULL,
    demographics_age INTEGER,
    wealth_worth_in_billions FLOAT
);

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_NAME FOREIGN KEY (name_id) REFERENCES dim_billionaire_name(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_YEAR FOREIGN KEY (year_id) REFERENCES dim_year(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_COMPANY_FOUNDED FOREIGN KEY (company_founded_id) REFERENCES dim_year(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_COMPANY_NAME FOREIGN KEY (company_name_id) REFERENCES dim_company_name(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_COMPANY_RELATIONSHIP FOREIGN KEY (company_relationship_id) REFERENCES dim_company_relationship(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_COMPANY_SECTOR FOREIGN KEY (company_sector_id) REFERENCES dim_company_sector(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_COMPANY_TYPE FOREIGN KEY (company_type_id) REFERENCES dim_company_type(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_GENDER FOREIGN KEY (demographics_gender_id) REFERENCES dim_gender(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_CITIZENSHIP FOREIGN KEY (location_citizenship_id) REFERENCES dim_country(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_WEALTH_TYPE FOREIGN KEY (wealth_type_id) REFERENCES dim_wealth_type(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_WEALTH_CATEGORY FOREIGN KEY (wealth_category_id) REFERENCES dim_wealth_category(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_WEALTH_INDUSTRY FOREIGN KEY (wealth_industry_id) REFERENCES dim_wealth_industry(id)
ON DELETE CASCADE;

ALTER TABLE fact_billionaires
ADD CONSTRAINT FACT_BILLIONAIRES_FK_WEALTH_INHERITED FOREIGN KEY (wealth_inherited_id) REFERENCES dim_wealth_inherited(id)
ON DELETE CASCADE;

CREATE TABLE fact_gdp(
    id serial PRIMARY KEY,
    country_id INTEGER,
    year_id INTEGER,
    gdp FLOAT
);

ALTER TABLE fact_gdp
ADD CONSTRAINT FACT_GDP_FK_COUNTRY FOREIGN KEY (country_id) REFERENCES dim_country(id)
ON DELETE CASCADE;

ALTER TABLE fact_gdp
ADD CONSTRAINT FACT_GDP_FK_YEAR FOREIGN KEY (year_id) REFERENCES dim_year(id)
ON DELETE CASCADE;

CREATE TABLE fact_countries (
    id serial PRIMARY KEY,
    country_name_id INTEGER NOT NULL,
    alpha_2 CHAR(2),
    alpha_3 CHAR(3),
    region_id INTEGER,
    sub_region_id INTEGER,
    inter_region_id INTEGER
);

ALTER TABLE fact_countries
ADD CONSTRAINT FACT_COUNTRIES_FK_COUNTRY FOREIGN KEY (country_name_id) REFERENCES dim_country(id)
ON DELETE CASCADE;

ALTER TABLE fact_countries
ADD CONSTRAINT FACT_COUNTRIES_FK_REGION FOREIGN KEY (region_id) REFERENCES dim_region(id)
ON DELETE CASCADE;

ALTER TABLE fact_countries
ADD CONSTRAINT FACT_COUNTRIES_FK_SUB_REGION FOREIGN KEY (sub_region_id) REFERENCES dim_sub_region(id)
ON DELETE CASCADE;

ALTER TABLE fact_countries
ADD CONSTRAINT FACT_COUNTRIES_FK_INTER_REGION FOREIGN KEY (inter_region_id) REFERENCES dim_inter_region(id)
ON DELETE CASCADE;

-- FILL FACT TABLES
INSERT INTO fact_billionaires(name_id, year_id, company_founded_id, company_name_id, company_relationship_id, company_sector_id, company_type_id, demographics_gender_id, location_citizenship_id, wealth_type_id, wealth_category_id, wealth_industry_id, wealth_inherited_id, rank, demographics_age, wealth_worth_in_billions)
SELECT dbn.id, dy.id, dy.id, dcn.id, dcr.id, dcs.id, dct.id, dg.id, dcou.id, dwt.id, dwc.id, dwi.id, dwinh.id, bi.rank, bi.demographics_age, bi.wealth_worth_in_billions
FROM billionaires_info bi
JOIN dim_billionaire_name dbn ON bi.name = dbn.billionaire_name
JOIN dim_year dy ON bi.year = dy.year
JOIN dim_company_name dcn ON bi.company_name = dcn.company_name
JOIN dim_company_relationship dcr ON bi.company_relationship = dcr.company_relationship
JOIN dim_company_sector dcs ON bi.company_sector = dcs.company_sector
JOIN dim_company_type dct ON bi.company_type = dct.company_type
JOIN dim_gender dg ON bi.demographics_gender = dg.gender
JOIN dim_country dcou ON bi.location_citizenship = dcou.country
JOIN dim_wealth_type dwt ON bi.wealth_type = dwt.wealth_type
JOIN dim_wealth_category dwc ON bi.wealth_how_category = dwc.wealth_category
JOIN dim_wealth_industry dwi ON bi.wealth_how_industry = dwi.wealth_industry
JOIN dim_wealth_inherited dwinh ON bi.wealth_how_inherited = dwinh.wealth_inherited;

INSERT INTO fact_gdp(country_id, year_id, gdp)
SELECT dc.id, dy.id, gi.gdp
FROM gdp_info gi
JOIN dim_country dc ON gi.country = dc.country
JOIN dim_year dy ON gi.year = dy.year;

INSERT INTO fact_countries(country_name_id, alpha_2, alpha_3, region_id, sub_region_id, inter_region_id)
SELECT dc.id, ci.alpha_2, ci.alpha_3, dr.id, dsr.id, dir.id
FROM countries_info ci
JOIN dim_country dc on ci.name = dc.country
JOIN dim_region dr ON ci.region = dr.region
JOIN dim_sub_region dsr ON ci.sub_region = dsr.sub_region
JOIN dim_inter_region dir ON ci.intermediate_region = dir.inter_region;

DROP TABLE billionaires_info;
DROP TABLE countries_info;
DROP TABLE gdp_info;

CREATE OR REPLACE PROCEDURE SCD_COUNTRY(old_country_name VARCHAR, new_country_name VARCHAR) AS $$
    DECLARE
        old_country_id INTEGER;
        new_country_id INTEGER;
    BEGIN
        SELECT id INTO old_country_id FROM dim_country WHERE country = old_country_name;

        IF old_country_id IS NULL THEN
            RAISE EXCEPTION 'Country % is not found', old_country_name;
        END IF;

        INSERT INTO dim_country(date_start, ref_id, country)
        SELECT now(), old_country_id, new_country_name;

        UPDATE dim_country
        SET date_end = now() WHERE id = old_country_id;

        SELECT id INTO new_country_id FROM dim_country WHERE country = new_country_name;

        UPDATE fact_billionaires
        SET location_citizenship_id = new_country_id WHERE location_citizenship_id = old_country_id;

        UPDATE fact_countries
        SET country_name_id = new_country_id WHERE country_name_id = old_country_id;

        UPDATE fact_gdp
        SET country_id = new_country_id WHERE country_id = old_country_id;
    END;
    $$ LANGUAGE plpgsql;

CALL SCD_COUNTRY('Ukraine', 'Ukrainian Empire');

SELECT fb.id, dy.year, fb.rank, dbn.billionaire_name, dcou.country
FROM fact_billionaires fb
JOIN dim_year dy ON dy.id = fb.year_id
JOIN dim_billionaire_name dbn ON fb.name_id = dbn.id
JOIN dim_country dcou ON fb.location_citizenship_id = dcou.id
WHERE dcou.country = 'Ukrainian Empire';