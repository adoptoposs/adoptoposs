defmodule Adoptoposs.JobsTest do
  use Adoptoposs.DataCase

  import Hammox
  import Adoptoposs.Factory

  alias Adoptoposs.{Jobs, Tags.Tag}

  describe "policy" do
    setup do
      {:ok, date} = Date.new(2222, 01, 01)
      {:ok, %{date: date}}
    end

    test "send_emails_monthly is permitted for the first permitted weekday of the month", %{
      date: date
    } do
      assert :ok = Bodyguard.permit(Jobs, :send_emails_monthly, date, 2)
      assert :ok = Bodyguard.permit(Jobs, :send_emails_monthly, date, "2")
    end

    test "send_emails_monthly is forbidden if not the first permitted weekday of the month", %{
      date: date
    } do
      # day is in first week of month but not the permitted weekday
      date_1 = date |> Timex.add(Timex.Duration.from_days(6))
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_monthly, date_1, 2)

      # day is the permitted weekday but not in the first week of the month
      date_2 = date |> Timex.add(Timex.Duration.from_days(7))
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_monthly, date_2, 2)

      # day is neither the permitted weekday nor in the first week of the month
      date_3 = date |> Timex.add(Timex.Duration.from_days(8))
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_monthly, date_3, 2)
    end

    test "send_emails_weekly is permitted if the given date is on the permitted weekday", %{
      date: date
    } do
      assert :ok = Bodyguard.permit(Jobs, :send_emails_weekly, date, 2)
      assert :ok = Bodyguard.permit(Jobs, :send_emails_weekly, date, "2")
    end

    test "send_emails_weekly is forbidden if the given date is not on the permitted weekday", %{
      date: date
    } do
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 1)
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 3)
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 4)
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 5)
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 6)
      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_weekly, date, 7)
    end

    test "send_emails_biweekly is permitted for the first permitted weekday of the month", %{
      date: date
    } do
      assert :ok = Bodyguard.permit(Jobs, :send_emails_biweekly, date, 2)
      assert :ok = Bodyguard.permit(Jobs, :send_emails_biweekly, date, "2")
    end

    test "send_emails_biweekly is permitted on the permitted weekday for the second half of the month" do
      {:ok, date} = Date.new(2222, 01, 15)

      assert :ok = Bodyguard.permit(Jobs, :send_emails_biweekly, date, 2)
      assert :ok = Bodyguard.permit(Jobs, :send_emails_biweekly, date, "2")
    end

    test "send_emails_biweekly is forbidden if the given date is not week 1 or week 3" do
      # First authorized day within the first two weeks of the month
      {:ok, date} = Date.new(2222, 01, 08)

      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_biweekly, date, 2)

      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_biweekly, date, "2")

      # First authorized day within the first two weeks of the month
      {:ok, date} = Date.new(2222, 01, 29)

      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_biweekly, date, 2)

      assert {:error, :unauthorized} = Bodyguard.permit(Jobs, :send_emails_biweekly, date, "2")
    end
  end

  describe "jobs" do
    use Bamboo.Test, shared: true

    @recommendations_subject "[Adoptoposs] Projects you might like to help maintain"

    defmock(PolicyMock, for: Bodyguard.Policy)

    setup do
      weekly_users = insert_list(2, :user, settings: %{email_project_recommendations: "weekly"})

      biweekly_users =
        insert_list(2, :user, settings: %{email_project_recommendations: "biweekly"})

      monthly_users = insert_list(2, :user, settings: %{email_project_recommendations: "monthly"})
      users = weekly_users ++ biweekly_users ++ monthly_users

      tag = insert(:tag, type: Tag.Language.type())
      insert(:project, language: tag)

      for user <- users do
        insert(:tag_subscription, user: user, tag: tag)
      end

      {:ok,
       %{weekly_users: weekly_users, biweekly_users: biweekly_users, monthly_user: monthly_users}}
    end

    test "send_project_recommendations/0 sends all weekly emails", %{
      weekly_users: weekly_users,
      biweekly_users: biweekly_users,
      monthly_user: monthly_users
    } do
      expect(PolicyMock, :authorize, 3, fn action, _, _ ->
        case action do
          :send_emails_weekly -> :ok
          :send_emails_biweekly -> :error
          :send_emails_monthly -> :error
          _ -> :error
        end
      end)

      assert [ok: {"weekly", emails}, error: {"biweekly", []}, error: {"monthly", []}] =
               Jobs.send_project_recommendations(PolicyMock)

      assert Enum.count(emails) == Enum.count(weekly_users)

      for {%{email: receiver}, index} <- Enum.with_index(weekly_users) do
        email = emails |> Enum.at(index)
        assert %{subject: @recommendations_subject, to: [nil: ^receiver]} = email
        assert_delivered_email(email)
      end

      for user <- biweekly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end

      for user <- monthly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end
    end

    test "send_project_recommendations/0 sends all biweekly emails", %{
      weekly_users: weekly_users,
      biweekly_users: biweekly_users,
      monthly_user: monthly_users
    } do
      expect(PolicyMock, :authorize, 3, fn action, _, _ ->
        case action do
          :send_emails_weekly -> :error
          :send_emails_biweekly -> :ok
          :send_emails_monthly -> :error
          _ -> :error
        end
      end)

      assert [error: {"weekly", []}, ok: {"biweekly", emails}, error: {"monthly", []}] =
               Jobs.send_project_recommendations(PolicyMock)

      assert Enum.count(emails) == Enum.count(biweekly_users)

      for {%{email: receiver}, index} <- Enum.with_index(biweekly_users) do
        email = emails |> Enum.at(index)
        assert %{subject: @recommendations_subject, to: [nil: ^receiver]} = email
        assert_delivered_email(email)
      end

      for user <- weekly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end

      for user <- monthly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end
    end

    test "send_project_recommendations/0 sends all monthly emails", %{
      weekly_users: weekly_users,
      biweekly_users: biweekly_users,
      monthly_user: monthly_users
    } do
      expect(PolicyMock, :authorize, 3, fn action, _, _ ->
        case action do
          :send_emails_weekly -> :error
          :send_emails_biweekly -> :error
          :send_emails_monthly -> :ok
          _ -> :error
        end
      end)

      assert [error: {"weekly", []}, error: {"biweekly", []}, ok: {"monthly", emails}] =
               Jobs.send_project_recommendations(PolicyMock)

      assert Enum.count(emails) == Enum.count(monthly_users)

      for {%{email: receiver}, index} <- Enum.with_index(monthly_users) do
        email = emails |> Enum.at(index)
        assert %{subject: @recommendations_subject, to: [nil: ^receiver]} = email
        assert_delivered_email(email)
      end

      for user <- weekly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end

      for user <- biweekly_users do
        refute_email_delivered_with(
          subject: @recommendations_subject,
          to: [nil: user.email]
        )
      end
    end
  end
end
