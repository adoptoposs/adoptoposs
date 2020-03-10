defmodule Adoptoposs.Tags.Policy do
  @behaviour Bodyguard.Policy

  import Ecto.Query, only: [where: 2]
  alias Adoptoposs.Repo
  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Tags.{Tag, TagSubscription}

  def authorize(:create_tag_subscription, %User{id: user_id}, %Tag{id: tag_id}) do
    count =
      TagSubscription
      |> where(user_id: ^user_id, tag_id: ^tag_id)
      |> Repo.aggregate(:count)

    if count == 0, do: :ok, else: :error
  end

  def authorize(:delete_tag_subscription, %User{id: user_id}, %TagSubscription{user_id: user_id}),
    do: :ok

  def authorize(:delete_tag_subscription, %User{}, %TagSubscription{}), do: :error
end
