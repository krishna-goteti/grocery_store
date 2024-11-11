# GroceryStore

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
GroceryStore.Products.upsert(%{code: "MG1", price: 10.0, name: "Mangoes", min_buy_qty: 2, discount_percent: 50})
```

### Cart Evaluation

The `GroceryStore` module calculates the total price of a cart, applying discounts based on product-specific rules. Discounts are automatically applied if the quantity conditions are met.

```elixir
# Example cart with product codes
iex> cart = ["GR1", "GR1", "CF1", "SR1"]

# Evaluate the cart
iex> {:ok, result} = GroceryStore.evaluate_cart(cart)
{:ok,
 %{
   actual_price: 22.45,
   cart_value: 19.34,
   discounts: 3.11,
   products: [
     %{
       code: "CF1",
       discount: 0.0,
       discount_text: "Buy 3 or more and get each for 2/3rd price",
       final_price: 11.23,
       fraction: 0.6666666666666666,
       min_buy_qty: 3,
       name: "Coffee",
       price: 11.23,
       quantity: 1
     },
     %{
       code: "GR1",
       discount: 3.11,
       discount_text: "Buy 1 get 1 free",
       final_price: 3.11,
       free_qty: 1,
       min_buy_qty: 1,
       name: "Green tea",
       price: 6.22,
       quantity: 2
     },
     %{
       code: "SR1",
       discount: 0.0,
       discount_text: "Buy 3 or more and get each for flat 4.5",
       final_price: 5.0,
       flat_price: 4.5,
       min_buy_qty: 3,
       name: "Strawberries",
       price: 5.0,
       quantity: 1
     }
   ],
   total_quantity: 4
 }}
```

### Discount Types

- **Buy X Get Y Free**: Automatically applies buy X get Y free discounts for products with `free_qty` and `min_buy_qty` attributes.
- **Flat Price Discount**: Applies a flat price to products when a specified minimum quantity is reached.
- **Fraction-Based Discount**: Discounts each item in the set to a fraction of its base price.
- **Percentage-Based Discount**: Reduces price based on a percentage when a minimum quantity is met.

## Testing and Coverage

To run the tests and ensure all functionalities are working as expected:

```bash
mix test
```

This will execute all test cases, covering product management, cart evaluation, and discount application scenarios.

Coverage for the GroceryStore

```bash
$ mix coveralls
Generated grocery_store app
.................
Finished in 0.1 seconds (0.1s async, 0.00s sync)
17 tests, 0 failures

Randomized with seed 288010
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/grocery_store.ex                          111       32        0
100.0% lib/products.ex                               132       19        0
[TOTAL] 100.0%
----------------
```

## Credo Checks

```bash
$ mix credo
Checking 5 source files ...

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 0.08 seconds (0.05s to load, 0.03s running 55 checks on 5 files)
25 mods/funs, found no issues.

Showing priority issues: ↑ ↗ →  (use `mix credo explain` to explain issues, `mix credo --help` for options).
```

## Dialyzer Checks

```bash
$ mix dialyzer
Finding suitable PLTs
Checking PLT...
[:compiler, :elixir, :grocery_store, :kernel, :logger, :stdlib]
PLT is up to date!
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
  check_plt: false,
  init_plt: '/Users/krishnagoteti/Documents/projects/grocery_store/_build/dev/dialyxir_erlang-24.3.4.2_elixir-1.14.5_deps-dev.plt',
  files: ['/Users/krishnagoteti/Documents/projects/grocery_store/_build/dev/lib/grocery_store/ebin/Elixir.GroceryStore.Products.beam',
   '/Users/krishnagoteti/Documents/projects/grocery_store/_build/dev/lib/grocery_store/ebin/Elixir.GroceryStore.beam'],
  warnings: [:unknown]
]
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m0.52s
done (passed successfully)
```

## Future Improvements

- **Enhanced Discount Rules**: Support for more complex discount rules and additional conditions.
- **Additional Cart Operations**: Implement features such as removing items from the cart and updating quantities.
- **Optimizations**: Improve efficiency for large carts and complex discount calculations.
- **Persistent Storage**: Transition to a more permanent storage solution (e.g., a database) for product data.
- **Upsert Efficiency** Take just Product Code and other fields inorder to modify the existing product
