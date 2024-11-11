# GroceryStore

![Test and Coverage](https://github.com/username/repository/actions/workflows/test.yml/badge.svg)

GroceryStore is an Elixir-based module designed to handle basic grocery cart management with a discount system. It evaluates a shopping cart by calculating final prices, applying discounts, and providing a breakdown of actual costs versus discounts. This module demonstrates key functionalities common in e-commerce settings.

## Features

- **Product Management**:

  - Supports products with unique codes, names, and base prices.
  - Applies product-specific discounts.
  - Available discount types: buy X get Y free, flat price discounts, fraction-based discounts, and percentage-based discounts.

- **Cart Evaluation**:
  - Adds products to a cart and calculates total costs.
  - Applies relevant discounts based on products from the cart.
  - Provides detailed breakdowns, including original price, discounts, and final cart value.

## Installation

To use this module, follow these steps:

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Install dependencies:

   ```bash
   mix deps.get
   ```

3. Compile the project:
   ```bash
   mix compile
   ```

## Usage

### Product Management

The `GroceryStore.Products` module initializes a set of default products with discount rules. You can also add new products and apply discounts to them.

```elixir
# Initialize the products table with default products
GroceryStore.Products.initialize_table()

# Fetch a product by its code
GroceryStore.Products.get_product("GR1")

# Updates existing product without discount (Code, Price and Name are required for any product modifications)
GroceryStore.Products.upsert(%{code: "SR1", price: 5.0, name: "Strawberries"})

# Create a new product with discount
GroceryStore.Products.upsert(%{code: "MG1", price: 10.0, name: "Strawberries", min_buy_qty: 2, discount_percent: 50})
```

### Cart Evaluation

The `GroceryStore` module calculates the total price of a cart, applying discounts based on product-specific rules. Discounts are automatically applied if the quantity conditions are met.

```elixir
# Example cart with product codes
cart = ["GR1", "GR1", "CF1", "SR1"]

# Evaluate the cart
{:ok, result} = GroceryStore.evaluate_cart(cart)

# Display results
IO.inspect(result, label: "Cart Evaluation Result")
```

### Discount Types

- **Buy X Get Y Free**: Automatically applies buy X get Y free discounts for products with `free_qty` and `min_buy_qty` attributes.
- **Flat Price Discount**: Applies a flat price to products when a specified minimum quantity is reached.
- **Fraction-Based Discount**: Discounts each item in the set to a fraction of its base price.
- **Percentage-Based Discount**: Reduces price based on a percentage when a minimum quantity is met.

## Testing

To run the tests and ensure all functionalities are working as expected:

```bash
mix test
```

This will execute all test cases, covering product management, cart evaluation, and discount application scenarios.

## Future Improvements

- **Enhanced Discount Rules**: Support for more complex discount rules and additional conditions.
- **Additional Cart Operations**: Implement features such as removing items from the cart and updating quantities.
- **Optimizations**: Improve efficiency for large carts and complex discount calculations.
- **Persistent Storage**: Transition to a more permanent storage solution (e.g., a database) for product data.
- **Upsert Efficiency** Take just Product Code and other fields inorder to modify the existing product
