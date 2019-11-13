defmodule AdoptopossWeb.SearchView do
  use AdoptopossWeb, :view

  def readable_number(number) when number > 1_000 do
    decimal = Float.floor(number / 1_000, 1)
    "#{decimal}k"
  end

  def readable_number(number) when number > 1_000_000 do
    decimal = Float.floor(number / 1_000_000, 1)
    "#{decimal}M"
  end

  def readable_number(number), do: "#{number}"

  def updated_ago(%DateTime{} = date) do
    Timex.from_now(date)
  end
end
