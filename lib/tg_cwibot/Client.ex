defmodule TgCwibot.Client do

  use Tesla

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://api.telegram.org/bot303531014:AAG7Y17zsKCECfZCWlhDge8Pi8PfghE0vf0"
  # plug Tesla.Middleware.BaseUrl, "http://localhost:8123/bot303531014:AAG7Y17zsKCECfZCWlhDge8Pi8PfghE0vf0"
  plug Tesla.Middleware.EncodeJson

  adapter Tesla.Adapter.Hackney

  def answerInlineQuery(result) do
    IO.inspect result
    IO.inspect post("/answerInlineQuery", result)
  end

  def setWebHook(url) do
    post("/setWebhook", %{"url" => url})
  end

  def deleteWebhook() do
    post("/deleteWebhook", %{})
  end

  def getWebhookInfo() do
    post("/getWebhookInfo", %{})
  end


end
