defmodule Adoptoposs.Factory do
  @moduledoc """
  Defines the factories to create records and resources
  """

  use ExMachina.Ecto, repo: Adoptoposs.Repo

  alias Adoptoposs.{Network, Accounts, Dashboard}

  def user_factory do
    %Accounts.User{
      uid: sequence("uid"),
      provider: "provider",
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence("User"),
      username: sequence("username"),
      avatar_url: sequence(:avatar_url, &"https://example.com/avatar-#{&1}.png"),
      profile_url: sequence(:avatar_url, &"https://example.com/profile/#{&1}")
    }
  end

  def project_factory do
    %Dashboard.Project{
      name: sequence("project"),
      language: sequence("language"),
      data: %{"some" => %{"nested" => "data"}},
      user: build(:user),
      description: "Description",
      repo_id: sequence("repo_id")
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
          avatar_url: sequence(:avatar_url, &"https://example.com/avatar-#{&1}.png"),
          html_url: sequence(:avatar_url, &"https://example.com/profile/#{&1}")
        }
      }
    }
  end

  def language_factory do
    %Network.Repository.Language{name: "Elixir", color: "#4E30A3"}
  end

  def contributor_factory do
    %Network.Repository.User{
      name: sequence("User"),
      login: sequence("user"),
      avatar_url: sequence(:avatar_url, &"https://example.com/user#{&1}.png"),
      profile_url: sequence(:profile_url, &"https://example.com/user#{&1}"),
      email: sequence(:email, &"user#{&1}@example.com")
    }
  end

  def commit_factory do
    %Network.Repository.Commit{
      authored_at: DateTime.utc_now(),
      author: build(:contributor)
    }
  end

  def repository_factory do
    %Network.Repository{
      id: sequence("id"),
      name: sequence("Repo"),
      description: "Description",
      url: sequence(:url, &"https://example.com/repos/repo#{&1}"),
      owner: build(:contributor),
      last_commit: build(:commit),
      language: build(:language),
      star_count: 0,
      watcher_count: 0,
      pull_request_count: 0,
      issue_count: 0
    }
  end
end
