defmodule TgCwibot.Supervisor do

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end


  def init(_) do
    children = [
      worker(TgCwibot.Handler, [])
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__)
  end

end
