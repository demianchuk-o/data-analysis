CREATE OR REPLACE PROCEDURE increment_countries() AS $$
    DECLARE
    BEGIN
        CREATE TEMPORARY TABLE temp_c AS SELECT d.*
        FROM DBLINK('dbname=stage user=dalabs password=pass1234', 'SELECT name, alpha_2, alpha_3, region, sub_region, intermediate_region FROM stage.public.countries')
        as d(name VARCHAR(255), alpha_2 CHAR(2), alpha_3 CHAR(3), region VARCHAR(255), sub_region VARCHAR(255), intermediate_region VARCHAR(255));

        INSERT INTO dim_region(region)
        SELECT DISTINCT region
        FROM temp_c
        WHERE NOT EXISTS(SELECT region FROM dim_region WHERE region = temp_c.region);

        INSERT INTO dim_sub_region(sub_region)
        SELECT DISTINCT sub_region
        FROM temp_c
        WHERE NOT EXISTS(SELECT sub_region FROM dim_sub_region WHERE sub_region = temp_c.sub_region);

        INSERT INTO dim_inter_region(inter_region)
        SELECT DISTINCT intermediate_region
        FROM temp_c
        WHERE NOT EXISTS(SELECT inter_region FROM dim_inter_region WHERE inter_region = temp_c.intermediate_region);

        INSERT INTO dim_country(country, date_start)
        SELECT DISTINCT name, now()
        FROM temp_c
        WHERE NOT EXISTS(SELECT country FROM dim_country WHERE country = temp_c.name);

        INSERT INTO fact_countries(country_name_id, alpha_2, alpha_3, region_id, sub_region_id, inter_region_id)
        SELECT dc.id, tc.alpha_2, tc.alpha_3, dr.id, dsr.id, dir.id
        FROM temp_c tc
        JOIN dim_country dc ON tc.name = dc.country
        JOIN dim_region dr ON tc.region = dr.region
        JOIN dim_sub_region dsr ON tc.sub_region = dsr.sub_region
        JOIN dim_inter_region dir ON tc.intermediate_region = dir.inter_region;

        DROP TABLE temp_c;
    END;
        $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE increment_billionaires() AS $$
    DECLARE
    BEGIN
        CREATE TEMPORARY TABLE temp_b AS SELECT d.*
        FROM DBLINK('dbname=stage user=dalabs password=pass1234', 'SELECT name,
    rank,
    year,
    company_founded,
    company_name,
    company_relationship,
    company_sector,
    company_type,
    demographics_age,
    demographics_gender,
    location_citizenship,
    wealth_type,
    wealth_worth_in_billions,
    wealth_how_category,
    wealth_how_industry,
    wealth_how_inherited FROM stage.public.billionaires')
        as d(
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
    wealth_type VARCHAR(255),
    wealth_worth_in_billions FLOAT,
    wealth_how_category VARCHAR(255),
    wealth_how_industry VARCHAR(255),
    wealth_how_inherited VARCHAR(255));

        INSERT INTO dim_billionaire_name(billionaire_name)
        SELECT DISTINCT name
        FROM temp_b
        WHERE NOT EXISTS(SELECT billionaire_name FROM dim_billionaire_name WHERE billionaire_name = temp_b.name);

        INSERT INTO dim_year(year)
        SELECT DISTINCT year
        FROM temp_b
        WHERE NOT EXISTS(SELECT year FROM dim_year WHERE year = temp_b.year);

        INSERT INTO dim_year(year)
        SELECT DISTINCT company_founded
        FROM temp_b
        WHERE NOT EXISTS(SELECT year FROM dim_year WHERE year = temp_b.company_founded);

        INSERT INTO dim_company_name(company_name)
        SELECT DISTINCT company_name
        FROM temp_b
        WHERE NOT EXISTS(SELECT company_name FROM dim_company_name WHERE dim_company_name.company_name = temp_b.company_name);

        INSERT INTO dim_company_relationship(company_relationship)
        SELECT DISTINCT company_relationship
        FROM temp_b
        WHERE NOT EXISTS(SELECT company_relationship FROM dim_company_relationship WHERE dim_company_relationship.company_relationship = temp_b.company_relationship);

        INSERT INTO dim_company_sector(company_sector)
        SELECT DISTINCT company_sector
        FROM temp_b
        WHERE NOT EXISTS(SELECT company_sector FROM dim_company_sector WHERE dim_company_sector.company_sector = temp_b.company_sector);

        INSERT INTO dim_company_type(company_type)
        SELECT DISTINCT company_type
        FROM temp_b
        WHERE NOT EXISTS(SELECT company_type FROM dim_company_type WHERE dim_company_type.company_type = temp_b.company_type);

        INSERT INTO dim_gender(gender)
        SELECT DISTINCT demographics_gender
        FROM temp_b
        WHERE NOT EXISTS(SELECT gender FROM dim_gender WHERE dim_gender.gender = temp_b.demographics_gender);

        INSERT INTO dim_country(country, date_start)
        SELECT DISTINCT location_citizenship, now()
        FROM temp_b
        WHERE NOT EXISTS(SELECT country FROM dim_country WHERE dim_country.country = temp_b.location_citizenship);

        INSERT INTO dim_wealth_type(wealth_type)
        SELECT DISTINCT wealth_type
        FROM temp_b
        WHERE NOT EXISTS(SELECT wealth_type FROM dim_wealth_type WHERE dim_wealth_type.wealth_type = temp_b.wealth_type);

        INSERT INTO dim_wealth_category(wealth_category)
        SELECT DISTINCT wealth_how_category
        FROM temp_b
        WHERE NOT EXISTS(SELECT wealth_category FROM dim_wealth_category WHERE dim_wealth_category.wealth_category = temp_b.wealth_how_category);

        INSERT INTO dim_wealth_industry(wealth_industry)
        SELECT DISTINCT wealth_how_industry
        FROM temp_b
        WHERE NOT EXISTS(SELECT wealth_industry FROM dim_wealth_industry WHERE dim_wealth_industry.wealth_industry = temp_b.wealth_how_industry);

        INSERT INTO dim_wealth_inherited(wealth_inherited)
        SELECT DISTINCT wealth_how_inherited
        FROM temp_b
        WHERE NOT EXISTS(SELECT wealth_inherited FROM dim_wealth_inherited WHERE dim_wealth_inherited.wealth_inherited = temp_b.wealth_how_inherited);

        INSERT INTO fact_billionaires(name_id, year_id, company_founded_id, company_name_id, company_relationship_id, company_sector_id, company_type_id, demographics_gender_id, location_citizenship_id, wealth_type_id, wealth_category_id, wealth_industry_id, wealth_inherited_id, rank, demographics_age, wealth_worth_in_billions)
        SELECT dbn.id, dy1.id, dy2.id, dcn.id, dcr.id, dcs.id, dct.id, dg.id, dcou.id, dwt.id, dwc.id, dwi.id, dwinh.id, tb.rank, tb.demographics_age, tb.wealth_worth_in_billions
        FROM temp_b tb
        JOIN dim_billionaire_name dbn ON tb.name = dbn.billionaire_name
        JOIN dim_year dy1 ON tb.year = dy1.year
        JOIN dim_year dy2 ON tb.company_founded = dy2.year
        JOIN dim_company_name dcn ON tb.company_name = dcn.company_name
        JOIN dim_company_relationship dcr ON tb.company_relationship = dcr.company_relationship
        JOIN dim_company_sector dcs ON tb.company_sector = dcs.company_sector
        JOIN dim_company_type dct ON tb.company_type = dct.company_type
        JOIN dim_gender dg ON tb.demographics_gender = dg.gender
        JOIN dim_country dcou ON tb.location_citizenship = dcou.country
        JOIN dim_wealth_type dwt ON tb.wealth_type = dwt.wealth_type
        JOIN dim_wealth_category dwc ON tb.wealth_how_category = dwc.wealth_category
        JOIN dim_wealth_industry dwi ON tb.wealth_how_industry = dwi.wealth_industry
        JOIN dim_wealth_inherited dwinh ON tb.wealth_how_inherited = dwinh.wealth_inherited;

        DROP TABLE temp_b;
    END;
        $$ LANGUAGE plpgsql;

CALL increment_countries();
CALL increment_billionaires();