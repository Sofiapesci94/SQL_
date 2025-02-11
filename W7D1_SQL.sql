SHOW DATABASES;
USE AdventureWorksDW; 
select*from dimproduct;

-- Esercizio 1 -- vedere se productkey è una delle PK di dimproduct (factresellerkey)

SELECT*FROM dimproduct;
select count(productkey)
FROM dimproduct;

SELECT distinct COUNT(productkey) 
FROM dimproduct;

DESCRIBE dimproduct;

-- Esercizio 2 -- verificare che la combinazione dei campi SalesOrderNumber e SalesOrderLineNumber sia PK
DESCRIBE factinternetsalesreason;


-- Esercizio 3 -- Conta il numero transazioni (SalesOrderLineNumber) realizzate ogni giorno a partire dal 1 Gennaio 2020.
SELECT OrderDate, COUNT(SalesOrderLineNumber) AS conteggiotransazioni
FROM factresellersales
WHERE OrderDate>= '2020-01-01'
GROUP BY OrderDate;


-- Esercizio 4 -- Calcola il fatturato totale (FactResellerSales.SalesAmount), la quantità totale venduta (FactResellerSales.OrderQuantity) 
-- e il prezzo medio di vendita (FactResellerSales.UnitPrice) per prodotto (DimProduct) a partire dal 1 Gennaio 2020. 
-- Il result set deve esporre pertanto il nome del prodotto, il fatturato totale, la quantità totale venduta e il prezzo medio di vendita. 
select*from factresellersales;
SELECT dimproduct.EnglishProductname, factresellersales.orderdate, 
SUM(factresellersales.salesamount) AS FATTURATO_TOTALE, 
SUM(factresellersales.OrderQuantity) AS QNT_TOTALE, 
round(AVG(factresellersales.UnitPrice), 2) AS PREZZO_MEDIO 
FROM dimproduct JOIN factresellersales ON dimproduct.productkey = factresellersales.productkey
WHERE factresellersales.orderdate >= '2020-01-01'
GROUP BY dimproduct.EnglishProductName;



-- Esercizio 5 -- Calcola il fatturato totale (FactResellerSales.SalesAmount) e la quantità totale venduta (FactResellerSales.OrderQuantity) 
-- per Categoria prodotto (DimProductCategory). 
-- Il result set deve esporre pertanto il nome della categoria prodotto, il fatturato totale e la quantità totale venduta.

SELECT dimproductcategory.EnglishProductCategoryName, SUM(factresellersales.SalesAmount) AS FATTURATO_TOT, SUM(factresellersales.OrderQuantity) AS TOT_VENDITA
FROM factresellersales JOIN dimproduct ON dimproduct.productkey = factresellersales.productkey 
JOIN dimproductsubcategory ON dimproductsubcategory.ProductSubcategoryKey = dimproduct.ProductSubcategoryKey
JOIN dimproductcategory ON dimproductcategory.productcategorykey = dimproductsubcategory.ProductCategoryKey
GROUP BY dimproductcategory.EnglishProductCategoryName;



-- Esercizio 6 -- Calcola il fatturato totale per area città (DimGeography.City)
-- realizzato a partire dal 1 Gennaio 2020. Il result set deve esporre lʼelenco delle città con fatturato realizzato superiore a 60K.
SELECT*FROM factresellersales;
SELECT dimgeography.city, SUM(factresellersales.salesamount) AS FATTURATO_TOT
FROM factresellersales JOIN dimreseller ON factresellersales.resellerkey = dimreseller.resellerkey
JOIN dimgeography ON dimgeography.geographykey = dimreseller.geographykey
WHERE factresellersales.orderdate >= '2020-01-01'
GROUP BY dimgeography.city 
HAVING FATTURATO_TOT >'60000';

