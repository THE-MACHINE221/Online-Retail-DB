-- Historical Oracle-style coursework SQL; see original/README.md.
-- CREATE Tables


CREATE TABLE Territory (
    Ter_ID INT PRIMARY KEY,
    Country VARCHAR(50) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL
);


CREATE TABLE Address (
    Add_ID INT PRIMARY KEY,
    Ter_Key INT NOT NULL,
    N_B VARCHAR(100) NOT NULL,
    Str_Name VARCHAR(100),
    Str_Num VARCHAR(100),
    ZIP_Code VARCHAR(10),
    FOREIGN KEY (Ter_Key) REFERENCES Territory(Ter_ID)
);


CREATE TABLE Customer (
    Cust_ID INT PRIMARY KEY,
    Phone_Number VARCHAR(15) NOT NULL,
    Age INT,
    Add_Key INT,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('F', 'M')),
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    FOREIGN KEY (Add_Key) REFERENCES Address(Add_ID)

);

CREATE TABLE Category (
    Cat_ID INT PRIMARY KEY,
    Cat_Name VARCHAR(100) NOT NULL
);


CREATE TABLE SubCategory (
    Sub_ID INT PRIMARY KEY,
    Sub_Name VARCHAR(100) NOT NULL,
    Cat_Key INT NOT NULL,
    FOREIGN KEY (Cat_Key) REFERENCES Category(Cat_ID)
);

CREATE TABLE Product (
    Prod_ID INT PRIMARY KEY,
    Prod_Name VARCHAR(50) NOT NULL,
    Sub_Key INT NOT NULL,
    Color VARCHAR(50),
    Price NUMERIC(10, 2) NOT NULL,
    Weight NUMERIC(10, 2),
    Description CLOB,
    FOREIGN KEY (Sub_Key) REFERENCES SubCategory(Sub_ID)
);

CREATE TABLE Size_ (
    Size_ID INT PRIMARY KEY,
    Cat_Key INT NOT NULL,
    US_Size VARCHAR(10) NOT NULL,
    FOREIGN KEY (Cat_Key) REFERENCES Category(Cat_ID)
);


CREATE TABLE Return_ (
    Return_ID INT PRIMARY KEY,
    Return_Date DATE NOT NULL,
    Cust_Key INT NOT NULL,
    Prod_Key INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (Cust_Key) REFERENCES Customer(Cust_ID),
    FOREIGN KEY (Prod_Key) REFERENCES Product(Prod_ID)
);


CREATE TABLE Payment (
    Pay_ID INT PRIMARY KEY,
    Pay_Type VARCHAR(50) NOT NULL,
    Pay_Name VARCHAR(100) NOT NULL
);

CREATE TABLE Order_ (
    Order_ID INT PRIMARY KEY,
    Cust_Key INT NOT NULL,
    Prod_Key INT NOT NULL,
    Quantity INT NOT NULL,
    Pay_Key INT NOT NULL,
    Discount DECIMAL(10, 2),
    Order_Date DATE NOT NULL,
    Size_Key INT NOT NULL,
    FOREIGN KEY (Cust_Key) REFERENCES Customer(Cust_ID),
    FOREIGN KEY (Prod_Key) REFERENCES Product(Prod_ID),
    FOREIGN KEY (Pay_Key) REFERENCES Payment(Pay_ID),
    FOREIGN KEY (Size_Key) REFERENCES Size_(Size_ID)
);
