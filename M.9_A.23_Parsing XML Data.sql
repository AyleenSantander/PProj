/*Assignment 23 Parsing XML Data*/
/*1. Setup the Database and XML Data: Create the Database*/
CREATE DATABASE ProductCatalogDB;
USE ProductCatalogDB;
/*2. Create a Table to Store XML Data:*/
CREATE TABLE ProductCatalog (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_data LONGTEXT
);
/*3. Insert Sample XML Data*/
INSERT INTO ProductCatalog (product_data) VALUES
('<catalog>
    <item id="201" category="Appliances">
        <name>Washing Machine</name>
        <brand>BrandX</brand>
        <price>799.99</price>
        <stock>30</stock>
    </item>
    <item id="202" category="Appliances">
        <name>Refrigerator</name>
        <brand>BrandY</brand>
        <price>1199.99</price>
        <stock>20</stock>
    </item>
    <item id="203" category="Books">
        <title>Learning SQL</title>
        <author>Alex Doe</author>
        <price>24.99</price>
        <stock>150</stock>
    </item>
    <item id="204" category="Books">
        <title>Mastering XML</title>
        <author>Sam Smith</author>
        <price>34.99</price>
        <stock>120</stock>
    </item>
</catalog>');
/*confirm the damage code */
SELECT product_data FROM ProductCatalog;

/*Part 2. Assignment Tasks:
1. Write SQL Queries to Read and Parse XML Data: Retrieve the entire XML data from the ProductCatalog table.*/
SELECT * FROM ProductCatalog;  SELECT product_data FROM ProductCatalog;

/*2. Extract Specific Information: 
Extract the names of all products and the authors of all books from the XML data.*/
SELECT 
    product_id, 1 AS item_num,
	ExtractValue(product_data, '/catalog/item[1]/@id') AS ItemID,
    ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
    COALESCE(NULLIF(ExtractValue(product_data, 'catalog/item[1]/name'),''),
		     ExtractValue(product_data, 'catalog/item[1]/title')) AS NameorTitle,
    ExtractValue(product_data, '/catalog/item[1]/author') AS Author,
    ExtractValue(product_data, '/catalog/item[1]/price') AS Price
FROM ProductCatalog
UNION ALL
SELECT 
    product_id, 2,
	ExtractValue(product_data, '/catalog/item[2]/@id'),
    ExtractValue(product_data, '/catalog/item[2]/@category'),
    COALESCE(NULLIF(ExtractValue(product_data, 'catalog/item[2]/name'),''),
		     ExtractValue(product_data, 'catalog/item[2]/title')),
    ExtractValue(product_data, '/catalog/item[2]/author'),
    ExtractValue(product_data, '/catalog/item[2]/price')
FROM ProductCatalog
UNION ALL
SELECT 
    product_id, 3,
	ExtractValue(product_data, '/catalog/item[3]/@id'),
    ExtractValue(product_data, '/catalog/item[3]/@category'),
    COALESCE(NULLIF(ExtractValue(product_data, 'catalog/item[3]/name'),''),
		     ExtractValue(product_data, 'catalog/item[3]/title')),
    ExtractValue(product_data, '/catalog/item[3]/author'),
    ExtractValue(product_data, '/catalog/item[3]/price')
FROM ProductCatalog
UNION ALL
SELECT product_id, 4,
    ExtractValue(product_data, '/catalog/item[4]/@id'),
    ExtractValue(product_data, '/catalog/item[4]/@category'),
    COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[4]/name'), ''),
             ExtractValue(product_data, '/catalog/item[4]/title')),
    ExtractValue(product_data, '/catalog/item[4]/author'),
    ExtractValue(product_data, '/catalog/item[4]/price')
FROM ProductCatalog
ORDER BY product_id, item_num;
/*Retrieve only names of products and authors of all books*/
/*Products names (Appliances)*/
SELECT * FROM (
    SELECT product_id, 1 AS item_num,
        ExtractValue(product_data, '/catalog/item[1]/@id') AS ItemID,
        ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[1]/name'), ''),
			    ExtractValue(product_data, '/catalog/item[1]/brand')) AS BrandName,
                ExtractValue(product_data, '/catalog/item[1]/price') AS Price,
                ExtractValue(product_data, '/catalog/item[1]/stock') AS StockProduct
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 2,
        ExtractValue(product_data, '/catalog/item[2]/@id'),
        ExtractValue(product_data, '/catalog/item[2]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[2]/name'), ''),
			    ExtractValue(product_data, '/catalog/item[2]/brand')),
                ExtractValue(product_data, '/catalog/item[2]/price'),
                ExtractValue(product_data, '/catalog/item[2]/stock') 
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 3,
        ExtractValue(product_data, '/catalog/item[3]/@id'),
        ExtractValue(product_data, '/catalog/item[3]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[3]/name'), ''),
			    ExtractValue(product_data, '/catalog/item[3]/brand')),
                ExtractValue(product_data, '/catalog/item[3]/price'),
                ExtractValue(product_data, '/catalog/item[3]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 4,
        ExtractValue(product_data, '/catalog/item[4]/@id'),
        ExtractValue(product_data, '/catalog/item[4]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[4]/name'), ''),
			    ExtractValue(product_data, '/catalog/item[4]/brand')),
                ExtractValue(product_data, '/catalog/item[4]/price'),
                ExtractValue(product_data, '/catalog/item[4]/stock')
    FROM ProductCatalog
) AS all_items
WHERE Category != 'Books'
ORDER BY product_id, item_num;

