create database dbms_project;
use dbms_project;
-- Chef Table

-- Dishes Table
CREATE TABLE Dishes (
    Dish_ID INT PRIMARY KEY,
    dish_Name VARCHAR(255),
    Preparation_time INT,
    Veg_NonVeg Enum('Veg','Non-Veg')
);
INSERT INTO Dishes
VALUES (1,'White Penne Pasta',1,'Veg'),(2,'Red spaghetti meatballs',1,'Non-Veg'),(3,'Butter Chicken',1,'Non-Veg'),(4,'Dal Makhani',1,'Veg');

select * from dishes;


-- Chef related queries.
CREATE TABLE Chef (
    Chef_ID INT PRIMARY KEY,
    chef_Name VARCHAR(255),
    Hours_available INT
);

update chef
set Hours_available=5
where chef_id=1;

select * from chef;

DELIMITER //

CREATE PROCEDURE UpdateHours(IN new_hours INT, IN chef_ids INT)
BEGIN
    IF new_hours <= 8 THEN
        UPDATE Chef
        SET Hours_available = new_hours
        WHERE Chef_ID = chef_ids ;
        SELECT 'Hours updated successfully' AS status;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check constraint violated: Hours must be less than or equal to 8';
    END IF;
END;

//

DELIMITER ;

INSERT INTO Chef
VALUES (1, 'Darsh', 0),( 2, 'Disha',0);



Call UpdateHours(6,1);
drop procedure UpdateHours;
select * from chef;
SET SQL_SAFE_UPDATES = 0;

Create Table dishes_known (
	Chef_ID INT,
    Dish_ID INT,
    dish_Name VARCHAR(255),
    FOREIGN KEY (Chef_ID) REFERENCES Chef(Chef_ID),
    FOREIGN KEY (Dish_ID) REFERENCES Dishes(Dish_ID)
);



insert into dishes_known values (1,1),(1,2),(2,1),(2,2);

-- Cooking Relationship Table
CREATE TABLE Dishes_Cooked (
    Chef_ID INT,
    Dish_ID INT,
    Dishes_cooked INT,
    FOREIGN KEY (Chef_ID) REFERENCES Chef(Chef_ID),
    FOREIGN KEY (Dish_ID) REFERENCES Dishes(Dish_ID),
    PRIMARY KEY (Chef_ID, Dish_ID)
);



-- Inventory Table
CREATE TABLE Inventory (
    Ingredient_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    Amount INT
);

INSERT INTO Inventory
VALUES
    (1, 'Spaghetti', 10),
    (2, 'Assorted vegetables', 10),
    (3, 'Cheese', 10),
    (4, 'Meatballs', 10),
    (5, 'Chicken', 10),
    (6, 'White sauce', 10),
    (7, 'Red sauce', 10),
    (8, 'Penne', 10),
    (9, 'Butter chicken mix', 10),
    (10, 'Dal', 10),
    (11, 'Makhani mix', 10);

ALTER TABLE Inventory 
CHANGE Name Ingredient_name VARCHAR(255);

select * from inventory;
DELIMITER //

CREATE PROCEDURE UpdateInventory(IN new_amount INT, IN ingriedient_id INT)
BEGIN
        UPDATE Inventory
        SET Amount = new_amount
        WHERE Ingredient_ID = ingriedient_id;
END;

//

DELIMITER ;

Call UpdateInventory(12,1);



CREATE TABLE Requirements (
    ingridient_ID INT PRIMARY KEY,
    Dish_ID INT,
    ingridient_Name VARCHAR(15),
    amount_Required INT,
    FOREIGN KEY (Dish_ID) REFERENCES Dishes(Dish_ID),
    FOREIGN KEY (ingridient_ID) REFERENCES Inventory(Ingredient_ID)
);

alter table requirements
add requirement_id int primary key auto_increment;
insert into requirements (dish_id,ingridient_id,amount_Required) values (1,2,1),(1,3,1),(1,6,1),(1,8,1),(2,1,1),(2,2,1),(2,4,1),(2,7,1),(3,2,1),(3,5,1),(3,9,1),(4,2,1),(4,3,1),(4,10,1),(4,11,1);
select * from requirements;

CREATE VIEW DishIngredientsView AS
SELECT
	dishes.Dish_name,
    Requirements.Dish_ID,
    Requirements.ingridient_ID,
    Inventory.Ingredient_name,
    Requirements.amount_Required
FROM
    Requirements
JOIN
    Inventory ON Requirements.ingridient_ID = Inventory.Ingredient_ID
