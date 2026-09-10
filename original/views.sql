-- Historical Oracle-style coursework SQL; see original/README.md.
-- CREATE Views


-- Customer Addresses View
CREATE VIEW Customer_Addresses AS
SELECT
    Customer.Cust_ID,
    Customer.First_Name,
    Customer.Last_Name,
    Customer.Phone_Number,
    Address.N_B AS Neighborhood,
    Address.Str_Name AS Street,
    Address.ZIP_Code
FROM Customer
JOIN Address ON Customer.Add_Key = Address.Add_ID
WITH CHECK OPTION;
-- End of the Customer Addresses View


-- Product Categories View
CREATE VIEW Product_Categories AS
SELECT
    Product.Prod_ID,
    Product.Prod_Name,
    Product.Price,
    SubCategory.Sub_Name AS SubCategory,
    Category.Cat_Name AS Category
FROM Product
JOIN SubCategory ON Product.Sub_Key = SubCategory.Sub_ID
JOIN Category ON SubCategory.Cat_Key = Category.Cat_ID
WITH CHECK OPTION;
-- End of the Product Categories View


-- Orders Summary View
CREATE VIEW Orders_Summary AS
SELECT
    Order_.Order_ID,
    Customer.First_Name || ' ' || Customer.Last_Name AS Customer_Name,
    Product.Prod_Name AS Product,
    Order_.Quantity,
    Order_.Discount,
    Order_.Order_Date,
    Payment.Pay_Type AS Payment_Method
FROM Order_
JOIN Customer ON Order_.Cust_Key = Customer.Cust_ID
JOIN Product ON Order_.Prod_Key = Product.Prod_ID
JOIN Payment ON Order_.Pay_Key = Payment.Pay_ID
WITH CHECK OPTION;
-- end of the Orders Summary View


-- Returns Summary View
CREATE VIEW Returns_Summary AS
SELECT
    Return_.Return_ID,
    Customer.First_Name || ' ' || Customer.Last_Name AS Customer_Name,
    Product.Prod_Name AS Product,
    Return_.Quantity AS Returned_Quantity,
    Return_.Return_Date
FROM Return_
JOIN Customer ON Return_.Cust_Key = Customer.Cust_ID
JOIN Product ON Return_.Prod_Key = Product.Prod_ID
WITH CHECK OPTION;
-- End of the Returns Summary View


-- Category Size View
CREATE VIEW Category_Sizes AS
SELECT
    Size_.Size_ID,
    Category.Cat_Name AS Category,
    Size_.US_Size AS Size_
FROM Size_
JOIN Category ON Size_.Cat_Key = Category.Cat_ID
WITH CHECK OPTION;
-- End of the Category Size View
