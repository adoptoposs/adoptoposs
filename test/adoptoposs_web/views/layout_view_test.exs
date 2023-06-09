defmodule AdoptopossWeb.LayoutViewTest do
  use AdoptopossWeb.ConnCase, async: true

  alias AdoptopossWeb.LayoutView

  test "email_header_image/1 returns messages image url for newsletter type" do
    assert LayoutView.email_header_image(:newsletter) =~ "/images/adoptoposs-message.webp"
  end

  test "email_header_image/1 returns notification image url for other types" do
    assert LayoutView.email_header_image(:notification) =~ "/images/adoptoposs-contact.webp"
  end

  test "email_footer_background/1 returns different colors for different layout type" do
    color_1 = LayoutView.email_footer_background(:notification)
    color_2 = LayoutView.email_footer_background(:newsletter)

    assert color_1 =~ ~r/\#[0-9a-f]{6}/
    assert color_2 =~ ~r/\#[0-9a-f]{6}/
    refute color_1 == color_2
  end
end
