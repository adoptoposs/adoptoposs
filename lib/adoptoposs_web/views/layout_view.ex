defmodule AdoptopossWeb.LayoutView do
  use AdoptopossWeb, :view

  def email_header_image(:notification) do
    image_url("adoptoposs-contact.png")
  end

  def email_header_image(_email_type) do
    image_url("adoptoposs-message.png")
  end

  def email_footer_background(:notification), do: "#2d3748"
  def email_footer_background(_email_type), do: "#f56565"

  defp image_url(image_name) do
    Routes.static_url(AdoptopossWeb.Endpoint, "/images/#{image_name}")
  end
end
