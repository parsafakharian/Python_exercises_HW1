import logging
from database import DatabaseManager

import psycopg2
from psycopg2 import OperationalError

logging.basicConfig(
    filename="inventory_updates.log",  # Log file name
    level=logging.INFO,  # Log level (e.g., DEBUG, INFO, WARNING, ERROR, CRITICAL)
    format="%(asctime)s - %(levelname)s - %(message)s",  # Log format
)

logging.info("Logging system initialized.")  # Example log


class Inventory:
    def init(self, id, name, quantity, price, type):
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
        self.type = type

    def add_and_save_to_db(self, new_db_manager):
        query = """
        INSERT INTO inventory (name, quantity, price, type)
        VALUES (%s, %s, %s, %s)
        """

        values = (self.name, self.quantity, self.price, self.type)
        new_db_manager.execute_query(query, values)

    def update_stock(self):
        raise NotImplementedError("This method should be overridden in subclasses")


class Phisycal_item(Inventory):
    def init(self, id, name, quantity, price, type, weight, dimensions):
        super().init(id, name, quantity, price, type)
        self.weight = weight
        self.dimensions = dimensions

    def add_and_save_to_db(self, new_db_manager):
        query = """
                INSERT INTO inventory (name, quantity, price, type, weight, dimensions)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
        values = (self.name, self.quantity, self.price, self.type, self.weight, self.dimensions)
        new_db_manager.execute_query(query, values)

    def update_stock(self, item_id, quantity):
        query = "UPDATE inventory SET quantity = %s WHERE id = %s"
        try:
            self.db_manager.execute_query(query, (quantity, item_id))
            logging.info(
                f"Item ID {item_id} updated: New Quantity = {quantity}"
            )
            print("Stock updated successfully.")
        except Exception as e:
            logging.error(f"Error updating item ID {item_id}: {e}")
            print("Failed to update stock.")
            print(f"Physical item with ID {item_id} updated to quantity {quantity}.")


class Digital_item(Inventory):
    def init(self, id, name, quantity, price, type, file_size, download_link):
        super().init(id, name, quantity, price)
        self.file_size = file_size
        self.download_link = download_link

    def add_and_save_to_db(self, db_manager):
        query = """
                INSERT INTO inventory (name, quantity, price, type, file_size, download_link)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
        values = (self.name, self.quantity, self.price, self.type, self.file_size, self.download_link)
        db_manager.execute_query(query, values)

    def update_stock(self, item_id, quantity):
        query = "UPDATE inventory SET quantity = %s WHERE id = %s"
        try:
            self.db_manager.execute_query(query, (quantity, item_id))
            logging.info(
                f"Item ID {item_id} updated: New Quantity = {quantity}"
            )
            print("Stock updated successfully.")
        except Exception as e:
            logging.error(f"Error updating item ID {item_id}: {e}")
            print("Failed to update stock.")
            print(f"Physical item with ID {item_id} updated to quantity {quantity}.")


class InventoryManager:
    def init(self, db_manager):
        self.db_manager = db_manager

    def get_all_items(self):
        query = "SELECT * FROM inventory"
        cursor = self.db_manager.connection.cursor()
        cursor.execute(query)
        items = cursor.fetchall()
        cursor.close()
        return items

    def remove_item(self, item_id):
        query = "DELETE FROM inventory WHERE id = %s"
        self.db_manager.execute_query(query, (item_id,))


new_db_manager = DatabaseManager("inventory", "parisa", "mypassword123", "127.0.0.1", "5432")
item = Inventory(None, "Laptop", 10, "1500.00", "physical")
item.add_and_save_to_db(new_db_manager)


class DatabaseManager:
    # our database info
    def init(self, db_name, db_user, db_password, db_host, db_port):
        self.connection = None
        try:
            self.connection = psycopg2.connect(
                database=db_name,
                user=db_user,
                password=db_password,
                host=db_host,
                port=db_port
            )
            print(f"Connection to PostgreSQL DB {db_name} successful.")
        except OperationalError as e:
            print(f"the error {e} occurred.")

    # to execute our query to work with database
    def execute_query(self, query, values=None):
        cursor = self.connection.cursor()
        try:
            cursor.execute(query, values)
            self.connection.commit()
            print("Query execute successfully.")
        except OperationalError as e:
            print(f"the error {e} occurred.")
        finally:
            cursor.close()

    def create_database(self, db_name):
        try:
            connection = psycopg2.connect(
                database="postgres",
                user="parisa",
                password="mypassword123",
                host="127.0.0.1",
                port="5432"
            )
            connection.autocommit = True
            cursor = connection.cursor()
            cursor.execute(f"CREATE DATABASE {db_name}")
            print(f"Database '{db_name}' created successfully.")
        except OperationalError as e:
            print(f"The error '{e}' occurred.")
        finally:
            if connection:
                cursor.close()
                connection.close()

    def create_table(self, create_table_query):
        self.execute_query(create_table_query)

    # def delete_table(self, table_name):
    #     drop_table_query = f"DROP TABLE IF EXISTS {table_name};"
    #     self.execute_query(drop_table_query)
    def add_column(self, table_name, column_name, column_type):
        query = f"ALTER TABLE {table_name} ADD {column_name} {column_type};"
        self.execute_query(query)


# db_manager = DatabaseManager("postgres", "parisa", "mypassword123", "127.0.0.1", "5432")
# db_manager.create_database("inventory")
new_db_manager = DatabaseManager("inventory", "parisa", "mypassword123", "127.0.0.1", "5432")
create_inventory_table = """
CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL NOT NULL,
    quantity INTEGER NOT NULL
);
"""

# new_db_manager.add_column("inventory", "type", "text")
