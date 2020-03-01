defmodule AdoptopossWeb.Mailer do
  @moduledoc """
  Defines functions for (async) delivering emails
  """

  use Bamboo.Mailer, otp_app: :adoptoposs

  alias AdoptopossWeb.Email

  def send_interest_received_email(interest) do
    deliver_later(Email.interest_received_email(interest))
  end
end
