defmodule TgCwibot do

  use Application

  def start(_, _) do
    TgCwibot.Supervisor.start_link()
  end

end
