defmodule TgCwibot do

  use Application

  def start(_, _) do
    TgCwibot.Client.setup()
    TgCwibot.Supervisor.start_link()
  end

end
