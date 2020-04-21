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

    assert email.html_body =~
             ~r/you’ve got a new message for your project.+#{interest.project.name}/

    assert email.html_body =~ interest.message

    assert email.text_body =~
             ~r/you’ve got a new message for your project "#{interest.project.name}"/

    assert email.text_body =~ interest.message
  end

  test "project recommendations email" do
    user = build(:user)
    elixir_projects = build_list(2, :project, language: build(:language, name: "Elixir"))
    js_projects = build_list(2, :project, language: build(:language, name: "JavaScript"))
    build_list(2, :project, language: build(:language, name: "Ruby"))

    projects = elixir_projects ++ js_projects
    email = Email.project_recommendations_email(user, projects)

    assert email.to == user.email
    assert email.subject =~ "[Adoptoposs] Projects you might like to help maintain"

    assert email.html_body =~ "Elixir"
    assert email.html_body =~ "JavaScript"
    refute email.html_body =~ "Ruby"

    assert email.text_body =~ "Elixir"
    assert email.text_body =~ "JavaScript"
    refute email.text_body =~ "Ruby"

    for project <- projects do
      assert email.html_body =~ project.name
      assert email.text_body =~ project.name
    end
  end
end
