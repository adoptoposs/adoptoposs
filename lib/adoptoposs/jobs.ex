defmodule Adoptoposs.Jobs do
  @moduledoc """
  Defines routines to be run as jobs.

  The default day for sending emails is Friday (5). The day can be overwritten
  by setting the EMAIL_WEEKDAY System env var.
  """

  alias Adoptoposs.Jobs.{Policy, ProjectRecommendations}
  alias Adoptoposs.Accounts.Settings

  @default_email_weekday 6 # Friday

  defdelegate authorize(action, date, params), to: Policy

  @doc """
  Sends project recommendation emails for all users using their account settings.

  Returns the state an number of sent emails per setting.

  ## Examples

      iex> send_project_recommendations(policy)
      [{:ok, {"weekly", 250}}, {:error, {"monthly", 0}}]

  """
  def send_project_recommendations(policy \\ Policy) do
    settings = Settings.email_project_recommendations_values() -- ["off"]

    for setting <- settings do
      action = :"send_emails_#{setting}"

      with :ok <- Bodyguard.permit(policy, action, Timex.today(), email_weekday()),
         count <- ProjectRecommendations.send_emails(setting) do
      {:ok, {setting, count}}
    else
      {:error, :unauthorized} ->
        {:error, {setting, 0}}

      {:error, reason} ->
        {:error, reason}
    end

    end
  end

  defp email_weekday do
    System.get_env("EMAIL_WEEKDAY") || @default_email_weekday
  end
end
