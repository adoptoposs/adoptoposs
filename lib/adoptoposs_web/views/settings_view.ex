defmodule AdoptopossWeb.SettingsView do
  use AdoptopossWeb, :view

  @doc """
  Returns whether the key in settings currently has the given value.
  """
  def active?(%Ecto.Changeset{data: data}, key, value) do
    Map.get(data.settings, key) == value
  end
end
