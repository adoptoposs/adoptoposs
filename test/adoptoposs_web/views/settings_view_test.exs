defmodule AdoptopossWeb.SettingsViewTest do
  use AdoptopossWeb.ConnCase, async: true

  import Adoptoposs.Factory

  alias AdoptopossWeb.SettingsView

  setup do
    value = "off"
    key = :email_when_contacted

    changeset =
      :user
      |> build(settings: %{key => value})
      |> Ecto.Changeset.cast(%{}, [])
      |> Ecto.Changeset.cast_embed(:settings)

    {:ok, changeset: changeset, key: key, value: value}
  end

  test "active?/3 returns true if the given key/value pair exits in the changeset",
       %{changeset: changeset, key: key, value: value} do
    assert SettingsView.active?(changeset, key, value)
  end

  test "active?/3 returns false if the given key/value pair does not exits in the changeset",
       %{changeset: changeset, key: key, value: value} do
    refute SettingsView.active?(changeset, key, "other" <> value)
    refute SettingsView.active?(changeset, :"other_#{key}", value)
  end
end
