defmodule GroceryStore.Products do
  @moduledoc """
  Module for managing products and their discounts in the ETS table.
  """

  @table :products

  @type product :: %{
          code: String.t(),
          name: String.t(),
          price: float(),
          discount_text: String.t(),
          min_buy_qty: non_neg_integer(),
          free_qty: non_neg_integer(),
          flat_price: float(),
          fraction: float(),
          discount_percent: non_neg_integer()
        }

  @default_products [
    %{
      code: "GR1",
      discount_text: "Buy 1 get 1 free",
      free_qty: 1,
      min_buy_qty: 1,
      name: "Green tea",
      price: 3.11
    },
    %{
      code: "CF1",
      discount_text: "Buy 3 or more and get each for 2/3rd price",
      fraction: 2 / 3,
      min_buy_qty: 3,
      name: "Coffee",
      price: 11.23
    },
    %{
      code: "SR1",
      discount_text: "Buy 3 or more and get each for flat 4.5",
      flat_price: 4.5,
      min_buy_qty: 3,
      name: "Strawberries",
      price: 5.0
    },
    %{
      code: "AP1",
      discount_text: "Buy 3 or more and get discount of 10%",
      discount_percent: 10,
      min_buy_qty: 3,
      name: "Apples",
      price: 4.0
    }
  ]

  @spec initialize_table() :: :ok
  def initialize_table do
    :ets.new(@table, [:named_table, :public, :set])

    Enum.each(@default_products, &upsert/1)

    :ok
  end

  @spec upsert(map()) :: {:ok, map()} | {:error, term()}
  def upsert(product) do
    with {:ok, product_data} <- validate_product(Map.take(product, ~w(code price name)a)),
         {:ok, discount} <- validate_discount(Map.drop(product, ~w(code price name)a)) do
      product_with_discount = Map.merge(product_data, discount)

      :ets.insert(@table, {product_with_discount.code, product_with_discount})
      {:ok, product_with_discount}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_product(String.t()) :: {:ok, map()} | {:error, :not_found}
  def get_product(code) do
    case :ets.lookup(@table, code) do
      [{^code, product_data}] -> {:ok, product_data}
      [] -> {:error, :not_found}
    end
  end

  # Validations and private functions

  @spec validate_product(map()) :: {:ok, map()} | {:error, term()}
  defp validate_product(%{code: code, name: name, price: price})
       when is_binary(code) and is_binary(name) and is_float(price) and price > 0 do
    {:ok, %{code: code, name: name, price: price}}
  end

  defp validate_product(_), do: {:error, :invalid_product_data}

  @spec validate_discount(map()) :: {:ok, map()} | {:error, term()}
  defp validate_discount(discount_data) do
    case discount_data do
      # Validate each discount type if present
      %{discount_text: discount_text, min_buy_qty: min_buy_qty} = data
      when is_binary(discount_text) and is_integer(min_buy_qty) and min_buy_qty > 0 ->
        validate_discount_fields(data)

      # If no discount data is provided or any unrelated fields, return an empty map
      _ ->
        {:ok, %{}}
    end
  end

  # Validate additional fields based on discount types
  defp validate_discount_fields(%{free_qty: free_qty} = discount_data)
       when is_integer(free_qty) and free_qty > 0 do
    {:ok, discount_data}
  end

  defp validate_discount_fields(%{flat_price: flat_price} = discount_data)
       when is_float(flat_price) and flat_price > 0 do
    {:ok, discount_data}
  end

  defp validate_discount_fields(%{fraction: fraction} = discount_data)
       when is_float(fraction) and fraction > 0 and fraction < 1 do
    {:ok, discount_data}
  end

  defp validate_discount_fields(%{discount_percent: discount_percent} = discount_data)
       when is_integer(discount_percent) and discount_percent > 0 and discount_percent <= 100 do
    {:ok, discount_data}
  end

  # Catch-all for cases with no matching discount fields
  defp validate_discount_fields(_), do: {:error, :invalid_discount_data}
end
