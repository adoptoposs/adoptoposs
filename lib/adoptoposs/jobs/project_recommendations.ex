defmodule Adoptoposs.Jobs.ProjectRecommendations do
  @moduledoc """
  Job for emailing project recommendations to subscribed users.
  """

  import Ecto.Query, only: [from: 2]

  alias Adoptoposs.{Repo, Accounts, Submissions}
  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.Mailer

  @project_per_tag 3

  @doc """
  Sends emails with recommended projects to all users with enabled setting.
  """
  def send_emails(setting) do
    setting
    |> get_user_ids()
    |> Task.async_stream(&send_email/1, max_concurrency: 25)
    |> Enum.reduce(0, fn result, sum ->
      case result do
        {:ok, n} -> sum + n
        _ -> sum
      end
    end)
  end

  defp get_user_ids(setting) do
    Repo.all(from u in User,
      select: u.id,
      where: fragment("settings->>'email_project_recommendations' = ?", ^to_string(setting))
    )
  end

  defp send_email(user_id) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])
    projects = list_recommended_projects(user)

    if Enum.any?(projects) do
      Mailer.send_project_recommendations_email(user, projects)
      1
    else
      0
    end
  end

  defp list_recommended_projects(user) do
    Enum.reduce(user.tag_subscriptions, [], fn tag_subscription, projects ->
      tag = tag_subscription.tag
      options = [preload: :language, limit: @project_per_tag]

      projects ++ Submissions.list_recommended_projects(user, tag, options)
    end)
  end
end
