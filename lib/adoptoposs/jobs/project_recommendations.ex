defmodule Adoptoposs.Jobs.ProjectRecommendations do
  @moduledoc """
  Job for emailing project recommendations to subscribed users.
  """

  import Ecto.Query, only: [from: 2]

  alias Adoptoposs.{Repo, Accounts, Submissions}
  alias Adoptoposs.Accounts.User
  alias AdoptopossWeb.Mailer

  @project_per_tag 3
  @task_max_concurrency 25
  @task_timeout 30_000

  @doc """
  Sends emails with recommended projects to all users with enabled setting.
  """
  def send_emails(setting) do
    opts = [max_concurrency: @task_max_concurrency, timeout: @task_timeout]

    setting
    |> get_user_ids()
    |> Task.async_stream(&send_email/1, opts)
    |> Enum.reduce([], &collect_emails/2)
  end

  defp get_user_ids(setting) do
    Repo.all(
      from u in User,
        select: u.id,
        where: fragment("settings->>'email_project_recommendations' = ?", ^to_string(setting))
    )
  end

  defp send_email(user_id) do
    user = Accounts.get_user!(user_id, preload: [tag_subscriptions: [:tag]])
    projects = list_recommended_projects(user)

    if Enum.any?(projects) do
      Mailer.send_project_recommendations_email(user, projects)
    else
      nil
    end
  end

  defp collect_emails(result, emails) do
    case result do
      {:ok, nil} -> emails
      {:ok, email} -> emails ++ [email]
      _ -> emails
    end
  end

  defp list_recommended_projects(user) do
    Enum.reduce(user.tag_subscriptions, [], fn tag_subscription, projects ->
      tag = tag_subscription.tag
      options = [preload: [:language, :user], limit: @project_per_tag]

      projects ++ Submissions.list_recommended_projects(user, tag, options)
    end)
  end
end
