TRUNCATE TABLE billionaires;
TRUNCATE TABLE countries;

COPY billionaires
    FROM 'D:\Labs_4sem\data-analysis\lab1\incremental\billionaires.csv'
    DELIMITER ',' CSV HEADER;

COPY countries
    FROM 'D:\Labs_4sem\data-analysis\lab1\incremental\countries.csv'
    DELIMITER ',' CSV HEADER;