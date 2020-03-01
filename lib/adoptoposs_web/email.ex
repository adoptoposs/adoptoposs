defmodule AdoptopossWeb.Email do
  @moduledoc """
  Defines all system emails.
  """

  use Bamboo.Phoenix, view: AdoptopossWeb.EmailView

  import AdoptopossWeb.Router.Helpers
  alias AdoptopossWeb.Endpoint

  defp base_email do
    new_email()
    |> from("Adoptoposs<notifications@#{System.get_env("HOST")}>")
    |> put_html_layout({AdoptopossWeb.LayoutView, "email.html"})
    |> put_text_layout({AdoptopossWeb.LayoutView, "email.text"})
  end
end
