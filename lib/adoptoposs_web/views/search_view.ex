defmodule AdoptopossWeb.SearchView do
  use AdoptopossWeb, :view
  alias Adoptoposs.Network.Repository

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

  def updated_ago(_date), do: ""

  def maintainance_need(%Repository{} = repo) do
    repo
    |> Adoptoposs.Projects.score()
    |> maintainance_type()
  end

  defp maintainance_type(percent) when percent > 0.9, do: "green"
  defp maintainance_type(percent) when percent > 0.3, do: "yellow"
  defp maintainance_type(percent) when percent < 0.3, do: "red"
end
