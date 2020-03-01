defmodule AdoptopossWeb.Email do
  @moduledoc """
  Defines all system emails.
  """

  use Bamboo.Phoenix, view: AdoptopossWeb.EmailView

  import AdoptopossWeb.Router.Helpers
  alias AdoptopossWeb.Endpoint

  def interest_received_email(interest) do
    %{project: project, creator: creator} = interest
    project_url = live_url(Endpoint, AdoptopossWeb.ProjectLive.Show, project.id)

    base_email()
    |> to(project.user.email)
    |> subject("[Adoptoposs][#{project.name}] #{creator.name} wrote you a message")
    |> put_header("Reply-To", creator.email)
    |> assign(:interest, interest)
    |> assign(:project_url, project_url)
    |> render(:interest_received)
  end

  defp base_email do
    new_email()
    |> from("Adoptoposs<notifications@#{System.get_env("HOST")}>")
    |> put_html_layout({AdoptopossWeb.LayoutView, "email.html"})
    |> put_text_layout({AdoptopossWeb.LayoutView, "email.text"})
  end
end
