# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Adoptoposs.Repo.insert!(%Adoptoposs.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Faker.start()

defmodule Seed do
  import Adoptoposs.Factory

  @languages [
    "Elixir",
    "JavaScript",
    "Python",
    "C",
    "Ruby",
    "Java",
    "TypeScript",
    "Rust",
    "Kotlin",
    "C++"
  ]

  def create_projects(count) do
    user_count = ceil(count / 100)
    users = create_users(user_count)

    for _ <- 1..count do
      user = Enum.random(users)
      language = Enum.random(@languages)
      name = Faker.Internet.slug()
      repo = build(:repository, language: build(:language, name: language))

      insert(:project,
        user: user,
        language: language,
        name: name,
        data: repo
      )
    end

    IO.puts("Inserted #{user_count} users with #{count} projects.")
  end

  defp create_users(count) do
    Enum.map(1..count, fn _ ->
      username = Faker.Internet.user_name()

      insert(:user,
        uid: username,
        name: Faker.Name.name(),
        username: username,
        provider: "github",
        email: Faker.Internet.safe_email(),
        avatar_url: Faker.Internet.image_url(),
        profile_url: Faker.Internet.url()
      )
    end)
  end
end

Seed.create_projects(2000)
