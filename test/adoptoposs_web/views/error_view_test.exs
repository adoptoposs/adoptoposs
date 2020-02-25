defmodule AdoptopossWeb.ErrorViewTest do
  use AdoptopossWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    page = render_to_string(AdoptopossWeb.ErrorView, "404.html", [])
    assert page =~ ~r"page(.+) is not available"
  end

  test "renders 500.html" do
    page = render_to_string(AdoptopossWeb.ErrorView, "500.html", [])
    assert page =~ "Looks like you found a bug"
  end
end
