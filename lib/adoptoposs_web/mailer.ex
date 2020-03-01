defmodule AdoptopossWeb.Mailer do
  @moduledoc """
  Defines functions for (async) delivering emails
  """

  use Bamboo.Mailer, otp_app: :adoptoposs

  alias AdoptopossWeb.Email
end