/*For authors of books*/
SELECT product_id, item_num, TitleName AS BookTitle, Author, Price
FROM (
    SELECT product_id, 1 AS item_num,
        ExtractValue(product_data, '/catalog/item[1]/@id') AS ItemID,
        ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[1]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[1]/title')) AS TitleName,
        ExtractValue(product_data, '/catalog/item[1]/author') AS Author,
        ExtractValue(product_data, '/catalog/item[1]/price') AS Price
	FROM ProductCatalog
    UNION ALL
    SELECT product_id, 2,
        ExtractValue(product_data, '/catalog/item[2]/@id'),
        ExtractValue(product_data, '/catalog/item[2]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[2]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[2]/title')),
        ExtractValue(product_data, '/catalog/item[2]/author'),
        ExtractValue(product_data, '/catalog/item[2]/price')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 3,
        ExtractValue(product_data, '/catalog/item[3]/@id'),
        ExtractValue(product_data, '/catalog/item[3]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[3]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[3]/title')),
        ExtractValue(product_data, '/catalog/item[3]/author'),
        ExtractValue(product_data, '/catalog/item[3]/price')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 4,
        ExtractValue(product_data, '/catalog/item[4]/@id'),
        ExtractValue(product_data, '/catalog/item[4]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[4]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[4]/title')),
        ExtractValue(product_data, '/catalog/item[4]/author'),
        ExtractValue(product_data, '/catalog/item[4]/price')
   FROM ProductCatalog
) AS all_items
WHERE Category != 'Appliances'
ORDER BY product_id, item_num;
/*3.Handle Nested Data Structures and Attributes
Extract the prices and stock levels for all items, including handling attributes such as id and category.*/
SELECT 
    product_id,
    ExtractValue(product_data, '/catalog/item/@id') AS ProductID,
	ExtractValue(product_data, '/catalog/item/@category')AS Category,
    ExtractValue(product_data, '/catalog/item/name') AS Name,
	ExtractValue(product_data, '/catalog/item/brand') AS Brand,
	ExtractValue(product_data, '/catalog/item/price') AS Price,
    ExtractValue(product_data, '/catalog/item/stock') AS StockLevels
FROM ProductCatalog;
/*Additional: Extract the prices and stocks levels in a individual rows*/
SELECT product_id, item_num, ProductID, Category, Price, StockLevels
FROM (
    SELECT product_id, 1 AS item_num,
    ExtractValue(product_data, '/catalog/item[1]/@id') AS ProductID,
	ExtractValue(product_data, '/catalog/item[1]/@category')AS Category,
    ExtractValue(product_data, '/catalog/item[1]/name') AS Name,
	ExtractValue(product_data, '/catalog/item[1]/brand') AS Brand,
	ExtractValue(product_data, '/catalog/item[1]/price') AS Price,
    ExtractValue(product_data, '/catalog/item[1]/stock') AS StockLevels
FROM ProductCatalog
UNION ALL
SELECT product_id, 2,
    ExtractValue(product_data, '/catalog/item[2]/@id'),
	ExtractValue(product_data, '/catalog/item[2]/@category'),
    ExtractValue(product_data, '/catalog/item[2]/name'),
	ExtractValue(product_data, '/catalog/item[2]/brand'),
	ExtractValue(product_data, '/catalog/item[2]/price'),
    ExtractValue(product_data, '/catalog/item[2]/stock')
FROM ProductCatalog
UNION ALL
SELECT product_id, 3,
    ExtractValue(product_data, '/catalog/item[3]/@id'),
	ExtractValue(product_data, '/catalog/item[3]/@category'),
    ExtractValue(product_data, '/catalog/item[3]/name'),
	ExtractValue(product_data, '/catalog/item[3]/brand'),
	ExtractValue(product_data, '/catalog/item[3]/price'),
    ExtractValue(product_data, '/catalog/item[3]/stock')
FROM ProductCatalog
UNION ALL
SELECT product_id, 4,
    ExtractValue(product_data, '/catalog/item[4]/@id'),
	ExtractValue(product_data, '/catalog/item[4]/@category'),
    ExtractValue(product_data, '/catalog/item[4]/name'),
	ExtractValue(product_data, '/catalog/item[4]/brand'),
	ExtractValue(product_data, '/catalog/item[4]/price'),
    ExtractValue(product_data, '/catalog/item[4]/stock')
FROM ProductCatalog
)AS all_items
ORDER BY product_id, item_num;
/*4.Use SQL XML Functions for Advanced Extraction: 
Utilize MySQL XML functions such as EXTRACTVALUE() to retrieve specific attributes and nested elements from the XML data*/
SELECT 
    product_id,
    EXTRACTVALUE(product_data, '/catalog/item/name'),
    EXTRACTVALUE(product_data, '/catalog/item/title') AS NameorTitle
