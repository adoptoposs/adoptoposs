defmodule Adoptoposs.Factory do
  @moduledoc """
  Defines the factories to create records and resources
  """

  use ExMachina.Ecto, repo: Adoptoposs.Repo

  alias Adoptoposs.Network

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
