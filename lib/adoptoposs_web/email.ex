defmodule AdoptopossWeb.Email do
  @moduledoc """
  Defines all system emails.
  """

  use Bamboo.Phoenix, view: AdoptopossWeb.EmailView

  import AdoptopossWeb.Router.Helpers
  alias AdoptopossWeb.Endpoint

  def interest_received_email(interest) do
    %{project: project, creator: creator} = interest

    message_url =
      live_url(Endpoint, AdoptopossWeb.MessagesLive.Interests) <> "/#p-#{project.uuid}"

    base_email(:notification)
    |> to(project.user.email)
    |> subject("[Adoptoposs][#{project.name}] #{creator.name} wrote you a message")
    |> put_header("Reply-To", creator.email)
    |> assign(:interest, interest)
    |> assign(:message_url, message_url)
    |> render_mjml(:interest_received)
  end

  def project_recommendations_email(user, projects) do
    base_email(:newsletter)
    |> to(user.email)
    |> subject("[Adoptoposs] Projects you might like to help maintain")
    |> assign(:user, user)
    |> assign(:projects, projects)
    |> render_mjml(:project_recommendations)
  end

  defp base_email(layout_type) do
    new_email()
    |> from("Adoptoposs<notifications@#{Endpoint.host()}>")
    |> put_html_layout({AdoptopossWeb.LayoutView, "email.html"})
    |> put_text_layout({AdoptopossWeb.LayoutView, "email.text"})
    |> assign(:layout_type, layout_type)
  end

  def render_mjml(email, template, assigns \\ []) do
    result = render(email, template, assigns)

    {:ok, html_body} =
      result
      |> Map.get(:html_body)
      |> Mjml.to_html(mjml_options())

    Map.put(result, :html_body, html_body)
  end

  defp mjml_options do
    [
      keep_comments: false,
      fonts: %{
        "Source Sans Pro": "https://fonts.googleapis.com/css?family=Source+Sans+Pro",
        Oswald: "https://fonts.googleapis.com/css?family=Oswald"
      }
    ]
  end
end
