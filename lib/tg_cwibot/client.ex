defmodule TgCwibot.Client do

  use Tesla

  require Logger

  @api_base "https://api.telegram.org/bot"

  adapter Tesla.Adapter.Hackney

  def client(token) do
    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, "#{@api_base}#{token}"},
      {Tesla.Middleware.Logger, nil},
      {Tesla.Middleware.EncodeJson, nil},
    ]
  end

  def answerInlineQuery(c, result) do
    post(c, "/answerInlineQuery", result)
  end

  def answerInlineQuery(result), do: answerInlineQuery(client(), result)

  def setWebHook(c, url) do
    Logger.debug("client: #{inspect c}")
    post(c, "/setWebhook", %{"url" => url})
  end

  def setWebhook(url), do: setWebHook(client(), url)

  def deleteWebhook(c) do
    post(c, "/deleteWebhook", %{})
  end

  def deleteWebhook(), do: deleteWebhook(client())

  def getWebhookInfo(c) do
    post(c, "/getWebhookInfo", %{})
  end

  def getWebhookInfo(), do: getWebhookInfo(client())

  defp client() do
    Application.get_env(:tg_cwibot, :token)
    |> IO.inspect()
    |> client()
  end

  def setup() do
    host = Application.get_env(:tg_cwibot, :host)
    endpoint = Application.get_env(:tg_cwibot, :endpoint)
    url = "#{host}/#{endpoint}"
    Logger.info("Setting webhook endpoint to #{url}")
    %Tesla.Env{status: 200} = setWebhook(url)
    :ok
  end


end