FROM ProductCatalog;

/*Extract stock levels from appliances and author name from first row*/
SELECT 
    product_id,  
    EXTRACTVALUE(product_data, '/catalog/item[1]/@category') AS Category,
    COALESCE(NULLIF(EXTRACTVALUE(product_data, '/catalog/item[1]/name'), ''),
             EXTRACTVALUE(product_data, '/catalog/item[1]/title')) AS ProductName,
    EXTRACTVALUE(product_data, '/catalog/item[1]/author') AS Author,
    EXTRACTVALUE(product_data, '/catalog/item[1]/stock') AS Stocklevels
FROM ProductCatalog;
/*Extract stock levesl from appliances and author names containt in all values*/
SELECT product_id, item_num, Category, ProductName, Author, StockLevels
FROM (
    SELECT product_id, 1 AS item_num,
        ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[1]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[1]/title')) AS ProductName,
        ExtractValue(product_data, '/catalog/item[1]/author') AS Author,
        ExtractValue(product_data, '/catalog/item[1]/stock') AS StockLevels
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 2,
        ExtractValue(product_data, '/catalog/item[2]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[2]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[2]/title')),
        ExtractValue(product_data, '/catalog/item[2]/author'),
        ExtractValue(product_data, '/catalog/item[2]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 3,
        ExtractValue(product_data, '/catalog/item[3]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[3]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[3]/title')),
        ExtractValue(product_data, '/catalog/item[3]/author'),
        ExtractValue(product_data, '/catalog/item[3]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 4,
        ExtractValue(product_data, '/catalog/item[4]/@category'),
        COALESCE(NULLIF(ExtractValue(product_data, '/catalog/item[4]/name'), ''),
                 ExtractValue(product_data, '/catalog/item[4]/title')),
        ExtractValue(product_data, '/catalog/item[4]/author'),
        ExtractValue(product_data, '/catalog/item[4]/stock')
    FROM ProductCatalog
) AS all_items
WHERE Category = 'Appliances' OR Author IS NOT NULL AND Author != ''
ORDER BY product_id, item_num;

/*5. Generate a Summary Report: 
Summarize the total stock of appliances and books, and calculate the average price of all items.*/
SELECT 
    Category,
    SUM(CAST(StockLevels AS UNSIGNED)) AS TotalStock,
    ROUND(AVG(CAST(Price AS DECIMAL(10,2))), 2) AS AveragePrice
FROM (
    SELECT product_id, 1 AS item_num,
        ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
        ExtractValue(product_data, '/catalog/item[1]/price') AS Price,
        ExtractValue(product_data, '/catalog/item[1]/stock') AS StockLevels
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 2,
        ExtractValue(product_data, '/catalog/item[2]/@category'),
        ExtractValue(product_data, '/catalog/item[2]/price'),
        ExtractValue(product_data, '/catalog/item[2]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 3,
        ExtractValue(product_data, '/catalog/item[3]/@category'),
        ExtractValue(product_data, '/catalog/item[3]/price'),
        ExtractValue(product_data, '/catalog/item[3]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 4,
        ExtractValue(product_data, '/catalog/item[4]/@category'),
        ExtractValue(product_data, '/catalog/item[4]/price'),
        ExtractValue(product_data, '/catalog/item[4]/stock')
    FROM ProductCatalog
) AS all_items
GROUP BY Category;
/*Shows the Overal Average price in general*/
SELECT 
    ROUND(AVG(CAST(Price AS DECIMAL(10,2))),2) AS OveralAveragePrice
FROM (
    SELECT product_id, 1 AS item_num,
        ExtractValue(product_data, '/catalog/item[1]/@category') AS Category,
        ExtractValue(product_data, '/catalog/item[1]/price') AS Price,
        ExtractValue(product_data, '/catalog/item[1]/stock') AS StockLevels
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 2,
        ExtractValue(product_data, '/catalog/item[2]/@category'),
        ExtractValue(product_data, '/catalog/item[2]/price'),
        ExtractValue(product_data, '/catalog/item[2]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 3,
        ExtractValue(product_data, '/catalog/item[3]/@category'),
        ExtractValue(product_data, '/catalog/item[3]/price'),
        ExtractValue(product_data, '/catalog/item[3]/stock')
    FROM ProductCatalog
    UNION ALL
    SELECT product_id, 4,
        ExtractValue(product_data, '/catalog/item[4]/@category'),
        ExtractValue(product_data, '/catalog/item[4]/price'),
        ExtractValue(product_data, '/catalog/item[4]/stock')
    FROM ProductCatalog
) AS all_items;
    