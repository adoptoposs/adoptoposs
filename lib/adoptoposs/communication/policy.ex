defmodule Adoptoposs.Communication.Policy do
  @behaviour Bodyguard.Policy

  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Dashboard.Project

  def authorize(:create_interest, %User{id: user_id}, %Project{user_id: user_id}), do: :error
  def authorize(:create_interest, %User{}, %Project{}), do: :ok
end
