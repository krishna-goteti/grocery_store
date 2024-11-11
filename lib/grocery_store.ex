defmodule GroceryStore do
  alias GroceryStore.Products

  @spec evaluate_cart(list()) ::
          {:ok, %{products: list(), total: float()}} | {:error, list(String.t()) | :invalid_cart}
  def evaluate_cart(products) when is_list(products) do
    with {cart, []} <- process_products(products),
         {discounted_products, []} <- process_cart(cart) do
      {:ok, calculate_final_cart(discounted_products)}
    else
      {_, errors} -> {:error, errors}
    end
  end

  def evaluate_cart(_), do: {:error, :invalid_cart}

  defp process_products(products) do
    Enum.reduce(products, {%{}, []}, fn
      product, {cart, errors} when is_binary(product) ->
        {Map.update(cart, product, 1, &(&1 + 1)), errors}

      product, {cart, errors} ->
        {cart, ["Invalid product format: #{inspect(product)}" | errors]}
    end)
  end

  # Calculate total values from evaluated products with discounts
  defp calculate_final_cart(discounted_products) do
    Enum.reduce(
      discounted_products,
      %{
        products: discounted_products,
        total_quantity: 0,
        cart_value: 0.0,
        actual_price: 0.0,
        discounts: 0.0
      },
      fn product, acc ->
        %{
          products: acc.products,
          total_quantity: acc.total_quantity + product.quantity,
          cart_value: acc.cart_value + product.final_price,
          actual_price: acc.actual_price + product.price,
          discounts: acc.discounts + product.discount
        }
      end
    )
  end

  defp process_cart(cart) do
    {products, errors} =
      cart
      |> Enum.map(fn {code, qty} ->
        case Products.get_product(code) do
          {:ok, product} ->
            final_price = calculate_final_price(product, qty)
            actual_price = qty * product.price

            {Map.merge(product, %{
               discount: actual_price - final_price,
               final_price: final_price,
               price: actual_price,
               quantity: qty
             }), nil}

          {:error, :not_found} ->
            {nil, "Product not found: #{code}"}
        end
      end)
      |> Enum.unzip()

    {Enum.reject(products, &is_nil/1), Enum.reject(errors, &is_nil/1)}
  end

  # Buy X, Get Y Free Discount
  defp calculate_final_price(%{free_qty: free_qty, min_buy_qty: min_buy_qty, price: price}, qty)
       when qty >= min_buy_qty do
    eligible_qty = div(qty, min_buy_qty + free_qty) * min_buy_qty
    total_qty = eligible_qty + rem(qty, min_buy_qty + free_qty)
    total_qty * price
  end

  # Flat Price Discount
  defp calculate_final_price(%{flat_price: flat_price, min_buy_qty: min_buy_qty}, qty)
       when qty >= min_buy_qty do
    qty * flat_price
  end

  # Fraction-Based Discount
  defp calculate_final_price(%{fraction: fraction, min_buy_qty: min_buy_qty, price: price}, qty)
       when qty >= min_buy_qty do
    discounted_price = price * fraction
    qty * discounted_price
  end

  # Percentage-Based Discount
  defp calculate_final_price(
         %{discount_percent: percent, min_buy_qty: min_buy_qty, price: price},
         qty
       )
       when qty >= min_buy_qty do
    discount_amount = price * (percent / 100.0)
    discounted_price = price - discount_amount
    qty * discounted_price
  end

  # No Discount
  defp calculate_final_price(%{price: price}, qty) do
    qty * price
  end
end
