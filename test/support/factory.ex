defmodule Adoptoposs.Factory do
  @moduledoc """
  Defines the factories to create records and resources
  """

  use ExMachina.Ecto, repo: Adoptoposs.Repo

  alias Adoptoposs.{Network, Accounts, Submissions, Communication, Tags}

  def user_factory do
    %Accounts.User{
      uid: sequence("uid"),
      provider: "provider",
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence("User"),
      username: sequence("username"),
      avatar_url: sequence(:avatar_url, &"https://example.com/avatar-#{&1}.png?s=64"),
      profile_url: sequence(:avatar_url, &"https://example.com/profile/#{&1}"),
      settings: %Accounts.Settings{}
    }
  end

  def project_factory do
    repo_id = sequence("repo_id")
    owner = build(:contributor, login: sequence("owner"))
    repo = build(:repository, id: repo_id, owner: owner)
    uuid = Ecto.UUID.generate()

    %Submissions.Project{
      name: sequence("project"),
      language: build(:tag),
      # encode and decode repository to get the data as it is stored in the database
      data: repo |> Jason.encode!() |> Jason.decode!(),
      user: build(:user),
      description: "another co-maintainer",
      repo_id: repo_id,
      repo_owner: owner.login,
      repo_description: repo.description,
      uuid: uuid,
      status: :published
    }
  end

  def auth_factory do
    %Ueberauth.Auth{
      uid: sequence("uid"),
      provider: "provider",
      info: %{
        name: sequence("name"),
        nickname: sequence("nickname"),
        email: sequence(:email, &"user#{&1}@example.com"),
        first_name: nil,
        last_name: nil,
        urls: %{
          avatar_url: sequence(:avatar_url, &"https://example.com/avatar-#{&1}.png?s=80"),
          html_url: sequence(:avatar_url, &"https://example.com/profile/#{&1}")
        }
      }
    }
  end

  def language_factory do
    %Network.Repository.Language{
      name: sequence("Language"),
      color: "#4E30A3"
    }
  end

  def contributor_factory do
    %Network.Repository.User{
      id: sequence("id"),
      name: sequence("User"),
      login: sequence("user"),
      avatar_url: sequence(:avatar_url, &"https://example.com/user#{&1}.png"),
      profile_url: sequence(:profile_url, &"https://example.com/user#{&1}"),
      email: sequence(:email, &"user#{&1}@example.com")
    }
  end

  def organization_factory do
    %Network.Organization{
      id: sequence("id"),
      name: sequence("organization"),
      description: sequence("Orga description "),
      avatar_url: sequence(:avatar_url, &"https://example.com/user#{&1}.png")
    }
  end

  def page_info_factory do
    %Network.PageInfo{
      has_next_page: false,
      end_cursor: "123"
    }
  end

  def repository_factory do
    %Network.Repository{
      id: sequence("id"),
      name: sequence("Repo"),
      description: "Solving all the issues",
      url: sequence(:url, &"https://example.com/repos/repo#{&1}"),
      owner: build(:contributor),
      language: build(:language),
      star_count: 0,
      watcher_count: 0,
      pull_request_count: 0,
      issue_count: 0
    }
  end

  def interest_factory do
    %Communication.Interest{
      message: sequence("Hi, user"),
      creator: build(:user),
      project: build(:project)
    }
  end

  def tag_factory do
    %Tags.Tag{
      name: sequence("tag"),
      type: sequence("language"),
      color: "#123456"
    }
  end

  def tag_subscription_factory do
    %Tags.TagSubscription{
      user: build(:user),
      tag: build(:tag)
    }
  end
end
