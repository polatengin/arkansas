using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Http.Extensions;

public static class TelemetryHelper
{
  private static TelemetryClient _telemetryClient;

  public static void Init()
  {
    var configuration = TelemetryConfiguration.CreateDefault();
    configuration.ConnectionString = Environment.GetEnvironmentVariable("APPLICATION_INSIGHTS_CONNECTION_STRING");
    _telemetryClient = new TelemetryClient(configuration);
    _telemetryClient.TrackTrace("Initialized TelemetryClient");
  }

  public static void TrackEvent(HttpContext context, string eventName)
  {
    var request = context.Request;
    var requestTelemetry = new RequestTelemetry
    {
      Name = request.Path,
      Url = new Uri(request.GetDisplayUrl()),
      Source = request.Host.Host,
    };
    _telemetryClient.TrackEvent(eventName, requestTelemetry.Properties, requestTelemetry.Metrics);
  }

  public static void TrackException(HttpContext context, System.Exception exception)
  {
    var request = context.Request;
    var requestTelemetry = new RequestTelemetry
    {
      Name = request.Path,
      Url = new Uri(request.GetDisplayUrl()),
      Source = request.Host.Host,
    };
    _telemetryClient.TrackException(exception, requestTelemetry.Properties, requestTelemetry.Metrics);
  }

  public static void TrackRequest(HttpContext context)
  {
    var request = context.Request;
    var response = context.Response;
    var requestTelemetry = new RequestTelemetry
    {
      Name = request.Path,
      Url = new Uri(request.GetDisplayUrl()),
      Source = request.Host.Host,
      ResponseCode = response.StatusCode.ToString(),
      Success = response.StatusCode < 400,
    };
    _telemetryClient.TrackRequest(requestTelemetry);
  }
}
