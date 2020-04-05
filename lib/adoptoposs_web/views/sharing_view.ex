defmodule AdoptopossWeb.SharingView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Submissions.Project
  alias Adoptoposs.Accounts.User

  def title(%{project: project}) when not is_nil(project) do
    "#{AdoptopossWeb.SharedView.project_name(project)} needs your help!"
  end

  def title(_assigns) do
    "Adoptoposs · Keep open source software maintained"
  end

  def description(%{project: %Project{user: %User{username: username}} = project}) do
    "@#{username} is looking for: #{String.trim(project.description)}"
  end

  def description(_assigns) do
    "Adoptoposs helps maintainers of open source software to finding co-maintainers or people to take over their project."
  end

  def image(%{project: project}) when not is_nil(project) do
    project.data["owner"]["avatar_url"]
  end

  def image(assigns) do
    Routes.static_url(assigns.conn, "/images/adoptoposs-social.jpg")
  end

  def url(assigns) do
    Plug.Conn.request_url(assigns.conn)
  end

  def twitter_card_type(%{project: _project}), do: "summary"
  def twitter_card_type(_assigns), do: "summary_large_image"
end
