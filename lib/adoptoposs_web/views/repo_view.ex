defmodule AdoptopossWeb.RepoView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Network.Repository

  def selected_attr(attr, other_attr) do
    if attr == other_attr, do: :selected
  end

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

  defp maintainance_type(percent) when percent >= 0.66, do: "green"
  defp maintainance_type(percent) when percent >= 0.33, do: "yellow"
  defp maintainance_type(percent) when percent < 0.33, do: "red"

  def switch_type(%Plug.Conn{params: %{"type" => "help"}}), do: "yellow"
  def switch_type(conn), do: "red"
end
