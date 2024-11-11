defmodule GroceryStore.ProductsTest do
  use ExUnit.Case, async: true
  alias GroceryStore.Products

  setup do
    Products.initialize_table()
    :ok
  end

  describe "initialize_table/0 and seed_products/0" do
    test "initializes table and seeds products" do
      assert Products.get_product("GR1") ==
               {:ok,
                %{
                  code: "GR1",
                  name: "Green tea",
                  price: 3.11,
                  discount_text: "Buy 1 get 1 free",
                  free_qty: 1,
                  min_buy_qty: 1
                }}

      assert Products.get_product("CF1") ==
               {:ok,
                %{
                  code: "CF1",
                  name: "Coffee",
                  price: 11.23,
                  discount_text: "Buy 3 or more and get each for 2/3rd price",
                  fraction: 2 / 3,
                  min_buy_qty: 3
                }}
    end
  end

  describe "upsert/1" do
    test "successfully creates a valid product" do
      new_product = %{
        code: "CH1",
        name: "Chocolate",
        price: 2.5,
        discount_text: "Buy 2 get 1 free",
        free_qty: 1,
        min_buy_qty: 2
      }

      assert {:ok, new_product} = Products.upsert(new_product)
      assert Products.get_product("CH1") == {:ok, new_product}
    end

    test "modifies existing product" do
      product = %{
        code: "SR1",
        name: "Strawberries",
        price: 3.0
      }

      assert {:ok, updated_product} = Products.upsert(product)
      assert Products.get_product("SR1") == {:ok, updated_product}
    end

    test "returns error for invalid product data" do
      invalid_product = %{
        code: "XX1",
        name: "Invalid Product",
        price: -5.0
      }

      assert Products.upsert(invalid_product) == {:error, :invalid_product_data}
    end

    test "returns error for invalid discount data" do
      product_with_invalid_discount = %{
        code: "XX1",
        name: "Invalid Discount Product",
        price: 10.0,
        discount_text: "Invalid discount",
        free_qty: -1,
        min_buy_qty: 2
      }

      assert Products.upsert(product_with_invalid_discount) == {:error, :invalid_discount_data}
    end

    test "should successfully create product when missing min_buy_qty / discount text" do
      product_with_missing_discount_qty = %{
        code: "XX1",
        name: "Product with missing min_buy_qty",
        price: 10.0,
        min_buy_qty: 2,
        free_qty: -1
      }

      product_with_missing_discount_text = %{
        code: "XX1",
        name: "Product with missing discount text",
        price: 10.0,
        discount_text: "Buy 1 get 1 free",
        free_qty: 1
      }

      assert Products.upsert(product_with_missing_discount_qty) ==
               {:ok, Map.take(product_with_missing_discount_qty, ~w(code name price)a)}

      assert Products.upsert(product_with_missing_discount_text) ==
               {:ok, Map.take(product_with_missing_discount_text, ~w(code name price)a)}
    end
  end

  describe "get_product/1" do
    test "fetches an existing product" do
      assert Products.get_product("GR1") ==
               {:ok,
                %{
                  code: "GR1",
                  name: "Green tea",
                  price: 3.11,
                  discount_text: "Buy 1 get 1 free",
                  free_qty: 1,
                  min_buy_qty: 1
                }}
    end

    test "returns error for non-existent product" do
      assert Products.get_product("NON_EXISTENT") == {:error, :not_found}
    end
  end
end
