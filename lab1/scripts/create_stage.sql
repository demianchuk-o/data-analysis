CREATE TABLE billionaires (
    name VARCHAR(255),
    rank INTEGER,
    year INTEGER,
    company_founded INTEGER,
    company_name VARCHAR(255),
    company_relationship VARCHAR(255),
    company_sector VARCHAR(255),
    company_type VARCHAR(255),
    demographics_age INTEGER,
    demographics_gender VARCHAR(255),
    location_citizenship VARCHAR(255),
    location_country_code VARCHAR(255),
    location_gdp FLOAT,
    location_region VARCHAR(255),
    wealth_type VARCHAR(255),
    wealth_worth_in_billions FLOAT,
    wealth_how_category VARCHAR(255),
    wealth_how_from_emerging BOOLEAN,
    wealth_how_industry VARCHAR(255),
    wealth_how_inherited VARCHAR(255),
    wealth_how_was_founder BOOLEAN,
    wealth_how_was_political BOOLEAN
);

COPY billionaires
    FROM 'D:\Labs_4sem\data-analysis\lab1\datasets\billionaires.csv'
    DELIMITER ',' CSV HEADER;

CREATE TABLE gdp_data (
  country VARCHAR(255),
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
  gdp_2023 FLOAT
);

COPY gdp_data
    FROM 'D:\Labs_4sem\data-analysis\lab1\datasets\World GDP Dataset.csv'
    DELIMITER ',' CSV HEADER;

CREATE TABLE countries (
  name VARCHAR(255),
  alpha_2 CHAR(2),
  alpha_3 CHAR(3),
  country_code SMALLINT,
  iso_3166_2 VARCHAR(255),
  region VARCHAR(255),
  sub_region VARCHAR(255),
  intermediate_region VARCHAR(255),
  region_code SMALLINT,
  sub_region_code SMALLINT,
  intermediate_region_code SMALLINT
);

COPY countries
    FROM 'D:\Labs_4sem\data-analysis\lab1\datasets\continents2.csv'
    DELIMITER ',' CSV HEADER;