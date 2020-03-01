defmodule AdoptopossWeb.EmailTest do
  use ExUnit.Case, async: true
  use Bamboo.Test

  import Adoptoposs.Factory

  alias AdoptopossWeb.Email

  test "interest received email" do
    interest = build(:interest, inserted_at: DateTime.utc_now(), project: build(:project, id: 1))
    email = Email.interest_received_email(interest)

    assert email.to == interest.project.user.email
    assert email.subject =~ "[Adoptoposs][#{interest.project.name}]"

    assert email.html_body =~ ~r/you’ve got a new message for your project.+#{interest.project.name}/
    assert email.html_body =~ interest.message

    assert email.text_body =~ ~r/you’ve got a new message for your project "#{interest.project.name}"/
    assert email.text_body =~ interest.message
  end
end
