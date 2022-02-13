defmodule Adoptoposs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Adoptoposs.Repo,
      # Start the Telemetry supervisor
      AdoptopossWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Adoptoposs.PubSub},
      # Start the endpoint (http/https)
      AdoptopossWeb.Endpoint,
      # Start scheduler for Quantum tasks
      Adoptoposs.Scheduler
      # Starts a worker by calling: Adoptoposs.Worker.start_link(arg)
      # {Adoptoposs.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Adoptoposs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AdoptopossWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
