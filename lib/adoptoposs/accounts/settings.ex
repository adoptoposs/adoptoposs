defmodule Adoptoposs.Accounts.Settings do
  @moduledoc """
  The schema representing the account settings of a user.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :email_when_contacted,
    :email_project_recommendations
  ]

  @email_when_contacted_values ~w(
    immediately
    off
  )

  @email_project_recommendations_values ~w(
    weekly
    biweekly
    monthly
    off
  )

  embedded_schema do
    field :email_when_contacted, :string, default: List.first(@email_when_contacted_values)

    field :email_project_recommendations, :string,
      default: List.first(@email_project_recommendations_values)
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, @fields)
    |> validate_allowed(:email_when_contacted, @email_when_contacted_values)
    |> validate_allowed(:email_project_recommendations, @email_project_recommendations_values)
  end

  @doc """
  Returns all allowed values for the email_on_contact setting.
  """
  def email_when_contacted_values do
    @email_when_contacted_values
  end

  @doc """
  Returns all allowed values for the email_project_recommendations setting.
  """
  def email_project_recommendations_values do
    @email_project_recommendations_values
  end

  defp validate_allowed(changeset, field, values) do
    validate_change(changeset, field, fn _field, value ->
      if value in values do
        []
      else
        valid_values = Enum.join(values, ", ")
        message = "value for :#{field} must be one of [#{valid_values}], you passed: `#{value}`"
        put_in([], [field], message)
      end
    end)
  end
end