Join
	dishes on Requirements.dish_id= dishes.dish_id;

select * from DishIngredientsView;
drop view DishIngredientsView;

Create table dishes_available (
	Dish_Id INT Primary key,
    amount_available INT,
    Foreign key (Dish_Id) References Dishes(Dish_ID)
    );
    
    


Create Table Customer (
	Customer_ID INT Key,
	Customer_Name varchar(265)
);
select * from customer;
Alter table Customer MODIFY COLUMN Customer_id INT AUTO_INCREMENT;
insert into Customer(customer_name) values ('Ram');
select * from customer;
-- Order Relationship Table
CREATE TABLE Orders (
    Customer_ID INT,
    Dish_ID INT,
    Order_ID INT,
    PRIMARY KEY ( Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Dish_ID) REFERENCES Dishes(Dish_ID)
);

DELIMITER //
CREATE FUNCTION AddCustomers(
    p_customer_name VARCHAR(255)
) RETURNS INT
NO SQL
BEGIN
    DECLARE customer_id INT;

    -- Insert customer information
    INSERT INTO Customer (Customer_Name)
    VALUES (p_customer_name);

    -- Get the auto-incremented Customer_ID
    SET customer_id = LAST_INSERT_ID();

    RETURN customer_id;
END //

DELIMITER ;

select * from customer;
select * from orders;
delete from customer;
delete from orders;

Alter table Orders add amount int;

-- Recreate the foreign key constraint
ALTER TABLE dbms_project.Orders
ADD CONSTRAINT orders_ibfk_1 FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) on delete cascade;

show create table orders;

ALTER TABLE dbms_project.requirements
DROP FOREIGN KEY requirements_ibfk_2;


CREATE VIEW DishesOrdersView AS
SELECT
    Orders.Order_ID,
    Dishes.Dish_ID,
    Dishes.dish_Name,
    Dishes.Preparation_time,
    Dishes.Veg_NonVeg,
    Orders.Customer_ID
FROM
    Orders
JOIN
    Dishes ON Orders.Dish_ID = Dishes.Dish_ID;



-- Trigger to check and update inventory before each order


-- Trigger to check if a new dish is possible based on chef hours and preparation time
DELIMITER //
CREATE TRIGGER check_dish_feasibility
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE total_preparation_time INT;
	DECLARE available_hours INT;
    declare chef_a int;
    -- Retrieve the total preparation time for the ordered dish
    SELECT D.Preparation_time * NEW.Amount INTO total_preparation_time
    FROM Dishes D
    WHERE D.Dish_ID = NEW.Dish_ID;
    
    SELECT DK.Chef_ID INTO chef_a
    FROM dishes_known DK
    WHERE DK.Dish_ID = NEW.Dish_ID;

    -- Retrieve the available hours of the chef
    SELECT C.Hours_available INTO available_hours
    FROM Chef C
    WHERE C.Chef_ID = chef_a;

    -- Check if the total preparation time is less than or equal to the available hours of the chef
    IF total_preparation_time IS NOT NULL AND total_preparation_time <= available_hours THEN
        update chef
        set Hours_available=available_hours-total_preparation_time;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient chef hours for the ordered dish';
    END IF;
END;
//
DELIMITER ;



-- Trigger to check if there are enough ingredients in the inventory for a new order
DELIMITER //
CREATE TRIGGER check_inventory
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE required_amount INT;
    DECLARE available_amount INT;
    declare ing_id int;

    -- Iterate over each ingredient in the order
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT Ingredient_ID, Amount
        FROM IngredientsInView
        WHERE Dish_ID = NEW.Dish_ID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO ing_id, new.amount;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Retrieve the required amount of the ingredient for the ordered dish
        SELECT amount_required INTO required_amount
        FROM Requirements
        WHERE Dish_ID = NEW.Dish_ID AND Ingredient_ID = NEW.Ingredient_ID
        LIMIT 1;

        -- Retrieve the available amount of the ingredient in inventory
        SELECT Amount INTO available_amount
        FROM Inventory
        WHERE Ingredient_ID = NEW.Ingredient_ID
        LIMIT 1;

        -- Check if there are enough ingredients in inventory
        IF required_amount IS NOT NULL AND required_amount * NEW.Amount <= available_amount THEN
            update inventory
			set amount= available_amount-required_amount * NEW.Amount ;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient ingredients for the ordered dish';
        END IF;
    END;

    CLOSE cur;
END;
//
DELIMITER ;

select * from orders;

show tables;

desc requirements;

    