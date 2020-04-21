defmodule AdoptopossWeb.Email do
  @moduledoc """
  Defines all system emails.
  """

  use Bamboo.Phoenix, view: AdoptopossWeb.EmailView

  import AdoptopossWeb.Router.Helpers
  alias AdoptopossWeb.Endpoint
  alias Adoptoposs.Mjml

  def interest_received_email(interest) do
    %{project: project, creator: creator} = interest
    project_url = live_url(Endpoint, AdoptopossWeb.ProjectLive.Show, project.id)

    base_email()
    |> to(project.user.email)
    |> subject("[Adoptoposs][#{project.name}] #{creator.name} wrote you a message")
    |> put_header("Reply-To", creator.email)
    |> assign(:interest, interest)
    |> assign(:project_url, project_url)
    |> render_mjml(:interest_received)
  end

  def project_recommendations_email(user, projects) do
    base_email()
    |> to(user.email)
    |> subject("[Adoptoposs] Projects you might like to help maintain")
    |> assign(:user, user)
    |> assign(:projects, projects)
    |> render_mjml(:project_recommendations)
  end

  defp base_email do
    new_email()
    |> from("Adoptoposs<notifications@#{System.get_env("HOST")}>")
    |> put_html_layout({AdoptopossWeb.LayoutView, "email.html"})
    |> put_text_layout({AdoptopossWeb.LayoutView, "email.text"})
  end

  def render_mjml(email, template, assigns \\ []) do
    result = render(email, template, assigns)
    Map.put(result, :html_body, Mjml.render(Map.get(result, :html_body)))
  end
end
