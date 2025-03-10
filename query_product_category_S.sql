-- QUERY: Product e Category con restockLevel = soglia.

USE vendicosedb;
SELECT * FROM Category;
SELECT * FROM Product;

-- VIEW category_product = CP
CREATE VIEW category_product AS
SELECT P.ID, P.productName, P.categoryID, C.categoryName, C.restockLevel FROM Product AS P				
LEFT JOIN Category AS C ON P.categoryID = C.ID;
SELECT*FROM category_product;


SELECT storeID, productID, SUM(quantity) AS totalQuantity												-- Quantità vendute fino ad oggi.
FROM Sales
GROUP BY storeID, productID;

SELECT ID FROM Product WHERE ID NOT IN(SELECT productID FROM Sales);									-- L'unico prodotto invenduto è l'ID 100.

-- --------------------- --------------------- --------------------- --------------------- --------------------- ---------------------

-- VIEW GIORNALIERA         		**
CREATE VIEW daily_flag AS
SELECT 
    W.ID AS codWarehouse, ST.ID AS codStore, CP.ID AS codProduct, CP.productName, CP.categoryID AS codCategory, CP.categoryName, CP.restockLevel, SL.stock,
    (SL.stock - IFNULL(DPS.totalQuantity, 0)) AS closingStock,
    IF((SL.stock - IFNULL(DPS.totalQuantity, 0)) < CP.restockLevel, 'Ordina', 'In stock') AS flag, IFNULL(DPS.totalQuantity, 0) AS orderQuantity
FROM Stores AS ST
JOIN Warehouses AS W ON ST.warehouseID = W.ID
JOIN Stocklevels AS SL ON W.ID = SL.warehouseID					
JOIN category_product AS CP ON SL.productID = CP.ID
LEFT JOIN daily_product_sales AS DPS ON CP.ID = DPS.productID AND ST.ID = DPS.storeID 		    -- IMPORTANTE! ST.ID = S.storeID --> vendite (Sales) associate al corretto negozio (Stores). 
ORDER BY codProduct;																			-- 									(L'errore che dava: invece di restituire 900 righe, ne dava 1386)						

SELECT * FROM daily_flag;									-- Si visualizza il 'daily_flag' -- > Ordini necessari per ogni productID e nel corrispttivo storeID.
SELECT * FROM daily_flag
WHERE flag LIKE 'Ordina' ORDER BY codWarehouse;				-- Si ordina in base al codWarehouse che rifornirà al rispettivo codStore. 

-- Esempio per le vendite del giorno 2025-02-24. 
SELECT 
    W.ID AS codWarehouse, ST.ID AS codStore, CP.ID AS codProduct, CP.productName, CP.categoryID AS codCategory, CP.categoryName, CP.restockLevel, SL.stock,
    (SL.stock - IFNULL(PS24.totalQuantity, 0)) AS closingStock,
    IF((SL.stock - IFNULL(PS24.totalQuantity, 0)) < CP.restockLevel, 'Ordina', 'In stock') AS flag, IFNULL(PS24.totalQuantity, 0) AS orderQuantity
FROM Stores AS ST
JOIN Warehouses AS W ON ST.warehouseID = W.ID
JOIN Stocklevels AS SL ON W.ID = SL.warehouseID					
JOIN category_product AS CP ON SL.productID = CP.ID
LEFT JOIN product_sales_24 AS PS24 ON CP.ID = PS24.productID AND PS24.storeID = ST.ID														
ORDER BY codProduct; 


-- Esempio per le vendite del giorno 2025-02-25. * 
SELECT 
    W.ID AS codWarehouse, ST.ID AS codStore, CP.ID AS codProduct, CP.productName, CP.categoryID AS codCategory, CP.categoryName, CP.restockLevel, SL.stock,
    (SL.stock - IFNULL(PS25.totalQuantity, 0)) AS closingStock,
    IF((SL.stock - IFNULL(PS25.totalQuantity, 0)) < CP.restockLevel, 'Ordina', 'In stock') AS flag, IFNULL(PS25.totalQuantity, 0) AS orderQuantity
FROM Stores AS ST
JOIN Warehouses AS W ON ST.warehouseID = W.ID
JOIN Stocklevels AS SL ON W.ID = SL.warehouseID					
JOIN category_product AS CP ON SL.productID = CP.ID
LEFT JOIN product_sales_25 AS PS25 ON CP.ID = PS25.productID AND PS25.storeID = ST.ID											
ORDER BY codProduct;														
																					

-- In questo DB abbiamo poche transazioni per ogni supermercato, quindi i dati sono abbastanza bassi. 
-- Conducendo delle analisi di mercato su almeno 6 mesi di vendite, si potrebbero gestire meglio le quantità di stock e restoklevel
-- di ogni supermercato, per poter permettere loro vendite in linea alle esigenze di domanda.

-- Commento di spiegazione: quando viene mostrato 'Ordina', il negozio dovrà fare l'ordine al suo magazzino di riferimento
-- (i negozi 1, 2, 3 al Magazzino 1, i negozi 4, 5, 6 al Magazzino 2, i negozi 7, 8, 9 al Magazzino 3).

-- Si ipotizza che alla richiesta di 'Ordine', venga chiesta la quantità doppia del restockLevel (da scegliere bene). 
-- POSSIBILE STUDIO FUTURO: Quanto range di vendita ha? Si potrebbe fare uno studio successivo sui prodotti più venduti. (Lavoro data analyst).
-- Ogni quanto si fa un ordine?


-- Stessa VIEW con subquery
SELECT 
    W.ID AS codWarehouse, ST.ID AS codStore, CP.ID AS codProduct, CP.productName, CP.categoryID AS codCategory, CP.categoryName, CP.restockLevel, SL.stock,
    (SL.stock - COALESCE(S.totalQuantity, 0)) AS closingStock,
    IF((SL.stock - COALESCE(S.totalQuantity, 0)) < CP.restockLevel, 'Ordina', 'In stock') AS flag	
FROM Stores AS ST
JOIN Warehouses AS W ON ST.warehouseID = W.ID
JOIN Stocklevels AS SL ON W.ID = SL.warehouseID					
JOIN category_product AS CP ON SL.productID = CP.ID
LEFT JOIN 																				
    (SELECT 
         storeID, 
         productID, 
         SUM(quantity) AS totalQuantity 
     FROM 
         Sales WHERE salesDate = '2025-02-24'							-- Prenderebbe la data di 4 giorni fa.  							
     GROUP BY 
         storeID, productID) AS S ON CP.ID = S.productID AND S.storeID = ST.ID 						-- ST.ID = S.storeID --> la condizione assicura che le vendite (Sales) siano associate al corretto
ORDER BY codProduct;	