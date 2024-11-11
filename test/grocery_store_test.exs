defmodule GroceryStoreTest do
  use ExUnit.Case, async: true
  alias GroceryStore.Products
  alias GroceryStore

  setup do
    Products.initialize_table()
    :ok
  end

  describe "evaluate_cart/1" do
    test "calculates cart with mixed discounts correctly" do
      cart = ~w(GR1 GR1 CF1 CF1 CF1 SR1)

      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 6
      assert_in_delta(result.cart_value, 30.57, 0.01)
      assert_in_delta(result.actual_price, 44.91, 0.01)
      assert_in_delta(result.discounts, 14.34, 0.01)

      assert Enum.any?(result.products, fn p -> p.code == "GR1" and p.final_price == 3.11 end)
      assert Enum.any?(result.products, fn p -> p.code == "CF1" and p.final_price == 22.46 end)

      # No discount for strawberries
      assert Enum.any?(result.products, fn p ->
               p.code == "SR1" and p.final_price == 5.0
             end)

      cart = ~w(SR1 SR1 GR1 SR1)

      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert_in_delta(result.cart_value, 16.61, 0.01)

      cart = ~w(GR1 SR1 GR1 GR1 CF1)

      {:ok, result} = GroceryStore.evaluate_cart(cart)
      assert_in_delta(result.cart_value, 22.45, 0.01)
    end

    test "calculates cart with buy X get Y free discount correctly" do
      cart = ["GR1", "GR1"]
      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 2
      assert_in_delta(result.cart_value, 3.11, 0.01)
      assert_in_delta(result.actual_price, 6.22, 0.01)
      assert_in_delta(result.discounts, 3.11, 0.01)
    end

    test "calculates cart with flat price discount correctly" do
      cart = ["SR1", "SR1", "SR1"]
      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 3
      assert_in_delta(result.cart_value, 13.5, 0.01)
      assert_in_delta(result.actual_price, 15.0, 0.01)
      assert_in_delta(result.discounts, 1.5, 0.01)
    end

    test "calculates cart with fraction-based discount correctly" do
      cart = ["CF1", "CF1", "CF1"]
      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 3
      assert_in_delta(result.cart_value, 22.46, 0.01)
      assert_in_delta(result.actual_price, 33.69, 0.01)
      assert_in_delta(result.discounts, 11.23, 0.01)
    end

    test "calculates cart with percentage-based discount correctly" do
      cart = ["AP1", "AP1", "AP1"]
      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 3
      assert_in_delta(result.cart_value, 10.8, 0.01)
      assert_in_delta(result.actual_price, 12.0, 0.01)
      assert_in_delta(result.discounts, 1.2, 0.01)
    end

    test "returns error for invalid product format" do
      cart = ["GR1", 123, %{}]
      assert {:error, errors} = GroceryStore.evaluate_cart(cart)
      assert "Invalid product format: 123" in errors
      assert "Invalid product format: %{}" in errors
    end

    test "returns error for non-existent product code" do
      cart = ["GR1", "UNKNOWN"]
      assert {:error, errors} = GroceryStore.evaluate_cart(cart)
      assert "Product not found: UNKNOWN" in errors
    end

    test "returns empty results for empty cart" do
      cart = []
      {:ok, result} = GroceryStore.evaluate_cart(cart)

      assert result.total_quantity == 0
      assert result.cart_value == 0.0
      assert result.actual_price == 0.0
      assert result.discounts == 0.0
      assert result.products == []
    end

    test "returns error for invalid cart" do
      cart = %{}

      assert {:error, :invalid_cart} = GroceryStore.evaluate_cart(cart)
    end
  end
end
