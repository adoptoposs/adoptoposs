defmodule AdoptopossWeb.MailerTest do
  use ExUnit.Case, async: true
  use Bamboo.Test

  import Adoptoposs.Factory

  alias AdoptopossWeb.Mailer

  test "send interest received email" do
    interest = build(:interest, inserted_at: DateTime.utc_now() ,project: build(:project, id: 1))
    assert_delivered_email Mailer.send_interest_received_email(interest)
  end
end
